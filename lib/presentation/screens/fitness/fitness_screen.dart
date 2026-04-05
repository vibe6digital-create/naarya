import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../core/utils/cycle_phase_calculator.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../data/models/workout_model.dart';
import '../../widgets/common/naarya_card.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/markdown_content_view.dart';

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

  final List<WorkoutModel> _workouts = const [
    WorkoutModel(
      id: 'w1',
      name: 'Morning Brisk Walk',
      description:
          'Start your day with an energising 30-minute brisk walk. Maintain a pace '
          'that raises your heart rate while still allowing conversation.',
      recommendedPhase: CyclePhase.follicular,
      durationMinutes: 30,
      intensity: WorkoutIntensity.low,
      category: 'Walking',
      steps: [
        'Warm up with 5 minutes of normal-paced walking.',
        'Increase to a brisk pace — aim for 100–110 steps per minute.',
        'Swing your arms naturally and keep your posture upright.',
        'Maintain the pace for 20 minutes.',
        'Cool down with 5 minutes of slow walking and light stretches.',
      ],
    ),
    WorkoutModel(
      id: 'w2',
      name: 'Evening Stroll',
      description:
          'A gentle 15-minute evening walk to aid digestion and wind down after '
          'a busy day. Perfect for all cycle phases.',
      recommendedPhase: CyclePhase.luteal,
      durationMinutes: 15,
      intensity: WorkoutIntensity.low,
      category: 'Walking',
      steps: [
        'Head outside about 30 minutes after dinner.',
        'Walk at a comfortable, relaxed pace.',
        'Focus on deep breathing — inhale for 4 counts, exhale for 6.',
        'Enjoy nature or listen to calming music.',
        'Return home and do a brief stretch.',
      ],
    ),
    WorkoutModel(
      id: 'w3',
      name: 'Daily Yoga with Rupali',
      description:
          'A well-rounded 20-minute yoga session suitable for intermediate '
          'practitioners. Covers flexibility, strength, and breathwork.',
      recommendedPhase: CyclePhase.follicular,
      durationMinutes: 20,
      intensity: WorkoutIntensity.moderate,
      category: 'Yoga',
      videoUrl: 'https://youtu.be/5IfeDR9y7xs',
      steps: [
        'Begin with 2 minutes of seated breathing (Pranayama).',
        'Flow through 5 rounds of Surya Namaskar A.',
        'Hold Warrior I, II, and Triangle pose — 30 seconds each side.',
        'Move to seated forward fold and spinal twist.',
        'End with 3 minutes of Savasana (corpse pose).',
      ],
    ),
    WorkoutModel(
      id: 'w4',
      name: 'Surya Namaskar by Sayali',
      description:
          'Learn the perfect Surya Namaskar (Sun Salutation) sequence with '
          'detailed alignment cues. Great for mornings.',
      recommendedPhase: CyclePhase.ovulation,
      durationMinutes: 15,
      intensity: WorkoutIntensity.moderate,
      category: 'Yoga',
      videoUrl: 'https://youtu.be/6ivs1RDxJ-4',
      steps: [
        'Stand at the top of your mat in Tadasana.',
        'Inhale — raise arms overhead (Hasta Uttanasana).',
        'Exhale — fold forward (Uttanasana).',
        'Step or jump back to Chaturanga Dandasana.',
        'Inhale — Upward Dog; Exhale — Downward Dog.',
        'Step forward and rise back to Tadasana.',
        'Repeat 6–12 rounds.',
      ],
    ),
    WorkoutModel(
      id: 'w5',
      name: 'Guided Mindfulness',
      description:
          'A calming 10-minute guided mindfulness meditation. Ideal during the '
          'luteal and menstrual phases when you need extra calm.',
      recommendedPhase: CyclePhase.menstrual,
      durationMinutes: 10,
      intensity: WorkoutIntensity.low,
      category: 'Meditation',
      videoUrl: 'https://youtu.be/KTkjZPQZuvk',
      steps: [
        'Find a quiet, comfortable seat.',
        'Close your eyes and take 3 deep cleansing breaths.',
        'Bring attention to your breath — observe each inhale and exhale.',
        'When thoughts arise, gently return focus to breathing.',
        'Slowly bring awareness back to your surroundings and open your eyes.',
      ],
    ),
  ];

  List<WorkoutModel> get _filteredWorkouts {
    if (_selectedCategory == 'All') return _workouts;
    return _workouts.where((w) => w.category == _selectedCategory).toList();
  }

  String? _extractVideoId(String? url) {
    if (url == null) return null;
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    // youtu.be/<id>
    if (uri.host.contains('youtu.be')) return uri.pathSegments.first;
    // youtube.com/watch?v=<id>
    if (uri.host.contains('youtube.com')) return uri.queryParameters['v'];
    return null;
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          // ── Markdown content ──
          const MarkdownContentView(assetPath: AssetPaths.physicalFitness),
          const SizedBox(height: AppSpacing.sectionGap),

          // ── Category filter chips ──
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final selected = cat == _selectedCategory;
                return FilterChip(
                  selected: selected,
                  label: Text(cat),
                  avatar: Icon(
                    _categoryIcons[cat],
                    size: 18,
                    color: selected ? Colors.white : AppColors.textMuted,
                  ),
                  labelStyle: AppTextStyles.label.copyWith(
                    color: selected ? Colors.white : AppColors.textBody,
                  ),
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primary,
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                    side: BorderSide(
                      color: selected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.sectionGap),
          const SectionHeader(title: 'Workouts'),
          const SizedBox(height: AppSpacing.componentGap),

          // ── Workout cards ──
          ..._filteredWorkouts.map((workout) {
            final videoId = _extractVideoId(workout.videoUrl);
            final hasVideo = videoId != null;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: NaaryaCard(
                onTap: hasVideo ? () => _openUrl(workout.videoUrl!) : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Video thumbnail
                    if (hasVideo) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSpacing.cardRadius - 4),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(
                                'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: AppColors.surfaceVariant,
                                  child: const Center(
                                    child: Icon(Icons.play_circle_fill_rounded,
                                        size: 48, color: AppColors.textMuted),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.85),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.play_arrow_rounded,
                                  color: Colors.white, size: 32),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // Header row
                    Row(
                      children: [
                        if (!hasVideo) ...[
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _categoryIcons[workout.category] ?? Icons.fitness_center,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                        ],
                        Expanded(
                          child: Text(workout.name, style: AppTextStyles.subtitle1),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Badges
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
                          bgColor: _intensityColor(workout.intensity).withValues(alpha: 0.1),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _Badge(
                          icon: Icons.category_outlined,
                          label: workout.category,
                          color: AppColors.textMuted,
                          bgColor: AppColors.surfaceVariant,
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),
                    Text(workout.description, style: AppTextStyles.body2),

                    if (hasVideo) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Icon(Icons.ondemand_video_rounded,
                              size: 16, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Tap to watch video',
                            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: AppSpacing.sectionGap),
        ],
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
          Text(label, style: AppTextStyles.caption.copyWith(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}
