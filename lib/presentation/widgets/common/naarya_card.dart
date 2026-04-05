import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_spacing.dart';

class NaaryaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final Border? border;

  const NaaryaCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color ?? AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: border ?? Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          boxShadow: AppColors.cardShadow,
        ),
        child: child,
      ),
    );
  }
}
