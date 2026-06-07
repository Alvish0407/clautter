import 'package:flutter/material.dart';
import '../core/models/animation_meta.dart';
import '../core/registry/animation_registry.dart';
import '../core/theme/app_theme.dart';
import '../shared/widgets/animation_card.dart';
import 'animation_viewer.dart';

/// Scrollable gallery listing all registered animations.
///
/// Layout follows the 60fps.design system: a light canvas, a slim pinned top
/// bar with the wordmark, a restrained hero line, and a responsive grid of
/// animation cards that reflows from one to three columns.
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  void _open(BuildContext context, AnimationMeta meta) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => AnimationViewer(meta: meta)));
  }

  @override
  Widget build(BuildContext context) {
    final count = animationRegistry.length;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.background.withValues(alpha: 0.85),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            titleSpacing: 0,
            toolbarHeight: 64,
            automaticallyImplyLeading: false,
            flexibleSpace: const _TopBarDivider(),
            title: const _Wordmark(),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: AppTheme.space2),
                child: _CountBadge(count: count),
              ),
            ],
          ),
          const SliverToBoxAdapter(child: _Hero()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.space2,
              0,
              AppTheme.space2,
              AppTheme.space4,
            ),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.crossAxisExtent;
                final columns = w >= 1040
                    ? 3
                    : w >= 680
                    ? 2
                    : 1;
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: AppTheme.space2,
                    mainAxisSpacing: AppTheme.space2,
                    mainAxisExtent: 408,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => AnimationCard(
                      meta: animationRegistry[i],
                      onTap: () => _open(context, animationRegistry[i]),
                    ),
                    childCount: count,
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: _Footer()),
        ],
          ),
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppTheme.space2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Text(
              'C',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Clautter',
            style: TextStyle(
              color: AppTheme.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(
        '$count ${count == 1 ? 'animation' : 'animations'}',
        style: const TextStyle(
          color: AppTheme.onSurfaceMuted,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// A 1px bottom hairline under the pinned top bar.
class _TopBarDivider extends StatelessWidget {
  const _TopBarDivider();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.bottomCenter,
      child: Divider(height: 1, thickness: 1, color: AppTheme.border),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.space2,
          AppTheme.space4,
          AppTheme.space2,
          AppTheme.space3,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: const Text(
                'A living collection of interactive animations, built entirely in code.',
                style: TextStyle(
                  color: AppTheme.onSurface,
                  fontSize: 28,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.6,
                ),
              ),
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: const Text(
                'Every card runs live — open one to play with it full-screen. '
                'All rendered in real time with Flutter, no videos, no images.',
                style: TextStyle(
                  color: AppTheme.onSurfaceMuted,
                  fontSize: 15,
                  height: 1.55,
                ),
              ),
            ),
          ],
        ),
      );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.space2,
          0,
          AppTheme.space2,
          AppTheme.space4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 1, thickness: 1, color: AppTheme.border),
            const SizedBox(height: AppTheme.space2),
            Text(
              'Clautter · open-source Flutter animations · more coming soon.',
              style: TextStyle(
                color: AppTheme.onSurfaceMuted.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
  }
}
