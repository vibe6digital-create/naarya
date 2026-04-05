import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/cycle_entry_model.dart';
import '../../widgets/common/naarya_button.dart';
import '../../widgets/common/section_header.dart';

class CycleLogScreen extends StatefulWidget {
  const CycleLogScreen({super.key});

  @override
  State<CycleLogScreen> createState() => _CycleLogScreenState();
}

class _CycleLogScreenState extends State<CycleLogScreen> {
  FlowIntensity _selectedFlow = FlowIntensity.none;
  Mood? _selectedMood;
  final Set<String> _selectedSymptoms = {};
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _onSave() {
    final entry = CycleEntry(
      id: const Uuid().v4(),
      date: DateTime.now(),
      flow: _selectedFlow,
      symptoms: _selectedSymptoms.toList(),
      mood: _selectedMood,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Entry saved successfully!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    Navigator.pop(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Log Today  \u2022  ${AppDateUtils.formatDate(today)}',
          style: AppTextStyles.h3.copyWith(color: AppColors.textOnPrimary),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFlowSection(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildMoodSection(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildSymptomsSection(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildNotesSection(),
            const SizedBox(height: 32),
            NaaryaButton(
              text: 'Save Entry',
              icon: Icons.check,
              onPressed: _onSave,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Flow Intensity'),
        const SizedBox(height: AppSpacing.componentGap),
        Row(
          children: FlowIntensity.values.map((flow) {
            final isSelected = _selectedFlow == flow;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedFlow = flow),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.phaseMenstrual : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.phaseMenstrual
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected ? AppColors.cardShadow : null,
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(
                          _getFlowIcon(flow),
                          color: isSelected ? Colors.white : AppColors.textMuted,
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getFlowLabel(flow),
                          style: AppTextStyles.caption.copyWith(
                            color: isSelected ? Colors.white : AppColors.textBody,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getFlowIcon(FlowIntensity flow) {
    switch (flow) {
      case FlowIntensity.none:
        return Icons.not_interested;
      case FlowIntensity.light:
        return Icons.water_drop_outlined;
      case FlowIntensity.medium:
        return Icons.water_drop;
      case FlowIntensity.heavy:
        return Icons.opacity;
    }
  }

  String _getFlowLabel(FlowIntensity flow) {
    switch (flow) {
      case FlowIntensity.none:
        return 'None';
      case FlowIntensity.light:
        return 'Light';
      case FlowIntensity.medium:
        return 'Medium';
      case FlowIntensity.heavy:
        return 'Heavy';
    }
  }

  Widget _buildMoodSection() {
    final moods = [
      (Mood.happy, 'Happy', '\u{1F60A}'),
      (Mood.calm, 'Calm', '\u{1F60C}'),
      (Mood.sad, 'Sad', '\u{1F622}'),
      (Mood.anxious, 'Anxious', '\u{1F630}'),
      (Mood.irritable, 'Irritable', '\u{1F624}'),
      (Mood.energetic, 'Energetic', '\u26A1'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Mood'),
        const SizedBox(height: AppSpacing.componentGap),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: moods.map((moodData) {
            final isSelected = _selectedMood == moodData.$1;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMood = isSelected ? null : moodData.$1;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: (MediaQuery.of(context).size.width - 32 - 20) / 3,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      moodData.$3,
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      moodData.$2,
                      style: AppTextStyles.caption.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textBody,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSymptomsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Symptoms'),
        const SizedBox(height: AppSpacing.componentGap),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: CycleEntry.commonSymptoms.map((symptom) {
            final isSelected = _selectedSymptoms.contains(symptom);
            return FilterChip(
              label: Text(symptom),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSymptoms.add(symptom);
                  } else {
                    _selectedSymptoms.remove(symptom);
                  }
                });
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
              checkmarkColor: AppColors.primary,
              labelStyle: AppTextStyles.body2.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textBody,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
              ),
              backgroundColor: AppColors.surface,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Notes'),
        const SizedBox(height: AppSpacing.componentGap),
        TextField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'How are you feeling today? Any additional notes...',
            hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: AppTextStyles.body1,
        ),
      ],
    );
  }
}
