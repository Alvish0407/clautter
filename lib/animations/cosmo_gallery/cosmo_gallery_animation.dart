import 'dart:math';
import 'dart:ui' as ui;

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
  // Ed Sheeran (more)
  _Album('+', 'Ed Sheeran', 'https://i.scdn.co/image/ab67616d00001e026567a393a964a845a89b7f70'),
  _Album('Autumn Variations', 'Ed Sheeran', 'https://i.scdn.co/image/ab67616d00001e02cfedd56771ae0e9217762eb7'),
  _Album('+-=÷× Tour (Live)', 'Ed Sheeran', 'https://i.scdn.co/image/ab67616d00001e02c2ca06104c4b04a034952aaa'),
  // Dua Lipa (more)
  _Album('Radical Optimism', 'Dua Lipa', 'https://i.scdn.co/image/ab67616d00001e022f8790ed72296c2614607575'),
  // Bruno Mars (more)
  _Album('Doo-Wops & Hooligans', 'Bruno Mars', 'https://i.scdn.co/image/ab67616d00001e0239745621c00acfd747c29bea'),
  _Album('Unorthodox Jukebox', 'Bruno Mars', 'https://i.scdn.co/image/ab67616d00001e0249055dce3554e72e82082980'),
  _Album(
    'An Evening With Silk Sonic',
    'Bruno Mars',
    'https://i.scdn.co/image/ab67616d00001e025f19f50677f8ded7021b8229',
  ),
  // Coldplay (more)
  _Album(
    'A Rush of Blood to the Head',
    'Coldplay',
    'https://i.scdn.co/image/ab67616d00001e02de09e02aa7febf30b7c02d82',
  ),
  _Album('X&Y', 'Coldplay', 'https://i.scdn.co/image/ab67616d00001e024e0362c225863f6ae2432651'),
  _Album(
    'A Head Full of Dreams',
    'Coldplay',
    'https://i.scdn.co/image/ab67616d00001e028ff7c3580d429c8212b9a3b6',
  ),
  _Album(
    'Music of the Spheres',
    'Coldplay',
    'https://i.scdn.co/image/ab67616d00001e02d5d34557fa33c03782d3e730',
  ),
  _Album('Everyday Life', 'Coldplay', 'https://i.scdn.co/image/ab67616d00001e02722d16eb3b31fae9cb1d2ada'),
  // One Direction
  _Album('Up All Night', 'One Direction', 'https://i.scdn.co/image/ab67616d00001e024a5584795dc73860653a9a3e'),
  _Album('Take Me Home', 'One Direction', 'https://i.scdn.co/image/ab67616d00001e024e31e0d38b89b8fb239d4fbf'),
  _Album(
    'Midnight Memories',
    'One Direction',
    'https://i.scdn.co/image/ab67616d00001e023cf0191cca87a4bc7e34bc4a',
  ),
  _Album(
    'Made In The A.M.',
    'One Direction',
    'https://i.scdn.co/image/ab67616d00001e024a075ca70ae4143a37eb4fbe',
  ),
  _Album('FOUR', 'One Direction', 'https://i.scdn.co/image/ab67616d00001e0234a29f220057810cce98e1b4'),
  // ZAYN
  _Album('Mind of Mine', 'ZAYN', 'https://i.scdn.co/image/ab67616d00001e02b4c42ba7470503094d5a1c5a'),
  // Louis Tomlinson
  _Album('Walls', 'Louis Tomlinson', 'https://i.scdn.co/image/ab67616d00001e02697252e9bf85d4bfaeba4449'),
  _Album(
    'Faith In The Future',
    'Louis Tomlinson',
    'https://i.scdn.co/image/ab67616d00001e02a4227b7f8b532ded84e7c76a',
  ),
  _Album(
    'How Did I Get Here?',
    'Louis Tomlinson',
    'https://i.scdn.co/image/ab67616d00001e02deeb72c504e2a0f474ca5e41',
  ),
  // Charlie Puth
  _Album('Voicenotes', 'Charlie Puth', 'https://i.scdn.co/image/ab67616d00001e02897f73256b9128a9d70eaf66'),
  _Album('Nine Track Mind', 'Charlie Puth', 'https://i.scdn.co/image/ab67616d00001e0215145482a542a9adb282250b'),
  _Album(
    "Whatever's Clever!",
    'Charlie Puth',
    'https://i.scdn.co/image/ab67616d00001e02391d8b7f4d327cb0ec4f0aef',
  ),
];

// ── Card layout data ──────────────────────────────────────────────────────────

