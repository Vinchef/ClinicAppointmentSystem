import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/branding.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  String _error = '';
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() => _error = '');
    
    if (!_agreeToTerms) {
      setState(() => _error = 'Please agree to the Terms & Conditions');
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() => _error = 'Passwords do not match');
        return;
      }

      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 800));

      try {
        final prefs = await SharedPreferences.getInstance();
        List<String> usersList = prefs.getStringList('users') ?? [];
        
        // Check if email already exists
        for (String userJson in usersList) {
          final parts = userJson.split('|');
          if (parts.length > 1 && parts[1] == _emailController.text) {
            if (mounted) {
              setState(() {
                _error = 'This email is already registered';
                _isLoading = false;
              });
            }
            return;
          }
        }
        
        // Create new user
        String newUser = '${_fullNameController.text}|${_emailController.text}|${_passwordController.text}|${_phoneController.text}';
        usersList.add(newUser);
        
        await prefs.setStringList('users', usersList);
        await prefs.setString('userType', 'user');
        await prefs.setString('username', _emailController.text);
        await prefs.setString('fullName', _fullNameController.text);
        await prefs.setString('phoneNumber', _phoneController.text);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Account created successfully!', 
                    style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              backgroundColor: Color(0xFF0066CC),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 2),
            ),
          );
          await Future.delayed(const Duration(milliseconds: 500));
          Navigator.pushReplacementNamed(context, '/signin');
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _error = 'Something went wrong. Please try again.';
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
                            'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=1600&h=900&fit=crop',
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
                                      constraints: BoxConstraints(maxWidth: 520),
                                      child: _buildSignUpForm(isMobile),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    if (!isMobile) _buildLeftContent(isMobile),
                                    if (!isMobile) SizedBox(height: 40),
                                    ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: 520),
                                      child: _buildSignUpForm(isMobile),
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
                        onPressed: () => Navigator.pushNamed(context, '/signin'),
                        child: Text('Sign In', style: TextStyle(color: Color(0xFF0066CC), fontWeight: FontWeight.w600)),
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
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/signin'),
                        child: Text('Sign In', style: TextStyle(color: Color(0xFF0066CC), fontWeight: FontWeight.w600, fontSize: 15)),
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
            'Join Our Healthcare\nCommunity',
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
            'Get instant access to world-class healthcare services,\nexpert doctors, and seamless appointment booking.',
            style: TextStyle(
              fontSize: isMobile ? 16 : 20,
              color: Colors.white.withOpacity(0.95),
              height: 1.6,
            ),
            textAlign: isMobile ? TextAlign.center : TextAlign.left,
          ),
          SizedBox(height: isMobile ? 24 : 40),
          
          // Features
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildFeatureBadge(Icons.verified_user, 'Secure & Private'),
              _buildFeatureBadge(Icons.schedule, '24/7 Support'),
              _buildFeatureBadge(Icons.trending_up, '50K+ Users'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm(bool isMobile) {
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
                  'Create Account',
                  style: TextStyle(
                    fontSize: isMobile ? 26 : 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A237E),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Start your healthcare journey today',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF666666),
                  ),
                ),
                SizedBox(height: isMobile ? 24 : 32),
                
                _buildTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  hint: 'John Doe',
                  icon: Icons.person_outline,
                  validator: (value) => 
                    value == null || value.isEmpty ? 'Please enter your name' : null,
                ),
                SizedBox(height: 18),
                
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'john.doe@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your email';
                    if (!value.contains('@')) return 'Please enter a valid email';
                    return null;
                  },
                ),
                SizedBox(height: 18),
                
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: '+63 XXX XXX XXXX',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) => 
                    value == null || value.isEmpty ? 'Please enter your phone number' : null,
                ),
                SizedBox(height: 18),
                
                _buildPasswordField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  isVisible: _passwordVisible,
                  onToggle: () => setState(() => _passwordVisible = !_passwordVisible),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter a password';
                    if (value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                SizedBox(height: 18),
                
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  isVisible: _confirmPasswordVisible,
                  onToggle: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
                  validator: (value) => 
                    value == null || value.isEmpty ? 'Please confirm your password' : null,
                ),
                SizedBox(height: 20),
                
                // Terms checkbox
                Row(
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
                        activeColor: Color(0xFF0066CC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Wrap(
                        children: [
                          Text(
                            'I agree to the ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF666666),
                            ),
                          ),
                          Text(
                            'Terms & Conditions',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF0066CC),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            ' and ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF666666),
                            ),
                          ),
                          Text(
                            'Privacy Policy',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF0066CC),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
                    onPressed: _isLoading ? null : _signUp,
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
                            'Create Account',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                
                SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/signin'),
                      child: Text(
                        'Sign In',
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