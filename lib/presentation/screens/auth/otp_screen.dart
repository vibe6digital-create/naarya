import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  int _resendCountdown = 30;
  Timer? _timer;
  String _phoneNumber = '';
  String _verificationId = '';
  int? _resendToken;
  bool _argsLoaded = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsLoaded) return;
    _argsLoaded = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _phoneNumber = args['phone'] as String? ?? LocalStorageService.userPhone;
      _verificationId = args['verificationId'] as String? ?? '';
      _resendToken = args['resendToken'] as int?;
    } else {
      _phoneNumber = LocalStorageService.userPhone;
    }
  }

  void _startCountdown() {
    _resendCountdown = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown <= 0) {
        timer.cancel();
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  String get _maskedPhone {
    if (_phoneNumber.length >= 10) {
      return '+91 ${_phoneNumber.substring(0, 2)}XXXXXX${_phoneNumber.substring(8)}';
    }
    return '+91 $_phoneNumber';
  }

  Future<void> _onVerify() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      _showError('Please enter the complete 6-digit OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await FirebaseAuthService.signInWithOtp(
        verificationId: _verificationId,
        otp: otp,
      );

      if (result.user != null) {
        await FirestoreService.saveOrUpdateUser(
          result.user!,
          phone: _phoneNumber,
          city: LocalStorageService.userCity,
        );
      }

      await LocalStorageService.setLoggedIn(true);

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      String message = 'Verification failed. Please try again.';
      if (e.toString().contains('invalid-verification-code')) {
        message = 'Invalid OTP. Please check and try again.';
      } else if (e.toString().contains('session-expired')) {
        message = 'OTP has expired. Please request a new one.';
      }
      _showError(message);
    }
  }

  void _onResendOtp() {
    if (_resendCountdown > 0) return;

    setState(() => _isLoading = true);

    FirebaseAuthService.verifyPhoneNumber(
      phoneNumber: '+91$_phoneNumber',
      resendToken: _resendToken,
      onCodeSent: (verificationId, resendToken) {
        if (!mounted) return;
        setState(() {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _isLoading = false;
        });
        _startCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('OTP resent successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
          ),
        );
      },
      onAutoVerified: (credential) async {
        try {
          final result = await FirebaseAuthService.signInWithCredential(credential);
          if (result.user != null) {
            await FirestoreService.saveOrUpdateUser(
              result.user!,
              phone: _phoneNumber,
              city: LocalStorageService.userCity,
            );
          }
          await LocalStorageService.setLoggedIn(true);
          if (!mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
        } catch (_) {
          if (!mounted) return;
          setState(() => _isLoading = false);
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showError(error);
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // Lock icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 36,
                  color: AppColors.primary,
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 500.ms),
              const SizedBox(height: 28),

              // Title
              Text(
                'Verify OTP',
                style: AppTextStyles.h1.copyWith(color: AppColors.primary),
              )
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 500.ms),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Enter the OTP sent to $_maskedPhone',
                textAlign: TextAlign.center,
                style: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
              )
                  .animate()
                  .fadeIn(delay: 250.ms, duration: 500.ms),
              const SizedBox(height: 40),

              // PIN code field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PinCodeTextField(
                  appContext: context,
                  length: AppConstants.otpLength,
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  autoFocus: true,
                  cursorColor: AppColors.primary,
                  textStyle: AppTextStyles.h1.copyWith(
                    color: AppColors.textDark,
                    fontSize: 22,
                  ),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    fieldHeight: 54,
                    fieldWidth: 46,
                    activeFillColor: AppColors.surface,
                    inactiveFillColor: AppColors.surface,
                    selectedFillColor: AppColors.surface,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.border,
                    selectedColor: AppColors.primary,
                    borderWidth: 1.5,
                  ),
                  enableActiveFill: true,
                  onChanged: (_) {},
                  onCompleted: (_) => _onVerify(),
                ),
              ),
              const SizedBox(height: 32),

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onVerify,
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
                      : Text('Verify', style: AppTextStyles.button),
                ),
              ),
              const SizedBox(height: 24),

              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
                  ),
                  GestureDetector(
                    onTap: _resendCountdown == 0 ? _onResendOtp : null,
                    child: Text(
                      _resendCountdown > 0
                          ? 'Resend in ${_resendCountdown}s'
                          : 'Resend OTP',
                      style: AppTextStyles.body2.copyWith(
                        color: _resendCountdown > 0
                            ? AppColors.textLight
                            : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
