import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../core/utils/cycle_phase_calculator.dart';
import '../../../core/utils/date_utils.dart';
import '../../widgets/common/naarya_card.dart';
import '../../widgets/common/section_header.dart';
import 'widgets/quick_action_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<String> _healthTips = [
    'Stay hydrated! Aim for at least 8 glasses of water daily to support your body through every cycle phase.',
    'Incorporate iron-rich foods like spinach, lentils, and dates during your menstrual phase to replenish lost nutrients.',
    'Regular gentle stretching can help reduce cramps and improve blood circulation during your period.',
    'Track your sleep patterns alongside your cycle to understand how hormonal changes affect your rest.',
    'Magnesium-rich foods like dark chocolate, nuts, and bananas can help ease PMS symptoms naturally.',
    'Practice deep breathing exercises for 5 minutes daily to manage stress and balance cortisol levels.',
    'Omega-3 fatty acids found in walnuts and flaxseeds can help reduce inflammation and menstrual pain.',
  ];

  String _getDailyTip() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _healthTips[dayOfYear % _healthTips.length];
  }

  Color _phaseColor(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:   return AppColors.phaseMenstrual;
      case CyclePhase.follicular:  return AppColors.phaseFollicular;
      case CyclePhase.ovulation:   return AppColors.phaseOvulation;
      case CyclePhase.luteal:      return AppColors.phaseLuteal;
    }
  }

  Color _phaseBgColor(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:   return AppColors.phaseMenstrualBg;
      case CyclePhase.follicular:  return AppColors.phaseFollicularBg;
      case CyclePhase.ovulation:   return AppColors.phaseOvulationBg;
      case CyclePhase.luteal:      return AppColors.phaseLutealBg;
    }
  }

  CyclePhaseInfo? _getCycleInfo() {
    final lastPeriodStr = LocalStorageService.lastPeriodDate;
    if (lastPeriodStr == null || lastPeriodStr.isEmpty) return null;
    final lastPeriod = DateTime.tryParse(lastPeriodStr);
    if (lastPeriod == null) return null;
    return CyclePhaseCalculator.calculate(
      lastPeriodStart: lastPeriod,
      cycleLength: LocalStorageService.cycleLength,
      periodLength: LocalStorageService.periodLength,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = LocalStorageService.userName;
    final displayName = userName.isNotEmpty ? userName : 'there';
    final greeting = AppDateUtils.greeting();
    final cycleInfo = _getCycleInfo();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreetingCard(greeting, displayName),
              const SizedBox(height: AppSpacing.sectionGap),

              if (cycleInfo != null) ...[
                _buildCycleSummaryCard(context, cycleInfo),
                const SizedBox(height: AppSpacing.sectionGap),
              ],

              // Daily Health Tip
              _buildHealthTipCard(),
              const SizedBox(height: AppSpacing.sectionGap),

              // Main Features
              const SectionHeader(title: 'Your Health Tools'),
              const SizedBox(height: AppSpacing.componentGap),
              _buildMainFeatureGrid(context),
              const SizedBox(height: AppSpacing.sectionGap),

              // Coming Soon
              const SectionHeader(title: 'Coming Soon'),
              const SizedBox(height: AppSpacing.componentGap),
              _buildComingSoonGrid(context),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingCard(String greeting, String displayName) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $displayName \u{1F338}',
                  style: AppTextStyles.h2.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  AppDateUtils.formatDayMonth(DateTime.now()),
                  style: AppTextStyles.body2.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleSummaryCard(BuildContext context, CyclePhaseInfo cycleInfo) {
    final phaseColor = _phaseColor(cycleInfo.phase);
    final phaseBg = _phaseBgColor(cycleInfo.phase);

    return NaaryaCard(
      onTap: () => Navigator.pushNamed(context, AppRoutes.cycleTracker),
      color: phaseBg,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Cycle Summary',
                  style: AppTextStyles.subtitle1.copyWith(color: AppColors.textDark)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: phaseColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                ),
                child: Text(
                  cycleInfo.phaseName,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: phaseColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildCycleStat('Day', '${cycleInfo.dayInCycle}', phaseColor),
              const SizedBox(width: 24),
              _buildCycleStat('Next Period', '${cycleInfo.daysUntilNextPeriod} days', phaseColor),
            ],
          ),
          const SizedBox(height: 12),
          Text(cycleInfo.phaseDescription,
              style: AppTextStyles.caption.copyWith(color: AppColors.textBody)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('View Details',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: phaseColor, fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios_rounded, size: 12, color: phaseColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCycleStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 2),
        Text(value,
            style: AppTextStyles.h3.copyWith(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildHealthTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLight.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Health Tip',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(_getDailyTip(), style: AppTextStyles.body2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainFeatureGrid(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.water_drop_rounded,
        illustrationIcon: Icons.calendar_month_rounded,
        title: 'Cycle Tracker',
        subtitle: 'Track your phases',
        color: AppColors.phaseMenstrual,
        bgColor: AppColors.phaseMenstrualBg,
        route: AppRoutes.cycleTracker,
      ),
      _QuickAction(
        icon: Icons.medical_services_rounded,
        illustrationIcon: Icons.local_hospital_rounded,
        title: 'Consult Doctor',
        subtitle: 'Meet our experts',
        color: AppColors.primary,
        bgColor: AppColors.primary.withValues(alpha: 0.1),
        route: AppRoutes.consult,
      ),
      _QuickAction(
        icon: Icons.restaurant_rounded,
        illustrationIcon: Icons.lunch_dining_rounded,
        title: 'Nutrition',
        subtitle: 'Eat well, feel good',
        color: AppColors.phaseFollicular,
        bgColor: AppColors.phaseFollicularBg,
        route: AppRoutes.nutrition,
      ),
      _QuickAction(
        icon: Icons.self_improvement_rounded,
        illustrationIcon: Icons.directions_run_rounded,
        title: 'Fitness',
        subtitle: 'Yoga & workouts',
        color: AppColors.phaseOvulation,
        bgColor: AppColors.phaseOvulationBg,
        route: AppRoutes.fitness,
      ),
      _QuickAction(
        icon: Icons.smart_toy_rounded,
        illustrationIcon: Icons.psychology_alt_rounded,
        title: 'AI Assistant',
        subtitle: 'Chat with Naarya AI',
        color: AppColors.info,
        bgColor: AppColors.infoLight,
        route: AppRoutes.aiChat,
      ),
      _QuickAction(
        icon: Icons.folder_shared_rounded,
        illustrationIcon: Icons.health_and_safety_rounded,
        title: 'Health Vault',
        subtitle: 'Medical records',
        color: AppColors.phaseLuteal,
        bgColor: AppColors.phaseLutealBg,
        route: AppRoutes.healthVault,
      ),
      _QuickAction(
        icon: Icons.child_care_rounded,
        illustrationIcon: Icons.pregnant_woman_rounded,
        title: 'Antenatal & Garbh Sanskar',
        subtitle: 'Expert sessions',
        color: AppColors.secondary,
        bgColor: AppColors.secondaryLight,
        route: AppRoutes.antenatal,
      ),
      _QuickAction(
        icon: Icons.psychology_rounded,
        illustrationIcon: Icons.spa_rounded,
        title: 'Mental Fitness',
        subtitle: 'Mind & Travel wellness',
        color: const Color(0xFF7B52A8),
        bgColor: const Color(0xFFEDE7F6),
        route: AppRoutes.mentalFitness,
      ),
      _QuickAction(
        icon: Icons.note_alt_rounded,
        illustrationIcon: Icons.edit_note_rounded,
        title: 'Keep Notes',
        subtitle: 'Tasks & reminders',
        color: const Color(0xFF5C8DBB),
        bgColor: const Color(0xFFE3F0FB),
        route: AppRoutes.todo,
      ),
      _QuickAction(
        icon: Icons.shield_rounded,
        illustrationIcon: Icons.verified_user_rounded,
        title: 'Safety & Legal',
        subtitle: 'Stay safe, know rights',
        color: AppColors.error,
        bgColor: AppColors.errorLight,
        route: AppRoutes.safety,
      ),
      _QuickAction(
        icon: Icons.shopping_bag_rounded,
        illustrationIcon: Icons.storefront_rounded,
        title: 'Products',
        subtitle: 'Wellness essentials',
        color: const Color(0xFFE91E8C),
        bgColor: const Color(0xFFFCE4EC),
        route: AppRoutes.products,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.componentGap,
        mainAxisSpacing: AppSpacing.componentGap,
        childAspectRatio: 1.05,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return QuickActionCard(
          icon: action.icon,
          illustrationIcon: action.illustrationIcon,
          title: action.title,
          subtitle: action.subtitle,
          iconColor: action.color,
          iconBackgroundColor: action.bgColor,
          onTap: () => Navigator.pushNamed(context, action.route),
        );
      },
    );
  }

  Widget _buildComingSoonGrid(BuildContext context) {
    final comingSoon = [
      _QuickAction(
        icon: Icons.biotech_rounded,
        illustrationIcon: Icons.science_rounded,
        title: 'Lab Tests',
        subtitle: 'Book at home',
        color: AppColors.textLight,
        bgColor: AppColors.surfaceVariant,
        route: '',
      ),
      _QuickAction(
        icon: Icons.medication_rounded,
        illustrationIcon: Icons.local_pharmacy_rounded,
        title: 'Medicine Order',
        subtitle: 'Doorstep delivery',
        color: AppColors.textLight,
        bgColor: AppColors.surfaceVariant,
        route: '',
      ),
      _QuickAction(
        icon: Icons.face_retouching_natural_rounded,
        illustrationIcon: Icons.face_rounded,
        title: 'Dermatology',
        subtitle: 'Skin consultation',
        color: AppColors.textLight,
        bgColor: AppColors.surfaceVariant,
        route: '',
      ),
      _QuickAction(
        icon: Icons.spa_rounded,
        illustrationIcon: Icons.eco_rounded,
        title: 'Naturopathy',
        subtitle: 'Natural healing',
        color: AppColors.textLight,
        bgColor: AppColors.surfaceVariant,
        route: '',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.componentGap,
        mainAxisSpacing: AppSpacing.componentGap,
        childAspectRatio: 1.05,
      ),
      itemCount: comingSoon.length,
      itemBuilder: (context, index) {
        final action = comingSoon[index];
        return QuickActionCard(
          icon: action.icon,
          illustrationIcon: action.illustrationIcon,
          title: action.title,
          subtitle: action.subtitle,
          iconColor: action.color,
          iconBackgroundColor: action.bgColor,
          isComingSoon: true,
        );
      },
    );
  }
}

class _QuickAction {
  final IconData icon;
  final IconData? illustrationIcon;
  final String title;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final String route;

  const _QuickAction({
    required this.icon,
    this.illustrationIcon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.route,
  });
}
