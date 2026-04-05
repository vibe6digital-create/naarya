import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../core/utils/cycle_phase_calculator.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../widgets/common/naarya_card.dart';

class CycleTrackerScreen extends StatefulWidget {
  const CycleTrackerScreen({super.key});

  @override
  State<CycleTrackerScreen> createState() => _CycleTrackerScreenState();
}

class _CycleTrackerScreenState extends State<CycleTrackerScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  late DateTime _lastPeriodDate;
  late int _cycleLength;
  late int _periodLength;
  late CyclePhaseInfo _currentPhaseInfo;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _loadCycleData();
  }

  void _loadCycleData() {
    final storedDate = LocalStorageService.lastPeriodDate;
    if (storedDate != null && storedDate.isNotEmpty) {
      _lastPeriodDate = DateTime.parse(storedDate);
    } else {
      _lastPeriodDate = DateTime.now().subtract(const Duration(days: 14));
    }
    _cycleLength = LocalStorageService.cycleLength;
    _periodLength = LocalStorageService.periodLength;

    _currentPhaseInfo = CyclePhaseCalculator.calculate(
      lastPeriodStart: _lastPeriodDate,
      cycleLength: _cycleLength,
      periodLength: _periodLength,
    );
  }

  CyclePhase _getPhaseForDay(DateTime day) {
    final daysSinceStart = day.difference(_lastPeriodDate).inDays;
    final dayInCycle = (daysSinceStart % _cycleLength) + 1;
    final ovulationDay = _cycleLength - 14;

    if (dayInCycle <= _periodLength) {
      return CyclePhase.menstrual;
    } else if (dayInCycle <= ovulationDay - 2) {
      return CyclePhase.follicular;
    } else if (dayInCycle <= ovulationDay + 2) {
      return CyclePhase.ovulation;
    } else {
      return CyclePhase.luteal;
    }
  }

  Color _getPhaseColor(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return AppColors.phaseMenstrual;
      case CyclePhase.follicular:
        return AppColors.phaseFollicular;
      case CyclePhase.ovulation:
        return AppColors.phaseOvulation;
      case CyclePhase.luteal:
        return AppColors.phaseLuteal;
    }
  }

  Color _getPhaseBgColor(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return AppColors.phaseMenstrualBg;
      case CyclePhase.follicular:
        return AppColors.phaseFollicularBg;
      case CyclePhase.ovulation:
        return AppColors.phaseOvulationBg;
      case CyclePhase.luteal:
        return AppColors.phaseLutealBg;
    }
  }

  String _getPhaseLabel(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return 'Menstrual';
      case CyclePhase.follicular:
        return 'Follicular';
      case CyclePhase.ovulation:
        return 'Ovulation';
      case CyclePhase.luteal:
        return 'Luteal';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Cycle Tracker', style: AppTextStyles.h2.copyWith(color: AppColors.textOnPrimary)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCalendar(),
            Padding(
              padding: AppSpacing.pageHorizontal,
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.sectionGap),
                  _buildPhaseInfoCard(),
                  const SizedBox(height: AppSpacing.sectionGap),
                  _buildPhaseLegend(),
                  const SizedBox(height: AppSpacing.sectionGap),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.cycleLog);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        icon: const Icon(Icons.add),
        label: Text('Log Today', style: AppTextStyles.button),
      ),
    );
  }

  Widget _buildCalendar() {
    return NaaryaCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: TableCalendar(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2027, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: AppTextStyles.h3,
          leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.primary),
          rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.primary),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
          weekendStyle: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.phaseMenstrual,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            return _buildDayCell(day, isSelected: false, isToday: false);
          },
          todayBuilder: (context, day, focusedDay) {
            return _buildDayCell(day, isSelected: false, isToday: true);
          },
          selectedBuilder: (context, day, focusedDay) {
            return _buildDayCell(day, isSelected: true, isToday: false);
          },
        ),
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
          cellMargin: EdgeInsets.all(2),
        ),
      ),
    );
  }

  Widget _buildDayCell(DateTime day, {required bool isSelected, required bool isToday}) {
    final phase = _getPhaseForDay(day);
    final phaseColor = _getPhaseColor(phase);
    final phaseBgColor = _getPhaseBgColor(phase);

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isSelected ? phaseColor : phaseBgColor,
        shape: BoxShape.circle,
        border: isToday
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: AppTextStyles.body2.copyWith(
          color: isSelected ? Colors.white : phaseColor,
          fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPhaseInfoCard() {
    final phase = _currentPhaseInfo.phase;
    final phaseColor = _getPhaseColor(phase);
    final phaseBgColor = _getPhaseBgColor(phase);

    return NaaryaCard(
      color: phaseBgColor,
      border: Border.all(color: phaseColor.withValues(alpha: 0.3)),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: phaseColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getPhaseIcon(phase),
                  color: phaseColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentPhaseInfo.phaseName,
                      style: AppTextStyles.h2.copyWith(color: phaseColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Day ${_currentPhaseInfo.dayInCycle} of $_cycleLength',
                      style: AppTextStyles.subtitle2.copyWith(color: phaseColor.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _currentPhaseInfo.phaseDescription,
            style: AppTextStyles.body2.copyWith(color: AppColors.textBody),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(
                Icons.calendar_today,
                'Next period in ${_currentPhaseInfo.daysUntilNextPeriod} days',
                phaseColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(text, style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  IconData _getPhaseIcon(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return Icons.water_drop;
      case CyclePhase.follicular:
        return Icons.eco;
      case CyclePhase.ovulation:
        return Icons.sunny;
      case CyclePhase.luteal:
        return Icons.nightlight_round;
    }
  }

  Widget _buildPhaseLegend() {
    return NaaryaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Phase Legend', style: AppTextStyles.subtitle1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem(AppColors.phaseMenstrual, 'Menstrual'),
              _buildLegendItem(AppColors.phaseFollicular, 'Follicular'),
              _buildLegendItem(AppColors.phaseOvulation, 'Ovulation'),
              _buildLegendItem(AppColors.phaseLuteal, 'Luteal'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Column(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
