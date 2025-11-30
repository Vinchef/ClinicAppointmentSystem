import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/doctor.dart';
import 'widgets/branding.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  // Real statistics from database
  int _totalUsers = 0;
  int _totalDoctors = 0;
  int _totalAppointments = 0;
  int _totalSpecialties = 0;
  List<Doctor> _featuredDoctors = [];

  @override
  void initState() {
    super.initState();
    _loadRealStats();
  }

  Future<void> _handleBookAppointment() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      Navigator.pushNamed(context, '/booking');
    } else {
      Navigator.pushNamed(context, '/signin');
    }
  }

  Future<void> _loadRealStats() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load real users count
    final users = prefs.getStringList('registeredUsers') ?? [];
    
    // Load real doctors
    final doctorsData = prefs.getStringList('doctorsData') ?? [];
    final doctors = doctorsData.map((s) => Doctor.decode(s)).toList();
    
    // Load real appointments count
    final appointments = prefs.getStringList('userAppointments') ?? [];
    
    // Count unique specialties
    final specialties = doctors.map((d) => d.specialty).where((s) => s.isNotEmpty).toSet();
    
    if (mounted) {
      setState(() {
        _totalUsers = users.length;
        _totalDoctors = doctors.length;
        _totalAppointments = appointments.length;
        _totalSpecialties = specialties.length > 0 ? specialties.length : 6;
        _featuredDoctors = doctors.take(4).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildNavBar(),
              _buildHeroSection(),
              _buildStatsSection(),
              _buildAboutSection(),
              _buildServicesSection(),
              _buildDoctorsSection(),
              _buildCTASection(),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;
        
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 40,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: isMobile
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    HorizonLogo(size: 32, showText: false),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.menu, color: Color(0xFF1A237E)),
                      onSelected: (value) {
                        if (value == 'Find a Doctor') {
                          Navigator.pushNamed(context, '/doctorbrowse');
                        } else if (value == 'Sign In') {
                          Navigator.pushNamed(context, '/signin');
                        } else if (value == 'Services') {
                          Navigator.pushNamed(context, '/services');
                        } else if (value == 'Book Appointment') {
                          _handleBookAppointment();
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'Services',
                          child: Text('Services'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Find a Doctor',
                          child: Text('Find a Doctor'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Sign In',
                          child: Text('Sign In'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Book Appointment',
                          child: Text('Book Appointment'),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    HorizonLogo(size: 40),
                    Row(
                      children: [
                        _navLink('Services'),
                        SizedBox(width: 40),
                        _navLink('Find a Doctor'),
                        SizedBox(width: 40),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/signin'),
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              color: Color(0xFF1A237E),
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: _handleBookAppointment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0066CC),
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Book Appointment',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _navLink(String text) {
    return InkWell(
      onTap: () {
        if (text == 'Find a Doctor') {
          Navigator.pushNamed(context, '/doctorbrowse');
        } else if (text == 'Services') {
          Navigator.pushNamed(context, '/services');
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          style: TextStyle(
            color: Color(0xFF1A237E),
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= 1200;
        final bool isMobile = constraints.maxWidth < 768;

        return Container(
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
                  Color(0xFF0066CC).withOpacity(0.88),
                  Color(0xFF1A237E).withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : (isWide ? 80 : 40),
              vertical: isMobile ? 60 : 100,
            ),
            child: Center(
              child: _buildHeroContent(isMobile),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroContent(bool isNarrow) {
    return Column(
      crossAxisAlignment: isNarrow ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Text(
            _totalUsers > 0 ? '✨ Trusted by ${_totalUsers}+ Patients' : '✨ Your Health Journey Starts Here',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 25),
        Text(
          'Your Health,\nOur Priority',
          style: TextStyle(
            fontSize: isNarrow ? 42 : 68,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.1,
            letterSpacing: -2,
          ),
          textAlign: isNarrow ? TextAlign.center : TextAlign.left,
        ),
        SizedBox(height: 25),
        Text(
          'Experience world-class healthcare with our expert doctors.\nBook appointments instantly and manage your health journey seamlessly.',
          style: TextStyle(
            fontSize: isNarrow ? 16 : 22,
            color: Colors.white.withOpacity(0.95),
            height: 1.6,
          ),
          textAlign: isNarrow ? TextAlign.center : TextAlign.left,
        ),
        SizedBox(height: 40),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: isNarrow ? WrapAlignment.center : WrapAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF0066CC),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 10,
              ),
              child: Text(
                'Get Started',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/doctorbrowse');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white, width: 2),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Find a Doctor',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;
        
        return Container(
          color: Color(0xFF1A237E),
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 40 : 60,
            horizontal: isMobile ? 20 : 40,
          ),
          child: isMobile
              ? Column(
                  children: [
                    _buildStatItem('${_totalUsers > 0 ? _totalUsers : 100}+', 'Happy Patients'),
                    SizedBox(height: 30),
                    _buildStatItem('${_totalDoctors > 0 ? _totalDoctors : 4}+', 'Expert Doctors'),
                    SizedBox(height: 30),
                    _buildStatItem('${_totalSpecialties}+', 'Specialties'),
                    SizedBox(height: 30),
                    _buildStatItem('24/7', 'Emergency Care'),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('${_totalUsers > 0 ? _totalUsers : 100}+', 'Happy Patients'),
                    _buildStatItem('${_totalDoctors > 0 ? _totalDoctors : 4}+', 'Expert Doctors'),
                    _buildStatItem('${_totalSpecialties}+', 'Specialties'),
                    _buildStatItem('24/7', 'Emergency Care'),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 1000;
        
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 80,
            vertical: isMobile ? 60 : 120,
          ),
          color: Colors.white,
          child: isMobile
              ? Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1631217868264-e5b90bb7e133?w=800&h=600&fit=crop',
                        height: 400,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 40),
                    _buildAboutContent(),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1631217868264-e5b90bb7e133?w=800&h=1000&fit=crop',
                          height: 600,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 80),
                    Expanded(child: _buildAboutContent()),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildAboutContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Leading Healthcare Excellence Since 2010',
          style: TextStyle(
            fontSize: 48,
            color: Color(0xFF1A237E),
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 25),
        Text(
          'At Horizon Clinic, we\'re committed to providing exceptional healthcare services with cutting-edge technology and compassionate care.',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF666666),
            height: 1.8,
          ),
        ),
        SizedBox(height: 20),
        Text(
          'With state-of-the-art facilities and a patient-first approach, we\'ve become the trusted healthcare partner for thousands of families.',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF666666),
            height: 1.8,
          ),
        ),
        SizedBox(height: 40),
        _buildFeatureItem(
          '✓',
          'Board-Certified Specialists',
          'Highly qualified doctors with years of experience',
        ),
        SizedBox(height: 20),
        _buildFeatureItem(
          '✓',
          'Advanced Technology',
          'Latest medical equipment and diagnostic tools',
        ),
        SizedBox(height: 20),
        _buildFeatureItem(
          '✓',
          'Personalized Care',
          'Tailored treatment plans for every patient',
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0066CC), Color(0xFF1A237E)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              icon,
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF1A237E),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(fontSize: 15, color: Color(0xFF666666)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServicesSection() {
    final services = [
      {
        'title': 'Cardiology',
        'desc': 'Expert heart care and cardiovascular treatments',
        'img': 'https://images.unsplash.com/photo-1628348068343-c6a848d2b6dd?w=600&h=800&fit=crop'
      },
      {
        'title': 'Pediatrics',
        'desc': 'Specialized care for children\'s health',
        'img': 'https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=600&h=800&fit=crop'
      },
      {
        'title': 'Orthopedics',
        'desc': 'Advanced bone, joint, and muscle treatments',
        'img': 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=600&h=800&fit=crop'
      },
      {
        'title': 'Dermatology',
        'desc': 'Comprehensive skin care solutions',
        'img': 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=600&h=800&fit=crop'
      },
      {
        'title': 'Neurology',
        'desc': 'Expert diagnosis of nervous system disorders',
        'img': 'https://images.unsplash.com/photo-1559757175-5700dde675bc?w=600&h=800&fit=crop'
      },
      {
        'title': 'General Medicine',
        'desc': 'Primary care for all your health needs',
        'img': 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=600&h=800&fit=crop'
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth < 768) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 1200) {
          crossAxisCount = 2;
        }

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth < 768 ? 20 : 80,
            vertical: constraints.maxWidth < 768 ? 60 : 120,
          ),
          color: Color(0xFFF8FAFF),
          child: Column(
            children: [
              Text(
                'Our Medical Services',
                style: TextStyle(
                  fontSize: constraints.maxWidth < 768 ? 32 : 48,
                  color: Color(0xFF1A237E),
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Comprehensive healthcare solutions across multiple specialties',
                style: TextStyle(
                  fontSize: constraints.maxWidth < 768 ? 16 : 20,
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 80),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 30,
                  mainAxisSpacing: 30,
                  childAspectRatio: 0.8,
                ),
                itemCount: services.length,
                itemBuilder: (context, index) => _buildServiceCard(services[index]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServiceCard(Map<String, String> service) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 40,
            offset: Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(service['img']!, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 30,
              right: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service['title']!,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    service['desc']!,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorsSection() {
    // Use real doctors from SharedPreferences, with fallback to defaults
    final displayDoctors = _featuredDoctors.isNotEmpty
        ? _featuredDoctors.map((d) => {
            'name': d.name,
            'specialty': d.specialty.isNotEmpty ? d.specialty : 'General Practitioner',
            'desc': d.description.isNotEmpty ? d.description : 'Experienced medical professional',
            'img': d.imageUrl.isNotEmpty ? d.imageUrl : 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=600&h=700&fit=crop'
          }).toList()
        : [
            {
              'name': 'Dr. Sarah Martinez',
              'specialty': 'Cardiology Specialist',
              'desc': '15+ years experience in cardiovascular medicine',
              'img': 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=600&h=700&fit=crop'
            },
            {
              'name': 'Dr. Michael Chen',
              'specialty': 'Pediatrician',
              'desc': 'Specialized in child healthcare',
              'img': 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=600&h=700&fit=crop'
            },
            {
              'name': 'Dr. Emily Roberts',
              'specialty': 'Orthopedic Surgeon',
              'desc': 'Expert in sports medicine and surgery',
              'img': 'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=600&h=700&fit=crop'
            },
            {
              'name': 'Dr. James Wilson',
              'specialty': 'Neurologist',
              'desc': 'Specializing in nervous system disorders',
              'img': 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=600&h=700&fit=crop'
            },
          ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 4;
        if (constraints.maxWidth < 768) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 1000) {
          crossAxisCount = 2;
        } else if (constraints.maxWidth < 1400) {
          crossAxisCount = 3;
        }

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth < 768 ? 20 : 80,
            vertical: constraints.maxWidth < 768 ? 60 : 120,
          ),
          color: Colors.white,
          child: Column(
            children: [
              Text(
                'Meet Our Expert Doctors',
                style: TextStyle(
                  fontSize: constraints.maxWidth < 768 ? 32 : 48,
                  color: Color(0xFF1A237E),
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Board-certified physicians dedicated to your health',
                style: TextStyle(
                  fontSize: constraints.maxWidth < 768 ? 16 : 20,
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 80),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 40,
                  mainAxisSpacing: 40,
                  childAspectRatio: 0.75,
                ),
                itemCount: displayDoctors.length,
                itemBuilder: (context, index) => _buildDoctorCard(displayDoctors[index]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDoctorCard(Map<String, String> doctor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              doctor['img']!,
              height: 320,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor['name']!,
                  style: TextStyle(
                    fontSize: 22,
                    color: Color(0xFF1A237E),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  doctor['specialty']!,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF0066CC),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  doctor['desc']!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;
        
        return Container(
          height: isMobile ? 300 : 400,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1538108149393-fbbd81895907?w=1600&h=900&fit=crop',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0066CC).withOpacity(0.9),
                  Color(0xFF1A237E).withOpacity(0.9),
                ],
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ready to Take Control of Your Health?',
                    style: TextStyle(
                      fontSize: isMobile ? 28 : 52,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 25),
                  Text(
                    'Join thousands of patients who trust Horizon Clinic for their healthcare needs',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 22,
                      color: Colors.white.withOpacity(0.95),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _handleBookAppointment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFF0066CC),
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Book Appointment Now',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;
        
        return Container(
          color: Color(0xFF1A237E),
          padding: EdgeInsets.all(isMobile ? 30 : 60),
          child: Column(
            children: [
              isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFooterBrand(),
                        SizedBox(height: 30),
                        _buildFooterLinks('Quick Links', [
                          {'label': 'Find a Doctor', 'route': '/doctorbrowse'},
                          {'label': 'Book Appointment', 'route': '/booking'},
                          {'label': 'Patient Login', 'route': '/signin'},
                          {'label': 'Admin Portal', 'route': '/admin'},
                        ]),
                        SizedBox(height: 30),
                        _buildFooterLinks('For Professionals', [
                          {'label': 'Doctor Login', 'route': '/doctor-login'},
                          {'label': 'Doctor Portal', 'route': '/doctor-login'},
                          {'label': 'Admin Dashboard', 'route': '/admin'},
                        ]),
                        SizedBox(height: 30),
                        _buildFooterContact(),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildFooterBrand(),
                        _buildFooterLinks('Quick Links', [
                          {'label': 'Find a Doctor', 'route': '/doctorbrowse'},
                          {'label': 'Book Appointment', 'route': '/booking'},
                          {'label': 'Patient Login', 'route': '/signin'},
                          {'label': 'Register', 'route': '/signup'},
                        ]),
                        _buildFooterLinks('For Professionals', [
                          {'label': 'Doctor Login', 'route': '/doctor-login'},
                          {'label': 'Doctor Portal', 'route': '/doctor-login'},
                          {'label': 'Admin Dashboard', 'route': '/admin'},
                        ]),
                        _buildFooterContact(),
                      ],
                    ),
              SizedBox(height: 40),
              
              // Portal Buttons
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    _buildPortalButton('Patient Portal', Icons.person, '/signin'),
                    _buildPortalButton('Doctor Portal', Icons.medical_services, '/doctor-login'),
                    _buildPortalButton('Admin Portal', Icons.admin_panel_settings, '/admin'),
                  ],
                ),
              ),
              
              SizedBox(height: 30),
              Divider(color: Colors.white.withOpacity(0.1)),
              SizedBox(height: 20),
              Text(
                ' 2024 Horizon Clinic. All rights reserved.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text('Privacy Policy', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                  ),
                  Text(' | ', style: TextStyle(color: Colors.white.withOpacity(0.5))),
                  TextButton(
                    onPressed: () {},
                    child: Text('Terms of Service', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFooterBrand() {
    return const HorizonFooterBrand();
  }

  Widget _buildFooterLinks(String title, List<Map<String, String>> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        SizedBox(height: 20),
        ...links.map((link) => Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, link['route']!),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_right, color: Colors.white54, size: 16),
                SizedBox(width: 4),
                Text(
                  link['label']!,
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 15),
                ),
              ],
            ),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildFooterContact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contact Us', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        SizedBox(height: 20),
        _buildContactRow(Icons.phone, '+63 XXX XXX XXXX'),
        _buildContactRow(Icons.email, 'support@horizonclinic.com'),
        _buildContactRow(Icons.location_on, 'Makati City, Metro Manila'),
        SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSocialIcon(Icons.facebook),
            SizedBox(width: 12),
            _buildSocialIcon(Icons.message),
            SizedBox(width: 12),
            _buildSocialIcon(Icons.email),
          ],
        ),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          SizedBox(width: 10),
          Text(text, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildPortalButton(String label, IconData icon, String route) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.pushNamed(context, route),
      icon: Icon(icon, size: 20),
      label: Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A237E),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}