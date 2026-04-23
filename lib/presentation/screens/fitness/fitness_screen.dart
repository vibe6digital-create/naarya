import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../core/services/expert_service.dart';
import '../../../core/services/expert_video_service.dart';
import '../../../core/services/workout_service.dart';
import '../../../data/models/expert_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../data/models/expert_video_model.dart';
import '../../../data/models/workout_model.dart';
import '../../widgets/common/naarya_card.dart';
import '../../widgets/common/section_header.dart';
import '../antenatal/story_viewer_screen.dart';
import 'video_player_screen.dart';

class FitnessScreen extends StatefulWidget {
  const FitnessScreen({super.key});

  @override
  State<FitnessScreen> createState() => _FitnessScreenState();
}

class _FitnessScreenState extends State<FitnessScreen> {
  String _selectedCategory = 'All';

  static const _categories = ['All', 'Walking', 'Yoga', 'Meditation'];

  static const _categoryIcons = {
    'All': Icons.grid_view_rounded,
    'Walking': Icons.directions_walk_rounded,
    'Yoga': Icons.self_improvement_rounded,
    'Meditation': Icons.spa_rounded,
  };

  static const _categoryColors = {
    'Walking': Color(0xFFFFF3C4),
    'Yoga': Color(0xFFE8D5F5),
    'Meditation': Color(0xFFC8EBF0),
  };

  Color _categoryColor(String category) =>
      _categoryColors[category] ?? const Color(0xFFFCE4EC);

  List<StorySlide> _buildWorkoutSlides(WorkoutModel workout) {
    final bg = _categoryColor(workout.category);
    final icon =
        _categoryIcons[workout.category] ?? Icons.fitness_center_rounded;
    return [
      StorySlide(
        isCover: true,
        stepTitle: workout.name,
        stepBody: '',
        coverSubtitle:
            '${workout.durationMinutes} min  ·  ${workout.intensityLabel} intensity',
        backgroundColor: bg,
        icon: icon,
        imageUrl: workout.coverImageUrl,
      ),
      ...workout.steps.asMap().entries.map(
            (e) => StorySlide(
              stepNumber: e.key + 1,
              stepTitle: e.value.title,
              stepBody: e.value.body,
              backgroundColor: bg,
              icon: icon,
              imageUrl: e.value.imageUrl,
            ),
          ),
    ];
  }

