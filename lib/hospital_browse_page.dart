import 'package:flutter/material.dart';

class HospitalBrowsePage extends StatefulWidget {
  @override
  _HospitalBrowsePageState createState() => _HospitalBrowsePageState();
}

class _HospitalBrowsePageState extends State<HospitalBrowsePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _searchQuery = '';
  
  final List<Map<String, String>> hospitals = [
    {'name': 'Doha Hospital', 'location': 'Doha, Qatar', 'rating': '4.8', 'beds': '500', 'phone': '+974 4413 9136'},
    {'name': 'Hamad Medical Corporation', 'location': 'Doha, Qatar', 'rating': '4.9', 'beds': '1200', 'phone': '+974 4413 9999'},
    {'name': 'Qatar National Hospital', 'location': 'Doha, Qatar', 'rating': '4.7', 'beds': '800', 'phone': '+974 4450 9999'},
    {'name': 'Al Ahli Hospital', 'location': 'Doha, Qatar', 'rating': '4.6', 'beds': '450', 'phone': '+974 4423 6666'},
    {'name': 'American Hospital', 'location': 'Doha, Qatar', 'rating': '4.8', 'beds': '350', 'phone': '+974 4428 7777'},
    {'name': 'Turkish Hospital', 'location': 'Doha, Qatar', 'rating': '4.7', 'beds': '300', 'phone': '+974 4414 8888'},
  ];

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

  List<Map<String, String>> get filteredHospitals {
    if (_searchQuery.isEmpty) return hospitals;
    return hospitals
        .where((hospital) =>
            (hospital['name'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (hospital['location'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text('Find Hospitals', style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontFamily: 'Montserrat', fontSize: 24)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Color(0xFF3949AB)),
                hintText: 'Search hospitals...',
                hintStyle: const TextStyle(color: Color(0xFFA0A0A0), fontFamily: 'Montserrat'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
                ),
              ),
              style: const TextStyle(fontFamily: 'Montserrat'),
            ),
          ),
          Expanded(
            child: filteredHospitals.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search_off, size: 64, color: const Color(0xFF1A237E).withOpacity(0.3)), const SizedBox(height: 16), Text('No hospitals found', style: TextStyle(fontSize: 18, fontFamily: 'Montserrat', color: const Color(0xFF1A237E).withOpacity(0.6)))]))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    itemCount: filteredHospitals.length,
                    itemBuilder: (context, index) {
                      final hospital = filteredHospitals[index];
                      return _HospitalCard(hospital: hospital);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _HospitalCard extends StatefulWidget {
  final Map<String, String> hospital;
  const _HospitalCard({required this.hospital});

  @override
  State<_HospitalCard> createState() => _HospitalCardState();
}

class _HospitalCardState extends State<_HospitalCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: _isHovered ? 8 : 4,
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFE3EAFD), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.local_hospital, color: Color(0xFF1A237E), size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.hospital['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Montserrat', color: Color(0xFF1A237E), fontSize: 16)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14, color: Color(0xFF3949AB)),
                              const SizedBox(width: 4),
                              Text(widget.hospital['location'] ?? '', style: const TextStyle(fontFamily: 'Montserrat', color: Color(0xFF3949AB), fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(widget.hospital['rating'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Montserrat', color: Color(0xFF1A237E))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('${widget.hospital['beds']} beds', style: const TextStyle(fontFamily: 'Montserrat', color: Color(0xFF3949AB), fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(height: 1, color: const Color(0xFF1A237E).withOpacity(0.1)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Color(0xFF3949AB)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(widget.hospital['phone'] ?? '', style: const TextStyle(fontFamily: 'Montserrat', color: Color(0xFF3949AB), fontSize: 13))),
                    ElevatedButton(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Calling ${widget.hospital['name']}...', style: const TextStyle(fontFamily: 'Montserrat')))),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: const Text('Contact', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, fontSize: 12)),
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
}
