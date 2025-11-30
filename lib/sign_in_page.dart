import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/branding.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String _error = '';
  bool _passwordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
    _ensureTestUser();
  }

  Future<void> _ensureTestUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = prefs.getStringList('users') ?? [];
      final testEntry = 'Test User|test@gmail.com|123123|+63 123 456 7890';
      final exists = users.any((u) => u.split('|').length > 1 && u.split('|')[1] == 'test@gmail.com');
      if (!exists) {
        users.add(testEntry);
        await prefs.setStringList('users', users);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _error = '');
    
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);
      
      await Future.delayed(const Duration(milliseconds: 800));
      
      final email = _emailController.text;
      final password = _passwordController.text;
      
      // Check if admin
      if (email == 'admin@gmail.com' && password == 'admin123') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userType', 'admin');
        await prefs.setString('username', 'admin@gmail.com');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Welcome back, Admin!', 
                    style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              backgroundColor: Color(0xFF0066CC),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          Navigator.pushReplacementNamed(context, '/admin');
        }
      } else {
        // Validate against registered users
        final prefs = await SharedPreferences.getInstance();
        final users = prefs.getStringList('users') ?? [];
        
        bool credentialsValid = false;
        String userName = '';
        String userPhone = '';
        
        for (String user in users) {
          final parts = user.split('|');
          if (parts.length >= 3) {
            final registeredEmail = parts[1];
            final registeredPassword = parts[2];
            
            if (email == registeredEmail && password == registeredPassword) {
              credentialsValid = true;
              userName = parts[0];
              if (parts.length > 3) userPhone = parts[3];
              break;
            }
          }
        }
        
        if (credentialsValid) {
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userType', 'user');
          await prefs.setString('username', email);
          await prefs.setString('fullName', userName);
          if (userPhone.isNotEmpty) {
            await prefs.setString('phoneNumber', userPhone);
          }
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Welcome back!', 
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                backgroundColor: Color(0xFF0066CC),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          setState(() {
            _error = 'Invalid email or password';
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth >= 1000;
          final bool isMobile = constraints.maxWidth < 768;

          return Column(
            children: [
              // Navigation Bar
              _buildNavBar(isMobile),
              
              // Main Content
              Expanded(
                child: Stack(
                  children: [
                    // Background image with overlay
                    Container(
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
                              Color(0xFF0066CC).withOpacity(0.92),
                              Color(0xFF1A237E).withOpacity(0.88),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                    
                    // Content
                    SafeArea(
                      top: false,
                      child: Center(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 20 : 40,
                            vertical: isMobile ? 30 : 40,
                          ),
                          child: isWide
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: _buildLeftContent(isMobile),
                                    ),
                                    SizedBox(width: 80),
                                    Container(
                                      constraints: BoxConstraints(maxWidth: 500),
                                      child: _buildSignInForm(isMobile),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    if (!isMobile) _buildLeftContent(isMobile),
                                    if (!isMobile) SizedBox(height: 40),
                                    ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: 500),
                                      child: _buildSignInForm(isMobile),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNavBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: isMobile
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, '/landing'),
                    child: HorizonLogo(size: 28, showText: false),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/signup'),
                        child: Text('Sign Up', style: TextStyle(color: Color(0xFF0066CC), fontWeight: FontWeight.w600)),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.menu, color: Color(0xFF1A237E)),
                        onSelected: (value) {
                          if (value == 'Home') Navigator.pushNamed(context, '/landing');
                          else if (value == 'Services') Navigator.pushNamed(context, '/services');
                          else if (value == 'Find a Doctor') Navigator.pushNamed(context, '/doctorbrowse');
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(value: 'Home', child: Text('Home')),
                          PopupMenuItem(value: 'Services', child: Text('Services')),
                          PopupMenuItem(value: 'Find a Doctor', child: Text('Find a Doctor')),
                        ],
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, '/landing'),
                    child: HorizonLogo(size: 36),
                  ),
                  Row(
                    children: [
                      _navLink('Home', '/landing'),
                      SizedBox(width: 32),
                      _navLink('Services', '/services'),
                      SizedBox(width: 32),
                      _navLink('Find a Doctor', '/doctorbrowse'),
                      SizedBox(width: 32),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/signup'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0066CC),
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('Sign Up', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _navLink(String text, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
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

  Widget _buildLeftContent(bool isMobile) {
    return FadeTransition(
      opacity: _animationController.drive(
        CurveTween(curve: Curves.easeOut),
      ),
      child: Column(
        crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          // Logo
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HorizonLogo(size: 48, darkMode: true),
            ],
          ),
          SizedBox(height: isMobile ? 20 : 40),
          
          Text(
            'Welcome Back\nto Better Health',
            style: TextStyle(
              fontSize: isMobile ? 36 : 56,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.1,
              letterSpacing: -2,
            ),
            textAlign: isMobile ? TextAlign.center : TextAlign.left,
          ),
          SizedBox(height: isMobile ? 16 : 24),
          
          Text(
            'Your journey to wellness continues here.\nAccess your appointments and health records instantly.',
            style: TextStyle(
              fontSize: isMobile ? 16 : 20,
              color: Colors.white.withOpacity(0.95),
              height: 1.6,
            ),
            textAlign: isMobile ? TextAlign.center : TextAlign.left,
          ),
          SizedBox(height: isMobile ? 24 : 40),
          
          // Quick stats
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✨ Trusted Healthcare Platform',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                _buildStatRow(Icons.people, '50,000+ Active Patients'),
                SizedBox(height: 12),
                _buildStatRow(Icons.verified, '200+ Expert Doctors'),
                SizedBox(height: 12),
                _buildStatRow(Icons.star, '4.9/5 Average Rating'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSignInForm(bool isMobile) {
    return SlideTransition(
      position: _animationController.drive(
        Tween<Offset>(
          begin: Offset(0, 0.3),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
      ),
      child: FadeTransition(
        opacity: _animationController.drive(
          CurveTween(curve: Interval(0.2, 1.0, curve: Curves.easeOut)),
        ),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 24 : 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 60,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: isMobile ? 28 : 36,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A237E),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Enter your credentials to continue',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF666666),
                  ),
                ),
                SizedBox(height: isMobile ? 28 : 36),
                
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'your.email@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your email';
                    if (!value.contains('@')) return 'Please enter a valid email';
                    return null;
                  },
                ),
                SizedBox(height: 20),
                
                _buildPasswordField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  isVisible: _passwordVisible,
                  onToggle: () => setState(() => _passwordVisible = !_passwordVisible),
                  validator: (value) => 
                    value == null || value.isEmpty ? 'Please enter your password' : null,
                ),
                SizedBox(height: 16),
                
                // Remember me & Forgot password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (value) => setState(() => _rememberMe = value ?? false),
                            activeColor: Color(0xFF0066CC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Remember me',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        // Forgot password action
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Password reset coming soon'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF0066CC),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                if (_error.isNotEmpty) ...[
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFFE53935),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Color(0xFFE53935), size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _error,
                            style: TextStyle(
                              color: Color(0xFFE53935),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                SizedBox(height: 28),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0066CC),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: Color(0xFF0066CC).withOpacity(0.6),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                  ],
                ),
                
                SizedBox(height: 24),
                
                // Demo accounts info
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8FAFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(0xFF0066CC).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Color(0xFF0066CC), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Demo Accounts',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A237E),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Admin: admin@gmail.com / admin123',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'User: test@gmail.com / 123123',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/signup'),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF0066CC),
                          fontWeight: FontWeight.w700,
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
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
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Color(0xFFA0A0A0)),
            prefixIcon: Icon(icon, color: Color(0xFF0066CC), size: 22),
            filled: true,
            fillColor: Color(0xFFF8FAFF),
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF0066CC), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE53935), width: 1.5),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
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
          obscureText: !isVisible,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Color(0xFFA0A0A0)),
            prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF0066CC), size: 22),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Color(0xFF666666),
                size: 22,
              ),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: Color(0xFFF8FAFF),
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF0066CC), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE53935), width: 1.5),
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
}