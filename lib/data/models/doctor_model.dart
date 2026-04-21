import 'package:cloud_firestore/cloud_firestore.dart';

enum ConsultMode { online, offline, both }

/// Firestore structure:
///
///   doctors (collection)
///   └── {doctorId} (document)
///         ├── name           : string   — "Dr. Niyati Jain Shah"
///         ├── degree         : string   — "MBBS, MS(OBGY)"
///         ├── specialties    : string[] — ["Gynecologist", "Obstetrician"]
///         ├── about          : string   — short bio
///         ├── photoUrl       : string?  — Firebase Storage download URL
///         ├── availableDays  : string[] — ["Mon", "Wed", "Fri"]
///         ├── availableSlots : string[] — ["10:00 AM", "2:00 PM"]
///         ├── mode           : "online" | "offline" | "both"
///         ├── whatsappNumber : string   — "919876543210" (with country code)
///         ├── cities         : string[] — ["Indore", "Pune"]
///         └── isActive       : bool     — set false to hide without deleting

class DoctorModel {
  final String id;
  final String name;
  final String degree;
  final List<String> specialties;
  final String about;
  final String? photoUrl;
  final List<String> availableDays;
  final List<String> availableSlots;
  final ConsultMode mode;
  final String whatsappNumber;
  final List<String> cities;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.degree,
    required this.specialties,
    required this.about,
    this.photoUrl,
    required this.availableDays,
    required this.availableSlots,
    this.mode = ConsultMode.online,
    required this.whatsappNumber,
    this.cities = const ['Indore', 'Pune', 'Ujjain'],
  });

  /// Convenience getter used across all existing UI — returns first specialty
  /// or joins all if multiple, so no UI changes are needed.
  String get specialty => specialties.isNotEmpty ? specialties.join(', ') : '';

  factory DoctorModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    // Support both old `specialty` (string) and new `specialties` (array)
    List<String> specialties;
    if (d['specialties'] != null) {
      specialties = List<String>.from(d['specialties']);
    } else if (d['specialty'] != null) {
      specialties = [d['specialty'] as String];
    } else {
      specialties = [];
    }

    return DoctorModel(
      id: doc.id,
      name: d['name'] ?? '',
      degree: d['degree'] ?? '',
      specialties: specialties,
      about: d['about'] ?? '',
      photoUrl: d['photoUrl'],
      availableDays: List<String>.from(d['availableDays'] ?? []),
      availableSlots: List<String>.from(d['availableSlots'] ?? []),
      mode: ConsultMode.values.firstWhere(
        (m) => m.name == d['mode'],
        orElse: () => ConsultMode.online,
      ),
      whatsappNumber: d['whatsappNumber'] ?? '',
      cities: List<String>.from(d['cities'] ?? ['Indore', 'Pune', 'Ujjain']),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'degree': degree,
        'specialties': specialties,
        'about': about,
        'photoUrl': photoUrl,
        'availableDays': availableDays,
        'availableSlots': availableSlots,
        'mode': mode.name,
        'whatsappNumber': whatsappNumber,
        'cities': cities,
        'isActive': true,
      };
}
