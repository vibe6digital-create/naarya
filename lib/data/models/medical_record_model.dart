enum RecordCategory { report, prescription, scan, other }

class MedicalRecord {
  final String id;
  final String title;
  final RecordCategory category;
  final String filePath;
  final DateTime dateAdded;
  final String? notes;
  final String? doctorName;

  const MedicalRecord({
    required this.id,
    required this.title,
    required this.category,
    required this.filePath,
    required this.dateAdded,
    this.notes,
    this.doctorName,
  });

  String get categoryLabel {
    switch (category) {
      case RecordCategory.report:
        return 'Lab Report';
      case RecordCategory.prescription:
        return 'Prescription';
      case RecordCategory.scan:
        return 'Scan Report';
      case RecordCategory.other:
        return 'Other';
    }
  }
}
