import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class QuickActionCard extends StatelessWidget {
  final IconData icon;

  /// Large decorative icon shown in the bottom-right illustration blob.
  /// Defaults to [icon] if not provided.
  final IconData? illustrationIcon;

  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBackgroundColor;
  final bool isComingSoon;
  final VoidCallback? onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    this.illustrationIcon,
    required this.title,
    this.subtitle = '',
    required this.iconColor,
    required this.iconBackgroundColor,
    this.isComingSoon = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final illIcon = illustrationIcon ?? icon;
    final effectiveColor = isComingSoon ? AppColors.textLight : iconColor;
    final effectiveBg = isComingSoon
        ? AppColors.surfaceVariant
        : iconBackgroundColor;

    return GestureDetector(
      onTap: isComingSoon ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
          border: Border.all(color: AppColors.border, width: 0.8),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // ── Illustration blob — bottom-right, partially clipped ──
            Positioned(
              right: -22,
              bottom: -22,
              child: Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  color: effectiveBg.withValues(alpha: isComingSoon ? 0.5 : 0.72),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Padding(
                    // nudge icon slightly toward card center so it's visible
                    padding: const EdgeInsets.only(right: 22, bottom: 22),
                    child: Icon(
                      illIcon,
                      size: 52,
                      color: effectiveColor.withValues(
                          alpha: isComingSoon ? 0.35 : 0.52),
                    ),
                  ),
                ),
              ),
            ),

            // ── Coming Soon badge — top right ──
            if (isComingSoon)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Soon',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

            // ── Main content ──
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: AppTextStyles.subtitle2.copyWith(
                      color: isComingSoon
                          ? AppColors.textLight
                          : AppColors.textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Subtitle
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const Spacer(),

                  // Small icon circle — bottom left
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: effectiveBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: effectiveColor,
                      size: 18,
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
}
