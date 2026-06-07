import 'package:flutter/material.dart';
import '../core/models/animation_meta.dart';
import '../core/registry/animation_registry.dart';
import '../core/theme/app_theme.dart';
import '../shared/widgets/animation_card.dart';
import 'animation_viewer.dart';

/// Scrollable gallery listing all registered animations.
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  void _open(BuildContext context, AnimationMeta meta) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AnimationViewer(meta: meta)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            backgroundColor: AppTheme.background,
            title: const Text(
              'Clautter',
              style: TextStyle(
                color: AppTheme.accent,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: AppTheme.background),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            sliver: SliverList.builder(
              itemCount: animationRegistry.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AnimationCard(
                  meta: animationRegistry[i],
                  onTap: () => _open(context, animationRegistry[i]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
