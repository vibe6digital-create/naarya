import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/reminder_model.dart';
import '../../widgets/common/naarya_card.dart';
import '../../widgets/common/empty_state_widget.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  ReminderType? _selectedFilter;

  late List<ReminderModel> _reminders;

  @override
  void initState() {
    super.initState();
    _reminders = _buildMockReminders();
  }

  List<ReminderModel> _buildMockReminders() {
    final now = DateTime.now();
    return [
      ReminderModel(
        id: const Uuid().v4(),
        title: 'Iron Supplement',
        type: ReminderType.medication,
        dateTime: DateTime(now.year, now.month, now.day, 8, 0),
        repeat: RepeatFrequency.daily,
        isEnabled: true,
        notes: 'Take with breakfast',
      ),
      ReminderModel(
        id: const Uuid().v4(),
        title: 'Period Tracker Check-in',
        type: ReminderType.cycle,
        dateTime: DateTime(now.year, now.month, now.day, 21, 0),
        repeat: RepeatFrequency.daily,
        isEnabled: true,
      ),
      ReminderModel(
        id: const Uuid().v4(),
        title: 'Breast Self-Exam',
        type: ReminderType.selfExam,
        dateTime: DateTime(now.year, now.month, 15, 10, 0),
        repeat: RepeatFrequency.monthly,
        isEnabled: true,
        notes: 'Perform on the 15th of each month',
      ),
      ReminderModel(
        id: const Uuid().v4(),
        title: 'Gynecologist Appointment',
        type: ReminderType.appointment,
        dateTime: DateTime(now.year, now.month + 1, 5, 14, 30),
        repeat: RepeatFrequency.none,
        isEnabled: true,
        notes: 'Annual check-up with Dr. Sharma',
      ),
      ReminderModel(
        id: const Uuid().v4(),
        title: 'Calcium & Vitamin D',
        type: ReminderType.medication,
        dateTime: DateTime(now.year, now.month, now.day, 13, 0),
        repeat: RepeatFrequency.daily,
        isEnabled: false,
      ),
    ];
  }

  List<ReminderModel> get _filteredReminders {
    if (_selectedFilter == null) return _reminders;
    return _reminders.where((r) => r.type == _selectedFilter).toList();
  }

  Color _getTypeColor(ReminderType type) {
    switch (type) {
      case ReminderType.medication:
        return AppColors.info;
      case ReminderType.cycle:
        return AppColors.phaseMenstrual;
      case ReminderType.appointment:
        return AppColors.phaseFollicular;
      case ReminderType.selfExam:
        return AppColors.phaseOvulation;
    }
  }

  IconData _getTypeIcon(ReminderType type) {
    switch (type) {
      case ReminderType.medication:
        return Icons.medication;
      case ReminderType.cycle:
        return Icons.calendar_month;
      case ReminderType.appointment:
        return Icons.local_hospital;
      case ReminderType.selfExam:
        return Icons.self_improvement;
    }
  }

  String _getRepeatLabel(RepeatFrequency freq) {
    switch (freq) {
      case RepeatFrequency.none:
        return 'Once';
      case RepeatFrequency.daily:
        return 'Daily';
      case RepeatFrequency.weekly:
        return 'Weekly';
      case RepeatFrequency.monthly:
        return 'Monthly';
    }
  }

  void _deleteReminder(int index, ReminderModel reminder) {
    setState(() {
      _reminders.remove(reminder);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${reminder.title} removed'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.phaseOvulation,
          onPressed: () {
            setState(() {
              _reminders.insert(index, reminder);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Reminders', style: AppTextStyles.h2.copyWith(color: AppColors.textOnPrimary)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _filteredReminders.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.notifications_off_outlined,
                    title: 'No reminders found',
                    subtitle: _selectedFilter != null
                        ? 'No ${_selectedFilter!.name} reminders yet.'
                        : 'Tap + to add your first reminder.',
                  )
                : ListView.builder(
                    padding: AppSpacing.pagePadding,
                    itemCount: _filteredReminders.length,
                    itemBuilder: (context, index) {
                      final reminder = _filteredReminders[index];
                      final globalIndex = _reminders.indexOf(reminder);
                      return _buildReminderCard(reminder, globalIndex);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.reminderAdd);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = <(ReminderType?, String)>[
      (null, 'All'),
      (ReminderType.medication, 'Medication'),
      (ReminderType.cycle, 'Cycle'),
      (ReminderType.appointment, 'Appointment'),
      (ReminderType.selfExam, 'Self Exam'),
    ];

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.pageHorizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter.$2),
                selected: isSelected,
                onSelected: (_) {
                  setState(() => _selectedFilter = filter.$1);
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
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildReminderCard(ReminderModel reminder, int globalIndex) {
    final typeColor = _getTypeColor(reminder.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.componentGap),
      child: Dismissible(
        key: ValueKey(reminder.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
        ),
        onDismissed: (_) => _deleteReminder(globalIndex, reminder),
        child: NaaryaCard(
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getTypeIcon(reminder.type), color: typeColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            reminder.title,
                            style: AppTextStyles.subtitle1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                          ),
                          child: Text(
                            reminder.typeLabel,
                            style: AppTextStyles.caption.copyWith(
                              color: typeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          AppDateUtils.formatTime(reminder.dateTime),
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.repeat, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          _getRepeatLabel(reminder.repeat),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: reminder.isEnabled,
                onChanged: (val) async {
                  final idx = _reminders.indexOf(reminder);
                  if (idx < 0) return;
                  setState(() => _reminders[idx] = reminder.copyWith(isEnabled: val));
                  final notifId = reminder.dateTime.millisecondsSinceEpoch ~/ 1000;
                  if (!val) {
                    await NotificationService.cancel(notifId);
                  } else if (reminder.dateTime.isAfter(DateTime.now())) {
                    await NotificationService.schedule(
                      id: notifId,
                      title: reminder.title,
                      body: 'Time for your ${reminder.typeLabel.toLowerCase()} reminder.',
                      scheduledTime: reminder.dateTime,
                      repeat: reminder.repeat,
                    );
                  }
                },
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
