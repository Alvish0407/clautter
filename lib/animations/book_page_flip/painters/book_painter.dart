import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/page_data.dart';

class BookPainter extends CustomPainter {
  final List<PageData> pages;
  final int currentSpread;
  final Offset? dragPoint;
  final double autoFlipProgress;
  final bool flippingForward;

  BookPainter({
    required this.pages,
    required this.currentSpread,
    this.dragPoint,
    this.autoFlipProgress = -1,
    this.flippingForward = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final bookW = size.width * 0.82;
    final bookH = bookW * 0.68;
    final pageW = bookW / 2;
    final bookLeft = cx - bookW / 2;
    final bookTop = cy - bookH / 2;
    final bookRight = bookLeft + bookW;
    final bookBottom = bookTop + bookH;

    final leftRect = Rect.fromLTWH(bookLeft, bookTop, pageW, bookH);
    final rightRect = Rect.fromLTWH(cx, bookTop, pageW, bookH);

    final leftIdx = currentSpread * 2;
    final rightIdx = leftIdx + 1;
    final leftPage = leftIdx < pages.length ? pages[leftIdx] : null;
    final rightPage = rightIdx < pages.length ? pages[rightIdx] : null;

    // Book shadow.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bookLeft + 4, bookTop + 6, bookW, bookH),
        const Radius.circular(3),
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    // Book cover (dark border).
    final coverRect = Rect.fromLTWH(bookLeft - 6, bookTop - 6, bookW + 12, bookH + 12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(coverRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFF2C2C2C),
    );

    // Page edge stack (visible thickness of pages).
    for (int i = 3; i >= 1; i--) {
      final offset = i * 1.5;
      canvas.drawRect(
        Rect.fromLTWH(bookLeft + offset, bookTop + offset, bookW - offset * 2, bookH - offset * 2),
        Paint()..color = Color.fromRGBO(240 - i * 8, 238 - i * 8, 232 - i * 8, 1),
      );
    }

    // Determine if we're flipping.
    Offset? effectiveDrag;
    if (autoFlipProgress >= 0) {
      final cornerBR = Offset(bookRight, bookBottom);
      final target = Offset(bookLeft - pageW * 0.15, bookBottom - bookH * 0.1);
      if (flippingForward) {
        effectiveDrag = Offset.lerp(cornerBR, target, autoFlipProgress);
      } else {
        effectiveDrag = Offset.lerp(target, cornerBR, 1 - autoFlipProgress);
      }
    } else if (dragPoint != null) {
      effectiveDrag = dragPoint;
    }

    final isFlipping = effectiveDrag != null;
    final nextLeftIdx = leftIdx + 2;
    final nextRightIdx = leftIdx + 3;

    // Always draw the current spread's left page.
    if (leftPage != null) _drawPage(canvas, leftRect, leftPage, isLeft: true);

    if (isFlipping && flippingForward) {
      // The next spread's left page sits under the right area while the fold travels across.
      final underRight = nextLeftIdx < pages.length ? pages[nextLeftIdx] : null;
      if (underRight != null) _drawPage(canvas, rightRect, underRight, isLeft: false);
    } else {
      // Not flipping: draw the current right page normally.
      if (rightPage != null) _drawPage(canvas, rightRect, rightPage, isLeft: false);
    }

    // Spine.
    _drawSpine(canvas, cx, bookTop, bookH);

    // Draw fold if dragging or animating.
    if (effectiveDrag != null && rightPage != null) {
      final nextPage = nextLeftIdx < pages.length ? pages[nextLeftIdx] : null;
      _drawFold(
        canvas,
        effectiveDrag,
        rightRect,
        rightPage,
        nextPage,
        bookLeft,
        bookTop,
        bookRight,
        bookBottom,
        pageW,
        bookH,
        cx,
      );
    }

    // Book border.
    canvas.drawRRect(
      RRect.fromRectAndRadius(coverRect, const Radius.circular(4)),
      Paint()
        ..color = const Color(0xFF1A1A1A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawPage(Canvas canvas, Rect rect, PageData page, {required bool isLeft}) {
    canvas.save();
    canvas.clipRect(rect);
    canvas.drawRect(rect, Paint()..color = const Color(0xFFFAF8F2));

    // Inner gutter shadow.
    final gutterGrad = LinearGradient(
      begin: isLeft ? Alignment.centerRight : Alignment.centerLeft,
      end: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      colors: [Colors.black.withValues(alpha: 0.06), Colors.transparent],
      stops: const [0.0, 0.12],
    );
    canvas.drawRect(rect, Paint()..shader = gutterGrad.createShader(rect));

    _drawPageContent(canvas, rect, page, isLeft: isLeft);
    canvas.restore();
  }

  void _drawPageContent(Canvas canvas, Rect rect, PageData page, {required bool isLeft}) {
    final margin = rect.width * 0.10;
    final contentWidth = rect.width - margin * 2;

    // Header.
    final headerText = isLeft ? page.headerLeft : page.headerRight;
    if (headerText != null && headerText.isNotEmpty) {
      final hb = ui.ParagraphBuilder(ui.ParagraphStyle(
        textAlign: isLeft ? TextAlign.left : TextAlign.right,
        fontSize: rect.width * 0.032,
        fontWeight: FontWeight.w400,
        height: 1.0,
      ))
        ..pushStyle(ui.TextStyle(
          color: const Color(0xFF555555),
          letterSpacing: 2.5,
        ))
        ..addText(headerText.toUpperCase());
      final hp = hb.build()..layout(ui.ParagraphConstraints(width: contentWidth));
      canvas.drawParagraph(hp, Offset(rect.left + margin, rect.top + margin * 0.8));
    }

    // Body text.
    if (page.body.isNotEmpty) {
      final bodyTop = rect.top + margin * 2.2;
      final bodyHeight = rect.height - margin * 3.8;

      final bb = ui.ParagraphBuilder(ui.ParagraphStyle(
        textAlign: TextAlign.justify,
        fontSize: rect.width * 0.044,
        fontWeight: FontWeight.w400,
        height: 1.65,
        maxLines: 50,
      ))
        ..pushStyle(ui.TextStyle(
          color: const Color(0xFF2A2A2A),
          fontFamily: 'serif',
        ))
        ..addText(page.body);
      final bp = bb.build()..layout(ui.ParagraphConstraints(width: contentWidth));

      canvas.save();
      canvas.clipRect(Rect.fromLTWH(rect.left, bodyTop, rect.width, bodyHeight));
      canvas.drawParagraph(bp, Offset(rect.left + margin, bodyTop));
      canvas.restore();
    }

    // Page number.
    final pnb = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: isLeft ? TextAlign.left : TextAlign.right,
      fontSize: rect.width * 0.042,
    ))
      ..pushStyle(ui.TextStyle(color: const Color(0xFF777777)))
      ..addText('${page.pageNumber}');
    final pnp = pnb.build()..layout(ui.ParagraphConstraints(width: contentWidth));
    canvas.drawParagraph(
      pnp,
      Offset(rect.left + margin, rect.bottom - margin * 1.1),
    );
  }

  void _drawSpine(Canvas canvas, double cx, double bookTop, double bookH) {
    final spineW = 8.0;
    final spineRect = Rect.fromLTWH(cx - spineW / 2, bookTop, spineW, bookH);
    canvas.drawRect(
      spineRect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.15),
            Colors.black.withValues(alpha: 0.03),
            Colors.black.withValues(alpha: 0.15),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(spineRect),
    );
  }

  void _drawFold(
    Canvas canvas,
    Offset drag,
    Rect pageRect,
    PageData frontPage,
    PageData? backPage,
    double bookLeft,
    double bookTop,
    double bookRight,
    double bookBottom,
    double pageW,
    double bookH,
    double cx,
  ) {
    // Corner that's being dragged (bottom-right of the right page).
    final corner = Offset(bookRight, bookBottom);

    // Clamp drag so the fold doesn't go past the spine too far.
    final clampedDrag = Offset(
      drag.dx.clamp(bookLeft, bookRight),
      drag.dy.clamp(bookTop - bookH * 0.3, bookBottom + bookH * 0.3),
    );

    // Perpendicular bisector of (corner → clampedDrag).
    final mid = Offset(
      (corner.dx + clampedDrag.dx) / 2,
      (corner.dy + clampedDrag.dy) / 2,
    );
    final dx = clampedDrag.dx - corner.dx;
    final dy = clampedDrag.dy - corner.dy;
    final len = sqrt(dx * dx + dy * dy);
    if (len < 1) return;

    // Normal of fold line (perpendicular to corner→drag).
    final nx = -dy / len;
    final ny = dx / len;

    // Find where the fold line intersects the page edges to build the fold polygon.
    final foldPoints = <Offset>[];
    final pageCorners = [
      Offset(cx, bookTop),        // top-left of right page
      Offset(bookRight, bookTop), // top-right
      corner,                      // bottom-right
      Offset(cx, bookBottom),     // bottom-left
    ];

    // Determine which page corners are on the "folded" side (same side as drag point).
    final cornerSide = <bool>[];
    for (final c in pageCorners) {
      final v = (c.dx - mid.dx) * nx + (c.dy - mid.dy) * ny;
      cornerSide.add(v > 0);
    }

    // The folded side is the side the drag point is on.
    final dragSide = (clampedDrag.dx - mid.dx) * nx + (clampedDrag.dy - mid.dy) * ny > 0;

    // Build polygon of the folded region.
    for (int i = 0; i < 4; i++) {
      final j = (i + 1) % 4;
      final ci = pageCorners[i];
      final cj = pageCorners[j];
      final si = cornerSide[i];
      final sj = cornerSide[j];

      if (si != dragSide) {
        foldPoints.add(ci);
      }

      if (si != sj) {
        // Edge crosses the fold line — find intersection.
        final edx = cj.dx - ci.dx;
        final edy = cj.dy - ci.dy;
        final denom = edx * nx + edy * ny;
        if (denom.abs() > 1e-6) {
          final t = ((mid.dx - ci.dx) * nx + (mid.dy - ci.dy) * ny) / denom;
          if (t >= -0.01 && t <= 1.01) {
            foldPoints.add(Offset(ci.dx + edx * t.clamp(0, 1), ci.dy + edy * t.clamp(0, 1)));
          }
        }
      }
    }

    if (foldPoints.length < 3) return;

    // The unfolded region = right page minus the folded polygon.
    // Draw the right page clipped to the unfolded area.
    canvas.save();
    canvas.clipRect(pageRect);
    // Subtract the folded region by drawing page, then re-drawing with fold clip.
    _drawPage(canvas, pageRect, frontPage, isLeft: false);
    canvas.restore();

    // Now clip out the folded region and draw the underlying page there.
    final foldPath = Path()..addPolygon(foldPoints, true);

    if (backPage != null) {
      canvas.save();
      canvas.clipPath(foldPath);
      canvas.clipRect(pageRect);
      // Draw the next page underneath.
      _drawPage(canvas, pageRect, backPage, isLeft: false);
      canvas.restore();
    }

    // Reflect the fold polygon across the fold line to get the "turned" page.
    final reflectedPoints = foldPoints.map((p) {
      final vx = p.dx - mid.dx;
      final vy = p.dy - mid.dy;
      final dot = vx * nx + vy * ny;
      return Offset(p.dx - 2 * dot * nx, p.dy - 2 * dot * ny);
    }).toList();

    final reflectedPath = Path()..addPolygon(reflectedPoints, true);

    // Draw the folded-over page (reflected).
    canvas.save();
    canvas.clipPath(reflectedPath);
    canvas.clipRect(Rect.fromLTWH(bookLeft - 20, bookTop - 20, bookRight - bookLeft + 40, bookH + 40));

    // Apply the reflection transform for the page content.
    // Reflect across the fold line: translate to mid, reflect across normal, translate back.
    // Reflection across the fold line passing through [mid] with normal (nx, ny).
    // T(mid) · R · T(-mid)  where R = I - 2·n·nᵀ.
    final r00 = 1 - 2 * nx * nx;
    final r01 = -2 * nx * ny;
    final r10 = -2 * nx * ny;
    final r11 = 1 - 2 * ny * ny;
    final tx = mid.dx - r00 * mid.dx - r01 * mid.dy;
    final ty = mid.dy - r10 * mid.dx - r11 * mid.dy;
    final reflectMatrix = Matrix4(
      r00, r10, 0, 0,
      r01, r11, 0, 0,
      0, 0, 1, 0,
      tx, ty, 0, 1,
    );

    canvas.transform(reflectMatrix.storage);

    // Draw the page content (it will appear mirrored).
    canvas.drawRect(pageRect, Paint()..color = const Color(0xFFF5F3ED));
    _drawPageContent(canvas, pageRect, frontPage, isLeft: false);

    // Slight darkening on the back of the folded page.
    canvas.drawRect(
      pageRect,
      Paint()..color = Colors.black.withValues(alpha: 0.04),
    );

    canvas.restore();

    // Shadow along the fold line.
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(bookLeft - 10, bookTop - 10, bookRight - bookLeft + 20, bookH + 20));
    final shadowLen = min(pageW * 0.12, len * 0.3);

    for (int i = 0; i < 8; i++) {
      final t = i / 8.0;
      final offset = shadowLen * t;
      final shadowPath = Path();
      final shifted = reflectedPoints.map((p) {
        return Offset(p.dx + nx * offset * 0.5, p.dy + ny * offset * 0.5);
      }).toList();
      shadowPath.addPolygon(shifted, true);

      canvas.drawPath(
        shadowPath,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.03 * (1 - t))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 + t * 8),
      );
    }
    canvas.restore();

    // Highlight along the fold edge.
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(bookLeft - 10, bookTop - 10, bookRight - bookLeft + 20, bookH + 20));
    if (foldPoints.length >= 2) {
      // Find two intersection points on the fold line.
      final intersections = <Offset>[];
      for (int i = 0; i < 4; i++) {
        final j = (i + 1) % 4;
        if (cornerSide[i] != cornerSide[j]) {
          final ci = pageCorners[i];
          final cj = pageCorners[j];
          final edx = cj.dx - ci.dx;
          final edy = cj.dy - ci.dy;
          final denom = edx * nx + edy * ny;
          if (denom.abs() > 1e-6) {
            final t = ((mid.dx - ci.dx) * nx + (mid.dy - ci.dy) * ny) / denom;
            if (t >= -0.01 && t <= 1.01) {
              intersections.add(Offset(ci.dx + edx * t.clamp(0, 1), ci.dy + edy * t.clamp(0, 1)));
            }
          }
        }
      }
      if (intersections.length >= 2) {
        canvas.drawLine(
          intersections[0],
          intersections[1],
          Paint()
            ..color = Colors.white.withValues(alpha: 0.4)
            ..strokeWidth = 1.5,
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(BookPainter old) => true;
}
