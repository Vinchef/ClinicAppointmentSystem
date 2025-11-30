import 'package:flutter/material.dart';
import 'sign_in_page.dart';
import 'sign_up_page.dart';
import 'profile_page.dart';
import 'admin_page.dart';
import 'booking_form_page.dart';
import 'doctor_browse_page.dart';
import 'doctors_catalog_page.dart';
import 'landing_page.dart';
import 'services_page.dart';
import 'user_dashboard.dart';
import 'doctor_login_page.dart';
import 'doctor_dashboard.dart';
import 'medical_records_page.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0066CC),
        fontFamily: 'Montserrat',
      ),
      home: LandingPage(),
      routes: {
        '/signin': (context) => SignInPage(),
        '/signup': (context) => SignUpPage(),
        '/profile': (context) => ProfilePage(),
        '/admin': (context) => AdminPage(),
        '/booking': (context) => BookingFormPage(),
        '/doctorbrowse': (context) => DoctorBrowsePage(),
        '/doctorscatalog': (context) => DoctorsCatalogPage(),
        '/landing': (context) => LandingPage(),
        '/home': (context) => UserDashboardPage(),
        '/services': (context) => ServicesPage(),
        '/doctor-login': (context) => DoctorLoginPage(),
        '/doctor-dashboard': (context) => DoctorDashboard(),
        '/medical-records': (context) => MedicalRecordsPage(),
      },
    );
  }
}
