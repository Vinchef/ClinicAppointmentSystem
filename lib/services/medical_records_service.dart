import 'package:shared_preferences/shared_preferences.dart';
import '../models/medical_record.dart';
import '../models/appointment.dart';
import 'appointment_service.dart';

class MedicalRecordsService {
  static const String _recordsKey = 'medical_records';

  // Get all records for a patient - includes records from completed appointments
  static Future<List<MedicalRecord>> getPatientRecords(String patientEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final records = <MedicalRecord>[];
    
    // 1. Get manually added records
    final recordsData = prefs.getStringList(_recordsKey) ?? [];
    for (final encoded in recordsData) {
      try {
        final record = MedicalRecord.decode(encoded);
        if (record.patientEmail.toLowerCase() == patientEmail.toLowerCase() ||
            record.patientName.toLowerCase() == patientEmail.toLowerCase()) {
          records.add(record);
        }
      } catch (_) {}
    }
    
    // 2. Generate records from COMPLETED appointments (past visits)
    final pastAppointments = await AppointmentService.getPastAppointments(patientEmail);
    for (final apt in pastAppointments) {
      // Check if we already have a record for this appointment
      final existingRecord = records.any((r) => r.appointmentId == apt.id);
      if (!existingRecord) {
        // Create a visit record from the completed appointment
        final visitRecord = MedicalRecord(
          id: 'visit_${apt.id}',
          patientEmail: apt.patientEmail,
          patientName: apt.patientName,
          type: MedicalRecord.typeNote,
          title: 'Visit: ${apt.specialty}',
          description: apt.notes.isNotEmpty 
              ? apt.notes 
              : 'Consultation with ${apt.doctorName} for ${apt.specialty}. ${apt.status == 'completed' ? 'Visit completed successfully.' : ''}',
          doctorName: apt.doctorName,
          doctorSpecialty: apt.specialty,
          date: apt.date,
          appointmentId: apt.id,
          data: {
            'appointmentTime': apt.time,
            'appointmentStatus': apt.status,
          },
          createdAt: DateTime.tryParse(apt.date) ?? DateTime.now(),
        );
        records.add(visitRecord);
      }
    }
    
    // Sort by date (newest first)
    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return records;
  }

  // Get records by type
  static Future<List<MedicalRecord>> getRecordsByType(String patientEmail, String type) async {
    final allRecords = await getPatientRecords(patientEmail);
    return allRecords.where((r) => r.type == type).toList();
  }

  // Add a new record
  static Future<void> addRecord(MedicalRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final recordsData = prefs.getStringList(_recordsKey) ?? [];
    recordsData.add(record.encode());
    await prefs.setStringList(_recordsKey, recordsData);
  }

  // Update a record
  static Future<void> updateRecord(MedicalRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final recordsData = prefs.getStringList(_recordsKey) ?? [];
    
    final updatedList = <String>[];
    for (final encoded in recordsData) {
      try {
        final existing = MedicalRecord.decode(encoded);
        if (existing.id == record.id) {
          updatedList.add(record.encode());
        } else {
          updatedList.add(encoded);
        }
      } catch (_) {
        updatedList.add(encoded);
      }
    }
    
    await prefs.setStringList(_recordsKey, updatedList);
  }

  // Delete a record
  static Future<void> deleteRecord(String recordId) async {
    final prefs = await SharedPreferences.getInstance();
    final recordsData = prefs.getStringList(_recordsKey) ?? [];
    
    final updatedList = <String>[];
    for (final encoded in recordsData) {
      try {
        final existing = MedicalRecord.decode(encoded);
        if (existing.id != recordId) {
          updatedList.add(encoded);
        }
      } catch (_) {
        updatedList.add(encoded);
      }
    }
    
    await prefs.setStringList(_recordsKey, updatedList);
  }

  // Get record counts by type
  static Future<Map<String, int>> getRecordCounts(String patientEmail) async {
    final records = await getPatientRecords(patientEmail);
    final counts = <String, int>{};
    
    for (final record in records) {
      counts[record.type] = (counts[record.type] ?? 0) + 1;
    }
    
    return counts;
  }

  // Get allergies (special case - always important)
  static Future<List<MedicalRecord>> getAllergies(String patientEmail) async {
    return getRecordsByType(patientEmail, MedicalRecord.typeAllergy);
  }

  // Get current medications (prescriptions from last 30 days)
  static Future<List<MedicalRecord>> getCurrentMedications(String patientEmail) async {
    final prescriptions = await getRecordsByType(patientEmail, MedicalRecord.typePrescription);
    final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
    return prescriptions.where((p) => p.createdAt.isAfter(thirtyDaysAgo)).toList();
  }

