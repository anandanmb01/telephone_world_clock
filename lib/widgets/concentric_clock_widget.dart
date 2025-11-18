import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Widget that displays two concentric 24-hour clocks
class ConcentricClockWidget extends StatelessWidget {
  final DateTime currentTime;
  final int localOffset;
  final int remoteOffset;
  final String localCountry;
  final String remoteCountry;

  const ConcentricClockWidget({
    super.key,
    required this.currentTime,
    required this.localOffset,
    required this.remoteOffset,
    required this.localCountry,
    required this.remoteCountry,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ClockPainter(
        currentTime: currentTime,
        localOffset: localOffset,
        remoteOffset: remoteOffset,
        localCountry: localCountry,
        remoteCountry: remoteCountry,
        colorScheme: Theme.of(context).colorScheme,
      ),
      child: Container(),
    );
  }
}

/// Custom painter for rendering the concentric clock faces
class ClockPainter extends CustomPainter {
  final DateTime currentTime;
  final int localOffset;
  final int remoteOffset;
  final String localCountry;
  final String remoteCountry;
  final ColorScheme colorScheme;

  ClockPainter({
    required this.currentTime,
    required this.localOffset,
    required this.remoteOffset,
    required this.localCountry,
    required this.remoteCountry,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = min(size.width, size.height) / 2 - 20;
    final innerRadius = outerRadius * 0.65;

    // Calculate local time with offset
    final utcTime = currentTime.toUtc();
    final localMinutes = (utcTime.hour * 60 + utcTime.minute + localOffset) % 1440;
    final localHour = localMinutes / 60;

    // Calculate remote time with offset
    final remoteMinutes = (utcTime.hour * 60 + utcTime.minute + remoteOffset) % 1440;
    final remoteHour = remoteMinutes / 60;

    // Draw outer circle (remote time)
    _drawClock(canvas, center, outerRadius, remoteHour, remoteCountry, colorScheme.primary, true);

    // Draw inner circle (local time)
    _drawClock(canvas, center, innerRadius, localHour, localCountry, colorScheme.secondary, false);

    // Draw current time pointer for local time
    _drawTimePointer(canvas, center, innerRadius, localHour, colorScheme.secondary);

    // Draw current time pointer for remote time
    _drawTimePointer(canvas, center, outerRadius, remoteHour, colorScheme.primary);

    // Draw legend
    _drawLegend(canvas, size, colorScheme);
  }

  void _drawClock(Canvas canvas, Offset center, double radius, double currentHour,
                  String country, Color color, bool isOuter) {
    // Draw clock circle
    final circlePaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, circlePaint);

    // Draw clock border
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);

