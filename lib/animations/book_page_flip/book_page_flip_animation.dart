import 'package:flutter/material.dart';

import 'models/page_data.dart';
import 'painters/book_painter.dart';

/// Book Page Flip animation.
///
/// Shows an open book. Tap the right side (or the → button) to flip forward;
/// tap the left side (or the ← button) to flip back. The flip is a smooth
/// 3D-perspective fold around the spine using a foreshortened trapezoid.
class BookPageFlipAnimation extends StatefulWidget {
  const BookPageFlipAnimation({super.key});

  @override
  State<BookPageFlipAnimation> createState() => _BookPageFlipAnimationState();
}

class _BookPageFlipAnimationState extends State<BookPageFlipAnimation>
    with SingleTickerProviderStateMixin {
  /// Index of the LEFT visible page (even index → 0, 2, 4 …).
  /// Pages are shown in pairs: spread [_spread] shows pages
  /// kBookPages[_spread*2] and kBookPages[_spread*2+1].
  int _spread = 0;

  late final AnimationController _ctrl;
  late Animation<double> _flipAnim;

  bool _flippingForward = true;
  bool _isFlipping = false;

  int get _maxSpread => ((kBookPages.length - 1) ~/ 2);

  PageData get _leftPage => kBookPages[_spread * 2];
  PageData get _rightPage =>
      (_spread * 2 + 1 < kBookPages.length) ? kBookPages[_spread * 2 + 1] : kBookPages.last;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _flipAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _ctrl.addStatusListener(_onAnimStatus);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onAnimStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        if (_flippingForward) {
          _spread = (_spread + 1).clamp(0, _maxSpread);
        } else {
          _spread = (_spread - 1).clamp(0, _maxSpread);
        }
        _isFlipping = false;
      });
      _ctrl.reset();
    }
  }

  void _flipForward() {
    if (_isFlipping || _spread >= _maxSpread) return;
    setState(() {
      _flippingForward = true;
      _isFlipping = true;
    });
    _ctrl.forward(from: 0);
  }

  void _flipBack() {
    if (_isFlipping || _spread <= 0) return;
    setState(() {
      _flippingForward = false;
      _isFlipping = true;
    });
    _ctrl.forward(from: 0);
  }

  void _onTapUp(TapUpDetails details, Size size) {
    final cx = size.width / 2;
    if (details.localPosition.dx > cx) {
      _flipForward();
    } else {
      _flipBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF3E2723), // dark wood background
      child: Stack(
        children: [
          // Subtle background texture lines.
          CustomPaint(
            painter: _WoodGrainPainter(),
            child: const SizedBox.expand(),
          ),

          // Book canvas.
          Center(
            child: LayoutBuilder(
              builder: (_, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);

                // Determine which pages are flipping.
                final frontPage = _flippingForward
                    ? _rightPage
                    : (_spread > 0 ? kBookPages[(_spread - 1) * 2 + 1] : _leftPage);
                final backPage = _flippingForward
                    ? (_spread + 1 <= _maxSpread ? kBookPages[(_spread + 1) * 2] : _rightPage)
                    : _leftPage;

                // While flipping forward the underlying left page is already
                // the next spread's left page; while flipping back it's the
                // previous spread's right page.
                final underLeft = _flippingForward
                    ? (_spread + 1 <= _maxSpread
                        ? kBookPages[(_spread + 1) * 2]
                        : _leftPage)
                    : (_spread > 0
                        ? kBookPages[(_spread - 1) * 2]
                        : _leftPage);
                final underRight = _flippingForward
                    ? (_spread + 1 <= _maxSpread
                        ? (_spread * 2 + 3 < kBookPages.length
                            ? kBookPages[_spread * 2 + 3]
                            : _rightPage)
                        : _rightPage)
                    : (_spread > 0
                        ? kBookPages[(_spread - 1) * 2 + 1]
                        : _rightPage);

                return GestureDetector(
                  onTapUp: (d) => _onTapUp(d, size),
                  child: AnimatedBuilder(
                    animation: _flipAnim,
                    builder: (context2, child2) => CustomPaint(
                      size: size,
                      painter: BookPainter(
                        leftPage: _isFlipping && _flippingForward ? underLeft : _leftPage,
                        rightPage: _isFlipping && !_flippingForward ? underRight : _rightPage,
                        flippingFront: frontPage,
                        flippingBack: backPage,
                        flipProgress: _isFlipping ? _flipAnim.value : 0.0,
                        flippingForward: _flippingForward,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Navigation buttons.
          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _NavButton(
                  icon: Icons.arrow_back_ios_rounded,
                  onTap: _flipBack,
                  enabled: !_isFlipping && _spread > 0,
                ),
                const SizedBox(width: 24),
                Text(
                  '${_spread + 1} / ${_maxSpread + 1}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 24),
                _NavButton(
                  icon: Icons.arrow_forward_ios_rounded,
                  onTap: _flipForward,
                  enabled: !_isFlipping && _spread < _maxSpread,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.25,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
          ),
          child: Icon(icon, color: Colors.white70, size: 18),
        ),
      ),
    );
  }
}

/// Paints faint horizontal lines to simulate a wood-grain desk surface.
class _WoodGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 1;
    for (double y = 10; y < size.height; y += 18) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_WoodGrainPainter _) => false;
}
