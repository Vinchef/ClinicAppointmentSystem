import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/doctor.dart';
import 'models/appointment.dart';
import 'services/appointment_service.dart';
import 'widgets/branding.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({Key? key}) : super(key: key);

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  bool _isLoading = true;
  
  // Doctor info
  String _doctorId = '';
  String _doctorName = '';
  Doctor? _currentDoctor;
  
  // Data
  List<Appointment> _allAppointments = [];
  List<Appointment> _todayAppointments = [];
  List<Appointment> _upcomingAppointments = [];
  List<Appointment> _completedAppointments = [];
  List<Map<String, dynamic>> _patients = [];
  
  // Calendar
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDoctorData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctorData() async {
    setState(() => _isLoading = true);
    
    final prefs = await SharedPreferences.getInstance();
    _doctorId = prefs.getString('loggedInDoctorId') ?? '';
    _doctorName = prefs.getString('loggedInDoctorName') ?? 'Doctor';
    
    // Load doctor details
    final doctorsData = prefs.getStringList('doctorsData') ?? [];
    for (final encoded in doctorsData) {
      try {
        final doctor = Doctor.decode(encoded);
        if (doctor.id == _doctorId) {
          _currentDoctor = doctor;
          break;
        }
      } catch (_) {}
    }
    
    // If no doctor found, create default
    _currentDoctor ??= Doctor(
      id: _doctorId,
      name: _doctorName,
      specialty: 'General Practitioner',
      experienceYears: 5,
      rating: 4.8,
      patientsCount: 500,
      consultationFee: 500,
    );
    
    // Load all appointments
    final appointments = await AppointmentService.getAllAppointments();

    // Helper to normalize doctor names (remove "Dr." prefix, punctuation, extra spaces)
    String normalizeName(String s) {
      return s
          .toLowerCase()
          .replaceAll(RegExp(r'dr\.?\s*'), '') // remove dr or dr.
          .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
          .trim();
    }

    final normDoctorName = normalizeName(_doctorName);

    // Filter appointments for this doctor using id first, then normalized name matching as fallback
    _allAppointments = appointments.where((apt) {
      try {
        final normAptName = normalizeName(apt.doctorName);
        if (apt.doctorId.isNotEmpty && _doctorId.isNotEmpty) {
          if (apt.doctorId == _doctorId) return true;
        }
        if (normDoctorName.isNotEmpty && normAptName.isNotEmpty) {
          if (normAptName == normDoctorName) return true;
          if (normAptName.contains(normDoctorName) || normDoctorName.contains(normAptName)) return true;
        }
      } catch (_) {}
      return false;
    }).toList();
    
    // Sort by date (try parsing dates where possible)
    _allAppointments.sort((a, b) {
      try {
        final da = DateTime.parse(a.date);
        final db = DateTime.parse(b.date);
        return da.compareTo(db);
      } catch (_) {
        return a.date.compareTo(b.date);
      }
    });

    // Categorize appointments
    final today = DateTime.now();

    _todayAppointments = _allAppointments.where((apt) {
      if (apt.status == 'cancelled') return false;
      try {
        final aptDate = DateTime.parse(apt.date);
        return aptDate.year == today.year && aptDate.month == today.month && aptDate.day == today.day;
      } catch (_) {
        // Fallback to string compare if parse fails
        final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        return apt.date == todayStr;
      }
    }).toList();

    _upcomingAppointments = _allAppointments.where((apt) =>
      apt.status == 'confirmed' || apt.status == 'rescheduled'
    ).toList();
    
    _completedAppointments = _allAppointments.where((apt) => 
      apt.status == 'completed'
    ).toList();
    
    // Extract unique patients
    final patientMap = <String, Map<String, dynamic>>{};
    for (final apt in _allAppointments) {
      if (!patientMap.containsKey(apt.patientEmail)) {
        patientMap[apt.patientEmail] = {
          'name': apt.patientName,
          'email': apt.patientEmail,
          'phone': apt.patientPhone,
          'visits': 1,
          'lastVisit': apt.date,
        };
      } else {
        patientMap[apt.patientEmail]!['visits'] = (patientMap[apt.patientEmail]!['visits'] as int) + 1;
        if (apt.date.compareTo(patientMap[apt.patientEmail]!['lastVisit'] as String) > 0) {
          patientMap[apt.patientEmail]!['lastVisit'] = apt.date;
        }
      }
    }
    _patients = patientMap.values.toList();
    
    setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.logout, color: Color(0xFFE53935)),
            SizedBox(width: 12),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isDoctorLoggedIn');
      await prefs.remove('loggedInDoctorId');
      await prefs.remove('loggedInDoctorName');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/landing');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF0066CC)))
        : LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 900;
              
              if (isMobile) {
                return _buildMobileLayout();
              }
              return _buildDesktopLayout();
            },
          ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066CC),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_doctorName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(_currentDoctor?.specialty ?? '', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadDoctorData),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboardView(),
          _buildScheduleView(),
          _buildPatientsView(),
          _buildProfileView(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF0066CC).withOpacity(0.1),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard, color: Color(0xFF0066CC)), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month, color: Color(0xFF0066CC)), label: 'Schedule'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people, color: Color(0xFF0066CC)), label: 'Patients'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: Color(0xFF0066CC)), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Sidebar
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
          ),
          child: Column(
            children: [
              // Logo Header
              const HorizonBrandedHeader(showPortalLabel: true, portalLabel: 'Doctor'),
              
              // Doctor Profile Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFF0066CC),
                      child: Text(
                        _doctorName.isNotEmpty ? _doctorName[0] : 'D',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _doctorName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A237E)),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _currentDoctor?.specialty ?? 'Specialist',
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Navigation Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _buildNavItem(Icons.dashboard_rounded, 'Dashboard', 0),
                    _buildNavItem(Icons.calendar_month_rounded, 'Schedule', 1),
                    _buildNavItem(Icons.people_alt_rounded, 'My Patients', 2),
                    _buildNavItem(Icons.person_rounded, 'Profile', 3),
                  ],
                ),
              ),
              
              // Logout
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE53935),
                      side: const BorderSide(color: Color(0xFFE53935)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Main Content
        Expanded(
          child: Column(
            children: [
              // Top Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    Text(
                      ['Dashboard', 'Schedule', 'My Patients', 'Profile'][_selectedIndex],
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1A237E)),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFF0066CC)),
                      onPressed: _loadDoctorData,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          const Text('Online', style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      _buildDashboardView(),
                      _buildScheduleView(),
                      _buildPatientsView(),
                      _buildProfileView(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: isActive ? const Color(0xFF0066CC) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => setState(() => _selectedIndex = index),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: isActive ? Colors.white : Colors.grey[600], size: 22),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFF1A237E),
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== DASHBOARD VIEW ====================
  
  Widget _buildDashboardView() {
    final now = DateTime.now();
    final greeting = now.hour < 12 ? 'Good Morning' : now.hour < 17 ? 'Good Afternoon' : 'Good Evening';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0066CC), Color(0xFF1A237E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: const Color(0xFF0066CC).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$greeting, ${_doctorName.split(' ').first}! 👋', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('You have ${_todayAppointments.length} appointments today', style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.9))),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildMiniStat(Icons.event_available, '${_todayAppointments.length}', 'Today'),
                        const SizedBox(width: 20),
                        _buildMiniStat(Icons.pending_actions, '${_upcomingAppointments.length}', 'Pending'),
                        const SizedBox(width: 20),
                        _buildMiniStat(Icons.check_circle, '${_completedAppointments.length}', 'Completed'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Stats Cards
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard('Today\'s Patients', '${_todayAppointments.length}', Icons.people_alt_rounded, const Color(0xFF0066CC)),
                _buildStatCard('Total Patients', '${_patients.length}', Icons.person_rounded, const Color(0xFF4CAF50)),
                _buildStatCard('This Week', '${_upcomingAppointments.where((a) => _isThisWeek(a.date)).length}', Icons.calendar_today, const Color(0xFF9C27B0)),
                _buildStatCard('Rating', '${_currentDoctor?.rating ?? 4.8}', Icons.star_rounded, const Color(0xFFFF9800)),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        
        // Today's Appointments
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Today\'s Appointments', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
            TextButton(onPressed: () => setState(() => _selectedIndex = 1), child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 16),
        
        if (_todayAppointments.isEmpty)
          _buildEmptyState('No appointments today', Icons.event_available)
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _todayAppointments.length,
            itemBuilder: (context, index) => _buildAppointmentCard(_todayAppointments[index]),
          ),
      ],
    );
  }

  Widget _buildMiniStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 24),
              ),
              Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
            ],
          ),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A237E))),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment apt) {
    final statusColor = Color(Appointment.getStatusColor(apt.status));
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          // Time
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0066CC).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.access_time, color: Color(0xFF0066CC), size: 20),
                const SizedBox(height: 4),
                Text(apt.time, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0066CC))),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Patient Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(apt.patientName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(apt.patientPhone.isNotEmpty ? apt.patientPhone : 'No phone', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
                if (apt.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('Note: ${apt.notes}', style: TextStyle(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic)),
                ],
              ],
            ),
          ),
          // Status & Actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(Appointment.getStatusText(apt.status), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor)),
              ),
              const SizedBox(height: 8),
              if (apt.status == 'confirmed')
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                      onPressed: () => _markComplete(apt),
                      tooltip: 'Mark Complete',
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Color(0xFFE53935)),
                      onPressed: () => _markNoShow(apt),
                      tooltip: 'No Show',
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _markComplete(Appointment apt) async {
    await AppointmentService.updateAppointmentStatus(apt.id, 'completed');
    _loadDoctorData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Appointment marked as completed'), backgroundColor: Color(0xFF4CAF50)),
    );
  }

  Future<void> _markNoShow(Appointment apt) async {
    await AppointmentService.cancelAppointment(appointmentId: apt.id, reason: 'Patient did not show up');
    _loadDoctorData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Marked as no-show'), backgroundColor: Color(0xFFE53935)),
    );
  }

  // ==================== SCHEDULE VIEW ====================
  
  Widget _buildScheduleView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Calendar Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
          ),
          child: Column(
            children: [
              // Month Navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1)),
                  ),
                  Text(
                    '${_getMonthName(_focusedMonth.month)} ${_focusedMonth.year}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A237E)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Day Headers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                    .map((day) => SizedBox(width: 40, child: Text(day, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600))))
                    .toList(),
              ),
              const SizedBox(height: 12),
              // Calendar Grid
              _buildCalendarGrid(),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Selected Day Appointments
        Text(
          'Appointments for ${_formatDate(_selectedDate)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A237E)),
        ),
        const SizedBox(height: 16),
        _buildSelectedDayAppointments(),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startPadding = firstDay.weekday % 7;
    
    final days = <Widget>[];
    
    // Add padding for days before month starts
    for (int i = 0; i < startPadding; i++) {
      days.add(const SizedBox(width: 40, height: 40));
    }
    
    // Add days of month
    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final hasAppointments = _allAppointments.any((apt) {
        try {
          final aptDate = DateTime.parse(apt.date);
          return aptDate.year == date.year && aptDate.month == date.month && aptDate.day == date.day;
        } catch (_) {
          return apt.date == dateStr;
        }
      });
      final isSelected = _selectedDate.day == day && _selectedDate.month == _focusedMonth.month && _selectedDate.year == _focusedMonth.year;
      final isToday = DateTime.now().day == day && DateTime.now().month == _focusedMonth.month && DateTime.now().year == _focusedMonth.year;
      
      days.add(
        GestureDetector(
          onTap: () => setState(() => _selectedDate = date),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF0066CC) : isToday ? const Color(0xFF0066CC).withOpacity(0.1) : null,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  day.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF1A237E),
                    fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (hasAppointments && !isSelected)
                  Positioned(
                    bottom: 4,
                    child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle)),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: days,
    );
  }

  Widget _buildSelectedDayAppointments() {
    final dateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    final dayAppointments = _allAppointments.where((apt) {
      try {
        final aptDate = DateTime.parse(apt.date);
        return aptDate.year == _selectedDate.year && aptDate.month == _selectedDate.month && aptDate.day == _selectedDate.day;
      } catch (_) {
        return apt.date == dateStr;
      }
    }).toList();
    
    if (dayAppointments.isEmpty) {
      return _buildEmptyState('No appointments on this day', Icons.event_busy);
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dayAppointments.length,
      itemBuilder: (context, index) => _buildAppointmentCard(dayAppointments[index]),
    );
  }

  // ==================== PATIENTS VIEW ====================
  
  Widget _buildPatientsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFF0066CC).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.people, color: Color(0xFF0066CC)),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${_patients.length}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1A237E))),
                        const Text('Total Patients', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFF4CAF50).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.repeat, color: Color(0xFF4CAF50)),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${_patients.where((p) => (p['visits'] as int) > 1).length}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1A237E))),
                        const Text('Returning', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Patients List
        const Text('All Patients', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
        const SizedBox(height: 16),
        
        if (_patients.isEmpty)
          _buildEmptyState('No patients yet', Icons.people_outline)
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _patients.length,
            itemBuilder: (context, index) => _buildPatientCard(_patients[index]),
          ),
      ],
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF0066CC).withOpacity(0.1),
            child: Text(
              (patient['name'] as String).isNotEmpty ? (patient['name'] as String)[0].toUpperCase() : 'P',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF0066CC)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient['name'] ?? 'Unknown', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.email, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Expanded(child: Text(patient['email'] ?? '', style: TextStyle(fontSize: 13, color: Colors.grey[600]), overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF0066CC).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text('${patient['visits']} visits', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0066CC))),
              ),
              const SizedBox(height: 4),
              Text('Last: ${patient['lastVisit']}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== PROFILE VIEW ====================
  
  Widget _buildProfileView() {
    return Column(
      children: [
        // Profile Header
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0066CC), Color(0xFF1A237E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Text(
                  _doctorName.isNotEmpty ? _doctorName[0] : 'D',
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Color(0xFF0066CC)),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_doctorName, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(_currentDoctor?.specialty ?? 'Specialist', style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text('${_currentDoctor?.rating ?? 4.8}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 16),
                        const Icon(Icons.work, color: Colors.white70, size: 18),
                        const SizedBox(width: 4),
                        Text('${_currentDoctor?.experienceYears ?? 5} years', style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Stats
        Row(
          children: [
            Expanded(child: _buildProfileStat('${_patients.length}', 'Total Patients', Icons.people)),
            const SizedBox(width: 16),
            Expanded(child: _buildProfileStat('${_allAppointments.length}', 'Appointments', Icons.calendar_today)),
            const SizedBox(width: 16),
            Expanded(child: _buildProfileStat('₱${((_currentDoctor?.consultationFee ?? 500) * _completedAppointments.length).toInt()}', 'Earnings', Icons.payments)),
          ],
        ),
        const SizedBox(height: 24),
        
        // Info Cards
        _buildInfoCard('Contact Information', [
          _buildInfoRow(Icons.badge, 'Doctor ID', _doctorId),
          _buildInfoRow(Icons.email, 'Email', _currentDoctor?.email.isNotEmpty == true ? _currentDoctor!.email : 'Not set'),
          _buildInfoRow(Icons.phone, 'Phone', _currentDoctor?.phone.isNotEmpty == true ? _currentDoctor!.phone : 'Not set'),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('Consultation Details', [
          _buildInfoRow(Icons.attach_money, 'Fee', '₱${_currentDoctor?.consultationFee ?? 500}'),
          _buildInfoRow(Icons.schedule, 'Available Days', _currentDoctor?.availableDays.isNotEmpty == true ? _currentDoctor!.availableDays.join(', ') : 'Mon, Wed, Fri'),
        ]),
      ],
    );
  }

  Widget _buildProfileStat(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF0066CC), size: 28),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1A237E))),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0066CC), size: 20),
          const SizedBox(width: 12),
          Text('$label: ', style: TextStyle(color: Colors.grey[600])),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A237E)))),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(fontSize: 16, color: Colors.grey[500])),
        ],
      ),
    );
  }

  // Helpers
  bool _isThisWeek(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && date.isBefore(endOfWeek.add(const Duration(days: 1)));
    } catch (_) {
      return false;
    }
  }

  String _getMonthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
