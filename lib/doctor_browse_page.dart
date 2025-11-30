import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/doctor.dart';
import 'widgets/branding.dart';

class DoctorBrowsePage extends StatefulWidget {
  @override
  _DoctorBrowsePageState createState() => _DoctorBrowsePageState();
}

class _DoctorBrowsePageState extends State<DoctorBrowsePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSpecialty = 'All';
  List<Doctor> _doctors = [];
  bool _isLoggedIn = false;
  String _userName = '';

  final List<String> _specialties = [
    'All',
    'Pediatrician',
    'Dermatologist',
    'Neurologist',
    'Cardiologist',
    'Orthopedic',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check login state
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userName = prefs.getString('fullName') ?? 'User';
    setState(() {
      _isLoggedIn = isLoggedIn;
      _userName = userName;
    });
    
    final list = prefs.getStringList('doctorsData') ?? [];
    if (list.isEmpty) {
      final defaults = [
        Doctor(
          name: 'Dr. Sarah Martinez',
          specialty: 'Cardiologist',
          imageUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=600&h=700&fit=crop',
          availableDays: ['Monday', 'Wednesday', 'Friday'],
          availableTimes: ['09:00 AM', '02:00 PM', '04:00 PM'],
        ),
        Doctor(
          name: 'Dr. Michael Chen',
          specialty: 'Pediatrician',
          imageUrl: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=600&h=700&fit=crop',
          availableDays: ['Tuesday', 'Thursday'],
          availableTimes: ['10:00 AM', '01:00 PM', '03:00 PM'],
        ),
        Doctor(
          name: 'Dr. Emily Roberts',
          specialty: 'Orthopedic',
          imageUrl: 'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=600&h=700&fit=crop',
          availableDays: ['Monday', 'Tuesday', 'Thursday'],
          availableTimes: ['08:00 AM', '11:00 AM', '02:00 PM'],
        ),
        Doctor(
          name: 'Dr. James Wilson',
          specialty: 'Neurologist',
          imageUrl: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=600&h=700&fit=crop',
          availableDays: ['Wednesday', 'Friday'],
          availableTimes: ['09:00 AM', '12:00 PM', '03:00 PM'],
        ),
        Doctor(
          name: 'Dr. Lisa Anderson',
          specialty: 'Dermatologist',
          imageUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=600&h=700&fit=crop',
          availableDays: ['Monday', 'Wednesday', 'Saturday'],
          availableTimes: ['10:00 AM', '01:00 PM', '04:00 PM'],
        ),
        Doctor(
          name: 'Dr. David Kim',
          specialty: 'Cardiologist',
          imageUrl: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=600&h=700&fit=crop',
          availableDays: ['Tuesday', 'Thursday', 'Friday'],
          availableTimes: ['08:00 AM', '11:00 AM', '02:00 PM'],
        ),
      ];
      await prefs.setStringList('doctorsData', defaults.map((d) => d.encode()).toList());
      setState(() => _doctors = defaults);
    } else {
      setState(() => _doctors = list.map((s) => Doctor.decode(s)).toList());
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Doctor> get filteredDoctors {
    var filtered = _doctors;
    
    if (_selectedSpecialty != 'All') {
      filtered = filtered.where((d) => d.specialty == _selectedSpecialty).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((d) =>
        d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        d.specialty.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 768;

          return CustomScrollView(
            slivers: [
              // App Bar with user info if logged in
              SliverAppBar(
                expandedHeight: isMobile ? 160 : 200,
                floating: false,
                pinned: true,
                backgroundColor: Color(0xFF0091EA),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Our Doctors',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: isMobile ? 18 : 22,
                      color: Colors.white,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0091EA), Color(0xFF1565C0)],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -50,
                          top: -50,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        Positioned(
                          left: -30,
                          bottom: -30,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                leading: Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  if (_isLoggedIn) ...[
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/home'),
                      child: Container(
                        margin: EdgeInsets.only(right: 16),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                                  style: TextStyle(color: Color(0xFF0091EA), fontWeight: FontWeight.w700, fontSize: 12),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(_userName, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Search and Filter Section
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _animationController,
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    child: Column(
                      children: [
                        // Search bar
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 20,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) => setState(() => _searchQuery = value),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.search,
                                color: Color(0xFF0066CC),
                                size: 24,
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear, color: Color(0xFF666666)),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                              hintText: 'Search by name or specialty...',
                              hintStyle: TextStyle(
                                color: Color(0xFFA0A0A0),
                                fontSize: isMobile ? 14 : 16,
                              ),
                              filled: true,
                              fillColor: Color(0xFFF8FAFF),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 20,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Color(0xFF0066CC),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        
                        // Specialty filter chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _specialties.map((specialty) {
                              final isSelected = _selectedSpecialty == specialty;
                              return Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: FilterChip(
                                  label: Text(
                                    specialty,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Color(0xFF1A237E),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() => _selectedSpecialty = specialty);
                                  },
                                  backgroundColor: Colors.white,
                                  selectedColor: Color(0xFF0066CC),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: isSelected 
                                          ? Color(0xFF0066CC)
                                          : Color(0xFFE0E0E0),
                                      width: 1.5,
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Results count
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 16 : 24,
                    16,
                    isMobile ? 16 : 24,
                    8,
                  ),
                  child: Text(
                    '${filteredDoctors.length} ${filteredDoctors.length == 1 ? 'doctor' : 'doctors'} found',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Doctors Grid
              filteredDoctors.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: isMobile ? 64 : 80,
                              color: Color(0xFF0066CC).withOpacity(0.3),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No doctors found',
                              style: TextStyle(
                                fontSize: isMobile ? 18 : 22,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A237E),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or filters',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        isMobile ? 16 : 24,
                        8,
                        isMobile ? 16 : 24,
                        24,
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isMobile ? 1 : (constraints.maxWidth < 1200 ? 2 : 3),
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: isMobile ? 1.1 : 0.85,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final doctor = filteredDoctors[index];
                            return FadeTransition(
                              opacity: _animationController.drive(
                                CurveTween(curve: Interval(
                                  (index * 0.1).clamp(0.0, 1.0),
                                  1.0,
                                  curve: Curves.easeOut,
                                )),
                              ),
                              child: _DoctorCard(
                                doctor: doctor,
                                isMobile: isMobile,
                                onBook: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/booking',
                                    arguments: {
                                      'doctorId': doctor.id,
                                      'doctorName': doctor.name,
                                    },
                                  );
                                },
                                onDelete: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (c) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: Text(
                                        'Delete Doctor',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1A237E),
                                        ),
                                      ),
                                      content: Text(
                                        'Are you sure you want to delete ${doctor.name}? This action cannot be undone.',
                                        style: TextStyle(color: Color(0xFF666666)),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(c, false),
                                          child: Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(c, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFFE53935),
                                          ),
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  
                                  if (confirm == true) {
                                    setState(() {
                                      _doctors.removeWhere((d) => d.id == doctor.id);
                                    });
                                    
                                    final prefs = await SharedPreferences.getInstance();
                                    await prefs.setStringList(
                                      'doctorsData',
                                      _doctors.map((d) => d.encode()).toList(),
                                    );
                                    
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${doctor.name} has been deleted'),
                                        backgroundColor: Color(0xFF0066CC),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                onViewProfile: () {
                                  _showDoctorProfile(context, doctor, isMobile);
                                },
                              ),
                            );
                          },
                          childCount: filteredDoctors.length,
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  void _showDoctorProfile(BuildContext context, Doctor doctor, bool isMobile) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          padding: EdgeInsets.all(isMobile ? 20 : 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Doctor Profile',
                      style: TextStyle(
                        fontSize: isMobile ? 22 : 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 20),
              
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: doctor.imageUrl.isNotEmpty
                        ? Image.network(
                            doctor.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              color: Color(0xFFF0F4FF),
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Color(0xFF0066CC),
                              ),
                            ),
                          )
                        : Container(
                            color: Color(0xFFF0F4FF),
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Color(0xFF0066CC),
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              
              Center(
                child: Column(
                  children: [
                    Text(
                      doctor.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A237E),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFF0066CC).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        doctor.specialty,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0066CC),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              Divider(),
              SizedBox(height: 16),
              
              _buildInfoRow(
                Icons.calendar_today,
                'Available Days',
                doctor.availableDays.isEmpty 
                    ? 'Not set' 
                    : doctor.availableDays.join(', '),
              ),
              SizedBox(height: 16),
              _buildInfoRow(
                Icons.access_time,
                'Available Times',
                doctor.availableTimes.isEmpty 
                    ? 'Not set' 
                    : doctor.availableTimes.join(', '),
              ),
              
              SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      '/booking',
                      arguments: {
                        'doctorId': doctor.id,
                        'doctorName': doctor.name,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0066CC),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Book Appointment',
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
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Color(0xFF0066CC)),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1A237E),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DoctorCard extends StatefulWidget {
  final Doctor doctor;
  final bool isMobile;
  final VoidCallback onBook;
  final VoidCallback onDelete;
  final VoidCallback onViewProfile;

  const _DoctorCard({
    required this.doctor,
    required this.isMobile,
    required this.onBook,
    required this.onDelete,
    required this.onViewProfile,
  });

  @override
  State<_DoctorCard> createState() => _DoctorCardState();
}

class _DoctorCardState extends State<_DoctorCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _isHovered 
                  ? Color(0xFF0066CC).withOpacity(0.2)
                  : Colors.black.withOpacity(0.08),
              blurRadius: _isHovered ? 30 : 15,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: widget.onViewProfile,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor image
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Color(0xFFF0F4FF),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: widget.doctor.imageUrl.isNotEmpty
                            ? Image.network(
                                widget.doctor.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Icon(
                                  Icons.person,
                                  size: 48,
                                  color: Color(0xFF0066CC),
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 48,
                                color: Color(0xFF0066CC),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Doctor info
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.doctor.name,
                          style: TextStyle(
                            fontSize: widget.isMobile ? 16 : 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A237E),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6),
                        
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Color(0xFF0066CC).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.doctor.specialty,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0066CC),
                            ),
                          ),
                        ),
                        
                        Spacer(),
                        
                        // Availability info
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: Color(0xFF666666)),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${widget.doctor.availableDays.length} days',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: widget.onBook,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF0066CC),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Book',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            IconButton(
                              onPressed: widget.onDelete,
                              icon: Icon(Icons.delete_outline),
                              color: Color(0xFFE53935),
                              style: IconButton.styleFrom(
                                backgroundColor: Color(0xFFFFEBEE),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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