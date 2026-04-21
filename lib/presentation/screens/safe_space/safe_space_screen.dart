import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/doctor_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../data/models/doctor_model.dart';
import '../../widgets/common/naarya_card.dart';
import '../../widgets/common/section_header.dart';

class SafeSpaceScreen extends StatelessWidget {
  const SafeSpaceScreen({super.key});

  static const _rose = Color(0xFFD4688A);
  static const _roseLight = Color(0xFFFCE4EC);
  static const _lavender = Color(0xFF7B52A8);
  static const _lavenderLight = Color(0xFFEDE7F6);

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
        title: Text('Safe Space', style: AppTextStyles.h2.copyWith(color: AppColors.textDark)),
      ),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          _buildHeroBanner(),
          const SizedBox(height: AppSpacing.sectionGap),

          _buildImmediateHelp(),
          const SizedBox(height: AppSpacing.sectionGap),

          _buildWhatIsSection(),
          const SizedBox(height: AppSpacing.sectionGap),

          const SectionHeader(title: 'Meet Our Counsellors'),
          const SizedBox(height: AppSpacing.componentGap),
          _buildCounsellors(),
          const SizedBox(height: AppSpacing.sectionGap),

          const SectionHeader(title: 'Resources & Support'),
          const SizedBox(height: AppSpacing.componentGap),
          _buildResources(),
          const SizedBox(height: AppSpacing.sectionGap),

          _buildSelfCareSection(),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  // Hero Banner
  // ────────────────────────────────────────────
  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _rose.withValues(alpha: 0.85),
            _lavender.withValues(alpha: 0.70),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(Icons.favorite_rounded, size: 130,
              color: Colors.white.withValues(alpha: 0.07)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.spa_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 14),
              const Text(
                'You Are Safe Here',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This is a judgement-free space created just for you. '
                'Whatever you\'re going through — you are not alone, '
                'and you deserve care, support, and peace.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  _HeroBadge(icon: Icons.lock_rounded, label: 'Private'),
                  SizedBox(width: 8),
                  _HeroBadge(icon: Icons.favorite_border_rounded, label: 'Non-judgemental'),
                  SizedBox(width: 8),
                  _HeroBadge(icon: Icons.support_agent_rounded, label: 'Supported'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  // Immediate Help — Crisis Helplines
  // ────────────────────────────────────────────
  Widget _buildImmediateHelp() {
    return Container(
      decoration: BoxDecoration(
        color: _roseLight,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: _rose.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _rose.withValues(alpha: 0.12),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.cardRadius),
                topRight: Radius.circular(AppSpacing.cardRadius),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: _rose.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.emergency_rounded, color: _rose, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Need Immediate Help?',
                  style: AppTextStyles.subtitle1.copyWith(
                    color: _rose, fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: const [
                _HelplineRow(
                  name: 'iCall (Tata Institute)',
                  number: '9152987821',
                  tagline: 'Free psychological counselling',
                  icon: Icons.psychology_rounded,
                ),
                _HelplineRow(
                  name: 'Vandrevala Foundation',
                  number: '18602662345',
                  tagline: '24/7 mental health helpline',
                  icon: Icons.support_agent_rounded,
                ),
                _HelplineRow(
                  name: 'Women Helpline (Govt.)',
                  number: '181',
                  tagline: 'For women in distress',
                  icon: Icons.shield_rounded,
                ),
                _HelplineRow(
                  name: 'National Crisis Helpline',
                  number: '9820466627',
                  tagline: 'Suicide & mental health crisis',
                  icon: Icons.favorite_rounded,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  // What Is Safe Space
  // ────────────────────────────────────────────
  Widget _buildWhatIsSection() {
    return NaaryaCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _lavenderLight,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.cardRadius),
                topRight: Radius.circular(AppSpacing.cardRadius),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: _lavender.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.info_outline_rounded, color: _lavender, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'What is Safe Space?',
                  style: AppTextStyles.subtitle1.copyWith(
                    color: _lavender, fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: const [
                _OfferingRow(
                  icon: Icons.chat_bubble_outline_rounded,
                  color: _rose,
                  title: 'Talk to a Counsellor',
                  subtitle: 'Connect one-on-one with a certified mental health professional who understands women\'s experiences.',
                ),
                _OfferingRow(
                  icon: Icons.people_outline_rounded,
                  color: _lavender,
                  title: 'Community Support',
                  subtitle: 'You\'re never alone. Share your story or listen to others in a moderated, supportive circle.',
                ),
                _OfferingRow(
                  icon: Icons.menu_book_rounded,
                  color: Color(0xFF26A69A),
                  title: 'Resources & Guides',
                  subtitle: 'Access curated articles, safety plans, legal guides, and self-care toolkits.',
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  // Counsellors (Firebase)
  // ────────────────────────────────────────────
  Widget _buildCounsellors() {
    return StreamBuilder<List<DoctorModel>>(
      stream: DoctorService.doctorsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, i) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _CounsellorSkeleton(),
            ),
          );
        }

        final doctors = snapshot.data ?? [];

        if (doctors.isEmpty) {
          return NaaryaCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: _roseLight, shape: BoxShape.circle),
                  child: const Icon(Icons.person_search_rounded, color: _rose, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Counsellor profiles will appear here.\nAdd doctors in Firebase Console → "doctors" collection.',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textMuted, height: 1.5),
                  ),
                ),
              ],
            ),
          );
        }

        return SizedBox(
          height: 172,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: doctors.length,
            separatorBuilder: (_, i) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _CounsellorCard(doctor: doctors[i]),
          ),
        );
      },
    );
  }

  // ────────────────────────────────────────────
  // Resources
  // ────────────────────────────────────────────
  Widget _buildResources() {
    const resources = [
      _Resource(
        icon: Icons.gavel_rounded,
        color: Color(0xFF5C8DBB),
        bg: Color(0xFFE3F0FB),
        title: 'Know Your Rights',
        subtitle: 'Legal protections for women in India — POCSO, domestic violence act, workplace safety & more.',
      ),
      _Resource(
        icon: Icons.self_improvement_rounded,
        color: Color(0xFF2E7D32),
        bg: Color(0xFFE8F5E9),
        title: 'Healing Through Self-Care',
        subtitle: 'Simple daily practices — breathwork, grounding, journaling — to restore your sense of calm.',
      ),
      _Resource(
        icon: Icons.home_rounded,
        color: _rose,
        bg: _roseLight,
        title: 'Domestic Violence Support',
        subtitle: 'Recognising abuse, safety planning, and reaching out to shelters and legal aid organisations.',
      ),
      _Resource(
        icon: Icons.nightlight_round,
        color: _lavender,
        bg: _lavenderLight,
        title: 'Sleep & Stress Connection',
        subtitle: 'How chronic stress disrupts your hormones and sleep — and evidence-based steps to reset.',
      ),
    ];

    return Column(
      children: resources.map((r) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.componentGap),
        child: NaaryaCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: r.bg, shape: BoxShape.circle),
                child: Icon(r.icon, color: r.color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.title, style: AppTextStyles.subtitle2.copyWith(
                      color: AppColors.textDark, fontWeight: FontWeight.w700,
                    )),
                    const SizedBox(height: 4),
                    Text(r.subtitle, style: AppTextStyles.caption.copyWith(
                      color: AppColors.textBody, height: 1.5,
                    )),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
            ],
          ),
        ),
      )).toList(),
    );
  }

  // ────────────────────────────────────────────
  // Self-Care Quick Actions
  // ────────────────────────────────────────────
  Widget _buildSelfCareSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _lavender.withValues(alpha: 0.10),
            _rose.withValues(alpha: 0.07),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _lavender.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Relief', style: AppTextStyles.subtitle1.copyWith(
            color: AppColors.textDark, fontWeight: FontWeight.w700,
          )),
          const SizedBox(height: 4),
          Text('Simple things you can do right now', style: AppTextStyles.caption.copyWith(
            color: AppColors.textMuted,
          )),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(child: _QuickReliefChip(emoji: '🌬️', label: 'Breathe')),
              SizedBox(width: 10),
              Expanded(child: _QuickReliefChip(emoji: '✍️', label: 'Journal')),
              SizedBox(width: 10),
              Expanded(child: _QuickReliefChip(emoji: '🎵', label: 'Music')),
              SizedBox(width: 10),
              Expanded(child: _QuickReliefChip(emoji: '🌿', label: 'Walk')),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────── Hero Badge ────────────────────

