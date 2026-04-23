import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/whatsapp_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../widgets/common/naarya_card.dart';
import '../../widgets/common/section_header.dart';

class AntenatalScreen extends StatefulWidget {
  const AntenatalScreen({super.key});

  @override
  State<AntenatalScreen> createState() => _AntenatalScreenState();
}

class _AntenatalScreenState extends State<AntenatalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Antenatal & Garbh Sanskar', style: AppTextStyles.h2),
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          dividerColor: AppColors.divider,
          tabs: const [
            Tab(text: 'Garbh Sanskar'),
            Tab(text: 'Antenatal Classes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGarbhSanskarTab(),
          _buildAntenatalTab(),
        ],
      ),
    );
  }

  Widget _buildGarbhSanskarTab() {
    return SingleChildScrollView(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          _buildConsultCTA(
            'Talk to Our Garbh Sanskar Expert',
            'Connect via WhatsApp for personalised guidance',
          ),
          const SizedBox(height: AppSpacing.sectionGap),

          _buildHeroBanner(
            title: 'Garbh Sanskar',
            subtitle: 'Nurture your baby before birth through music, meditation & positive thought',
            color: AppColors.secondary,
            icon: Icons.self_improvement_rounded,
          ),
          const SizedBox(height: AppSpacing.sectionGap),

          const SectionHeader(title: 'What is Garbh Sanskar?'),
          const SizedBox(height: AppSpacing.componentGap),
          NaaryaCard(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Garbh Sanskar is the ancient Indian practice of educating, nurturing, and positively influencing a baby while it is still in the womb. '
              'Scientific studies support that a baby in the womb can sense sounds, emotions, and vibrations from around 18–20 weeks of pregnancy.\n\n'
              'Practices include:\n'
              '• Listening to classical or devotional music\n'
              '• Meditation and deep breathing for emotional calm\n'
              '• Reading positive and uplifting literature\n'
              '• Maintaining a joyful, stress-free environment\n'
              '• Gentle yoga and pranayama for mother and baby',
              style: AppTextStyles.body1.copyWith(color: AppColors.textBody, height: 1.6),
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),

          const SectionHeader(title: 'Recorded Sessions'),
          const SizedBox(height: AppSpacing.componentGap),
          ..._garbhSessions.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.componentGap),
            child: _buildSessionCard(s),
          )),
          const SizedBox(height: AppSpacing.sectionGap),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildAntenatalTab() {
    return SingleChildScrollView(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          _buildConsultCTA(
            'Book an Antenatal Consultation',
            'Speak to our gynaecologist or midwife today',
          ),
          const SizedBox(height: AppSpacing.sectionGap),

          _buildHeroBanner(
            title: 'Antenatal Classes',
            subtitle: 'Prepare for birth with expert-led classes for mother & partner',
            color: AppColors.primary,
            icon: Icons.child_care_rounded,
          ),
          const SizedBox(height: AppSpacing.sectionGap),

          const SectionHeader(title: 'What are Antenatal Classes?'),
          const SizedBox(height: AppSpacing.componentGap),
          NaaryaCard(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Antenatal (prenatal) classes prepare expectant parents for labour, birth, and early parenthood. '
              'They cover a range of topics to help you feel informed, confident, and in control.\n\n'
              'Topics covered include:\n'
              '• Stages of labour and what to expect\n'
              '• Pain relief options (epidural, gas & air, water birth)\n'
              '• Breathing and relaxation techniques\n'
              '• Breastfeeding basics\n'
              '• Newborn care (bathing, feeding, sleeping)\n'
              '• Postnatal recovery for the mother\n'
              '• Partner support during labour',
              style: AppTextStyles.body1.copyWith(color: AppColors.textBody, height: 1.6),
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),

          const SectionHeader(title: 'Class Schedule'),
          const SizedBox(height: AppSpacing.componentGap),
          ..._antenatalClasses.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.componentGap),
            child: _buildClassCard(c),
          )),
          const SizedBox(height: AppSpacing.sectionGap),

          const SectionHeader(title: 'Meet Our Experts'),
          const SizedBox(height: AppSpacing.componentGap),
          ..._experts.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.componentGap),
            child: _buildExpertCard(e),
          )),
          const SizedBox(height: AppSpacing.sectionGap),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildHeroBanner({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.h2.copyWith(color: Colors.white)),
                const SizedBox(height: 6),
                Text(subtitle,
                    style: AppTextStyles.body2.copyWith(
                        color: Colors.white.withValues(alpha: 0.85))),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(_Session session) {
    return NaaryaCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.play_circle_outline_rounded,
                color: AppColors.secondary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.title,
                    style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(session.duration,
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Watch',
                style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.secondary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(_ClassItem cls) {
    return NaaryaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(cls.title,
                    style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.w600, color: AppColors.textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Text(cls.week,
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Text(cls.description,
              style: AppTextStyles.body2.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildExpertCard(_Expert expert) {
    return NaaryaCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(expert.name[4].toUpperCase(),
                style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expert.name,
                    style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.w600)),
                Text(expert.specialty,
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => WhatsappService.openChat(
              phoneNumber: AppConstants.whatsappNumber,
              message: 'Hi, I\'d like to consult ${expert.name} for ${expert.specialty}.',
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('Consult',
                  style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultCTA(String title, String subtitle) {
    return GestureDetector(
      onTap: () => WhatsappService.openChat(
        phoneNumber: AppConstants.whatsappNumber,
        message: 'Hi, I\'d like to learn more about Antenatal & Garbh Sanskar services.',
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.chat_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.subtitle1.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                  Text(subtitle,
                      style: AppTextStyles.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.85))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  static const List<_Session> _garbhSessions = [
    _Session(title: 'Introduction to Garbh Sanskar', duration: '15 min'),
    _Session(title: 'Music & Meditation for the Womb', duration: '22 min'),
    _Session(title: 'Breathing & Pranayama in Pregnancy', duration: '18 min'),
    _Session(title: 'Positive Affirmations & Visualisation', duration: '12 min'),
  ];

  static const List<_ClassItem> _antenatalClasses = [
    _ClassItem(
      title: 'Understanding Labour',
      description: 'Stages of labour, early signs, and when to go to hospital.',
      week: 'Week 28+',
    ),
    _ClassItem(
      title: 'Pain Relief Options',
      description: 'Epidural, gas & air, hypnobirthing and natural methods.',
      week: 'Week 30+',
    ),
    _ClassItem(
      title: 'Breastfeeding Basics',
      description: 'Latch techniques, frequency, and common challenges.',
      week: 'Week 32+',
    ),
    _ClassItem(
      title: 'Newborn Care',
      description: 'Bathing, feeding, sleeping patterns and postpartum care.',
      week: 'Week 34+',
    ),
  ];

  static const List<_Expert> _experts = [
    _Expert(name: 'Dr. Anjali Mehta', specialty: 'Gynaecologist & Obstetrician'),
    _Expert(name: 'Dr. Priya Gupta', specialty: 'Antenatal Educator & Midwife'),
    _Expert(name: 'Dr. Niyati Sharma', specialty: 'Garbh Sanskar & Wellness Expert'),
  ];
}

class _Session {
  final String title;
  final String duration;
  const _Session({required this.title, required this.duration});
}

class _ClassItem {
  final String title;
  final String description;
  final String week;
  const _ClassItem({required this.title, required this.description, required this.week});
}

class _Expert {
  final String name;
  final String specialty;
  const _Expert({required this.name, required this.specialty});
}
