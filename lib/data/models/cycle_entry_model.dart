enum FlowIntensity { none, light, medium, heavy }

enum Mood { happy, calm, sad, anxious, irritable, energetic }

class CycleEntry {
  final String id;
  final DateTime date;
  final FlowIntensity flow;
  final List<String> symptoms;
  final Mood? mood;
  final String? notes;

  const CycleEntry({
    required this.id,
    required this.date,
    this.flow = FlowIntensity.none,
    this.symptoms = const [],
    this.mood,
    this.notes,
  });

  CycleEntry copyWith({
    FlowIntensity? flow,
    List<String>? symptoms,
    Mood? mood,
    String? notes,
  }) {
    return CycleEntry(
      id: id,
      date: date,
      flow: flow ?? this.flow,
      symptoms: symptoms ?? this.symptoms,
      mood: mood ?? this.mood,
      notes: notes ?? this.notes,
    );
  }

  static const List<String> commonSymptoms = [
    'Cramps',
    'Headache',
    'Bloating',
    'Fatigue',
    'Back pain',
    'Breast tenderness',
    'Acne',
    'Nausea',
    'Insomnia',
    'Mood swings',
    'Food cravings',
    'Dizziness',
  ];
}
