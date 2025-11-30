import 'package:flutter/material.dart';

class ServicesPage extends StatefulWidget {
  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Primary Care',
    'Specialty Care',
    'Diagnostics',
    'Women\'s Health',
    'Mental Health',
    'Emergency',
  ];

  final List<Map<String, dynamic>> _services = [
    {
      'name': 'General Medicine',
      'category': 'Primary Care',
      'description': 'Complete primary healthcare services for all ages with experienced physicians',
      'icon': Icons.medical_services,
      'color': Color(0xFF0066CC),
      'image': 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800&h=600&fit=crop',
      'features': ['Routine Checkups', 'Preventive Care', 'Health Screenings'],
    },
    {
      'name': 'Cardiology',
      'category': 'Specialty Care',
      'description': 'Expert heart and cardiovascular care with advanced diagnostic tools',
      'icon': Icons.favorite,
      'color': Color(0xFFE53935),
      'image': 'https://images.unsplash.com/photo-1628348068343-c6a848d2b6dd?w=800&h=600&fit=crop',
      'features': ['ECG Testing', 'Heart Monitoring', 'Cardiac Rehabilitation'],
    },
    {
      'name': 'Pediatrics',
      'category': 'Primary Care',
      'description': 'Specialized healthcare for infants, children, and adolescents',
      'icon': Icons.child_care,
      'color': Color(0xFF00BCD4),
      'image': 'https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=800&h=600&fit=crop',
      'features': ['Well-Child Visits', 'Vaccinations', 'Growth Monitoring'],
    },
    {
      'name': 'Orthopedics',
      'category': 'Specialty Care',
      'description': 'Advanced treatment for bones, joints, and musculoskeletal conditions',
      'icon': Icons.accessibility_new,
      'color': Color(0xFFFF9800),
      'image': 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=800&h=600&fit=crop',
      'features': ['Sports Medicine', 'Joint Replacement', 'Physical Therapy'],
    },
    {
      'name': 'Dermatology',
      'category': 'Specialty Care',
      'description': 'Comprehensive skin, hair, and nail care with modern treatments',
      'icon': Icons.face,
      'color': Color(0xFF9C27B0),
      'image': 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=800&h=600&fit=crop',
      'features': ['Skin Analysis', 'Acne Treatment', 'Cosmetic Procedures'],
    },
    {
      'name': 'Neurology',
      'category': 'Specialty Care',
      'description': 'Expert diagnosis and treatment of nervous system disorders',
      'icon': Icons.psychology,
      'color': Color(0xFF3F51B5),
      'image': 'https://images.unsplash.com/photo-1559757175-5700dde675bc?w=800&h=600&fit=crop',
      'features': ['Brain Imaging', 'Neurological Testing', 'Headache Management'],
    },
    {
      'name': 'Laboratory Services',
      'category': 'Diagnostics',
      'description': 'State-of-the-art diagnostic testing with accurate results',
      'icon': Icons.biotech,
      'color': Color(0xFF4CAF50),
      'image': 'https://images.unsplash.com/photo-1582719471137-c3967ffb1c42?w=800&h=600&fit=crop',
      'features': ['Blood Tests', 'Urinalysis', 'Molecular Testing'],
    },
    {
      'name': 'Radiology & Imaging',
      'category': 'Diagnostics',
      'description': 'Advanced imaging services for accurate diagnosis',
      'icon': Icons.camera_alt,
      'color': Color(0xFF607D8B),
      'image': 'https://images.unsplash.com/photo-1516549655169-df83a0774514?w=800&h=600&fit=crop',
      'features': ['X-Ray', 'CT Scan', 'MRI', 'Ultrasound'],
    },
    {
      'name': 'Women\'s Health',
      'category': 'Women\'s Health',
      'description': 'Comprehensive healthcare services for women at every life stage',
      'icon': Icons.pregnant_woman,
      'color': Color(0xFFE91E63),
      'image': 'https://images.unsplash.com/photo-1584820927498-cfe5211fd8bf?w=800&h=600&fit=crop',
      'features': ['OB/GYN Care', 'Prenatal Care', 'Mammography'],
    },
    {
      'name': 'Mental Health',
      'category': 'Mental Health',
      'description': 'Professional support for emotional and psychological wellbeing',
      'icon': Icons.self_improvement,
      'color': Color(0xFF00ACC1),
      'image': 'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=800&h=600&fit=crop',
      'features': ['Counseling', 'Therapy Sessions', 'Stress Management'],
    },
    {
      'name': 'Emergency Care',
      'category': 'Emergency',
      'description': '24/7 emergency medical services with rapid response team',
      'icon': Icons.local_hospital,
      'color': Color(0xFFD32F2F),
      'image': 'https://images.unsplash.com/photo-1587351021759-3e566b6af7cc?w=800&h=600&fit=crop',
      'features': ['24/7 Availability', 'Ambulance Service', 'Critical Care'],
    },
    {
      'name': 'Telemedicine',
      'category': 'Primary Care',
      'description': 'Virtual healthcare consultations from the comfort of your home',
      'icon': Icons.video_call,
      'color': Color(0xFF1976D2),
      'image': 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=800&h=600&fit=crop',
      'features': ['Video Consultations', 'Online Prescriptions', 'Remote Monitoring'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredServices {
    var filtered = _services;

    if (_selectedCategory != 'All') {
      filtered = filtered.where((s) => s['category'] == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((s) =>
        s['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
        s['description'].toLowerCase().contains(_searchQuery.toLowerCase())
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
          final bool isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;

          return CustomScrollView(
            slivers: [
              // Hero Section
              _buildHeroSection(isMobile),
              
              // Search and Filter
              SliverToBoxAdapter(
                child: _buildSearchAndFilter(isMobile),
              ),

              // Featured Services
              SliverToBoxAdapter(
                child: _buildFeaturedSection(isMobile),
              ),

              // Services Grid
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 40,
                  vertical: 20,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        filteredServices.isEmpty ? 'No services found' : 
                        '${filteredServices.length} ${filteredServices.length == 1 ? 'service' : 'services'} available',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF666666),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              filteredServices.isEmpty
                  ? SliverFillRemaining(
                      child: _buildEmptyState(isMobile),
                    )
                  : SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 40,
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          childAspectRatio: isMobile ? 0.95 : 0.85,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final service = filteredServices[index];
                            return FadeTransition(
                              opacity: _animationController.drive(
                                CurveTween(curve: Interval(
                                  (index * 0.1).clamp(0.0, 0.8),
                                  1.0,
                                  curve: Curves.easeOut,
                                )),
                              ),
                              child: _ServiceCard(
                                service: service,
                                isMobile: isMobile,
                              ),
                            );
                          },
                          childCount: filteredServices.length,
                        ),
                      ),
                    ),

              // How It Works Section
              SliverToBoxAdapter(
                child: _buildHowItWorksSection(isMobile),
              ),

              // Stats Section
              SliverToBoxAdapter(
                child: _buildStatsSection(isMobile),
              ),

              // CTA Section
              SliverToBoxAdapter(
                child: _buildCTASection(isMobile),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroSection(bool isMobile) {
    return SliverAppBar(
      expandedHeight: isMobile ? 280 : 350,
      floating: false,
      pinned: true,
      backgroundColor: Color(0xFF1A237E),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Our Services',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: isMobile ? 20 : 28,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1538108149393-fbbd81895907?w=1600&h=900&fit=crop',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1A237E).withOpacity(0.8),
                    Color(0xFF0066CC).withOpacity(0.95),
                  ],
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 60),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Comprehensive Healthcare',
                      style: TextStyle(
                        fontSize: isMobile ? 28 : 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'World-class medical services for every need',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 18,
                        color: Colors.white.withOpacity(0.95),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildSearchAndFilter(bool isMobile) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(isMobile ? 16 : 40),
      child: Column(
        children: [
          // Search Bar
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
                prefixIcon: Icon(Icons.search, color: Color(0xFF0066CC), size: 24),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Color(0xFF666666)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                hintText: 'Search services...',
                hintStyle: TextStyle(color: Color(0xFFA0A0A0)),
                filled: true,
                fillColor: Color(0xFFF8FAFF),
                contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Color(0xFF0066CC), width: 2),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Color(0xFF1A237E),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category);
                    },
                    backgroundColor: Colors.white,
                    selectedColor: Color(0xFF0066CC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? Color(0xFF0066CC) : Color(0xFFE0E0E0),
                        width: 1.5,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: isMobile ? 40 : 60,
      ),
      color: Color(0xFFF8FAFF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⭐ Featured Services',
            style: TextStyle(
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A237E),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Most popular healthcare services',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
          SizedBox(height: 32),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFeaturedCard(
                  'Emergency Care',
                  '24/7 availability',
                  Icons.local_hospital,
                  Color(0xFFE53935),
                  isMobile,
                ),
                SizedBox(width: 16),
                _buildFeaturedCard(
                  'Telemedicine',
                  'Virtual consultations',
                  Icons.video_call,
                  Color(0xFF0066CC),
                  isMobile,
                ),
                SizedBox(width: 16),
                _buildFeaturedCard(
                  'Cardiology',
                  'Heart health experts',
                  Icons.favorite,
                  Color(0xFFE91E63),
                  isMobile,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(String title, String subtitle, IconData icon, Color color, bool isMobile) {
    return Container(
      width: isMobile ? 200 : 280,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A237E),
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: isMobile ? 40 : 80,
      ),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            'How It Works',
            style: TextStyle(
              fontSize: isMobile ? 28 : 40,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A237E),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Get started in three simple steps',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
          SizedBox(height: isMobile ? 32 : 48),
          isMobile
              ? Column(
                  children: [
                    _buildStepCard(1, 'Choose Service', 'Browse and select the medical service you need', Icons.search, isMobile),
                    SizedBox(height: 24),
                    _buildStepCard(2, 'Book Appointment', 'Schedule with your preferred doctor and time', Icons.calendar_today, isMobile),
                    SizedBox(height: 24),
                    _buildStepCard(3, 'Get Care', 'Receive expert medical care and follow-up', Icons.medical_services, isMobile),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _buildStepCard(1, 'Choose Service', 'Browse and select the medical service you need', Icons.search, isMobile)),
                    SizedBox(width: 24),
                    Expanded(child: _buildStepCard(2, 'Book Appointment', 'Schedule with your preferred doctor and time', Icons.calendar_today, isMobile)),
                    SizedBox(width: 24),
                    Expanded(child: _buildStepCard(3, 'Get Care', 'Receive expert medical care and follow-up', Icons.medical_services, isMobile)),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildStepCard(int step, String title, String description, IconData icon, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(0xFF0066CC).withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0066CC), Color(0xFF1A237E)],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                '$step',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Icon(icon, size: 40, color: Color(0xFF0066CC)),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A237E),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: isMobile ? 40 : 60,
      ),
      color: Color(0xFF1A237E),
      child: isMobile
          ? Column(
              children: [
                _buildStatItem('50,000+', 'Happy Patients', isMobile),
                SizedBox(height: 32),
                _buildStatItem('200+', 'Expert Doctors', isMobile),
                SizedBox(height: 32),
                _buildStatItem('15+', 'Specialties', isMobile),
                SizedBox(height: 32),
                _buildStatItem('24/7', 'Emergency Care', isMobile),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('50,000+', 'Happy Patients', isMobile),
                _buildStatItem('200+', 'Expert Doctors', isMobile),
                _buildStatItem('15+', 'Specialties', isMobile),
                _buildStatItem('24/7', 'Emergency Care', isMobile),
              ],
            ),
    );
  }

  Widget _buildStatItem(String number, String label, bool isMobile) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: isMobile ? 36 : 48,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCTASection(bool isMobile) {
    return Container(
      height: isMobile ? 300 : 400,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=1600&h=900&fit=crop',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0066CC).withOpacity(0.95),
              Color(0xFF1A237E).withOpacity(0.95),
            ],
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ready to Experience\nWorld-Class Healthcare?',
                style: TextStyle(
                  fontSize: isMobile ? 28 : 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Book your appointment today and take the first step\ntowards better health',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 18,
                  color: Colors.white.withOpacity(0.95),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/booking'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF0066CC),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 32 : 48,
                    vertical: isMobile ? 16 : 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 8,
                ),
                child: Text(
                  'Book Appointment Now',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return Center(
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
            'No services found',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.w700,
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
    );
  }
}

class _ServiceCard extends StatefulWidget {
  final Map<String, dynamic> service;
  final bool isMobile;

  const _ServiceCard({
    required this.service,
    required this.isMobile,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? widget.service['color'].withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
              blurRadius: _isHovered ? 30 : 15,
              offset: Offset(0, _isHovered ? 12 : 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: () {
              _showServiceDetails(context, widget.service, widget.isMobile);
            },
            borderRadius: BorderRadius.circular(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Image
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          child: Image.network(
                            widget.service['image'],
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              color: widget.service['color'].withOpacity(0.1),
                              child: Icon(
                                widget.service['icon'],
                                size: 64,
                                color: widget.service['color'],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      // Category badge
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.service['color'],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.service['category'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Service Info
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon and Title
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: widget.service['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                widget.service['icon'],
                                color: widget.service['color'],
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.service['name'],
                                style: TextStyle(
                                  fontSize: widget.isMobile ? 18 : 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A237E),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),

                        // Description
                        Text(
                          widget.service['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                            height: 1.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),

                        Spacer(),

                        // Features
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (widget.service['features'] as List<String>)
                              .take(3)
                              .map((feature) => Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF8FAFF),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Color(0xFFE0E0E0),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          size: 14,
                                          color: widget.service['color'],
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          feature,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF666666),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),

                        SizedBox(height: 16),

                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/booking');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.service['color'],
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Book Now',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                          ),
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
    );
  }

  void _showServiceDetails(BuildContext context, Map<String, dynamic> service, bool isMobile) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          constraints: BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Image
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      child: Image.network(
                        service['image'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          height: 200,
                          color: service['color'].withOpacity(0.1),
                          child: Icon(service['icon'], size: 80, color: service['color']),
                        ),
                      ),
                    ),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),

                // Content
                Padding(
                  padding: EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon and Title
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: service['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              service['icon'],
                              color: service['color'],
                              size: 32,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service['name'],
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1A237E),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: service['color'].withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    service['category'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: service['color'],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),

                      // Description
                      Text(
                        'About This Service',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        service['description'],
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF666666),
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: 24),

                      // Features
                      Text(
                        'What\'s Included',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      SizedBox(height: 16),
                      ...(service['features'] as List<String>).map((feature) => Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: service['color'].withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: service['color'],
                                    size: 16,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: service['color'],
                                side: BorderSide(color: service['color'], width: 2),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Close',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, '/booking');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: service['color'],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Book Appointment',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 18),
                                ],
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
    );
  }
}