  // Generate sample records for demo
  static Future<void> generateSampleRecords(String patientEmail, String patientName) async {
    final existing = await getPatientRecords(patientEmail);
    if (existing.isNotEmpty) return; // Don't generate if already has records

    final now = DateTime.now();
    final sampleRecords = [
      // Allergies
      MedicalRecord(
        id: 'rec_${now.millisecondsSinceEpoch}_1',
        patientEmail: patientEmail,
        patientName: patientName,
        type: MedicalRecord.typeAllergy,
        title: 'Penicillin Allergy',
        description: 'Severe allergic reaction to Penicillin and related antibiotics. Patient experiences rash and difficulty breathing.',
        doctorName: 'Dr. Maria Santos',
        doctorSpecialty: 'General Practitioner',
        date: now.subtract(Duration(days: 365)).toIso8601String().split('T')[0],
        data: {'severity': 'severe', 'reaction': 'anaphylaxis'},
        createdAt: now.subtract(Duration(days: 365)),
      ),
      
      // Recent diagnosis
      MedicalRecord(
        id: 'rec_${now.millisecondsSinceEpoch}_2',
        patientEmail: patientEmail,
        patientName: patientName,
        type: MedicalRecord.typeDiagnosis,
        title: 'Seasonal Allergic Rhinitis',
        description: 'Patient presents with sneezing, runny nose, and itchy eyes. Symptoms consistent with seasonal allergies.',
        doctorName: 'Dr. Anna Reyes',
        doctorSpecialty: 'Allergist',
        date: now.subtract(Duration(days: 14)).toIso8601String().split('T')[0],
        data: {'icdCode': 'J30.2', 'severity': 'mild'},
        createdAt: now.subtract(Duration(days: 14)),
      ),
      
      // Prescription
      MedicalRecord(
        id: 'rec_${now.millisecondsSinceEpoch}_3',
        patientEmail: patientEmail,
        patientName: patientName,
        type: MedicalRecord.typePrescription,
        title: 'Allergy Medication',
        description: 'Prescribed for seasonal allergic rhinitis management.',
        doctorName: 'Dr. Anna Reyes',
        doctorSpecialty: 'Allergist',
        date: now.subtract(Duration(days: 14)).toIso8601String().split('T')[0],
        data: {
          'medications': [
            {'medication': 'Cetirizine 10mg', 'dosage': '10mg', 'frequency': 'Once daily', 'duration': '30 days', 'instructions': 'Take at bedtime'},
            {'medication': 'Fluticasone Nasal Spray', 'dosage': '50mcg', 'frequency': 'Twice daily', 'duration': '14 days', 'instructions': '2 sprays each nostril'},
          ]
        },
        createdAt: now.subtract(Duration(days: 14)),
      ),
      
      // Vital signs
      MedicalRecord(
        id: 'rec_${now.millisecondsSinceEpoch}_4',
        patientEmail: patientEmail,
        patientName: patientName,
        type: MedicalRecord.typeVitals,
        title: 'Routine Checkup Vitals',
        description: 'Vital signs recorded during routine health checkup.',
        doctorName: 'Dr. Elena Cruz',
        doctorSpecialty: 'General Practitioner',
        date: now.subtract(Duration(days: 7)).toIso8601String().split('T')[0],
        data: {
          'bloodPressureSystolic': 120,
          'bloodPressureDiastolic': 80,
          'heartRate': 72,
          'temperature': 36.6,
          'weight': 70,
          'height': 170,
          'oxygenSaturation': 98,
        },
        createdAt: now.subtract(Duration(days: 7)),
      ),
      
      // Lab result
      MedicalRecord(
        id: 'rec_${now.millisecondsSinceEpoch}_5',
        patientEmail: patientEmail,
        patientName: patientName,
        type: MedicalRecord.typeLabResult,
        title: 'Complete Blood Count (CBC)',
        description: 'Routine blood work results. All values within normal range.',
        doctorName: 'Dr. Elena Cruz',
        doctorSpecialty: 'General Practitioner',
        date: now.subtract(Duration(days: 7)).toIso8601String().split('T')[0],
        data: {
          'results': [
            {'test': 'Hemoglobin', 'value': '14.5', 'unit': 'g/dL', 'range': '13.5-17.5', 'status': 'normal'},
            {'test': 'White Blood Cells', 'value': '7.2', 'unit': 'K/uL', 'range': '4.5-11.0', 'status': 'normal'},
            {'test': 'Platelets', 'value': '250', 'unit': 'K/uL', 'range': '150-400', 'status': 'normal'},
            {'test': 'Red Blood Cells', 'value': '4.8', 'unit': 'M/uL', 'range': '4.5-5.5', 'status': 'normal'},
          ]
        },
        createdAt: now.subtract(Duration(days: 7)),
      ),
      
      // Vaccination
      MedicalRecord(
        id: 'rec_${now.millisecondsSinceEpoch}_6',
        patientEmail: patientEmail,
        patientName: patientName,
        type: MedicalRecord.typeVaccination,
        title: 'Influenza Vaccine',
        description: 'Annual flu vaccination administered.',
        doctorName: 'Dr. Maria Santos',
        doctorSpecialty: 'General Practitioner',
        date: now.subtract(Duration(days: 60)).toIso8601String().split('T')[0],
        data: {
          'vaccine': 'Influenza (Flu) Vaccine',
          'manufacturer': 'Sanofi Pasteur',
          'lotNumber': 'FLU2024A',
          'site': 'Left deltoid',
          'nextDue': now.add(Duration(days: 305)).toIso8601String().split('T')[0],
        },
        createdAt: now.subtract(Duration(days: 60)),
      ),
      
      // Doctor note
      MedicalRecord(
        id: 'rec_${now.millisecondsSinceEpoch}_7',
        patientEmail: patientEmail,
        patientName: patientName,
        type: MedicalRecord.typeNote,
        title: 'Follow-up Recommendations',
        description: 'Patient advised to maintain healthy diet and regular exercise. Schedule follow-up in 3 months for routine checkup. Continue current allergy medication as prescribed.',
        doctorName: 'Dr. Elena Cruz',
        doctorSpecialty: 'General Practitioner',
        date: now.subtract(Duration(days: 7)).toIso8601String().split('T')[0],
        data: {},
        createdAt: now.subtract(Duration(days: 7)),
      ),
    ];

    for (final record in sampleRecords) {
      await addRecord(record);
    }
  }
}
