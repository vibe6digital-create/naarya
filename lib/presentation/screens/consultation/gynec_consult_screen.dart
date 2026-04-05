import 'package:flutter/material.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/services/whatsapp_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../data/models/doctor_model.dart';
import '../../widgets/common/markdown_content_view.dart';
import '../../widgets/common/naarya_card.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/whatsapp_cta_button.dart';

class GynecConsultScreen extends StatelessWidget {
  const GynecConsultScreen({super.key});

  static const DoctorModel _doctor = DoctorModel(
    id: 'dr_niyati',
    name: 'Dr. Niyati Jain Shah',
    degree: 'MS (OBG)',
    specialty: 'Gynecologist & Cancer Specialist',
    about:
        'Dr. Niyati Jain Shah is a highly experienced gynecologist and cancer '
        'specialist dedicated to providing compassionate and comprehensive '
        'women\'s healthcare.',
    availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    availableSlots: ['10:00 AM', '12:00 PM', '4:00 PM', '6:00 PM'],
    whatsappNumber: '919876543210',
    cities: ['Indore', 'Pune', 'Ujjain'],
  );

  void _bookConsultation(BuildContext context) {
    final userName = LocalStorageService.userName;
    WhatsappService.openConsultation(
      doctorName: _doctor.name,
      issue: 'Gynecology Consultation',
      userName: userName.isNotEmpty ? userName : 'User',
      phoneNumber: _doctor.whatsappNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Gynecology Consultation', style: AppTextStyles.h2),
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
            // Doctor info card
            _DoctorInfoCard(doctor: _doctor),
            const SizedBox(height: AppSpacing.sectionGap),

            // Content section
            const SectionHeader(title: 'About the Consultation'),
            const SizedBox(height: AppSpacing.componentGap),
            const MarkdownContentView(assetPath: AssetPaths.gynecConsultation),
            const SizedBox(height: AppSpacing.sectionGap),

            // WhatsApp CTA
            WhatsappCtaButton(
              onPressed: () => _bookConsultation(context),
              text: 'Chat with Dr. Niyati',
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
            child: ElevatedButton(
              onPressed: () => _bookConsultation(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                ),
              ),
              child: Text('Book Consultation', style: AppTextStyles.button),
            ),
          ),
        ),
      ),
    );
  }
}

class _DoctorInfoCard extends StatelessWidget {
  final DoctorModel doctor;

  const _DoctorInfoCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return NaaryaCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with initials
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  'NJ',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: AppTextStyles.subtitle1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      doctor.degree,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doctor.specialty,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Specialty badges
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _buildChip('Gynecology'),
              _buildChip('Obstetrics'),
              _buildChip('Cancer Specialist'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Available cities
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  doctor.cities.join('  \u2022  '),
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Available days
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  doctor.availableDays.join(', '),
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
