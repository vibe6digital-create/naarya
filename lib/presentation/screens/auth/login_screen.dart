import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../core/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _selectedCity = AppConstants.cities.first;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final phone = _phoneController.text.trim();
    final fullPhone = '+91$phone';

    await LocalStorageService.setUserPhone(phone);
    await LocalStorageService.setUserCity(_selectedCity);

    // If Firebase isn't available, bypass auth for simulator testing
    if (!FirebaseAuthService.isAvailable) {
      await LocalStorageService.setLoggedIn(true);
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
      return;
    }

    FirebaseAuthService.verifyPhoneNumber(
      phoneNumber: fullPhone,
      onCodeSent: (verificationId, resendToken) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.of(context).pushNamed(
          AppRoutes.otpVerify,
          arguments: {
            'phone': phone,
            'verificationId': verificationId,
            'resendToken': resendToken,
          },
        );
      },
      onAutoVerified: (credential) async {
        try {
          await FirebaseAuthService.signInWithCredential(credential);
          if (!mounted) return;
          await LocalStorageService.setLoggedIn(true);
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.home,
            (route) => false,
          );
        } catch (e) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          _showError('Auto-verification failed. Please enter OTP manually.');
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showError(error);
      },
    );
  }

  Future<void> _onGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final result = await FirebaseAuthService.signInWithGoogle();
      if (result == null) {
        // User cancelled
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }

      // Save user info from Google account
      final user = result.user;
      if (user != null) {
        await LocalStorageService.setLoggedIn(true);
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          await LocalStorageService.setUserName(user.displayName!);
        }
        if (user.email != null && user.email!.isNotEmpty) {
          await LocalStorageService.setUserEmail(user.email!);
        }
        if (user.photoURL != null && user.photoURL!.isNotEmpty) {
          await LocalStorageService.setUserPhotoUrl(user.photoURL!);
        }
        if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
          await LocalStorageService.setUserPhone(user.phoneNumber!);
        }
      }

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Google sign-in failed. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),

                // App logo
                Center(
                  child: Image.asset(
                    AssetPaths.icon,
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 600.ms),
                const SizedBox(height: 32),

                // Welcome text
                Center(
                  child: Text(
                    'Welcome to ${AppConstants.appName}',
                    style: AppTextStyles.h1.copyWith(color: AppColors.primary),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 500.ms)
                    .slideY(begin: 0.15, end: 0, duration: 500.ms),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    AppConstants.appTagline,
                    style: AppTextStyles.subtitle2,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 500.ms),
                const SizedBox(height: 48),

                // Phone label
                Text(
                  'Phone Number',
                  style: AppTextStyles.subtitle1.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),

                // Phone input
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: Validators.phone,
                  style: AppTextStyles.body1.copyWith(color: AppColors.textDark),
                  decoration: InputDecoration(
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '+91',
                            style: AppTextStyles.body1.copyWith(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(width: 1, height: 24, color: AppColors.border),
                        ],
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                    hintText: 'Enter your phone number',
                    hintStyle: AppTextStyles.body1.copyWith(color: AppColors.textLight),
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // City label
                Text(
                  'Select Your City',
                  style: AppTextStyles.subtitle1.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),

                // City dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  items: AppConstants.cities
                      .map(
                        (city) => DropdownMenuItem(
                          value: city,
                          child: Text(
                            city,
                            style: AppTextStyles.body1.copyWith(color: AppColors.textDark),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCity = value);
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
                  dropdownColor: AppColors.surface,
                ),
                const SizedBox(height: 40),

                // Send OTP button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onSendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text('Send OTP', style: AppTextStyles.button),
                  ),
                ),
                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.border)),
                  ],
                ),
                const SizedBox(height: 24),

                // Google Sign-In button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _onGoogleSignIn,
                    icon: const Icon(
                      Icons.g_mobiledata,
                      size: 28,
                      color: AppColors.textDark,
                    ),
                    label: Text(
                      'Continue with Google',
                      style: AppTextStyles.button.copyWith(color: AppColors.textDark),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                      ),
                      backgroundColor: AppColors.surface,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Test number hint
                Center(
                  child: Text(
                    'Test: +91 91588 56817 / OTP: 123456',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