  void _openWorkoutStory(WorkoutModel workout) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondary) => StoryViewerScreen(
          storyLabel: workout.category,
          slides: _buildWorkoutSlides(workout),
        ),
        transitionsBuilder: (context, animation, secondary, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _showVideoPreview(ExpertVideoModel video) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (ctx) => _VideoPreviewSheet(
        video: video,
        onWatch: () {
          Navigator.pop(ctx);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPlayerScreen(video: video),
            ),
          );
        },
      ),
    );
  }

  Color _intensityColor(WorkoutIntensity intensity) {
    switch (intensity) {
      case WorkoutIntensity.low:
        return AppColors.success;
      case WorkoutIntensity.moderate:
        return AppColors.warning;
      case WorkoutIntensity.high:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Physical Fitness')),
      body: StreamBuilder<List<WorkoutModel>>(
        stream: WorkoutService.workoutsStream(),
        builder: (context, snapshot) {
          final isLoading =
              snapshot.connectionState == ConnectionState.waiting;
          final workouts = snapshot.data ?? [];

          return ListView(
            padding: AppSpacing.pagePadding,
            children: [
              // ── Hero quote ──
              _QuoteBanner(),
              const SizedBox(height: AppSpacing.sectionGap),

              // ── Meet Our Experts ──
              const SectionHeader(title: 'Meet Our Experts'),
              const SizedBox(height: AppSpacing.componentGap),
              _buildExpertsSection(),
              const SizedBox(height: AppSpacing.sectionGap),

              // ── Introduction ──
              _InfoSection(
                icon: Icons.favorite_rounded,
                iconColor: AppColors.primary,
                iconBg: AppColors.primaryLight.withValues(alpha: 0.15),
                title: 'Introduction',
                body:
                    'Regular physical activity keeps you both physically and mentally fit. '
                    'It could be a simple walk, Yoga or a workout at the gym. Studies have proven '
                    'that regular physical activity can prevent almost all chronic diseases like '
                    'diabetes, heart disease and even Cancer.\n\nDaily moderate exercise helps '
                    'maintain energy levels throughout the day and increases happy hormones that '
                    'help prevent anxiety and depression.',
              ),
              const SizedBox(height: AppSpacing.componentGap),

              // ── Walking ──
              _InfoSection(
                icon: Icons.directions_walk_rounded,
                iconColor: const Color(0xFFE65100),
                iconBg: const Color(0xFFFFF3E0),
                title: 'Walking',
                body:
                    'It is the easiest exercise. One should have a brisk walk at least for '
                    '15–30 mins every day. Brisk walk should be done on an empty stomach, '
                    'preferably in the morning. After meals, just 100 steps of slow-walk helps '
                    'in better digestion of food.',
                callout: _Callout(
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xFFE65100),
                  bgColor: const Color(0xFFFFF3E0),
                  text:
                      'Brisk walk after a meal can result in indigestion and bloating. Only slow walks are advised after eating.',
                ),
              ),
              const SizedBox(height: AppSpacing.componentGap),

              // ── Yoga ──
              _InfoSection(
                icon: Icons.self_improvement_rounded,
                iconColor: const Color(0xFF6A1B9A),
                iconBg: const Color(0xFFF3E5F5),
                title: 'Yoga',
                body:
                    'Yoga is a blend of physical movements and breathing techniques. It brings '
                    'physical, mental, hormonal and emotional harmony to the body.\n\n'
                    'Most gynecological problems are due to hormonal imbalances — irregular periods, '
                    'PCOS, fertility issues, perimenopausal problems. Yoga has a preventive as well '
                    'as therapeutic role in all such issues. Just 15–20 mins everyday keeps you '
                    'away from these difficult-to-treat diseases.',
              ),
              const SizedBox(height: AppSpacing.sectionGap),

              // ── Expert videos ──
              const SectionHeader(title: 'Expert Videos'),
              const SizedBox(height: AppSpacing.componentGap),
              StreamBuilder<List<ExpertVideoModel>>(
                stream: ExpertVideoService.videosStream(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return Column(children: [
                      _VideoCardSkeleton(),
                      const SizedBox(height: AppSpacing.componentGap),
                      _VideoCardSkeleton(),
                    ]);
                  }
                  final videos = snap.data ?? [];
                  if (videos.isEmpty) return const SizedBox.shrink();
                  return Column(
                    children: videos
                        .map((v) => Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppSpacing.componentGap),
                              child: _VideoCard(
                                video: v,
                                onTap: () => _showVideoPreview(v),
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sectionGap),

              // ── Category filter chips ──
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (ctx, i) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final selected = cat == _selectedCategory;
                    return FilterChip(
                      selected: selected,
                      label: Text(cat),
                      avatar: Icon(
                        _categoryIcons[cat],
                        size: 18,
                        color:
                            selected ? Colors.white : AppColors.textMuted,
                      ),
                      labelStyle: AppTextStyles.label.copyWith(
                        color:
                            selected ? Colors.white : AppColors.textBody,
                      ),
                      backgroundColor: AppColors.surface,
                      selectedColor: AppColors.primary,
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.chipRadius),
                        side: BorderSide(
                          color: selected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      onSelected: (_) =>
                          setState(() => _selectedCategory = cat),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.sectionGap),
              const SectionHeader(title: 'Workouts'),
              const SizedBox(height: AppSpacing.componentGap),

              // ── Loading skeletons ──
              if (isLoading) ...[
                _WorkoutCardSkeleton(),
                const SizedBox(height: AppSpacing.componentGap),
                _WorkoutCardSkeleton(),
                const SizedBox(height: AppSpacing.componentGap),
                _WorkoutCardSkeleton(),
              ]

              // ── Error ──
              else if (snapshot.hasError) ...[
                _buildMessageState(
                  icon: Icons.wifi_off_outlined,
                  message:
                      'Could not load workouts.\nCheck Firestore rules.',
                  color: AppColors.warning,
                ),
              ]

              // ── Empty ──
              else if (workouts.isEmpty) ...[
                _buildMessageState(
                  icon: Icons.fitness_center_outlined,
                  message:
                      'No workouts added yet.\nAdd workouts in Firebase Console → "workouts" collection.',
                  color: AppColors.textLight,
                ),
              ]

              // ── Workout cards ──
              else ...[
                ..._filteredWorkouts(workouts).map(
                  (workout) => Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppSpacing.componentGap),
                    child: NaaryaCard(
                      onTap: () => _openWorkoutStory(workout),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: icon + name + play button
                          Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: _categoryColor(workout.category),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _categoryIcons[workout.category] ??
                                      Icons.fitness_center,
                                  color: const Color(0xFF1A1A2E)
                                      .withValues(alpha: 0.55),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(workout.name,
                                    style: AppTextStyles.subtitle1),
                              ),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight
                                      .withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),

                          // Description
                          if (workout.description.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              workout.description,
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.textMuted,
                                height: 1.5,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],

                          const SizedBox(height: 10),

                          // Badges row
                          Row(
                            children: [
                              _Badge(
                                icon: Icons.timer_outlined,
                                label: '${workout.durationMinutes} min',
                                color: AppColors.info,
                                bgColor: AppColors.infoLight,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              _Badge(
                                icon: Icons.speed_rounded,
                                label: workout.intensityLabel,
                                color: _intensityColor(workout.intensity),
                                bgColor: _intensityColor(workout.intensity)
                                    .withValues(alpha: 0.1),
                              ),
                              if (workout.steps.isNotEmpty) ...[
                                const SizedBox(width: AppSpacing.sm),
                                _Badge(
                                  icon: Icons.format_list_numbered_rounded,
                                  label: '${workout.steps.length} steps',
                                  color: AppColors.textMuted,
                                  bgColor: AppColors.surfaceVariant,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.sectionGap),
            ],
          );
        },
      ),
    );
  }

  List<WorkoutModel> _filteredWorkouts(List<WorkoutModel> all) {
    if (_selectedCategory == 'All') return all;
    return all.where((w) => w.category == _selectedCategory).toList();
  }

  Widget _buildExpertsSection() {
    return StreamBuilder<List<ExpertModel>>(
      stream: ExpertService.expertsStreamForCategory('Physical Fitness'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 168,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, i) => const SizedBox(width: 12),
              itemBuilder: (_, i) => const _FitnessExpertSkeleton(),
            ),
          );
        }

        final experts = snapshot.data ?? [];

        if (experts.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
          return NaaryaCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_search_rounded,
                      color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'No experts available for this category.',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted, height: 1.5),
                  ),
                ),
              ],
            ),
          );
        }

        return SizedBox(
          height: 182,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: experts.length,
            separatorBuilder: (_, i) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _FitnessExpertCard(expert: experts[i]),
          ),
        );
      },
    );
  }

  Widget _buildMessageState({
    required IconData icon,
    required String message,
    required Color color,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────── Quote Banner ────────────────────

// ──────────────────── Fitness Expert Card ────────────────────

class _FitnessExpertCard extends StatelessWidget {
  final ExpertModel expert;
  const _FitnessExpertCard({required this.expert});

  static const _accent = Color(0xFF6A1B9A);
  static const _accentLight = Color(0xFFF3E5F5);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _accentLight,
              border: Border.all(color: _accent.withValues(alpha: 0.25), width: 2),
            ),
            clipBehavior: Clip.hardEdge,
            child: expert.photoUrl != null && expert.photoUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: expert.photoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        const Icon(Icons.person_rounded, color: _accent, size: 28),
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.person_rounded, color: _accent, size: 28),
                  )
                : const Icon(Icons.person_rounded, color: _accent, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            expert.name,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            expert.specialties.isNotEmpty ? expert.specialties.first : '',
            style: AppTextStyles.caption.copyWith(color: _accent, fontSize: 10),
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: _accentLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_rounded, color: _accent, size: 12),
                SizedBox(width: 4),
                Text('Consult', style: TextStyle(
                  color: _accent, fontWeight: FontWeight.w600, fontSize: 11,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FitnessExpertSkeleton extends StatelessWidget {
  const _FitnessExpertSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFEEEEEE), shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 10, width: 100, decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(6),
          )),
          const SizedBox(height: 5),
          Container(height: 8, width: 70, decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(6),
          )),
          const Spacer(),
          Container(height: 28, decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(8),
          )),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────

