import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;

  User? get currentUser => auth.currentUser;
  bool get isLoggedIn => auth.currentUser != null;
  String? get uid => auth.currentUser?.uid;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => auth.authStateChanges();

  // === Email & Password ===
  Future<String?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Update display name
      await credential.user?.updateDisplayName(name);
      notifyListeners();
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  // === Phone OTP ===
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    required Function(PhoneAuthCredential credential) onAutoVerify,
  }) async {
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verify (Android auto-retrieval)
        onAutoVerify(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(_getErrorMessage(e.code));
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<String?> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      await auth.signInWithCredential(credential);
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    } catch (e) {
      return 'Invalid OTP. Please try again.';
    }
  }

  // === Sign Out ===
  Future<void> signOut() async {
    await auth.signOut();
    notifyListeners();
  }

  // === Password Reset ===
  Future<String?> sendPasswordReset(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    } catch (e) {
      return 'Something went wrong.';
    }
  }

  // Error message helper
  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'invalid-phone-number':
        return 'Invalid phone number format.';
      case 'invalid-verification-code':
        return 'Invalid OTP code.';
      case 'session-expired':
        return 'OTP expired. Request a new one.';
      default:
        return 'An error occurred ($code).';
    }
  }
}
