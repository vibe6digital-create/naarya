import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../widgets/common/markdown_content_view.dart';
import '../../widgets/common/naarya_card.dart';

class CancerDetailScreen extends StatelessWidget {
  final String title;
  final String assetPath;
  final List<String> warningSigns;
  final List<String> screeningGuidelines;

  const CancerDetailScreen({
    super.key,
    required this.title,
    required this.assetPath,
    this.warningSigns = const [],
    this.screeningGuidelines = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title, style: AppTextStyles.h3),
        backgroundColor: AppColors.surface,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Markdown content
            MarkdownContentView(assetPath: assetPath),

            if (warningSigns.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sectionGap),
              _buildWarningSignsCard(),
            ],

            if (screeningGuidelines.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sectionGap),
              _buildScreeningGuidelinesCard(),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningSignsCard() {
    return NaaryaCard(
      color: AppColors.errorLight,
      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Warning Signs',
                style: AppTextStyles.h3.copyWith(color: AppColors.error),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...warningSigns.map(
            (sign) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      sign,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreeningGuidelinesCard() {
    return NaaryaCard(
      color: AppColors.successLight,
      border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.checklist_outlined,
                color: AppColors.success,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Screening Guidelines',
                style: AppTextStyles.h3.copyWith(color: AppColors.success),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...screeningGuidelines.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