class _QuoteBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E8C), Color(0xFF9C27B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Icon(
              Icons.fitness_center_rounded,
              size: 90,
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.format_quote_rounded,
                  color: Colors.white54, size: 28),
              const SizedBox(height: 6),
              const Text(
                'Take care of your body.\nIt\'s the only place you have to live.',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '— Jim Rohn',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.75),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────── Info Section Card ────────────────────

class _Callout {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String text;
  const _Callout({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.text,
  });
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String body;
  final _Callout? callout;

  const _InfoSection({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.body,
    this.callout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coloured header bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.cardRadius),
                topRight: Radius.circular(AppSpacing.cardRadius),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTextStyles.subtitle1.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Body text
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  body,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textBody,
                    height: 1.65,
                  ),
                ),
                if (callout != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: callout!.bgColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: callout!.color.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(callout!.icon,
                            color: callout!.color, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            callout!.text,
                            style: AppTextStyles.caption.copyWith(
                              color: callout!.color,
                              fontWeight: FontWeight.w600,
                              height: 1.5,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────── Video Card ────────────────────

class _VideoCard extends StatelessWidget {
  final ExpertVideoModel video;
  final VoidCallback onTap;

  const _VideoCard({required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final thumbnail = video.resolvedThumbnail;
    final isYoutube = video.type == VideoType.youtube;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.border, width: 0.8),
          boxShadow: AppColors.cardShadow,
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            // Thumbnail
            SizedBox(
              width: 110,
              height: 78,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  thumbnail != null
                      ? Image.network(
                          thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, url, err) =>
                              _thumbnailPlaceholder(),
                        )
                      : _thumbnailPlaceholder(),
                  Container(color: Colors.black.withValues(alpha: 0.28)),
                  Center(
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow_rounded,
                          color: Color(0xFF6A1B9A), size: 22),
                    ),
                  ),
                ],
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video.instructor,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          isYoutube
                              ? Icons.ondemand_video_rounded
                              : Icons.play_circle_outline_rounded,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isYoutube ? 'Watch on YouTube' : 'Play Video',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnailPlaceholder() => Container(
        color: const Color(0xFFE8D5F5),
        child: const Icon(Icons.play_circle_fill_rounded,
            size: 36, color: Color(0xFF6A1B9A)),
      );
}

// ──────────────────── Video Preview Sheet ────────────────────

class _VideoPreviewSheet extends StatefulWidget {
  final ExpertVideoModel video;
  final VoidCallback onWatch;

  const _VideoPreviewSheet({required this.video, required this.onWatch});

  @override
  State<_VideoPreviewSheet> createState() => _VideoPreviewSheetState();
}

class _VideoPreviewSheetState extends State<_VideoPreviewSheet> {
  YoutubePlayerController? _ytController;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isPlaying = false;
  bool _isLoadingStorage = false;
  bool _storageError = false;

  void _startPlayback() {
    if (widget.video.type == VideoType.youtube) {
      final videoId = widget.video.youtubeVideoId ?? '';
      _ytController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: false,
        ),
      );
      setState(() => _isPlaying = true);
    } else {
      _initStorage();
    }
  }

  Future<void> _initStorage() async {
    setState(() => _isLoadingStorage = true);
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.video.url),
      );
      await _videoController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoController!.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        placeholder: Container(color: Colors.black),
      );
      if (mounted) setState(() { _isLoadingStorage = false; _isPlaying = true; });
    } catch (_) {
      if (mounted) setState(() { _isLoadingStorage = false; _storageError = true; });
    }
  }

  @override
  void dispose() {
    _ytController?.dispose();
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thumbnail = widget.video.resolvedThumbnail;
    final isYoutube = widget.video.type == VideoType.youtube;

    Widget playerArea;
    if (_isPlaying && isYoutube && _ytController != null) {
      playerArea = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: YoutubePlayer(
              controller: _ytController!,
              showVideoProgressIndicator: true,
              progressIndicatorColor: AppColors.primary,
              progressColors: const ProgressBarColors(
                playedColor: AppColors.primary,
                handleColor: AppColors.primaryDark,
              ),
            ),
          ),
        ),
      );
    } else if (_isPlaying && !isYoutube && _chewieController != null) {
      playerArea = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: Chewie(controller: _chewieController!),
          ),
        ),
      );
    } else if (_storageError) {
      playerArea = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.white54, size: 48),
                  SizedBox(height: 8),
                  Text(
                    'Could not load video',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      // Thumbnail with tappable play button
      playerArea = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                thumbnail != null
                    ? Image.network(
                        thumbnail,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, url, err) => Container(
                          color: const Color(0xFFE8D5F5),
                          child: const Icon(Icons.play_circle_fill_rounded,
                              size: 56, color: Color(0xFF6A1B9A)),
                        ),
                      )
                    : Container(
                        color: const Color(0xFFE8D5F5),
                        child: const Icon(Icons.play_circle_fill_rounded,
                            size: 56, color: Color(0xFF6A1B9A)),
                      ),
                Container(color: Colors.black.withValues(alpha: 0.22)),
                Center(
                  child: GestureDetector(
                    onTap: _isLoadingStorage ? null : _startPlayback,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isYoutube
                            ? const Color(0xFFFF0000)
                            : AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _isLoadingStorage
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.play_arrow_rounded,
                              color: Colors.white, size: 32),
                    ),
                  ),
                ),
                if (isYoutube)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF0000),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.smart_display_rounded,
                              color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'YouTube',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Player / thumbnail area
          playerArea,

          // Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.video.title,
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.video.instructor,
                  style:
                      AppTextStyles.body2.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),

          // Full screen button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: widget.onWatch,
                icon: const Icon(Icons.open_in_full_rounded, size: 20),
                label: const Text('Open Full Screen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isYoutube ? const Color(0xFFFF0000) : AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // Cancel
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style:
                      AppTextStyles.body2.copyWith(color: AppColors.textMuted),
                ),
              ),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
          ],
        ),
      ),
    );
  }
}

