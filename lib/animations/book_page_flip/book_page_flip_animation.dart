import 'package:flutter/material.dart';

import 'models/page_data.dart';
import 'painters/book_painter.dart';

class BookPageFlipAnimation extends StatefulWidget {
  const BookPageFlipAnimation({super.key});

  @override
  State<BookPageFlipAnimation> createState() => _BookPageFlipAnimationState();
}

class _BookPageFlipAnimationState extends State<BookPageFlipAnimation>
    with SingleTickerProviderStateMixin {
  int _spread = 0;
  Offset? _dragPoint;
  bool _isDragging = false;

  late final AnimationController _ctrl;
  bool _animatingForward = true;
  bool _snapBack = false;

  int get _maxSpread => (kBookPages.length ~/ 2) - 1;

  // Book geometry — computed in build, cached for hit-testing.
  Rect _bookRect = Rect.zero;
  Rect _rightPageRect = Rect.zero;
  Rect _leftPageRect = Rect.zero;
  double _pageW = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addStatusListener(_onAnimStatus);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _computeBookGeometry(Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final bookW = size.width * 0.82;
    final bookH = bookW * 0.68;
    _pageW = bookW / 2;
    final bookLeft = cx - bookW / 2;
    final bookTop = cy - bookH / 2;
    _bookRect = Rect.fromLTWH(bookLeft, bookTop, bookW, bookH);
    _leftPageRect = Rect.fromLTWH(bookLeft, bookTop, _pageW, bookH);
    _rightPageRect = Rect.fromLTWH(cx, bookTop, _pageW, bookH);
  }

  void _onAnimStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        if (!_snapBack) {
          if (_animatingForward && _spread < _maxSpread) {
            _spread++;
          } else if (!_animatingForward && _spread > 0) {
            _spread--;
          }
        }
        _dragPoint = null;
        _isDragging = false;
      });
      // Reset after the new-spread frame is painted to avoid a flicker frame
      // where the controller is at 0 but _spread has already advanced.
      WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.reset());
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (_ctrl.isAnimating) return;
    final pos = details.localPosition;

    // Allow starting drag on right page (flip forward) or left page (flip back).
    if (_rightPageRect.contains(pos) && _spread < _maxSpread) {
      _isDragging = true;
      _animatingForward = true;
      _dragPoint = pos;
      setState(() {});
    } else if (_leftPageRect.contains(pos) && _spread > 0) {
      _isDragging = true;
      _animatingForward = false;
      _dragPoint = pos;
      setState(() {});
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    setState(() {
      _dragPoint = details.localPosition;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDragging) return;

    // Decide: complete the flip or snap back.
    final cx = _bookRect.center.dx;
    final dragX = _dragPoint?.dx ?? cx;
    final threshold = cx - _pageW * 0.3;

    if (dragX < threshold) {
      // Complete the flip.
      _snapBack = false;
      _animatingForward = true;
      _ctrl.duration = const Duration(milliseconds: 400);
      _ctrl.forward(from: 0);
    } else {
      // Snap back.
      _snapBack = true;
      _animatingForward = true;
      _ctrl.duration = const Duration(milliseconds: 300);
      _ctrl.forward(from: 0);
    }

    _isDragging = false;
  }

  void _flipForward() {
    if (_ctrl.isAnimating || _spread >= _maxSpread) return;
    _snapBack = false;
    _animatingForward = true;
    _dragPoint = null;
    _ctrl.duration = const Duration(milliseconds: 600);
    _ctrl.forward(from: 0);
  }

  void _flipBack() {
    if (_ctrl.isAnimating || _spread <= 0) return;
    _spread--;
    _snapBack = false;
    _animatingForward = true;
    _dragPoint = null;
    _ctrl.duration = const Duration(milliseconds: 600);
    _ctrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFBBBBBB),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          _computeBookGeometry(size);

          return Stack(
            children: [
              GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: AnimatedBuilder(
                  animation: _ctrl,
                  builder: (ctx, child) {
                    Offset? effectiveDrag = _dragPoint;
                    double autoProgress = -1;

                    if (_ctrl.isAnimating || _ctrl.isCompleted && _ctrl.value == 1.0) {
                      if (_snapBack) {
                        // Animate from drag point back to corner.
                        final corner = Offset(_bookRect.right, _bookRect.bottom);
                        if (_dragPoint != null) {
                          effectiveDrag = Offset.lerp(_dragPoint, corner, Curves.easeOut.transform(_ctrl.value));
                        }
                      } else {
                        autoProgress = Curves.easeInOut.transform(_ctrl.value);
                        effectiveDrag = null;
                      }
                    }

                    return CustomPaint(
                      size: size,
                      painter: BookPainter(
                        pages: kBookPages,
                        currentSpread: _spread,
                        dragPoint: effectiveDrag,
                        autoFlipProgress: autoProgress,
                        flippingForward: _animatingForward,
                      ),
                    );
                  },
                ),
              ),

              // Bottom controls.
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: _BottomControls(
                  spread: _spread,
                  maxSpread: _maxSpread,
                  onPrev: _flipBack,
                  onNext: _flipForward,
                  onSliderChanged: (v) {
                    if (!_ctrl.isAnimating && !_isDragging) {
                      setState(() {
                        _spread = v;
                        _dragPoint = null;
                      });
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  final int spread;
  final int maxSpread;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<int> onSliderChanged;

  const _BottomControls({
    required this.spread,
    required this.maxSpread,
    required this.onPrev,
    required this.onNext,
    required this.onSliderChanged,
  });

  @override
  Widget build(BuildContext context) {
    final leftPage = spread * 2 + 1;
    final rightPage = spread * 2 + 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: onPrev,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.chevron_left,
                color: spread > 0 ? Colors.black54 : Colors.black12,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                activeTrackColor: Colors.black38,
                inactiveTrackColor: Colors.black12,
                thumbColor: Colors.white,
                overlayColor: Colors.black.withValues(alpha: 0.08),
              ),
              child: Slider(
                min: 0,
                max: maxSpread.toDouble(),
                divisions: maxSpread > 0 ? maxSpread : 1,
                value: spread.toDouble(),
                onChanged: (v) => onSliderChanged(v.round()),
              ),
            ),
          ),
          GestureDetector(
            onTap: onNext,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.chevron_right,
                color: spread < maxSpread ? Colors.black54 : Colors.black12,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$leftPage-$rightPage',
            style: const TextStyle(
              color: Colors.black45,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
