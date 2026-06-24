import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/page_data.dart';

/// Paints a two-page open book spread with a page-flip in progress.
///
/// [flipProgress] ∈ [0, 1]:
///   0.0 = page fully resting on the right (pre-flip)
///   0.5 = page is at the spine (vertical, halfway)
///   1.0 = page fully landed on the left (post-flip)
///
/// The flip is rendered as a trapezoid that foreshortens horizontally as the
/// virtual page rotates, plus a soft gradient shadow that deepens at the spine.
class BookPainter extends CustomPainter {
  final PageData leftPage;
  final PageData rightPage;
  final PageData flippingFront; // face visible 0→0.5
  final PageData flippingBack;  // face visible 0.5→1
  final double flipProgress;    // 0..1
  final bool flippingForward;   // true = next page, false = previous

  const BookPainter({
    required this.leftPage,
    required this.rightPage,
    required this.flippingFront,
    required this.flippingBack,
    required this.flipProgress,
    required this.flippingForward,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final bookW = size.width * 0.82;
    final bookH = bookW * 0.65;
    final pageW = bookW / 2;
    final bookLeft = cx - bookW / 2;
    final bookTop = cy - bookH / 2;

    final leftRect = Rect.fromLTWH(bookLeft, bookTop, pageW, bookH);
    final rightRect = Rect.fromLTWH(cx, bookTop, pageW, bookH);

    _drawBookShadow(canvas, bookLeft, bookTop, bookW, bookH);
    _drawPage(canvas, leftRect, leftPage, isLeft: true);
    _drawPage(canvas, rightRect, rightPage, isLeft: false);
    _drawSpine(canvas, cx, bookTop, bookH);
    _drawFlippingPage(canvas, leftRect, rightRect, bookTop, bookH, pageW, cx);
    _drawBookEdges(canvas, bookLeft, bookTop, bookW, bookH);
  }

  void _drawBookShadow(Canvas canvas, double l, double t, double w, double h) {
    final rr = RRect.fromRectAndRadius(
      Rect.fromLTWH(l + 6, t + 8, w, h),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      rr,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
  }

  void _drawPage(Canvas canvas, Rect rect, PageData page, {required bool isLeft}) {
    final radius = isLeft
        ? const BorderRadius.only(
            topLeft: Radius.circular(4),
            bottomLeft: Radius.circular(4),
          )
        : const BorderRadius.only(
            topRight: Radius.circular(4),
            bottomRight: Radius.circular(4),
          );

    final rrect = radius.toRRect(rect);

    // Page background.
    canvas.drawRRect(rrect, Paint()..color = page.color);

    // Subtle inner gradient (paper texture feel).
    final grad = LinearGradient(
      begin: isLeft ? Alignment.centerRight : Alignment.centerLeft,
      end: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      colors: [Colors.black.withValues(alpha: 0.06), Colors.transparent],
      stops: const [0.0, 0.35],
    );
    canvas.drawRRect(rrect, Paint()..shader = grad.createShader(rect));

    // Page lines.
    _drawPageLines(canvas, rect, page);

    // Page-number footer.
    _drawPageNumber(canvas, rect, page.pageNumber);
  }

  void _drawPageLines(Canvas canvas, Rect rect, PageData page) {
    final linePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..strokeWidth = 0.8;

    final textPad = rect.width * 0.15;
    final lineSpacing = rect.height * 0.08;
    final startY = rect.top + rect.height * 0.22;
    final endX = rect.right - textPad;
    final startX = rect.left + textPad;

    for (int i = 0; i < 6; i++) {
      final y = startY + i * lineSpacing;
      if (y < rect.bottom - rect.height * 0.15) {
        canvas.drawLine(Offset(startX, y), Offset(endX, y), linePaint);
      }
    }

    // Draw label text via paragraph.
    final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: TextAlign.center,
      fontSize: rect.width * 0.11,
      fontWeight: FontWeight.w300,
    ))
      ..pushStyle(ui.TextStyle(color: Colors.black54))
      ..addText(page.label);

    final paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: rect.width * 0.7));

    canvas.drawParagraph(
      paragraph,
      Offset(
        rect.left + (rect.width - rect.width * 0.7) / 2,
        rect.top + rect.height * 0.28,
      ),
    );
  }

  void _drawPageNumber(Canvas canvas, Rect rect, int number) {
    final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: TextAlign.center,
      fontSize: rect.width * 0.08,
    ))
      ..pushStyle(ui.TextStyle(color: Colors.black38))
      ..addText('$number');

    final para = pb.build()..layout(ui.ParagraphConstraints(width: rect.width));
    canvas.drawParagraph(
      para,
      Offset(rect.left, rect.bottom - rect.height * 0.10),
    );
  }

  void _drawSpine(Canvas canvas, double cx, double bookTop, double bookH) {
    final spinePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.black.withValues(alpha: 0.18),
          Colors.black.withValues(alpha: 0.05),
          Colors.black.withValues(alpha: 0.18),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(cx - 4, bookTop, 8, bookH));

    canvas.drawRect(Rect.fromLTWH(cx - 4, bookTop, 8, bookH), spinePaint);
  }

  void _drawBookEdges(Canvas canvas, double l, double t, double w, double h) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(l, t, w, h),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.brown.shade300.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawFlippingPage(
    Canvas canvas,
    Rect leftRect,
    Rect rightRect,
    double bookTop,
    double bookH,
    double pageW,
    double cx,
  ) {
    // angle ∈ [0, π] as flipProgress goes 0 → 1
    final angle = flipProgress * pi;

    // The page flips from the right side to the left side.
    // cos(angle): 1 at 0°, 0 at 90°, -1 at 180°
    final cosA = cos(angle);
    final absCos = cosA.abs();

    // Foreshortened width of the flipping page.
    final fWidth = pageW * absCos;

    // Which face are we showing?
    final showBack = angle > pi / 2;
    final pageData = showBack ? flippingBack : flippingFront;

    // The spine edge is always at cx (spine).
    // First half (0→π/2): right face — page sweeps left from cx+pageW → cx
    // Second half (π/2→π): back face — page sweeps left from cx → cx-pageW
    double left, right;
    if (!showBack) {
      // cosA: 1 → 0, so page right edge goes from cx+pageW to cx
      right = cx + pageW * cosA;
      left = cx;
    } else {
      // cosA: 0 → -1, so page left edge goes from cx to cx-pageW
      left = cx + pageW * cosA; // cosA is negative here
      right = cx;
    }

    if (fWidth < 0.5) return; // invisible at 90°

    final flipRect = Rect.fromLTRB(left, bookTop, right, bookTop + bookH);

    canvas.save();
    // Clip so the flipping page doesn't overflow the book bounds.
    canvas.clipRect(Rect.fromLTWH(
      cx - pageW,
      bookTop,
      pageW * 2,
      bookH,
    ));

    // Page background.
    canvas.drawRect(flipRect, Paint()..color = pageData.color);

    // Lines and text — scale horizontally so they fit the foreshortened rect.
    canvas.save();
    canvas.translate(flipRect.left + flipRect.width / 2, flipRect.top + flipRect.height / 2);
    canvas.scale(absCos, 1.0);
    canvas.translate(-(pageW / 2), -(bookH / 2));

    final fullRect = Rect.fromLTWH(0, 0, pageW, bookH);
    _drawPageLines(canvas, fullRect, pageData);
    _drawPageNumber(canvas, fullRect, pageData.pageNumber);
    canvas.restore();

    // Lighting: shadow deepens at spine side.
    final shadowGrad = LinearGradient(
      begin: showBack ? Alignment.centerLeft : Alignment.centerRight,
      end: showBack ? Alignment.centerRight : Alignment.centerLeft,
      colors: [
        Colors.black.withValues(alpha: 0.30 * (1 - absCos)),
        Colors.transparent,
      ],
    );
    canvas.drawRect(
      flipRect,
      Paint()..shader = shadowGrad.createShader(flipRect),
    );

    // Thin edge line at spine.
    canvas.drawLine(
      Offset(cx, bookTop),
      Offset(cx, bookTop + bookH),
      Paint()
        ..color = Colors.black26
        ..strokeWidth = 1,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(BookPainter old) =>
      old.flipProgress != flipProgress ||
      old.leftPage != leftPage ||
      old.rightPage != rightPage;
}
