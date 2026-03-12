import 'dart:math';
import 'package:flutter/material.dart';
import '../models/chip_data.dart';

const double gravityY = 800.0;
const double bounceFactor = 0.8;
const double friction = 0.98;
const double sleepThreshold = 5.0;
const double spawnDelay = 1.0;
const double spawnStagger = 0.01;
const double spawnYOffset = -200.0;
const double chipHeight = 44.0;
const double chipHPadding = 18.0;
const double chipIconSize = 20.0;
const double chipFontSize = 17.0;
const double chipSpacing = 12.0;

class PhysicsChip {
  final ChipData data;
  Offset position;
  Offset velocity;
  final Size size;
  final double cornerRadius;
  double alpha;
  bool isSelected;
  bool isSleeping;

  PhysicsChip({
    required this.data,
    required this.position,
    required this.velocity,
    required this.size,
    required this.cornerRadius,
    this.alpha = 0.0,
    this.isSelected = false,
    this.isSleeping = false,
  });

  Rect get rect => Rect.fromCenter(
    center: position,
    width: size.width,
    height: size.height,
  );
}

double measureChipWidth(ChipData chip) {
  final textPainter = TextPainter(
    text: TextSpan(
      text: chip.title,
      style: const TextStyle(fontSize: chipFontSize, fontWeight: FontWeight.bold),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  return chipIconSize + chipSpacing + textPainter.width + chipHPadding * 2;
}

class ChipPhysicsEngine {
  final List<PhysicsChip> chips = [];
  final Random _random = Random();

  double containerLeft = 0;
  double containerRight = 0;
  double containerBottom = 0;
  double containerTop = 0;

  void setContainerBounds(double left, double top, double right, double bottom) {
    containerLeft = left;
    containerTop = top;
    containerRight = right;
    containerBottom = bottom;
  }

  void spawnChips(List<ChipData> chipDataList, VoidCallback onUpdate) {
    for (int i = 0; i < chipDataList.length; i++) {
      final delay = spawnDelay + (spawnStagger * i);
      Future.delayed(Duration(milliseconds: (delay * 1000).round()), () {
        final chipWidth = measureChipWidth(chipDataList[i]);
        final maxX = containerRight - chipWidth / 2 - 16;
        final minX = containerLeft + chipWidth / 2 + 16;
        final x = minX + _random.nextDouble() * (maxX - minX).clamp(0, double.infinity);
        final spawnY = containerTop + spawnYOffset;

        chips.add(PhysicsChip(
          data: chipDataList[i],
          position: Offset(x, spawnY),
          velocity: Offset.zero,
          size: Size(chipWidth, chipHeight),
          cornerRadius: chipHeight / 2,
        ));
        onUpdate();
      });
    }
  }

  void update(double dt) {
    final clampedDt = dt.clamp(0.0, 0.033);

    for (final chip in chips) {
      if (chip.isSleeping) continue;

      // Gravity
      chip.velocity = Offset(
        chip.velocity.dx,
        chip.velocity.dy + gravityY * clampedDt,
      );

      // Friction
      chip.velocity = chip.velocity * friction;

      // Position
      chip.position = chip.position + chip.velocity * clampedDt;

      // Fade in
      chip.alpha = (chip.alpha + clampedDt * 4.0).clamp(0.0, 1.0);

      // Boundary collisions
      _resolveBoundary(chip);
    }

    // Chip-to-chip collisions
    for (int i = 0; i < chips.length; i++) {
      for (int j = i + 1; j < chips.length; j++) {
        _resolveCollision(chips[i], chips[j]);
      }
    }

    // Sleep check
    for (final chip in chips) {
      if (!chip.isSleeping &&
          chip.velocity.distance < sleepThreshold &&
          chip.position.dy >= containerBottom - chip.size.height / 2 - 5) {
        chip.isSleeping = true;
      }
    }
  }

  void _resolveBoundary(PhysicsChip chip) {
    final halfW = chip.size.width / 2;
    final halfH = chip.size.height / 2;

    // Bottom wall
    if (chip.position.dy + halfH > containerBottom) {
      chip.position = Offset(chip.position.dx, containerBottom - halfH);
      chip.velocity = Offset(
        chip.velocity.dx,
        -chip.velocity.dy.abs() * bounceFactor,
      );
    }

    // Left wall
    if (chip.position.dx - halfW < containerLeft) {
      chip.position = Offset(containerLeft + halfW, chip.position.dy);
      chip.velocity = Offset(
        chip.velocity.dx.abs() * bounceFactor,
        chip.velocity.dy,
      );
    }

    // Right wall
    if (chip.position.dx + halfW > containerRight) {
      chip.position = Offset(containerRight - halfW, chip.position.dy);
      chip.velocity = Offset(
        -chip.velocity.dx.abs() * bounceFactor,
        chip.velocity.dy,
      );
    }
  }

  void _resolveCollision(PhysicsChip a, PhysicsChip b) {
    final aRect = a.rect;
    final bRect = b.rect;

    if (!aRect.overlaps(bRect)) return;

    final overlapX = (aRect.width / 2 + bRect.width / 2) -
        (a.position.dx - b.position.dx).abs();
    final overlapY = (aRect.height / 2 + bRect.height / 2) -
        (a.position.dy - b.position.dy).abs();

    if (overlapX <= 0 || overlapY <= 0) return;

    if (overlapX < overlapY) {
      final sign = (a.position.dx > b.position.dx) ? 1.0 : -1.0;
      a.position = Offset(a.position.dx + sign * overlapX / 2, a.position.dy);
      b.position = Offset(b.position.dx - sign * overlapX / 2, b.position.dy);

      final tempVx = a.velocity.dx;
      a.velocity = Offset(b.velocity.dx * bounceFactor, a.velocity.dy);
      b.velocity = Offset(tempVx * bounceFactor, b.velocity.dy);

      // Wake up chips on collision
      a.isSleeping = false;
      b.isSleeping = false;
    } else {
      final sign = (a.position.dy > b.position.dy) ? 1.0 : -1.0;
      a.position = Offset(a.position.dx, a.position.dy + sign * overlapY / 2);
      b.position = Offset(b.position.dx, b.position.dy - sign * overlapY / 2);

      final tempVy = a.velocity.dy;
      a.velocity = Offset(a.velocity.dx, b.velocity.dy * bounceFactor);
      b.velocity = Offset(b.velocity.dx, tempVy * bounceFactor);

      a.isSleeping = false;
      b.isSleeping = false;
    }
  }

  PhysicsChip? hitTest(Offset position) {
    for (int i = chips.length - 1; i >= 0; i--) {
      if (chips[i].rect.contains(position)) {
        return chips[i];
      }
    }
    return null;
  }
}
