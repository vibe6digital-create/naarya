class UserModel {
  final String name;
  final String phone;
  final String city;
  final int age;
  final String healthGoal;
  final bool onboardingDone;

  const UserModel({
    required this.name,
    required this.phone,
    required this.city,
    this.age = 0,
    this.healthGoal = '',
    this.onboardingDone = false,
  });

  UserModel copyWith({
    String? name,
    String? phone,
    String? city,
    int? age,
    String? healthGoal,
    bool? onboardingDone,
  }) {
    return UserModel(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      age: age ?? this.age,
      healthGoal: healthGoal ?? this.healthGoal,
      onboardingDone: onboardingDone ?? this.onboardingDone,
    );
  }
}
