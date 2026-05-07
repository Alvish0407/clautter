import 'package:flutter/material.dart';
import 'polaroid_tear_screen.dart';

/// Gallery / home screen listing all animation demos.
/// Add new demos here as the project grows.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _demos = <_Demo>[
    _Demo(
      title: 'Polaroid Tear Delete',
      subtitle: 'Paper-tear animation on a Polaroid photo card',
      icon: Icons.photo_outlined,
      builder: PolaroidTearScreen.new,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Clautter'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _demos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final demo = _demos[index];
          return _DemoCard(demo: demo);
        },
      ),
    );
  }
}

class _Demo {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget Function() builder;

  const _Demo({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.builder,
  });
}

class _DemoCard extends StatelessWidget {
  final _Demo demo;
  const _DemoCard({super.key, required this.demo});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => demo.builder()),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0E8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(demo.icon, color: const Color(0xFFE85D6F)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    demo.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    demo.subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8A8A8A),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }
}
