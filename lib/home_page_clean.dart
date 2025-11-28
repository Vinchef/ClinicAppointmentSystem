import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clean responsive HomePage with animations and interactivity.
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _currentUserEmail;
  String? _currentUserFullName;
  bool _isLoggedIn = false;
  String _userType = '';

  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userEmail = prefs.getString('username');
    final userFullName = prefs.getString('fullName');
    final userType = prefs.getString('userType') ?? '';
    
    setState(() {
      _isLoggedIn = isLoggedIn;
      _currentUserEmail = userEmail;
      _currentUserFullName = userFullName;
      _userType = userType;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('username');
    await prefs.remove('fullName');
    await prefs.remove('phoneNumber');
    await prefs.remove('userType');
    
    if (mounted) {
      setState(() {
        _isLoggedIn = false;
        _currentUserEmail = null;
        _currentUserFullName = null;
      });
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('ClinicHub', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold, fontFamily: 'Montserrat', fontSize: 22)),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                _NavText('Find a Doctor', onTap: () => Navigator.pushNamed(context, '/doctorbrowse')),
                const SizedBox(width: 18),
                const SizedBox(width: 18),
                _NavText('Health A to Z', onTap: () => Navigator.pushNamed(context, '/healthatoz')),
                const SizedBox(width: 28),
                if (!_isLoggedIn)
                  Row(
                    children: [
                      _NavText('Log In', onTap: () => Navigator.pushNamed(context, '/signin')),
                      const SizedBox(width: 12),
                      _AnimatedButton(
                        label: 'Sign up',
                        onTap: () => Navigator.pushNamed(context, '/signup'),
                        color: const Color(0xFF1A237E),
                      ),
                    ],
                  )
                else
                  _ProfileMenu(
                    userEmail: _currentUserEmail ?? '',
                    userFullName: _currentUserFullName ?? '',
                    onLogout: _logout,
                    isAdmin: _userType == 'admin',
                  ),
              ]),
            )
          ],
        ),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final horizontalPadding = isWide ? 40.0 : 16.0;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const SizedBox(height: 8),
            ]),
          ),
        );
      }),
    );
  }
}

class _AnimatedContainer extends StatefulWidget {
  final Widget child;
  const _AnimatedContainer({required this.child});

  @override
  State<_AnimatedContainer> createState() => _AnimatedContainerState();
}

class _AnimatedContainerState extends State<_AnimatedContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(_animation),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))]),
          child: widget.child,
        ),
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _AnimatedButton({required this.label, required this.onTap, required this.color});

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton(
          onPressed: widget.onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: _isHovered ? 8 : 2,
          ),
          child: Text(widget.label, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final String hint;
  const _SearchField({required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: Icon(hint == 'Search Doctor' ? Icons.search : Icons.location_on, color: const Color(0xFF1A237E)),
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2)),
      ),
    );
  }
}

class _NavText extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  const _NavText(this.text, {required this.onTap});

  @override
  State<_NavText> createState() => _NavTextState();
}

class _NavTextState extends State<_NavText> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: _isHovered ? const Color(0xFF3949AB) : const Color(0xFF1A237E),
              fontWeight: _isHovered ? FontWeight.bold : FontWeight.w600,
              fontFamily: 'Montserrat',
              fontSize: _isHovered ? 16 : 15,
            ),
            child: Text(widget.text),
          ),
        ),
      ),
    );
  }
}

class _HeroTextColumn extends StatelessWidget {
  const _HeroTextColumn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('FEEL BETTER ABOUT', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A237E), fontFamily: 'Montserrat')),
      const Text('FINDING HEALTHCARE', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A237E), fontFamily: 'Montserrat')),
      const SizedBox(height: 12),
      const Text('Doctors are some of the most important people in society. Find trusted profiles, ratings and book appointments quickly.', style: TextStyle(fontSize: 14, color: Color(0xFF424242), height: 1.5)),
      const SizedBox(height: 14),
      Wrap(spacing: 10, children: [
          _AnimatedCTAButton(
          label: 'Profiles for Every Doctor',
          color: const Color(0xFF1A237E),
          onPressed: () => Navigator.of(context).pushNamed('/doctorscatalog'),
        ),
        _AnimatedCTAButton(
          label: 'Book Appointment',
          color: const Color(0xFF3949AB),
          onPressed: () => Navigator.of(context).pushNamed('/booking'),
        ),
      ]),
    ]);
  }
}

