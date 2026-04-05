import '../../core/utils/cycle_phase_calculator.dart';

enum WorkoutIntensity { low, moderate, high }

class WorkoutModel {
  final String id;
  final String name;
  final String description;
  final CyclePhase recommendedPhase;
  final int durationMinutes;
  final String? videoUrl;
  final String? thumbnailUrl;
  final List<String> steps;
  final WorkoutIntensity intensity;
  final String category; // yoga, walking, strength, meditation

  const WorkoutModel({
    required this.id,
    required this.name,
    required this.description,
    required this.recommendedPhase,
    required this.durationMinutes,
    this.videoUrl,
    this.thumbnailUrl,
    required this.steps,
    required this.intensity,
    required this.category,
  });

  String get intensityLabel {
    switch (intensity) {
      case WorkoutIntensity.low:
        return 'Easy';
      case WorkoutIntensity.moderate:
        return 'Moderate';
      case WorkoutIntensity.high:
        return 'Intense';
    }
  }
}
