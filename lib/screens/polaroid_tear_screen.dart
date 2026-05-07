import 'dart:math';
import 'package:flutter/material.dart';
import '../models/tear_state.dart';
import '../painters/tear_clipper.dart';
import '../utils/tear_path_generator.dart';
import '../widgets/delete_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/polaroid_card.dart';

// ── Card layout ──
const double _cardWidthRatio = 0.70;
const double _cardFramePadding = 14.0;
const double _cardBottomPadding = 50.0;
// ── Tear path ──
const int _tearSegmentCount = 50;
const double _tearMaxWobble = 30.0;
const double _tearMeanReversion = 0.25;
const double _tearFibrousAmplitude = 2.5;
const double _tearGapMax = 10.0;

// ── Durations ──
const Duration _separationDuration = Duration(milliseconds: 500);
const Duration _fallDuration = Duration(milliseconds: 600);
const Duration _dialogDuration = Duration(milliseconds: 300);
const Duration _dimDuration = Duration(milliseconds: 300);
const Duration _reverseDuration = Duration(milliseconds: 800);
const Duration _rejoinDuration = Duration(milliseconds: 400);

// ── Separation transforms ──
const double _leftSepTx = -20.0;
const double _leftSepTy = 30.0;
const double _leftSepRot = -8.0;
const double _rightSepTx = 30.0;
const double _rightSepTy = 20.0;
const double _rightSepRot = 12.0;

// ── Fall transforms (added to separation) ──
const double _leftFallTx = -40.0;
const double _leftFallRot = -17.0;
const double _rightFallTx = 50.0;
const double _rightFallRot = 18.0;
const double _fallGravityMul = 0.6;

// ── Colors ──
const Color _bgColor = Color(0xFFF5F5F5);
const Color _fabColor = Color(0xFFE85D6F);

// ── Tear threshold: fraction of card height torn to auto-complete ──
const double _tearCompleteThreshold = 0.35;

// ── How far the tear extends beyond finger (paper running ahead) ──
const double _tearExtensionFactor = 0.4;

class PolaroidTearScreen extends StatefulWidget {
  const PolaroidTearScreen({super.key});

  @override
  State<PolaroidTearScreen> createState() => _PolaroidTearScreenState();
}