class _AnimatedCTAButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _AnimatedCTAButton({required this.label, required this.color, required this.onPressed});

  @override
  State<_AnimatedCTAButton> createState() => _AnimatedCTAButtonState();
}

class _AnimatedCTAButtonState extends State<_AnimatedCTAButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isPressed = true),
      onExit: (_) => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: _isPressed ? 2 : 4,
          ),
          child: Text(widget.label, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Montserrat')),
        ),
      ),
    );
  }
}

class _HeroImagePlaceholder extends StatelessWidget {
  final double size;
  const _HeroImagePlaceholder({this.size = 300});

  @override
  Widget build(BuildContext context) {
    return Container(height: size, decoration: BoxDecoration(color: const Color(0xFFE3EAFD), borderRadius: BorderRadius.circular(12)), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.image, size: 56, color: Color(0xFF1A237E)), SizedBox(height: 8), Text('Doctor Images', style: TextStyle(color: Color(0xFF1A237E)))])));
  }
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Find the right Doctor', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
      const SizedBox(height: 8),
      const Text('• We are here to hear and heal your health problems', style: TextStyle(fontSize: 14, color: Color(0xFF424242))),
      const SizedBox(height: 6),
      const Text('• It is not only about the money', style: TextStyle(fontSize: 14, color: Color(0xFF424242))),
      const SizedBox(height: 6),
      const Text('• More than just treating patients', style: TextStyle(fontSize: 14, color: Color(0xFF424242))),
      const SizedBox(height: 16),
      _AnimatedCTAButton(
        label: 'Search Nearest Hospital',
        color: const Color(0xFF1A237E),
        onPressed: () => Navigator.of(context).pushNamed('/doctorscatalog'),
      ),
    ]);
  }
}

class _FilterTag extends StatefulWidget {
  final String label;
  const _FilterTag(this.label, {Key? key}) : super(key: key);

  @override
  State<_FilterTag> createState() => _FilterTagState();
}

class _FilterTagState extends State<_FilterTag> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool active = widget.label == 'All';
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active || _isHovered ? const Color(0xFF1A237E) : const Color(0xFFE3EAFD),
          borderRadius: BorderRadius.circular(20),
          boxShadow: _isHovered ? [BoxShadow(color: const Color(0xFF1A237E).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))] : [],
        ),
        child: Text(widget.label, style: TextStyle(color: active || _isHovered ? Colors.white : const Color(0xFF1A237E), fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _ProfileMenu extends StatefulWidget {
  final String userEmail;
  final String userFullName;
  final VoidCallback onLogout;
  final bool isAdmin;

  const _ProfileMenu({
    required this.userEmail,
    required this.userFullName,
    required this.onLogout,
    this.isAdmin = false,
  });

  @override
  State<_ProfileMenu> createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<_ProfileMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'logout') {
          widget.onLogout();
        } else if (value == 'profile') {
          if (widget.isAdmin) {
            // Prevent admins from accessing user profile pages
            Navigator.pushReplacementNamed(context, '/admin');
          } else {
            Navigator.pushNamed(context, '/profile');
          }
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: const [
              Icon(Icons.person, color: Color(0xFF1A237E)),
              SizedBox(width: 12),
              Text('Profile', style: TextStyle(fontFamily: 'Montserrat')),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: const [
              Icon(Icons.logout, color: Color(0xFFE53935)),
              SizedBox(width: 12),
              Text('Logout', style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFFE53935))),
            ],
          ),
        ),
      ],
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1A237E),
        ),
        padding: const EdgeInsets.all(10),
        child: Tooltip(
          message: '${widget.userFullName}\n${widget.userEmail}',
          child: const Icon(Icons.person, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
