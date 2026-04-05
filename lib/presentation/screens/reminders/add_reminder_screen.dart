import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/reminder_model.dart';
import '../../widgets/common/naarya_button.dart';

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  ReminderType _selectedType = ReminderType.medication;
  RepeatFrequency _selectedRepeat = RepeatFrequency.none;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final reminder = ReminderModel(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      type: _selectedType,
      dateTime: dateTime,
      repeat: _selectedRepeat,
      isEnabled: true,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Reminder added!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    Navigator.pop(context, reminder);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Add Reminder', style: AppTextStyles.h2.copyWith(color: AppColors.textOnPrimary)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text('Title', style: AppTextStyles.subtitle1),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration('e.g. Take iron supplement'),
                style: AppTextStyles.body1,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.sectionGap),

              // Type
              Text('Type', style: AppTextStyles.subtitle1),
              const SizedBox(height: 8),
              DropdownButtonFormField<ReminderType>(
                value: _selectedType,
                decoration: _inputDecoration(null),
                style: AppTextStyles.body1,
                items: ReminderType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_typeLabel(type), style: AppTextStyles.body1),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),

              const SizedBox(height: AppSpacing.sectionGap),

              // Date
              Text('Date', style: AppTextStyles.subtitle1),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        AppDateUtils.formatDate(_selectedDate),
                        style: AppTextStyles.body1,
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.sectionGap),

              // Time
              Text('Time', style: AppTextStyles.subtitle1),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickTime,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 20, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        _selectedTime.format(context),
                        style: AppTextStyles.body1,
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.sectionGap),

              // Repeat
              Text('Repeat', style: AppTextStyles.subtitle1),
              const SizedBox(height: 8),
              DropdownButtonFormField<RepeatFrequency>(
                value: _selectedRepeat,
                decoration: _inputDecoration(null),
                style: AppTextStyles.body1,
                items: RepeatFrequency.values.map((freq) {
                  return DropdownMenuItem(
                    value: freq,
                    child: Text(_repeatLabel(freq), style: AppTextStyles.body1),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRepeat = val);
                },
              ),

              const SizedBox(height: 40),

              NaaryaButton(
                text: 'Save Reminder',
                icon: Icons.check,
                onPressed: _onSave,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  String _typeLabel(ReminderType type) {
    switch (type) {
      case ReminderType.medication:
        return 'Medication';
      case ReminderType.cycle:
        return 'Cycle';
      case ReminderType.appointment:
        return 'Appointment';
      case ReminderType.selfExam:
        return 'Self Exam';
    }
  }

  String _repeatLabel(RepeatFrequency freq) {
    switch (freq) {
      case RepeatFrequency.none:
        return 'Does not repeat';
      case RepeatFrequency.daily:
        return 'Daily';
      case RepeatFrequency.weekly:
        return 'Weekly';
      case RepeatFrequency.monthly:
        return 'Monthly';
    }
  }
}
