import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

enum RecordType { report, prescription, scan, vaccination, consultation, other }

enum FileType { pdf, image }

enum Severity { mild, moderate, severe }

// ─── Health Problem Details (optional nested object) ─────────────────────────

class HealthProblemDetails {
  final String? symptoms;
  final String? diagnosis;
  final String? treatmentPlan;
  final String? medications;
  final Severity severity;
  final DateTime? followUpDate;

  const HealthProblemDetails({
    this.symptoms,
    this.diagnosis,
    this.treatmentPlan,
    this.medications,
    this.severity = Severity.mild,
    this.followUpDate,
  });

  bool get isEmpty =>
      symptoms == null &&
      diagnosis == null &&
      treatmentPlan == null &&
      medications == null;

  Map<String, dynamic> toMap() => {
        'symptoms': symptoms,
        'diagnosis': diagnosis,
        'treatmentPlan': treatmentPlan,
        'medications': medications,
        'severity': severity.name,
        'followUpDate': followUpDate != null
            ? Timestamp.fromDate(followUpDate!)
            : null,
      };

  factory HealthProblemDetails.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const HealthProblemDetails();
    return HealthProblemDetails(
      symptoms: data['symptoms'],
      diagnosis: data['diagnosis'],
      treatmentPlan: data['treatmentPlan'],
      medications: data['medications'],
      severity: Severity.values.firstWhere(
        (s) => s.name == data['severity'],
        orElse: () => Severity.mild,
      ),
      followUpDate: data['followUpDate'] != null
          ? (data['followUpDate'] as Timestamp).toDate()
          : null,
    );
  }
}

// ─── Medical Record ───────────────────────────────────────────────────────────
//
// Firestore document shape (users/{uid}/health_vault/{recordId}):
//
//   id          : string
//   title       : string
//   type        : "report" | "prescription" | "scan" | "vaccination" | ...
//   doctor      : string
//   hospital    : string
//   date        : string  (dd MMM yyyy)
//   fileUrl     : string  ← Firebase Storage download URL
//   fileType    : "pdf" | "image"
//   storagePath : string  ← Firebase Storage path (for deletion)
//   tags        : string[]
//   notes       : string
//   createdAt   : timestamp
//   updatedAt   : timestamp
//
// ─────────────────────────────────────────────────────────────────────────────

class MedicalRecord {
  final String id;
  final String title;
  final RecordType type;
  final String? doctor;
  final String? hospital;
  final String date;            // formatted display string
  final String? fileUrl;        // download URL from Firebase Storage
  final FileType? fileType;     // "pdf" | "image"
  final String? storagePath;    // raw Storage path — used for deletion
  final List<String> tags;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Extra fields (not in base spec but used in-app)
  final String? userId;
  final HealthProblemDetails? healthDetails;

  const MedicalRecord({
    required this.id,
    required this.title,
    required this.type,
    this.doctor,
    this.hospital,
    required this.date,
    this.fileUrl,
    this.fileType,
    this.storagePath,
    this.tags = const [],
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
    this.healthDetails,
  });

  // ─── Computed ──────────────────────────────────────────────────────────────

  String get typeLabel {
    switch (type) {
      case RecordType.prescription:  return 'Prescription';
      case RecordType.report:        return 'Lab Report';
      case RecordType.scan:          return 'Scan';
      case RecordType.vaccination:   return 'Vaccination';
      case RecordType.consultation:  return 'Consultation';
      case RecordType.other:         return 'Other';
    }
  }

  bool get hasFile => fileUrl != null;
  bool get isImage => fileType == FileType.image;
  bool get isPdf   => fileType == FileType.pdf;

  // ─── Firestore ─────────────────────────────────────────────────────────────

  factory MedicalRecord.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return MedicalRecord(
      id:          doc.id,
      title:       d['title'] ?? '',
      type:        RecordType.values.firstWhere(
                     (t) => t.name == d['type'],
                     orElse: () => RecordType.other),
      doctor:      d['doctor'],
      hospital:    d['hospital'],
      date:        d['date'] ?? '',
      fileUrl:     d['fileUrl'],
      fileType:    d['fileType'] != null
                     ? FileType.values.firstWhere(
                         (f) => f.name == d['fileType'],
                         orElse: () => FileType.image)
                     : null,
      storagePath: d['storagePath'],
      tags:        List<String>.from(d['tags'] ?? []),
      notes:       d['notes'],
      createdAt:   d['createdAt'] != null
                     ? (d['createdAt'] as Timestamp).toDate()
                     : DateTime.now(),
      updatedAt:   d['updatedAt'] != null
                     ? (d['updatedAt'] as Timestamp).toDate()
                     : DateTime.now(),
      userId:      d['userId'],
      healthDetails: HealthProblemDetails.fromMap(
                     d['healthDetails'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'id':          id,
        'title':       title,
        'type':        type.name,
        'doctor':      doctor,
        'hospital':    hospital,
        'date':        date,
        'fileUrl':     fileUrl,
        'fileType':    fileType?.name,
        'storagePath': storagePath,
        'tags':        tags,
        'notes':       notes,
        'createdAt':   Timestamp.fromDate(createdAt),
        'updatedAt':   Timestamp.fromDate(updatedAt),
        'userId':      userId,
        'healthDetails': healthDetails?.isEmpty == false
                           ? healthDetails?.toMap()
                           : null,
      };
}
