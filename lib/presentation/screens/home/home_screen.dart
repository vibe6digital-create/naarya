import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/daily_health_tip_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../core/utils/cycle_phase_calculator.dart';
import '../../../core/utils/date_utils.dart';
import '../../widgets/common/section_header.dart';
import 'widgets/quick_action_card.dart';

class HomeScreen extends StatefulWidget {
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

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  DailyHealthTipData? _dailyTip;
  VideoPlayerController? _penguinController;
  int _notificationCount = 0;
  StreamSubscription<QuerySnapshot>? _notificationSub;

  @override
  void initState() {
    super.initState();
    DailyHealthTipService.getDailyTip().then((data) {
      if (mounted) setState(() => _dailyTip = data);
    });
    _penguinController =
        VideoPlayerController.asset('assets/images/penguin.webm')
          ..initialize().then((_) {
            if (mounted) {
              setState(() {});
              _penguinController!.setLooping(true);
              _penguinController!.setVolume(0);
              _penguinController!.play();
            }
          });
    _notificationSub = FirebaseFirestore.instance
        .collection('notifications')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snap) {
      if (mounted) setState(() => _notificationCount = snap.docs.length);
    });
  }

  @override
  void dispose() {
    _penguinController?.dispose();
    _notificationSub?.cancel();
    super.dispose();
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
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      // Cycle Tracker drawer — opens when penguin icon is tapped
      drawer: cycleInfo != null
          ? Drawer(
              backgroundColor: AppColors.background,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cycle Tracker',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCycleSummaryCard(context, cycleInfo),
                    ],
                  ),
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreetingCard(context, greeting, displayName),
              const SizedBox(height: AppSpacing.sectionGap),

              // Daily Health Tip
              _buildHealthTipCard(context),
              const SizedBox(height: AppSpacing.sectionGap),

              // Main Features
              SectionHeader(
                title: 'Your Health Tools',
                actionText: 'See All',
                onAction: () {},
              ),
              const SizedBox(height: AppSpacing.componentGap),
              _buildMainFeatureGrid(context),
              const SizedBox(height: AppSpacing.sectionGap),

              // Coming Soon
              SectionHeader(
                title: 'Coming Soon',
                actionText: 'Explore All',
                onAction: () {},
              ),
              const SizedBox(height: AppSpacing.componentGap),
              _buildComingSoonGrid(context),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingCard(BuildContext context, String greeting, String displayName) {
    return Container(
      height: 118,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE57BA8), Color(0xFFF8A8C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0x28D4688A),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // ── Decorative circles (provide depth for blur) ──
          Positioned(
            right: -28,
            top: -28,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 55,
            bottom: -25,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -10,
            bottom: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // ── Glassmorphism frosted layer ──
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),
            ),
          ),

          // ── Content ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$greeting, $displayName \u{1F338}',
                        style: AppTextStyles.h2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppDateUtils.formatDayMonth(DateTime.now()),
                        style: AppTextStyles.body2.copyWith(
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                      ),
                    ],
                  ),
                ),
                // Penguin icon — opens Cycle Tracker drawer
                GestureDetector(
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: _penguinController != null &&
                              _penguinController!.value.isInitialized
                          ? FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _penguinController!.value.size.width,
                                height: _penguinController!.value.size.height,
                                child: VideoPlayer(_penguinController!),
                              ),
                            )
                          : Image.asset(
                              'assets/images/penguin.gif',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Notification bell with badge
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.45),
                            width: 1.2,
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      if (_notificationCount > 0)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                                minWidth: 18, minHeight: 18),
                            child: Text(
                              _notificationCount > 99
                                  ? '99+'
                                  : '$_notificationCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
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

  String _heroTitle(CyclePhaseInfo info) {
    switch (info.phase) {
      case CyclePhase.menstrual:   return 'Period';
      case CyclePhase.follicular:  return 'Next Ovulation';
      case CyclePhase.ovulation:   return 'Ovulation';
      case CyclePhase.luteal:      return 'Next Period';
    }
  }

  String _heroValue(CyclePhaseInfo info, int cycleLength) {
    switch (info.phase) {
      case CyclePhase.menstrual:   return 'Day ${info.dayInCycle}';
      case CyclePhase.follicular:
        final ovDay = cycleLength - 14;
        return '${ovDay - info.dayInCycle} Days Left';
      case CyclePhase.ovulation:   return 'Fertile Window';
      case CyclePhase.luteal:      return '${info.daysUntilNextPeriod} Days Left';
    }
  }

  String _heroSubtitle(CyclePhaseInfo info) {
    return 'Next period: ${info.daysUntilNextPeriod} days left';
  }

  String _fertilityLabel(CyclePhaseInfo info, int cycleLength) {
    final cycleDay = info.dayInCycle;
    final ovDay = cycleLength - 14;
    if (cycleDay == ovDay || (cycleDay - ovDay).abs() <= 1) {
      return 'High chance of getting pregnant';
    } else if ((cycleDay - ovDay).abs() <= 4) {
      return 'Medium chance of getting pregnant';
    }
    return 'Low chance of getting pregnant';
  }

  Color _fertilityBannerColor(CyclePhaseInfo info, int cycleLength) {
    final cycleDay = info.dayInCycle;
    final ovDay = cycleLength - 14;
    if (cycleDay == ovDay || (cycleDay - ovDay).abs() <= 1) {
      return AppColors.phaseMenstrual;
    } else if ((cycleDay - ovDay).abs() <= 4) {
      return AppColors.phaseOvulation;
    }
    return AppColors.primary;
  }

  Widget _buildCycleSummaryCard(BuildContext context, CyclePhaseInfo cycleInfo) {
    final cycleLength = LocalStorageService.cycleLength;
    final bannerColor = _fertilityBannerColor(cycleInfo, cycleLength);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.cycleTracker),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surfaceVariant,
              AppColors.background,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow,
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: 20,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Penguin mascot — bottom right
            Positioned(
              right: 4,
              bottom: 4,
              child: Image.asset(
                'assets/images/penguin.png',
                width: 90,
                height: 90,
                fit: BoxFit.contain,
              ),
            ),

            // Main content
            Column(
              children: [
                // Fertility banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  color: bannerColor.withValues(alpha: 0.6),
                  child: Center(
                    child: Text(
                      _fertilityLabel(cycleInfo, cycleLength),
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                // Hero content
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Column(
                    children: [
                      Text(
                        _heroTitle(cycleInfo),
                        style: AppTextStyles.subtitle2.copyWith(
                          color: AppColors.textBody,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _heroValue(cycleInfo, cycleLength),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.display.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _heroSubtitle(cycleInfo),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Edit Period pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Edit Period',
                          style: AppTextStyles.buttonSmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildHealthTipCard(BuildContext context) {
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;

    final String tipText = _dailyTip?.tip ??
        HomeScreen._healthTips[dayOfYear % HomeScreen._healthTips.length];

    final parts = <String>[tipText];
    if (_dailyTip?.awareness != null) parts.add(_dailyTip!.awareness!);
    if (_dailyTip?.thought != null) parts.add('"${_dailyTip!.thought}"');
    final tip = parts.join('\n\n');

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
            child: const Icon(Icons.lightbulb_rounded,
                color: AppColors.primary, size: 20),
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
                Text(tip, style: AppTextStyles.body2),
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
        icon: Icons.notifications_active_rounded,
        assetImagePath: 'assets/images/reminder.png',
        title: 'Reminder',
        subtitle: 'Never miss a thing',
        color: const Color(0xFFE57BA8),
        bgColor: const Color(0xFFFCE4F0),
        route: AppRoutes.reminders,
      ),
      _QuickAction(
        icon: Icons.note_alt_rounded,
        assetImagePath: 'assets/images/Keep notes.png',
        title: 'Keep Notes',
        subtitle: 'Tasks & reminders',
        color: const Color(0xFF5C8DBB),
        bgColor: const Color(0xFFE3F0FB),
        route: AppRoutes.todo,
      ),
      _QuickAction(
        icon: Icons.shield_rounded,
        assetImagePath: 'assets/images/Safety & legal.png',
        title: 'Safety & Legal',
        subtitle: 'Stay safe, know rights',
        color: AppColors.error,
        bgColor: AppColors.errorLight,
        route: AppRoutes.safety,
      ),
      _QuickAction(
        icon: Icons.folder_shared_rounded,
        assetImagePath: 'assets/images/medicalrecords.png',
        title: 'Medical Records',
        subtitle: 'Your health vault',
        color: AppColors.phaseLuteal,
        bgColor: AppColors.phaseLutealBg,
        route: AppRoutes.healthVault,
      ),
      _QuickAction(
        icon: Icons.medical_services_rounded,
        assetImagePath: 'assets/images/Consult Doctor.png',
        title: 'Consult Doctor',
        subtitle: 'Meet our experts',
        color: AppColors.primary,
        bgColor: AppColors.primary.withValues(alpha: 0.1),
        route: AppRoutes.consult,
      ),
      _QuickAction(
        icon: Icons.child_care_rounded,
        assetImagePath: 'assets/images/Garbhsanskar.png',
        title: 'Antenatal & Garbh Sanskar',
        subtitle: 'Expert sessions',
        color: AppColors.secondary,
        bgColor: AppColors.secondaryLight,
        route: AppRoutes.antenatal,
      ),
      _QuickAction(
        icon: Icons.self_improvement_rounded,
        assetImagePath: 'assets/images/Physicalfitness.png',
        title: 'Physical Fitness',
        subtitle: 'Yoga & workouts',
        color: AppColors.phaseOvulation,
        bgColor: AppColors.phaseOvulationBg,
        route: AppRoutes.fitness,
      ),
      _QuickAction(
        icon: Icons.psychology_rounded,
        assetImagePath: 'assets/images/mentalfitness.png',
        title: 'Mental Fitness',
        subtitle: 'Mind & wellness',
        color: const Color(0xFF7B52A8),
        bgColor: const Color(0xFFEDE7F6),
        route: AppRoutes.mentalFitness,
      ),
      _QuickAction(
        icon: Icons.water_drop_rounded,
        assetImagePath: 'assets/images/cycle tracker.png',
        title: 'Cycle Tracker',
        subtitle: 'Track your phases',
        color: AppColors.phaseMenstrual,
        bgColor: AppColors.phaseMenstrualBg,
        route: AppRoutes.cycleTracker,
      ),
      _QuickAction(
        icon: Icons.spa_rounded,
        assetImagePath: 'assets/images/naturopathy.png',
        title: 'Naturopathy',
        subtitle: 'Natural healing',
        color: const Color(0xFF2E7D32),
        bgColor: const Color(0xFFE8F5E9),
        route: AppRoutes.naturopathy,
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
          illustrationEmoji: action.illustrationEmoji,
          imageUrl: action.imageUrl,
          assetImagePath: action.assetImagePath,
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
        illustrationEmoji: '\u{1F9EA}',
        imageUrl: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=300&h=350&fit=crop&auto=format&q=80',
        title: 'Lab Test',
        subtitle: 'Book at home',
        color: AppColors.textLight,
        bgColor: AppColors.surfaceVariant,
        route: '',
      ),
      _QuickAction(
        icon: Icons.shopping_bag_rounded,
        illustrationEmoji: '\u{1F33A}',
        imageUrl: 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=300&h=350&fit=crop&auto=format&q=80',
        title: 'Naarya Products',
        subtitle: 'Wellness essentials',
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
          illustrationEmoji: action.illustrationEmoji,
          imageUrl: action.imageUrl,
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
  final String? illustrationEmoji;
  final String? imageUrl;
  final String? assetImagePath;
  final String title;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final String route;

  const _QuickAction({
    required this.icon,
    this.illustrationEmoji,
    this.imageUrl,
    this.assetImagePath,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.route,
  });
}
