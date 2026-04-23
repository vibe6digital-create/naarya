import 'package:flutter/material.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class PetUpgradeScreen extends StatelessWidget {
  const PetUpgradeScreen({super.key});

  static const _levels = [
    _UpgradeLevel(
      level: 1,
      title: 'Default',
      description: 'Your pet is at its base form.',
      icon: Icons.star_outline_rounded,
      unlocked: true,
    ),
    _UpgradeLevel(
      level: 2,
      title: 'Glow Effect',
      description: 'Your pet shines with a soft aura.',
      icon: Icons.auto_awesome_rounded,
      unlocked: false,
    ),
    _UpgradeLevel(
      level: 3,
      title: 'Animation',
      description: 'Your pet comes to life with unique animations.',
      icon: Icons.animation_rounded,
      unlocked: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final petIndex = LocalStorageService.selectedPetIndex;
    final assetPath = petIndex > 0
        ? 'assets/images/pet$petIndex.png'
        : 'assets/images/pet1.png';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textDark, size: 20),
        ),
        title: Text('Upgrade Your Pet', style: AppTextStyles.h2),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Current pet display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.08),
                    AppColors.primaryLight.withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Image.asset(assetPath, width: 100, height: 100,
                      fit: BoxFit.contain),
                  const SizedBox(height: 12),
                  Text('Your Pet', style: AppTextStyles.subtitle1),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Level 1 · Default',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Upgrade Levels',
                  style: AppTextStyles.h3
                      .copyWith(color: AppColors.textDark)),
            ),
            const SizedBox(height: 16),
            ..._levels.map((lvl) => _buildLevelTile(lvl)),
            const SizedBox(height: 32),
            // Coming soon notice
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.textMuted, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Pet upgrades will be available soon. Stay tuned!',
                      style: AppTextStyles.body2
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelTile(_UpgradeLevel lvl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lvl.unlocked ? AppColors.surface : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: lvl.unlocked
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: lvl.unlocked
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              lvl.icon,
              color: lvl.unlocked ? AppColors.primary : AppColors.textMuted,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Level ${lvl.level}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: lvl.unlocked
                            ? AppColors.primary
                            : AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('·', style: AppTextStyles.body2),
                    const SizedBox(width: 6),
                    Text(lvl.title, style: AppTextStyles.subtitle1),
                  ],
                ),
                const SizedBox(height: 2),
                Text(lvl.description, style: AppTextStyles.body2),
              ],
            ),
          ),
          if (lvl.unlocked)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Active',
                style: AppTextStyles.labelSmall
                    .copyWith(color: Colors.white),
              ),
            )
          else
            const Icon(Icons.lock_outline_rounded,
                color: AppColors.textMuted, size: 18),
        ],
      ),
    );
  }
}

class _UpgradeLevel {
  final int level;
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;

  const _UpgradeLevel({
    required this.level,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
  });
}
