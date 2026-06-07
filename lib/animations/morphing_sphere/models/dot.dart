import 'dart:math';

import 'package:flutter/material.dart';

/// A single point with a fixed random position inside a unit sphere.
///
/// Stores the "chaos" coordinates that a dot starts from before morphing
/// towards its golden-angle sphere target.
class Dot {
  final double randomX;
  final double randomY;
  final double randomZ;

  const Dot({
    required this.randomX,
    required this.randomY,
    required this.randomZ,
  });
}

/// Generates a [Dot] at a uniformly random position inside a unit sphere.
///
/// Uses spherical coordinates for even volumetric distribution:
/// - θ ∈ [0, 2π] covers the full azimuthal angle.
/// - φ via acos(2v − 1) avoids pole-clustering from a naive random φ.
/// - radius is cube-root scaled so density stays constant through the volume.
Dot generateRandomDot(Random rng) {
  final u = rng.nextDouble();
  final v = rng.nextDouble();
  final theta = u * 2 * pi;
  final phi = acos(2 * v - 1);
  final r = pow(rng.nextDouble(), 1.0 / 3.0).toDouble();
  return Dot(
    randomX: r * sin(phi) * cos(theta),
    randomY: r * sin(phi) * sin(theta),
    randomZ: r * cos(phi),
  );
}

/// Standard linear interpolation.
double lerp(double from, double to, double t) => from * (1 - t) + to * t;

/// Linearly blends two [Color] values in sRGB space.
///
/// Used for the staggered wave-colour transitions across the sphere surface.
Color blendColor(Color c1, Color c2, double t) {
  return Color.fromARGB(
    255,
    (c1.red + (c2.red - c1.red) * t).round().clamp(0, 255),
    (c1.green + (c2.green - c1.green) * t).round().clamp(0, 255),
    (c1.blue + (c2.blue - c1.blue) * t).round().clamp(0, 255),
  );
}
