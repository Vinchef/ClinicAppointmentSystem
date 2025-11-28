import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/doctor.dart';

class BookingFormPage extends StatefulWidget {
  @override
  _BookingFormPageState createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _formKey = GlobalKey<FormState>();
  String? _selectedDoctorId; // stores doctor.id
  String? _selectedDoctorName; // for display
  String? _name;
  String? _selectedDate;
  String? _selectedTime;
  bool _buttonHovered = false;
  List<String> _bookedSlots = [];
  List<Doctor> _doctors = [];
  final List<String> _times = ['09:00 AM', '10:00 AM', '11:00 AM', '02:00 PM', '03:00 PM', '04:00 PM'];

  int _timeStringToMinutes(String t) {
    // format: HH:MM AM/PM
    try {
      final parts = t.split(' ');
      if (parts.length != 2) return 0;
      final time = parts[0];
      final ampm = parts[1];
      final hhmm = time.split(':');
      int hh = int.parse(hhmm[0]);
      final mm = int.parse(hhmm[1]);
      if (ampm.toUpperCase() == 'PM' && hh != 12) hh += 12;
      if (ampm.toUpperCase() == 'AM' && hh == 12) hh = 0;
      return hh * 60 + mm;
    } catch (e) {
      return 0;
    }
  }

  List<String> _timesInRange(List<String> allTimes, String start, String end) {
    final s = _timeStringToMinutes(start);
    final e = _timeStringToMinutes(end);
    if (s >= e) return allTimes.where((t) => true).toList();
    return allTimes.where((t) {
      final m = _timeStringToMinutes(t);
      return m >= s && m <= e;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _animationController.forward();
    _loadDoctors().then((_) => _loadBookedSlots());
    _checkLoginStatus();
    // If opened with an argument specifying doctorId, preselect below in build via ModalRoute
  }

  Future<void> _loadDoctors() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('doctorsData') ?? [];
    setState(() {
      _doctors = list.map((s) => Doctor.decode(s)).toList();
    });
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    if (!isLoggedIn && mounted) {
      _showLoginRequiredDialog();
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          title: const Text('Sign In Required', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
          content: const Text('You need to sign in before booking an appointment. Please log in with your credentials.', style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFF3949AB))),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/signin');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Go to Sign In', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadBookedSlots() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('bookedAppointments') ?? [];
    // Attempt migration: if slot starts with doctor name, replace with doctor.id when possible
    final migrated = <String>[];
    for (final slot in raw) {
      final parts = slot.split('|');
      if (parts.length < 3) continue;
      final first = parts[0];
      final date = parts[1];
      final time = parts[2];

      // If already an id that matches a doctor, keep
      final byId = _doctors.where((d) => d.id == first).toList();
      if (byId.isNotEmpty) {
        migrated.add(slot);
        continue;
      }

      // Otherwise try to find by name and migrate
      final byName = _doctors.where((d) => d.name == first).toList();
      if (byName.isNotEmpty) {
        migrated.add('${byName.first.id}|$date|$time');
      } else {
        // keep original if we can't resolve
        migrated.add(slot);
      }
    }

    await prefs.setStringList('bookedAppointments', migrated);
    setState(() {
      _bookedSlots = migrated;
    });
  }

  bool _isSlotBooked(String doctorId, String date, String time) {
    final slotById = '$doctorId|$date|$time';
    // Also accept legacy name-based entries for compatibility
    final doctorName = _doctors.firstWhere((d) => d.id == doctorId, orElse: () => Doctor(name: '', id: '')).name;
    final slotByName = '$doctorName|$date|$time';
    return _bookedSlots.contains(slotById) || _bookedSlots.contains(slotByName);
  }

  Future<void> _saveBooking() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Check if slot is already booked
      if (_selectedDoctorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a doctor')));
        return;
      }
      if (_isSlotBooked(_selectedDoctorId!, _selectedDate!, _selectedTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('This time slot is already booked. Please choose another time.', style: TextStyle(fontFamily: 'Montserrat')),
            backgroundColor: const Color(0xFFE53935),
          ),
        );
        return;
      }

      _showConfirmationDialog();
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          title: const Text('Confirm Booking', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ConfirmationField(label: 'Name:', value: _name ?? ''),
              _ConfirmationField(label: 'Doctor:', value: _selectedDoctorName ?? (_doctors.firstWhere((d) => d.id == (_selectedDoctorId ?? ''), orElse: () => Doctor(name: '', id: '')).name)),
              _ConfirmationField(label: 'Date:', value: _selectedDate ?? ''),
              _ConfirmationField(label: 'Time:', value: _selectedTime ?? ''),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFFE53935), fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                
                // Save booking (use doctorId|date|time)
                final prefs = await SharedPreferences.getInstance();
                final slotKey = '${_selectedDoctorId!}|${_selectedDate!}|${_selectedTime!}';
                _bookedSlots.add(slotKey);
                await prefs.setStringList('bookedAppointments', _bookedSlots);

