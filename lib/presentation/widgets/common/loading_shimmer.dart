import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';

class LoadingShimmer extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const LoadingShimmer({
    super.key,
    this.height = 100,
    this.width = double.infinity,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.surfaceVariant,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  static Widget list({int count = 3, double itemHeight = 80}) {
    return Column(
      children: List.generate(
        count,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: LoadingShimmer(height: itemHeight),
        ),
      ),
    );
  }
}
