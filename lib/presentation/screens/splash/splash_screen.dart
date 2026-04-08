import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    String route;
    try {
      if (!LocalStorageService.isOnboardingDone) {
        route = AppRoutes.onboarding;
      } else if (!FirebaseAuthService.isLoggedIn && !LocalStorageService.isLoggedIn) {
        route = AppRoutes.login;
      } else {
        route = AppRoutes.home;
      }
    } catch (_) {
      // Fallback if Firebase isn't available
      route = LocalStorageService.isOnboardingDone
          ? (LocalStorageService.isLoggedIn ? AppRoutes.home : AppRoutes.login)
          : AppRoutes.onboarding;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Naarya logo
            Image.asset(
              AssetPaths.logo,
              width: 260,
              fit: BoxFit.contain,
            )
                .animate()
                .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                .slideY(begin: -0.3, end: 0, duration: 800.ms, curve: Curves.easeOut),
            const SizedBox(height: 16),

            // Tagline
            Text(
              AppConstants.appTagline,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.primary.withValues(alpha: 0.7),
                letterSpacing: 0.5,
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 800.ms, curve: Curves.easeOut)
                .slideY(begin: 0.3, end: 0, duration: 800.ms, curve: Curves.easeOut),
          ],
        ),
      ),
    );
  }
}
