import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// ── Album data ────────────────────────────────────────────────────────────────

class _Album {
  final String title;
  final String artist;
  final String imageUrl;
  const _Album(this.title, this.artist, this.imageUrl);
}

const _albums = <_Album>[
  // Ed Sheeran — required
  _Album('÷', 'Ed Sheeran', 'https://i.scdn.co/image/ab67616d00001e02ba5db46f4b838ef6027e6f96'),
  _Album('×', 'Ed Sheeran', 'https://i.scdn.co/image/ab67616d00001e0213b3e37318a0c247b550bccd'),
  _Album('=', 'Ed Sheeran', 'https://i.scdn.co/image/ab67616d00001e02dc806722f6802a8ea9953c89'),
  _Album(
    'No.6 Collaborations',
    'Ed Sheeran',
    'https://i.scdn.co/image/ab67616d00001e02f528fc2d5d8b26e4e3413715',
  ),
  _Album('Play', 'Ed Sheeran', 'https://i.scdn.co/image/ab67616d00001e02b07c28bb3192bdfb585fb438'),
  // Dua Lipa
  _Album(
    'Future Nostalgia',
    'Dua Lipa',
    'https://i.scdn.co/image/ab67616d00001e02c88bae7846e62a8ba59ee0bd',
  ),
  _Album(
    'Future Nostalgia\n(Moonlight Edition)',
    'Dua Lipa',
    'https://i.scdn.co/image/ab67616d00001e02d85ec490b441a6444a736cc3',
  ),
  // Harry Styles
  _Album(
    'Fine Line',
    'Harry Styles',
    'https://i.scdn.co/image/ab67616d00001e0225180571abce9472f61bd722',
  ),
  _Album(
    "Harry's House",
    'Harry Styles',
    'https://i.scdn.co/image/ab67616d00001e0282ce362511fb3d9dda6578ee',
  ),
  _Album(
    'Harry Styles',
    'Harry Styles',
    'https://i.scdn.co/image/ab67616d00001e023f8b8a9c71b2bd2f3019940b',
  ),
  // Coldplay
  _Album(
    'Moon Music',
    'Coldplay',
    'https://i.scdn.co/image/ab67616d00001e02f40306925074cfdcd8bee61f',
  ),
  // Bruno Mars
  _Album(
    '24K Magic',
    'Bruno Mars',
    'https://i.scdn.co/image/ab67616d00001e02232711f7d66a1e19e89e28c5',
  ),
  _Album(
    'The Romantic',
    'Bruno Mars',
    'https://i.scdn.co/image/ab67616d00001e023eb8dc748f7efb1470f74395',
  ),
  // Adele
  _Album('30', 'Adele', 'https://i.scdn.co/image/ab67616d00001e02c6b577e4c4a6d326354a89f7'),
  _Album('25', 'Adele', 'https://i.scdn.co/image/ab67616d00001e0247ce408fb4926d69da6713c2'),
  _Album('21', 'Adele', 'https://i.scdn.co/image/ab67616d00001e027e7e5dd9d1ab19fcded8a17f'),
  _Album('19', 'Adele', 'https://i.scdn.co/image/ab67616d00001e0262e62cf225b72fca8d765168'),
];

// ── Main widget ───────────────────────────────────────────────────────────────

class CosmoGalleryAnimation extends StatefulWidget {
  const CosmoGalleryAnimation({super.key});

  @override
  State<CosmoGalleryAnimation> createState() => _CosmoGalleryAnimationState();
}