class _CardInfo {
  final int index;
  final double screenX, screenY, z, scale, theta;
  const _CardInfo({
    required this.index,
    required this.screenX,
    required this.screenY,
    required this.z,
    required this.scale,
    required this.theta,
  });
}

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
  final List<ui.Image?> _images = List.filled(_albums.length, null);
  final Map<int, double> _liftProgress = {};

  static const _autoRad = 0.003;
  static const _friction = 0.88;
  static const _dragK = 0.006;

  @override
  void initState() {
    super.initState();
    _loadImages();
    _ticker = createTicker((_) {
      _velocity *= _friction;
      final useAuto = _velocity.abs() < 0.0003;
      _rotation += useAuto ? _autoRad : _velocity;
      if (useAuto) _velocity = 0;

      for (var i = 0; i < _albums.length; i++) {
        final target = _hoveredIndex == i ? 1.0 : 0.0;
        final cur = _liftProgress[i] ?? 0.0;
        if ((cur - target).abs() > 0.001) {
          _liftProgress[i] = cur + (target - cur) * 0.18;
        }
      }
      if (mounted) setState(() {});
    })..start();
  }

  void _loadImages() {
    for (var i = 0; i < _albums.length; i++) {
      final idx = i;
      final stream = NetworkImage(_albums[idx].imageUrl).resolve(ImageConfiguration.empty);
      stream.addListener(
        ImageStreamListener(
          (info, _) {
            if (mounted) setState(() => _images[idx] = info.image);
          },
          onError: (e, _) {},
        ),
      );
    }
  }

  List<_CardInfo> _computeCards(Size size) {
    final w = size.width;
    final h = size.height;
    final n = _albums.length;
    final R = w * 0.32;
    final focal = w * 0.72;
    const tilt = 0.35;
    final cx = w / 2;
    final cy = h * 0.45;

    return List.generate(n, (i) {
      final theta = i * 2 * pi / n + _rotation;
      final cosT = cos(theta);
      final sinT = sin(theta);
      final z = (focal - R * cosT * cos(tilt)).clamp(1.0, double.infinity);
      final sc = focal / z;
      return _CardInfo(
        index: i,
        screenX: cx + R * sinT * sc,
        screenY: cy + R * cosT * sin(tilt) * sc,
        z: z,
        scale: sc,
        theta: theta,
      );
    });
  }

  // Approximate hit test: use cos(theta) to estimate visible card width.
  int? _hitTest(List<_CardInfo> sortedBackToFront, Offset pos) {
    const cW = 130.0;
    const cH = 165.0;
    for (final c in sortedBackToFront.reversed) {
      final lift = (_liftProgress[c.index] ?? 0.0) * 22.0;
      final visW = cW * c.scale * cos(c.theta).abs().clamp(0.12, 1.0);
      final ch = cH * c.scale;
      final left = c.screenX - visW / 2;
      final top = c.screenY - ch / 2 - lift;
      if (pos.dx >= left && pos.dx <= left + visW &&
          pos.dy >= top && pos.dy <= top + ch) {
        return c.index;
      }
    }
    return null;
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
              LayoutBuilder(
                builder: (_, constraints) {
                  final size = Size(constraints.maxWidth, constraints.maxHeight);
                  final cards = _computeCards(size)
                    ..sort((a, b) => b.z.compareTo(a.z));
                  return MouseRegion(
                    cursor: SystemMouseCursors.basic,
                    onHover: (e) {
                      final hit = _hitTest(cards, e.localPosition);
                      if (hit != _hoveredIndex) setState(() => _hoveredIndex = hit);
                    },
                    onExit: (_) {
                      if (_hoveredIndex != null) setState(() => _hoveredIndex = null);
                    },
                    child: CustomPaint(
                      size: size,
                      painter: _RingPainter(
                        cards: cards,
                        images: _images,
                        liftProgress: Map.of(_liftProgress),
                        hoveredIndex: _hoveredIndex,
                      ),
                    ),
                  );
                },
              ),
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

// ── 3-D ring painter ─────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final List<_CardInfo> cards;
  final List<ui.Image?> images;
  final Map<int, double> liftProgress;
  final int? hoveredIndex;

  static const _cW = 130.0;
  static const _cH = 165.0;

  const _RingPainter({
    required this.cards,
    required this.images,
    required this.liftProgress,
    required this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final imgPaint = Paint()..filterQuality = FilterQuality.medium;
    final placeholderPaint = Paint()..color = const Color(0xFFEEEEEE);
    final shadowPaint = Paint();

    for (final c in cards) {
      final img = images[c.index];
      final lift = (liftProgress[c.index] ?? 0.0) * 22.0;
      final isHov = hoveredIndex == c.index;
      final cw = _cW * c.scale;
      final ch = _cH * c.scale;
      final cardRect = Rect.fromCenter(center: Offset.zero, width: cw, height: ch);

      canvas.save();
      canvas.translate(c.screenX, c.screenY - lift);

      final m = Matrix4.identity()
        ..setEntry(3, 2, 0.0015)
        ..rotateY(c.theta);
      canvas.transform(m.storage);

      // Shadow drawn before clip so it spills outside the rounded rect.
      shadowPaint
        ..color = Colors.black.withValues(alpha: isHov ? 0.40 : 0.18)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, (isHov ? 26.0 : 10.0) * c.scale);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(0, (isHov ? 10.0 : 4.0) * c.scale), width: cw, height: ch),
          const Radius.circular(6),
        ),
        shadowPaint,
      );

      // Clip to rounded corners then draw image / placeholder.
      canvas.clipRRect(RRect.fromRectAndRadius(cardRect, const Radius.circular(6)));
      if (img != null) {
        canvas.drawImageRect(
          img,
          Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
          cardRect,
          imgPaint,
        );
      } else {
        canvas.drawRect(cardRect, placeholderPaint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => true;
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
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Color(0x44000000), blurRadius: 28, offset: Offset(0, 12)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(album.imageUrl, width: 160, height: 160, fit: BoxFit.cover),
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
        Text(
          album.artist,
          style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
        ),
      ],
    );
  }
}
