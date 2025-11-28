import 'package:flutter/material.dart';

/// Fixed HomePage to replace corrupted home_page.dart
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 72,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Your logo', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold, fontFamily: 'Montserrat', fontSize: 18)),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                _NavText('Find a Doctor', onTap: () => Navigator.pushNamed(context, '/doctorbrowse')),
                const SizedBox(width: 18),
                _NavText('Find a Hospital', onTap: () {}),
                const SizedBox(width: 18),
                _NavText('Health A to Z', onTap: () {}),
                const SizedBox(width: 28),
                _NavText('Log In', onTap: () => Navigator.pushNamed(context, '/signin')),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                  child: const Text('Sign up', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                ),
              ]),
            )
          ],
        ),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final padding = EdgeInsets.symmetric(horizontal: isWide ? 40 : 16, vertical: 24);

        return SingleChildScrollView(
          child: Padding(
            padding: padding,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: isWide
                    ? Row(children: [const Expanded(child: _HeroTextColumn()), const SizedBox(width: 20), const SizedBox(width: 420, child: _HeroImagePlaceholder())])
                    : Column(children: const [_HeroTextColumn(), SizedBox(height: 16), _HeroImagePlaceholder(size: 220)]),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(children: [
                  Row(children: [
                    const Expanded(child: _SearchField(hint: 'Search Doctor')),
                    const SizedBox(width: 12),
                    SizedBox(width: isWide ? 300 : 160, child: const _SearchField(hint: 'Set Location')),
                    const SizedBox(width: 12),
                    ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/doctorbrowse'), child: const Icon(Icons.search), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), padding: const EdgeInsets.all(14))),
                  ]),
                  const SizedBox(height: 12),
                  Align(alignment: Alignment.centerLeft, child: Wrap(spacing: 10, children: const [_FilterTag('Family Medicine'), _FilterTag('COVID'), _FilterTag('Top Hospital'), _FilterTag('Telehealth'), _FilterTag('All')])),
                ]),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFFF5F8FF), borderRadius: BorderRadius.circular(12)),
                child: isWide
                    ? Row(children: const [Expanded(child: _InfoColumn()), SizedBox(width: 20), SizedBox(width: 280, child: _HeroImagePlaceholder(size: 260))])
                    : Column(children: const [_InfoColumn(), SizedBox(height: 16), _HeroImagePlaceholder(size: 200)]),
              ),
            ]),
          ),
        );
      }),
    );
  }
}

class _SearchField extends StatelessWidget {
  final String hint;
  const _SearchField({required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(prefixIcon: Icon(hint == 'Search Doctor' ? Icons.search : Icons.location_on), hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
    );
  }
}

class _NavText extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _NavText(this.text, {required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6), child: Text(text, style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontFamily: 'Montserrat'))));
}

class _HeroTextColumn extends StatelessWidget {
  const _HeroTextColumn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
      Text('FEEL BETTER ABOUT', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A237E), fontFamily: 'Montserrat')),
      Text('FINDING HEALTHCARE', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A237E), fontFamily: 'Montserrat')),
      SizedBox(height: 12),
      Text('Doctors are some of the most important people in society. Find trusted profiles, ratings and book appointments quickly.', style: TextStyle(fontSize: 14, color: Color(0xFF424242), height: 1.5)),
      SizedBox(height: 14),
      Wrap(spacing: 10, children: [
        ElevatedButton(onPressed: null, child: Text('Profiles for Every Doctor'), style: null),
        ElevatedButton(onPressed: null, child: Text('Patient Ratings'), style: null),
      ])
    ]);
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
      Text('Find the right Doctor', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
      SizedBox(height: 8),
      Text('• We are here to hear and heal your health problems', style: TextStyle(fontSize: 14, color: Color(0xFF424242))),
      SizedBox(height: 6),
      Text('• It is not only about the money', style: TextStyle(fontSize: 14, color: Color(0xFF424242))),
      SizedBox(height: 6),
      Text('• More than just treating patients', style: TextStyle(fontSize: 14, color: Color(0xFF424242))),
      SizedBox(height: 12),
      SizedBox(),
    ]);
  }
}

class _FilterTag extends StatelessWidget {
  final String label;
  const _FilterTag(this.label, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool active = label == 'All';
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: active ? const Color(0xFF1A237E) : const Color(0xFFE3EAFD), borderRadius: BorderRadius.circular(20)), child: Text(label, style: TextStyle(color: active ? Colors.white : const Color(0xFF1A237E), fontWeight: FontWeight.bold)));
  }
}
