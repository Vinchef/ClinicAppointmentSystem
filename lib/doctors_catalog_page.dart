import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/doctor.dart';

class DoctorsCatalogPage extends StatefulWidget {
  @override
  _DoctorsCatalogPageState createState() => _DoctorsCatalogPageState();
}

class _DoctorsCatalogPageState extends State<DoctorsCatalogPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  List<Doctor> _doctors = [];
  String _search = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _animationController.forward();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('doctorsData') ?? [];
    setState(() {
      _doctors = list.map((s) => Doctor.decode(s)).toList();
    });
  }

  Future<bool> _isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString('userType') ?? '') == 'admin';
  }

  List<Doctor> get filtered => _search.isEmpty
      ? _doctors
      : _doctors.where((d) => d.name.toLowerCase().contains(_search.toLowerCase()) || d.specialty.toLowerCase().contains(_search.toLowerCase())).toList();

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
        title: const Text('Doctors Catalog', style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontFamily: 'Montserrat', fontSize: 24)),
        centerTitle: true,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Color(0xFF1A237E)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Color(0xFF3949AB)),
                hintText: 'Search doctors by name or specialty...'
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text('No doctors yet', style: TextStyle(color: const Color(0xFF1A237E).withOpacity(0.6))))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final doctor = filtered[index];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Container(
                                height: 68,
                                width: 68,
                                decoration: BoxDecoration(color: const Color(0xFFE3EAFD), borderRadius: BorderRadius.circular(12)),
                                child: doctor.imageUrl.isNotEmpty
                                    ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(doctor.imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.person, color: Color(0xFF1A237E))))
                                    : const Icon(Icons.person, color: Color(0xFF1A237E), size: 40),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A237E), fontFamily: 'Montserrat')),
                                  const SizedBox(height: 6),
                                  Text(doctor.specialty, style: const TextStyle(color: Color(0xFF3949AB), fontFamily: 'Montserrat')),
                                  const SizedBox(height: 6),
                                  Text('Days: ${doctor.availableDates.isEmpty ? 'Not set' : doctor.availableDates.join(', ')}', style: const TextStyle(color: Color(0xFF3949AB))),
                                ]),
                              ),
                              ElevatedButton(onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(
                                title: Text(doctor.name),
                                content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  if (doctor.imageUrl.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom:8.0), child: Image.network(doctor.imageUrl, height: 80, width: 80, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.person))),
                                  Text('Specialty: ${doctor.specialty}'),
                                  const SizedBox(height:6),
                                  Text(doctor.description),
                                  const SizedBox(height:8),
                                  Text('Available Days: ${doctor.availableDays.isEmpty ? 'Not set' : doctor.availableDays.join(', ')}'),
                                  const SizedBox(height:4),
                                  Text('Available Times: ${doctor.availableTimes.isEmpty ? 'Not set' : doctor.availableTimes.join(' - ')}'),
                                ]),
                                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')), ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/booking', arguments: {'doctorId': doctor.id, 'doctorName': doctor.name}), child: const Text('Book'))],
                              )), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E)), child: const Text('Profile')),
                              const SizedBox(width: 8),
                              ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/booking', arguments: {'doctorId': doctor.id, 'doctorName': doctor.name}), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E)), child: const Text('Book')),
                              FutureBuilder<bool>(
                                future: _isAdmin(),
                                builder: (context, snap) {
                                  if (snap.hasData && snap.data == true) {
                                    return Row(children: [
                                          const SizedBox(width: 8),
                                          ElevatedButton(onPressed: () async {
                                            final confirm = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Delete Doctor'), content: const Text('Delete this doctor permanently?'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete'))]));
                                            if (confirm == true) {
                                              setState(() {
                                                _doctors.removeWhere((d) => d.id == doctor.id);
                                              });
                                              final prefs = await SharedPreferences.getInstance();
                                              // cascade delete bookings and user appointments referencing this doctor
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
                                          }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)), child: const Text('Delete'))
                                        ]);
                                  }
                                  return const SizedBox.shrink();
                                },
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
    );
  }
}
