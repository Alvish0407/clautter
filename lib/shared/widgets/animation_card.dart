import 'package:flutter/material.dart';

import '../../core/models/animation_meta.dart';
import '../../core/theme/app_theme.dart';
import 'video_preview.dart';

/// Gallery card presenting a single [AnimationMeta] entry.
///
/// Light, rounded, flat-with-subtle-border surface in the 60fps.design idiom:
/// a live animation preview up top, then title, description and tag chips, with
/// an accent "Open" affordance at the foot. Lifts gently on hover (web/desktop).
class AnimationCard extends StatefulWidget {
  final AnimationMeta meta;
  final VoidCallback onTap;

  const AnimationCard({super.key, required this.meta, required this.onTap});

  @override
  State<AnimationCard> createState() => _AnimationCardState();
}

class _AnimationCardState extends State<AnimationCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final meta = widget.meta;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(
              color: _hovered ? AppTheme.primary : AppTheme.border,
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : const [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Preview(meta: meta),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.space2),
                  child: _Body(meta: meta, hovered: _hovered),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The live, non-interactive animation thumbnail at the top of the card.
class _Preview extends StatelessWidget {
  final AnimationMeta meta;
  const _Preview({required this.meta});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppTheme.radiusCard - 1),
      ),
      child: SizedBox(
        height: 190,
        width: double.infinity,
        // A looping video is preferred when supplied (scales as the gallery
        // grows); otherwise fall back to a live, non-interactive render.
        // IgnorePointer keeps the card tappable/scrollable; RepaintBoundary
        // isolates the preview from the rest of the gallery.
        child: RepaintBoundary(
          child: IgnorePointer(
            child: meta.previewVideoAsset != null
                ? VideoPreview(
                    asset: meta.previewVideoAsset!,
                    background: meta.previewBg,
                  )
                : ColoredBox(
                    color: meta.previewBg,
                    child: meta.preview(context),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Title, description, tags and the accent open-affordance.
class _Body extends StatelessWidget {
  final AnimationMeta meta;
  final bool hovered;
  const _Body({required this.meta, required this.hovered});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          meta.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppTheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: AppTheme.space1),
        Expanded(
          child: Text(
            meta.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.onSurfaceMuted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.space1),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: meta.tags.take(4).map((t) => _Chip(label: t)).toList(),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Text(
              'Open',
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            AnimatedSlide(
              duration: const Duration(milliseconds: 160),
              offset: Offset(hovered ? 0.25 : 0, 0),
              child: const Icon(
                Icons.arrow_forward,
                color: AppTheme.primary,
                size: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusChip),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.onSurfaceMuted,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
