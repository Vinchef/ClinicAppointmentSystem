import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/doctor.dart';

class DoctorBrowsePage extends StatefulWidget {
  @override
  _DoctorBrowsePageState createState() => _DoctorBrowsePageState();
}

class _DoctorBrowsePageState extends State<DoctorBrowsePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _searchQuery = '';
  List<Doctor> _doctors = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _animationController.forward();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('doctorsData') ?? [];
    if (list.isEmpty) {
      // Seed default doctors so browse is usable without visiting admin
      final defaults = [
        Doctor(
          name: 'Dr. Khaled Almatrook',
          specialty: 'Pediatrician',
          imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTtnGZakFUDorHSis3TuThW8LgEBdbNCFYMw4K8g4YwsUc5zvzvnWtIiiDO_JsGw5M6vjgK862Sgf4c_k4BKTVjIC9GDi6-dVG4avV99Tsl&s=10',
          availableDays: ['Monday', 'Wednesday'],
          availableTimes: ['09:00 AM', '12:00 PM'],
        ),
        Doctor(
          name: 'Dr. Ahmed Al-Khaldi',
          specialty: 'Dermatologist',
          imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRsj0W-Epmj4Zf2mnWcAO8g5STA33HqPQvm3QRi4AKUznpjhAQyKvar-PyHayDZjNvOwGrpVArK6eeNyhuRuDQMipyGohGTXD5sBT95ZwQuyw&s=10',
          availableDays: ['Tuesday', 'Thursday'],
          availableTimes: ['10:00 AM', '02:00 PM'],
        ),
        Doctor(
          name: 'Dr. Youssef Al-Mohannadi',
          specialty: 'Pediatrician',
          imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSdNmEnEZXfZTdQr3m93QPdj14GxsAgpcuLM5eUxNuSfw9HtQqwGL5GScVBMQCAVO2LUH45OATpDXaN4I81CDazH_7Gj2AwnoOYneL2RnPXXg&s=10',
          availableDays: ['Friday'],
          availableTimes: ['08:00 AM', '11:00 AM'],
        ),
        Doctor(
          name: 'Dr. Hassan Al-Thani',
          specialty: 'Neurologist',
          imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR1kV5c0YYdhhRCUPzNSTLaJL8xFo1AGrKEv9AFcocGfnXXbJgEABTEaz2nRFaPtP6uNwn_QtYveyGcpoVvV_S7-NnPpZRl7zRszG1vo_yoKg&s=10',
          availableDays: ['Saturday'],
          availableTimes: ['01:00 PM', '04:00 PM'],
        ),
      ];
      await prefs.setStringList('doctorsData', defaults.map((d) => d.encode()).toList());
      setState(() {
        _doctors = defaults;
      });
    } else {
      setState(() {
        _doctors = list.map((s) => Doctor.decode(s)).toList();
      });
    }
  }

  // helper if needed in future

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Doctor> get filteredDoctors {
    if (_searchQuery.isEmpty) return _doctors;
    return _doctors
        .where((doctor) =>
            doctor.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            doctor.specialty.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          'Our Doctors',
          style: TextStyle(
            color: Color(0xFF1A237E),
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1A237E)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _animationController.drive(Tween(begin: 0.0, end: 1.0)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 1))],
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF3949AB)),
                    hintText: 'Search doctors by name or specialty...',
                    hintStyle: const TextStyle(color: Color(0xFFA0A0A0), fontFamily: 'Montserrat'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
                    ),
                  ),
                  style: const TextStyle(fontFamily: 'Montserrat'),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredDoctors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: const Color(0xFF1A237E).withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text('No doctors found', style: TextStyle(fontSize: 18, fontFamily: 'Montserrat', color: const Color(0xFF1A237E).withOpacity(0.6))),
                      ],
                    ),
                  )
                : LayoutBuilder(builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    int crossAxisCount = 4;
                    if (width < 900) crossAxisCount = 2;
                    if (width < 600) crossAxisCount = 1;

                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: filteredDoctors.length,
                      itemBuilder: (context, index) {
                        final doctor = filteredDoctors[index];
                        return FadeTransition(
                          opacity: _animationController.drive(Tween(begin: 0.0, end: 1.0)),
                          child: SlideTransition(
                            position: _animationController.drive(Tween(begin: Offset(0, 0.05 * (index + 1)), end: Offset.zero)),
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                              color: Colors.white,
                              child: InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // image area
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: const Color(0xFFF5F5F5)),
                                          child: doctor.imageUrl.isNotEmpty
                                              ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(doctor.imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.person, size: 40)))
                                              : const Icon(Icons.person, size: 48, color: Color(0xFF1A237E)),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A237E), fontFamily: 'Montserrat')),
                                      const SizedBox(height: 4),
                                      Text(doctor.specialty, style: const TextStyle(color: Color(0xFF3949AB), fontFamily: 'Montserrat', fontSize: 12)),
                                      const SizedBox(height: 8),
                                      // show available days and times on the card
                                      Text('Days: ${doctor.availableDays.isEmpty ? 'Not set' : doctor.availableDays.join(', ')}', style: const TextStyle(color: Color(0xFF3949AB), fontFamily: 'Montserrat', fontSize: 12)),
                                      const SizedBox(height: 4),
                                      Text('Times: ${doctor.availableTimes.isEmpty ? 'Not set' : doctor.availableTimes.join(' - ')}', style: const TextStyle(color: Color(0xFF3949AB), fontFamily: 'Montserrat', fontSize: 12)),
                                      const SizedBox(height: 8),
                                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                        ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/booking', arguments: {'doctorId': doctor.id, 'doctorName': doctor.name}), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E)), child: const Text('Book')),
                                        const SizedBox(width: 8),
                                        ElevatedButton(onPressed: () async {
                                          final confirm = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Delete Doctor'), content: const Text('Delete this doctor permanently?'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete'))]));
                                          if (confirm == true) {
                                            setState(() {
                                              _doctors.removeWhere((d) => d.id == doctor.id);
                                            });
                                            final prefs = await SharedPreferences.getInstance();
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
                                              if (parts.length < 2) return true;
                                              final doctorKey = parts[1];
                                              return doctorKey != doctor.id && doctorKey != doctor.name;
                                            }).toList();
                                            await prefs.setStringList('userAppointments', cleanedUser);

                                            await prefs.setStringList('doctorsData', _doctors.map((d) => d.encode()).toList());
                                          }
                                        }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)), child: const Text('Delete')),
                                      ])
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
          ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatefulWidget {
  final Doctor doctor;
  final int index;
  final VoidCallback onBook;
  final VoidCallback onDelete;

  const _DoctorCard({
    required this.doctor,
    required this.index,
    required this.onBook,
    required this.onDelete,
  });

  @override
  State<_DoctorCard> createState() => _DoctorCardState();
}

