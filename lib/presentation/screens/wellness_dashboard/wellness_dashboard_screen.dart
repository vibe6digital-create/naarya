import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../widgets/common/naarya_card.dart';
import '../../widgets/common/section_header.dart';

class WellnessDashboardScreen extends StatelessWidget {
  const WellnessDashboardScreen({super.key});

  // ── Mock data ──

  static const _overallScore = 72;

  static const List<_ScoreCategory> _categories = [
    _ScoreCategory(
      label: 'Nutrition',
      score: 75,
      icon: Icons.restaurant_rounded,
      color: Color(0xFF2E7D32), // green
    ),
    _ScoreCategory(
      label: 'Fitness',
      score: 68,
      icon: Icons.fitness_center_rounded,
      color: Color(0xFFF57C00), // orange
    ),
    _ScoreCategory(
      label: 'Sleep',
      score: 80,
      icon: Icons.bedtime_rounded,
      color: Color(0xFF3949AB), // indigo
    ),
    _ScoreCategory(
      label: 'Mood',
      score: 65,
      icon: Icons.mood_rounded,
      color: Color(0xFFFFA000), // amber
    ),
    _ScoreCategory(
      label: 'Cycle Health',
      score: 72,
      icon: Icons.favorite_rounded,
      color: Color(0xFFE91E63), // pink
    ),
  ];

  // 7-day mock trend
  static const _weeklyScores = [64, 68, 70, 66, 72, 74, 72];
  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String get _lowestCategory {
    var lowest = _categories.first;
    for (final c in _categories) {
      if (c.score < lowest.score) lowest = c;
    }
    return lowest.label;
  }

  List<String> _tipsForLowest(String category) {
    switch (category) {
      case 'Mood':
        return [
          'Try journaling for 5 minutes each morning to process your thoughts.',
          'Spend at least 15 minutes outdoors in natural sunlight.',
          'Practice gratitude — write down 3 things you\'re thankful for today.',
          'Limit screen time before bed to improve sleep quality and mood.',
        ];
      case 'Fitness':
        return [
          'Start with a 15-minute walk today — consistency beats intensity.',
          'Try gentle yoga or stretching if high-intensity feels too much.',
          'Set a daily step goal and gradually increase it each week.',
          'Find a workout buddy for accountability and motivation.',
        ];
      case 'Nutrition':
        return [
          'Add one extra serving of vegetables to each meal today.',
          'Stay hydrated — aim for 8 glasses of water daily.',
          'Reduce processed food intake and cook one meal at home.',
          'Include a source of protein in every meal for sustained energy.',
        ];
      case 'Sleep':
        return [
          'Maintain a consistent sleep schedule, even on weekends.',
          'Create a calming bedtime routine — dim lights 30 minutes before sleep.',
          'Avoid caffeine after 2 PM for better sleep quality.',
          'Keep your bedroom cool, dark, and quiet.',
        ];
      default:
        return [
          'Track your cycle regularly for better health insights.',
          'Stay consistent with self-care routines throughout your cycle.',
          'Consult your healthcare provider for personalised advice.',
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final tips = _tipsForLowest(_lowestCategory);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Wellness Score')),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          // ── Big circular score ──
          Center(
            child: CircularPercentIndicator(
              radius: 90,
              lineWidth: 14,
              percent: _overallScore / 100,
              animation: true,
              animationDuration: 1200,
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: AppColors.primary,
              backgroundColor: AppColors.border,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_overallScore',
                    style: AppTextStyles.h1.copyWith(
                      fontSize: 42,
                      color: AppColors.primary,
                    ),
                  ),
                  Text('out of 100', style: AppTextStyles.caption),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),
          Center(
            child: Text(
              _scoreLabel(_overallScore),
              style: AppTextStyles.subtitle1.copyWith(color: AppColors.primary),
            ),
          ),

          const SizedBox(height: AppSpacing.sectionGap),

          // ── Score breakdown grid ──
          const SectionHeader(title: 'Score Breakdown'),
          const SizedBox(height: AppSpacing.componentGap),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.componentGap,
            crossAxisSpacing: AppSpacing.componentGap,
            childAspectRatio: 1.45,
            children: _categories.map((cat) => _ScoreCard(category: cat)).toList(),
          ),

          const SizedBox(height: AppSpacing.sectionGap),

          // ── Weekly trend chart ──
          const SectionHeader(title: 'Weekly Trend'),
          const SizedBox(height: AppSpacing.componentGap),

          NaaryaCard(
            padding: const EdgeInsets.fromLTRB(12, 20, 16, 12),
            child: SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: 50,
                  maxY: 100,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 10,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: AppColors.border,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 10,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= _dayLabels.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(_dayLabels[idx], style: AppTextStyles.caption),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        _weeklyScores.length,
                        (i) => FlSpot(i.toDouble(), _weeklyScores[i].toDouble()),
                      ),
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) =>
                            FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.surface,
                          strokeWidth: 2.5,
                          strokeColor: AppColors.primary,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => AppColors.primary,
                      tooltipRoundedRadius: 8,
                      getTooltipItems: (spots) => spots.map((s) {
                        return LineTooltipItem(
                          '${s.y.toInt()}',
                          AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sectionGap),

          // ── Tips section ──
          SectionHeader(title: 'Tips to Improve $_lowestCategory'),
          const SizedBox(height: AppSpacing.componentGap),

          NaaryaCard(
            child: Column(
              children: tips.asMap().entries.map((entry) {
                final isLast = entry.key == tips.length - 1;
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(entry.value, style: AppTextStyles.body2),
                        ),
                      ],
                    ),
                    if (!isLast) const SizedBox(height: AppSpacing.md),
                  ],
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: AppSpacing.sectionGap),
        ],
      ),
    );
  }

  String _scoreLabel(int score) {
    if (score >= 85) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 55) return 'Fair';
    return 'Needs Attention';
  }
}

// ──────────────────── Helper models & widgets ────────────────────

class _ScoreCategory {
  final String label;
  final int score;
  final IconData icon;
  final Color color;

  const _ScoreCategory({
    required this.label,
    required this.score,
    required this.icon,
    required this.color,
  });
}

class _ScoreCard extends StatelessWidget {
  final _ScoreCategory category;

  const _ScoreCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final percent = category.score / 100;

    return NaaryaCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(category.icon, color: category.color, size: 20),
              ),
              const Spacer(),
              Text(
                '${category.score}',
                style: AppTextStyles.h2.copyWith(color: category.color),
              ),
            ],
          ),
          const Spacer(),
          Text(category.label, style: AppTextStyles.subtitle2),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: category.color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(category.color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
