import '../../core/utils/cycle_phase_calculator.dart';

class NutritionPlan {
  final CyclePhase phase;
  final String phaseDescription;
  final List<MealSuggestion> meals;
  final List<String> tips;
  final List<String> focusNutrients;

  const NutritionPlan({
    required this.phase,
    required this.phaseDescription,
    required this.meals,
    required this.tips,
    required this.focusNutrients,
  });
}

class MealSuggestion {
  final String name;
  final String type; // breakfast, lunch, dinner, snack
  final List<String> ingredients;
  final String? recipe;
  final String? imageUrl;

  const MealSuggestion({
    required this.name,
    required this.type,
    required this.ingredients,
    this.recipe,
    this.imageUrl,
  });
}