class _HeroBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeroBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(
            fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600,
          )),
        ],
      ),
    );
  }
}

// ──────────────────── Helpline Row ────────────────────

class _HelplineRow extends StatelessWidget {
  final String name;
  final String number;
  final String tagline;
  final IconData icon;
  final bool isLast;

  const _HelplineRow({
    required this.name,
    required this.number,
    required this.tagline,
    required this.icon,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: SafeSpaceScreen._rose.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: SafeSpaceScreen._rose, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.subtitle2.copyWith(
                  color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 13,
                )),
                Text(tagline, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => launchUrl(Uri.parse('tel:$number')),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: SafeSpaceScreen._rose,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.call_rounded, color: Colors.white, size: 13),
                  const SizedBox(width: 4),
                  Text(number, style: const TextStyle(
                    color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600,
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────── Offering Row ────────────────────

class _OfferingRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool isLast;

  const _OfferingRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.subtitle2.copyWith(
                  color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 13,
                )),
                const SizedBox(height: 3),
                Text(subtitle, style: AppTextStyles.caption.copyWith(
                  color: AppColors.textBody, height: 1.5,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────── Counsellor Card ────────────────────

class _CounsellorCard extends StatelessWidget {
  final DoctorModel doctor;
  const _CounsellorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: SafeSpaceScreen._roseLight,
            child: doctor.photoUrl != null && doctor.photoUrl!.isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: doctor.photoUrl!,
                      width: 68, height: 68,
                      fit: BoxFit.cover,
                      placeholder: (c, u) => const Icon(Icons.person_rounded,
                          color: SafeSpaceScreen._rose, size: 30),
                      errorWidget: (c, u, e) => const Icon(Icons.person_rounded,
                          color: SafeSpaceScreen._rose, size: 30),
                    ),
                  )
                : const Icon(Icons.person_rounded, color: SafeSpaceScreen._rose, size: 30),
          ),
          const SizedBox(height: 8),
          Text(doctor.name,
            style: AppTextStyles.subtitle2.copyWith(
              color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 11,
            ),
            maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(doctor.specialty,
            style: AppTextStyles.caption.copyWith(color: SafeSpaceScreen._rose, fontSize: 10),
            maxLines: 1, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: SafeSpaceScreen._roseLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Consult',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10, color: SafeSpaceScreen._rose, fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CounsellorSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        children: [
          CircleAvatar(radius: 34, backgroundColor: Colors.grey.shade200),
          const SizedBox(height: 8),
          Container(height: 10, width: 100, color: Colors.grey.shade200),
          const SizedBox(height: 5),
          Container(height: 8, width: 70, color: Colors.grey.shade200),
        ],
      ),
    );
  }
}

// ──────────────────── Resource ────────────────────

class _Resource {
  final IconData icon;
  final Color color;
  final Color bg;
  final String title;
  final String subtitle;
  const _Resource({
    required this.icon,
    required this.color,
    required this.bg,
    required this.title,
    required this.subtitle,
  });
}

// ──────────────────── Quick Relief Chip ────────────────────

class _QuickReliefChip extends StatelessWidget {
  final String emoji;
  final String label;
  const _QuickReliefChip({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SafeSpaceScreen._lavender.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600,
            color: SafeSpaceScreen._lavender,
          )),
        ],
      ),
    );
  }
}
