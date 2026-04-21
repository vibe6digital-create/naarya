import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../data/models/reminder_model.dart';
import '../../widgets/common/naarya_card.dart';
import 'package:uuid/uuid.dart';

// ── Simple in-line model for app-level notifications ──────────────────────

class _AppNotification {
  final String id;
  final String title;
  final String body;
  final String type; // "video" | "tip" | "announcement" | "health"
  final DateTime createdAt;

  const _AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
  });

  factory _AppNotification.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return _AppNotification(
      id: doc.id,
      title: d['title'] as String? ?? '',
      body: d['body'] as String? ?? '',
      type: d['type'] as String? ?? 'announcement',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

Stream<List<_AppNotification>> _notificationsStream() {
  return FirebaseFirestore.instance
      .collection('notifications')
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((snap) {
    final list = snap.docs.map(_AppNotification.fromFirestore).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  });
}

// ──────────────────────────────────────────────────────────────────────────

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  List<ReminderModel> _upcomingReminders() {
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
        title: 'Gynecologist Appointment',
        type: ReminderType.appointment,
        dateTime: DateTime(now.year, now.month + 1, 5, 14, 30),
        repeat: RepeatFrequency.none,
        isEnabled: true,
        notes: 'Annual check-up with Dr. Sharma',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App Updates from Firebase ───────────────────────────────
            Text('Updates',
                style: AppTextStyles.h2.copyWith(color: AppColors.textDark)),
            const SizedBox(height: AppSpacing.componentGap),
            StreamBuilder<List<_AppNotification>>(
              stream: _notificationsStream(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return _buildUpdatesSkeleton();
                }
                if (snap.hasError) {
                  return Text('Error loading notifications',
                      style: AppTextStyles.body2
                          .copyWith(color: AppColors.textMuted));
                }
                final items = snap.data ?? [];
                if (items.isEmpty) {
                  return NaaryaCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(Icons.notifications_none_rounded,
                            color: AppColors.textMuted, size: 28),
                        const SizedBox(width: 12),
                        Text('No new updates',
                            style: AppTextStyles.body2
                                .copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                  );
                }
                return Column(
                  children: items
                      .map((n) => Padding(
                            padding: const EdgeInsets.only(
                                bottom: AppSpacing.componentGap),
                            child: _NotificationTile(notification: n),
                          ))
                      .toList(),
                );
              },
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            // ── Upcoming Reminders ────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Reminders',
                    style:
                        AppTextStyles.h2.copyWith(color: AppColors.textDark)),
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.reminders),
                  child: Text('See All',
                      style: AppTextStyles.body2.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.componentGap),
            ..._upcomingReminders()
                .map((r) => Padding(
                      padding: const EdgeInsets.only(
                          bottom: AppSpacing.componentGap),
                      child: _ReminderTile(reminder: r),
                    )),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdatesSkeleton() {
    return Column(
      children: List.generate(
        2,
        (i) => Padding(
          padding:
              const EdgeInsets.only(bottom: AppSpacing.componentGap),
          child: NaaryaCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          height: 12,
                          width: 160,
                          decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(4))),
                      const SizedBox(height: 6),
                      Container(
                          height: 10,
                          width: 220,
                          decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(4))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Notification tile ─────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final _AppNotification notification;
  const _NotificationTile({required this.notification});

  IconData get _icon {
    switch (notification.type) {
      case 'video':
        return Icons.play_circle_rounded;
      case 'tip':
        return Icons.lightbulb_rounded;
      case 'health':
        return Icons.favorite_rounded;
      default:
        return Icons.campaign_rounded;
    }
  }

  Color get _color {
    switch (notification.type) {
      case 'video':
        return AppColors.primary;
      case 'tip':
        return const Color(0xFFF57C00);
      case 'health':
        return const Color(0xFFE53935);
      default:
        return AppColors.phaseFollicular;
    }
  }

  String _timeAgo() {
    final diff = DateTime.now().difference(notification.createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return NaaryaCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: _color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.title,
                    style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                const SizedBox(height: 3),
                Text(notification.body,
                    style: AppTextStyles.body2
                        .copyWith(color: AppColors.textBody)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(_timeAgo(),
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}

// ── Reminder tile ─────────────────────────────────────────────────────────

class _ReminderTile extends StatelessWidget {
  final ReminderModel reminder;
  const _ReminderTile({required this.reminder});

  Color get _color {
    switch (reminder.type) {
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

  IconData get _icon {
    switch (reminder.type) {
      case ReminderType.medication:
        return Icons.medication_rounded;
      case ReminderType.cycle:
        return Icons.water_drop_rounded;
      case ReminderType.appointment:
        return Icons.calendar_month_rounded;
      case ReminderType.selfExam:
        return Icons.health_and_safety_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final time =
        TimeOfDay.fromDateTime(reminder.dateTime).format(context);
    return NaaryaCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: _color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reminder.title,
                    style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(reminder.typeLabel,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time,
                  style: AppTextStyles.body2.copyWith(
                      color: _color, fontWeight: FontWeight.w600)),
              if (reminder.repeat != RepeatFrequency.none)
                Text(_repeatLabel(reminder.repeat),
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textMuted, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  String _repeatLabel(RepeatFrequency r) {
    switch (r) {
      case RepeatFrequency.daily:
        return 'Daily';
      case RepeatFrequency.weekly:
        return 'Weekly';
      case RepeatFrequency.monthly:
        return 'Monthly';
      case RepeatFrequency.none:
        return '';
    }
  }
}
