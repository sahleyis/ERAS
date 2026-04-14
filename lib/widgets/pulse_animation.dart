import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Expanding pulse animation used on the waiting/searching screen.
class PulseAnimation extends StatefulWidget {
  final double size;
  final Color color;
  final Widget? child;
  final int ringCount;

  const PulseAnimation({
    super.key,
    this.size = 200,
    this.color = ErasTheme.sosRed,
    this.child,
    this.ringCount = 4,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
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
          return Stack(
            alignment: Alignment.center,
            children: [
              // Concentric expanding rings
              for (int i = 0; i < widget.ringCount; i++)
                _buildRing(i),

              // Center content
              if (widget.child != null) widget.child!,
            ],
          );
        },
      ),
    );
  }

  Widget _buildRing(int index) {
    final delay = index / widget.ringCount;
    final progress = (_controller.value + delay) % 1.0;
    final scale = 0.3 + (progress * 0.7);
    final opacity = (1.0 - progress).clamp(0.0, 0.5);

    return Transform.scale(
      scale: scale,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.color.withOpacity(opacity),
            width: 2,
          ),
        ),
      ),
    );
  }
}

/// Radar-style scanning animation for the search screen.
class RadarAnimation extends StatefulWidget {
  final double size;
  final Color color;
  final String? centerText;

  const RadarAnimation({
    super.key,
    this.size = 250,
    this.color = ErasTheme.medicalBlue,
    this.centerText,
  });

  @override
  State<RadarAnimation> createState() => _RadarAnimationState();
}

class _RadarAnimationState extends State<RadarAnimation>
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
        builder: (context, _) {
          return CustomPaint(
            painter: _RadarPainter(
              progress: _controller.value,
              color: widget.color,
            ),
            child: Center(
              child: widget.centerText != null
                  ? Text(
                      widget.centerText!,
                      style: ErasTheme.displayMedium.copyWith(
                        color: widget.color,
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RadarPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Draw concentric circles
    for (int i = 1; i <= 4; i++) {
      final radius = maxRadius * (i / 4);
      final paint = Paint()
        ..color = color.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(center, radius, paint);
    }

    // Draw sweep arc
    final sweepAngle = progress * 2 * 3.14159;
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: sweepAngle - 1.0,
        endAngle: sweepAngle,
        colors: [
          color.withOpacity(0.0),
          color.withOpacity(0.3),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, maxRadius, sweepPaint);

    // Center dot
    canvas.drawCircle(
      center,
      4,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