                // Also save appointment details (store doctor id for robustness)
                List<String> appointments = prefs.getStringList('userAppointments') ?? [];
                String appointmentDetails = '$_name|${_selectedDoctorId!}|$_selectedDate|$_selectedTime';
                appointments.add(appointmentDetails);
                await prefs.setStringList('userAppointments', appointments);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$_name, your appointment is confirmed!', style: const TextStyle(fontFamily: 'Montserrat')),
                      backgroundColor: const Color(0xFF1A237E),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  await Future.delayed(const Duration(milliseconds: 500));
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Confirm', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Handle optional route arguments for pre-selecting a doctor
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map && _selectedDoctorId == null) {
      try {
        final doctorId = args['doctorId']?.toString();
        final doctorName = args['doctorName']?.toString();
        if (doctorId != null) {
          _selectedDoctorId = doctorId;
          _selectedDoctorName = doctorName ?? _doctors.firstWhere((d) => d.id == doctorId, orElse: () => Doctor(name: '', id: '')).name;
        }
      } catch (e) {
        // ignore
      }
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text('Book Your Appointment', style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontFamily: 'Montserrat', fontSize: 22)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
            child: FadeTransition(
              opacity: _animationController.drive(Tween(begin: 0.0, end: 1.0)),
              child: SlideTransition(
                position: _animationController.drive(Tween(begin: const Offset(0, 0.2), end: Offset.zero)),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 8,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Appointment Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A237E), fontFamily: 'Montserrat')),
                          const SizedBox(height: 24),
                          // DATE & TIME DISPLAY SECTION
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3EAFD),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF1A237E), width: 2),
                            ),
                            child: Column(
                              children: [
                                const Text('Selected Date & Time', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A237E), fontFamily: 'Montserrat')),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        const Icon(Icons.calendar_today, color: Color(0xFF1A237E), size: 28),
                                        const SizedBox(height: 8),
                                        Text(
                                          _selectedDate ?? 'Not selected',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: _selectedDate != null ? const Color(0xFF1A237E) : const Color(0xFFA0A0A0),
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(width: 1, height: 40, color: const Color(0xFF1A237E).withOpacity(0.2)),
                                    Column(
                                      children: [
                                        const Icon(Icons.schedule, color: Color(0xFF1A237E), size: 28),
                                        const SizedBox(height: 8),
                                        Text(
                                          _selectedTime ?? 'Not selected',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: _selectedTime != null ? const Color(0xFF1A237E) : const Color(0xFFA0A0A0),
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // FORM FIELDS
                          _AnimatedFormField(
                            label: 'Full Name',
                            labelText: 'Name',
                            icon: Icons.person,
                            validator: (value) => value == null || value.isEmpty ? 'Enter your name' : null,
                            onSaved: (value) => _name = value,
                          ),
                          const SizedBox(height: 16),
                          // Build list of doctor names filtered by selected date availability (if any)
                          Builder(builder: (context) {
                            String? weekdayName;
                            if (_selectedDate != null) {
                              try {
                                final parts = _selectedDate!.split('-');
                                final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
                                const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
                                weekdayName = names[dt.weekday - 1];
                              } catch (e) {
                                weekdayName = null;
                              }
                            }

                            final doctorNames = _doctors.where((d) {
                              if (_selectedDate == null) return true;
                              if (d.availableDates.contains(_selectedDate)) return true;
                              if (weekdayName != null && d.availableDays.contains(weekdayName)) return true;
                              return false;
                            }).map((d) => d.name).toList();

                            return _AnimatedDropdownField(
                              label: 'Select Doctor',
                              value: _selectedDoctorName,
                              items: doctorNames,
                              onChanged: (value) => setState(() {
                                _selectedDoctorName = value;
                                final found = _doctors.where((d) => d.name == value).toList();
                                _selectedDoctorId = found.isNotEmpty ? found.first.id : null;
                                _selectedTime = null; // reset selected time when doctor changes
                              }),
                              validator: (value) => value == null ? 'Select a doctor' : null,
                            );
                          }),
                          const SizedBox(height: 16),
                          _AnimatedDatePicker(
                            label: 'Select Date',
                            value: _selectedDate,
                            onChanged: (date) => setState(() => _selectedDate = date),
                          ),
                          const SizedBox(height: 16),
                          // Compute times allowed for selected doctor using their availableTimes range (if set)
                          Builder(builder: (context) {
                            List<String> timesForDoctor = _times;
                            if (_selectedDoctorId != null) {
                              final matches = _doctors.where((d) => d.id == _selectedDoctorId).toList();
                              if (matches.isNotEmpty) {
                                final doc = matches.first;
                                if (doc.availableTimes.length >= 2) {
                                  timesForDoctor = _timesInRange(_times, doc.availableTimes.first, doc.availableTimes[1]);
                                }
                              }
                            }

                            return _AnimatedTimeDropdown(
                              label: 'Select Time',
                              value: _selectedTime,
                              items: timesForDoctor,
                              doctor: _selectedDoctorId,
                              doctorName: _selectedDoctorName,
                              selectedDate: _selectedDate,
                              bookedSlots: _bookedSlots,
                              onChanged: (value) => setState(() => _selectedTime = value),
                              validator: (value) => value == null ? 'Select a time' : null,
                            );
                          }),
                          const SizedBox(height: 32),
                          MouseRegion(
                            onEnter: (_) => setState(() => _buttonHovered = true),
                            onExit: (_) => setState(() => _buttonHovered = false),
                            cursor: SystemMouseCursors.click,
                            child: AnimatedScale(
                              scale: _buttonHovered ? 1.02 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _saveBooking,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1A237E),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: _buttonHovered ? 8 : 4,
                                  ),
                                  child: const Text('Confirm Booking', style: TextStyle(fontSize: 16, fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF1A237E),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: Color(0xFF1A237E), width: 2),
                                ),
                              ),
                              child: const Text('Cancel', style: TextStyle(fontSize: 16, fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedFormField extends StatefulWidget {
  final String label;
  final String labelText;
  final IconData icon;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;

  const _AnimatedFormField({
    required this.label,
    required this.labelText,
    required this.icon,
    this.validator,
    this.onSaved,
  });

  @override
  State<_AnimatedFormField> createState() => _AnimatedFormFieldState();
}

class _AnimatedFormFieldState extends State<_AnimatedFormField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3949AB), fontFamily: 'Montserrat')),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isFocused ? [BoxShadow(color: const Color(0xFF1A237E).withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 1))],
          ),
          child: Focus(
            onFocusChange: (isFocused) => setState(() => _isFocused = isFocused),
            child: TextFormField(
              decoration: InputDecoration(
                prefixIcon: Icon(widget.icon, color: _isFocused ? const Color(0xFF1A237E) : const Color(0xFF3949AB)),
                labelText: widget.labelText,
                labelStyle: const TextStyle(color: Color(0xFF3949AB), fontFamily: 'Montserrat'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                fillColor: _isFocused ? const Color(0xFFF0F4FF) : Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2)),
                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE53935))),
              ),
              style: const TextStyle(fontFamily: 'Montserrat'),
              validator: widget.validator,
              onSaved: widget.onSaved,
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;

  const _AnimatedDropdownField({
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3949AB), fontFamily: 'Montserrat')),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 1))],
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontFamily: 'Montserrat')))).toList(),
            onChanged: onChanged,
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.local_hospital, color: Color(0xFF3949AB)),
              labelText: 'Choose Doctor',
              labelStyle: const TextStyle(color: Color(0xFF3949AB), fontFamily: 'Montserrat'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              fillColor: Colors.white,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2)),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedDatePicker extends StatelessWidget {
  final String label;
  final String? value;
  final void Function(String?)? onChanged;

  const _AnimatedDatePicker({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3949AB), fontFamily: 'Montserrat')),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 1))]),
          child: TextField(
            readOnly: true,
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 60)),
                builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF1A237E), secondary: Color(0xFF3949AB))), child: child!),
              );
              if (pickedDate != null) {
                onChanged?.call('${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}');
              }
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF3949AB)),
              hintText: value ?? 'Select a date',
              hintStyle: const TextStyle(color: Color(0xFFA0A0A0), fontFamily: 'Montserrat'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              fillColor: Colors.white,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2)),
            ),
            style: const TextStyle(fontFamily: 'Montserrat'),
          ),
        ),
      ],
    );
  }
}

