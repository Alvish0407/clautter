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
const Duration _tearDuration = Duration(milliseconds: 600);
const Duration _separationDuration = Duration(milliseconds: 500);
const Duration _fallDuration = Duration(milliseconds: 600);
const Duration _dialogDuration = Duration(milliseconds: 300);
const Duration _dimDuration = Duration(milliseconds: 300);
const Duration _reverseDuration = Duration(milliseconds: 800);

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

  // ── Animation controllers ──
  late final AnimationController _tearCtrl;
  late final AnimationController _sepCtrl;
  late final AnimationController _fallCtrl;
  late final AnimationController _dialogCtrl;
  late final AnimationController _dimCtrl;

  // ── Curved animations ──
  late final Animation<double> _tearAnim;
  late final Animation<double> _sepAnim;
  late final Animation<double> _fallAnim;

  @override
  void initState() {
    super.initState();

    _tearCtrl = AnimationController(vsync: this, duration: _tearDuration);
    _sepCtrl = AnimationController(vsync: this, duration: _separationDuration);
    _fallCtrl = AnimationController(vsync: this, duration: _fallDuration);
    _dialogCtrl = AnimationController(vsync: this, duration: _dialogDuration);
    _dimCtrl = AnimationController(vsync: this, duration: _dimDuration);

    _tearAnim =
        CurvedAnimation(parent: _tearCtrl, curve: Curves.easeInOut);
    _sepAnim =
        CurvedAnimation(parent: _sepCtrl, curve: Curves.easeInCubic);
    _fallAnim =
        CurvedAnimation(parent: _fallCtrl, curve: Curves.easeInQuad);

    // Chain: tear → separation → fall + dialog
    _tearCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && _phase == TearPhase.tearing) {
        _phase = TearPhase.separating;
        _sepCtrl.forward();
      }
    });

    _sepCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && _phase == TearPhase.separating) {
        _phase = TearPhase.falling;
        _fallCtrl.forward();
        _dimCtrl.forward();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (_phase == TearPhase.falling || _phase == TearPhase.dialogShowing) {
            _dialogCtrl.forward();
            setState(() => _phase = TearPhase.dialogShowing);
          }
        });
      }
    });

    // Rebuild on every tick
    for (final c in [_tearCtrl, _sepCtrl, _fallCtrl, _dialogCtrl, _dimCtrl]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _tearCtrl.dispose();
    _sepCtrl.dispose();
    _fallCtrl.dispose();
    _dialogCtrl.dispose();
    _dimCtrl.dispose();
    super.dispose();
  }

  // ── Actions ──

  void _onTrashTapped() {
    if (_phase != TearPhase.idle) return;

    _tearSeed = DateTime.now().millisecondsSinceEpoch;

    // Card rect in local coords (centered horizontally)
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * _cardWidthRatio;
    final photoHeight = (cardWidth - _cardFramePadding * 2) * 4 / 3;
    final cardHeight =
        _cardFramePadding + photoHeight + _cardBottomPadding;
    final cardRect = Rect.fromLTWH(0, 0, cardWidth, cardHeight);

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
      _tearSeed + 1, // Different jitter seed → mismatched edges
    );

    setState(() => _phase = TearPhase.tearing);
    _tearCtrl.forward(from: 0);
  }

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
      _tearCtrl
          .animateBack(0,
              duration: _reverseDuration, curve: Curves.easeOutCubic)
          .then((_) {
        if (mounted) setState(() => _phase = TearPhase.idle);
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

    final gapWidth = _tearGapMax * _tearAnim.value;
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
                  const SizedBox(width: 40), // Balance the row
                ],
              ),
            ),
          ),

          // ── Card (idle or animating) ──
          if (!isAnimating)
            Center(
              child: PolaroidCard(cardWidth: cardWidth),
            ),

          if (isAnimating) ...[
            // Left half
            Center(
              child: Transform(
                transform: _leftTransform(cardWidth, cardHeight),
                alignment: Alignment.topLeft,
                child: ClipPath(
                  clipper: TearClipper(
                    tearPoints: _tearPathLeft,
                    tearProgress: _tearAnim.value,
                    side: TearSide.left,
                    gapOffset: -gapWidth / 2,
                  ),
                  child: PolaroidCard(cardWidth: cardWidth),
                ),
              ),
            ),
            // Right half
            Center(
              child: Transform(
                transform: _rightTransform(cardWidth, cardHeight),
                alignment: Alignment.topRight,
                child: ClipPath(
                  clipper: TearClipper(
                    tearPoints: _tearPathRight,
                    tearProgress: _tearAnim.value,
                    side: TearSide.right,
                    gapOffset: gapWidth / 2,
                  ),
                  child: PolaroidCard(cardWidth: cardWidth),
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
