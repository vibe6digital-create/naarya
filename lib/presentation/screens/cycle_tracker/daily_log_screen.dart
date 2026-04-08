import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/local_storage_service.dart';

class DailyLogScreen extends StatefulWidget {
  final DateTime date;
  const DailyLogScreen({super.key, required this.date});

  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  Map<String, List<String>> _selections = {};
  final _diaryController = TextEditingController();
  late String _dateKey;

  static const _sections = <_LogSection>[
    _LogSection(
      title: 'Symptoms',
      key: 'symptoms',
      options: [
        _LogOption('\u{1F4AA}', 'Lower back pain'),
        _LogOption('\u{1F915}', 'Headache'),
        _LogOption('\u{1FA78}', 'Spotting'),
        _LogOption('\u{1F534}', 'Acne'),
        _LogOption('\u{1F625}', 'Pelvic pain'),
        _LogOption('\u{1F634}', 'Fatigue'),
        _LogOption('\u{1F62C}', 'Cramps'),
        _LogOption('\u{1F917}', 'Breast sensitivity'),
        _LogOption('\u{1F922}', 'Nausea'),
        _LogOption('\u{1F4A8}', 'Bloating'),
      ],
    ),
    _LogSection(
      title: 'Moods',
      key: 'moods',
      options: [
        _LogOption('\u{1F60A}', 'Happy'),
        _LogOption('\u{1F620}', 'Angry'),
        _LogOption('\u{1F970}', 'In love'),
        _LogOption('\u{1F62B}', 'Exhausted'),
        _LogOption('\u{1F622}', 'Sad'),
        _LogOption('\u{1F629}', 'Depressed'),
        _LogOption('\u{1F622}', 'Emotional'),
        _LogOption('\u{1F630}', 'Anxious'),
        _LogOption('\u{1F610}', 'Calm'),
        _LogOption('\u{1F914}', 'Confused'),
      ],
    ),
    _LogSection(
      title: 'Energy',
      key: 'energy',
      options: [
        _LogOption('\u{1F7E5}', 'Low'),
        _LogOption('\u{1F7E7}', 'Medium'),
        _LogOption('\u{1F7E9}', 'High'),
        _LogOption('\u{26A1}', 'Energized'),
      ],
    ),
    _LogSection(
      title: 'Breast self-exam',
      key: 'breastExam',
      options: [
        _LogOption('\u{2705}', 'Everything is fine'),
        _LogOption('\u{1F7E0}', 'Engorgement'),
        _LogOption('\u{1F534}', 'Lump'),
        _LogOption('\u{26A0}\u{FE0F}', 'Dimple'),
        _LogOption('\u{1F7E5}', 'Skin redness'),
        _LogOption('\u{1FA79}', 'Cracked nipples'),
        _LogOption('\u{1F494}', 'Pain'),
        _LogOption('\u{1F4A7}', 'Nipple discharge'),
      ],
    ),
    _LogSection(
      title: 'Sex life',
      key: 'sexLife',
      options: [
        _LogOption('\u{1F6AB}', 'Didn\'t have'),
        _LogOption('\u{1F494}', 'Unprotected sex'),
        _LogOption('\u{1F6E1}\u{FE0F}', 'Protected sex'),
        _LogOption('\u{270B}', 'Masturbation'),
        _LogOption('\u{1F615}', 'No orgasm'),
        _LogOption('\u{1F60D}', 'Orgasm'),
        _LogOption('\u{1F497}', 'Sex drive'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _dateKey = DateFormat('yyyy-MM-dd').format(widget.date);
    _loadData();
  }

  @override
  void dispose() {
    _diaryController.dispose();
    super.dispose();
  }

  void _loadData() {
    final json = LocalStorageService.dailyLogJson;
    if (json != null && json.isNotEmpty) {
      final allLogs = Map<String, dynamic>.from(jsonDecode(json));
      if (allLogs.containsKey(_dateKey)) {
        final dayLog = Map<String, dynamic>.from(allLogs[_dateKey]);
        for (final entry in dayLog.entries) {
          if (entry.key == 'diary') {
            _diaryController.text = entry.value as String;
          } else {
            _selections[entry.key] = List<String>.from(entry.value);
          }
        }
      }
    }
  }

  void _saveData() {
    final json = LocalStorageService.dailyLogJson;
    Map<String, dynamic> allLogs = {};
    if (json != null && json.isNotEmpty) {
      allLogs = Map<String, dynamic>.from(jsonDecode(json));
    }

    final dayLog = <String, dynamic>{};
    for (final entry in _selections.entries) {
      if (entry.value.isNotEmpty) {
        dayLog[entry.key] = entry.value;
      }
    }
    if (_diaryController.text.trim().isNotEmpty) {
      dayLog['diary'] = _diaryController.text.trim();
    }

    if (dayLog.isNotEmpty) {
      allLogs[_dateKey] = dayLog;
    } else {
      allLogs.remove(_dateKey);
    }

    LocalStorageService.setDailyLogJson(jsonEncode(allLogs));
  }

  void _toggleOption(String sectionKey, String option) {
    setState(() {
      _selections[sectionKey] ??= [];
      final list = _selections[sectionKey]!;
      if (list.contains(option)) {
        list.remove(option);
      } else {
        list.add(option);
      }
    });
  }

  bool _isSelected(String sectionKey, String option) {
    return _selections[sectionKey]?.contains(option) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, MMM d').format(widget.date);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(dateStr),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  for (final section in _sections) ...[
                    _buildSection(section),
                    const SizedBox(height: 12),
                  ],
                  _buildDiarySection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String dateStr) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, color: AppColors.textDark, size: 24),
          ),
          const Spacer(),
          Text(dateStr, style: AppTextStyles.h3),
          const Spacer(),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildSection(_LogSection section) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: AppTextStyles.subtitle1.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: section.options.map((opt) {
              final selected = _isSelected(section.key, opt.label);
              return GestureDetector(
                onTap: () => _toggleOption(section.key, opt.label),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.border,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(opt.emoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text(
                        opt.label,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                          color: selected ? AppColors.primary : AppColors.textBody,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDiarySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Write diary',
                style: AppTextStyles.subtitle1.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              const Text('\u{270D}\u{FE0F}', style: TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _diaryController,
            maxLines: 4,
            style: AppTextStyles.body1,
            decoration: InputDecoration(
              hintText: 'Write something...',
              hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textLight),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            _saveData();
            Navigator.pop(context, true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            elevation: 0,
          ),
          child: Text('Save Log', style: AppTextStyles.button),
        ),
      ),
    );
  }
}

class _LogSection {
  final String title;
  final String key;
  final List<_LogOption> options;
  const _LogSection({required this.title, required this.key, required this.options});
}

class _LogOption {
  final String emoji;
  final String label;
  const _LogOption(this.emoji, this.label);
}
