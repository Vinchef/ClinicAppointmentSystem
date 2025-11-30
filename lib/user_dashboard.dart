import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/doctor.dart';
import 'models/appointment.dart';
import 'models/app_notification.dart';
import 'services/appointment_service.dart';
import 'widgets/branding.dart';
import 'dart:async';

class UserDashboardPage extends StatefulWidget {
  @override
  _UserDashboardPageState createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _userName = 'User';
  String _userEmail = '';
  String _userPhone = '';
  int _selectedIndex = 0;
  bool _isLoading = true;
  List<Appointment> _upcomingAppointments = [];
  List<Appointment> _recentActivity = [];
  List<AppNotification> _appNotifications = [];
  int _unreadCount = 0;
  List<Map<String, String>> _allDoctors = [];

  final List<Map<String, dynamic>> _healthTips = [
    {
      'title': 'Stay Hydrated',
      'description': 'Drink at least 8 glasses of water daily',
      'icon': '💧',
      'color': Color(0xFF00BCD4),
    },
    {
      'title': 'Regular Exercise',
      'description': '30 minutes of activity keeps you healthy',
      'icon': '🏃',
      'color': Color(0xFF4CAF50),
    },
    {
      'title': 'Sleep Well',
      'description': '7-8 hours of quality sleep is essential',
      'icon': '😴',
      'color': Color(0xFF9C27B0),
    },
    {
      'title': 'Eat Healthy',
      'description': 'Balanced diet for better health',
      'icon': '🥗',
      'color': Color(0xFFFF9800),
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('fullName') ?? 'User';
    final email = prefs.getString('username') ?? '';
    final phone = prefs.getString('phoneNumber') ?? '';
    
    // Migrate old data if needed
    await AppointmentService.migrateOldData();
    
    // Load doctors
    var doctorsData = prefs.getStringList('doctorsData') ?? [];
    final defaultDoctorsMap = {
      'dr1': Doctor(id: 'dr1', name: 'Dr. Maria Santos', specialty: 'Pediatrician', imageUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=200', availableDays: ['Monday', 'Wednesday', 'Friday'], availableTimes: ['09:00 AM', '05:00 PM']),
      'dr2': Doctor(id: 'dr2', name: 'Dr. Juan Dela Cruz', specialty: 'Cardiologist', imageUrl: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=200', availableDays: ['Tuesday', 'Thursday'], availableTimes: ['10:00 AM', '04:00 PM']),
      'dr3': Doctor(id: 'dr3', name: 'Dr. Anna Reyes', specialty: 'Dermatologist', imageUrl: 'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=200', availableDays: ['Monday', 'Tuesday', 'Thursday'], availableTimes: ['09:00 AM', '03:00 PM']),
      'dr4': Doctor(id: 'dr4', name: 'Dr. Roberto Garcia', specialty: 'OB-GYN', imageUrl: 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=200', availableDays: ['Wednesday', 'Friday'], availableTimes: ['08:00 AM', '04:00 PM']),
      'dr5': Doctor(id: 'dr5', name: 'Dr. Elena Cruz', specialty: 'General Practitioner', imageUrl: 'https://images.unsplash.com/photo-1651008376811-b90baee60c1f?w=200', availableDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'], availableTimes: ['09:00 AM', '05:00 PM']),
      'dr6': Doctor(id: 'dr6', name: 'Dr. Michael Tan', specialty: 'Neurologist', imageUrl: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=200', availableDays: ['Monday', 'Thursday'], availableTimes: ['10:00 AM', '03:00 PM']),
    };
    
    if (doctorsData.isEmpty) {
      doctorsData = defaultDoctorsMap.values.map((d) => d.encode()).toList();
      await prefs.setStringList('doctorsData', doctorsData);
    }
    
    // Build doctors list for Doctors tab
    final docs = <Map<String, String>>[];
    for (final d in doctorsData) {
      try {
        final doctor = Doctor.decode(d);
        docs.add({
          'id': doctor.id,
          'name': doctor.name,
          'specialty': doctor.specialty,
          'image': doctor.imageUrl,
        });
      } catch (_) {}
    }
    
    // Load appointments using AppointmentService (use email, fallback to name)
    final searchKey = email.isNotEmpty ? email : name;
    final upcoming = await AppointmentService.getUpcomingAppointments(searchKey);
    final past = await AppointmentService.getPastAppointments(searchKey);
    
    // Load notifications (use email, fallback to name)
    final notifications = await AppointmentService.getUserNotifications(searchKey);
    final unread = await AppointmentService.getUnreadCount(searchKey);

    if (mounted) {
      setState(() {
        _userName = name;
        _userEmail = email;
        _userPhone = phone;
        _upcomingAppointments = upcoming;
        _recentActivity = past;
        _appNotifications = notifications;
        _unreadCount = unread;
        _allDoctors = docs;
        _isLoading = false;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  Widget _buildHeroStat(String value, String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 20),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  DateTime? _lastBackPressed;
  
  Future<bool> _onWillPop() async {
    // If not on home tab, go back to home tab first
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return false;
    }
    
    // Double-tap back to exit - require 2 taps within 2 seconds
    final now = DateTime.now();
    if (_lastBackPressed == null || now.difference(_lastBackPressed!) > Duration(seconds: 2)) {
      _lastBackPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF1A237E),
        ),
      );
      return false;
    }
    return true; // Allow exit without logout (session preserved)
  }

  Future<bool?> _showLogoutDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (c) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: EdgeInsets.all(24),
          constraints: BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logout Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFE53935)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFE53935).withOpacity(0.3),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(Icons.logout_rounded, color: Colors.white, size: 40),
              ),
              SizedBox(height: 24),
              // Title
              Text(
                'Leaving So Soon?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A237E),
                ),
              ),
              SizedBox(height: 12),
              // Message
              Text(
                'Are you sure you want to logout?\nYou\'ll need to sign in again to access your appointments.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF666666),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 28),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(c, false),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Color(0xFF0066CC), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Stay',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0066CC),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(c, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE53935),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await _showLogoutDialog();

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/landing');
      }
    }
  }

  Future<void> _cancelAppointment(Map<String, String> appointment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.cancel_outlined, color: Color(0xFFE53935)),
            SizedBox(width: 12),
            Text('Cancel Appointment', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
          ],
        ),
        content: Text('Are you sure you want to cancel your appointment with ${appointment['doctor']} on ${appointment['date']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text('Keep', style: TextStyle(color: Color(0xFF666666))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE53935)),
            child: Text('Cancel Appointment'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      
      // Remove from userAppointments
      final raw = appointment['raw'] ?? '';
      if (raw.isNotEmpty) {
        final rawList = prefs.getStringList('userAppointments') ?? [];
        rawList.remove(raw);
        await prefs.setStringList('userAppointments', rawList);
      }

      // Remove from bookedAppointments - parse raw to get doctorId
      final parts = raw.split('|');
      if (parts.length >= 4) {
        final doctorId = parts[1];
        final date = parts[2];
        final time = parts[3];
        final bookedKey = '$doctorId|$date|$time';
        final bookedList = prefs.getStringList('bookedAppointments') ?? [];
        bookedList.removeWhere((b) => b == bookedKey);
        await prefs.setStringList('bookedAppointments', bookedList);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Appointment cancelled successfully'),
            ],
          ),
          backgroundColor: Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      await _loadUserData();
    }
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.notifications, color: Color(0xFF0066CC), size: 28),
                    SizedBox(width: 12),
                    Text('Notifications', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A237E))),
                    Spacer(),
                    if (_unreadCount > 0)
                      TextButton(
                        onPressed: () async {
                          await AppointmentService.markAllNotificationsRead(_userEmail);
                          await _loadUserData();
                          setModalState(() {});
                        },
                        child: Text('Mark all read', style: TextStyle(color: Color(0xFF0066CC), fontSize: 12)),
                      ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _unreadCount > 0 ? Color(0xFFE53935) : Color(0xFF0066CC).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_appNotifications.length}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _unreadCount > 0 ? Colors.white : Color(0xFF0066CC),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1),
              Expanded(
                child: _appNotifications.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.notifications_off_outlined, size: 64, color: Color(0xFFE0E0E0)),
                        SizedBox(height: 16),
                        Text('No notifications yet', style: TextStyle(color: Color(0xFF666666), fontSize: 16)),
                        SizedBox(height: 8),
                        Text('Book an appointment to get started!', style: TextStyle(color: Color(0xFF999999), fontSize: 14)),
                      ]))
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _appNotifications.length,
                        itemBuilder: (context, index) {
                          final notif = _appNotifications[index];
                          final color = Color(AppNotification.getColor(notif.type));
                          return GestureDetector(
                            onTap: () async {
                              if (!notif.isRead) {
                                await AppointmentService.markNotificationRead(notif.id);
                                await _loadUserData();
                                setModalState(() {});
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 12),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: notif.isRead ? Color(0xFFF8FAFF) : color.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: notif.isRead ? Color(0xFFE0E0E0) : color.withOpacity(0.3),
                                  width: notif.isRead ? 1 : 2,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      AppNotification.getIcon(notif.type),
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                notif.title,
                                                style: TextStyle(
                                                  fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w800,
                                                  color: Color(0xFF1A237E),
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                            if (!notif.isRead)
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: color,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          notif.message,
                                          style: TextStyle(color: Color(0xFF666666), fontSize: 13),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (notif.reason.isNotEmpty) ...[
                                          SizedBox(height: 6),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFFFF3E0),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'Reason: ${notif.reason}',
                                              style: TextStyle(color: Color(0xFFE65100), fontSize: 12),
                                            ),
                                          ),
                                        ],
                                        SizedBox(height: 6),
                                        Text(
                                          notif.timeAgo,
                                          style: TextStyle(color: Color(0xFF999999), fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildBottomNav() {
    final navItems = [
      {'icon': Icons.home_outlined, 'activeIcon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.calendar_month_outlined, 'activeIcon': Icons.calendar_month, 'label': 'Bookings'},
      {'icon': Icons.medical_services_outlined, 'activeIcon': Icons.medical_services, 'label': 'Doctors'},
      {'icon': Icons.person_outline_rounded, 'activeIcon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF0091EA).withOpacity(0.15),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          final item = navItems[index];
          final isSelected = _selectedIndex == index;
          
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 20 : 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF0091EA) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: Color(0xFF0091EA).withOpacity(0.4),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ] : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? item['activeIcon'] as IconData : item['icon'] as IconData,
                    color: isSelected ? Colors.white : Color(0xFF666666),
                    size: 24,
                  ),
                  if (isSelected) ...[
                    SizedBox(width: 8),
                    Text(
                      item['label'] as String,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Color(0xFFF5F8FF),
        body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _selectedIndex == 0
              ? _buildHomeView()
              : _selectedIndex == 1
                  ? _buildAppointmentsView()
                  : _selectedIndex == 2
                      ? _buildDoctorsView()
                      : _buildProfileView(),
        bottomNavigationBar: _buildBottomNav(),
        floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/booking'),
              backgroundColor: Color(0xFF0091EA),
              elevation: 8,
              icon: Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                'Book Now',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : null,
      ),
    );
  }

  Widget _buildHomeView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;

        return RefreshIndicator(
          onRefresh: _loadUserData,
          child: CustomScrollView(
            slivers: [
              // App Bar - Clean modern design
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.white,
                elevation: 0,
                toolbarHeight: 70,
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    HorizonLogo(size: 38, compact: true),
                  ],
                ),
                actions: [
                  // Search Button
                  Container(
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.search, color: Color(0xFF0091EA)),
                      onPressed: () => Navigator.pushNamed(context, '/doctorbrowse'),
                      tooltip: 'Find Doctor',
                    ),
                  ),
                  // Notifications
                  Container(
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        IconButton(
                          icon: Icon(Icons.notifications_outlined, color: Color(0xFF0091EA)),
                          onPressed: _showNotifications,
                          tooltip: 'Notifications',
                        ),
                        if (_unreadCount > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Color(0xFFE53935),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              constraints: BoxConstraints(minWidth: 18, minHeight: 18),
                              child: Text(
                                '$_unreadCount',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Profile Avatar
                  Container(
                    margin: EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedIndex = 3),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0091EA), Color(0xFF1565C0)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Welcome Hero Section - Modern Design
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _animationController,
                  child: Container(
                    margin: EdgeInsets.all(isMobile ? 16 : 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0091EA), Color(0xFF1565C0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF0091EA).withOpacity(0.35),
                          blurRadius: 40,
                          offset: Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Background Pattern
                        Positioned(
                          right: -30,
                          top: -30,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 40,
                          bottom: -40,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: EdgeInsets.all(isMobile ? 24 : 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // User Avatar
                                  Container(
                                    width: isMobile ? 65 : 80,
                                    height: isMobile ? 65 : 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 15,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                                        style: TextStyle(
                                          fontSize: isMobile ? 28 : 36,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0091EA),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getGreeting(),
                                          style: TextStyle(
                                            fontSize: isMobile ? 14 : 16,
                                            color: Colors.white.withOpacity(0.9),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          _userName,
                                          style: TextStyle(
                                            fontSize: isMobile ? 24 : 32,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.5,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 28),
                              // Stats Row
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: _buildHeroStat('${_upcomingAppointments.length}', 'Upcoming', Icons.event_available)),
                                    Container(width: 1, height: 40, color: Colors.white24),
                                    Expanded(child: _buildHeroStat('${_recentActivity.length}', 'Completed', Icons.check_circle_outline)),
                                    Container(width: 1, height: 40, color: Colors.white24),
                                    Expanded(child: _buildHeroStat('${_allDoctors.length}', 'Doctors', Icons.medical_services_outlined)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Health Tips Stories
              SliverToBoxAdapter(
                child: Container(
                  height: 160,
                  margin: EdgeInsets.only(bottom: 16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
                    itemCount: _healthTips.length,
                    itemBuilder: (context, index) {
                      final tip = _healthTips[index];
                      return Container(
                        width: 140,
                        margin: EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              tip['color'],
                              tip['color'].withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: tip['color'].withOpacity(0.3),
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tip['icon'],
                                    style: TextStyle(fontSize: 36),
                                  ),
                                  Spacer(),
                                  Text(
                                    tip['title'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    tip['description'],
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 11,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: isMobile ? 20 : 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: isMobile ? 2 : 4,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                        children: [
                          _buildQuickActionCard(
                            'Book Appointment',
                            Icons.calendar_month,
                            Color(0xFF0066CC),
                            () => Navigator.pushNamed(context, '/booking'),
                          ),
                          _buildQuickActionCard(
                            'Find Doctor',
                            Icons.person_search,
                            Color(0xFF00BCD4),
                            () => Navigator.pushNamed(context, '/doctorbrowse'),
                          ),
                          _buildQuickActionCard(
                            'Medical Records',
                            Icons.folder_special,
                            Color(0xFF4CAF50),
                            () => Navigator.pushNamed(context, '/medical-records'),
                          ),
                          _buildQuickActionCard(
                            'Emergency',
                            Icons.local_hospital,
                            Color(0xFFE53935),
                            () => ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.phone, color: Colors.white),
                                    SizedBox(width: 12),
                                    Text('Emergency: Call 911 or your local emergency'),
                                  ],
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Color(0xFFE53935),
                                duration: Duration(seconds: 5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Upcoming Appointments
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 16 : 24,
                    24,
                    isMobile ? 16 : 24,
                    8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Upcoming Appointments',
                        style: TextStyle(
                          fontSize: isMobile ? 20 : 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _selectedIndex = 1),
                        child: Text(
                          'View All',
                          style: TextStyle(
                            color: Color(0xFF0066CC),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              _upcomingAppointments.isEmpty
                  ? SliverToBoxAdapter(
                      child: _buildEmptyState(
                        'No Upcoming Appointments',
                        'Book your first appointment to get started',
                        Icons.calendar_today_outlined,
                        isMobile,
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final appointment = _upcomingAppointments[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 16 : 24,
                              vertical: 8,
                            ),
                            child: _buildAppointmentCard(appointment, isMobile),
                          );
                        },
                        childCount: _upcomingAppointments.length,
                      ),
                    ),

              // Recent Activity
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 16 : 24,
                    24,
                    isMobile ? 16 : 24,
                    16,
                  ),
                  child: Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: isMobile ? 20 : 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final activity = _recentActivity[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 24,
                        vertical: 6,
                      ),
                      child: _buildActivityCard(activity, isMobile),
                    );
                  },
                  childCount: _recentActivity.length,
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: isMobile ? 20 : 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A237E),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment apt, bool isMobile) {
    final statusColor = Color(Appointment.getStatusColor(apt.status));
    final isUpcoming = apt.status == 'confirmed' || apt.status == 'rescheduled';
    final isPast = apt.status == 'completed';
    final isCancelled = apt.status == 'cancelled';
    
    // Parse date for display
    String formattedDate = apt.date;
    String dayName = '';
    try {
      final date = DateTime.parse(apt.date);
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      dayName = days[date.weekday - 1];
      formattedDate = '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {}
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isUpcoming ? statusColor.withOpacity(0.3) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with gradient
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isUpcoming 
                    ? [Color(0xFF0066CC), Color(0xFF1A237E)]
                    : isCancelled 
                        ? [Color(0xFFE53935), Color(0xFFB71C1C)]
                        : [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: Row(
              children: [
                // Doctor Avatar
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Icon(Icons.person, size: 40, color: Color(0xFF0066CC)),
                  ),
                ),
                SizedBox(width: 16),
                // Doctor Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        apt.doctorName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 6),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          apt.specialty,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isUpcoming ? Icons.schedule : isCancelled ? Icons.cancel : Icons.check_circle,
                        size: 16,
                        color: statusColor,
                      ),
                      SizedBox(width: 6),
                      Text(
                        Appointment.getStatusText(apt.status),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Appointment Details
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Date & Time Row
                Row(
                  children: [
                    // Date Card
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFF8FAFF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Color(0xFFE8EEF8)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFF0066CC).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.calendar_today, color: Color(0xFF0066CC), size: 24),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF666666),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A237E),
                                    ),
                                  ),
                                  if (dayName.isNotEmpty)
                                    Text(
                                      dayName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF0066CC),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    // Time Card
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFF8FAFF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Color(0xFFE8EEF8)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFF4CAF50).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.access_time, color: Color(0xFF4CAF50), size: 24),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Time',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF666666),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    apt.time,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A237E),
                                    ),
                                  ),
                                  Text(
                                    'Appointment',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF4CAF50),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Rescheduled Notice
                if (apt.status == 'rescheduled' && apt.previousDate.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFFFCC80)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.history, color: Color(0xFFFF9800), size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rescheduled',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFE65100),
                                ),
                              ),
                              Text(
                                'Originally: ${apt.previousDate} at ${apt.previousTime}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFFF9800),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Cancelled Reason
                if (apt.status == 'cancelled' && apt.cancelReason.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFEF9A9A)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFFE53935), size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cancellation Reason',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFB71C1C),
                                ),
                              ),
                              Text(
                                apt.cancelReason,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFE53935),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Notes
                if (apt.notes.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.note_outlined, color: Color(0xFF666666), size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notes',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A237E),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                apt.notes,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Action Buttons
                if (isUpcoming) ...[
                  SizedBox(height: 20),
                  Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _cancelUserAppointment(apt),
                          icon: Icon(Icons.cancel_outlined, size: 18),
                          label: Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(0xFFE53935),
                            side: BorderSide(color: Color(0xFFE53935), width: 2),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      // Reschedule Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implement reschedule for user
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Contact clinic to reschedule')),
                            );
                          },
                          icon: Icon(Icons.edit_calendar, size: 18),
                          label: Text('Reschedule'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0066CC),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                
                // Completed Badge
                if (isPast) ...[
                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Appointment Completed',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelUserAppointment(Appointment apt) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.cancel_outlined, color: Color(0xFFE53935)),
            SizedBox(width: 12),
            Text('Cancel Appointment', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
          ],
        ),
        content: Text('Are you sure you want to cancel your appointment with ${apt.doctorName} on ${apt.date}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text('Keep', style: TextStyle(color: Color(0xFF666666)))),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE53935)),
            child: Text('Cancel Appointment'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AppointmentService.cancelAppointment(appointmentId: apt.id, reason: 'Cancelled by patient');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 12), Text('Appointment cancelled')]),
          backgroundColor: Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _loadUserData();
    }
  }

  Widget _buildActivityCard(Appointment apt, bool isMobile) {
    final statusColor = Color(Appointment.getStatusColor(apt.status));
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE0E0E0), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              apt.status == 'completed' ? Icons.check_circle : 
              apt.status == 'cancelled' ? Icons.cancel : Icons.event,
              color: statusColor,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(apt.doctorName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
                SizedBox(height: 4),
                Text('${apt.specialty} • ${apt.date}', style: TextStyle(fontSize: 12, color: Color(0xFF666666))),
                if (apt.cancelReason.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text('Reason: ${apt.cancelReason}', style: TextStyle(fontSize: 11, color: Color(0xFFE53935))),
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(Appointment.getStatusText(apt.status), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon, bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 32),
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(0xFFE0E0E0),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 64, color: Color(0xFF0066CC).withOpacity(0.3)),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A237E),
            ),
          ),
          SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsView() {
    final allAppointments = [..._upcomingAppointments, ..._recentActivity];
    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text('My Appointments', style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.w800, fontSize: 24)),
            actions: [
              IconButton(
                icon: Icon(Icons.add_circle, color: Color(0xFF0066CC), size: 28),
                onPressed: () => Navigator.pushNamed(context, '/booking'),
              ),
              SizedBox(width: 8),
            ],
          ),
          if (allAppointments.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 80, color: Color(0xFFE0E0E0)),
                    SizedBox(height: 16),
                    Text('No appointments yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
                    SizedBox(height: 8),
                    Text('Book your first appointment to get started', style: TextStyle(color: Color(0xFF666666))),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/booking'),
                      icon: Icon(Icons.add),
                      label: Text('Book Appointment'),
                      style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0066CC), padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final apt = allAppointments[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: _buildAppointmentCard(apt, true),
                  );
                },
                childCount: allAppointments.length,
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildDoctorsView() {
    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0066CC), Color(0xFF1A237E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Our Doctors', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                    SizedBox(height: 8),
                    Text('Find the best specialists for your health needs', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/doctorbrowse'),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: Row(children: [Icon(Icons.search, color: Color(0xFF0066CC)), SizedBox(width: 12), Text('Search doctors...', style: TextStyle(color: Color(0xFF999999)))]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(20),
              color: Color(0xFFF8FAFF),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(children: [Icon(Icons.verified_user, color: Color(0xFF0066CC)), SizedBox(height: 8), Text('${_allDoctors.length}+', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A237E))), Text('Specialists', style: TextStyle(fontSize: 12, color: Color(0xFF666666)))]),
                  Container(width: 1, height: 40, color: Color(0xFFE0E0E0)),
                  Column(children: [Icon(Icons.star, color: Color(0xFF0066CC)), SizedBox(height: 8), Text('4.9', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A237E))), Text('Rating', style: TextStyle(fontSize: 12, color: Color(0xFF666666)))]),
                  Container(width: 1, height: 40, color: Color(0xFFE0E0E0)),
                  Column(children: [Icon(Icons.support_agent, color: Color(0xFF0066CC)), SizedBox(height: 8), Text('24/7', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A237E))), Text('Support', style: TextStyle(fontSize: 12, color: Color(0xFF666666)))]),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: Padding(padding: EdgeInsets.fromLTRB(20, 24, 20, 16), child: Text('All Specialists', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A237E))))),
          if (_allDoctors.isEmpty)
            SliverFillRemaining(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.medical_services_outlined, size: 80, color: Color(0xFFE0E0E0)), SizedBox(height: 16), Text('No doctors available', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A237E)))])))
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final doc = _allDoctors[index];
                  final ratings = [4.9, 4.8, 4.7, 5.0, 4.6, 4.9];
                  final experience = [12, 8, 15, 10, 6, 20];
                  final patients = [1200, 850, 2000, 1500, 600, 3000];
                  final rating = ratings[index % ratings.length];
                  final exp = experience[index % experience.length];
                  final patientCount = patients[index % patients.length];
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: Offset(0, 8))]),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Color(0xFF0066CC).withOpacity(0.1), Color(0xFF1A237E).withOpacity(0.05)]),
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 90, height: 90,
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Color(0xFF0066CC).withOpacity(0.2), width: 3), image: (doc['image'] ?? '').isNotEmpty ? DecorationImage(image: NetworkImage(doc['image']!), fit: BoxFit.cover) : null),
                                child: (doc['image'] ?? '').isEmpty ? Icon(Icons.person, color: Color(0xFF0066CC), size: 45) : null,
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: Text(doc['name'] ?? '', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A237E)))),
                                        Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Color(0xFF4CAF50), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.verified, size: 12, color: Colors.white), SizedBox(width: 4), Text('Verified', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600))])),
                                      ],
                                    ),
                                    SizedBox(height: 6),
                                    Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Color(0xFF0066CC).withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(doc['specialty'] ?? '', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0066CC)))),
                                    SizedBox(height: 10),
                                    Row(children: [Icon(Icons.star, size: 16, color: Color(0xFFFFC107)), SizedBox(width: 4), Text('$rating', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A237E))), SizedBox(width: 16), Icon(Icons.work_history, size: 16, color: Color(0xFF666666)), SizedBox(width: 4), Text('$exp yrs', style: TextStyle(fontSize: 13, color: Color(0xFF666666))), SizedBox(width: 16), Icon(Icons.people, size: 16, color: Color(0xFF666666)), SizedBox(width: 4), Text('$patientCount+', style: TextStyle(fontSize: 13, color: Color(0xFF666666)))]),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(children: [Expanded(child: Container(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: Color(0xFF4CAF50).withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Color(0xFF4CAF50).withOpacity(0.3))), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.access_time, size: 16, color: Color(0xFF4CAF50)), SizedBox(width: 6), Text('Available Today', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4CAF50)))]))), SizedBox(width: 12), Expanded(child: Container(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: Color(0xFFFF9800).withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Color(0xFFFF9800).withOpacity(0.3))), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.attach_money, size: 16, color: Color(0xFFFF9800)), SizedBox(width: 6), Text('From ₱500', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFFF9800)))])))]),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: OutlinedButton.icon(onPressed: () => _showDoctorProfile(doc, rating, exp, patientCount), icon: Icon(Icons.person_outline, size: 18), label: Text('View Profile'), style: OutlinedButton.styleFrom(foregroundColor: Color(0xFF0066CC), side: BorderSide(color: Color(0xFF0066CC), width: 2), padding: EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
                                  SizedBox(width: 12),
                                  Expanded(child: ElevatedButton.icon(onPressed: () => Navigator.pushNamed(context, '/booking', arguments: {'doctorId': doc['id'], 'doctorName': doc['name']}), icon: Icon(Icons.calendar_today, size: 18), label: Text('Book Now'), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0066CC), foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 14), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: _allDoctors.length,
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showDoctorProfile(Map<String, String> doc, double rating, int experience, int patients) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(
          children: [
            Container(margin: EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2))),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Container(width: 120, height: 120, decoration: BoxDecoration(color: Color(0xFFF0F4FF), shape: BoxShape.circle, border: Border.all(color: Color(0xFF0066CC), width: 4), image: (doc['image'] ?? '').isNotEmpty ? DecorationImage(image: NetworkImage(doc['image']!), fit: BoxFit.cover) : null), child: (doc['image'] ?? '').isEmpty ? Icon(Icons.person, size: 60, color: Color(0xFF0066CC)) : null),
                          SizedBox(height: 16),
                          Text(doc['name'] ?? '', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1A237E))),
                          SizedBox(height: 8),
                          Container(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(color: Color(0xFF0066CC).withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(doc['specialty'] ?? '', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0066CC)))),
                          SizedBox(height: 8),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.verified, color: Color(0xFF4CAF50), size: 18), SizedBox(width: 6), Text('Verified Professional', style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.w600))]),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Container(
                      padding: EdgeInsets.all(20), decoration: BoxDecoration(color: Color(0xFFF8FAFF), borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                        Column(children: [Icon(Icons.people, color: Color(0xFF0066CC), size: 28), SizedBox(height: 8), Text('$patients+', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A237E))), Text('Patients', style: TextStyle(fontSize: 12, color: Color(0xFF666666)))]),
                        Container(width: 1, height: 50, color: Color(0xFFE0E0E0)),
                        Column(children: [Icon(Icons.work_history, color: Color(0xFF0066CC), size: 28), SizedBox(height: 8), Text('$experience', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A237E))), Text('Years Exp', style: TextStyle(fontSize: 12, color: Color(0xFF666666)))]),
                        Container(width: 1, height: 50, color: Color(0xFFE0E0E0)),
                        Column(children: [Icon(Icons.star, color: Color(0xFF0066CC), size: 28), SizedBox(height: 8), Text('$rating', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A237E))), Text('Rating', style: TextStyle(fontSize: 12, color: Color(0xFF666666)))]),
                      ]),
                    ),
                    SizedBox(height: 24),
                    Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A237E))),
                    SizedBox(height: 12),
                    Text('Dr. ${doc['name']?.split(' ').last ?? 'Doctor'} is a highly experienced ${doc['specialty']} with over $experience years of practice. Known for compassionate patient care and expertise in treating complex conditions.', style: TextStyle(fontSize: 14, color: Color(0xFF666666), height: 1.6)),
                    SizedBox(height: 24),
                    Text('Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A237E))),
                    SizedBox(height: 12),
                    Container(margin: EdgeInsets.only(bottom: 10), padding: EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Color(0xFFE0E0E0))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Icon(Icons.medical_services, size: 20, color: Color(0xFF0066CC)), SizedBox(width: 12), Text('General Consultation', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A237E)))]), Text('₱500 - ₱800', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF4CAF50)))])),
                    Container(margin: EdgeInsets.only(bottom: 10), padding: EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Color(0xFFE0E0E0))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Icon(Icons.medical_services, size: 20, color: Color(0xFF0066CC)), SizedBox(width: 12), Text('Follow-up Visit', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A237E)))]), Text('₱300 - ₱500', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF4CAF50)))])),
                    SizedBox(height: 24),
                    SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () { Navigator.pop(ctx); Navigator.pushNamed(context, '/booking', arguments: {'doctorId': doc['id'], 'doctorName': doc['name']}); }, icon: Icon(Icons.calendar_today), label: Text('Book Appointment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0066CC), foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 18), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfile() {
    final nameCtrl = TextEditingController(text: _userName);
    final phoneCtrl = TextEditingController(text: _userPhone);
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => Container(
      height: MediaQuery.of(context).size.height * 0.7, padding: EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2)))),
        SizedBox(height: 20), Text('Edit Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1A237E))),
        SizedBox(height: 24), Text('Full Name', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF666666))), SizedBox(height: 8),
        TextField(controller: nameCtrl, decoration: InputDecoration(prefixIcon: Icon(Icons.person_outline, color: Color(0xFF0066CC)), filled: true, fillColor: Color(0xFFF8FAFF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
        SizedBox(height: 16), Text('Phone', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF666666))), SizedBox(height: 8),
        TextField(controller: phoneCtrl, decoration: InputDecoration(prefixIcon: Icon(Icons.phone, color: Color(0xFF0066CC)), filled: true, fillColor: Color(0xFFF8FAFF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
        Spacer(),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () async { final p = await SharedPreferences.getInstance(); await p.setString('fullName', nameCtrl.text); await p.setString('phoneNumber', phoneCtrl.text); Navigator.pop(ctx); _loadUserData(); }, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0066CC), padding: EdgeInsets.symmetric(vertical: 16)), child: Text('Save'))),
      ]),
    ));
  }

  void _showSettings() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => Container(
      height: MediaQuery.of(context).size.height * 0.5, padding: EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2)))),
        SizedBox(height: 20), Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1A237E))), SizedBox(height: 24),
        ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.notifications, color: Color(0xFF0066CC)), title: Text('Push Notifications'), trailing: Switch(value: true, onChanged: (_){}, activeColor: Color(0xFF0066CC))),
        ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.email, color: Color(0xFF0066CC)), title: Text('Email Notifications'), trailing: Switch(value: true, onChanged: (_){}, activeColor: Color(0xFF0066CC))),
        Spacer(), Center(child: Text('Version 1.0.0', style: TextStyle(color: Color(0xFF999999)))),
      ]),
    ));
  }

  void _showHelpSupport() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => Container(
      height: MediaQuery.of(context).size.height * 0.5, padding: EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2)))),
        SizedBox(height: 20), Text('Help & Support', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1A237E))), SizedBox(height: 24),
        Container(padding: EdgeInsets.all(16), decoration: BoxDecoration(color: Color(0xFF0066CC).withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: Row(children: [Icon(Icons.email, color: Color(0xFF0066CC)), SizedBox(width: 16), Text('support@horizonclinic.com')])),
        SizedBox(height: 12),
        Container(padding: EdgeInsets.all(16), decoration: BoxDecoration(color: Color(0xFF4CAF50).withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: Row(children: [Icon(Icons.phone, color: Color(0xFF4CAF50)), SizedBox(width: 16), Text('+63 123 456 7890')])),
      ]),
    ));
  }

  Widget _buildProfileView() {
    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          // Profile Header with gradient
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0066CC), Color(0xFF1A237E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    // Profile picture
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 5))],
                      ),
                      child: Center(
                        child: Text(
                          _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                          style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: Color(0xFF0066CC)),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(_userName, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                    SizedBox(height: 4),
                    Text(_userEmail, style: TextStyle(fontSize: 14, color: Colors.white70)),
                    SizedBox(height: 24),
                    // Stats row
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 24),
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildProfileStat('${_upcomingAppointments.length}', 'Upcoming'),
                          Container(width: 1, height: 40, color: Colors.white24),
                          _buildProfileStat('${_recentActivity.length}', 'Completed'),
                          Container(width: 1, height: 40, color: Colors.white24),
                          _buildProfileStat('${_upcomingAppointments.length + _recentActivity.length}', 'Total'),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
          // Menu items
          SliverToBoxAdapter(
            child: Container(
              color: Color(0xFFF5F8FF),
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Account', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF999999), letterSpacing: 1)),
                  SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        _buildProfileMenuItem(Icons.person_outline, 'Edit Profile', 'Update your personal info', _showEditProfile),
                        _buildProfileMenuItem(Icons.calendar_today_outlined, 'My Appointments', 'View your booking history', () => setState(() => _selectedIndex = 1)),
                        _buildProfileMenuItem(Icons.notifications_outlined, 'Notifications', '$_unreadCount new notifications', _showNotifications, showBadge: _unreadCount > 0),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Text('Preferences', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF999999), letterSpacing: 1)),
                  SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        _buildProfileMenuItem(Icons.settings_outlined, 'Settings', 'Manage your preferences', _showSettings),
                        _buildProfileMenuItem(Icons.help_outline, 'Help & Support', 'Get help or contact us', _showHelpSupport),
                        _buildProfileMenuItem(Icons.info_outline, 'About', 'Version 1.0.0', () {}),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  // Logout button
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFEBEE),
                        foregroundColor: Color(0xFFE53935),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, size: 20),
                          SizedBox(width: 8),
                          Text('Logout', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  Widget _buildProfileMenuItem(IconData icon, String title, String subtitle, VoidCallback onTap, {bool showBadge = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Color(0xFF0066CC).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Center(child: Icon(icon, color: Color(0xFF0066CC), size: 22)),
                  if (showBadge)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A237E))),
                  SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Color(0xFF999999))),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Color(0xFFCCCCCC), size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF0066CC)),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A237E))),
      trailing: Icon(Icons.chevron_right, color: Color(0xFF999999)),
      onTap: onTap,
    );
  }
}