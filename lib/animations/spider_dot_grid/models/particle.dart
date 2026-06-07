import 'dart:math';
import 'package:flutter/material.dart';

/// A single particle in the spider-web drift simulation.
///
/// [position] and [velocity] are mutable so [stepParticle] can update
/// them in-place each tick, avoiding per-frame allocation.
class Particle {
  Offset position;
  Offset velocity;

  Particle({required this.position, required this.velocity});
}

/// Creates a [Particle] at a random position within [size].
///
/// Velocity direction is uniformly random; magnitude is in the range
/// [speed × 0.5, speed × 1.5] pixels per second.
Particle randomParticle(Random rng, Size size, {double speed = 60.0}) {
  final angle = rng.nextDouble() * 2 * pi;
  final magnitude = speed * (0.5 + rng.nextDouble());
  return Particle(
    position: Offset(
      rng.nextDouble() * size.width,
      rng.nextDouble() * size.height,
    ),
    velocity: Offset(cos(angle) * magnitude, sin(angle) * magnitude),
  );
}

/// Advances [particle] forward by [dt] seconds using Euler integration
/// and reflects it off the [bounds] edges (perfectly elastic bounce).
void stepParticle(Particle particle, double dt, Size bounds) {
  particle.position += particle.velocity * dt;

  if (particle.position.dx < 0) {
    particle.position = Offset(0, particle.position.dy);
    particle.velocity = Offset(-particle.velocity.dx, particle.velocity.dy);
  } else if (particle.position.dx > bounds.width) {
    particle.position = Offset(bounds.width, particle.position.dy);
    particle.velocity = Offset(-particle.velocity.dx, particle.velocity.dy);
  }

  if (particle.position.dy < 0) {
    particle.position = Offset(particle.position.dx, 0);
    particle.velocity = Offset(particle.velocity.dx, -particle.velocity.dy);
  } else if (particle.position.dy > bounds.height) {
    particle.position = Offset(particle.position.dx, bounds.height);
    particle.velocity = Offset(particle.velocity.dx, -particle.velocity.dy);
  }
}
