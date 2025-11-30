import 'dart:convert';

class MedicalRecord {
  final String id;
  final String patientEmail;
  final String patientName;
  final String type; // diagnosis, prescription, lab_result, vitals, allergy, note
  final String title;
  final String description;
  final String doctorName;
  final String doctorSpecialty;
  final String date;
  final String appointmentId;
  final Map<String, dynamic> data; // Additional data based on type
  final DateTime createdAt;

  MedicalRecord({
    required this.id,
    required this.patientEmail,
    required this.patientName,
    required this.type,
    required this.title,
    required this.description,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.date,
    this.appointmentId = '',
    this.data = const {},
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Type constants
  static const String typeDiagnosis = 'diagnosis';
  static const String typePrescription = 'prescription';
  static const String typeLabResult = 'lab_result';
  static const String typeVitals = 'vitals';
  static const String typeAllergy = 'allergy';
  static const String typeNote = 'note';
  static const String typeVaccination = 'vaccination';

  // Get icon for type
  static String getIcon(String type) {
    switch (type) {
      case typeDiagnosis: return '🩺';
      case typePrescription: return '💊';
      case typeLabResult: return '🔬';
      case typeVitals: return '❤️';
      case typeAllergy: return '⚠️';
      case typeNote: return '📝';
      case typeVaccination: return '💉';
      default: return '📋';
    }
  }

  // Get color for type
  static int getColor(String type) {
    switch (type) {
      case typeDiagnosis: return 0xFF0091EA;
      case typePrescription: return 0xFF4CAF50;
      case typeLabResult: return 0xFF9C27B0;
      case typeVitals: return 0xFFE91E63;
      case typeAllergy: return 0xFFFF9800;
      case typeNote: return 0xFF607D8B;
      case typeVaccination: return 0xFF00BCD4;
      default: return 0xFF666666;
    }
  }

  // Get readable type name
  static String getTypeName(String type) {
    switch (type) {
      case typeDiagnosis: return 'Diagnosis';
      case typePrescription: return 'Prescription';
      case typeLabResult: return 'Lab Result';
      case typeVitals: return 'Vital Signs';
      case typeAllergy: return 'Allergy';
      case typeNote: return 'Doctor Note';
      case typeVaccination: return 'Vaccination';
      default: return 'Record';
    }
  }

  String encode() {
    return jsonEncode({
      'id': id,
      'patientEmail': patientEmail,
      'patientName': patientName,
      'type': type,
      'title': title,
      'description': description,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'date': date,
      'appointmentId': appointmentId,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
    });
  }

  static MedicalRecord decode(String encoded) {
    final map = jsonDecode(encoded);
    return MedicalRecord(
      id: map['id'] ?? '',
      patientEmail: map['patientEmail'] ?? '',
      patientName: map['patientName'] ?? '',
      type: map['type'] ?? 'note',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      doctorName: map['doctorName'] ?? '',
      doctorSpecialty: map['doctorSpecialty'] ?? '',
      date: map['date'] ?? '',
      appointmentId: map['appointmentId'] ?? '',
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
    );
  }

  MedicalRecord copyWith({
    String? id,
    String? patientEmail,
    String? patientName,
    String? type,
    String? title,
    String? description,
    String? doctorName,
    String? doctorSpecialty,
    String? date,
    String? appointmentId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
  }) {
    return MedicalRecord(
      id: id ?? this.id,
      patientEmail: patientEmail ?? this.patientEmail,
      patientName: patientName ?? this.patientName,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      date: date ?? this.date,
      appointmentId: appointmentId ?? this.appointmentId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Vital Signs data structure
class VitalSigns {
  final double? bloodPressureSystolic;
  final double? bloodPressureDiastolic;
  final double? heartRate;
  final double? temperature;
  final double? weight;
  final double? height;
  final double? oxygenSaturation;

  VitalSigns({
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.heartRate,
    this.temperature,
    this.weight,
    this.height,
    this.oxygenSaturation,
  });

  Map<String, dynamic> toMap() => {
    'bloodPressureSystolic': bloodPressureSystolic,
    'bloodPressureDiastolic': bloodPressureDiastolic,
    'heartRate': heartRate,
    'temperature': temperature,
    'weight': weight,
    'height': height,
    'oxygenSaturation': oxygenSaturation,
  };

  static VitalSigns fromMap(Map<String, dynamic> map) => VitalSigns(
    bloodPressureSystolic: map['bloodPressureSystolic']?.toDouble(),
    bloodPressureDiastolic: map['bloodPressureDiastolic']?.toDouble(),
    heartRate: map['heartRate']?.toDouble(),
    temperature: map['temperature']?.toDouble(),
    weight: map['weight']?.toDouble(),
    height: map['height']?.toDouble(),
    oxygenSaturation: map['oxygenSaturation']?.toDouble(),
  );

  String get bloodPressure => 
    bloodPressureSystolic != null && bloodPressureDiastolic != null
      ? '${bloodPressureSystolic!.toInt()}/${bloodPressureDiastolic!.toInt()} mmHg'
      : 'N/A';
}

// Prescription item
class PrescriptionItem {
  final String medication;
  final String dosage;
  final String frequency;
  final String duration;
  final String instructions;

  PrescriptionItem({
    required this.medication,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions = '',
  });

  Map<String, dynamic> toMap() => {
    'medication': medication,
    'dosage': dosage,
    'frequency': frequency,
    'duration': duration,
    'instructions': instructions,
  };

  static PrescriptionItem fromMap(Map<String, dynamic> map) => PrescriptionItem(
    medication: map['medication'] ?? '',
    dosage: map['dosage'] ?? '',
    frequency: map['frequency'] ?? '',
    duration: map['duration'] ?? '',
    instructions: map['instructions'] ?? '',
  );
}
