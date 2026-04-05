import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../data/models/cancer_info_model.dart';
import '../../widgets/common/naarya_card.dart';
import 'cancer_detail_screen.dart';

class CancerHubScreen extends StatelessWidget {
  const CancerHubScreen({super.key});

  static final List<CancerInfoModel> _cancerTopics = [
    CancerInfoModel(
      id: 'cervical',
      title: 'Cervical Cancer',
      category: 'cervical',
      summary:
          'Cervical cancer develops in the cervix and is primarily caused by persistent HPV infection. It is one of the most preventable and treatable cancers when detected early through regular screening.',
      contentAssetPath: AssetPaths.gynecConsultation,
      warningSigns: [
        'Abnormal vaginal bleeding (between periods, after intercourse, or post-menopause)',
        'Unusual vaginal discharge that may be watery, bloody, or foul-smelling',
        'Pelvic pain or pain during intercourse',
        'Unexplained weight loss and fatigue',
        'Leg swelling or lower back pain in advanced stages',
      ],
      screeningGuidelines: [
        'Age 21-29: Pap smear every 3 years',
        'Age 30-65: Pap smear + HPV test every 5 years (preferred), or Pap smear alone every 3 years',
        'HPV vaccination recommended for ages 9-26 (can be given up to 45 in some cases)',
        'Women with HIV or weakened immune systems may need more frequent screening',
      ],
    ),
    CancerInfoModel(
      id: 'breast',
      title: 'Breast Cancer',
      category: 'breast',
      summary:
          'Breast cancer is the most common cancer among women worldwide. Early detection through self-exams and mammography significantly improves treatment outcomes and survival rates.',
      contentAssetPath: AssetPaths.breastConsultation,
      warningSigns: [
        'A new lump or thickening in the breast or underarm area',
        'Change in breast size, shape, or appearance',
        'Dimpling, puckering, or redness of the breast skin',
        'Nipple inversion (turning inward) that is new',
        'Nipple discharge other than breast milk (especially if bloody)',
        'Peeling, scaling, or flaking of the nipple or breast skin',
        'Persistent breast pain not related to menstrual cycle',
      ],
      screeningGuidelines: [
        'Monthly breast self-exam starting at age 20',
        'Clinical breast exam every 1-3 years for ages 25-39',
        'Annual mammogram starting at age 40 (some guidelines suggest 50)',
        'Women with family history or BRCA mutations may need earlier and more frequent screening (including MRI)',
        'Discuss personal risk factors with your doctor to create a screening plan',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Cancer Awareness', style: AppTextStyles.h3),
        backgroundColor: AppColors.surface,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Awareness banner
            _buildAwarenessBanner(),

            const SizedBox(height: AppSpacing.sectionGap),

            // Cancer topic cards
            Text('Learn About', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.componentGap),
            ..._cancerTopics.map((topic) => Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppSpacing.componentGap),
                  child: _buildTopicCard(context, topic),
                )),

            const SizedBox(height: AppSpacing.sectionGap),

            // Warning signs section
            Text('Warning Signs to Watch For', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.componentGap),
            _buildWarningSignsCard(
              'Cervical Cancer Warning Signs',
              _cancerTopics[0].warningSigns,
              Icons.warning_amber_rounded,
              AppColors.error,
            ),
            const SizedBox(height: AppSpacing.componentGap),
            _buildWarningSignsCard(
              'Breast Cancer Warning Signs',
              _cancerTopics[1].warningSigns,
              Icons.warning_amber_rounded,
              AppColors.warning,
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            // Screening guidelines section
            Text('Screening Guidelines', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.componentGap),
            _buildGuidelinesCard(
              'Cervical Cancer Screening',
              _cancerTopics[0].screeningGuidelines,
            ),
            const SizedBox(height: AppSpacing.componentGap),
            _buildGuidelinesCard(
              'Breast Cancer Screening',
              _cancerTopics[1].screeningGuidelines,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAwarenessBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Early detection saves lives.',
                  style: AppTextStyles.h3.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'Stay informed, stay safe. Learn about prevention, warning signs, and screening guidelines.',
                  style: AppTextStyles.body2.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.health_and_safety_outlined,
            size: 48,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicCard(BuildContext context, CancerInfoModel topic) {
    final icon = topic.category == 'cervical'
        ? Icons.medical_information_outlined
        : Icons.favorite_outline;
    final iconColor = topic.category == 'cervical'
        ? AppColors.primary
        : const Color(0xFFE91E63);

    return NaaryaCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CancerDetailScreen(
              title: topic.title,
              assetPath: topic.contentAssetPath,
              warningSigns: topic.warningSigns,
              screeningGuidelines: topic.screeningGuidelines,
            ),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(topic.title, style: AppTextStyles.subtitle1),
                const SizedBox(height: 4),
                Text(
                  topic.summary,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textMuted,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'Learn More',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningSignsCard(
    String title,
    List<String> signs,
    IconData icon,
    Color color,
  ) {
    return NaaryaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.subtitle1.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...signs.map(
            (sign) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(sign, style: AppTextStyles.body2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelinesCard(String title, List<String> guidelines) {
    return NaaryaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.checklist_outlined,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.subtitle1.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...guidelines.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(entry.value, style: AppTextStyles.body2),
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
