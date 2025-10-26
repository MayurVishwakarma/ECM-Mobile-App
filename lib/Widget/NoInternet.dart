import 'dart:math' as math;
import 'package:flutter/material.dart';

class NoInternetIllustration extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;
  final EdgeInsetsGeometry padding;

  const NoInternetIllustration({
    super.key,
    this.title = "No Internet",
    this.subtitle = "We can’t reach the network. Check your connection.",
    this.onRetry,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, c) {
          final size = math.min(c.maxWidth, c.maxHeight);
          final artSize = size.isFinite ? size * 0.5 : 180.0;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Breathing(
                child: SizedBox(
                  width: artSize,
                  height: artSize,
                  child: CustomPaint(
                    painter: _NoNetPainter(
                      primary: color.primary,
                      secondary: isDark
                          ? color.primary.withOpacity(0.12)
                          : color.primary.withOpacity(0.16),
                      outline: theme.dividerColor.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (onRetry != null)
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Try Again"),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Subtle scale animation (breathing) for the illustration
class _Breathing extends StatefulWidget {
  final Widget child;
  const _Breathing({required this.child});

  @override
  State<_Breathing> createState() => _BreathingState();
}

class _BreathingState extends State<_Breathing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat(reverse: true);
  late final Animation<double> _a =
      Tween(begin: 0.98, end: 1.02).animate(CurvedAnimation(
    parent: _c,
    curve: Curves.easeInOut,
  ));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (context, _) => Transform.scale(
        scale: _a.value,
        child: widget.child,
      ),
    );
  }
}

/// Custom painter that draws:
/// - a soft cloud
/// - a Wi-Fi glyph
/// - a slash (to indicate “no/blocked”)
/// - a few floating dots for depth
class _NoNetPainter extends CustomPainter {
  final Color primary;
  final Color secondary;
  final Color outline;

  _NoNetPainter({
    required this.primary,
    required this.secondary,
    required this.outline,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ---- background accents (soft circles)
    final accent = Paint()..color = secondary;
    canvas.drawCircle(Offset(w * 0.25, h * 0.25), w * 0.16, accent);
    canvas.drawCircle(Offset(w * 0.78, h * 0.28), w * 0.12, accent);
    canvas.drawCircle(Offset(w * 0.70, h * 0.72), w * 0.14, accent);
    canvas.drawCircle(Offset(w * 0.32, h * 0.70), w * 0.10, accent);

    // ---- cloud
    final cloudPaint = Paint()
      ..color = secondary
      ..style = PaintingStyle.fill;
    final cloud = Path()
      ..moveTo(w * 0.2, h * 0.6)
      ..cubicTo(w * 0.15, h * 0.5, w * 0.28, h * 0.45, w * 0.35, h * 0.5)
      ..cubicTo(w * 0.42, h * 0.4, w * 0.6, h * 0.4, w * 0.62, h * 0.52)
      ..cubicTo(w * 0.75, h * 0.52, w * 0.82, h * 0.6, w * 0.8, h * 0.68)
      ..lineTo(w * 0.22, h * 0.68)
      ..close();
    canvas.drawPath(cloud, cloudPaint);

    // ---- wifi arcs
    final center = Offset(w * 0.5, h * 0.58);
    final wifiPaint = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    void arc(double r, double sweep) {
      final rect =
          Rect.fromCircle(center: center, radius: r).deflate(4); // nicer arcs
      canvas.drawArc(rect, math.pi, sweep, false, wifiPaint);
    }

    arc(w * 0.22, math.pi * 0.6);
    arc(w * 0.16, math.pi * 0.6);
    arc(w * 0.10, math.pi * 0.6);

    // dot
    final dot = Paint()..color = primary;
    canvas.drawCircle(Offset(center.dx, center.dy + w * 0.08), 4, dot);

    // ---- slash (no symbol)
    final slash = Paint()
      ..color = primary
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.30, h * 0.35),
      Offset(w * 0.72, h * 0.77),
      slash,
    );

    // ---- outline for cloud bottom
    final ground = Paint()
      ..color = outline
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final groundPath = Path()
      ..moveTo(w * 0.22, h * 0.70)
      ..quadraticBezierTo(w * 0.5, h * 0.75, w * 0.78, h * 0.70);
    canvas.drawPath(groundPath, ground);
  }

  @override
  bool shouldRepaint(covariant _NoNetPainter oldDelegate) {
    return oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary ||
        oldDelegate.outline != outline;
  }
}