class _AnimatedTimeDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final String? doctor;
  final String? doctorName;
  final String? selectedDate;
  final List<String> bookedSlots;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;

  const _AnimatedTimeDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.doctor,
    this.doctorName,
    required this.selectedDate,
    required this.bookedSlots,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    List<String> availableTimes = items.where((time) {
      final byId = '$doctor|$selectedDate|$time';
      final byName = doctorName != null ? '${doctorName}|$selectedDate|$time' : '';
      return !bookedSlots.contains(byId) && (doctorName == null || !bookedSlots.contains(byName));
    }).toList();

    // Ensure the dropdown value is one of the available times; otherwise present null
    final String? selectedValue = (value != null && availableTimes.contains(value)) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3949AB), fontFamily: 'Montserrat')),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 1))]),
          child: DropdownButtonFormField<String>(
            value: selectedValue,
            items: availableTimes.isEmpty
                ? [const DropdownMenuItem(value: null, child: Text('No available times', style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFFE53935))))]
                : availableTimes.map((time) => DropdownMenuItem(value: time, child: Text(time, style: const TextStyle(fontFamily: 'Montserrat')))).toList(),
            onChanged: availableTimes.isEmpty ? null : onChanged,
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.schedule, color: Color(0xFF3949AB)),
              labelText: 'Choose Time',
              labelStyle: const TextStyle(color: Color(0xFF3949AB), fontFamily: 'Montserrat'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              fillColor: Colors.white,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2)),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfirmationField extends StatelessWidget {
  final String label;
  final String value;

  const _ConfirmationField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF3949AB), fontFamily: 'Montserrat')),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(color: Color(0xFF1A237E), fontFamily: 'Montserrat'))),
        ],
      ),
    );
  }
}
