import 'package:flutter/material.dart';

class HomeClean extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Clinic Booking')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Welcome to the Clinic Booking App', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/doctorbrowse'),
                child: Text('Find a Doctor'),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/booking'),
                child: Text('Make a Booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
