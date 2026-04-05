import 'package:flutter/material.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/services/whatsapp_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../widgets/common/markdown_content_view.dart';
import '../../widgets/common/naarya_card.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/whatsapp_cta_button.dart';

class BreastConsultScreen extends StatelessWidget {
  const BreastConsultScreen({super.key});

  static const String _whatsappNumber = '919876543210';
  static const String _doctorName = 'Dr. Niyati Jain Shah';

  void _openConsultationChat(BuildContext context) {
    final userName = LocalStorageService.userName;
    WhatsappService.openConsultation(
      doctorName: _doctorName,
      issue: 'Breast Health Consultation',
      userName: userName.isNotEmpty ? userName : 'User',
      phoneNumber: _whatsappNumber,
    );
  }

  void _showReminderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        title: Row(
          children: [
            Icon(Icons.notifications_active, color: AppColors.primary, size: 24),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Self-Breast Examination',
                style: AppTextStyles.h3,
              ),
            ),
          ],
        ),
        content: Text(
          'Would you like to set a monthly reminder for self-breast examination? '
          'Regular self-exams help in early detection and better health outcomes.',
          style: AppTextStyles.body2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Not Now',
              style: AppTextStyles.subtitle2.copyWith(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Monthly reminder set! We\'ll remind you every month.',
                    style: AppTextStyles.body2.copyWith(color: Colors.white),
                  ),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
              ),
            ),
            child: Text('Set Reminder', style: AppTextStyles.buttonSmall),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Breast Health', style: AppTextStyles.h2),
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
            // Important info card
            _SelfExamReminderCard(
              onSetReminder: () => _showReminderDialog(context),
            ),
            const SizedBox(height: AppSpacing.sectionGap),

            // Awareness info card
            NaaryaCard(
              color: AppColors.infoLight,
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: AppColors.info, size: 22),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Early Detection Saves Lives',
                          style: AppTextStyles.subtitle1.copyWith(
                            color: AppColors.info,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Regular self-breast examination and timely screening can '
                          'significantly improve treatment outcomes. Consult a specialist '
                          'if you notice any unusual changes.',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textBody,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),

            // Content
            const SectionHeader(title: 'Breast Health Guide'),
            const SizedBox(height: AppSpacing.componentGap),
            const MarkdownContentView(assetPath: AssetPaths.breastConsultation),
            const SizedBox(height: AppSpacing.sectionGap),

            // WhatsApp CTA
            WhatsappCtaButton(
              onPressed: () => _openConsultationChat(context),
              text: 'Consult a Specialist',
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openConsultationChat(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                ),
              ),
              icon: const Icon(Icons.health_and_safety, size: 20),
              label: Text('Book Consultation', style: AppTextStyles.button),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelfExamReminderCard extends StatelessWidget {
  final VoidCallback onSetReminder;

  const _SelfExamReminderCard({required this.onSetReminder});

  @override
  Widget build(BuildContext context) {
    return NaaryaCard(
      color: const Color(0xFFFCE4EC),
      border: Border.all(color: const Color(0xFFF48FB1).withValues(alpha: 0.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8BBD0),
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
                child: const Icon(
                  Icons.notifications_active,
                  color: Color(0xFFAD1457),
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Self-Breast Examination',
                      style: AppTextStyles.subtitle1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFAD1457),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Set a monthly reminder for self-breast examination',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onSetReminder,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFAD1457),
                side: const BorderSide(color: Color(0xFFAD1457)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                ),
              ),
              icon: const Icon(Icons.alarm_add, size: 18),
              label: Text(
                'Set Monthly Reminder',
                style: AppTextStyles.buttonSmall.copyWith(
                  color: const Color(0xFFAD1457),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