class _PolaroidTearScreenState extends State<PolaroidTearScreen>
    with TickerProviderStateMixin {
  // ── State ──
  TearPhase _phase = TearPhase.idle;
  List<Offset> _tearPathLeft = [];
  List<Offset> _tearPathRight = [];
  int _tearSeed = 0;

  // ── Tear region (0–1 along card height) ──
  double _tearTopRatio = 0.0;
  double _tearBottomRatio = 0.0;
  double _tearOriginRatio = 0.5; // where on card the drag started
  double _cardHeight = 0.0;
  GlobalKey _cardKey = GlobalKey();

  // ── Saved values for animations ──
  double _rejoinStartTop = 0.0;
  double _rejoinStartBottom = 0.0;
  double _tearCompleteStartTop = 0.0;
  double _tearCompleteStartBottom = 0.0;

  // ── Animation controllers ──
  late final AnimationController _rejoinCtrl;
  late final AnimationController _tearCompleteCtrl;
  late final AnimationController _sepCtrl;
  late final AnimationController _fallCtrl;
  late final AnimationController _dialogCtrl;
  late final AnimationController _dimCtrl;

  // ── Curved animations ──
  late final Animation<double> _sepAnim;
  late final Animation<double> _fallAnim;

  @override
  void initState() {
    super.initState();

    _rejoinCtrl = AnimationController(vsync: this, duration: _rejoinDuration);
    _tearCompleteCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _sepCtrl = AnimationController(vsync: this, duration: _separationDuration);
    _fallCtrl = AnimationController(vsync: this, duration: _fallDuration);
    _dialogCtrl = AnimationController(vsync: this, duration: _dialogDuration);
    _dimCtrl = AnimationController(vsync: this, duration: _dimDuration);

    _sepAnim =
        CurvedAnimation(parent: _sepCtrl, curve: Curves.easeInCubic);
    _fallAnim =
        CurvedAnimation(parent: _fallCtrl, curve: Curves.easeInQuad);

    // Rejoin: animate top & bottom back to origin (collapse tear)
    _rejoinCtrl.addListener(() {
      final t = _rejoinCtrl.value;
      setState(() {
        _tearTopRatio =
            _rejoinStartTop + (_tearOriginRatio - _rejoinStartTop) * t;
        _tearBottomRatio =
            _rejoinStartBottom + (_tearOriginRatio - _rejoinStartBottom) * t;
      });
    });
    _rejoinCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && _phase == TearPhase.rejoining) {
        setState(() {
          _phase = TearPhase.idle;
          _tearTopRatio = 0.0;
          _tearBottomRatio = 0.0;
        });
      }
    });

    // Tear complete: animate top→0 and bottom→1
    _tearCompleteCtrl.addListener(() {
      final t = _tearCompleteCtrl.value;
      setState(() {
        _tearTopRatio = _tearCompleteStartTop * (1 - t);
        _tearBottomRatio =
            _tearCompleteStartBottom + (1.0 - _tearCompleteStartBottom) * t;
      });
    });
    _tearCompleteCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && _phase == TearPhase.tearing) {
        _phase = TearPhase.separating;
        _sepCtrl.forward();
      }
    });

    // Chain: separation → fall + dialog
    _sepCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && _phase == TearPhase.separating) {
        _phase = TearPhase.falling;
        _fallCtrl.forward();
        _dimCtrl.forward();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (_phase == TearPhase.falling ||
              _phase == TearPhase.dialogShowing) {
            _dialogCtrl.forward();
            setState(() => _phase = TearPhase.dialogShowing);
          }
        });
      }
    });

    // Rebuild on every tick
    for (final c in [
      _rejoinCtrl,
      _tearCompleteCtrl,
      _sepCtrl,
      _fallCtrl,
      _dialogCtrl,
      _dimCtrl,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _rejoinCtrl.dispose();
    _tearCompleteCtrl.dispose();
    _sepCtrl.dispose();
    _fallCtrl.dispose();
    _dialogCtrl.dispose();
    _dimCtrl.dispose();
    super.dispose();
  }

  // ── Responsive card width ──
  double _responsiveCardWidth(BuildContext context) {
    final screen = MediaQuery.of(context);
    final screenWidth = screen.size.width;
    final screenHeight = screen.size.height;
    final safeTop = screen.padding.top;

    // Max height available: screen minus top bar, safe area, FAB, and padding
    final maxCardHeight = screenHeight - safeTop - 56 - 80 - 40;

    // Width from ratio
    final widthFromRatio = screenWidth * _cardWidthRatio;

    // Card height = padding + photo (4:3) + bottom
    // cardHeight = 14 + (w - 28) * 4/3 + 50 = 64 + (w - 28) * 4/3
    // Solve for w: w = (maxCardHeight - 64) * 3/4 + 28
    final widthFromHeight = (maxCardHeight - 64) * 3 / 4 + 28;

    return min(widthFromRatio, widthFromHeight).clamp(200.0, screenWidth * 0.9);
  }

  double _cardHeightFromWidth(double cardWidth) {
    final photoHeight = (cardWidth - _cardFramePadding * 2) * 4 / 3;
    return _cardFramePadding + photoHeight + _cardBottomPadding;
  }

  // ── Drag handlers ──

  void _onDragStart(DragStartDetails details) {
    if (_phase != TearPhase.idle) return;

    final cardWidth = _responsiveCardWidth(context);
    final ch = _cardHeightFromWidth(cardWidth);
    final cardRect = Rect.fromLTWH(0, 0, cardWidth, ch);

    _tearSeed = DateTime.now().millisecondsSinceEpoch;
    _tearPathLeft = addFibrousEdge(
      generateTearPath(
        cardRect,
        _tearSeed,
        segmentCount: _tearSegmentCount,
        maxWobble: _tearMaxWobble,
        meanReversion: _tearMeanReversion,
      ),
      _tearFibrousAmplitude,
      _tearSeed,
    );
    _tearPathRight = addFibrousEdge(
      generateTearPath(
        cardRect,
        _tearSeed,
        segmentCount: _tearSegmentCount,
        maxWobble: _tearMaxWobble,
        meanReversion: _tearMeanReversion,
      ),
      _tearFibrousAmplitude,
      _tearSeed + 1,
    );

    _cardHeight = ch;
    _tearTopRatio = 0.0;
    _tearBottomRatio = 0.0;

    // Where on card the user touched
    final cardBox = _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (cardBox != null) {
      final cardTopY = cardBox.localToGlobal(Offset.zero).dy;
      final touchLocalY = details.globalPosition.dy - cardTopY;
      _tearOriginRatio = (touchLocalY / ch).clamp(0.0, 1.0);
    } else {
      _tearOriginRatio = 0.5;
    }

    setState(() => _phase = TearPhase.dragging);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_phase != TearPhase.dragging) return;

    // Current finger position relative to card
    final cardBox = _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (cardBox == null) return;

    final cardTopY = cardBox.localToGlobal(Offset.zero).dy;
    final fingerLocalY = details.globalPosition.dy - cardTopY;
    final fingerRatio = (fingerLocalY / _cardHeight).clamp(0.0, 1.0);

    // Tear spans from start to finger
    final rawTop = min(_tearOriginRatio, fingerRatio);
    final rawBottom = max(_tearOriginRatio, fingerRatio);

    // Extend beyond finger for natural "paper running ahead" feel
    final range = rawBottom - rawTop;
    final extension = range * _tearExtensionFactor;

    setState(() {
      _tearTopRatio = (rawTop - extension).clamp(0.0, 1.0);
      _tearBottomRatio = (rawBottom + extension).clamp(0.0, 1.0);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_phase != TearPhase.dragging) return;

    final coverage = _tearBottomRatio - _tearTopRatio;

    if (coverage >= _tearCompleteThreshold) {
      // Complete the tear
      _tearCompleteStartTop = _tearTopRatio;
      _tearCompleteStartBottom = _tearBottomRatio;
      setState(() => _phase = TearPhase.tearing);
      _tearCompleteCtrl.forward(from: 0);
    } else {
      // Rejoin
      _rejoinStartTop = _tearTopRatio;
      _rejoinStartBottom = _tearBottomRatio;
      setState(() => _phase = TearPhase.rejoining);
      _rejoinCtrl.forward(from: 0);
    }
  }

  // ── Cancel / Delete ──

  void _onCancel() {
    if (_phase != TearPhase.dialogShowing) return;
    setState(() => _phase = TearPhase.reversing);

    _dialogCtrl.reverse();
    _dimCtrl.reverse();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      _fallCtrl.animateBack(0,
          duration: _reverseDuration, curve: Curves.easeOutCubic);
      _sepCtrl.animateBack(0,
          duration: _reverseDuration, curve: Curves.easeOutCubic);

      // After separation reverses, rejoin the tear
      Future.delayed(_reverseDuration * 0.6, () {
        if (!mounted) return;
        _rejoinStartTop = _tearTopRatio;
        _rejoinStartBottom = _tearBottomRatio;
        _rejoinCtrl.forward(from: 0);
      });

      Future.delayed(_reverseDuration + _rejoinDuration, () {
        if (mounted) {
          setState(() {
            _phase = TearPhase.idle;
            _tearTopRatio = 0.0;
            _tearBottomRatio = 0.0;
            _tearCompleteCtrl.reset();
            _sepCtrl.reset();
            _fallCtrl.reset();
          });
        }
      });
    });
  }

  void _onConfirmDelete() {
    if (_phase != TearPhase.dialogShowing) return;
    _dialogCtrl.reverse();
    _dimCtrl.reverse();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _phase = TearPhase.deleted);
    });
  }

  // ── Trash icon triggers instant tear ──
  void _onTrashTapped() {
    if (_phase != TearPhase.idle) return;

    final cardWidth = _responsiveCardWidth(context);
    final ch = _cardHeightFromWidth(cardWidth);
    final cardRect = Rect.fromLTWH(0, 0, cardWidth, ch);

    _tearSeed = DateTime.now().millisecondsSinceEpoch;
    _tearPathLeft = addFibrousEdge(
      generateTearPath(cardRect, _tearSeed,
          segmentCount: _tearSegmentCount,
          maxWobble: _tearMaxWobble,
          meanReversion: _tearMeanReversion),
      _tearFibrousAmplitude,
      _tearSeed,
    );
    _tearPathRight = addFibrousEdge(
      generateTearPath(cardRect, _tearSeed,
          segmentCount: _tearSegmentCount,
          maxWobble: _tearMaxWobble,
          meanReversion: _tearMeanReversion),
      _tearFibrousAmplitude,
      _tearSeed + 1,
    );

    _cardHeight = ch;
    _tearOriginRatio = 0.5;
    _tearTopRatio = 0.5;
    _tearBottomRatio = 0.5;
    _tearCompleteStartTop = 0.5;
    _tearCompleteStartBottom = 0.5;
    setState(() => _phase = TearPhase.tearing);
    _tearCompleteCtrl.forward(from: 0);
  }

  // ── Transform helpers ──

  Matrix4 _leftTransform(double cardWidth, double cardHeight) {
    final sep = _sepAnim.value;
    final fall = _fallAnim.value;
    final screenH = MediaQuery.of(context).size.height;

    final tx = _leftSepTx * sep + _leftFallTx * fall;
    final ty = _leftSepTy * sep + screenH * _fallGravityMul * fall * fall;
    final angle =
        (_leftSepRot * sep + _leftFallRot * fall) * (pi / 180);

    return Matrix4.identity()
      ..translate(tx, ty)
      ..rotateZ(angle);
  }

  Matrix4 _rightTransform(double cardWidth, double cardHeight) {
    final sep = _sepAnim.value;
    final fall = _fallAnim.value;
    final screenH = MediaQuery.of(context).size.height;

    final tx = _rightSepTx * sep + _rightFallTx * fall;
    final ty = _rightSepTy * sep + screenH * _fallGravityMul * fall * fall;
    final angle =
        (_rightSepRot * sep + _rightFallRot * fall) * (pi / 180);

    return Matrix4.identity()
      ..translate(tx, ty)
      ..translate(cardWidth, 0.0)
      ..rotateZ(angle)
      ..translate(-cardWidth, 0.0);
  }

  // ── Effective tear coverage for gap width ──
  double get _tearCoverage => (_tearBottomRatio - _tearTopRatio).clamp(0.0, 1.0);

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    if (_phase == TearPhase.deleted) {
      return Scaffold(
        backgroundColor: _bgColor,
        body: EmptyState(
          onBack: () => Navigator.of(context).pop(),
        ),
        floatingActionButton: _buildFab(),
      );
    }

    final cardWidth = _responsiveCardWidth(context);
    final cardHeight = _cardHeightFromWidth(cardWidth);

    final gapWidth = _tearGapMax * _tearCoverage;
    final isAnimating = _phase != TearPhase.idle;

    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          // ── Top bar ──
          SafeArea(
            bottom: false,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _onTrashTapped,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.delete_outline,
                          size: 20, color: Color(0xFF1A1A1A)),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Selected Day',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),

          // ── Card (idle — draggable) ──
          if (!isAnimating)
            Center(
              child: GestureDetector(
                onVerticalDragStart: _onDragStart,
                onVerticalDragUpdate: _onDragUpdate,
                onVerticalDragEnd: _onDragEnd,
                child: PolaroidCard(key: _cardKey, cardWidth: cardWidth),
              ),
            ),

          // ── Card while dragging / tearing / animating ──
          if (isAnimating) ...[
            // Left half
            Center(
              child: Transform(
                transform: _leftTransform(cardWidth, cardHeight),
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onVerticalDragUpdate: _onDragUpdate,
                  onVerticalDragEnd: _onDragEnd,
                  child: ClipPath(
                    clipper: TearClipper(
                      tearPoints: _tearPathLeft,
                      tearTopRatio: _tearTopRatio,
                      tearBottomRatio: _tearBottomRatio,
                      side: TearSide.left,
                      gapOffset: -gapWidth / 2,
                    ),
                    child: PolaroidCard(cardWidth: cardWidth),
                  ),
                ),
              ),
            ),
            // Right half
            Center(
              child: Transform(
                transform: _rightTransform(cardWidth, cardHeight),
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onVerticalDragUpdate: _onDragUpdate,
                  onVerticalDragEnd: _onDragEnd,
                  child: ClipPath(
                    clipper: TearClipper(
                      tearPoints: _tearPathRight,
                      tearTopRatio: _tearTopRatio,
                      tearBottomRatio: _tearBottomRatio,
                      side: TearSide.right,
                      gapOffset: gapWidth / 2,
                    ),
                    child: PolaroidCard(cardWidth: cardWidth),
                  ),
                ),
              ),
            ),
          ],

          // ── Dim overlay ──
          if (_dimCtrl.value > 0)
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color:
                      Colors.black.withOpacity(_dimCtrl.value * 0.3),
                ),
              ),
            ),

          // ── Dialog ──
          if (_dialogCtrl.value > 0)
            DeleteDialog(
              animationValue: _dialogCtrl.value,
              onCancel: _onCancel,
              onDelete: _onConfirmDelete,
            ),

          // ── Bottom chevron ──
          if (!isAnimating)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Icon(
                  Icons.expand_more,
                  color: Colors.grey.withOpacity(0.4),
                  size: 28,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildFab() {
    return SizedBox(
      width: 60,
      height: 60,
      child: FloatingActionButton(
        onPressed: () {},
        backgroundColor: _fabColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }
}
