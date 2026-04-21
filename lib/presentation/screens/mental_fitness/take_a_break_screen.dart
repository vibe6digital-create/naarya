import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/services/travel_partner_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../data/models/travel_partner_model.dart';
import '../../widgets/common/naarya_card.dart';
import '../../widgets/common/section_header.dart';
import '../antenatal/story_viewer_screen.dart';

class TakeABreakScreen extends StatefulWidget {
  const TakeABreakScreen({super.key});

  @override
  State<TakeABreakScreen> createState() => _TakeABreakScreenState();
}

class _TakeABreakScreenState extends State<TakeABreakScreen> {
  static const _mauve = Color(0xFF7B52A8);
  static const _teal = Color(0xFF26A69A);
  static const _tealLight = Color(0xFFE0F2F1);

  final Set<int> _viewedStories = {};

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
        title: Text('Take a Break', style: AppTextStyles.h2.copyWith(color: AppColors.textDark)),
      ),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          _buildHeroBanner(),
          const SizedBox(height: AppSpacing.sectionGap),

          const SectionHeader(title: 'Meet Our Travel Partners'),
          const SizedBox(height: AppSpacing.componentGap),
          _buildTravelPartners(),
          const SizedBox(height: AppSpacing.sectionGap),

          const SectionHeader(title: 'Explore'),
          const SizedBox(height: AppSpacing.componentGap),
          _buildBenefitsStoriesRow(),
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
            _teal.withValues(alpha: 0.88),
            _mauve.withValues(alpha: 0.72),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -18,
            child: Icon(
              Icons.flight_rounded,
              size: 120,
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.self_improvement_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Travel Therapy',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Sometimes, the best medicine is a change of scenery. '
                'Travel therapy harnesses the healing power of new environments, '
                'cultures, and experiences to restore your mind and spirit.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _HeroBadge(icon: Icons.landscape_rounded, label: 'Heal'),
                  const SizedBox(width: 8),
                  _HeroBadge(icon: Icons.explore_rounded, label: 'Explore'),
                  const SizedBox(width: 8),
                  _HeroBadge(icon: Icons.favorite_rounded, label: 'Restore'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  // Benefits + Types as Instagram Stories
  // ────────────────────────────────────────────
  Widget _buildBenefitsStoriesRow() {
    final benefits = [
      (
        label: 'Proven\nBenefits',
        icon: Icons.star_rounded,
        color: AppColors.primary,
        slides: [
          StorySlide(stepTitle: 'Reduces Cortisol Levels', stepBody: 'Exposure to new environments lowers the primary stress hormone, easing anxiety and tension. Even a weekend trip can measurably reduce cortisol and restore emotional balance.', backgroundColor: const Color(0xFF7B52A8), icon: Icons.psychology_rounded),
          StorySlide(stepTitle: 'Shifts Perspective', stepBody: 'New cultures and landscapes interrupt rumination and break fixed thought patterns. Stepping out of your routine environment resets the mental lens through which you see your problems.', backgroundColor: _teal, icon: Icons.remove_red_eye_rounded),
          StorySlide(stepTitle: 'Boosts Serotonin & Dopamine', stepBody: 'Novel experiences stimulate reward pathways, elevating mood and motivation. The anticipation of travel alone increases happiness — science confirms planning a trip is as joyful as the trip itself.', backgroundColor: const Color(0xFFD4688A), icon: Icons.favorite_rounded),
          StorySlide(stepTitle: 'Builds Social Connection', stepBody: 'Group healing trips and retreats reduce loneliness — a key mental health risk factor. Shared experiences forge deep bonds that persist long after the journey ends.', backgroundColor: const Color(0xFF43A047), icon: Icons.people_rounded),
          StorySlide(stepTitle: 'Promotes Mindfulness', stepBody: 'Being in an unfamiliar place naturally brings you into the present moment. When everything is new, the mind stops replaying the past or worrying about the future — and simply experiences now.', backgroundColor: const Color(0xFFFB8C00), icon: Icons.spa_rounded),
        ],
      ),
      (
        label: 'Travel\nTypes',
        icon: Icons.map_rounded,
        color: _mauve,
        slides: [
          StorySlide(stepTitle: '🌿 Ecotherapy Retreats', stepBody: 'Immersive nature experiences — forest bathing, mountain retreats, and coastal stays — proven to lower blood pressure and reduce anxiety.', backgroundColor: const Color(0xFF43A047), icon: Icons.forest_rounded),
          StorySlide(stepTitle: '🧘 Wellness Retreats', stepBody: 'Structured programmes combining yoga, meditation, Ayurveda, and therapy in a tranquil setting designed for deep emotional reset.', backgroundColor: const Color(0xFF7B52A8), icon: Icons.self_improvement_rounded),
          StorySlide(stepTitle: '🚶‍♀️ Solo Healing Journeys', stepBody: 'Intentional solo travel builds self-reliance, self-awareness, and clarity — especially effective for processing grief or life transitions.', backgroundColor: const Color(0xFFD4688A), icon: Icons.directions_walk_rounded),
          StorySlide(stepTitle: '🌅 Pilgrimage & Sacred Travel', stepBody: 'Visits to spiritually significant places provide a sense of purpose, community, and transcendence that supports emotional recovery.', backgroundColor: const Color(0xFFFB8C00), icon: Icons.temple_hindu_rounded),
          StorySlide(stepTitle: '🏡 Slow Travel', stepBody: 'Staying in one place for an extended period reduces travel fatigue and allows genuine cultural immersion, fostering calm and belonging.', backgroundColor: _teal, icon: Icons.home_rounded),
        ],
      ),
    ];

    return SizedBox(
      height: 115,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: benefits.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, i) {
          final b = benefits[i];
          final isViewed = _viewedStories.contains(i);
          return GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StoryViewerScreen(
                    slides: b.slides,
                    storyLabel: b.label.replaceAll('\n', ' '),
                  ),
                ),
              );
              setState(() => _viewedStories.add(i));
            },
            child: Column(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isViewed
                        ? null
                        : LinearGradient(
                            colors: [b.color, _mauve],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    color: isViewed ? Colors.grey.shade300 : null,
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      backgroundColor: b.color.withValues(alpha: 0.12),
                      child: Icon(b.icon, color: b.color, size: 24),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  b.label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ────────────────────────────────────────────
  // Types of Therapeutic Travel
  // ────────────────────────────────────────────
  // ────────────────────────────────────────────
  // Travel Partners (Firebase)
  // ────────────────────────────────────────────
  Widget _buildTravelPartners() {
    return StreamBuilder<List<TravelPartnerModel>>(
      stream: TravelPartnerService.partnersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            children: List.generate(
              3,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.componentGap),
                child: _PartnerCardSkeleton(),
              ),
            ),
          );
        }

        final partners = snapshot.data ?? [];

        if (partners.isEmpty) {
          return NaaryaCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: _tealLight, shape: BoxShape.circle),
                  child: const Icon(Icons.travel_explore_rounded, color: _teal, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Travel partner profiles will appear here.\nAdd partners in Firebase Console → "travelPartners" collection.',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textMuted, height: 1.5),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: partners.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.componentGap),
            child: NaaryaCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: p.logoUrl != null && p.logoUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: p.logoUrl!,
                                width: 56, height: 56,
                                fit: BoxFit.cover,
                                placeholder: (c, u) => Container(
                                  width: 56, height: 56,
                                  color: _tealLight,
                                  child: const Icon(Icons.travel_explore_rounded, color: _teal, size: 26),
                                ),
                                errorWidget: (c, u, e) => Container(
                                  width: 56, height: 56,
                                  color: _tealLight,
                                  child: const Icon(Icons.travel_explore_rounded, color: _teal, size: 26),
                                ),
                              )
                            : Container(
                                width: 56, height: 56,
                                decoration: BoxDecoration(
                                  color: _tealLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.travel_explore_rounded, color: _teal, size: 26),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: AppTextStyles.subtitle1.copyWith(
                                color: AppColors.textDark, fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (p.category.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _tealLight,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  p.category,
                                  style: const TextStyle(
                                    fontSize: 10, color: _teal, fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    p.description,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textBody, height: 1.6,
                    ),
                  ),
                  if (p.websiteUrl != null && p.websiteUrl!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _tealLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _teal.withValues(alpha: 0.25)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.open_in_new_rounded, color: _teal, size: 15),
                          SizedBox(width: 6),
                          Text(
                            'Learn More & Book',
                            style: TextStyle(
                              color: _teal, fontWeight: FontWeight.w600, fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          )).toList(),
        );
      },
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
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(
            fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600,
          )),
        ],
      ),
    );
  }
}

// ──────────────────── Partner Card Skeleton ────────────────────

class _PartnerCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NaaryaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14, width: 160, color: Colors.grey.shade200),
                    const SizedBox(height: 6),
                    Container(height: 10, width: 100, color: Colors.grey.shade200),
                    const SizedBox(height: 6),
                    Container(height: 10, width: 120, color: Colors.grey.shade200),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 10, width: double.infinity, color: Colors.grey.shade200),
          const SizedBox(height: 6),
          Container(height: 10, width: double.infinity, color: Colors.grey.shade200),
          const SizedBox(height: 6),
          Container(height: 10, width: 200, color: Colors.grey.shade200),
        ],
      ),
    );
  }
}
