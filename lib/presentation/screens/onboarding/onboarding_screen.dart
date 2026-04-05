import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      icon: Icons.calendar_month,
      title: 'Track Your Cycle',
      description:
          'Effortlessly log and monitor your menstrual cycle. Get accurate predictions, '
          'timely reminders, and understand your body\'s unique rhythm with smart insights.',
    ),
    _OnboardingPageData(
      icon: Icons.medical_services,
      title: 'Expert Consultations',
      description:
          'Connect with trusted gynecologists, breast health specialists, and wellness experts '
          'from the comfort of your home. Book appointments with just a tap.',
    ),
    _OnboardingPageData(
      icon: Icons.favorite,
      title: 'Holistic Wellness',
      description:
          'Explore personalized nutrition plans, guided fitness routines, and mental health '
          'resources designed exclusively for women at every stage of life.',
    ),
  ];

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  Future<void> _completeOnboarding() async {
    await LocalStorageService.setOnboardingDone();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 16),
                child: isLastPage
                    ? const SizedBox(height: 48)
                    : TextButton(
                        onPressed: _skipToEnd,
                        child: Text(
                          'Skip',
                          style: AppTextStyles.subtitle2.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _OnboardingPage(data: page);
                },
              ),
            ),

            // Dot indicator
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _pages.length,
                effect: WormEffect(
                  dotHeight: 10,
                  dotWidth: 10,
                  activeDotColor: AppColors.primary,
                  dotColor: AppColors.secondary.withOpacity(0.4),
                  spacing: 12,
                ),
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLastPage
                      ? _completeOnboarding
                      : () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isLastPage ? 'Get Started' : 'Next',
                    style: AppTextStyles.button,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon in a circle
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
            ),
            child: Icon(
              data.icon,
              size: 80,
              color: AppColors.primary,
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 500.ms),
          const SizedBox(height: 40),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.h1.copyWith(
              color: AppColors.primary,
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 500.ms)
              .slideY(begin: 0.2, end: 0, duration: 500.ms),
          const SizedBox(height: 16),

          // Description
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textMuted,
              height: 1.6,
            ),
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 500.ms)
              .slideY(begin: 0.2, end: 0, duration: 500.ms),
        ],
      ),
    );
  }
}
