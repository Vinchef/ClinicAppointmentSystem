import 'package:flutter/material.dart';

/// Horizon Clinic branding constants
class HorizonColors {
  static const Color primary = Color(0xFF0091EA); // Bright blue from logo
  static const Color primaryDark = Color(0xFF1A237E);
  static const Color accent = Color(0xFF64B5F6); // Light blue leaf color
  static const Color leafBlue = Color(0xFF81D4FA); // Leaf accent color
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color textPrimary = Color(0xFF212121); // Dark text like logo
  static const Color textSecondary = Color(0xFF666666);
  static const Color background = Color(0xFFF5F8FF);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0091EA), Color(0xFF1A237E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Typography constants
class HorizonTypography {
  static const String fontFamily = 'Montserrat';
  
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: HorizonColors.textPrimary,
    letterSpacing: -0.5,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: HorizonColors.textPrimary,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: HorizonColors.textPrimary,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: HorizonColors.textSecondary,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: HorizonColors.textSecondary,
  );
}

/// Custom Cross with Leaf Logo - Matches the actual Horizon Clinic logo
class HorizonLogoMark extends StatelessWidget {
  final double size;
  final bool darkMode;

  const HorizonLogoMark({
    this.size = 48,
    this.darkMode = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Blue Medical Cross
          Center(
            child: CustomPaint(
              size: Size(size * 0.7, size * 0.7),
              painter: _CrossPainter(
                color: darkMode ? Colors.white : const Color(0xFF0091EA),
              ),
            ),
          ),
          // Light Blue Leaf on top right
          Positioned(
            top: -size * 0.05,
            right: -size * 0.1,
            child: Transform.rotate(
              angle: -0.3,
              child: CustomPaint(
                size: Size(size * 0.5, size * 0.35),
                painter: _LeafPainter(
                  color: darkMode ? Colors.white70 : const Color(0xFF64B5F6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CrossPainter extends CustomPainter {
  final Color color;
  _CrossPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final armWidth = w * 0.38;
    
    // Vertical bar
    final verticalRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w / 2, h / 2), width: armWidth, height: h),
      Radius.circular(armWidth * 0.15),
    );
    canvas.drawRRect(verticalRect, paint);
    
    // Horizontal bar
    final horizontalRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w / 2, h / 2), width: w, height: armWidth),
      Radius.circular(armWidth * 0.15),
    );
    canvas.drawRRect(horizontalRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LeafPainter extends CustomPainter {
  final Color color;
  _LeafPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;
    
    // Draw leaf shape
    path.moveTo(0, h * 0.7);
    path.quadraticBezierTo(w * 0.2, h * 0.1, w * 0.9, 0);
    path.quadraticBezierTo(w, h * 0.3, w * 0.7, h * 0.6);
    path.quadraticBezierTo(w * 0.4, h, 0, h * 0.7);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Leaf vein
    final veinPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    final veinPath = Path();
    veinPath.moveTo(w * 0.15, h * 0.65);
    veinPath.quadraticBezierTo(w * 0.5, h * 0.35, w * 0.8, h * 0.15);
    canvas.drawPath(veinPath, veinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Main Horizon Clinic Logo Widget - Use this everywhere
class HorizonLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool showTagline;
  final bool darkMode;
  final bool compact;
  final MainAxisAlignment alignment;

  const HorizonLogo({
    this.size = 48,
    this.showText = true,
    this.showTagline = false,
    this.darkMode = false,
    this.compact = false,
    this.alignment = MainAxisAlignment.start,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = darkMode ? Colors.white : HorizonColors.textPrimary;
    final taglineColor = darkMode ? Colors.white70 : HorizonColors.textSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo Mark (Cross + Leaf)
        HorizonLogoMark(size: size, darkMode: darkMode),
        if (showText) ...[
          SizedBox(width: size * 0.3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // HORIZON CLINIC text
              Text(
                'HORIZON CLINIC',
                style: TextStyle(
                  fontSize: compact ? size * 0.32 : size * 0.38,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: 1.5,
                  height: 1.2,
                ),
              ),
              // Always There To Care tagline
              if (showTagline || !compact)
                Text(
                  'Always There To Care',
                  style: TextStyle(
                    fontSize: compact ? size * 0.18 : size * 0.22,
                    fontWeight: FontWeight.w400,
                    color: taglineColor,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0.5,
                    height: 1.4,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Logo Icon Only - for app bars, favicons, small spaces
class HorizonLogoIcon extends StatelessWidget {
  final double size;
  final bool darkMode;
  final bool withBackground;

  const HorizonLogoIcon({
    this.size = 40,
    this.darkMode = false,
    this.withBackground = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (withBackground) {
      return Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.15),
        decoration: BoxDecoration(
          color: darkMode ? Colors.white : const Color(0xFFF0F7FF),
          borderRadius: BorderRadius.circular(size * 0.25),
          boxShadow: [
            BoxShadow(
              color: HorizonColors.primary.withOpacity(0.15),
              blurRadius: size * 0.3,
              offset: Offset(0, size * 0.1),
            ),
          ],
        ),
        child: HorizonLogoMark(size: size * 0.7, darkMode: false),
      );
    }
    return HorizonLogoMark(size: size, darkMode: darkMode);
  }
}

/// Simple text-only branding for headers
class HorizonTextLogo extends StatelessWidget {
  final double fontSize;
  final bool darkMode;
  final bool showTagline;
  final bool vertical;

  const HorizonTextLogo({
    this.fontSize = 24,
    this.darkMode = false,
    this.showTagline = false,
    this.vertical = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = darkMode ? Colors.white : HorizonColors.textPrimary;
    final secondaryColor = darkMode ? Colors.white70 : HorizonColors.textSecondary;
    
    if (vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'HORIZON CLINIC',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: primaryColor,
              letterSpacing: 1.5,
              height: 1.1,
            ),
          ),
          if (showTagline) ...[
            SizedBox(height: 2),
            Text(
              'Always There To Care',
              style: TextStyle(
                fontSize: fontSize * 0.5,
                fontWeight: FontWeight.w400,
                color: secondaryColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      );
    }
    
    return Text(
      'HORIZON CLINIC',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: primaryColor,
        letterSpacing: 1.5,
      ),
    );
  }
}

/// Full branded header for sidebars/drawers with gradient background
class HorizonBrandedHeader extends StatelessWidget {
  final bool showPortalLabel;
  final String portalLabel;
  final double height;

  const HorizonBrandedHeader({
    this.showPortalLabel = false,
    this.portalLabel = 'Portal',
    this.height = 160,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0091EA), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo with text
          Row(
            children: [
              HorizonLogoMark(size: 50, darkMode: true),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'HORIZON CLINIC',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Always There To Care',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (showPortalLabel) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    portalLabel == 'Admin' ? Icons.admin_panel_settings :
                    portalLabel == 'Doctor' ? Icons.medical_services :
                    Icons.person,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$portalLabel Portal',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Footer branding widget
class HorizonFooterBrand extends StatelessWidget {
  final bool showDescription;
  
  const HorizonFooterBrand({this.showDescription = true, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HorizonLogoMark(size: 48, darkMode: true),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'HORIZON CLINIC',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Always There To Care',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (showDescription) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: 280,
            child: Text(
              'Leading healthcare appointment system providing quality medical services nationwide. Your health is our priority.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Compact logo for navigation bars
class HorizonNavLogo extends StatelessWidget {
  final bool darkMode;
  final VoidCallback? onTap;
  
  const HorizonNavLogo({this.darkMode = false, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HorizonLogoMark(size: 36, darkMode: darkMode),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'HORIZON CLINIC',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: darkMode ? Colors.white : HorizonColors.textPrimary,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'Always There To Care',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: darkMode ? Colors.white60 : HorizonColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
