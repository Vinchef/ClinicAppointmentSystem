
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/doctor.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _selectedTabIndex = 0;
  List<Doctor> _doctors = [
    Doctor(
      name: 'Dr. Khaled Almatrook',
      specialty: 'Pediatrician',
      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTtnGZakFUDorHSis3TuThW8LgEBdbNCFYMw4K8g4YwsUc5zvzvnWtIiiDO_JsGw5M6vjgK862Sgf4c_k4BKTVjIC9GDi6-dVG4avV99Tsl&s=10',
      availableDays: ['Monday', 'Tuesday', 'Wednesday'],
      availableTimes: ['09:00 AM', '04:00 PM'],
    ),
    Doctor(
      name: 'Dr. Ahmed Al-Khaldi',
      specialty: 'Dermatologist',
      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRsj0W-Epmj4Zf2mnWcAO8g5STA33HqPQvm3QRi4AKUznpjhAQyKvar-PyHayDZjNvOwGrpVArK6eeNyhuRuDQMipyGohGTXD5sBT95ZwQuyw&s=10',
      availableDays: ['Monday', 'Tuesday', 'Wednesday'],
      availableTimes: ['09:00 AM', '04:00 PM'],
    ),
    Doctor(
      name: 'Dr. Youssef Al-Mohannadi',
      specialty: 'Pediatrician',
      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSdNmEnEZXfZTdQr3m93QPdj14GxsAgpcuLM5eUxNuSfw9HtQqwGL5GScVBMQCAVO2LUH45OATpDXaN4I81CDazH_7Gj2AwnoOYneL2RnPXXg&s=10',
      availableDays: ['Monday', 'Tuesday', 'Wednesday'],
      availableTimes: ['09:00 AM', '04:00 PM'],
    ),
    Doctor(
      name: 'Dr. Hassan Al-Thani',
      specialty: 'Neurologist',
      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR1kV5c0YYdhhRCUPzNSTLaJL8xFo1AGrKEv9AFcocGfnXXbJgEABTEaz2nRFaPtP6uNwn_QtYveyGcpoVvV_S7-NnPpZRl7zRszG1vo_yoKg&s=10',
      availableDays: ['Monday', 'Tuesday', 'Wednesday'],
      availableTimes: ['09:00 AM', '04:00 PM'],
    ),
  ];
  List<String> _bookedAppointments = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _animationController.forward();
    _loadDoctors().then((_) => _loadBookedAppointments());
  }

  Future<void> _loadDoctors() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('doctorsData');
    if (saved != null && saved.isNotEmpty) {
      setState(() {
        _doctors = saved.map((s) => Doctor.decode(s)).toList();
      });
    } else {
      // migrate legacy simple list if present
      final legacy = prefs.getStringList('doctors') ?? [];
      if (legacy.isNotEmpty) {
        setState(() {
          _doctors = legacy.map((name) => Doctor(name: name)).toList();
        });
        await prefs.setStringList('doctorsData', _doctors.map((d) => d.encode()).toList());
      }
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
        migrated.add(slot);
      }
    }

    await prefs.setStringList('bookedAppointments', migrated);
    setState(() {
      _bookedAppointments = migrated;
    });
  }

  void _addDoctor() {
    final nameController = TextEditingController();
    final specialtyController = TextEditingController();
    final imageController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add New Doctor', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(hintText: 'Enter doctor name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: specialtyController,
                  decoration: InputDecoration(hintText: 'Specialty (e.g. Cardiologist)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: imageController,
                  decoration: InputDecoration(hintText: 'Image URL (optional)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                                  final newDoctor = Doctor(name: nameController.text.trim(), specialty: specialtyController.text.trim(), imageUrl: imageController.text.trim());
                  setState(() {
                    _doctors.add(newDoctor);
                  });
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setStringList('doctorsData', _doctors.map((d) => d.encode()).toList());
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E)),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _editDoctorSchedule(Doctor doctor) {
    final schedule = DoctorSchedule(availableDates: doctor.availableDates, availableTimes: doctor.availableTimes);
    
    // Available times list
    final timeSlots = ['09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM', '12:00 PM', '12:30 PM', '01:00 PM', '01:30 PM', '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM', '04:00 PM'];
    final datesList = List.generate(30, (i) => DateTime.now().add(Duration(days: i+1)).toString().split(' ')[0]).toList();
    
    String? selectedStartDate = schedule.availableDates.isNotEmpty ? schedule.availableDates.first : null;
    String? selectedEndDate = schedule.availableDates.isNotEmpty ? schedule.availableDates.last : null;
    String? selectedStartTime = schedule.availableTimes.isNotEmpty ? schedule.availableTimes.first : null;
    String? selectedEndTime = schedule.availableTimes.isNotEmpty ? schedule.availableTimes.last : null;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Edit ${doctor.name} Schedule', style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Available Date Range:', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text('Start Date', style: TextStyle(fontSize: 12)),
                            value: selectedStartDate,
                            items: datesList.map((date) => DropdownMenuItem(value: date, child: Text(date, style: const TextStyle(fontSize: 12)))).toList(),
                            onChanged: (value) => setState(() => selectedStartDate = value),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text('End Date', style: TextStyle(fontSize: 12)),
                            value: selectedEndDate,
                            items: datesList.map((date) => DropdownMenuItem(value: date, child: Text(date, style: const TextStyle(fontSize: 12)))).toList(),
                            onChanged: (value) => setState(() => selectedEndDate = value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Select Available Time Range:', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text('Start Time', style: TextStyle(fontSize: 12)),
                            value: selectedStartTime,
                            items: timeSlots.map((time) => DropdownMenuItem(value: time, child: Text(time, style: const TextStyle(fontSize: 12)))).toList(),
                            onChanged: (value) => setState(() => selectedStartTime = value),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text('End Time', style: TextStyle(fontSize: 12)),
                            value: selectedEndTime,
                            items: timeSlots.map((time) => DropdownMenuItem(value: time, child: Text(time, style: const TextStyle(fontSize: 12)))).toList(),
                            onChanged: (value) => setState(() => selectedEndTime = value),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                        if (selectedStartDate != null && selectedEndDate != null && selectedStartTime != null && selectedEndTime != null) {
                          // validate times: start != end and end after start
                          final s = _timeStringToMinutes(selectedStartTime!);
                          final e = _timeStringToMinutes(selectedEndTime!);
                          if (s == e) {
                            // show simple alert
                            await showDialog(context: context, builder: (c) => AlertDialog(title: const Text('Invalid Time Range'), content: const Text('Start and end times cannot be the same.'), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))]));
                            return;
                          }
                          if (e < s) {
                            await showDialog(context: context, builder: (c) => AlertDialog(title: const Text('Invalid Time Range'), content: const Text('End time must be after start time.'), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))]));
                            return;
                          }

                          this.setState(() {
                            doctor.availableDates = [selectedStartDate!, selectedEndDate!];
                            doctor.availableTimes = [selectedStartTime!, selectedEndTime!];
                          });

                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setStringList('doctorsData', _doctors.map((d) => d.encode()).toList());

                          Navigator.pop(context);
                        }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E)),
                  child: const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  int _timeStringToMinutes(String time) {
    // expects format like '09:30 AM' or '12:00 PM'
    try {
      final parts = time.split(' ');
      if (parts.length != 2) return 0;
      final hm = parts[0].split(':');
      final hour = int.tryParse(hm[0]) ?? 0;
      final minute = int.tryParse(hm[1]) ?? 0;
      final ampm = parts[1].toUpperCase();
      var h = hour % 12;
      if (ampm == 'PM') h += 12;
      return h * 60 + minute;
    } catch (_) {
      return 0;
    }
  }

  int _getBookingCountForDoctor(Doctor doctor) {
    return _bookedAppointments.where((booking) {
      final key = booking.split('|').first;
      return key == doctor.id || key == doctor.name;
    }).length;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        automaticallyImplyLeading: false,
        title: const Text('Admin Dashboard', style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontFamily: 'Montserrat', fontSize: 24)),
        centerTitle: true,
        actions: [
          Padding(padding: const EdgeInsets.all(16.0), child: Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF1A237E).withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: const Text('Admin', style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontFamily: 'Montserrat')))))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeTransition(
                opacity: _animationController.drive(Tween(begin: 0.0, end: 1.0)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Admin Panel', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A237E), fontFamily: 'Montserrat')),
                      ElevatedButton(onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('isLoggedIn', false);
                        await prefs.remove('username');
                        await prefs.remove('fullName');
                        await prefs.remove('phoneNumber');
                        await prefs.remove('userType');
                        if (mounted) Navigator.pushReplacementNamed(context, '/home');
                      }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)), child: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
                ]),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _TabButton(label: 'Analytics', isActive: _selectedTabIndex == 0, onTap: () => setState(() => _selectedTabIndex = 0)),
                  const SizedBox(width: 12),
                  _TabButton(label: 'Manage Doctors', isActive: _selectedTabIndex == 1, onTap: () => setState(() => _selectedTabIndex = 1)),
                  const SizedBox(width: 12),
                  _TabButton(label: 'Bookings Report', isActive: _selectedTabIndex == 2, onTap: () => setState(() => _selectedTabIndex = 2)),
                ],
              ),
              const SizedBox(height: 24),
              if (_selectedTabIndex == 0) _buildAnalyticsTab(),
              if (_selectedTabIndex == 1) _buildManageDoctorsTab(),
              if (_selectedTabIndex == 2) _buildBookingsReportTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return Column(
      children: [
        _AnimatedStatCard(animation: _animationController, index: 0, icon: Icons.local_hospital, iconColor: const Color(0xFF1A237E), title: 'Total Doctors', value: _doctors.length.toString(), backgroundColor: const Color(0xFFE3EAFD)),
        const SizedBox(height: 16),
        _AnimatedStatCard(animation: _animationController, index: 1, icon: Icons.calendar_today, iconColor: const Color(0xFF3949AB), title: 'Total Bookings', value: _bookedAppointments.length.toString(), backgroundColor: const Color(0xFFF0F4FF)),
        const SizedBox(height: 16),
        _AnimatedStatCard(animation: _animationController, index: 2, icon: Icons.trending_up, iconColor: const Color(0xFF4CAF50), title: 'Total Users', value: '${(_bookedAppointments.length / 2).toStringAsFixed(0)}', backgroundColor: const Color(0xFFE8F5E9)),
      ],
    );
  }

  Widget _buildManageDoctorsTab() {
    return Column(
      children: [
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _addDoctor, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('+ Add New Doctor', style: TextStyle(fontSize: 16, fontFamily: 'Montserrat', fontWeight: FontWeight.bold, color: Colors.white)))),
        const SizedBox(height: 24),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _doctors.length,
          itemBuilder: (context, index) {
            final doctor = _doctors[index];
            final schedule = DoctorSchedule(availableDates: doctor.availableDates, availableTimes: doctor.availableTimes);
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(doctor.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E), fontFamily: 'Montserrat')),
                      Row(children: [
                        ElevatedButton(onPressed: () => _editDoctorSchedule(doctor), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3949AB)), child: const Text('Edit Schedule', style: TextStyle(color: Colors.white, fontSize: 12))),
                        const SizedBox(width: 8),
                        ElevatedButton(onPressed: () => _editDoctorProfile(doctor), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E)), child: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 12))),
                        const SizedBox(width: 8),
                        ElevatedButton(onPressed: () async {
                          final confirm = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Delete Doctor'), content: const Text('Delete this doctor permanently?'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete'))]));
                        
                          if (confirm == true) {
                            setState(() {
                              _doctors.remove(doctor);
                            });
                            final prefs = await SharedPreferences.getInstance();
                            // Cascade delete bookings and user appointments referencing this doctor
                            final rawBooked = prefs.getStringList('bookedAppointments') ?? [];
                            final cleanedBooked = rawBooked.where((b) {
                              final parts = b.split('|');
                              if (parts.isEmpty) return false;
                              final key = parts.first;
                              return key != doctor.id && key != doctor.name;
                            }).toList();
                            await prefs.setStringList('bookedAppointments', cleanedBooked);

                            final rawUser = prefs.getStringList('userAppointments') ?? [];
                            final cleanedUser = rawUser.where((u) {
                              final parts = u.split('|');
                              // format may be name|doctorId|date|time or name|DoctorName|date|time
                              if (parts.length < 2) return true;
                              final doctorKey = parts[1];
                              return doctorKey != doctor.id && doctorKey != doctor.name;
                            }).toList();
                            await prefs.setStringList('userAppointments', cleanedUser);

                            await prefs.setStringList('doctorsData', _doctors.map((d) => d.encode()).toList());
                          }
                        }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)), child: const Text('Delete', style: TextStyle(color: Colors.white, fontSize: 12))),
                      ])
                    ]),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Available Dates: ${schedule.availableDates.isEmpty ? 'Not set' : schedule.availableDates.join(', ')}', style: const TextStyle(color: Color(0xFF3949AB), fontFamily: 'Montserrat')),
                        const SizedBox(height: 8),
                        Text('Available Times: ${schedule.availableTimes.isEmpty ? 'Not set' : schedule.availableTimes.join(', ')}', style: const TextStyle(color: Color(0xFF3949AB), fontFamily: 'Montserrat')),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _editDoctorProfile(Doctor doctor) {
    final nameController = TextEditingController(text: doctor.name);
    final specialtyController = TextEditingController(text: doctor.specialty);
    final imageController = TextEditingController(text: doctor.imageUrl);
    final descriptionController = TextEditingController(text: doctor.description);
    final weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final selectedDays = Set<String>.from(doctor.availableDays);
    String? startTime = doctor.availableTimes.isNotEmpty ? doctor.availableTimes.first : null;
    String? endTime = doctor.availableTimes.length > 1 ? doctor.availableTimes[1] : null;
    final timeSlots = ['09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM','11:00 AM','11:30 AM','12:00 PM','12:30 PM','01:00 PM','01:30 PM','02:00 PM','02:30 PM','03:00 PM','03:30 PM','04:00 PM'];

    showDialog(
      context: context,
      builder: (c) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Doctor Profile'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: specialtyController.text.isEmpty ? null : specialtyController.text,
                    items: [
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
                    ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => setState(() => specialtyController.text = v ?? ''),
                    decoration: const InputDecoration(labelText: 'Specialty'),
                    isExpanded: true,
                  ),
                  const SizedBox(height: 8),
                  // Image preview
                  Align(alignment: Alignment.centerLeft, child: const Text('Image Preview', style: TextStyle(fontWeight: FontWeight.w600))),
                  const SizedBox(height: 8),
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                    clipBehavior: Clip.hardEdge,
                    child: imageController.text.trim().isEmpty
                        ? Center(child: Icon(Icons.image, size: 48, color: Colors.grey.shade400))
                        : Image.network(
                            imageController.text.trim(),
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, st) => Center(child: Icon(Icons.broken_image, size: 48, color: Colors.grey.shade400)),
                          ),
                  ),
                  const SizedBox(height: 8),
                  TextField(controller: imageController, decoration: const InputDecoration(labelText: 'Image URL (or paste/upload)'), onChanged: (_) => setState(() {})),
                  const SizedBox(height: 8),
                  TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Short description'), maxLines: 3),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: DropdownButtonFormField<String>(
                      value: startTime,
                      items: timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) => setState(() => startTime = v),
                      decoration: const InputDecoration(labelText: 'Start Time'),
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: DropdownButtonFormField<String>(
                      value: endTime,
                      items: timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) => setState(() => endTime = v),
                      decoration: const InputDecoration(labelText: 'End Time'),
                    )),
                  ]),
                  const SizedBox(height: 12),
                  Align(alignment: Alignment.centerLeft, child: const Text('Available Days', style: TextStyle(fontWeight: FontWeight.bold))),
                  Wrap(spacing: 8, children: weekdays.map((d) {
                    final sel = selectedDays.contains(d);
                    return FilterChip(label: Text(d), selected: sel, onSelected: (v) => setState(() => v ? selectedDays.add(d) : selectedDays.remove(d)));
                  }).toList()),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
                ElevatedButton(
                onPressed: () async {
                  // validate times if set
                  if (startTime != null && endTime != null) {
                    final s = _timeStringToMinutes(startTime!);
                    final e = _timeStringToMinutes(endTime!);
                    if (s == e) {
                      await showDialog(context: context, builder: (c) => AlertDialog(title: const Text('Invalid Time Range'), content: const Text('Start and end times cannot be the same.'), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))]));
                      return;
                    }
                    if (e < s) {
                      await showDialog(context: context, builder: (c) => AlertDialog(title: const Text('Invalid Time Range'), content: const Text('End time must be after start time.'), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))]));
                      return;
                    }
                  }

                  setState(() {
                    doctor.name = nameController.text.trim();
                    doctor.specialty = specialtyController.text.trim();
                    doctor.imageUrl = imageController.text.trim();
                    doctor.description = descriptionController.text.trim();
                    doctor.availableDays = selectedDays.toList();
                    doctor.availableTimes = [];
                    if (startTime != null && endTime != null) {
                      doctor.availableTimes = [startTime!, endTime!];
                    }
                  });
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setStringList('doctorsData', _doctors.map((d) => d.encode()).toList());
                  if (mounted) Navigator.pop(c);
                },
                child: const Text('Save'),
              )
            ],
          );
        });
      },
    );
  }

  Widget _buildBookingsReportTab() {
    return Column(
      children: [
        const Text('Booking Details by Doctor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A237E), fontFamily: 'Montserrat')),
        const SizedBox(height: 16),
        if (_bookedAppointments.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 64, color: const Color(0xFF1A237E).withOpacity(0.3)),
                const SizedBox(height: 16),
                Text('No bookings yet', style: TextStyle(fontSize: 18, fontFamily: 'Montserrat', color: const Color(0xFF1A237E).withOpacity(0.6))),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _doctors.length,
            itemBuilder: (context, index) {
              final doctor = _doctors[index];
              final bookingCount = _getBookingCountForDoctor(doctor);
              final doctorBookings = _bookedAppointments.where((b) {
                final key = b.split('|').first;
                return key == doctor.id || key == doctor.name;
              }).toList();
              
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(doctor.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A237E), fontFamily: 'Montserrat')),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF1A237E), borderRadius: BorderRadius.circular(20)), child: Text('$bookingCount bookings', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Montserrat', fontSize: 12))),
                      ]),
                      if (doctorBookings.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: doctorBookings.map((booking) {
                            final parts = booking.split('|');
                            return Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text('• ${parts.length > 2 ? '${parts[1]} at ${parts[2]}' : booking}', style: const TextStyle(color: Color(0xFF3949AB), fontFamily: 'Montserrat')));
                          }).toList(),
                        ),
                      ]
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class DoctorSchedule {
  List<String> availableDates;
  List<String> availableTimes;
  DoctorSchedule({required this.availableDates, required this.availableTimes});
}

