import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class NaaryaButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isOutlined;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const NaaryaButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isOutlined = false,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: _buildChild(AppColors.primary),
        ),
      );
    }
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: _buildChild(AppColors.textOnPrimary),
      ),
    );
  }

  Widget _buildChild(Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: textColor,
        ),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text, style: AppTextStyles.button.copyWith(color: textColor)),
        ],
      );
    }
    return Text(text, style: AppTextStyles.button.copyWith(color: textColor));
  }
}
