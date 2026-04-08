import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class EditPeriodScreen extends StatefulWidget {
  final Set<DateTime> initialDates;

  const EditPeriodScreen({super.key, required this.initialDates});

  @override
  State<EditPeriodScreen> createState() => _EditPeriodScreenState();
}

class _EditPeriodScreenState extends State<EditPeriodScreen> {
  late Set<DateTime> _selectedDates;
  late ScrollController _scrollController;

  static const _dayHeaders = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  List<DateTime> get _months {
    final now = DateTime.now();
    return List.generate(6, (i) => DateTime(now.year, now.month - 4 + i));
  }

  @override
  void initState() {
    super.initState();
    _selectedDates = Set.from(widget.initialDates);
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        _scrollController.jumpTo(maxScroll * 0.65);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _toggleDate(DateTime date) {
    setState(() {
      final n = _normalize(date);
      if (_selectedDates.contains(n)) {
        _selectedDates.remove(n);
      } else {
        _selectedDates.add(n);
      }
    });
  }

  int _computePeriodDayNum(DateTime date) {
    final sorted = _selectedDates.toList()..sort();
    final n = _normalize(date);

    List<DateTime> currentBlock = [];
    for (final d in sorted) {
      if (currentBlock.isEmpty ||
          d.difference(currentBlock.last).inDays <= 1) {
        currentBlock.add(d);
      } else {
        if (currentBlock.any((b) => _isSameDay(b, n))) {
          return currentBlock.indexWhere((b) => _isSameDay(b, n)) + 1;
        }
        currentBlock = [d];
      }
    }

    if (currentBlock.any((b) => _isSameDay(b, n))) {
      return currentBlock.indexWhere((b) => _isSameDay(b, n)) + 1;
    }
    return 0;
  }

  void _onSave() {
    Navigator.pop(context, _selectedDates);
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
            _buildBanner(),
            _buildDayHeaders(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: _months.length,
                itemBuilder: (_, i) => _buildMonthSection(_months[i]),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child:
                const Icon(Icons.close, color: AppColors.textDark, size: 24),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: const Icon(Icons.help_outline,
                color: AppColors.textMuted, size: 22),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {},
            child: const Icon(Icons.calendar_today,
                color: AppColors.textMuted, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: AppColors.surfaceVariant,
      child: Row(
        children: [
          const Text('\u{1FA78}', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Text(
            'Tap on date to adjust your period',
            style: AppTextStyles.subtitle1.copyWith(color: AppColors.textBody),
          ),
        ],
      ),
    );
  }

  Widget _buildDayHeaders() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: AppColors.background,
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

  Widget _buildMonthSection(DateTime month) {
    final monthName = DateFormat('MMMM').format(month);
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    final startWeekday = first.weekday % 7;

    final List<DateTime?> days = [];
    for (int i = 0; i < startWeekday; i++) {
      days.add(null);
    }
    for (int d = 1; d <= last.day; d++) {
      days.add(DateTime(month.year, month.month, d));
    }

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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: rowDays.map((day) {
              if (day == null) {
                return const Expanded(child: SizedBox(height: 76));
              }
              return Expanded(child: _buildEditDayCell(day));
            }).toList(),
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Column(
            children: [
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 12),
              Text(monthName, style: AppTextStyles.h3),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(children: rows),
        ),
      ],
    );
  }

  Widget _buildEditDayCell(DateTime day) {
    final normalized = _normalize(day);
    final today = _normalize(DateTime.now());
    final isToday = _isSameDay(normalized, today);
    final isSelected = _selectedDates.contains(normalized);
    final periodDayNum = isSelected ? _computePeriodDayNum(normalized) : 0;

    return GestureDetector(
      onTap: () => _toggleDate(day),
      child: SizedBox(
        height: 76,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODAY label
            if (isToday)
              Text(
                'TODAY',
                style: GoogleFonts.dmSans(
                  color: AppColors.primary,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              )
            else
              const SizedBox(height: 12),

            // Date number
            Text(
              '${day.day}',
              style: GoogleFonts.poppins(
                color: isSelected ? AppColors.primary : AppColors.textDark,
                fontSize: 17,
                fontWeight:
                    (isToday || isSelected) ? FontWeight.w700 : FontWeight.w500,
              ),
            ),

            // Today underline
            if (isToday && !isSelected)
              Container(
                width: 20,
                height: 2,
                margin: const EdgeInsets.only(bottom: 2),
                color: AppColors.primary,
              )
            else if (!isToday)
              const SizedBox(height: 2),

            const SizedBox(height: 4),

            // Toggle circle
            if (isSelected)
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check,
                        color: AppColors.textOnPrimary, size: 15),
                  ),
                  if (periodDayNum > 0)
                    Positioned(
                      top: -5,
                      left: -5,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.background, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            '$periodDayNum',
                            style: GoogleFonts.dmSans(
                              color: AppColors.textOnPrimary,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              )
            else
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
          borderRadius: BorderRadius.circular(26),
        ),
        child: ElevatedButton(
          onPressed: _onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
          ),
          child: Text(
            'SAVE',
            style: GoogleFonts.poppins(
              color: AppColors.textOnPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
