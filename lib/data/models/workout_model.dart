import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/cycle_phase_calculator.dart';

enum WorkoutIntensity { low, moderate, high }

/// A single step in a workout with an optional illustration image.
class WorkoutStep {
  final String title;
  final String body;
  final String? imageUrl;

  const WorkoutStep({
    required this.title,
    required this.body,
    this.imageUrl,
  });

  factory WorkoutStep.fromMap(Map<String, dynamic> m) {
    // Support both {title, body} format and plain {text} format
    final text = m['text'] as String? ?? '';
    final title = m['title'] as String?;
    final body = m['body'] as String?;

    // If explicit title/body exist use them; otherwise use text as body only
    // (title left empty to avoid showing the same text twice in the story)
    final resolvedTitle =
        (title != null && title.isNotEmpty) ? title : '';
    final resolvedBody =
        (body != null && body.isNotEmpty) ? body : text;

    return WorkoutStep(
      title: resolvedTitle,
      body: resolvedBody,
      imageUrl: (m['imageUrl'] as String?)?.isEmpty == true
          ? null
          : m['imageUrl'] as String?,
    );
  }
}

/// Firestore structure:
///
///   workouts (collection)
///   └── {workoutId} (document)
///         ├── name            : string   — "Morning Brisk Walk"
///         ├── description     : string   — short description
///         ├── category        : string   — "Walking" | "Yoga" | "Meditation"
///         ├── durationMinutes : number   — 30
///         ├── intensity       : string   — "low" | "moderate" | "high"
///         ├── videoUrl        : string?  — YouTube URL
///         ├── coverImageUrl   : string?  — Firebase Storage download URL
///         ├── recommendedPhase: string   — "follicular"|"luteal"|"ovulation"|"menstrual"
///         ├── isActive        : bool     — set false to hide
///         ├── order           : number   — display sort order (1, 2, 3…)
///         └── steps           : array of maps
///               ├── title    : string   — short step title
///               ├── body     : string   — full step description
///               └── imageUrl : string?  — Firebase Storage URL for illustration
///
/// Admin Panel:
///   Add/edit workouts directly in the Firebase Console under the
///   "workouts" collection. Set isActive: true to make them visible.

class WorkoutModel {
  final String id;
  final String name;
  final String description;
  final CyclePhase recommendedPhase;
  final int durationMinutes;
  final String? videoUrl;
  final String? coverImageUrl;
  final List<WorkoutStep> steps;
  final WorkoutIntensity intensity;
  final String category;
  final int order;

  const WorkoutModel({
    required this.id,
    required this.name,
    required this.description,
    required this.recommendedPhase,
    required this.durationMinutes,
    this.videoUrl,
    this.coverImageUrl,
    required this.steps,
    required this.intensity,
    required this.category,
    this.order = 0,
  });

  factory WorkoutModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    // Normalise category: "yoga" → "Yoga"
    final rawCategory = (d['category'] as String? ?? 'Walking').trim();
    final category = rawCategory.isEmpty
        ? 'Walking'
        : rawCategory[0].toUpperCase() + rawCategory.substring(1).toLowerCase();

    // Support both plain-string steps and map-based steps
    final rawSteps = d['steps'] as List<dynamic>? ?? [];
    final steps = rawSteps.map((s) {
      if (s is Map<String, dynamic>) return WorkoutStep.fromMap(s);
      final text = s.toString();
      return WorkoutStep(title: _shortTitle(text), body: text);
    }).toList();

    return WorkoutModel(
      id: doc.id,
      name: d['name'] as String? ?? '',
      description: d['description'] as String? ?? '',
      category: category,
      durationMinutes: (d['durationMinutes'] as num?)?.toInt() ?? 30,
      intensity: WorkoutIntensity.values.firstWhere(
        (i) => i.name == (d['intensity'] as String? ?? ''),
        orElse: () => WorkoutIntensity.low,
      ),
      recommendedPhase: CyclePhase.values.firstWhere(
        (p) => p.name == (d['recommendedPhase'] as String? ?? ''),
        orElse: () => CyclePhase.follicular,
      ),
      videoUrl: (d['videoUrl'] as String?)?.isEmpty == true
          ? null
          : d['videoUrl'] as String?,
      coverImageUrl: (d['coverImageUrl'] as String?)?.isEmpty == true
          ? null
          : d['coverImageUrl'] as String?,
      order: (d['order'] as num?)?.toInt() ?? 0,
      steps: steps,
    );
  }

  /// Extracts a short title from a plain step string.
  static String _shortTitle(String step) {
    if (step.contains(' — ')) return step.split(' — ').first.trim();
    final comma = step.indexOf(',');
    if (comma > 5 && comma <= 35) return step.substring(0, comma).trim();
    final words = step.split(' ');
    final title = words.take(4).join(' ');
    return title.replaceAll(RegExp(r'[.,;]$'), '');
  }

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
