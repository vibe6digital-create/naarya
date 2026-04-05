class WellnessScore {
  final DateTime date;
  final int overallScore;
  final int nutritionScore;
  final int fitnessScore;
  final int sleepScore;
  final int moodScore;
  final int cycleHealthScore;

  const WellnessScore({
    required this.date,
    required this.overallScore,
    required this.nutritionScore,
    required this.fitnessScore,
    required this.sleepScore,
    required this.moodScore,
    required this.cycleHealthScore,
  });
}
