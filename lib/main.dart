
import 'package:flutter/material.dart';
import 'sign_in_page.dart';
import 'sign_up_page.dart';
import 'profile_page.dart';
import 'admin_page.dart';
import 'booking_form_page.dart';
import 'doctor_browse_page.dart';
import 'doctors_catalog_page.dart';
import 'health_a_to_z_page.dart';
import 'home_page_clean.dart';

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
      home: const HomePage(),
      routes: {
        '/signin': (context) => SignInPage(),
        '/signup': (context) => SignUpPage(),
        '/profile': (context) => ProfilePage(),
        '/admin': (context) => AdminPage(),
        '/booking': (context) => BookingFormPage(),
        '/doctorbrowse': (context) => DoctorBrowsePage(),
        '/doctorscatalog': (context) => DoctorsCatalogPage(),
        '/healthatoz': (context) => HealthAtoZPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
