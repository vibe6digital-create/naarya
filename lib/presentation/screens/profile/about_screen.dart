import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../widgets/common/markdown_content_view.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('About Naarya', style: AppTextStyles.h2),
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownContentView(assetPath: AssetPaths.about),
            const SizedBox(height: AppSpacing.sectionGap),
            Center(
              child: Column(
                children: [
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: AppSpacing.lg),
                  Image.asset(
                    AssetPaths.logo,
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    AppConstants.appTagline,
                    style: AppTextStyles.subtitle2,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Version ${AppConstants.appVersion}',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
