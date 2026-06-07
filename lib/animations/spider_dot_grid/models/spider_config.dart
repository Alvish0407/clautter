import 'package:flutter/material.dart';

// ─── Dimensions ──────────────────────────────────────────────────────────────

const double kGridDotSize = 6.0;
const double kBodyWidth = 30.0;
const double kBodyHeight = 24.0;
const double kBodyPlateSize = 14.0;

/// Distance from body centre to each plate attachment point.
const double kBodyPlateOffset = 18.0;

const double kUpperLegLength = 45.0;
const double kLowerLegLength = 45.0;

/// How far from the body centre each foot rests at idle.
const double kLegRestDistance = 80.0;

/// A foot must drift this far from its ideal grid position before a step fires.
const double kStepThreshold = 55.0;

/// Duration of one foot-arc animation (seconds).
const double kStepDuration = 0.12;

/// Maximum vertical lift at the midpoint of a step arc.
const double kStepLiftHeight = 8.0;

/// Lerp factor applied each frame to smooth body movement toward the target.
const double kBodyFollowSpeed = 0.08;

const double kFootSize = 8.0;
const double kKneeJointSize = 6.0;
const double kLegStrokeWidth = 1.8;

// ─── Colours ─────────────────────────────────────────────────────────────────

const Color kBackgroundColor = Color(0xFFF5F5F5);
const Color kGridDotColor = Color(0xFF4A4A4A);
const Color kBodyColor = Color(0xFF2A2A2A);
const Color kLegColor = Color(0xFFD06060);
const Color kFootColor = Color(0xFF3A3A3A);

// ─── Per-leg configuration ────────────────────────────────────────────────────

/// Rest angles for all 8 legs in radians, measured from the body centre.
const List<double> kLegRestAngles = [
  -2.5, // Leg 0: ~NW
  -1.9, // Leg 1: ~NNW
  -1.2, // Leg 2: ~NNE
  -0.6, // Leg 3: ~NE
  0.6, // Leg 4: ~SE
  1.2, // Leg 5: ~SSE
  1.9, // Leg 6: ~SSW
  2.5, // Leg 7: ~SW
];

/// Which body plate each leg attaches to: 0 = N, 1 = E, 2 = S, 3 = W.
const List<int> kLegPlateIndex = [3, 0, 0, 1, 1, 2, 2, 3];

/// Knee bend direction per leg.
/// true = bend left (CCW from hip→foot), false = bend right (CW).
const List<bool> kLegBendLeft = [
  true, // 0
  true, // 1
  false, // 2
  false, // 3
  true, // 4
  true, // 5
  false, // 6
  false, // 7
];
