import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../widgets/common/naarya_card.dart';
import '../../widgets/common/section_header.dart';

class MentalFitnessScreen extends StatefulWidget {
  const MentalFitnessScreen({super.key});

  @override
  State<MentalFitnessScreen> createState() => _MentalFitnessScreenState();
}

class _MentalFitnessScreenState extends State<MentalFitnessScreen> {
  static const _mauve = Color(0xFF7B52A8);
  static const _mauveLight = Color(0xFFEDE7F6);
  static const _mauveMid = Color(0xFFAB6DBC);

  static const List<_Session> _sessions = [
    _Session(
      title: 'Understanding Anxiety & Hormones',
      duration: '18 min',
      tag: 'Theory',
      icon: Icons.psychology_rounded,
      color: Color(0xFF9C5BB5),
    ),
    _Session(
      title: 'Breathing for Calm — Daily Practice',
      duration: '12 min',
      tag: 'Recorded',
      icon: Icons.air_rounded,
      color: Color(0xFF7B52A8),
    ),
    _Session(
      title: 'Managing PMS Mood Swings',
      duration: '22 min',
      tag: 'Theory',
      icon: Icons.mood_rounded,
      color: Color(0xFFAB6DBC),
    ),
    _Session(
      title: 'Sleep & Hormonal Balance',
      duration: '15 min',
      tag: 'Recorded',
      icon: Icons.bedtime_rounded,
      color: Color(0xFF9C5BB5),
    ),
    _Session(
      title: 'Mindfulness for Busy Women',
      duration: '10 min',
      tag: 'Recorded',
      icon: Icons.self_improvement_rounded,
      color: Color(0xFF7B52A8),
    ),
  ];

  Future<void> _openWhatsApp(String message) async {
    final msg = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/${AppConstants.whatsappNumber}?text=$msg');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showSessionSheet(_Session session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border, borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: session.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(session.icon, color: session.color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.title, style: AppTextStyles.h3),
                      const SizedBox(height: 2),
                      Text('${session.tag} · ${session.duration}',
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'This session is available via WhatsApp with our panel experts. '
              'Tap below to access recorded content or schedule a live session.',
              style: AppTextStyles.body1,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _openWhatsApp(
                    'Hi, I would like to access the session: "${session.title}" from the Naarya app.',
                  );
                },
                icon: const Icon(Icons.play_circle_rounded, color: Colors.white, size: 20),
                label: Text('Access Session', style: AppTextStyles.button),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Mental Fitness', style: AppTextStyles.h2.copyWith(color: AppColors.textDark)),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderBanner(),
            const SizedBox(height: AppSpacing.sectionGap),

            const SectionHeader(title: 'Meet Our Expert'),
            const SizedBox(height: AppSpacing.componentGap),
            _buildExpertCard(),
            const SizedBox(height: AppSpacing.sectionGap),

            const SectionHeader(title: 'Theory & Recorded Sessions'),
            const SizedBox(height: AppSpacing.componentGap),
            ..._sessions.map((s) => _buildSessionTile(s)),
            const SizedBox(height: AppSpacing.sectionGap),

            const SectionHeader(title: 'Take a Break · Rejuvenation'),
            const SizedBox(height: AppSpacing.componentGap),
            _buildRejuvenationCard(context),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _mauveMid.withValues(alpha: 0.14),
            AppColors.primaryLight.withValues(alpha: 0.07),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _mauveMid.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: _mauveLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology_rounded, color: _mauve, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Mind Matters',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Expert sessions, guided practices & travel wellness for a balanced life.',
                  style: TextStyle(
                    fontSize: 12, color: AppColors.textMuted, height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertCard() {
    return NaaryaCard(
      padding: const EdgeInsets.all(16),
      onTap: () => _openWhatsApp(
        'Hi, I would like to book a session with the psychologist through Naarya.',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60, height: 60,
                decoration: const BoxDecoration(
                  color: _mauveLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded, color: _mauve, size: 32),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. Ananya Mehta',
                      style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Clinical Psychologist · 12 yrs exp',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Specialises in women\'s mental health, hormonal anxiety & perimenopause.',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: _mauveLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_rounded, color: _mauve, size: 16),
                SizedBox(width: 6),
                Text(
                  'Book a Session via WhatsApp',
                  style: TextStyle(
                    color: _mauve, fontWeight: FontWeight.w600, fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTile(_Session session) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.componentGap),
      child: NaaryaCard(
        padding: const EdgeInsets.all(14),
        onTap: () => _showSessionSheet(session),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: session.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(session.icon, color: session.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    style: AppTextStyles.subtitle2.copyWith(
                      color: AppColors.textDark, fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: session.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          session.tag,
                          style: TextStyle(
                            fontSize: 10, color: session.color, fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 3),
                      Text(
                        session.duration,
                        style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.play_circle_rounded,
              color: session.color.withValues(alpha: 0.7),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejuvenationCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/travelling-health'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.11),
              _mauveMid.withValues(alpha: 0.07),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.flight_takeoff_rounded, color: AppColors.primary, size: 26),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Take a Break · Rejuvenation',
                    style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Travel wellness, self-care tips & healthy travel planning for a clear mind.',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _Session {
  final String title;
  final String duration;
  final String tag;
  final IconData icon;
  final Color color;

  const _Session({
    required this.title,
    required this.duration,
    required this.tag,
    required this.icon,
    required this.color,
  });
}
