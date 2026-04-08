import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/routes/app_routes.dart';
import 'daily_log_screen.dart';

class CycleTrackerScreen extends StatefulWidget {
  const CycleTrackerScreen({super.key});

  @override
  State<CycleTrackerScreen> createState() => _CycleTrackerScreenState();
}

class _CycleTrackerScreenState extends State<CycleTrackerScreen> {
  late DateTime _displayMonth;
  late DateTime _selectedDate;

  Set<DateTime> _periodDates = {};
  Map<String, String> _notes = {};
  int _cycleLength = 28;
  int _periodLength = 5;
  DateTime? _lastPeriodStart;

  static const _dayHeaders = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
    _loadData();
  }

  // ── Helpers ──

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ── Data Loading ──

  void _loadData() {
    final storedDates = LocalStorageService.periodDates;
    if (storedDates.isNotEmpty) {
      _periodDates = storedDates.map((s) => DateTime.parse(s)).toSet();
    } else {
      final stored = LocalStorageService.lastPeriodDate;
      if (stored != null && stored.isNotEmpty) {
        final start = DateTime.parse(stored);
        final len = LocalStorageService.periodLength;
        _periodDates = Set.from(
          List.generate(len, (i) => _normalize(start.add(Duration(days: i)))),
        );
        _savePeriodDates();
      }
    }

    final notesJson = LocalStorageService.cycleNotesJson;
    if (notesJson != null && notesJson.isNotEmpty) {
      _notes = Map<String, String>.from(json.decode(notesJson));
    }

    _cycleLength = LocalStorageService.cycleLength;
    _periodLength = LocalStorageService.periodLength;
    _findLastPeriodStart();
  }

  void _findLastPeriodStart() {
    if (_periodDates.isEmpty) {
      _lastPeriodStart = null;
      return;
    }
    final sorted = _periodDates.toList()..sort();
    DateTime blockStart = sorted.last;
    for (int i = sorted.length - 2; i >= 0; i--) {
      if (blockStart.difference(sorted[i]).inDays <= 1) {
        blockStart = sorted[i];
      } else {
        break;
      }
    }
    _lastPeriodStart = blockStart;
    LocalStorageService.setLastPeriodDate(
      _lastPeriodStart!.toIso8601String().split('T')[0],
    );
  }

  void _savePeriodDates() {
    final dates =
        _periodDates.map((d) => d.toIso8601String().split('T')[0]).toList();
    LocalStorageService.setPeriodDates(dates);
  }

  void _saveNotes() {
    LocalStorageService.setCycleNotesJson(json.encode(_notes));
  }

  // ── Cycle Calculations ──

  int _getCycleDay(DateTime date) {
    if (_lastPeriodStart == null) return 0;
    final diff = _normalize(date).difference(_lastPeriodStart!).inDays;
    if (diff < 0) return 0;
    return (diff % _cycleLength) + 1;
  }

  bool _isFertileDay(DateTime date) {
    final cd = _getCycleDay(date);
    if (cd == 0) return false;
    final ovDay = _cycleLength - 14;
    return cd >= ovDay - 4 && cd <= ovDay + 1 && cd != ovDay;
  }

  bool _isOvulationDay(DateTime date) {
    final cd = _getCycleDay(date);
    if (cd == 0) return false;
    return cd == _cycleLength - 14;
  }

  bool _isPredictedPeriod(DateTime date) {
    final cd = _getCycleDay(date);
    if (cd == 0) return false;
    final normalized = _normalize(date);
    if (_periodDates.contains(normalized)) return false;
    final today = _normalize(DateTime.now());
    if (normalized.isBefore(today)) return false;
    return cd <= _periodLength;
  }

  String _getPregnancyChance(int cycleDay) {
    if (cycleDay == 0) return '';
    final ovDay = _cycleLength - 14;
    if (cycleDay == ovDay) return 'High - chance of getting pregnant';
    if ((cycleDay - ovDay).abs() <= 2) {
      return 'Medium - chance of getting pregnant';
    }
    return 'Low - chance of getting pregnant';
  }

  // ── Calendar Grid Helpers ──

  List<DateTime?> _getMonthDays() {
    final first = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final last = DateTime(_displayMonth.year, _displayMonth.month + 1, 0);
    final startWeekday = first.weekday % 7;

    final List<DateTime?> days = [];
    for (int i = 0; i < startWeekday; i++) {
      days.add(null);
    }
    for (int d = 1; d <= last.day; d++) {
      days.add(DateTime(_displayMonth.year, _displayMonth.month, d));
    }
    return days;
  }

  void _prevMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
    });
  }

  // ── Navigation ──

  Future<void> _openEditPeriod() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.editPeriod,
      arguments: _periodDates,
    );
    if (result != null && result is Set<DateTime>) {
      setState(() {
        _periodDates = result;
        _findLastPeriodStart();
        _savePeriodDates();
      });
    }
  }

  Future<void> _openDailyLog() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DailyLogScreen(date: _selectedDate),
      ),
    );
    if (result == true) {
      setState(() {}); // Refresh to show log indicator
    }
  }

  bool _hasLog(DateTime date) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    final json = LocalStorageService.dailyLogJson;
    if (json == null || json.isEmpty) return false;
    final allLogs = Map<String, dynamic>.from(jsonDecode(json));
    return allLogs.containsKey(key);
  }

  void _showCycleInfoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Cycle Information', style: AppTextStyles.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _infoRow('Cycle length', '$_cycleLength days'),
            _infoRow('Period length', '$_periodLength days'),
            if (_lastPeriodStart != null)
              _infoRow(
                  'Last period', DateFormat('MMM d, y').format(_lastPeriodStart!)),
            _infoRow('Ovulation day', 'Day ${_cycleLength - 14}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body2),
          Text(value,
              style: AppTextStyles.subtitle1
                  .copyWith(color: AppColors.textDark)),
        ],
      ),
    );
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const SizedBox(height: 4),
            _buildDayHeaders(),
            const SizedBox(height: 4),
            Expanded(child: _buildCalendarGrid()),
            _buildActionButtons(),
            _buildBottomInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final monthName = DateFormat('MMM').format(_displayMonth);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.textDark, size: 20),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    monthName,
                    style: GoogleFonts.poppins(
                      color: AppColors.textOnPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                  child: Text(
                    'Year',
                    style: GoogleFonts.poppins(
                      color: AppColors.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              GestureDetector(
                onTap: _prevMonth,
                child: const Icon(Icons.chevron_left,
                    color: AppColors.textMuted, size: 28),
              ),
              GestureDetector(
                onTap: _nextMonth,
                child: const Icon(Icons.chevron_right,
                    color: AppColors.textMuted, size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayHeaders() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: _dayHeaders
            .map((d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final days = _getMonthDays();
    final rows = <Widget>[];

    for (int i = 0; i < days.length; i += 7) {
      final rowDays = <DateTime?>[];
      for (int j = i; j < i + 7 && j < days.length; j++) {
        rowDays.add(days[j]);
      }
      while (rowDays.length < 7) {
        rowDays.add(null);
      }
      rows.add(
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: rowDays.map((day) {
                if (day == null) return const Expanded(child: SizedBox());
                return Expanded(child: _buildDayCell(day));
              }).toList(),
            ),
          ),
        ),
      );
    }

    while (rows.length < 6) {
      rows.add(const Expanded(child: SizedBox()));
    }

    return Column(children: rows);
  }

  Widget _buildDayCell(DateTime day) {
    final normalized = _normalize(day);
    final today = _normalize(DateTime.now());
    final isToday = _isSameDay(normalized, today);
    final isPeriod = _periodDates.contains(normalized);
    final isFertile = _isFertileDay(day);
    final isOvulation = _isOvulationDay(day);
    final isPredicted = _isPredictedPeriod(day);
    final isSelected = _isSameDay(normalized, _normalize(_selectedDate));
    final cycleDay = _getCycleDay(day);
    final noteKey = DateFormat('yyyy-MM-dd').format(day);
    final hasNote = _notes.containsKey(noteKey) || _hasLog(day);

    Color? bgColor;
    Color textColor = AppColors.textDark;

    if (isPeriod) {
      bgColor = AppColors.primary;
      textColor = AppColors.textOnPrimary;
    } else if (isToday) {
      bgColor = AppColors.secondary;
      textColor = AppColors.textOnPrimary;
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedDate = day),
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: isSelected && bgColor == null
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5)
              : null,
        ),
        child: Stack(
          children: [
            // Date number + cycle day superscript
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 6, right: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${day.day}',
                    style: GoogleFonts.poppins(
                      color: isPredicted
                          ? AppColors.primaryLight
                          : textColor,
                      fontSize: 17,
                      fontWeight: (isToday || isPeriod)
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                  if (cycleDay > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 1, left: 1),
                      child: Text(
                        '$cycleDay',
                        style: GoogleFonts.dmSans(
                          color: (isPeriod || isToday)
                              ? textColor.withValues(alpha: 0.6)
                              : AppColors.textLight,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Fertility flower icon
            if (isFertile)
              Positioned(
                bottom: 4,
                left: 0,
                right: 0,
                child: Center(
                  child: Icon(
                    Icons.local_florist,
                    size: 14,
                    color: AppColors.phaseOvulation,
                  ),
                ),
              ),

            // Ovulation dot
            if (isOvulation)
              Positioned(
                bottom: 6,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.phaseLuteal,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),

            // Predicted period bar
            if (isPredicted)
              Positioned(
                bottom: 0,
                left: 4,
                right: 4,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

            // Note indicator dot
            if (hasNote)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.warning,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _openEditPeriod,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                'Edit period',
                style: AppTextStyles.subtitle1.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: _openDailyLog,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                'Daily Log',
                style: AppTextStyles.subtitle1.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFertilityLabel(DateTime date) {
    if (_isOvulationDay(date)) return 'Ovulation day';
    if (_isFertileDay(date)) return 'Fertile window';
    if (_periodDates.contains(_normalize(date))) return 'Period day';
    if (_isPredictedPeriod(date)) return 'Predicted period';
    return '';
  }

  Color _getFertilityColor(DateTime date) {
    if (_isOvulationDay(date)) return AppColors.phaseLuteal;
    if (_isFertileDay(date)) return AppColors.phaseOvulation;
    if (_periodDates.contains(_normalize(date))) return AppColors.phaseMenstrual;
    if (_isPredictedPeriod(date)) return AppColors.primaryLight;
    return AppColors.textMuted;
  }

  String _getChanceLevel(int cycleDay) {
    if (cycleDay == 0) return '';
    final ovDay = _cycleLength - 14;
    if (cycleDay == ovDay) return 'High';
    if ((cycleDay - ovDay).abs() <= 2) return 'Medium';
    if ((cycleDay - ovDay).abs() <= 4) return 'Low';
    return 'Very low';
  }

  Color _getChanceColor(String level) {
    switch (level) {
      case 'High':
        return AppColors.phaseMenstrual;
      case 'Medium':
        return AppColors.phaseOvulation;
      case 'Low':
        return AppColors.phaseFollicular;
      default:
        return AppColors.textMuted;
    }
  }

  Widget _buildBottomInfo() {
    final cycleDay = _getCycleDay(_selectedDate);
    final chanceLevel = _getChanceLevel(cycleDay);
    final dateStr = DateFormat('MMM d').format(_selectedDate);
    final fertilityLabel = _getFertilityLabel(_selectedDate);
    final fertilityColor = _getFertilityColor(_selectedDate);
    final noteKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final note = _notes[noteKey];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(dateStr, style: AppTextStyles.h1),
              const Spacer(),
              if (cycleDay > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Day $cycleDay',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _showCycleInfoDialog,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.textMuted, width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(Icons.info_outline, size: 14, color: AppColors.textMuted),
                  ),
                ),
              ),
            ],
          ),
          if (fertilityLabel.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: fertilityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: fertilityColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isOvulationDay(_selectedDate) ? Icons.egg_rounded
                        : _isFertileDay(_selectedDate) ? Icons.local_florist
                        : Icons.water_drop_rounded,
                    size: 16,
                    color: fertilityColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    fertilityLabel,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: fertilityColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (chanceLevel.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Pregnancy chance: ', style: AppTextStyles.body2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getChanceColor(chanceLevel).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    chanceLevel,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: _getChanceColor(chanceLevel),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (note != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.note, size: 16, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note,
                      style: AppTextStyles.body2.copyWith(color: AppColors.textBody),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
