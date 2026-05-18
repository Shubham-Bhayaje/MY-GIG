import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_state.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_shell.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Firebase
      if (kIsWeb) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyCXrXhZMBGfNIDE1rAgTryQvG-IFuTlK1A',
            appId: '1:850386777127:android:057c2fe08aa58d50790a02',
            messagingSenderId: '850386777127',
            projectId: 'hyperlocalgig',
            storageBucket: 'hyperlocalgig.firebasestorage.app',
          ),
        );
      } else {
        await Firebase.initializeApp();
      }

      // Register FCM background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Catch Flutter framework errors
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        debugPrint('[FLUTTER ERROR] ${details.exceptionAsString()}');
      };

      // Catch errors that happen outside the Flutter context
      PlatformDispatcher.instance.onError = (error, stack) {
        debugPrint('[PLATFORM ERROR] $error');
        return true;
      };

      // Global Error Screen
      ErrorWidget.builder = (FlutterErrorDetails details) {
        return const GlobalErrorScreen();
      };

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.primaryDark,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );
      runApp(const HyperLocalGigApp());
    },
    (error, stackTrace) {
      debugPrint('[ZONED ERROR] $error');
    },
  );
}

class GlobalErrorScreen extends StatelessWidget {
  const GlobalErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.primaryDark,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.error_outline, color: AppColors.error, size: 64),
              SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please restart the app.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HyperLocalGigApp extends StatelessWidget {
  const HyperLocalGigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'GigMap - HyperLocal Jobs',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthGate(),
      ),
    );
  }
}

/// Checks if user is already logged in via Firebase Auth.
/// If yes, skips onboarding/login and goes straight to MainShell.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    // Defer to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
  }

  Future<void> _checkAuth() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && mounted) {
        // User is already signed in — sync with AppState (silent, no notifyListeners)
        final appState = context.read<AppState>();
        appState.loginSilent(
          name: user.displayName ?? '',
          email: user.email ?? '',
          phone: user.phoneNumber ?? '',
          uid: user.uid,
        );

        // Initialize FCM for this user
        NotificationService().init(user.uid);
        // Subscribe to 'new_gigs' topic so all workers get notified
        NotificationService().subscribeToTopic('new_gigs');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to restore session: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _checking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      // Show splash while checking auth
      return Scaffold(
        backgroundColor: AppColors.primaryDark,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accentCyan, AppColors.accentPurple],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    'assets/images/LOGO.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'GigMap',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return const MainShell();
    }
    return const OnboardingScreen();
  }
}
