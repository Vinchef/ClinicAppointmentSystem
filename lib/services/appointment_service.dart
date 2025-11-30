import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment.dart';
import '../models/app_notification.dart';

class AppointmentService {
  static const String _appointmentsKey = 'appointments_v2';
  static const String _notificationsKey = 'notifications_v2';
  static const String _bookedSlotsKey = 'booked_slots_v2';

  // ============== APPOINTMENTS ==============

  // Get all appointments
  static Future<List<Appointment>> getAllAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_appointmentsKey) ?? [];
    return data.map((s) => Appointment.decode(s)).toList();
  }

  // Get appointments for a specific user (by email or name)
  static Future<List<Appointment>> getUserAppointments(String emailOrName) async {
    final all = await getAllAppointments();
    if (emailOrName.isEmpty) return all;
    final searchLower = emailOrName.toLowerCase();
    return all.where((a) => 
      a.patientEmail.toLowerCase() == searchLower ||
      a.patientEmail.toLowerCase().contains(searchLower) ||
      a.patientName.toLowerCase() == searchLower ||
      a.patientName.toLowerCase().contains(searchLower) ||
      searchLower.contains(a.patientEmail.toLowerCase()) ||
      searchLower.contains(a.patientName.toLowerCase())
    ).toList();
  }

  // Get upcoming appointments for a user
  static Future<List<Appointment>> getUpcomingAppointments(String email) async {
    final userApts = await getUserAppointments(email);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return userApts.where((a) {
      if (a.status == 'cancelled') return false;
      try {
        final aptDate = DateTime.parse(a.date);
        return !aptDate.isBefore(today);
      } catch (_) {
        return true;
      }
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // Get past appointments for a user
  static Future<List<Appointment>> getPastAppointments(String email) async {
    final userApts = await getUserAppointments(email);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return userApts.where((a) {
      try {
        final aptDate = DateTime.parse(a.date);
        return aptDate.isBefore(today) || a.status == 'completed' || a.status == 'cancelled';
      } catch (_) {
        return false;
      }
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Create new appointment (auto-confirmed)
  static Future<Appointment> createAppointment({
    required String patientName,
    required String patientEmail,
    required String patientPhone,
    required String doctorId,
    required String doctorName,
    required String specialty,
    required String date,
    required String time,
    String notes = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Create appointment
    final appointment = Appointment(
      id: Appointment.generateId(),
      patientName: patientName,
      patientEmail: patientEmail,
      patientPhone: patientPhone,
      doctorId: doctorId,
      doctorName: doctorName,
      specialty: specialty,
      date: date,
      time: time,
      status: 'confirmed',
      notes: notes,
      createdAt: DateTime.now().toIso8601String(),
    );

    // Save appointment
    final appointments = prefs.getStringList(_appointmentsKey) ?? [];
    appointments.add(appointment.encode());
    await prefs.setStringList(_appointmentsKey, appointments);

    // Book the slot
    await _bookSlot(doctorId, date, time);

    // Create confirmation notification
    final notification = AppNotification.bookingConfirmed(
      userEmail: patientEmail,
      appointmentId: appointment.id,
      doctorName: doctorName,
      date: date,
      time: time,
    );
    await _saveNotification(notification);

    return appointment;
  }

  // Reschedule appointment (admin action)
  static Future<void> rescheduleAppointment({
    required String appointmentId,
    required String newDate,
    required String newTime,
    required String reason,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final appointments = prefs.getStringList(_appointmentsKey) ?? [];
    
    final updatedList = <String>[];
    Appointment? updated;
    
    for (final encoded in appointments) {
      final apt = Appointment.decode(encoded);
      if (apt.id == appointmentId) {
        // Free the old slot
        await _freeSlot(apt.doctorId, apt.date, apt.time);
        
        // Update appointment
        updated = apt.copyWith(
          previousDate: apt.date,
          previousTime: apt.time,
          date: newDate,
          time: newTime,
          status: 'rescheduled',
          adminNotes: reason,
        );
        updatedList.add(updated.encode());
        
        // Book the new slot
        await _bookSlot(apt.doctorId, newDate, newTime);
        
        // Create notification
        final notification = AppNotification.rescheduled(
          userEmail: apt.patientEmail,
          appointmentId: apt.id,
          doctorName: apt.doctorName,
          newDate: newDate,
          newTime: newTime,
          reason: reason,
        );
        await _saveNotification(notification);
      } else {
        updatedList.add(encoded);
      }
    }
    
    await prefs.setStringList(_appointmentsKey, updatedList);
  }

  // Cancel appointment (admin action)
  static Future<void> cancelAppointment({
    required String appointmentId,
    required String reason,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final appointments = prefs.getStringList(_appointmentsKey) ?? [];
    
    final updatedList = <String>[];
    
    for (final encoded in appointments) {
      final apt = Appointment.decode(encoded);
      if (apt.id == appointmentId) {
        // Free the slot
        await _freeSlot(apt.doctorId, apt.date, apt.time);
        
        // Update appointment
        final updated = apt.copyWith(
          status: 'cancelled',
          cancelReason: reason,
        );
        updatedList.add(updated.encode());
        
        // Create notification
        final notification = AppNotification.cancelled(
          userEmail: apt.patientEmail,
          appointmentId: apt.id,
          doctorName: apt.doctorName,
          date: apt.date,
          reason: reason,
        );
        await _saveNotification(notification);
      } else {
        updatedList.add(encoded);
      }
    }
    
    await prefs.setStringList(_appointmentsKey, updatedList);
  }

  // Update appointment status (general purpose)
  static Future<void> updateAppointmentStatus(String appointmentId, String newStatus) async {
    final prefs = await SharedPreferences.getInstance();
    final appointments = prefs.getStringList(_appointmentsKey) ?? [];
    
    final updatedList = <String>[];
    
    for (final encoded in appointments) {
      final apt = Appointment.decode(encoded);
      if (apt.id == appointmentId) {
        final updated = apt.copyWith(status: newStatus);
        updatedList.add(updated.encode());
      } else {
        updatedList.add(encoded);
      }
    }
    
    await prefs.setStringList(_appointmentsKey, updatedList);
  }

  // Mark appointment as completed
  static Future<void> completeAppointment(String appointmentId) async {
    await updateAppointmentStatus(appointmentId, 'completed');
  }

  // Mark as no-show
  static Future<void> markNoShow(String appointmentId) async {
    final prefs = await SharedPreferences.getInstance();
    final appointments = prefs.getStringList(_appointmentsKey) ?? [];
    
    final updatedList = <String>[];
    
    for (final encoded in appointments) {
      final apt = Appointment.decode(encoded);
      if (apt.id == appointmentId) {
        final updated = apt.copyWith(status: 'no_show');
        updatedList.add(updated.encode());
      } else {
        updatedList.add(encoded);
      }
    }
    
    await prefs.setStringList(_appointmentsKey, updatedList);
  }

  // ============== SLOT MANAGEMENT ==============

  static Future<void> _bookSlot(String doctorId, String date, String time) async {
    final prefs = await SharedPreferences.getInstance();
    final slots = prefs.getStringList(_bookedSlotsKey) ?? [];
    final key = '$doctorId|$date|$time';
    if (!slots.contains(key)) {
      slots.add(key);
      await prefs.setStringList(_bookedSlotsKey, slots);
    }
  }

  static Future<void> _freeSlot(String doctorId, String date, String time) async {
    final prefs = await SharedPreferences.getInstance();
    final slots = prefs.getStringList(_bookedSlotsKey) ?? [];
    final key = '$doctorId|$date|$time';
    slots.remove(key);
    await prefs.setStringList(_bookedSlotsKey, slots);
  }

  static Future<bool> isSlotAvailable(String doctorId, String date, String time) async {
    final prefs = await SharedPreferences.getInstance();
    final slots = prefs.getStringList(_bookedSlotsKey) ?? [];
    final key = '$doctorId|$date|$time';
    return !slots.contains(key);
  }

  static Future<List<String>> getBookedSlots() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_bookedSlotsKey) ?? [];
  }

  // ============== NOTIFICATIONS ==============

  static Future<void> _saveNotification(AppNotification notification) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getStringList(_notificationsKey) ?? [];
    notifications.insert(0, notification.encode()); // Add to beginning
    await prefs.setStringList(_notificationsKey, notifications);
  }

  // Get notifications for a user (flexible matching)
  static Future<List<AppNotification>> getUserNotifications(String emailOrName) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_notificationsKey) ?? [];
    final decoded = data.map((s) => AppNotification.decode(s)).toList();
    if (emailOrName.isEmpty) return decoded;
    final searchLower = emailOrName.toLowerCase();
    return decoded.where((n) => 
      n.userEmail.toLowerCase() == searchLower ||
      n.userEmail.toLowerCase().contains(searchLower) ||
      searchLower.contains(n.userEmail.toLowerCase()) ||
      n.userEmail.isEmpty
    ).toList();
  }

  // Get unread count
  static Future<int> getUnreadCount(String email) async {
    final notifications = await getUserNotifications(email);
    return notifications.where((n) => !n.isRead).length;
  }

  // Mark notification as read
  static Future<void> markNotificationRead(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getStringList(_notificationsKey) ?? [];
    
    final updatedList = <String>[];
    
    for (final encoded in notifications) {
      final notif = AppNotification.decode(encoded);
      if (notif.id == notificationId) {
        final updated = notif.copyWith(isRead: true);
        updatedList.add(updated.encode());
      } else {
        updatedList.add(encoded);
      }
    }
    
    await prefs.setStringList(_notificationsKey, updatedList);
  }

  // Mark all as read
  static Future<void> markAllNotificationsRead(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getStringList(_notificationsKey) ?? [];
    
    final updatedList = <String>[];
    
    for (final encoded in notifications) {
      final notif = AppNotification.decode(encoded);
      if (notif.userEmail.toLowerCase() == email.toLowerCase() && !notif.isRead) {
        final updated = notif.copyWith(isRead: true);
        updatedList.add(updated.encode());
      } else {
        updatedList.add(encoded);
      }
    }
    
    await prefs.setStringList(_notificationsKey, updatedList);
  }

  // ============== MIGRATION ==============
  // Migrate old data format to new format
  static Future<void> migrateOldData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if already migrated
    final migrated = prefs.getBool('data_migrated_v2') ?? false;
    if (migrated) return;

    // Migrate old userAppointments
    final oldApts = prefs.getStringList('userAppointments') ?? [];
    final doctorsData = prefs.getStringList('doctorsData') ?? [];
    
    // Build doctor lookup
    final doctorLookup = <String, Map<String, String>>{};
    for (final d in doctorsData) {
      try {
        final parts = d.split('||');
        if (parts.isNotEmpty) {
          final id = parts[0];
          final name = parts.length > 1 ? parts[1] : id;
          final specialty = parts.length > 2 ? parts[2] : '';
          doctorLookup[id] = {'name': name, 'specialty': specialty};
        }
      } catch (_) {}
    }

    final newAppointments = <String>[];
    
    for (final old in oldApts) {
      try {
        // Old format: name|doctorId|date|time|email|phone|notes
        final parts = old.split('|');
        if (parts.length >= 4) {
          final doctorId = parts[1];
          final doctorInfo = doctorLookup[doctorId] ?? {'name': doctorId, 'specialty': ''};
          
          final apt = Appointment(
            id: Appointment.generateId(),
            patientName: parts[0],
            patientEmail: parts.length > 4 ? parts[4] : '',
            patientPhone: parts.length > 5 ? parts[5] : '',
            doctorId: doctorId,
            doctorName: doctorInfo['name'] ?? doctorId,
            specialty: doctorInfo['specialty'] ?? '',
            date: parts[2],
            time: parts[3],
            status: 'confirmed',
            notes: parts.length > 6 ? parts[6] : '',
            createdAt: DateTime.now().toIso8601String(),
          );
          newAppointments.add(apt.encode());
        }
      } catch (_) {}
    }

    if (newAppointments.isNotEmpty) {
      await prefs.setStringList(_appointmentsKey, newAppointments);
    }

    // Mark as migrated
    await prefs.setBool('data_migrated_v2', true);
  }
}