class _TabButton extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.isActive, required this.onTap});

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isActive ? const Color(0xFF1A237E) : (Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF1A237E), width: 2),
            boxShadow: _isHovered ? [BoxShadow(color: const Color(0xFF1A237E).withOpacity(0.3), blurRadius: 8)] : [],
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              color: widget.isActive ? Colors.white : const Color(0xFF1A237E),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedStatCard extends StatefulWidget {
  final Animation<double> animation;
  final int index;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final Color backgroundColor;

  const _AnimatedStatCard({
    required this.animation,
    required this.index,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.backgroundColor,
  });

  @override
  State<_AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<_AnimatedStatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.animation.drive(Tween(begin: 0.0, end: 1.0)),
      child: SlideTransition(
        position: widget.animation.drive(Tween(begin: Offset(0, 0.1 * (widget.index + 1)), end: Offset.zero)),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedScale(
            scale: _isHovered ? 1.02 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: _isHovered ? 8 : 4,
              color: Colors.white,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: _isHovered ? LinearGradient(colors: [Colors.white, widget.backgroundColor]) : null),
                child: Row(
                  children: [
                    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: widget.backgroundColor, borderRadius: BorderRadius.circular(12)), child: Icon(widget.icon, color: widget.iconColor, size: 32)),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.title, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF3949AB))),
                          const SizedBox(height: 4),
                          Text(widget.value, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, fontSize: 28, color: Color(0xFF1A237E))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
