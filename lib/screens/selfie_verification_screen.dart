import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../core/theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'main_shell.dart';

/// Mandatory selfie verification screen shown after sign-up.
/// User must take a face selfie before they can proceed to the app.
class SelfieVerificationScreen extends StatefulWidget {
  final String uid;
  final String userName;
  final VoidCallback onVerified;

  const SelfieVerificationScreen({
    super.key,
    required this.uid,
    required this.userName,
    required this.onVerified,
  });

  @override
  State<SelfieVerificationScreen> createState() =>
      _SelfieVerificationScreenState();
}

class _SelfieVerificationScreenState extends State<SelfieVerificationScreen> {
  File? _selfieFile;
  bool _isUploading = false;
  String? _errorMessage;

  Future<void> _takeSelfie() async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 60,
      );

      if (photo != null) {
        setState(() {
          _selfieFile = File(photo.path);
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not open camera. Please grant camera permission.';
      });
    }
  }

  Future<void> _uploadAndProceed() async {
    if (_selfieFile == null) return;

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      // Upload selfie to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('selfies/${widget.uid}.jpg');
      await storageRef.putFile(_selfieFile!);
      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .set({
        'avatarUrl': downloadUrl,
        'selfieVerified': true,
        'selfieUploadedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('[SELFIE] Saved selfie URL for ${widget.uid}: $downloadUrl');

      if (!mounted) return;

      // Navigate to app directly from here
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('[SELFIE] Save error: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Upload failed. Please try again.';
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF050505), AppColors.primaryDark],
              ),
            ),
          ),

          // Decorative glow
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentCyan.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Header
                  Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accentCyan,
                              AppColors.accentPurple,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentCyan.withValues(alpha: 0.3),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.face_retouching_natural_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Verify Your Identity',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hey ${widget.userName.split(' ').first}! Take a quick selfie to verify your account. This helps keep GigMap safe.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, duration: 500.ms),

                  const SizedBox(height: 32),

                  // Selfie preview area
                  Expanded(
                    child: _selfieFile != null
                        ? _buildSelfiePreview()
                        : _buildCameraPrompt(),
                  ),

                  const SizedBox(height: 16),

                  // Error message
                  if (_errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: AppColors.error, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: AppColors.error, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Guidelines
                  GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        _buildGuidelineRow(Icons.wb_sunny_outlined, 'Good lighting on your face'),
                        const SizedBox(height: 8),
                        _buildGuidelineRow(Icons.face_outlined, 'Face clearly visible, no masks'),
                        const SizedBox(height: 8),
                        _buildGuidelineRow(Icons.shield_outlined, 'Photo stored securely & privately'),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                  const SizedBox(height: 16),

                  // Action buttons
                  if (_selfieFile == null)
                    // Take selfie button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _takeSelfie,
                        icon: const Icon(Icons.camera_alt_rounded, size: 22),
                        label: const Text(
                          'Take Selfie',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentCyan,
                          foregroundColor: AppColors.primaryDark,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 400.ms)
                  else
                    // Retake / Continue buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isUploading ? null : _takeSelfie,
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Retake'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              side: BorderSide(color: AppColors.divider),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _isUploading ? null : _uploadAndProceed,
                            icon: _isUploading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primaryDark,
                                    ),
                                  )
                                : const Icon(Icons.check_circle_rounded, size: 20),
                            label: Text(
                              _isUploading ? 'Uploading...' : 'Looks Good!',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 300.ms),

                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPrompt() {
    return Center(
      child: GlassCard(
        padding: const EdgeInsets.all(40),
        borderRadius: 24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceLight,
                border: Border.all(
                  color: AppColors.accentCyan.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.person_rounded,
                size: 60,
                color: AppColors.textMuted.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No selfie taken yet',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap the button below to open camera',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).scale(
          begin: const Offset(0.95, 0.95),
          duration: 400.ms,
        );
  }

  Widget _buildSelfiePreview() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accentGreen,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGreen.withValues(alpha: 0.2),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.file(
                _selfieFile!,
                fit: BoxFit.cover,
                width: 200,
                height: 200,
              ),
            ),
          ).animate().fadeIn(duration: 400.ms).scale(
                begin: const Offset(0.8, 0.8),
                duration: 400.ms,
                curve: Curves.easeOutBack,
              ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: AppColors.accentGreen, size: 18),
              const SizedBox(width: 6),
              const Text(
                'Selfie captured!',
                style: TextStyle(
                  color: AppColors.accentGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.accentCyan),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }
}