class _DoctorCardState extends State<_DoctorCard> {
  bool _isHovered = false;
  bool _buttonHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: _isHovered ? 8 : 4,
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: _isHovered ? LinearGradient(colors: [Colors.white, const Color(0xFFF0F4FF)]) : null,
            ),
                          child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    height: 68,
                    width: 68,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3EAFD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: widget.doctor.imageUrl.isNotEmpty
                        ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(widget.doctor.imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.person, color: Color(0xFF1A237E))))
                        : const Icon(Icons.person, color: Color(0xFF1A237E), size: 40),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.doctor.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                            color: Color(0xFF1A237E),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3949AB).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.doctor.specialty,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              color: Color(0xFF3949AB),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(widget.doctor.description, style: const TextStyle(color: Color(0xFF3949AB))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  MouseRegion(
                    onEnter: (_) => setState(() => _buttonHovered = true),
                    onExit: (_) => setState(() => _buttonHovered = false),
                    cursor: SystemMouseCursors.click,
                    child: AnimatedScale(
                      scale: _buttonHovered ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(
                              title: Text(widget.doctor.name),
                              content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                if (widget.doctor.imageUrl.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom:8.0), child: Image.network(widget.doctor.imageUrl, height: 80, width: 80, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.person))),
                                Text('Specialty: ${widget.doctor.specialty}'),
                                const SizedBox(height:6),
                                Text(widget.doctor.description),
                                const SizedBox(height:8),
                                Text('Available Days: ${widget.doctor.availableDays.isEmpty ? 'Not set' : widget.doctor.availableDays.join(', ')}'),
                                const SizedBox(height:4),
                                Text('Available Times: ${widget.doctor.availableTimes.isEmpty ? 'Not set' : widget.doctor.availableTimes.join(' - ')}'),
                              ]),
                              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                                ElevatedButton(onPressed: widget.onBook, child: const Text('Book'))],
                            )),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A237E),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: _buttonHovered ? 6 : 2,
                            ),
                            child: const Text('Book', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: widget.onDelete,
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
                            child: const Text('Delete', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(
                              title: Text(widget.doctor.name),
                              content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                if (widget.doctor.imageUrl.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom:8.0), child: Image.network(widget.doctor.imageUrl, height: 80, width: 80, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.person))),
                                Text('Specialty: ${widget.doctor.specialty}'),
                                const SizedBox(height:6),
                                Text(widget.doctor.description),
                                const SizedBox(height:8),
                                Text('Available Days: ${widget.doctor.availableDays.isEmpty ? 'Not set' : widget.doctor.availableDays.join(', ')}'),
                                const SizedBox(height:4),
                                Text('Available Times: ${widget.doctor.availableTimes.isEmpty ? 'Not set' : widget.doctor.availableTimes.join(' - ')}'),
                              ]),
                              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                            )),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3949AB)),
                            child: const Text('Profile', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