    // Draw hour markers and labels
    for (int i = 0; i < 24; i++) {
      final angle = (i * 15 - 90) * pi / 180; // 15 degrees per hour
      final markerStart = Offset(
        center.dx + radius * 0.9 * cos(angle),
        center.dy + radius * 0.9 * sin(angle),
      );
      final markerEnd = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      final markerPaint = Paint()
        ..color = color
        ..strokeWidth = i % 6 == 0 ? 3 : 1;
      canvas.drawLine(markerStart, markerEnd, markerPaint);

      // Draw hour numbers
      if (i % 3 == 0) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: i.toString(),
            style: TextStyle(
              color: color,
              fontSize: isOuter ? 14 : 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        );
        textPainter.layout();
        final textOffset = Offset(
          center.dx + radius * 0.75 * cos(angle) - textPainter.width / 2,
          center.dy + radius * 0.75 * sin(angle) - textPainter.height / 2,
        );
        textPainter.paint(canvas, textOffset);
      }
    }

    // Draw country label
    final countryPainter = TextPainter(
      text: TextSpan(
        text: country,
        style: TextStyle(
          color: color,
          fontSize: isOuter ? 16 : 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    countryPainter.layout();
    final labelOffset = Offset(
      center.dx - countryPainter.width / 2,
      center.dy + (isOuter ? radius * 0.5 : 0) - countryPainter.height / 2,
    );
    countryPainter.paint(canvas, labelOffset);
  }

  void _drawTimePointer(Canvas canvas, Offset center, double radius, double currentHour, Color color) {
    final angle = (currentHour * 15 - 90) * pi / 180;
    final pointerEnd = Offset(
      center.dx + radius * 0.85 * cos(angle),
      center.dy + radius * 0.85 * sin(angle),
    );

    // Draw shadow for depth
    final shadowPath = Path();
    final shadowWidth = 8.0;
    final perpAngle = angle + pi / 2;

    shadowPath.moveTo(
      center.dx + shadowWidth / 2 * cos(perpAngle),
      center.dy + shadowWidth / 2 * sin(perpAngle),
    );
    shadowPath.lineTo(
      center.dx - shadowWidth / 2 * cos(perpAngle),
      center.dy - shadowWidth / 2 * sin(perpAngle),
    );
    shadowPath.lineTo(pointerEnd.dx, pointerEnd.dy);
    shadowPath.close();

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(shadowPath, shadowPaint);

    // Draw tapered pointer (arrow shape)
    final pointerPath = Path();
    final baseWidth = 6.0;

    // Base of the pointer (wider)
    pointerPath.moveTo(
      center.dx + baseWidth * cos(perpAngle),
      center.dy + baseWidth * sin(perpAngle),
    );
    pointerPath.lineTo(
      center.dx - baseWidth * cos(perpAngle),
      center.dy - baseWidth * sin(perpAngle),
    );

    // Tip of the pointer (narrow point)
    pointerPath.lineTo(pointerEnd.dx, pointerEnd.dy);
    pointerPath.close();

    // Gradient from center to tip
    final pointerPaint = Paint()
      ..shader = ui.Gradient.linear(
        center,
        pointerEnd,
        [
          color.withOpacity(0.7),
          color,
        ],
        [0.0, 1.0],
      )
      ..style = PaintingStyle.fill;
    canvas.drawPath(pointerPath, pointerPaint);

    // Draw border around pointer for definition
    final borderPaint = Paint()
      ..color = color.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(pointerPath, borderPaint);

    // Draw center pivot circle
    final centerPivotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, centerPivotPaint);

    final centerHighlight = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx - 2, center.dy - 2),
      3,
      centerHighlight,
    );

    // Draw modern pointer tip
    final tipPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pointerEnd, 3.5, tipPaint);

    final tipBorderPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(pointerEnd, 3.5, tipBorderPaint);

    // Draw time text in a modern badge
    final hour = currentHour.floor();
    final minute = ((currentHour - hour) * 60).round();
    final timeText = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    final timePainter = TextPainter(
      text: TextSpan(
        text: timeText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    timePainter.layout();

    final badgePadding = 6.0;
    final badgeWidth = timePainter.width + badgePadding * 2;
    final badgeHeight = timePainter.height + badgePadding * 1.5;
    final badgeOffset = Offset(
      pointerEnd.dx - badgeWidth / 2,
      pointerEnd.dy - badgeHeight - 18,
    );

    // Badge shadow
    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        badgeOffset.dx + 1,
        badgeOffset.dy + 1,
        badgeWidth,
        badgeHeight,
      ),
      const Radius.circular(12),
    );
    final badgeShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(badgeRect, badgeShadowPaint);

    // Badge background with gradient
    final badgeRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        badgeOffset.dx,
        badgeOffset.dy,
        badgeWidth,
        badgeHeight,
      ),
      const Radius.circular(12),
    );

    final badgePaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(badgeOffset.dx, badgeOffset.dy),
        Offset(badgeOffset.dx, badgeOffset.dy + badgeHeight),
        [
          color.withOpacity(0.95),
          color.withOpacity(0.85),
        ],
      )
      ..style = PaintingStyle.fill;
    canvas.drawRRect(badgeRRect, badgePaint);

    // Badge border
    final badgeBorderPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(badgeRRect, badgeBorderPaint);

    // Draw time text
    final timeTextOffset = Offset(
      badgeOffset.dx + badgePadding,
      badgeOffset.dy + badgePadding * 0.75,
    );
    timePainter.paint(canvas, timeTextOffset);
  }

  void _drawLegend(Canvas canvas, Size size, ColorScheme colorScheme) {
    final legendY = size.height - 40;

    // Local time legend
    final localCirclePaint = Paint()
      ..color = colorScheme.secondary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(40, legendY), 8, localCirclePaint);

    final localTextPainter = TextPainter(
      text: TextSpan(
        text: 'Inner: $localCountry',
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 12,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    localTextPainter.layout();
    localTextPainter.paint(canvas, Offset(55, legendY - 6));

    // Remote time legend
    final remoteCirclePaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2 + 20, legendY), 8, remoteCirclePaint);

    final remoteTextPainter = TextPainter(
      text: TextSpan(
        text: 'Outer: $remoteCountry',
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 12,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    remoteTextPainter.layout();
    remoteTextPainter.paint(canvas, Offset(size.width / 2 + 35, legendY - 6));
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) {
    return currentTime != oldDelegate.currentTime ||
           localOffset != oldDelegate.localOffset ||
           remoteOffset != oldDelegate.remoteOffset;
  }
}
