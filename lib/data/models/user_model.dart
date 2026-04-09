import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String photoUrl;
  final String city;
  final int age;
  final String healthGoal;
  final bool onboardingDone;
  final String authProvider;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    this.uid = '',
    required this.name,
    required this.phone,
    this.email = '',
    this.photoUrl = '',
    required this.city,
    this.age = 0,
    this.healthGoal = '',
    this.onboardingDone = false,
    this.authProvider = '',
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? '',
      city: map['city'] as String? ?? '',
      age: map['age'] as int? ?? 0,
      healthGoal: map['healthGoal'] as String? ?? '',
      onboardingDone: map['onboardingDone'] as bool? ?? false,
      authProvider: map['authProvider'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'photoUrl': photoUrl,
      'city': city,
      'age': age,
      'healthGoal': healthGoal,
      'onboardingDone': onboardingDone,
      'authProvider': authProvider,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? phone,
    String? email,
    String? photoUrl,
    String? city,
    int? age,
    String? healthGoal,
    bool? onboardingDone,
    String? authProvider,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      city: city ?? this.city,
      age: age ?? this.age,
      healthGoal: healthGoal ?? this.healthGoal,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      authProvider: authProvider ?? this.authProvider,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
