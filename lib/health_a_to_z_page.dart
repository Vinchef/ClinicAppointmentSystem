import 'package:flutter/material.dart';

class HealthAtoZPage extends StatefulWidget {
  @override
  _HealthAtoZPageState createState() => _HealthAtoZPageState();
}

class _HealthAtoZPageState extends State<HealthAtoZPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _searchQuery = '';

  final List<Map<String, String>> healthTopics = [
    {'title': 'Cold & Flu', 'description': 'Common viral infections affecting respiratory system', 'icon': '🤧'},
    {'title': 'Headaches', 'description': 'Various types of headaches and migraine management', 'icon': '🤕'},
    {'title': 'High Blood Pressure', 'description': 'Hypertension management and prevention', 'icon': '💓'},
    {'title': 'Diabetes', 'description': 'Type 1 and Type 2 diabetes care and treatment', 'icon': '💉'},
    {'title': 'Asthma', 'description': 'Respiratory condition management', 'icon': '💨'},
    {'title': 'Heart Disease', 'description': 'Cardiovascular health and prevention', 'icon': '❤️'},
    {'title': 'Arthritis', 'description': 'Joint inflammation and treatment options', 'icon': '🦴'},
    {'title': 'Cancer', 'description': 'Cancer types, treatment and support', 'icon': '🏥'},
    {'title': 'Anxiety & Depression', 'description': 'Mental health disorders and therapies', 'icon': '🧠'},
    {'title': 'Obesity', 'description': 'Weight management and healthy lifestyle', 'icon': '⚖️'},
    {'title': 'Skin Conditions', 'description': 'Dermatology conditions and treatments', 'icon': '💆'},
    {'title': 'Sleep Disorders', 'description': 'Insomnia and sleep-related conditions', 'icon': '😴'},
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

  List<Map<String, String>> get filteredTopics {
    if (_searchQuery.isEmpty) return healthTopics;
    return healthTopics
        .where((topic) =>
            (topic['title'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (topic['description'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text('Health A to Z', style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontFamily: 'Montserrat', fontSize: 24)),
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
                hintText: 'Search health topics...',
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
            child: filteredTopics.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: const Color(0xFF1A237E).withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text('No health topics found', style: TextStyle(fontSize: 18, fontFamily: 'Montserrat', color: const Color(0xFF1A237E).withOpacity(0.6))),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: filteredTopics.length,
                    itemBuilder: (context, index) {
                      final topic = filteredTopics[index];
                      return _HealthTopicCard(topic: topic);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _HealthTopicCard extends StatefulWidget {
  final Map<String, String> topic;
  const _HealthTopicCard({required this.topic});

  @override
  State<_HealthTopicCard> createState() => _HealthTopicCardState();
}

class _HealthTopicCardState extends State<_HealthTopicCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: _isHovered ? 8 : 4,
          color: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: _isHovered ? LinearGradient(colors: [Colors.white, const Color(0xFFF0F4FF)]) : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(widget.topic['icon'] ?? '', style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    widget.topic['title'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                      color: Color(0xFF1A237E),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.topic['description'] ?? '',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Color(0xFF3949AB),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  if (_isHovered)
                    ElevatedButton(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Learn more about ${widget.topic['title']}', style: const TextStyle(fontFamily: 'Montserrat')),
                          backgroundColor: const Color(0xFF1A237E),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Learn', style: TextStyle(fontFamily: 'Montserrat', fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
