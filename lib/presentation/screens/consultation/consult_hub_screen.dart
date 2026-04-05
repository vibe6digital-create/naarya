import 'package:flutter/material.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../widgets/common/naarya_card.dart';
import '../content_pages/content_page_screen.dart';

class _ConsultCategory {
  final IconData icon;
  final String title;
  final String description;
  final Color iconColor;
  final Color iconBgColor;
  final String? routeName;
  final Widget Function(BuildContext)? pageBuilder;

  const _ConsultCategory({
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
    required this.iconBgColor,
    this.routeName,
    this.pageBuilder,
  });
}

class ConsultHubScreen extends StatelessWidget {
  const ConsultHubScreen({super.key});

  static final List<_ConsultCategory> _categories = [
    _ConsultCategory(
      icon: Icons.pregnant_woman,
      title: 'Gynecology Consultation',
      description: 'Expert gynecology care with Dr. Niyati and team',
      iconColor: const Color(0xFFAD1457),
      iconBgColor: const Color(0xFFFCE4EC),
      routeName: AppRoutes.gynecConsult,
    ),
    _ConsultCategory(
      icon: Icons.health_and_safety,
      title: 'Breast Health',
      description: 'Breast health awareness and specialist consultation',
      iconColor: const Color(0xFFC2185B),
      iconBgColor: const Color(0xFFF8BBD0),
      routeName: AppRoutes.breastConsult,
    ),
    _ConsultCategory(
      icon: Icons.psychology,
      title: 'Mental Fitness',
      description: 'Mental health support and counseling',
      iconColor: const Color(0xFF5C6BC0),
      iconBgColor: const Color(0xFFE8EAF6),
      routeName: AppRoutes.mentalFitness,
      pageBuilder: (_) => const ContentPageScreen(
        title: 'Mental Fitness',
        assetPath: AssetPaths.mentalFitness,
        showWhatsappCta: true,
      ),
    ),
    _ConsultCategory(
      icon: Icons.self_improvement,
      title: 'Mind & Body Healing',
      description: 'Mindfulness, meditation, and holistic healing',
      iconColor: const Color(0xFF00897B),
      iconBgColor: const Color(0xFFE0F2F1),
      routeName: AppRoutes.mindBodyHealing,
      pageBuilder: (_) => const ContentPageScreen(
        title: 'Mind & Body Healing',
        assetPath: AssetPaths.mindBodyHealing,
        showWhatsappCta: true,
      ),
    ),
    _ConsultCategory(
      icon: Icons.face,
      title: 'Skin & Hair',
      description: 'Dermatology consultation for skin and hair',
      iconColor: const Color(0xFFEF6C00),
      iconBgColor: const Color(0xFFFFF3E0),
      routeName: AppRoutes.skinHair,
      pageBuilder: (_) => const ContentPageScreen(
        title: 'Skin & Hair',
        assetPath: AssetPaths.skinHair,
        showWhatsappCta: true,
      ),
    ),
    _ConsultCategory(
      icon: Icons.restaurant_menu,
      title: 'Nutrition',
      description: 'Personalized diet plans and nutrition guidance',
      iconColor: const Color(0xFF2E7D32),
      iconBgColor: const Color(0xFFE8F5E9),
      routeName: AppRoutes.nutrition,
    ),
    _ConsultCategory(
      icon: Icons.fitness_center,
      title: 'Physical Fitness',
      description: 'Workout recommendations and fitness guidance',
      iconColor: const Color(0xFF1565C0),
      iconBgColor: const Color(0xFFE3F2FD),
      routeName: AppRoutes.fitness,
    ),
    _ConsultCategory(
      icon: Icons.gavel,
      title: 'Legal Help',
      description: 'Know your rights as a woman',
      iconColor: const Color(0xFF4E342E),
      iconBgColor: const Color(0xFFEFEBE9),
      routeName: AppRoutes.legalHelp,
      pageBuilder: (_) => const ContentPageScreen(
        title: 'Legal Help',
        assetPath: AssetPaths.legalHelp,
        showWhatsappCta: true,
      ),
    ),
  ];

  void _onCategoryTap(BuildContext context, _ConsultCategory category) {
    if (category.pageBuilder != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: category.pageBuilder!),
      );
    } else if (category.routeName != null) {
      Navigator.pushNamed(context, category.routeName!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Consult & Services', style: AppTextStyles.h2),
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: ListView.separated(
        padding: AppSpacing.pagePadding,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final category = _categories[index];
          return NaaryaCard(
            onTap: () => _onCategoryTap(context, category),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: category.iconBgColor,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  ),
                  child: Icon(
                    category.icon,
                    color: category.iconColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        style: AppTextStyles.subtitle1.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        category.description,
                        style: AppTextStyles.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textLight,
                  size: 22,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