class _CosmoGalleryAnimationState extends State<CosmoGalleryAnimation>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _rotation = 0;
  double _velocity = 0;
  int? _hoveredIndex;

  // Auto-rotate speed (rad/frame @ 60fps)
  static const _autoRad = 0.003;
  // Momentum friction per frame
  static const _friction = 0.88;
  // Drag px → rad
  static const _dragK = 0.006;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      setState(() {
        _velocity *= _friction;
        final useAuto = _velocity.abs() < 0.0003;
        _rotation += useAuto ? _autoRad : _velocity;
        if (useAuto) _velocity = 0;
      });
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (e) {
        if (e is PointerScrollEvent) {
          setState(() => _velocity -= e.scrollDelta.dy * 0.0006);
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (d) => setState(() {
          _velocity = d.delta.dx * _dragK;
          _rotation += _velocity;
        }),
        child: ColoredBox(
          color: Colors.white,
          child: Stack(
            children: [
              // 3-D ring
              LayoutBuilder(
                builder: (_, c) => _Ring(
                  size: Size(c.maxWidth, c.maxHeight),
                  rotation: _rotation,
                  hoveredIndex: _hoveredIndex,
                  onHover: (i) => setState(() => _hoveredIndex = i),
                ),
              ),
              // Top-left album preview
              Positioned(
                top: 20,
                left: 20,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.04),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                      child: child,
                    ),
                  ),
                  child: _hoveredIndex != null
                      ? _AlbumPreview(key: ValueKey(_hoveredIndex), album: _albums[_hoveredIndex!])
                      : const SizedBox.shrink(key: ValueKey<int>(-1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 3-D ring ──────────────────────────────────────────────────────────────────

class _CardInfo {
  final int index;
  final double screenX, screenY, z, scale;
  const _CardInfo({
    required this.index,
    required this.screenX,
    required this.screenY,
    required this.z,
    required this.scale,
  });
}

class _Ring extends StatelessWidget {
  final Size size;
  final double rotation;
  final int? hoveredIndex;
  final void Function(int?) onHover;

  const _Ring({
    required this.size,
    required this.rotation,
    required this.hoveredIndex,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    final w = size.width;
    final h = size.height;
    final n = _albums.length;

    // 3-D projection constants
    final R = w * 0.32; // ring radius
    final focal = w * 0.72; // perspective focal length
    const tilt = 0.35; // X-axis tilt (rad) — ring viewed from above
    final cx = w / 2;
    final cy = h * 0.45;

    // Base card dimensions (at z=0 perspective distance)
    const cW = 130.0;
    const cH = 165.0;

    // Project each album into screen space
    final cards = <_CardInfo>[];
    for (var i = 0; i < n; i++) {
      final theta = i * 2 * pi / n + rotation;
      final cosT = cos(theta);
      final sinT = sin(theta);

      final x3d = R * sinT;
      // Perspective depth (smaller z = closer = bigger scale)
      final z = (focal - R * cosT * cos(tilt)).clamp(1.0, double.infinity);
      // Vertical offset due to ring tilt (back of ring rises, front drops)
      final y3d = R * cosT * sin(tilt);

      final sc = focal / z;
      cards.add(
        _CardInfo(index: i, screenX: cx + x3d * sc, screenY: cy + y3d * sc, z: z, scale: sc),
      );
    }

    // Painter's algorithm: sort back → front so front cards paint on top
    cards.sort((a, b) => b.z.compareTo(a.z));

    return Stack(
      clipBehavior: Clip.none,
      children: cards.map((c) {
        final album = _albums[c.index];
        final isHov = hoveredIndex == c.index;
        final cw = cW * c.scale;
        final ch = cH * c.scale;

        return Positioned(
          key: ValueKey(c.index),
          left: c.screenX - cw / 2,
          top: c.screenY - ch / 2,
          width: cw,
          height: ch,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            // Lift the card upward on hover
            tween: Tween(end: isHov ? -22.0 : 0.0),
            builder: (_, lift, child) => Transform.translate(offset: Offset(0, lift), child: child),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => onHover(c.index),
              onExit: (_) => onHover(null),
              child: _AlbumCard(album: album, scale: c.scale, hovered: isHov),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Album card ────────────────────────────────────────────────────────────────

class _AlbumCard extends StatelessWidget {
  final _Album album;
  final double scale;
  final bool hovered;

  const _AlbumCard({required this.album, required this.scale, required this.hovered});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8 * scale.clamp(0.5, 1.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: hovered ? 0.38 : 0.15),
            blurRadius: (hovered ? 24 : 8) * scale,
            spreadRadius: hovered ? 2 * scale : 0,
            offset: Offset(0, (hovered ? 10 : 4) * scale),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8 * scale.clamp(0.5, 1.5)),
        child: RepaintBoundary(
          child: Image.network(
            album.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => ColoredBox(
              color: const Color(0xFFEEEEEE),
              child: Center(
                child: Icon(
                  Icons.music_note_outlined,
                  color: const Color(0xFFAAAAAA),
                  size: 24 * scale,
                ),
              ),
            ),
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return const ColoredBox(color: Color(0xFFEEEEEE));
            },
          ),
        ),
      ),
    );
  }
}

// ── Top-left album preview ────────────────────────────────────────────────────

class _AlbumPreview extends StatelessWidget {
  final _Album album;
  const _AlbumPreview({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 164,
          height: 164,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Color(0x40000000), blurRadius: 28, offset: Offset(0, 12)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(album.imageUrl, width: 164, height: 164, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          album.title,
          style: const TextStyle(
            color: Color(0xFF111111),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.3,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(album.artist, style: const TextStyle(color: Color(0xFF888888), fontSize: 12)),
      ],
    );
  }
}
