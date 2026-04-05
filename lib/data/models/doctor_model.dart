enum ConsultMode { whatsapp, video, inPerson }

class DoctorModel {
  final String id;
  final String name;
  final String degree;
  final String specialty;
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
    required this.specialty,
    required this.about,
    this.photoUrl,
    required this.availableDays,
    required this.availableSlots,
    this.mode = ConsultMode.whatsapp,
    required this.whatsappNumber,
    this.cities = const ['Indore', 'Pune', 'Ujjain'],
  });
}
