import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Living halftone dot field (same look as the website hero).
/// A diagonal ribbon of fine dots + a swirling field of big dots.
/// Dots push away from the finger / cursor and swell under it.
class Halftone extends StatefulWidget {
  const Halftone({super.key, this.color = const Color(0xFF121212), this.band = true, this.swirl = true, this.swirlX = 1.05, this.swirlY = 0.45, this.spacing = 11, this.speed = 1});

  final Color color;
  final bool band, swirl;
  final double swirlX, swirlY, spacing, speed;

  @override
  State<Halftone> createState() => _HalftoneState();
}

class _HalftoneState extends State<Halftone> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _time = ValueNotifier<double>(0);
  static const _off = Offset(-9999, -9999);
  Offset _target = _off, _m = _off;
  double _boost = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((e) {
      _m = (_target == _off || _m == _off) ? _target : Offset.lerp(_m, _target, 0.14)!;
      _boost *= 0.94;
      _time.value = e.inMicroseconds / 1e6;
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (e) => _target = e.localPosition,
      onExit: (_) => _target = _m = _off,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (e) {
          _target = e.localPosition;
          _boost = 1.4;
        },
        onPointerMove: (e) => _target = e.localPosition,
        onPointerUp: (_) => Future.delayed(const Duration(milliseconds: 500), () => _target = _off),
        child: RepaintBoundary(
          child: CustomPaint(size: Size.infinite, painter: _HalftonePainter(this)),
        ),
      ),
    );
  }
}

class _HalftonePainter extends CustomPainter {
  _HalftonePainter(this.s) : super(repaint: s._time);
  final _HalftoneState s;

  @override
  void paint(Canvas canvas, Size size) {
    final w = s.widget;
    final t = s._time.value * 0.72 * w.speed;
    final W = size.width, H = size.height;
    final paint = Paint()..color = w.color;
    final m = s._m;
    final R = 120 + s._boost * 50;

    void dot(double x, double y, double r) {
      final dx = x - m.dx, dy = y - m.dy, d2 = dx * dx + dy * dy;
      if (d2 < R * R) {
        final d = math.sqrt(d2) + 0.001, k = 1 - d / R, e = k * k;
        x += dx / d * e * 22;
        y += dy / d * e * 22;
        r = r * (1 + e * 1.6) + e * 1.1;
      }
      canvas.drawCircle(Offset(x, y), r, paint);
    }

    if (w.band) {
      final s1 = w.spacing;
      final p0x = W * 0.22, p0y = -H * 0.05;
      var dx = W * 0.42, dy = H;
      final L = math.sqrt(dx * dx + dy * dy);
      dx /= L;
      dy /= L;
      final nx = -dy, ny = dx, bw0 = math.max(W * 0.14, 60.0);
      var row = 0;
      for (double y = -s1; y < H + s1; y += s1, row++) {
        for (double x = -s1 + (row % 2) * s1 / 2; x < W + s1; x += s1) {
          final rx = x - p0x, ry = y - p0y;
          final u = rx * dx + ry * dy;
          var v = rx * nx + ry * ny;
          v += math.sin(u * 0.005 + t * 0.6) * W * 0.07 + math.sin(u * 0.011 - t * 0.45) * W * 0.025;
          final bw = bw0 * (0.75 + 0.35 * math.sin(u * 0.004 + t * 0.35));
          if (v.abs() > bw * 2.3) continue;
          final inten = math.exp(-(v / bw) * (v / bw));
          final r = inten * 1.9 * (0.85 + 0.15 * math.sin(u * 0.05 - t * 2));
          if (r < 0.28) continue;
          dot(x, y, r);
        }
      }
    }

    if (w.swirl) {
      final s2 = w.spacing * 2.5;
      final cx = W * w.swirlX, cy = H * w.swirlY, maxR = w.spacing * 0.7;
      var row = 0;
      for (double y = -s2; y < H + s2; y += s2, row++) {
        for (double x = -s2 + (row % 2) * s2 / 2; x < W + s2; x += s2) {
          final mask = ((x - W * 0.4) / (W * 0.6)).clamp(0.0, 1.0);
          if (mask <= 0.02) continue;
          final ddx = x - cx, ddy = y - cy;
          final rr = math.sqrt(ddx * ddx + ddy * ddy), a = math.atan2(ddy, ddx);
          final ring = 0.5 + 0.5 * math.sin(rr * 0.016 - t * 0.9 + a * 2.0);
          final ring2 = 0.5 + 0.5 * math.sin(rr * 0.028 + t * 0.5 - a * 3.0);
          final r = mask * mask * (0.6 + maxR * (0.55 * ring + 0.45 * ring2) * mask);
          if (r < 0.7) continue;
          dot(x, y, r);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HalftonePainter old) => false;
}
