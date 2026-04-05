enum ReminderType { medication, cycle, appointment, selfExam }

enum RepeatFrequency { none, daily, weekly, monthly }

class ReminderModel {
  final String id;
  final String title;
  final ReminderType type;
  final DateTime dateTime;
  final RepeatFrequency repeat;
  final bool isEnabled;
  final String? notes;

  const ReminderModel({
    required this.id,
    required this.title,
    required this.type,
    required this.dateTime,
    this.repeat = RepeatFrequency.none,
    this.isEnabled = true,
    this.notes,
  });

  ReminderModel copyWith({
    String? title,
    ReminderType? type,
    DateTime? dateTime,
    RepeatFrequency? repeat,
    bool? isEnabled,
    String? notes,
  }) {
    return ReminderModel(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      repeat: repeat ?? this.repeat,
      isEnabled: isEnabled ?? this.isEnabled,
      notes: notes ?? this.notes,
    );
  }

  String get typeLabel {
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
}
