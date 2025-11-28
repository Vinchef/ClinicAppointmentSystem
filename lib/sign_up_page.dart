import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  
  String _fullName = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _phoneNumber = '';
  String _error = '';
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isLoading = false;
  bool _buttonHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      if (_password != _confirmPassword) {
        setState(() => _error = 'Passwords do not match');
        return;
      }

      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 500));

      try {
        final prefs = await SharedPreferences.getInstance();
        
        // Get existing users list
        List<String> usersList = prefs.getStringList('users') ?? [];
        
        // Check if email already exists
        for (String userJson in usersList) {
          final parts = userJson.split('|');
          if (parts.length > 1 && parts[1] == _email) {
            if (mounted) {
              setState(() {
                _error = 'Email already registered';
                _isLoading = false;
              });
            }
            return;
          }
        }
        
        // Create new user string (format: fullName|email|password|phoneNumber)
        String newUser = '$_fullName|$_email|$_password|$_phoneNumber';
        usersList.add(newUser);
        
        // Save updated users list
        await prefs.setStringList('users', usersList);
        
        // Also save current user info for quick access
        await prefs.setString('userType', 'user');
        await prefs.setString('username', _email);
        await prefs.setString('fullName', _fullName);
        await prefs.setString('phoneNumber', _phoneNumber);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Account created successfully!', style: TextStyle(fontFamily: 'Montserrat')),
              backgroundColor: const Color(0xFF1A237E),
              duration: const Duration(seconds: 2),
            ),
          );
          await Future.delayed(const Duration(milliseconds: 500));
          Navigator.pushReplacementNamed(context, '/signin');
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _error = 'Error creating account: ${e.toString()}';
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
                      child: const Icon(Icons.app_registration, color: Color(0xFF1A237E), size: 48),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Join us to book appointments easily',
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
                              _AnimatedSignUpField(
                                label: 'Full Name',
                                icon: Icons.person,
                                validator: (value) => value == null || value.isEmpty ? 'Enter your full name' : null,
                                onSaved: (value) => _fullName = value ?? '',
                              ),
                              const SizedBox(height: 16),
                              _AnimatedSignUpField(
                                label: 'Email Address',
                                icon: Icons.email,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Enter your email';
                                  if (!value.contains('@')) return 'Enter a valid email';
                                  return null;
                                },
                                onSaved: (value) => _email = value ?? '',
                              ),
                              const SizedBox(height: 16),
                              _AnimatedSignUpField(
                                label: 'Phone Number',
                                icon: Icons.phone,
                                keyboardType: TextInputType.phone,
                                validator: (value) => value == null || value.isEmpty ? 'Enter your phone number' : null,
                                onSaved: (value) => _phoneNumber = value ?? '',
                              ),
                              const SizedBox(height: 16),
                              _AnimatedPasswordField(
                                label: 'Password',
                                passwordVisible: _passwordVisible,
                                onVisibilityToggle: () => setState(() => _passwordVisible = !_passwordVisible),
                                onSaved: (value) => _password = value ?? '',
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Enter a password';
                                  if (value.length < 6) return 'Password must be at least 6 characters';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _AnimatedPasswordField(
                                label: 'Confirm Password',
                                passwordVisible: _confirmPasswordVisible,
                                onVisibilityToggle: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
                                onSaved: (value) => _confirmPassword = value ?? '',
                                validator: (value) => value == null || value.isEmpty ? 'Confirm your password' : null,
                              ),
                              const SizedBox(height: 24),
                              if (_error.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE53935).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFE53935), width: 1),
                                  ),
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
                                      onPressed: _isLoading ? null : _signUp,
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
                                          : const Text('Create Account', style: TextStyle(fontSize: 18, fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Already have an account? ', style: TextStyle(color: Color(0xFF3949AB), fontFamily: 'Montserrat')),
                                  GestureDetector(
                                    onTap: () => Navigator.pushReplacementNamed(context, '/signin'),
                                    child: const Text('Sign In', style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontFamily: 'Montserrat')),
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

class _AnimatedSignUpField extends StatefulWidget {
  final String label;
  final IconData icon;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const _AnimatedSignUpField({
    required this.label,
    required this.icon,
    this.onSaved,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<_AnimatedSignUpField> createState() => _AnimatedSignUpFieldState();
}

class _AnimatedSignUpFieldState extends State<_AnimatedSignUpField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3949AB),
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
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
              keyboardType: widget.keyboardType,
              validator: widget.validator,
              onSaved: widget.onSaved,
            ),
          ),
        ),
      ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3949AB),
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 8),
        Container(
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
        ),
      ],
    );
  }
}
