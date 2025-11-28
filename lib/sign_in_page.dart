import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _error = '';
  bool _passwordVisible = false;
  bool _isLoading = false;
  bool _buttonHovered = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _animationController.forward();
    _ensureTestUser();
  }

  Future<void> _ensureTestUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = prefs.getStringList('users') ?? [];
      // format: fullName|email|password|phoneNumber
      final testEntry = 'Test User|test@gmail.com|123123|';
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
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Check if admin
      if (_email == 'admin@gmail.com' && _password == 'admin123') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userType', 'admin');
        await prefs.setString('username', 'admin@gmail.com');
        if (mounted) Navigator.pushReplacementNamed(context, '/admin');
      } else {
        // Validate against registered users list
        final prefs = await SharedPreferences.getInstance();
        final users = prefs.getStringList('users') ?? [];
        
        bool credentialsValid = false;
        for (String user in users) {
          final parts = user.split('|');
          if (parts.length >= 3) {
            final registeredEmail = parts[1];
            final registeredPassword = parts[2];
            
            if (_email == registeredEmail && _password == registeredPassword) {
              credentialsValid = true;
              break;
            }
          }
        }
        
        if (credentialsValid) {
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userType', 'user');
          await prefs.setString('username', _email);
          if (mounted) Navigator.pushReplacementNamed(context, '/home');
        } else {
          setState(() {
            _error = 'Invalid email or password. Please check your credentials or sign up.';
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child: FadeTransition(
              opacity: _animationController.drive(Tween(begin: 0.0, end: 1.0)),
              child: SlideTransition(
                position: _animationController.drive(Tween(begin: const Offset(0, 0.2), end: Offset.zero)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A237E).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.medical_services, color: Color(0xFF1A237E), size: 48),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in to continue to your account',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF3949AB),
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 32),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _AnimatedSignInField(
                                label: 'Email',
                                icon: Icons.email,
                                onSaved: (value) => _email = value ?? '',
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Enter email';
                                  if (!value.contains('@')) return 'Enter valid email';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              _AnimatedPasswordField(
                                label: 'Password',
                                passwordVisible: _passwordVisible,
                                onVisibilityToggle: () => setState(() => _passwordVisible = !_passwordVisible),
                                onSaved: (value) => _password = value ?? '',
                                validator: (value) => value == null || value.isEmpty ? 'Enter password' : null,
                              ),
                              const SizedBox(height: 24),
                              if (_error.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: const Color(0xFFE53935).withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE53935), width: 1)),
                                  child: Text(_error, style: const TextStyle(color: Color(0xFFE53935), fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
                                ),
                              const SizedBox(height: 24),
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
                                      onPressed: _isLoading ? null : _signIn,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF1A237E),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        elevation: _buttonHovered ? 8 : 4,
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                            )
                                          : const Text('Sign In', style: TextStyle(fontSize: 18, fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Don't have an account? ", style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFF3949AB))),
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(context, '/signup'),
                                    child: const Text('Sign up here', style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFF1A237E), fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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

class _AnimatedSignInField extends StatefulWidget {
  final String label;
  final IconData icon;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;

  const _AnimatedSignInField({
    required this.label,
    required this.icon,
    this.onSaved,
    this.validator,
  });

  @override
  State<_AnimatedSignInField> createState() => _AnimatedSignInFieldState();
}

class _AnimatedSignInFieldState extends State<_AnimatedSignInField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: _isFocused
            ? [BoxShadow(color: const Color(0xFF1A237E).withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))]
            : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Focus(
        onFocusChange: (isFocused) => setState(() => _isFocused = isFocused),
        child: TextFormField(
          decoration: InputDecoration(
            prefixIcon: Icon(widget.icon, color: _isFocused ? const Color(0xFF1A237E) : const Color(0xFF3949AB)),
            labelText: widget.label,
            labelStyle: const TextStyle(color: Color(0xFF3949AB), fontFamily: 'Montserrat'),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            fillColor: _isFocused ? const Color(0xFFF0F4FF) : Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
            ),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE53935), width: 1)),
          ),
          style: const TextStyle(fontFamily: 'Montserrat'),
          validator: widget.validator,
          onSaved: widget.onSaved,
        ),
      ),
    );
  }
}

class _AnimatedPasswordField extends StatelessWidget {
  final String label;
  final bool passwordVisible;
  final VoidCallback onVisibilityToggle;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;

  const _AnimatedPasswordField({
    required this.label,
    required this.passwordVisible,
    required this.onVisibilityToggle,
    this.onSaved,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: TextFormField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock, color: Color(0xFF3949AB)),
          suffixIcon: IconButton(
            icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF3949AB)),
            onPressed: onVisibilityToggle,
          ),
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF3949AB), fontFamily: 'Montserrat'),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          fillColor: Colors.white,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
          ),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE53935), width: 1)),
        ),
        style: const TextStyle(fontFamily: 'Montserrat'),
        obscureText: !passwordVisible,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}
