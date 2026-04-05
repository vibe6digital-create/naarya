enum CyclePhase { menstrual, follicular, ovulation, luteal }

class CyclePhaseInfo {
  final CyclePhase phase;
  final int dayInCycle;
  final int daysUntilNextPeriod;
  final DateTime? nextPeriodDate;
  final DateTime? ovulationDate;

  const CyclePhaseInfo({
    required this.phase,
    required this.dayInCycle,
    required this.daysUntilNextPeriod,
    this.nextPeriodDate,
    this.ovulationDate,
  });

  String get phaseName {
    switch (phase) {
      case CyclePhase.menstrual:
        return 'Menstrual';
      case CyclePhase.follicular:
        return 'Follicular';
      case CyclePhase.ovulation:
        return 'Ovulation';
      case CyclePhase.luteal:
        return 'Luteal';
    }
  }

  String get phaseDescription {
    switch (phase) {
      case CyclePhase.menstrual:
        return 'Your period is here. Rest, hydrate, and nourish your body with iron-rich foods.';
      case CyclePhase.follicular:
        return 'Energy is rising! Great time for new projects, socializing, and trying new workouts.';
      case CyclePhase.ovulation:
        return 'Peak energy and fertility window. You may feel more confident and social.';
      case CyclePhase.luteal:
        return 'Wind down phase. Focus on self-care, gentle exercise, and comfort foods.';
    }
  }
}

class CyclePhaseCalculator {
  CyclePhaseCalculator._();

  static CyclePhaseInfo calculate({
    required DateTime lastPeriodStart,
    int cycleLength = 28,
    int periodLength = 5,
  }) {
    final today = DateTime.now();
    final daysSinceStart = today.difference(lastPeriodStart).inDays;
    final dayInCycle = (daysSinceStart % cycleLength) + 1;
    final ovulationDay = cycleLength - 14;
    final daysUntilNext = cycleLength - dayInCycle;

    final nextPeriodDate = today.add(Duration(days: daysUntilNext));
    final daysUntilOvulation = ovulationDay - dayInCycle;
    final ovulationDate = daysUntilOvulation > 0
        ? today.add(Duration(days: daysUntilOvulation))
        : null;

    CyclePhase phase;
    if (dayInCycle <= periodLength) {
      phase = CyclePhase.menstrual;
    } else if (dayInCycle <= ovulationDay - 2) {
      phase = CyclePhase.follicular;
    } else if (dayInCycle <= ovulationDay + 2) {
      phase = CyclePhase.ovulation;
    } else {
      phase = CyclePhase.luteal;
    }

    return CyclePhaseInfo(
      phase: phase,
      dayInCycle: dayInCycle,
      daysUntilNextPeriod: daysUntilNext,
      nextPeriodDate: nextPeriodDate,
      ovulationDate: ovulationDate,
    );
  }

  static List<DateTime> getPeriodDays({
    required DateTime lastPeriodStart,
    int periodLength = 5,
  }) {
    return List.generate(
      periodLength,
      (i) => lastPeriodStart.add(Duration(days: i)),
    );
  }

  static List<DateTime> getFertileWindow({
    required DateTime lastPeriodStart,
    int cycleLength = 28,
  }) {
    final ovulationDay = cycleLength - 14;
    final ovulationDate = lastPeriodStart.add(Duration(days: ovulationDay - 1));
    return List.generate(
      5,
      (i) => ovulationDate.subtract(Duration(days: 2)).add(Duration(days: i)),
    );
  }
}
