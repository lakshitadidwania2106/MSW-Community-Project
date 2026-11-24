import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/scene.dart';
import 'onboarding.dart';

/// Opening sequence: community photos pop in as a collage, a counter runs,
/// "MSW." rises, then the last photo zooms to fill the screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _run = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));
  late final AnimationController _zoom = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  static const n = 10;
  final _rand = math.Random(4);
  late final List<(double, double, double)> _spots = List.generate(n, (i) {
    final ang = i * 2.4, rad = 0.35 + (i % 3) * 0.25;
    return i == n - 1 ? (0.0, 0.0, 0.0) : (math.cos(ang) * rad, math.sin(ang) * rad, (_rand.nextDouble() - 0.5) * 0.28);
  });

  @override
  void initState() {
    super.initState();
    _run.forward().whenComplete(() async {
      await _zoom.forward();
      if (mounted) Navigator.of(context).pushReplacement(fadeRoute(const WelcomeScreen(), ms: 900));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (var i = 0; i < n; i++) {
      precacheImage(NetworkImage(photo(i)), context);
    }
  }

  @override
  void dispose() {
    _run.dispose();
    _zoom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: C.dark,
      body: AnimatedBuilder(
        animation: Listenable.merge([_run, _zoom]),
        builder: (context, _) {
          final k = _run.value, z = Curves.easeInOutCubic.transform(_zoom.value);
          final shown = (k * 1.1 * n).floor();
          final pw = size.width * 0.46, ph = pw * 4 / 3;
          return Stack(
            children: [
              for (var i = 0; i < n; i++)
                if (i < shown) _photo(i, size, pw, ph, z),
              // wordmark + counter (difference blend so it reads on any photo)
              Positioned(
                left: 28,
                right: 28,
                bottom: size.height * 0.16,
                child: Opacity(
                  opacity: 1 - z,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRect(
                        child: Transform.translate(
                          offset: Offset(0, (1 - Curves.easeOutCubic.transform((k * 2.2).clamp(0, 1))) * 110),
                          child: const Padding(padding: EdgeInsets.only(bottom: 8), child: Logo(light: true, height: 96)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 1,
                        color: Colors.white12,
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: Curves.easeOutCubic.transform(k),
                          child: Container(color: C.teal),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('LOADING THE COMMUNITY', style: mono(11, color: C.onDark.withValues(alpha: 0.7))),
                          Text((Curves.easeOutCubic.transform(k) * 100).round().toString().padLeft(3, '0'), style: mono(11, color: C.onDark.withValues(alpha: 0.7))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _photo(int i, Size size, double pw, double ph, double z) {
    final (dx, dy, rot) = _spots[i];
    final last = i == n - 1;
    final cx = size.width / 2 + dx * size.width * 0.5, cy = size.height * 0.42 + dy * size.height * 0.32;
    double w = pw, h = ph, left = cx - pw / 2, top = cy - ph / 2, r = rot, radius = 8, op = 1;
    if (last) {
      w = pw + (size.width - pw) * z;
      h = ph + (size.height - ph) * z;
      left = (cx - pw / 2) * (1 - z);
      top = (cy - ph / 2) * (1 - z);
      radius = 8 * (1 - z);
    } else {
      left += dx * size.width * 0.6 * z;
      top += dy * size.height * 0.6 * z;
      op = 1 - z;
    }
    return Positioned(
      left: left,
      top: top,
      width: w,
      height: h,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.55, end: 1),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutBack,
        builder: (_, s, child) => Opacity(
          opacity: op * ((s - 0.55) / 0.45).clamp(0, 1),
          child: Transform.rotate(
            angle: r * (1 - (last ? z : 0)),
            child: Transform.scale(scale: s, child: child),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 30, offset: Offset(0, 20))],
            color: C.dark2,
          ),
          clipBehavior: Clip.antiAlias,
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: last ? 0.45 * z : 0), BlendMode.darken),
            child: Image.network(
              photo(i),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => ColoredBox(color: C.dark2),
            ),
          ),
        ),
      ),
    );
  }
}
