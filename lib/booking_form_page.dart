import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/doctor.dart';
import 'services/appointment_service.dart';

class BookingFormPage extends StatefulWidget {
  @override
  _BookingFormPageState createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedDoctorId;
  String? _selectedDate;
  String? _selectedTime;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isAuthenticated = false; // Track auth status
  int _currentStep = 0;

  List<Doctor> _doctors = [];
  List<String> _bookedSlots = [];

  final List<String> _timeSlots = [
    '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM',
    '11:00 AM', '11:30 AM', '01:00 PM', '01:30 PM',
    '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM',
    '04:00 PM', '04:30 PM', '05:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if logged in FIRST
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      if (!isLoggedIn) {
        if (mounted) {
          setState(() {
            _isAuthenticated = false;
            _isLoading = false;
          });
        }
        return;
      }

      // User is authenticated
      _isAuthenticated = true;

      // Load user data
      _nameController.text = prefs.getString('fullName') ?? '';
      _emailController.text = prefs.getString('username') ?? '';
      _phoneController.text = prefs.getString('phoneNumber') ?? '';

      // Load doctors
      var doctorsList = prefs.getStringList('doctorsData') ?? [];
      if (doctorsList.isEmpty) {
        // Use same doctors as doctor_browse_page for consistency
        final defaults = [
          Doctor(id: 'dr1', name: 'Dr. Maria Santos', specialty: 'Pediatrician', imageUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400', availableDays: ['Monday', 'Wednesday', 'Friday'], availableTimes: ['09:00 AM', '05:00 PM']),
          Doctor(id: 'dr2', name: 'Dr. Juan Dela Cruz', specialty: 'Cardiologist', imageUrl: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400', availableDays: ['Tuesday', 'Thursday'], availableTimes: ['10:00 AM', '04:00 PM']),
          Doctor(id: 'dr3', name: 'Dr. Anna Reyes', specialty: 'Dermatologist', imageUrl: 'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=400', availableDays: ['Monday', 'Tuesday', 'Thursday'], availableTimes: ['09:00 AM', '03:00 PM']),
          Doctor(id: 'dr4', name: 'Dr. Roberto Garcia', specialty: 'OB-GYN', imageUrl: 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=400', availableDays: ['Wednesday', 'Friday'], availableTimes: ['08:00 AM', '04:00 PM']),
          Doctor(id: 'dr5', name: 'Dr. Elena Cruz', specialty: 'General Practitioner', imageUrl: 'https://images.unsplash.com/photo-1651008376811-b90baee60c1f?w=400', availableDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'], availableTimes: ['09:00 AM', '05:00 PM']),
          Doctor(id: 'dr6', name: 'Dr. Michael Tan', specialty: 'Neurologist', imageUrl: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400', availableDays: ['Monday', 'Thursday'], availableTimes: ['10:00 AM', '03:00 PM']),
        ];
        doctorsList = defaults.map((d) => d.encode()).toList();
        await prefs.setStringList('doctorsData', doctorsList);
      }

      _doctors = doctorsList.map((s) => Doctor.decode(s)).toList();
      _bookedSlots = await AppointmentService.getBookedSlots();

      // Check for pre-selected doctor from arguments
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map) {
        _selectedDoctorId = args['doctorId']?.toString();
      }

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showLoginRequired() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sign In Required',
          style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A237E)),
        ),
        content: Text(
          'Please sign in to book an appointment.',
          style: TextStyle(color: Color(0xFF666666)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(c);
              Navigator.pushReplacementNamed(context, '/signin');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0066CC)),
            child: Text('Sign In'),
          ),
        ],
      ),
    );
  }

  bool _isSlotBooked(String doctorId, String date, String time) {
    return _bookedSlots.contains('$doctorId|$date|$time');
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      // Validate personal info
      if (_nameController.text.isEmpty || _emailController.text.isEmpty || _phoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill in all personal information'),
            backgroundColor: Color(0xFFE53935),
          ),
        );
        return false;
      }
      if (!_emailController.text.contains('@')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid email address'),
            backgroundColor: Color(0xFFE53935),
          ),
        );
        return false;
      }
    } else if (_currentStep == 1) {
      // Validate doctor selection
      if (_selectedDoctorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a doctor'),
            backgroundColor: Color(0xFFFF9800),
          ),
        );
        return false;
      }
    } else if (_currentStep == 2) {
      // Validate date and time
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a date'),
            backgroundColor: Color(0xFFFF9800),
          ),
        );
        return false;
      }
      if (_selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a time slot'),
            backgroundColor: Color(0xFFFF9800),
          ),
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    // Specific validation for final step
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a date for your appointment'),
          backgroundColor: Color(0xFFFF9800),
        ),
      );
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a time slot'),
          backgroundColor: Color(0xFFFF9800),
        ),
      );
      return;
    }
    if (_selectedDoctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a doctor'),
          backgroundColor: Color(0xFFFF9800),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final doctor = _doctors.firstWhere((d) => d.id == _selectedDoctorId);

      // Check slot availability via service
      final isAvailable = await AppointmentService.isSlotAvailable(
        _selectedDoctorId!,
        _selectedDate!,
        _selectedTime!,
      );

      if (!isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('This slot was just booked. Please choose another time.'),
            backgroundColor: Color(0xFFFF9800),
          ),
        );
        setState(() => _isSaving = false);
        return;
      }

      // Create appointment using the service (auto-confirms + creates notification)
      await AppointmentService.createAppointment(
        patientName: _nameController.text,
        patientEmail: _emailController.text,
        patientPhone: _phoneController.text,
        doctorId: _selectedDoctorId!,
        doctorName: doctor.name,
        specialty: doctor.specialty,
        date: _selectedDate!,
        time: _selectedTime!,
        notes: _notesController.text,
      );

      if (mounted) {
        _showSuccessDialog(doctor);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSuccessDialog(Doctor doctor) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          padding: EdgeInsets.all(32),
          constraints: BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success animation
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF4CAF50).withOpacity(0.3),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(Icons.check_circle, color: Colors.white, size: 60),
              ),
              SizedBox(height: 24),
              Text(
                'Booking Confirmed! 🎉',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A237E),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Your appointment has been successfully scheduled',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              
              // Appointment summary
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFF8FAFF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Color(0xFF0066CC).withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    _summaryRow(Icons.person, 'Doctor', doctor.name),
                    Divider(height: 24),
                    _summaryRow(Icons.medical_services, 'Specialty', doctor.specialty),
                    Divider(height: 24),
                    _summaryRow(Icons.calendar_today, 'Date', _selectedDate!),
                    Divider(height: 24),
                    _summaryRow(Icons.access_time, 'Time', _selectedTime!),
                  ],
                ),
              ),
              SizedBox(height: 24),
              
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF0066CC), size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'A confirmation has been sent to your email',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0066CC),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(c);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0066CC),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF0066CC).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Color(0xFF0066CC)),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A237E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show login required screen if not authenticated
    if (!_isLoading && !_isAuthenticated) {
      return Scaffold(
        backgroundColor: Color(0xFFF5F8FF),
        body: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Color(0xFFE3F2FD),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lock_outline, size: 64, color: Color(0xFF0091EA)),
                ),
                SizedBox(height: 32),
                Text(
                  'Sign In Required',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A237E),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Please sign in to your account to book an appointment with our doctors.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/signin'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0091EA),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Sign In',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 14),
                      children: [
                        TextSpan(text: "Don't have an account? ", style: TextStyle(color: Color(0xFF666666))),
                        TextSpan(text: 'Sign Up', style: TextStyle(color: Color(0xFF0091EA), fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back),
                  label: Text('Go Back'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFF666666),
                    side: BorderSide(color: Color(0xFFE0E0E0)),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF5F8FF),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF0091EA)))
          : LayoutBuilder(
              builder: (context, constraints) {
                final bool isMobile = constraints.maxWidth < 768;

                return CustomScrollView(
                  slivers: [
                    // App Bar
                    SliverAppBar(
                      expandedHeight: isMobile ? 120 : 150,
                      floating: false,
                      pinned: true,
                      backgroundColor: Color(0xFF0066CC),
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          'Book Appointment',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: isMobile ? 18 : 22,
                          ),
                        ),
                        background: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0066CC), Color(0xFF1A237E)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Progress Indicator
                    SliverToBoxAdapter(
                      child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16 : 40,
                          vertical: 20,
                        ),
                        child: Row(
                          children: [
                            _buildStepIndicator(0, 'Personal', isMobile),
                            Expanded(child: _buildStepLine(0)),
                            _buildStepIndicator(1, 'Doctor', isMobile),
                            Expanded(child: _buildStepLine(1)),
                            _buildStepIndicator(2, 'Date & Time', isMobile),
                          ],
                        ),
                      ),
                    ),

                    // Form Content
                    SliverPadding(
                      padding: EdgeInsets.all(isMobile ? 16 : 40),
                      sliver: SliverToBoxAdapter(
                        child: FadeTransition(
                          opacity: _animationController,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 900),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Step 0: Personal Information
                                  if (_currentStep == 0) ...[
                                    _buildSectionCard(
                                      'Personal Information',
                                      Icons.person,
                                      Column(
                                        children: [
                                          _buildTextField(
                                            controller: _nameController,
                                            label: 'Full Name',
                                            hint: 'John Doe',
                                            icon: Icons.person_outline,
                                          ),
                                          SizedBox(height: 16),
                                          _buildTextField(
                                            controller: _emailController,
                                            label: 'Email Address',
                                            hint: 'john.doe@example.com',
                                            icon: Icons.email_outlined,
                                            keyboardType: TextInputType.emailAddress,
                                          ),
                                          SizedBox(height: 16),
                                          _buildTextField(
                                            controller: _phoneController,
                                            label: 'Phone Number',
                                            hint: '+63 XXX XXX XXXX',
                                            icon: Icons.phone_outlined,
                                            keyboardType: TextInputType.phone,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  // Step 1: Select Doctor
                                  if (_currentStep == 1) ...[
                                    _buildSectionCard(
                                      'Select Your Doctor',
                                      Icons.medical_services,
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Choose from our specialist doctors',
                                            style: TextStyle(
                                              color: Color(0xFF666666),
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          GridView.builder(
                                            shrinkWrap: true,
                                            physics: NeverScrollableScrollPhysics(),
                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: isMobile ? 1 : 2,
                                              crossAxisSpacing: 16,
                                              mainAxisSpacing: 16,
                                              childAspectRatio: isMobile ? 2.5 : 2.8,
                                            ),
                                            itemCount: _doctors.length,
                                            itemBuilder: (context, index) {
                                              final doctor = _doctors[index];
                                              final isSelected = _selectedDoctorId == doctor.id;
                                              return _buildDoctorCard(doctor, isSelected, isMobile);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  // Step 2: Date & Time
                                  if (_currentStep == 2) ...[
                                    _buildSectionCard(
                                      'Select Date & Time',
                                      Icons.calendar_month,
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Date',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1A237E),
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          InkWell(
                                            onTap: () async {
                                              // Get selected doctor's available days
                                              final doctor = _doctors.firstWhere(
                                                (d) => d.id == _selectedDoctorId,
                                                orElse: () => _doctors.first,
                                              );
                                              final availableDays = doctor.availableDays;
                                              
                                              // Map day names to weekday numbers
                                              final dayMap = {
                                                'Monday': DateTime.monday,
                                                'Tuesday': DateTime.tuesday,
                                                'Wednesday': DateTime.wednesday,
                                                'Thursday': DateTime.thursday,
                                                'Friday': DateTime.friday,
                                                'Saturday': DateTime.saturday,
                                                'Sunday': DateTime.sunday,
                                              };
                                              
                                              final allowedWeekdays = availableDays
                                                  .map((d) => dayMap[d])
                                                  .whereType<int>()
                                                  .toList();
                                              
                                              // Find first available date
                                              DateTime initialDate = DateTime.now().add(Duration(days: 1));
                                              while (!allowedWeekdays.contains(initialDate.weekday)) {
                                                initialDate = initialDate.add(Duration(days: 1));
                                              }
                                              
                                              final date = await showDatePicker(
                                                context: context,
                                                initialDate: initialDate,
                                                firstDate: DateTime.now(),
                                                lastDate: DateTime.now().add(Duration(days: 60)),
                                                selectableDayPredicate: (DateTime day) {
                                                  // Only allow doctor's available days
                                                  return allowedWeekdays.contains(day.weekday);
                                                },
                                                builder: (context, child) => Theme(
                                                  data: Theme.of(context).copyWith(
                                                    colorScheme: ColorScheme.light(
                                                      primary: Color(0xFF0066CC),
                                                    ),
                                                  ),
                                                  child: child!,
                                                ),
                                                helpText: 'Available: ${availableDays.join(", ")}',
                                              );
                                              if (date != null) {
                                                setState(() {
                                                  _selectedDate = date.toIso8601String().split('T')[0];
                                                  _selectedTime = null;
                                                });
                                              }
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: _selectedDate != null
                                                    ? Color(0xFF0066CC).withOpacity(0.1)
                                                    : Color(0xFFF8FAFF),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: _selectedDate != null
                                                      ? Color(0xFF0066CC)
                                                      : Color(0xFFE0E0E0),
                                                  width: 2,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.calendar_today,
                                                    color: Color(0xFF0066CC),
                                                  ),
                                                  SizedBox(width: 12),
                                                  Text(
                                                    _selectedDate ?? 'Choose a date',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: _selectedDate != null
                                                          ? FontWeight.w700
                                                          : FontWeight.w500,
                                                      color: _selectedDate != null
                                                          ? Color(0xFF1A237E)
                                                          : Color(0xFF666666),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 24),
                                          Text(
                                            'Time Slot',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1A237E),
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          Wrap(
                                            spacing: 12,
                                            runSpacing: 12,
                                            children: _timeSlots.map((time) {
                                              final booked = _selectedDoctorId != null &&
                                                  _selectedDate != null &&
                                                  _isSlotBooked(_selectedDoctorId!, _selectedDate!, time);
                                              final selected = _selectedTime == time;
                                              return _buildTimeChip(time, selected, booked);
                                            }).toList(),
                                          ),
                                          SizedBox(height: 24),
                                          Text(
                                            'Additional Notes (Optional)',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1A237E),
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          TextFormField(
                                            controller: _notesController,
                                            maxLines: 4,
                                            decoration: InputDecoration(
                                              hintText: 'Any specific concerns or notes...',
                                              hintStyle: TextStyle(color: Color(0xFFA0A0A0)),
                                              filled: true,
                                              fillColor: Color(0xFFF8FAFF),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(color: Color(0xFF0066CC), width: 2),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  SizedBox(height: 32),

                                  // Navigation Buttons
                                  Row(
                                    children: [
                                      if (_currentStep > 0)
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => setState(() => _currentStep--),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Color(0xFF0066CC),
                                              side: BorderSide(color: Color(0xFF0066CC), width: 2),
                                              padding: EdgeInsets.symmetric(vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                            ),
                                            child: Text(
                                              'Previous',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (_currentStep > 0) SizedBox(width: 16),
                                      Expanded(
                                        flex: _currentStep == 0 ? 1 : 1,
                                        child: ElevatedButton(
                                          onPressed: _isSaving
                                              ? null
                                              : () {
                                                  if (_currentStep < 2) {
                                                    if (_validateCurrentStep()) {
                                                      setState(() => _currentStep++);
                                                    }
                                                  } else {
                                                    if (_validateCurrentStep()) {
                                                      _submitBooking();
                                                    }
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF0066CC),
                                            padding: EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: _isSaving
                                              ? SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : Text(
                                                  _currentStep == 2 ? 'Confirm Booking' : 'Next',
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
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isMobile) {
    final isActive = _currentStep >= step;
    final isCompleted = _currentStep > step;

    return Column(
      children: [
        Container(
          width: isMobile ? 40 : 50,
          height: isMobile ? 40 : 50,
          decoration: BoxDecoration(
            color: isActive ? Color(0xFF0066CC) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? Color(0xFF0066CC) : Color(0xFFE0E0E0),
              width: 2,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Color(0xFF0066CC).withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, color: Colors.white, size: isMobile ? 20 : 24)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w700,
                      color: isActive ? Colors.white : Color(0xFFE0E0E0),
                    ),
                  ),
          ),
        ),
        SizedBox(height: 8),
        if (!isMobile)
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? Color(0xFF0066CC) : Color(0xFF666666),
            ),
          ),
      ],
    );
  }

  Widget _buildStepLine(int step) {
    final isActive = _currentStep > step;
    return Container(
      height: 2,
      margin: EdgeInsets.only(bottom: 30),
      color: isActive ? Color(0xFF0066CC) : Color(0xFFE0E0E0),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, Widget child) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF0066CC).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Color(0xFF0066CC), size: 24),
              ),
              SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A237E),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A237E),
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your $label';
            }
            if (label == 'Email Address' && !value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Color(0xFFA0A0A0)),
            prefixIcon: Icon(icon, color: Color(0xFF0066CC)),
            filled: true,
            fillColor: Color(0xFFF8FAFF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF0066CC), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE53935)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE53935), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard(Doctor doctor, bool isSelected, bool isMobile) {
    return InkWell(
      onTap: () => setState(() => _selectedDoctorId = doctor.id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF0066CC).withOpacity(0.1) : Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Color(0xFF0066CC) : Color(0xFFE0E0E0),
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Color(0xFF0066CC).withOpacity(0.2),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: isMobile ? 60 : 70,
              height: isMobile ? 60 : 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(doctor.imageUrl),
                  fit: BoxFit.cover,
                ),
                border: Border.all(
                  color: isSelected ? Color(0xFF0066CC) : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    doctor.name,
                    style: TextStyle(
                      fontSize: isMobile ? 15 : 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    doctor.specialty,
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 14,
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Color(0xFF0066CC),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          doctor.availableDays.take(2).join(', '),
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF666666),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF0066CC),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeChip(String time, bool selected, bool booked) {
    return InkWell(
      onTap: booked ? null : () => setState(() => _selectedTime = time),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: booked
              ? Color(0xFFE0E0E0)
              : selected
                  ? Color(0xFF0066CC)
                  : Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: booked
                ? Color(0xFFBDBDBD)
                : selected
                    ? Color(0xFF0066CC)
                    : Color(0xFFE0E0E0),
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Text(
          time,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: booked
                ? Color(0xFF9E9E9E)
                : selected
                    ? Colors.white
                    : Color(0xFF1A237E),
            decoration: booked ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}