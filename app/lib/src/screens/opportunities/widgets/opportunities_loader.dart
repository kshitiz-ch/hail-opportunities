import 'dart:math' as math;
import 'package:flutter/material.dart';

class OpportunitiesLoader extends StatefulWidget {
  final double size;
  final Color color;

  const OpportunitiesLoader({
    Key? key,
    this.size = 50.0,
    this.color = const Color(0xFF7F30FE), // Your active purple color
  }) : super(key: key);

  @override
  _OpportunitiesLoaderState createState() => _OpportunitiesLoaderState();
}

class _OpportunitiesLoaderState extends State<OpportunitiesLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _CompassPainter(
              color: widget.color,
              progress: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final Color color;
  final double progress;

  _CompassPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08 // Relative stroke width
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // --- 1. Draw Outer Spinning Ring ---
    canvas.save();
    canvas.translate(center.dx, center.dy);
    // Rotate the full circle based on progress
    canvas.rotate(progress * 2 * math.pi);

    // Draw the main arc (leaving a gap for the "arrow" feel)
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: radius * 0.8),
      0,
      1.5 * math.pi, // 3/4 circle
      false,
      paint,
    );

    // Draw the arrow head at the end of the arc
    final arrowPath = Path();
    final arrowSize = radius * 0.25;
    // Position at the start of the arc (0 radians)
    arrowPath.moveTo(radius * 0.8 + arrowSize / 2, 0);
    arrowPath.lineTo(radius * 0.8, arrowSize);
    arrowPath.lineTo(radius * 0.8 - arrowSize / 2, 0);

    // Rotate arrow to match the end of the arc line if needed,
    // but a simple triangle at the tip works for the "scan" look.
    canvas.drawPath(
        arrowPath, paint..style = PaintingStyle.stroke); // Keep stroke style

    canvas.restore();

    // --- 2. Draw Inner Seeking Needle ---
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Make the needle wiggle back and forth (Sine wave)
    // We limit the wiggle to 45 degrees (pi/4)
    double wiggle = math.sin(progress * 4 * math.pi) * (math.pi / 4);
    canvas.rotate(wiggle);

    final needlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeJoin = StrokeJoin.round;

    final needlePath = Path();
    final needleLen = radius * 0.5;
    final needleWid = radius * 0.25;

    // Draw Diamond Needle shape
    needlePath.moveTo(0, -needleLen); // Top
    needlePath.lineTo(needleWid / 2, 0); // Right
    needlePath.lineTo(0, needleLen); // Bottom
    needlePath.lineTo(-needleWid / 2, 0); // Left
    needlePath.close();

    // Draw the line in the middle of needle (like a real compass)
    canvas.drawPath(needlePath, needlePaint);
    canvas.drawLine(Offset(0, -needleLen / 2), Offset(0, needleLen / 2),
        needlePaint..strokeWidth = 1);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) => true;
}
