import 'package:flutter/material.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/services/whatsapp_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../widgets/common/markdown_content_view.dart';
import '../../widgets/common/whatsapp_cta_button.dart';

class ContentPageScreen extends StatelessWidget {
  final String title;
  final String assetPath;
  final bool showWhatsappCta;
  final String whatsappCtaText;
  final String whatsappNumber;

  const ContentPageScreen({
    super.key,
    required this.title,
    required this.assetPath,
    this.showWhatsappCta = false,
    this.whatsappCtaText = 'Chat on WhatsApp',
    this.whatsappNumber = '919876543210',
  });

  void _openWhatsappChat() {
    final userName = LocalStorageService.userName;
    WhatsappService.openConsultation(
      doctorName: 'Naarya Team',
      issue: title,
      userName: userName.isNotEmpty ? userName : 'User',
      phoneNumber: whatsappNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title, style: AppTextStyles.h2),
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
            MarkdownContentView(assetPath: assetPath),
            if (showWhatsappCta) ...[
              const SizedBox(height: AppSpacing.sectionGap),
              WhatsappCtaButton(
                onPressed: _openWhatsappChat,
                text: whatsappCtaText,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
