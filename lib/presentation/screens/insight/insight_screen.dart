import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../widgets/common/naarya_card.dart';
import '../../widgets/common/section_header.dart';

class InsightScreen extends StatelessWidget {
  const InsightScreen({super.key});

  void _showNotificationInfo(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'You\'ll be notified when new expert videos are added — every day or alternate day.',
          style: AppTextStyles.body2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static const List<_TipCard> _tips = [
    _TipCard(
      icon: Icons.water_drop_rounded,
      color: Color(0xFF1976D2),
      bg: Color(0xFFE3F2FD),
      title: 'Hydration & Hormones',
      body: 'Drinking enough water helps regulate cortisol and supports a healthy menstrual cycle. Aim for 8–10 glasses daily.',
    ),
    _TipCard(
      icon: Icons.bedtime_rounded,
      color: Color(0xFF7B52A8),
      bg: Color(0xFFEDE7F6),
      title: 'Sleep & Cycle Health',
      body: 'Poor sleep disrupts estrogen and progesterone levels. 7–9 hours of quality sleep per night is key for hormonal balance.',
    ),
    _TipCard(
      icon: Icons.self_improvement_rounded,
      color: Color(0xFFC2185B),
      bg: Color(0xFFFCE4EC),
      title: 'Yoga for Hormonal Balance',
      body: 'Poses like Cobra, Bridge, and Child\'s Pose stimulate glandular health and reduce cortisol. 20 minutes daily makes a difference.',
    ),
    _TipCard(
      icon: Icons.restaurant_rounded,
      color: Color(0xFF43A047),
      bg: Color(0xFFE8F5E9),
      title: 'Iron-Rich Foods',
      body: 'Spinach, lentils, and dates help replenish iron lost during menstruation and maintain energy throughout the cycle.',
    ),
    _TipCard(
      icon: Icons.favorite_rounded,
      color: Color(0xFFE53935),
      bg: Color(0xFFFFEBEE),
      title: 'Heart Health for Women',
      body: 'Estrogen protects the heart. After menopause, cardiovascular risk increases — regular exercise and diet matter more than ever.',
    ),
    _TipCard(
      icon: Icons.psychology_rounded,
      color: Color(0xFFF57C00),
      bg: Color(0xFFFFF3E0),
      title: 'Stress & Your Cycle',
      body: 'Chronic stress raises cortisol which can delay ovulation and worsen PMS. Daily mindfulness or journaling helps manage stress hormones.',
    ),
  ];

  static const List<_VideoCard> _videos = [
    _VideoCard(
      title: 'Understanding Your Cycle',
      expert: 'Dr. Niyati Sharma',
      duration: '12 min',
      category: 'Cycle Health',
      color: Color(0xFFC2185B),
    ),
    _VideoCard(
      title: 'Yoga for PCOS Relief',
      expert: 'Dr. Priya Gupta',
      duration: '18 min',
      category: 'Fitness',
      color: Color(0xFF7B52A8),
    ),
    _VideoCard(
      title: 'Nutrition in Pregnancy',
      expert: 'Dr. Anjali Mehta',
      duration: '15 min',
      category: 'Nutrition',
      color: Color(0xFF43A047),
    ),
    _VideoCard(
      title: 'Managing Menopause',
      expert: 'Dr. Niyati Sharma',
      duration: '20 min',
      category: 'Menopause',
      color: Color(0xFFF57C00),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Insights', style: AppTextStyles.h1.copyWith(color: AppColors.textDark)),
                        const SizedBox(height: 4),
                        Text(
                          'Expert videos, tips & health education',
                          style: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Builder(
                    builder: (ctx) => GestureDetector(
                      onTap: () => _showNotificationInfo(ctx),
                      child: Stack(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.notifications_outlined,
                                color: AppColors.textDark, size: 20),
                          ),
                          Positioned(
                            top: 8, right: 8,
                            child: Container(
                              width: 8, height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary, shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Expert Videos
              const SectionHeader(title: 'Expert Videos'),
              const SizedBox(height: 4),
              Text(
                'New videos added every day by our panel experts',
                style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: AppSpacing.componentGap),
              SizedBox(
                height: 168,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _videos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => _buildVideoCard(_videos[index]),
                ),
              ),
              const SizedBox(height: AppSpacing.sectionGap),

              // Health Tips
              const SectionHeader(title: 'Health Tips'),
              const SizedBox(height: AppSpacing.componentGap),
              ...List.generate(
                _tips.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.componentGap),
                  child: _buildTipCard(_tips[i]),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoCard(_VideoCard video) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail placeholder
          Container(
            height: 90,
            color: video.color.withValues(alpha: 0.12),
            child: Stack(
              children: [
                Center(
                  child: Icon(Icons.play_circle_fill_rounded,
                      size: 40, color: video.color.withValues(alpha: 0.7)),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(video.duration,
                        style: AppTextStyles.caption.copyWith(color: Colors.white, fontSize: 10)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: video.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(video.category,
                      style: AppTextStyles.caption.copyWith(
                        color: video.color, fontWeight: FontWeight.w600, fontSize: 9)),
                ),
                const SizedBox(height: 4),
                Text(video.title,
                    style: AppTextStyles.subtitle2.copyWith(fontSize: 12),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(video.expert,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textMuted, fontSize: 10),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(_TipCard tip) {
    return NaaryaCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: tip.bg, shape: BoxShape.circle),
            child: Icon(tip.icon, color: tip.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tip.title,
                    style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text(tip.body,
                    style: AppTextStyles.body2.copyWith(color: AppColors.textBody)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard {
  final IconData icon;
  final Color color;
  final Color bg;
  final String title;
  final String body;
  const _TipCard({required this.icon, required this.color, required this.bg,
      required this.title, required this.body});
}

class _VideoCard {
  final String title;
  final String expert;
  final String duration;
  final String category;
  final Color color;
  const _VideoCard({required this.title, required this.expert, required this.duration,
      required this.category, required this.color});
}
