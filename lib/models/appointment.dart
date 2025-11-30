import 'dart:convert';

class Appointment {
  final String id;
  final String patientName;
  final String patientEmail;
  final String patientPhone;
  final String doctorId;
  final String doctorName;
  final String specialty;
  final String date;
  final String time;
  final String status; // confirmed | cancelled | rescheduled | completed | no_show
  final String notes;
  final String adminNotes;
  final String createdAt;
  final String updatedAt;
  final String cancelReason;
  final String previousDate; // For rescheduled appointments
  final String previousTime;

  Appointment({
    required this.id,
    required this.patientName,
    required this.patientEmail,
    required this.patientPhone,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    this.status = 'confirmed',
    this.notes = '',
    this.adminNotes = '',
    required this.createdAt,
    String? updatedAt,
    this.cancelReason = '',
    this.previousDate = '',
    this.previousTime = '',
  }) : updatedAt = updatedAt ?? createdAt;

  // Generate unique ID
  static String generateId() {
    return 'apt_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Copy with modifications
  Appointment copyWith({
    String? id,
    String? patientName,
    String? patientEmail,
    String? patientPhone,
    String? doctorId,
    String? doctorName,
    String? specialty,
    String? date,
    String? time,
    String? status,
    String? notes,
    String? adminNotes,
    String? createdAt,
    String? updatedAt,
    String? cancelReason,
    String? previousDate,
    String? previousTime,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      patientEmail: patientEmail ?? this.patientEmail,
      patientPhone: patientPhone ?? this.patientPhone,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now().toIso8601String(),
      cancelReason: cancelReason ?? this.cancelReason,
      previousDate: previousDate ?? this.previousDate,
      previousTime: previousTime ?? this.previousTime,
    );
  }

  // Encode to JSON string for storage
  String encode() {
    return jsonEncode({
      'id': id,
      'patientName': patientName,
      'patientEmail': patientEmail,
      'patientPhone': patientPhone,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'specialty': specialty,
      'date': date,
      'time': time,
      'status': status,
      'notes': notes,
      'adminNotes': adminNotes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'cancelReason': cancelReason,
      'previousDate': previousDate,
      'previousTime': previousTime,
    });
  }

  // Decode from JSON string
  static Appointment decode(String encoded) {
    final map = jsonDecode(encoded) as Map<String, dynamic>;
    return Appointment(
      id: map['id'] ?? '',
      patientName: map['patientName'] ?? '',
      patientEmail: map['patientEmail'] ?? '',
      patientPhone: map['patientPhone'] ?? '',
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      specialty: map['specialty'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      status: map['status'] ?? 'confirmed',
      notes: map['notes'] ?? '',
      adminNotes: map['adminNotes'] ?? '',
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
      cancelReason: map['cancelReason'] ?? '',
      previousDate: map['previousDate'] ?? '',
      previousTime: map['previousTime'] ?? '',
    );
  }

  // Check if appointment is in the past
  bool get isPast {
    try {
      final aptDate = DateTime.parse(date);
      return aptDate.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  // Check if appointment is today
  bool get isToday {
    try {
      final aptDate = DateTime.parse(date);
      final now = DateTime.now();
      return aptDate.year == now.year && 
             aptDate.month == now.month && 
             aptDate.day == now.day;
    } catch (_) {
      return false;
    }
  }

  // Get status display color
  static int getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return 0xFF4CAF50; // Green
      case 'cancelled':
        return 0xFFE53935; // Red
      case 'rescheduled':
        return 0xFFFF9800; // Orange
      case 'completed':
        return 0xFF0066CC; // Blue
      case 'no_show':
        return 0xFF9E9E9E; // Grey
      default:
        return 0xFF666666;
    }
  }

  // Get status display text
  static String getStatusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmed';
      case 'cancelled':
        return 'Cancelled';
      case 'rescheduled':
        return 'Rescheduled';
      case 'completed':
        return 'Completed';
      case 'no_show':
        return 'No Show';
      default:
        return status;
    }
  }
}
