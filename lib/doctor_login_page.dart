import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/doctor.dart';
import 'widgets/branding.dart';

class DoctorLoginPage extends StatefulWidget {
  const DoctorLoginPage({Key? key}) : super(key: key);

  @override
  State<DoctorLoginPage> createState() => _DoctorLoginPageState();
}

class _DoctorLoginPageState extends State<DoctorLoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _formKey = GlobalKey<FormState>();
  final _doctorIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  // Default doctors for demo
  final List<Map<String, String>> _defaultDoctors = [
    {'id': 'dr1', 'name': 'Dr. Maria Santos', 'password': 'doctor123'},
    {'id': 'dr2', 'name': 'Dr. Juan Dela Cruz', 'password': 'doctor123'},
    {'id': 'dr3', 'name': 'Dr. Anna Reyes', 'password': 'doctor123'},
    {'id': 'dr4', 'name': 'Dr. Roberto Garcia', 'password': 'doctor123'},
    {'id': 'dr5', 'name': 'Dr. Elena Cruz', 'password': 'doctor123'},
    {'id': 'dr6', 'name': 'Dr. Michael Tan', 'password': 'doctor123'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _doctorIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network

    final doctorId = _doctorIdController.text.trim().toLowerCase();
    final password = _passwordController.text;

    // Check against default doctors or database
    final prefs = await SharedPreferences.getInstance();
    final doctorsData = prefs.getStringList('doctorsData') ?? [];
    
    Doctor? foundDoctor;
    
    // First check stored doctors
    for (final encoded in doctorsData) {
      try {
        final doctor = Doctor.decode(encoded);
        if (doctor.id.toLowerCase() == doctorId && doctor.password == password) {
          foundDoctor = doctor;
          break;
        }
      } catch (_) {}
    }

    // If not found, check default doctors
    if (foundDoctor == null) {
      for (final defaultDoc in _defaultDoctors) {
        if (defaultDoc['id'] == doctorId && defaultDoc['password'] == password) {
          // Create a temporary doctor object
          foundDoctor = Doctor(
            id: defaultDoc['id']!,
            name: defaultDoc['name']!,
            password: defaultDoc['password']!,
          );
          break;
        }
      }
    }

    if (foundDoctor != null) {
      // Save doctor session
      await prefs.setBool('isDoctorLoggedIn', true);
      await prefs.setString('loggedInDoctorId', foundDoctor.id);
      await prefs.setString('loggedInDoctorName', foundDoctor.name);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/doctor-dashboard');
      }
    } else {
      setState(() {
        _errorMessage = 'Invalid Doctor ID or Password';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0066CC), Color(0xFF1A237E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 768;
              
              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 24 : 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Section
                      FadeTransition(
                        opacity: _animationController,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, -0.5),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeOutBack,
                          )),
                          child: Column(
                            children: [
                              const HorizonLogo(size: 70, darkMode: true),
                              const SizedBox(height: 24),
                              const Text(
                                'Doctor Portal',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sign in to manage your appointments',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Login Card
                      FadeTransition(
                        opacity: _animationController,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.5),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeOutBack,
                          )),
                          child: Container(
                            width: isMobile ? double.infinity : 450,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Welcome Back',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1A237E),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Sign in to access your dashboard',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  // Error Message
                                  if (_errorMessage != null) ...[
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.red.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.error_outline, color: Colors.red.shade700),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              _errorMessage!,
                                              style: TextStyle(color: Colors.red.shade700),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                  ],

                                  // Doctor ID Field
                                  const Text(
                                    'Doctor ID',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A237E),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _doctorIdController,
                                    decoration: InputDecoration(
                                      hintText: 'Enter your doctor ID (e.g., dr1)',
                                      prefixIcon: const Icon(Icons.badge_outlined, color: Color(0xFF0066CC)),
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAFF),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(color: Colors.grey.shade200),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: const BorderSide(color: Color(0xFF0066CC), width: 2),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your Doctor ID';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // Password Field
                                  const Text(
                                    'Password',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A237E),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      hintText: 'Enter your password',
                                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF0066CC)),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAFF),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(color: Colors.grey.shade200),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: const BorderSide(color: Color(0xFF0066CC), width: 2),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),

                                  // Forgot Password
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Please contact admin to reset your password'),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Forgot Password?',
                                        style: TextStyle(color: Color(0xFF0066CC)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Login Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0066CC),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : const Text(
                                              'Sign In',
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Demo Credentials
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F7FF),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFF0066CC).withOpacity(0.2)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: const [
                                            Icon(Icons.info_outline, size: 18, color: Color(0xFF0066CC)),
                                            SizedBox(width: 8),
                                            Text(
                                              'Demo Credentials',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF0066CC),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        _buildCredentialRow('Doctor ID:', 'dr1, dr2, dr3, dr4, dr5, dr6'),
                                        const SizedBox(height: 4),
                                        _buildCredentialRow('Password:', 'doctor123'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Back to Home
                      TextButton.icon(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/landing'),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        label: const Text(
                          'Back to Home',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCredentialRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF1A237E),
            ),
          ),
        ),
      ],
    );
  }
}
