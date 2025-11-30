import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/doctor.dart';
import 'models/appointment.dart';
import 'services/appointment_service.dart';
import 'widgets/branding.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with TickerProviderStateMixin {
  // Animation
  late AnimationController _animationController;
  late AnimationController _sidebarController;
  
  // Navigation
  int _selectedNavIndex = 0;
  bool _isSidebarExpanded = true;
  
  // Data
  List<Doctor> _doctors = [];
  List<Appointment> _appointments = [];
  List<Map<String, String>> _users = [];
  List<String> _bookedAppointments = [];
  bool _isLoading = true;
  
  // Search & Filters
  String _doctorSearchQuery = '';
  String _selectedSpecialtyFilter = 'All';
  String _appointmentStatusFilter = 'All';
  String _userSearchQuery = '';
  
  // Specialties list
  final List<String> _specialties = [
    'All',
    'Pediatrician',
    'OB-GYN',
    'Dermatologist',
    'Cardiologist',
    'Endocrinologist',
    'Neurologist',
    'Orthopedic Doctor',
    'ENT / Otolaryngologist',
    'Gastroenterologist',
    'Pulmonologist',
    'General Practitioner',
  ];

  // Default doctors for initialization
  final List<Doctor> _defaultDoctors = [
    Doctor(
      name: 'Dr. Khaled Almatrook',
      specialty: 'Pediatrician',
      imageUrl: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=150',
      availableDays: ['Monday', 'Tuesday', 'Wednesday'],
      availableTimes: ['09:00 AM', '04:00 PM'],
      description: 'Experienced pediatrician with 10+ years of practice.',
    ),
    Doctor(
      name: 'Dr. Ahmed Al-Khaldi',
      specialty: 'Dermatologist',
      imageUrl: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=150',
      availableDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday'],
      availableTimes: ['10:00 AM', '05:00 PM'],
      description: 'Specialist in skin care and cosmetic dermatology.',
    ),
    Doctor(
      name: 'Dr. Youssef Al-Mohannadi',
      specialty: 'Cardiologist',
      imageUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=150',
      availableDays: ['Tuesday', 'Wednesday', 'Thursday'],
      availableTimes: ['08:00 AM', '03:00 PM'],
      description: 'Heart specialist with expertise in cardiac care.',
    ),
    Doctor(
      name: 'Dr. Hassan Al-Thani',
      specialty: 'Neurologist',
      imageUrl: 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=150',
      availableDays: ['Monday', 'Wednesday', 'Friday'],
      availableTimes: ['09:00 AM', '04:00 PM'],
      description: 'Expert in neurological disorders and treatments.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _sidebarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sidebarController.forward();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    await _loadDoctors();
    await _loadBookedAppointments();
    await _loadUsers();
    await _parseAppointments();
    _animationController.forward();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadDoctors() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('doctorsData');
    if (saved != null && saved.isNotEmpty) {
      _doctors = saved.map((s) => Doctor.decode(s)).toList();
      // Ensure demo accounts (dr1..dr6) exist in a merge-only fashion
      final demoDefaults = [
        Doctor(id: 'dr1', name: 'Dr. Maria Santos', specialty: 'Pediatrician', imageUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=600&h=700&fit=crop', availableDays: ['Monday', 'Wednesday', 'Friday'], availableTimes: ['09:00 AM', '05:00 PM']),
        Doctor(id: 'dr2', name: 'Dr. Juan Dela Cruz', specialty: 'Cardiologist', imageUrl: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=600&h=700&fit=crop', availableDays: ['Tuesday', 'Thursday'], availableTimes: ['10:00 AM', '04:00 PM']),
        Doctor(id: 'dr3', name: 'Dr. Anna Reyes', specialty: 'Dermatologist', imageUrl: 'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=600&h=700&fit=crop', availableDays: ['Monday', 'Tuesday', 'Thursday'], availableTimes: ['09:00 AM', '03:00 PM']),
        Doctor(id: 'dr4', name: 'Dr. Roberto Garcia', specialty: 'OB-GYN', imageUrl: 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=600&h=700&fit=crop', availableDays: ['Wednesday', 'Friday'], availableTimes: ['08:00 AM', '04:00 PM']),
        Doctor(id: 'dr5', name: 'Dr. Elena Cruz', specialty: 'General Practitioner', imageUrl: 'https://images.unsplash.com/photo-1651008376811-b90baee60c1f?w=600&h=700&fit=crop', availableDays: ['Monday','Tuesday','Wednesday','Thursday','Friday'], availableTimes: ['09:00 AM','05:00 PM']),
        Doctor(id: 'dr6', name: 'Dr. Michael Tan', specialty: 'Neurologist', imageUrl: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=600&h=700&fit=crop', availableDays: ['Monday','Thursday'], availableTimes: ['10:00 AM','03:00 PM']),
      ];

      final existingIds = _doctors.map((d) => d.id).toSet();
      final existingNames = _doctors.map((d) => d.name.toLowerCase()).toSet();
      var added = false;
      for (final demo in demoDefaults) {
        if (!existingIds.contains(demo.id) && !existingNames.contains(demo.name.toLowerCase())) {
          _doctors.add(demo);
          added = true;
        }
      }
      if (added) {
        await prefs.setStringList('doctorsData', _doctors.map((d) => d.encode()).toList());
      }
    } else {
      // Use default doctors if no saved data
      _doctors = List.from(_defaultDoctors);
      await prefs.setStringList('doctorsData', _doctors.map((d) => d.encode()).toList());
    }
    // Ensure every doctor has an id
    var changed = false;
    for (var d in _doctors) {
      if (d.id.isEmpty) {
        d.id = DateTime.now().microsecondsSinceEpoch.toString();
        changed = true;
      }
    }
    if (changed) {
      await prefs.setStringList('doctorsData', _doctors.map((d) => d.encode()).toList());
    }
    if (mounted) setState(() {});
  }

  Future<void> _loadBookedAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('bookedAppointments') ?? [];
    final migrated = <String>[];
    for (final slot in raw) {
      final parts = slot.split('|');
      if (parts.length < 3) continue;
      final first = parts[0];
      final date = parts[1];
      final time = parts[2];

      final byId = _doctors.where((d) => d.id == first).toList();
      if (byId.isNotEmpty) {
        migrated.add(slot);
        continue;
      }

      final byName = _doctors.where((d) => d.name == first).toList();
      if (byName.isNotEmpty) {
        migrated.add('${byName.first.id}|$date|$time');
      } else {
        migrated.add(slot);
      }
    }

    await prefs.setStringList('bookedAppointments', migrated);
    if (mounted) setState(() => _bookedAppointments = migrated);
  }

  Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    // Load from 'users' key - format: "FullName|Email|Password|Phone"
    final rawUsers = prefs.getStringList('users') ?? [];
    _users = rawUsers.map((u) {
      final parts = u.split('|');
      return {
        'fullName': parts.isNotEmpty ? parts[0] : '',
        'email': parts.length > 1 ? parts[1] : '',
        'password': parts.length > 2 ? parts[2] : '',
        'phone': parts.length > 3 ? parts[3] : '',
      };
    }).toList();
    if (mounted) setState(() {});
  }

  Future<void> _parseAppointments() async {
    // Migrate old data and load from new service
    await AppointmentService.migrateOldData();
    _appointments = await AppointmentService.getAllAppointments();
    // Sort by date descending (newest first)
    _appointments.sort((a, b) => b.date.compareTo(a.date));
    if (mounted) setState(() {});
  }

  String _getAppointmentStatus(String dateStr) {
    if (dateStr.isEmpty) return 'Pending';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final appointmentDate = DateTime(date.year, date.month, date.day);
      
      if (appointmentDate.isBefore(today)) return 'Completed';
      if (appointmentDate.isAtSameMomentAs(today)) return 'Today';
      return 'Upcoming';
    } catch (_) {
      return 'Pending';
    }
  }

  // ==================== DOCTOR CRUD OPERATIONS ====================

  // Generate unique doctor ID
  String _generateDoctorId() {
    int maxId = 0;
    for (final doc in _doctors) {
      if (doc.id.startsWith('dr')) {
        final numPart = int.tryParse(doc.id.substring(2)) ?? 0;
        if (numPart > maxId) maxId = numPart;
      }
    }
    return 'dr${maxId + 1}';
  }

  void _showAddDoctorDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final imageController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final feeController = TextEditingController(text: '500');
    String selectedSpecialty = 'General Practitioner';
    final weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final selectedDays = <String>{};
    String? startTime = '09:00 AM';
    String? endTime = '04:00 PM';
    final timeSlots = ['08:00 AM', '08:30 AM', '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM', '12:00 PM', '12:30 PM', '01:00 PM', '01:30 PM', '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM', '04:00 PM', '04:30 PM', '05:00 PM'];
    
    // Auto-generate doctor ID
    final generatedId = _generateDoctorId();
    const defaultPassword = 'doctor123';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0066CC).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person_add, color: Color(0xFF0066CC), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text('Add New Doctor', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, color: Color(0xFF1A237E), fontSize: 20)),
                ],
              ),
              content: SizedBox(
                width: 550,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Auto-generated credentials info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.badge, color: Color(0xFF4CAF50), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF1A237E)),
                                  children: [
                                    const TextSpan(text: 'Doctor ID: '),
                                    TextSpan(text: generatedId, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF4CAF50))),
                                    const TextSpan(text: '  •  Password: '),
                                    const TextSpan(text: defaultPassword, style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF4CAF50))),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDialogTextField(nameController, 'Full Name', Icons.person, 'Dr. John Smith'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildDialogTextField(emailController, 'Email', Icons.email, 'doctor@clinic.com')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildDialogTextField(phoneController, 'Phone', Icons.phone, '+63 XXX XXX XXXX')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDialogDropdown(
                        'Specialty',
                        Icons.medical_services,
                        selectedSpecialty,
                        _specialties.where((s) => s != 'All').toList(),
                        (val) => setDialogState(() => selectedSpecialty = val!),
                      ),
                      const SizedBox(height: 16),
                      _buildDialogTextField(feeController, 'Consultation Fee (₱)', Icons.payments, '500'),
                      const SizedBox(height: 16),
                      _buildDialogTextField(descriptionController, 'Bio / Description', Icons.description, 'Brief bio...', maxLines: 2),
                      const SizedBox(height: 16),
                      const Text('Profile Image', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A237E), fontFamily: 'Montserrat')),
                      const SizedBox(height: 8),
                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                          color: const Color(0xFFF5F8FF),
                        ),
                        child: imageController.text.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(imageController.text, fit: BoxFit.cover, width: double.infinity,
                                  errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey))),
                              )
                            : const Center(child: Icon(Icons.add_photo_alternate, size: 40, color: Color(0xFF0066CC))),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: imageController,
                        decoration: InputDecoration(
                          hintText: 'Image URL (optional)',
                          prefixIcon: const Icon(Icons.link, color: Color(0xFF0066CC)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),
                      const SizedBox(height: 20),
                      const Text('Available Days', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A237E), fontFamily: 'Montserrat')),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: weekdays.map((day) {
                          final isSelected = selectedDays.contains(day);
                          return FilterChip(
                            label: Text(day.substring(0, 3)),
                            selected: isSelected,
                            onSelected: (sel) => setDialogState(() => sel ? selectedDays.add(day) : selectedDays.remove(day)),
                            selectedColor: const Color(0xFF0066CC),
                            labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFF1A237E), fontWeight: FontWeight.w600),
                            checkmarkColor: Colors.white,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      const Text('Working Hours', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A237E), fontFamily: 'Montserrat')),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: startTime,
                              decoration: InputDecoration(
                                labelText: 'Start',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)))).toList(),
                              onChanged: (v) => setDialogState(() => startTime = v),
                            ),
                          ),
                          const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('to', style: TextStyle(fontWeight: FontWeight.w600))),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: endTime,
                              decoration: InputDecoration(
                                labelText: 'End',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)))).toList(),
                              onChanged: (v) => setDialogState(() => endTime = v),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF666666))),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      _showSnackBar('Please enter doctor name', isError: true);
                      return;
                    }
                    if (selectedDays.isEmpty) {
                      _showSnackBar('Please select at least one available day', isError: true);
                      return;
                    }
                    final newDoctor = Doctor(
                      id: generatedId,
                      name: nameController.text.trim(),
                      specialty: selectedSpecialty,
                      description: descriptionController.text.trim(),
                      imageUrl: imageController.text.trim(),
                      email: emailController.text.trim(),
                      phone: phoneController.text.trim(),
                      password: defaultPassword,
                      consultationFee: double.tryParse(feeController.text) ?? 500,
                      availableDays: selectedDays.toList(),
                      availableTimes: [startTime ?? '09:00 AM', endTime ?? '04:00 PM'],
                    );
                    setState(() => _doctors.add(newDoctor));
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setStringList('doctorsData', _doctors.map((d) => d.encode()).toList());
                    Navigator.pop(ctx);
                    // Show credentials dialog
                    _showDoctorCredentialsDialog(newDoctor.name, generatedId, defaultPassword);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066CC),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Add Doctor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDoctorCredentialsDialog(String doctorName, String doctorId, String password) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 28),
            ),
            const SizedBox(width: 12),
            const Text('Doctor Added!', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A237E), fontSize: 20)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$doctorName has been added successfully.',
              style: const TextStyle(fontSize: 15, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F8FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF0066CC).withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Login Credentials',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A237E)),
                  ),
                  const SizedBox(height: 16),
                  _buildCredentialRow('Doctor ID', doctorId),
                  const SizedBox(height: 12),
                  _buildCredentialRow('Password', password),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.info_outline, color: Color(0xFFFF9800), size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Please share these credentials with the doctor securely.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              // Copy to clipboard simulation
              _showSnackBar('Credentials copied to clipboard!');
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copy'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0066CC),
              side: const BorderSide(color: Color(0xFF0066CC)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF666666))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0066CC).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0066CC), letterSpacing: 1),
          ),
        ),
      ],
    );
  }

  void _showEditDoctorDialog(Doctor doctor) {
    final nameController = TextEditingController(text: doctor.name);
    final descriptionController = TextEditingController(text: doctor.description);
    final imageController = TextEditingController(text: doctor.imageUrl);
    String selectedSpecialty = doctor.specialty.isEmpty ? 'General Practitioner' : doctor.specialty;
    final weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final selectedDays = Set<String>.from(doctor.availableDays);
    String? startTime = doctor.availableTimes.isNotEmpty ? doctor.availableTimes.first : '09:00 AM';
    String? endTime = doctor.availableTimes.length > 1 ? doctor.availableTimes[1] : '04:00 PM';
    final timeSlots = ['08:00 AM', '08:30 AM', '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM', '12:00 PM', '12:30 PM', '01:00 PM', '01:30 PM', '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM', '04:00 PM', '04:30 PM', '05:00 PM'];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0066CC).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.edit, color: Color(0xFF0066CC), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Edit Doctor', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, color: Color(0xFF1A237E), fontSize: 20))),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDialogTextField(nameController, 'Full Name', Icons.person, 'Dr. John Smith'),
                      const SizedBox(height: 16),
                      _buildDialogDropdown(
                        'Specialty',
                        Icons.medical_services,
                        selectedSpecialty,
                        _specialties.where((s) => s != 'All').toList(),
                        (val) => setDialogState(() => selectedSpecialty = val!),
                      ),
                      const SizedBox(height: 16),
                      _buildDialogTextField(descriptionController, 'Description', Icons.description, 'Brief bio...', maxLines: 2),
                      const SizedBox(height: 16),
                      const Text('Profile Image', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A237E), fontFamily: 'Montserrat')),
                      const SizedBox(height: 8),
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                          color: const Color(0xFFF5F8FF),
                        ),
                        child: imageController.text.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(imageController.text, fit: BoxFit.cover, width: double.infinity,
                                  errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey))),
                              )
                            : const Center(child: Icon(Icons.add_photo_alternate, size: 40, color: Color(0xFF0066CC))),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: imageController,
                        decoration: InputDecoration(
                          hintText: 'Image URL',
                          prefixIcon: const Icon(Icons.link, color: Color(0xFF0066CC)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),
                      const SizedBox(height: 20),
                      const Text('Available Days', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A237E), fontFamily: 'Montserrat')),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: weekdays.map((day) {
                          final isSelected = selectedDays.contains(day);
                          return FilterChip(
                            label: Text(day.substring(0, 3)),
                            selected: isSelected,
                            onSelected: (sel) => setDialogState(() => sel ? selectedDays.add(day) : selectedDays.remove(day)),
                            selectedColor: const Color(0xFF0066CC),
                            labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFF1A237E), fontWeight: FontWeight.w600),
                            checkmarkColor: Colors.white,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      const Text('Working Hours', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A237E), fontFamily: 'Montserrat')),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: startTime,
                              decoration: InputDecoration(
                                labelText: 'Start',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)))).toList(),
                              onChanged: (v) => setDialogState(() => startTime = v),
                            ),
                          ),
                          const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('to', style: TextStyle(fontWeight: FontWeight.w600))),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: endTime,
                              decoration: InputDecoration(
                                labelText: 'End',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)))).toList(),
                              onChanged: (v) => setDialogState(() => endTime = v),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF666666))),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      _showSnackBar('Please enter doctor name', isError: true);
                      return;
                    }
                    setState(() {
                      doctor.name = nameController.text.trim();
                      doctor.specialty = selectedSpecialty;
                      doctor.description = descriptionController.text.trim();
                      doctor.imageUrl = imageController.text.trim();
                      doctor.availableDays = selectedDays.toList();
                      doctor.availableTimes = [startTime ?? '09:00 AM', endTime ?? '04:00 PM'];
                    });
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setStringList('doctorsData', _doctors.map((d) => d.encode()).toList());
                    Navigator.pop(ctx);
                    _showSnackBar('Doctor updated successfully!');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066CC),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteDoctor(Doctor doctor) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFE53935).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.delete_forever, color: Color(0xFFE53935), size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Delete Doctor', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
          ],
        ),
        content: Text('Are you sure you want to delete ${doctor.name}? This will also remove all their appointments.', style: const TextStyle(fontFamily: 'Montserrat')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: Color(0xFF666666)))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _doctors.remove(doctor));
      final prefs = await SharedPreferences.getInstance();
      
      // Cascade delete bookings
      final rawBooked = prefs.getStringList('bookedAppointments') ?? [];
      final cleanedBooked = rawBooked.where((b) {
        final key = b.split('|').first;
        return key != doctor.id && key != doctor.name;
      }).toList();
      await prefs.setStringList('bookedAppointments', cleanedBooked);

      // Cascade delete user appointments
      final rawUser = prefs.getStringList('userAppointments') ?? [];
      final cleanedUser = rawUser.where((u) {
        final parts = u.split('|');
        if (parts.length < 2) return true;
        return parts[1] != doctor.id && parts[1] != doctor.name;
      }).toList();
      await prefs.setStringList('userAppointments', cleanedUser);

      await prefs.setStringList('doctorsData', _doctors.map((d) => d.encode()).toList());
      await _parseAppointments();
      _showSnackBar('Doctor deleted successfully');
    }
  }

  // ==================== APPOINTMENT OPERATIONS ====================

  Future<void> _cancelAppointment(Map<String, String> appointment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFFF9800).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.cancel, color: Color(0xFFFF9800), size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Cancel Appointment', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
          ],
        ),
        content: Text('Cancel appointment for ${appointment['patientName']} with ${appointment['doctorName']} on ${appointment['date']}?', style: const TextStyle(fontFamily: 'Montserrat')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep', style: TextStyle(color: Color(0xFF666666)))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
            child: const Text('Cancel Appointment', style: TextStyle(color: Colors.white)),
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

      // Remove from bookedAppointments
      final bookedKey = '${appointment['doctorId']}|${appointment['date']}|${appointment['time']}';
      final bookedList = prefs.getStringList('bookedAppointments') ?? [];
      bookedList.removeWhere((b) => b == bookedKey);
      await prefs.setStringList('bookedAppointments', bookedList);

      await _loadBookedAppointments();
      await _parseAppointments();
      _showSnackBar('Appointment cancelled');
    }
  }

  void _showAppointmentDetails(Map<String, String> appointment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFF0066CC).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.event, color: Color(0xFF0066CC), size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Appointment Details', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, color: Color(0xFF1A237E)))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow(Icons.person, 'Patient', appointment['patientName'] ?? ''),
            _buildDetailRow(Icons.email, 'Email', appointment['email'] ?? ''),
            _buildDetailRow(Icons.phone, 'Phone', appointment['phone'] ?? ''),
            const Divider(height: 24),
            _buildDetailRow(Icons.medical_services, 'Doctor', appointment['doctorName'] ?? ''),
            _buildDetailRow(Icons.category, 'Specialty', appointment['specialty'] ?? ''),
            const Divider(height: 24),
            _buildDetailRow(Icons.calendar_today, 'Date', appointment['date'] ?? ''),
            _buildDetailRow(Icons.access_time, 'Time', appointment['time'] ?? ''),
            _buildDetailRow(Icons.info, 'Status', appointment['status'] ?? ''),
            if ((appointment['notes'] ?? '').isNotEmpty) ...[
              const Divider(height: 24),
              _buildDetailRow(Icons.notes, 'Notes', appointment['notes'] ?? ''),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          if (appointment['status'] != 'Completed')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _cancelAppointment(appointment);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF0066CC)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF666666), fontFamily: 'Montserrat')),
                Text(value.isEmpty ? 'N/A' : value, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Montserrat')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HELPER METHODS ====================

  Widget _buildDialogTextField(TextEditingController controller, String label, IconData icon, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF0066CC)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDialogDropdown(String label, IconData icon, String value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : items.first,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0066CC)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: onChanged,
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error : Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(fontFamily: 'Montserrat'))),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFE53935) : const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.logout, color: Color(0xFFE53935)),
            SizedBox(width: 12),
            Text('Logout', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
          ],
        ),
        content: Text('Are you sure you want to logout? You will need to sign in again to access the admin panel.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text('Cancel', style: TextStyle(color: Color(0xFF666666))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE53935)),
            child: Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await prefs.remove('username');
      await prefs.remove('fullName');
      await prefs.remove('phoneNumber');
      await prefs.remove('userType');
      if (mounted) Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  int _getBookingCountForDoctor(Doctor doctor) {
    // Count from actual appointments (using Appointment model)
    return _appointments.where((apt) =>
      apt.doctorId == doctor.id || 
      apt.doctorName == doctor.name ||
      apt.doctorName.contains(doctor.name) ||
      doctor.name.contains(apt.doctorName)
    ).length;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _sidebarController.dispose();
    super.dispose();
  }

  // ==================== MAIN BUILD ====================

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
        final isMobile = constraints.maxWidth < 768;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F8FF),
          drawer: isMobile ? _buildSidebar(isMobile: true) : null,
          appBar: isMobile ? _buildMobileAppBar() : null,
          body: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF0066CC)))
              : Row(
                  children: [
                    if (!isMobile) _buildSidebar(isCollapsed: isTablet && !_isSidebarExpanded),
                    Expanded(
                      child: Column(
                        children: [
                          if (!isMobile) _buildHeader(),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.all(isMobile ? 16 : 24),
                              child: _buildMainContent(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF1A237E)),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0066CC).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.local_hospital, color: Color(0xFF0066CC), size: 20),
          ),
          const SizedBox(width: 12),
          const Text('Horizon Clinic Admin', style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.w700, fontFamily: 'Montserrat', fontSize: 18)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Color(0xFF0066CC)),
          onPressed: _initializeData,
        ),
      ],
    );
  }

  Widget _buildSidebar({bool isCollapsed = false, bool isMobile = false}) {
    final navItems = [
      {'icon': Icons.dashboard_rounded, 'label': 'Dashboard', 'index': 0},
      {'icon': Icons.medical_services_rounded, 'label': 'Doctors', 'index': 1},
      {'icon': Icons.calendar_month_rounded, 'label': 'Appointments', 'index': 2},
      {'icon': Icons.people_alt_rounded, 'label': 'Patients', 'index': 3},
      {'icon': Icons.analytics_rounded, 'label': 'Reports', 'index': 4},
      {'icon': Icons.settings_rounded, 'label': 'Settings', 'index': 5},
    ];

    final sidebarWidth = isCollapsed ? 80.0 : 280.0;

    final sidebarContent = Container(
      width: sidebarWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(4, 0))],
      ),
      child: Column(
        children: [
          // Logo Section with Gradient Background
          isCollapsed
            ? Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0091EA), Color(0xFF1565C0)])),
                child: Center(child: HorizonLogoIcon(size: 40, darkMode: true)),
              )
            : const HorizonBrandedHeader(showPortalLabel: true, portalLabel: 'Admin'),
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: navItems.map((item) {
                final isActive = _selectedNavIndex == item['index'];
                return Tooltip(
                  message: isCollapsed ? item['label'] as String : '',
                  child: InkWell(
                    onTap: () {
                      setState(() => _selectedNavIndex = item['index'] as int);
                      if (isMobile) Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.symmetric(horizontal: isCollapsed ? 8 : 16, vertical: 4),
                      padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 0 : 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF0066CC) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                        children: [
                          Icon(item['icon'] as IconData, color: isActive ? Colors.white : const Color(0xFF666666), size: 22),
                          if (!isCollapsed) ...[
                            const SizedBox(width: 14),
                            Text(
                              item['label'] as String,
                              style: TextStyle(
                                color: isActive ? Colors.white : const Color(0xFF1A237E),
                                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                fontFamily: 'Montserrat',
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Admin Profile
          Container(
            padding: EdgeInsets.all(isCollapsed ? 12 : 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8FF),
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: isCollapsed ? 18 : 22,
                  backgroundColor: const Color(0xFF0066CC),
                  child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Admin', style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Montserrat', color: Color(0xFF1A237E))),
                        Text('Administrator', style: TextStyle(fontSize: 12, color: Color(0xFF666666), fontFamily: 'Montserrat')),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Color(0xFFE53935), size: 20),
                    onPressed: _logout,
                    tooltip: 'Logout',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (isMobile) {
      return Drawer(child: sidebarContent);
    }
    return sidebarContent;
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final greeting = now.hour < 12 ? 'Good Morning' : (now.hour < 17 ? 'Good Afternoon' : 'Good Evening');
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$greeting, Admin!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1A237E), fontFamily: 'Montserrat')),
                const SizedBox(height: 4),
                Text(_getPageTitle(), style: const TextStyle(color: Color(0xFF666666), fontFamily: 'Montserrat')),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF0066CC)),
            onPressed: _initializeData,
            tooltip: 'Refresh Data',
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  String _getPageTitle() {
    switch (_selectedNavIndex) {
      case 0: return 'Overview of your clinic management';
      case 1: return 'Manage your medical staff';
      case 2: return 'View and manage appointments';
      case 3: return 'Registered users overview';
      case 4: return 'Analytics and reports';
      case 5: return 'System settings';
      default: return '';
    }
  }

  Widget _buildMainContent() {
    switch (_selectedNavIndex) {
      case 0: return _buildDashboardView();
      case 1: return _buildDoctorsView();
      case 2: return _buildAppointmentsView();
      case 3: return _buildUsersView();
      case 4: return _buildReportsView();
      case 5: return _buildSettingsView();
      default: return _buildDashboardView();
    }
  }

  // ==================== DASHBOARD VIEW ====================

  Widget _buildDashboardView() {
    final todayAppointments = _appointments.where((a) => a.isToday && a.status != 'cancelled').toList();
    final pendingAppointments = _appointments.where((a) => a.status == 'confirmed' || a.status == 'rescheduled').length;
    final completedAppointments = _appointments.where((a) => a.status == 'completed').length;
    final cancelledAppointments = _appointments.where((a) => a.status == 'cancelled').length;
    final noShowAppointments = _appointments.where((a) => a.status == 'no_show').length;
    
    // Calculate revenue only from completed and confirmed appointments (not cancelled/no-show)
    double totalRevenue = 0;
    for (final apt in _appointments) {
      if (apt.status == 'cancelled' || apt.status == 'no_show') continue;
      
      // Find the doctor's consultation fee
      final doctor = _doctors.where((d) => 
        d.id == apt.doctorId || 
        d.name.toLowerCase() == apt.doctorName.toLowerCase()
      ).firstOrNull;
      
      final fee = doctor?.consultationFee ?? 500.0; // Default fee if doctor not found
      totalRevenue += fee;
    }
    
    // Calculate actual revenue (completed only)
    double actualRevenue = 0;
    for (final apt in _appointments) {
      if (apt.status != 'completed') continue;
      final doctor = _doctors.where((d) => 
        d.id == apt.doctorId || 
        d.name.toLowerCase() == apt.doctorName.toLowerCase()
      ).firstOrNull;
      final fee = doctor?.consultationFee ?? 500.0;
      actualRevenue += fee;
    }
    
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
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: const Color(0xFF0066CC).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$greeting, Admin! 👋', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('Here\'s what\'s happening at Horizon Clinic today', style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.9))),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildMiniStat(Icons.calendar_today, '${todayAppointments.length}', 'Today'),
                        const SizedBox(width: 24),
                        _buildMiniStat(Icons.pending_actions, '$pendingAppointments', 'Pending'),
                        const SizedBox(width: 24),
                        _buildMiniStat(Icons.check_circle, '$completedAppointments', 'Completed'),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.local_hospital, color: Colors.white, size: 48),
                    const SizedBox(height: 8),
                    const Text('HORIZON', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 2)),
                    Text('CLINIC', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, letterSpacing: 3)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Stats Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.6,
              children: [
                _buildStatCard('Total Doctors', _doctors.length.toString(), Icons.medical_services_rounded, const Color(0xFF0066CC), 'Medical Staff', [const Color(0xFF0066CC), const Color(0xFF1976D2)]),
                _buildStatCard('Appointments', '${_appointments.length - cancelledAppointments}', Icons.calendar_month_rounded, const Color(0xFF4CAF50), '$completedAppointments completed, $pendingAppointments pending', [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]),
                _buildStatCard('Patients', _users.length.toString(), Icons.people_alt_rounded, const Color(0xFF9C27B0), 'Registered users', [const Color(0xFF9C27B0), const Color(0xFFBA68C8)]),
                _buildStatCard('Revenue', '₱${actualRevenue.toStringAsFixed(0)}', Icons.payments_rounded, const Color(0xFFFF9800), '₱${totalRevenue.toStringAsFixed(0)} expected', [const Color(0xFFFF9800), const Color(0xFFFFB74D)]),
              ],
            );
          },
        ),
        const SizedBox(height: 28),

        // Quick Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.more_horiz, size: 20),
              label: const Text('More'),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF666666)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildQuickActionButton('Add Doctor', Icons.person_add_rounded, const Color(0xFF0066CC), _showAddDoctorDialog),
            _buildQuickActionButton('New Appointment', Icons.add_box_rounded, const Color(0xFF4CAF50), () => setState(() => _selectedNavIndex = 2)),
            _buildQuickActionButton('Manage Patients', Icons.group_rounded, const Color(0xFF9C27B0), () => setState(() => _selectedNavIndex = 3)),
            _buildQuickActionButton('Analytics', Icons.insights_rounded, const Color(0xFFFF9800), () => setState(() => _selectedNavIndex = 4)),
          ],
        ),
        const SizedBox(height: 28),

        // Recent Activity & Today's Appointments
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 900) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildRecentActivityCard()),
                  const SizedBox(width: 24),
                  Expanded(child: _buildTodayAppointmentsCard(todayAppointments)),
                ],
              );
            }
            return Column(
              children: [
                _buildRecentActivityCard(),
                const SizedBox(height: 24),
                _buildTodayAppointmentsCard(todayAppointments),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildMiniStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle, [List<Color>? gradientColors]) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradientColors != null 
            ? LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight)
            : null,
        color: gradientColors == null ? Colors.white : null,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: (gradientColors?.first ?? color).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(gradientColors != null ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: gradientColors != null ? Colors.white : color, size: 26),
              ),
              Text(
                value, 
                style: TextStyle(
                  fontSize: 32, 
                  fontWeight: FontWeight.w800, 
                  color: gradientColors != null ? Colors.white : color,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, 
                style: TextStyle(
                  fontSize: 15, 
                  fontWeight: FontWeight.w700, 
                  color: gradientColors != null ? Colors.white : const Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle, 
                style: TextStyle(
                  fontSize: 12, 
                  color: gradientColors != null ? Colors.white.withOpacity(0.8) : const Color(0xFF666666),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontFamily: 'Montserrat')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    final recentAppointments = _appointments.take(5).toList();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A237E), fontFamily: 'Montserrat')),
              TextButton(onPressed: () => setState(() => _selectedNavIndex = 2), child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 16),
          if (recentAppointments.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No recent activity', style: TextStyle(color: Color(0xFF666666)))))
          else
            ...recentAppointments.map((apt) => _buildActivityItem(apt)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Appointment apt) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: Color(Appointment.getStatusColor(apt.status)).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.event, color: Color(Appointment.getStatusColor(apt.status)), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(apt.patientName, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Montserrat')),
                Text('with ${apt.doctorName}', style: const TextStyle(fontSize: 12, color: Color(0xFF666666), fontFamily: 'Montserrat')),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Color(Appointment.getStatusColor(apt.status)).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(Appointment.getStatusText(apt.status), style: TextStyle(color: Color(Appointment.getStatusColor(apt.status)), fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayAppointmentsCard(List<Appointment> todayAppointments) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Today's Appointments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A237E), fontFamily: 'Montserrat')),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF4CAF50), borderRadius: BorderRadius.circular(20)),
                child: Text('${todayAppointments.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (todayAppointments.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No appointments today', style: TextStyle(color: Color(0xFF666666)))))
          else
            ...todayAppointments.take(5).map((apt) => _buildTodayAppointmentItem(apt)),
        ],
      ),
    );
  }

  Widget _buildTodayAppointmentItem(Appointment apt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF0066CC), borderRadius: BorderRadius.circular(8)),
            child: Text(apt.time, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(apt.patientName, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Montserrat')),
                Text(apt.doctorName, style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.check_circle_outline, size: 20, color: Color(0xFF4CAF50)),
                onPressed: () => _markComplete(apt),
                tooltip: 'Mark Complete',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== DOCTORS VIEW ====================

  Widget _buildDoctorsView() {
    final filteredDoctors = _doctors.where((d) {
      final matchesSearch = _doctorSearchQuery.isEmpty || d.name.toLowerCase().contains(_doctorSearchQuery.toLowerCase()) || d.specialty.toLowerCase().contains(_doctorSearchQuery.toLowerCase());
      final matchesFilter = _selectedSpecialtyFilter == 'All' || d.specialty == _selectedSpecialtyFilter;
      return matchesSearch && matchesFilter;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Add Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Manage Doctors', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1A237E), fontFamily: 'Montserrat')),
            ElevatedButton.icon(
              onPressed: _showAddDoctorDialog,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add Doctor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066CC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Search and Filter
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                onChanged: (v) => setState(() => _doctorSearchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search doctors...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF666666)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSpecialtyFilter,
                    isExpanded: true,
                    items: _specialties.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => setState(() => _selectedSpecialtyFilter = v!),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Doctors Grid
        if (filteredDoctors.isEmpty)
          _buildEmptyState('No doctors found', Icons.people_outline)
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1000 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.4,
                ),
                itemCount: filteredDoctors.length,
                itemBuilder: (context, index) => _buildDoctorCard(filteredDoctors[index]),
              );
            },
          ),
      ],
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    final bookingCount = _getBookingCountForDoctor(doctor);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF0066CC).withOpacity(0.1),
                    backgroundImage: doctor.imageUrl.isNotEmpty ? NetworkImage(doctor.imageUrl) : null,
                    child: doctor.imageUrl.isEmpty ? Text(doctor.name.isNotEmpty ? doctor.name[0] : 'D', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF0066CC))) : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doctor.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A237E), fontFamily: 'Montserrat'), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFF0066CC).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text(doctor.specialty.isNotEmpty ? doctor.specialty : 'General', style: const TextStyle(fontSize: 11, color: Color(0xFF0066CC), fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 8),
                        if (doctor.availableDays.isNotEmpty)
                          Wrap(
                            spacing: 4,
                            children: doctor.availableDays.take(3).map((d) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFFF5F8FF), borderRadius: BorderRadius.circular(4)),
                              child: Text(d.substring(0, 3), style: const TextStyle(fontSize: 10, color: Color(0xFF666666))),
                            )).toList(),
                          ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.event, size: 14, color: Color(0xFF666666)),
                            const SizedBox(width: 4),
                            Text('$bookingCount bookings', style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8FF),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCardAction(Icons.edit, 'Edit', () => _showEditDoctorDialog(doctor)),
                _buildCardAction(Icons.delete, 'Delete', () => _deleteDoctor(doctor), isDestructive: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardAction(IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    final color = isDestructive ? const Color(0xFFE53935) : const Color(0xFF0066CC);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  // ==================== APPOINTMENTS VIEW ====================

  Widget _buildAppointmentsView() {
    final filteredAppointments = _appointments.where((apt) {
      if (_appointmentStatusFilter == 'All') return true;
      return apt.status == _appointmentStatusFilter.toLowerCase();
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Appointments', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1A237E), fontFamily: 'Montserrat')),
        const SizedBox(height: 24),

        // Status Filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'confirmed', 'rescheduled', 'cancelled', 'completed'].map((status) {
              final isActive = _appointmentStatusFilter == status;
              final count = status == 'All' ? _appointments.length : _appointments.where((a) => a.status == status).length;
              final displayLabel = status == 'All' ? 'All' : Appointment.getStatusText(status);
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilterChip(
                  label: Text('$displayLabel ($count)'),
                  selected: isActive,
                  onSelected: (_) => setState(() => _appointmentStatusFilter = status),
                  selectedColor: const Color(0xFF0066CC),
                  labelStyle: TextStyle(color: isActive ? Colors.white : const Color(0xFF1A237E), fontWeight: FontWeight.w600),
                  checkmarkColor: Colors.white,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),

        // Appointments List
        if (filteredAppointments.isEmpty)
          _buildEmptyState('No appointments found', Icons.calendar_today)
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredAppointments.length,
            itemBuilder: (context, index) => _buildAppointmentCardNew(filteredAppointments[index]),
          ),
      ],
    );
  }

  Widget _buildAppointmentCard(Map<String, String> appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: const Color(0xFF0066CC).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.person, color: Color(0xFF0066CC)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment['patientName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Montserrat')),
                const SizedBox(height: 4),
                Text('${appointment['doctorName']} • ${appointment['specialty']}', style: const TextStyle(color: Color(0xFF666666), fontSize: 13)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Color(0xFF666666)),
                    const SizedBox(width: 4),
                    Text(appointment['date'] ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time, size: 14, color: Color(0xFF666666)),
                    const SizedBox(width: 4),
                    Text(appointment['time'] ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStatusBadge(appointment['status'] ?? 'Pending'),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility, size: 20),
                    color: const Color(0xFF0066CC),
                    onPressed: () => _showAppointmentDetails(appointment),
                    tooltip: 'View Details',
                  ),
                  if (appointment['status'] != 'Completed')
                    IconButton(
                      icon: const Icon(Icons.cancel, size: 20),
                      color: const Color(0xFFE53935),
                      onPressed: () => _cancelAppointment(appointment),
                      tooltip: 'Cancel',
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCardNew(Appointment apt) {
    final statusColor = Color(Appointment.getStatusColor(apt.status));
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: const Color(0xFF0066CC).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.person, color: Color(0xFF0066CC)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(apt.patientName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Montserrat')),
                const SizedBox(height: 4),
                Text('${apt.doctorName} • ${apt.specialty}', style: const TextStyle(color: Color(0xFF666666), fontSize: 13)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Color(0xFF666666)),
                    const SizedBox(width: 4),
                    Text(apt.date, style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time, size: 14, color: Color(0xFF666666)),
                    const SizedBox(width: 4),
                    Text(apt.time, style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
                  ],
                ),
                if (apt.status == 'rescheduled' && apt.previousDate.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('Moved from: ${apt.previousDate} ${apt.previousTime}', style: const TextStyle(fontSize: 11, color: Color(0xFFFF9800), fontStyle: FontStyle.italic)),
                  ),
                if (apt.cancelReason.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('Reason: ${apt.cancelReason}', style: const TextStyle(fontSize: 11, color: Color(0xFFE53935))),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(Appointment.getStatusText(apt.status), style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 11)),
              ),
              const SizedBox(height: 8),
              if (apt.status == 'confirmed' || apt.status == 'rescheduled')
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_calendar, size: 20),
                      color: const Color(0xFFFF9800),
                      onPressed: () => _showRescheduleDialog(apt),
                      tooltip: 'Reschedule',
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, size: 20),
                      color: const Color(0xFFE53935),
                      onPressed: () => _showCancelDialog(apt),
                      tooltip: 'Cancel',
                    ),
                    IconButton(
                      icon: const Icon(Icons.check_circle, size: 20),
                      color: const Color(0xFF4CAF50),
                      onPressed: () => _markComplete(apt),
                      tooltip: 'Mark Complete',
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showRescheduleDialog(Appointment apt) async {
    DateTime? newDate;
    String? newTime;
    final reasonController = TextEditingController();
    final times = ['09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM', '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM', '04:00 PM', '04:30 PM'];

    final result = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(children: [
            Icon(Icons.edit_calendar, color: Color(0xFFFF9800)),
            SizedBox(width: 12),
            Text('Reschedule Appointment', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
          ]),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Patient: ${apt.patientName}', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('Current: ${apt.date} at ${apt.time}', style: TextStyle(color: Color(0xFF666666))),
                SizedBox(height: 16),
                Text('New Date:', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 60)),
                    );
                    if (picked != null) setDialogState(() => newDate = picked);
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(border: Border.all(color: Color(0xFFE0E0E0)), borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      Icon(Icons.calendar_today, color: Color(0xFF0066CC)),
                      SizedBox(width: 8),
                      Text(newDate != null ? '${newDate!.year}-${newDate!.month.toString().padLeft(2, '0')}-${newDate!.day.toString().padLeft(2, '0')}' : 'Select date'),
                    ]),
                  ),
                ),
                SizedBox(height: 16),
                Text('New Time:', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: times.map((t) => ChoiceChip(
                    label: Text(t),
                    selected: newTime == t,
                    onSelected: (s) { if (s) setDialogState(() => newTime = t); },
                    selectedColor: Color(0xFF0066CC),
                    labelStyle: TextStyle(color: newTime == t ? Colors.white : Colors.black),
                  )).toList(),
                ),
                SizedBox(height: 16),
                Text('Reason:', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Doctor schedule conflict',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: Text('Cancel')),
            ElevatedButton(
              onPressed: newDate != null && newTime != null ? () => Navigator.pop(c, true) : null,
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFF9800)),
              child: Text('Reschedule'),
            ),
          ],
        ),
      ),
    );

    if (result == true && newDate != null && newTime != null) {
      final dateStr = '${newDate!.year}-${newDate!.month.toString().padLeft(2, '0')}-${newDate!.day.toString().padLeft(2, '0')}';
      await AppointmentService.rescheduleAppointment(
        appointmentId: apt.id,
        newDate: dateStr,
        newTime: newTime!,
        reason: reasonController.text.isEmpty ? 'Schedule change' : reasonController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Appointment rescheduled! Patient will be notified.'), backgroundColor: Color(0xFF4CAF50)));
      await _parseAppointments();
    }
  }

  Future<void> _showCancelDialog(Appointment apt) async {
    final reasonController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Icon(Icons.cancel, color: Color(0xFFE53935)),
          SizedBox(width: 12),
          Text('Cancel Appointment', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cancel appointment for ${apt.patientName}?'),
            SizedBox(height: 8),
            Text('${apt.date} at ${apt.time} with ${apt.doctorName}', style: TextStyle(color: Color(0xFF666666))),
            SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Reason for cancellation',
                hintText: 'e.g., Doctor emergency',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text('Keep')),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE53935)),
            child: Text('Cancel Appointment'),
          ),
        ],
      ),
    );

    if (result == true) {
      await AppointmentService.cancelAppointment(
        appointmentId: apt.id,
        reason: reasonController.text.isEmpty ? 'Cancelled by admin' : reasonController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Appointment cancelled. Patient will be notified.'), backgroundColor: Color(0xFFE53935)));
      await _parseAppointments();
    }
  }

  Future<void> _markComplete(Appointment apt) async {
    await AppointmentService.completeAppointment(apt.id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Appointment marked as complete.'), backgroundColor: Color(0xFF4CAF50)));
    await _parseAppointments();
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Today': color = const Color(0xFF0066CC); break;
      case 'Upcoming': color = const Color(0xFF4CAF50); break;
      case 'Completed': color = const Color(0xFF666666); break;
      default: color = const Color(0xFFFF9800);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11)),
    );
  }

  // ==================== USERS VIEW ====================

  Widget _buildUsersView() {
    final filteredUsers = _users.where((u) {
      if (_userSearchQuery.isEmpty) return true;
      return (u['fullName'] ?? '').toLowerCase().contains(_userSearchQuery.toLowerCase()) ||
             (u['email'] ?? '').toLowerCase().contains(_userSearchQuery.toLowerCase());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Registered Users', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1A237E), fontFamily: 'Montserrat')),
        const SizedBox(height: 24),

        // Search
        TextField(
          onChanged: (v) => setState(() => _userSearchQuery = v),
          decoration: InputDecoration(
            hintText: 'Search users by name or email...',
            prefixIcon: const Icon(Icons.search, color: Color(0xFF666666)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 24),

        // Users Stats
        Row(
          children: [
            _buildUserMiniStat('Total Users', _users.length.toString(), Icons.people),
            const SizedBox(width: 16),
            _buildUserMiniStat('Active', _users.length.toString(), Icons.check_circle),
          ],
        ),
        const SizedBox(height: 24),

        // Users List
        if (filteredUsers.isEmpty)
          _buildEmptyState('No users found', Icons.person_outline)
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              final userAppointments = _appointments.where((a) => a.patientEmail == user['email']).length;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF0066CC).withOpacity(0.1),
                      child: Text((user['fullName'] ?? 'U')[0].toUpperCase(), style: const TextStyle(color: Color(0xFF0066CC), fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user['fullName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Montserrat')),
                          Text(user['email'] ?? '', style: const TextStyle(color: Color(0xFF666666), fontSize: 13)),
                          if ((user['phone'] ?? '').isNotEmpty)
                            Text(user['phone']!, style: const TextStyle(color: Color(0xFF666666), fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFF4CAF50).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: const Text('Active', style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.w600, fontSize: 11)),
                        ),
                        const SizedBox(height: 4),
                        Text('$userAppointments appointments', style: const TextStyle(color: Color(0xFF666666), fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildUserMiniStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0066CC)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
                Text(label, style: const TextStyle(color: Color(0xFF666666), fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== REPORTS VIEW ====================

  Widget _buildReportsView() {
    // Calculate statistics (excluding cancelled from active counts)
    final completedApts = _appointments.where((a) => a.status == 'completed').toList();
    final confirmedApts = _appointments.where((a) => a.status == 'confirmed' || a.status == 'rescheduled').toList();
    final cancelledApts = _appointments.where((a) => a.status == 'cancelled').toList();
    final noShowApts = _appointments.where((a) => a.status == 'no_show').toList();
    final activeApts = _appointments.where((a) => a.status != 'cancelled' && a.status != 'no_show').toList();
    
    // Specialty breakdown (exclude cancelled)
    final specialtyCounts = <String, int>{};
    final specialtyRevenue = <String, double>{};
    for (var apt in activeApts) {
      final specialty = apt.specialty.isNotEmpty ? apt.specialty : 'General';
      specialtyCounts[specialty] = (specialtyCounts[specialty] ?? 0) + 1;
      
      // Get doctor fee for this appointment
      final doctor = _doctors.where((d) => d.id == apt.doctorId || d.name.toLowerCase() == apt.doctorName.toLowerCase()).firstOrNull;
      final fee = doctor?.consultationFee ?? 500.0;
      specialtyRevenue[specialty] = (specialtyRevenue[specialty] ?? 0) + fee;
    }
    
    // Revenue calculations
    double actualRevenue = 0; // Completed only
    double expectedRevenue = 0; // Completed + Confirmed
    for (var apt in _appointments) {
      if (apt.status == 'cancelled' || apt.status == 'no_show') continue;
      final doctor = _doctors.where((d) => d.id == apt.doctorId || d.name.toLowerCase() == apt.doctorName.toLowerCase()).firstOrNull;
      final fee = doctor?.consultationFee ?? 500.0;
      expectedRevenue += fee;
      if (apt.status == 'completed') actualRevenue += fee;
    }
    
    // Calculate lost revenue from cancellations
    double lostRevenue = 0;
    for (var apt in cancelledApts) {
      final doctor = _doctors.where((d) => d.id == apt.doctorId || d.name.toLowerCase() == apt.doctorName.toLowerCase()).firstOrNull;
      lostRevenue += doctor?.consultationFee ?? 500.0;
    }
    
    // Success rate
    final totalProcessed = completedApts.length + cancelledApts.length + noShowApts.length;
    final successRate = totalProcessed > 0 ? (completedApts.length / totalProcessed * 100) : 0.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reports & Analytics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1A237E), fontFamily: 'Montserrat')),
          const SizedBox(height: 24),

          // Revenue Summary Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              final cardWidth = isWide ? (constraints.maxWidth - 48) / 4 : (constraints.maxWidth - 16) / 2;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(width: cardWidth, child: _buildReportCard('Actual Revenue', '₱${actualRevenue.toStringAsFixed(0)}', Icons.payments_rounded, const Color(0xFF4CAF50))),
                  SizedBox(width: cardWidth, child: _buildReportCard('Expected Revenue', '₱${expectedRevenue.toStringAsFixed(0)}', Icons.trending_up, const Color(0xFF0066CC))),
                  SizedBox(width: cardWidth, child: _buildReportCard('Lost Revenue', '₱${lostRevenue.toStringAsFixed(0)}', Icons.trending_down, const Color(0xFFE53935))),
                  SizedBox(width: cardWidth, child: _buildReportCard('Success Rate', '${successRate.toStringAsFixed(1)}%', Icons.verified, const Color(0xFFFF9800))),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Appointment Status Breakdown
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Appointment Status Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
                const SizedBox(height: 20),
                _buildStatusRow('Completed', completedApts.length, const Color(0xFF4CAF50), _appointments.length),
                _buildStatusRow('Confirmed/Pending', confirmedApts.length, const Color(0xFF0066CC), _appointments.length),
                _buildStatusRow('Cancelled', cancelledApts.length, const Color(0xFFE53935), _appointments.length),
                _buildStatusRow('No Show', noShowApts.length, const Color(0xFFFF9800), _appointments.length),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Two column layout for charts
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildSpecialtyBreakdown(specialtyCounts, activeApts.length)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildRevenueBySpecialty(specialtyRevenue)),
                  ],
                );
              }
              return Column(
                children: [
                  _buildSpecialtyBreakdown(specialtyCounts, activeApts.length),
                  const SizedBox(height: 24),
                  _buildRevenueBySpecialty(specialtyRevenue),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Top Performing Doctors (by completed appointments)
          _buildTopDoctorsCard(),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, int count, Color color, int total) {
    final percentage = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 8),
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              Text('$count (${(percentage * 100).toStringAsFixed(1)}%)', style: TextStyle(fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: percentage, backgroundColor: const Color(0xFFE0E0E0), valueColor: AlwaysStoppedAnimation(color), minHeight: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtyBreakdown(Map<String, int> specialtyCounts, int total) {
    final sortedEntries = specialtyCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bookings by Specialty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
          const SizedBox(height: 16),
          if (sortedEntries.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No active bookings', style: TextStyle(color: Color(0xFF666666)))))
          else
            ...sortedEntries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500))),
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: total > 0 ? e.value / total : 0,
                        backgroundColor: const Color(0xFFE0E0E0),
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF0066CC)),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(width: 40, child: Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A237E)), textAlign: TextAlign.right)),
                ],
              ),
            )).toList(),
        ],
      ),
    );
  }

  Widget _buildRevenueBySpecialty(Map<String, double> specialtyRevenue) {
    final sortedEntries = specialtyRevenue.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final maxRevenue = sortedEntries.isNotEmpty ? sortedEntries.first.value : 1.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Revenue by Specialty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
          const SizedBox(height: 16),
          if (sortedEntries.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No revenue data', style: TextStyle(color: Color(0xFF666666)))))
          else
            ...sortedEntries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500))),
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: e.value / maxRevenue,
                        backgroundColor: const Color(0xFFE0E0E0),
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF4CAF50)),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(width: 80, child: Text('₱${e.value.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF4CAF50)), textAlign: TextAlign.right)),
                ],
              ),
            )).toList(),
        ],
      ),
    );
  }

  Widget _buildTopDoctorsCard() {
    // Calculate completed appointments per doctor
    final doctorStats = <String, Map<String, dynamic>>{};
    for (var apt in _appointments) {
      if (apt.status == 'cancelled' || apt.status == 'no_show') continue;
      final key = apt.doctorId.isNotEmpty ? apt.doctorId : apt.doctorName;
      doctorStats[key] ??= {'completed': 0, 'total': 0, 'revenue': 0.0, 'name': apt.doctorName};
      doctorStats[key]!['total'] = (doctorStats[key]!['total'] as int) + 1;
      if (apt.status == 'completed') {
        doctorStats[key]!['completed'] = (doctorStats[key]!['completed'] as int) + 1;
        final doctor = _doctors.where((d) => d.id == apt.doctorId || d.name.toLowerCase() == apt.doctorName.toLowerCase()).firstOrNull;
        doctorStats[key]!['revenue'] = (doctorStats[key]!['revenue'] as double) + (doctor?.consultationFee ?? 500.0);
      }
    }
    
    final sortedDoctors = doctorStats.entries.toList()..sort((a, b) => (b.value['completed'] as int).compareTo(a.value['completed'] as int));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Performing Doctors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
          const Text('Ranked by completed appointments', style: TextStyle(fontSize: 12, color: Color(0xFF666666))),
          const SizedBox(height: 16),
          if (sortedDoctors.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No appointment data', style: TextStyle(color: Color(0xFF666666)))))
          else
            ...sortedDoctors.take(5).map((entry) {
              final stats = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFF0066CC).withOpacity(0.1),
                      child: Text((stats['name'] as String).isNotEmpty ? (stats['name'] as String)[0] : 'D', style: const TextStyle(color: Color(0xFF0066CC), fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(stats['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text('${stats['completed']} completed / ${stats['total']} total', style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFF4CAF50), borderRadius: BorderRadius.circular(20)),
                      child: Text('₱${(stats['revenue'] as double).toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildReportCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
              Text(title, style: const TextStyle(color: Color(0xFF666666), fontFamily: 'Montserrat')),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== SETTINGS VIEW ====================

  Widget _buildSettingsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1A237E), fontFamily: 'Montserrat')),
        const SizedBox(height: 24),

        // Clinic Information
        _buildSettingsSection('Clinic Information', [
          _buildSettingsItem('Clinic Name', 'Horizon Clinic Medical Center', Icons.local_hospital),
          _buildSettingsItem('Address', '123 Healthcare Street, Medical City', Icons.location_on),
          _buildSettingsItem('Contact', '+1 234 567 8900', Icons.phone),
          _buildSettingsItem('Email', 'admin@horizonclinic.com', Icons.email),
        ]),
        const SizedBox(height: 24),

        // Operating Hours
        _buildSettingsSection('Operating Hours', [
          _buildSettingsItem('Weekdays', '8:00 AM - 6:00 PM', Icons.access_time),
          _buildSettingsItem('Saturday', '9:00 AM - 4:00 PM', Icons.access_time),
          _buildSettingsItem('Sunday', 'Closed', Icons.access_time),
        ]),
        const SizedBox(height: 24),

        // System
        _buildSettingsSection('System', [
          _buildSettingsItem('Version', '1.0.0', Icons.info),
          _buildSettingsItem('Last Updated', DateTime.now().toString().split(' ')[0], Icons.update),
        ]),
        const SizedBox(height: 24),

        // Danger Zone
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE53935).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Danger Zone', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFFE53935), fontFamily: 'Montserrat')),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showClearDataDialog(),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Clear All Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A237E), fontFamily: 'Montserrat')),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildSettingsItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0066CC), size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF666666)))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A237E))),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Data?'),
        content: const Text('This will permanently delete all appointments and user data. Doctors will be reset to defaults. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('bookedAppointments');
              await prefs.remove('userAppointments');
              await prefs.remove('doctorsData');
              Navigator.pop(ctx);
              await _initializeData();
              _showSnackBar('All data cleared');
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
            child: const Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(icon, size: 64, color: const Color(0xFF1A237E).withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(message, style: TextStyle(fontSize: 16, color: const Color(0xFF1A237E).withOpacity(0.5), fontFamily: 'Montserrat')),
          ],
        ),
      ),
    );
  }
}
