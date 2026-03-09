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

// ── Drag threshold to complete tear ──
const double _tearCompleteThreshold = 0.85;

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

  // ── Drag-driven tear progress (0.0 → 1.0) ──
  double _dragTearProgress = 0.0;
  double _dragStartY = 0.0;
  double _cardHeight = 0.0;
  GlobalKey _cardKey = GlobalKey();

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

    // Rejoin animation: animate _dragTearProgress back to 0
    _rejoinCtrl.addListener(() {
      setState(() {
        _dragTearProgress = _rejoinStartValue * (1 - _rejoinCtrl.value);
      });
    });
    _rejoinCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && _phase == TearPhase.rejoining) {
        setState(() {
          _phase = TearPhase.idle;
          _dragTearProgress = 0.0;
        });
      }
    });

    // Tear complete animation: animate from current drag progress to 1.0
    _tearCompleteCtrl.addListener(() {
      setState(() {
        _dragTearProgress =
            _tearCompleteStartValue + (1.0 - _tearCompleteStartValue) * _tearCompleteCtrl.value;
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

  double _rejoinStartValue = 0.0;
  double _tearCompleteStartValue = 0.0;

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

  // ── Drag handlers ──

  void _onDragStart(DragStartDetails details) {
    if (_phase != TearPhase.idle) return;

    // Generate tear path
    _tearSeed = DateTime.now().millisecondsSinceEpoch;

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * _cardWidthRatio;
    final photoHeight = (cardWidth - _cardFramePadding * 2) * 4 / 3;
    final ch = _cardFramePadding + photoHeight + _cardBottomPadding;
    final cardRect = Rect.fromLTWH(0, 0, cardWidth, ch);

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
    _dragStartY = details.globalPosition.dy;
    _dragTearProgress = 0.0;

    setState(() => _phase = TearPhase.dragging);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_phase != TearPhase.dragging) return;

    final dy = details.globalPosition.dy - _dragStartY;
    setState(() {
      _dragTearProgress = (dy / _cardHeight).clamp(0.0, 1.0);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_phase != TearPhase.dragging) return;

    if (_dragTearProgress >= _tearCompleteThreshold) {
      // Complete the tear
      _tearCompleteStartValue = _dragTearProgress;
      setState(() => _phase = TearPhase.tearing);
      _tearCompleteCtrl.forward(from: 0);
    } else {
      // Rejoin the paper
      _rejoinStartValue = _dragTearProgress;
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
        _rejoinStartValue = _dragTearProgress;
        _rejoinCtrl.forward(from: 0);
      });

      Future.delayed(_reverseDuration + _rejoinDuration, () {
        if (mounted) {
          setState(() {
            _phase = TearPhase.idle;
            _dragTearProgress = 0.0;
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

    _tearSeed = DateTime.now().millisecondsSinceEpoch;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * _cardWidthRatio;
    final photoHeight = (cardWidth - _cardFramePadding * 2) * 4 / 3;
    final ch = _cardFramePadding + photoHeight + _cardBottomPadding;
    final cardRect = Rect.fromLTWH(0, 0, cardWidth, ch);

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
    _dragTearProgress = 0.0;
    _tearCompleteStartValue = 0.0;
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

  // ── Effective tear progress ──
  double get _effectiveTearProgress => _dragTearProgress;

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

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * _cardWidthRatio;
    final photoHeight = (cardWidth - _cardFramePadding * 2) * 4 / 3;
    final cardHeight =
        _cardFramePadding + photoHeight + _cardBottomPadding;

    final tearProgress = _effectiveTearProgress;
    final gapWidth = _tearGapMax * tearProgress;
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
                      tearProgress: tearProgress,
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
                      tearProgress: tearProgress,
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
