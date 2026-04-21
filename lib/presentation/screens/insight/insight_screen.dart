import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/expert_video_service.dart';
import '../../../core/services/health_tip_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../data/models/expert_video_model.dart';
import '../fitness/video_player_screen.dart';
import '../../widgets/common/naarya_card.dart';
import '../../widgets/common/section_header.dart';

class InsightScreen extends StatelessWidget {
  const InsightScreen({super.key});

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
                        Text('Insights',
                            style: AppTextStyles.h1
                                .copyWith(color: AppColors.textDark)),
                        const SizedBox(height: 4),
                        Text(
                          'Expert videos, tips & health education',
                          style: AppTextStyles.body2
                              .copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
                      child: Stack(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.notifications_outlined,
                                color: AppColors.textDark, size: 20),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sectionGap),

              // Expert Videos
              const SectionHeader(title: 'Expert Videos'),
              const SizedBox(height: 4),
              Text(
                'New videos added every day by our panel experts',
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: AppSpacing.componentGap),
              StreamBuilder<List<ExpertVideoModel>>(
                stream: ExpertVideoService.videosStream(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 168,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _VideoSkeleton(),
                          const SizedBox(width: 12),
                          _VideoSkeleton(),
                          const SizedBox(width: 12),
                          _VideoSkeleton(),
                        ],
                      ),
                    );
                  }
                  final videos = snap.data ?? [];
                  if (videos.isEmpty) {
                    return const SizedBox(
                      height: 168,
                      child: Center(
                        child: Text('No videos yet — check back soon!'),
                      ),
                    );
                  }
                  return SizedBox(
                    height: 168,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: videos.length,
                      separatorBuilder: (context, i) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) =>
                          _buildVideoCard(context, videos[index]),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sectionGap),

              // Health Tips
              const SectionHeader(title: 'Health Tips'),
              const SizedBox(height: AppSpacing.componentGap),
              StreamBuilder<List<HealthTip>>(
                stream: HealthTipService.tipsStream(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return Column(
                      children: List.generate(
                        3,
                        (i) => Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppSpacing.componentGap),
                          child: _TipSkeleton(),
                        ),
                      ),
                    );
                  }
                  if (snap.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text('Error: ${snap.error}',
                          style: AppTextStyles.body2
                              .copyWith(color: AppColors.error)),
                    );
                  }
                  final tips = snap.data ?? [];
                  if (tips.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: Text('No tips available.')),
                    );
                  }
                  return Column(
                    children: tips
                        .map((tip) => Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppSpacing.componentGap),
                              child: _buildTipCard(tip),
                            ))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, ExpertVideoModel video) {
    final thumbnail = video.resolvedThumbnail;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: video)),
      ),
      child: Container(
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
            // Thumbnail
            SizedBox(
              height: 110,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  thumbnail != null
                      ? CachedNetworkImage(
                          imageUrl: thumbnail,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: AppColors.surfaceVariant),
                          errorWidget: (context, url, err) => Container(
                            color: AppColors.primary.withValues(alpha: 0.12),
                          ),
                        )
                      : Container(
                          color: AppColors.primary.withValues(alpha: 0.12),
                        ),
                  Container(color: Colors.black.withValues(alpha: 0.22)),
                  Center(
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow_rounded,
                          color: AppColors.primary, size: 22),
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
                  Text(video.title,
                      style: AppTextStyles.subtitle2.copyWith(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(video.instructor,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textMuted, fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(HealthTip tip) {
    return NaaryaCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tip.imageUrl != null && tip.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: tip.imageUrl!,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                    height: 140, color: AppColors.surfaceVariant),
                errorWidget: (context, url, err) => const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lightbulb_rounded,
                      color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (tip.title.isNotEmpty)
                        Text(tip.title,
                            style: AppTextStyles.subtitle2.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark)),
                      if (tip.title.isNotEmpty && tip.body.isNotEmpty)
                        const SizedBox(height: 4),
                      if (tip.body.isNotEmpty)
                        Text(tip.body,
                            style: AppTextStyles.body2
                                .copyWith(color: AppColors.textBody)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skeletons ────────────────────────────────────────────────────────────────

class _VideoSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 110, color: AppColors.surfaceVariant),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 12,
                    width: 140,
                    decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 6),
                Container(
                    height: 10,
                    width: 90,
                    decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(4))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NaaryaCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: AppColors.surfaceVariant, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 6),
                Container(
                    height: 12,
                    width: 180,
                    decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(4))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
