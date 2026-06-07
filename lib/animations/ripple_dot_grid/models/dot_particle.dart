import 'dart:ui';

/// A single dot in the ripple grid.
///
/// Each dot lives at its [home] position and is displaced by touch repulsion.
/// Spring physics continuously pull [pos] back toward [home].
class DotParticle {
  /// Fixed grid position — the attractor target for spring physics.
  final Offset home;

  /// Current render position (may differ from [home] when displaced).
  Offset pos;

  /// Current velocity in logical pixels per second.
  Offset vel;

  DotParticle(this.home)
      : pos = home,
        vel = Offset.zero;

  /// Returns true when the dot has essentially come to rest at home.
  bool get isAtRest {
    final d = pos - home;
    return d.distance < 0.1 && vel.distance < 0.1;
  }

  void reset() {
    pos = home;
    vel = Offset.zero;
  }
}