// ──────────────────── Video Card Skeleton ────────────────────

class _VideoCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          Container(width: 110, color: AppColors.surfaceVariant),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 13,
                    width: 140,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    )),
                const SizedBox(height: 6),
                Container(
                    height: 11,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────── Skeleton card ────────────────────

class _WorkoutCardSkeleton extends StatefulWidget {
  @override
  State<_WorkoutCardSkeleton> createState() => _WorkoutCardSkeletonState();
}

class _WorkoutCardSkeletonState extends State<_WorkoutCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 0.85).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _box(width: 46, height: 46, radius: 12),
                const SizedBox(width: 14),
                Expanded(child: _box(width: double.infinity, height: 14)),
                const SizedBox(width: 10),
                _box(width: 32, height: 32, radius: 16),
              ],
            ),
            const SizedBox(height: 10),
            _box(width: double.infinity, height: 12),
            const SizedBox(height: 6),
            _box(width: 180, height: 12),
            const SizedBox(height: 10),
            Row(children: [
              _box(width: 65, height: 22, radius: 20),
              const SizedBox(width: 6),
              _box(width: 65, height: 22, radius: 20),
              const SizedBox(width: 6),
              _box(width: 65, height: 22, radius: 20),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _box(
      {required double width, required double height, double radius = 6}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: _anim.value),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ──────────────────── Small badge widget ────────────────────

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: AppTextStyles.caption
                  .copyWith(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}
