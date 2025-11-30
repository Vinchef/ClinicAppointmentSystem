import 'dart:convert';

class AppNotification {
  final String id;
  final String userEmail;
  final String appointmentId;
  final String type; // booking_confirmed | rescheduled | cancelled | reminder | completed
  final String title;
  final String message;
  final String reason;
  final bool isRead;
  final String createdAt;

  AppNotification({
    required this.id,
    required this.userEmail,
    required this.appointmentId,
    required this.type,
    required this.title,
    required this.message,
    this.reason = '',
    this.isRead = false,
    required this.createdAt,
  });

  // Generate unique ID
  static String generateId() {
    return 'notif_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Copy with modifications
  AppNotification copyWith({
    String? id,
    String? userEmail,
    String? appointmentId,
    String? type,
    String? title,
    String? message,
    String? reason,
    bool? isRead,
    String? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userEmail: userEmail ?? this.userEmail,
      appointmentId: appointmentId ?? this.appointmentId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      reason: reason ?? this.reason,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Encode to JSON string for storage
  String encode() {
    return jsonEncode({
      'id': id,
      'userEmail': userEmail,
      'appointmentId': appointmentId,
      'type': type,
      'title': title,
      'message': message,
      'reason': reason,
      'isRead': isRead,
      'createdAt': createdAt,
    });
  }

  // Decode from JSON string
  static AppNotification decode(String encoded) {
    final map = jsonDecode(encoded) as Map<String, dynamic>;
    return AppNotification(
      id: map['id'] ?? '',
      userEmail: map['userEmail'] ?? '',
      appointmentId: map['appointmentId'] ?? '',
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      reason: map['reason'] ?? '',
      isRead: map['isRead'] ?? false,
      createdAt: map['createdAt'] ?? '',
    );
  }

  // Get icon based on type
  static String getIcon(String type) {
    switch (type) {
      case 'booking_confirmed':
        return '✅';
      case 'rescheduled':
        return '📅';
      case 'cancelled':
        return '❌';
      case 'reminder':
        return '⏰';
      case 'completed':
        return '🎉';
      default:
        return '📢';
    }
  }

  // Get color based on type
  static int getColor(String type) {
    switch (type) {
      case 'booking_confirmed':
        return 0xFF4CAF50; // Green
      case 'rescheduled':
        return 0xFFFF9800; // Orange
      case 'cancelled':
        return 0xFFE53935; // Red
      case 'reminder':
        return 0xFF0066CC; // Blue
      case 'completed':
        return 0xFF9C27B0; // Purple
      default:
        return 0xFF666666;
    }
  }

  // Format time ago
  String get timeAgo {
    try {
      final created = DateTime.parse(createdAt);
      final now = DateTime.now();
      final diff = now.difference(created);
      
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${created.day}/${created.month}/${created.year}';
    } catch (_) {
      return '';
    }
  }

  // Factory methods for creating notifications
  static AppNotification bookingConfirmed({
    required String userEmail,
    required String appointmentId,
    required String doctorName,
    required String date,
    required String time,
  }) {
    return AppNotification(
      id: generateId(),
      userEmail: userEmail,
      appointmentId: appointmentId,
      type: 'booking_confirmed',
      title: 'Booking Confirmed! 🎉',
      message: 'Your appointment with $doctorName on $date at $time is confirmed.',
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  static AppNotification rescheduled({
    required String userEmail,
    required String appointmentId,
    required String doctorName,
    required String newDate,
    required String newTime,
    required String reason,
  }) {
    return AppNotification(
      id: generateId(),
      userEmail: userEmail,
      appointmentId: appointmentId,
      type: 'rescheduled',
      title: 'Appointment Rescheduled',
      message: 'Your appointment with $doctorName has been moved to $newDate at $newTime.',
      reason: reason,
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  static AppNotification cancelled({
    required String userEmail,
    required String appointmentId,
    required String doctorName,
    required String date,
    required String reason,
  }) {
    return AppNotification(
      id: generateId(),
      userEmail: userEmail,
      appointmentId: appointmentId,
      type: 'cancelled',
      title: 'Appointment Cancelled',
      message: 'Your appointment with $doctorName on $date has been cancelled.',
      reason: reason,
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  static AppNotification reminder({
    required String userEmail,
    required String appointmentId,
    required String doctorName,
    required String date,
    required String time,
  }) {
    return AppNotification(
      id: generateId(),
      userEmail: userEmail,
      appointmentId: appointmentId,
      type: 'reminder',
      title: 'Appointment Reminder',
      message: 'Reminder: You have an appointment with $doctorName tomorrow at $time.',
      createdAt: DateTime.now().toIso8601String(),
    );
  }
}
