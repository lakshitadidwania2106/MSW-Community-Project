import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';

/// Palette for an illustrated scene (sky, hills, sun/moon, stickers).
class ScenePalette {
  const ScenePalette({required this.sky, required this.hills, required this.sun, required this.accent, required this.emoji, required this.seal, this.stars = false, this.onSky = Colors.white});
  final List<Color> sky; // top → horizon
  final List<Color> hills; // back → front
  final Color sun, accent, onSky;
  final List<String> emoji;
  final String seal;
  final bool stars;
}

const welcomePalettes = [
  ScenePalette(
    sky: [Color(0xFF4E7E86), Color(0xFFB9C7B4), Color(0xFFF1DDB0)],
    hills: [Color(0xFF6F9C8F), Color(0xFF2E6467), Color(0xFF184449)],
    sun: Color(0xFFFFD98A),
    accent: C.lime,
    emoji: ['🎓', '⚡', '🚀'],
    seal: 'WELCOME • MSW COMMUNITY • ',
    stars: true,
  ),
  ScenePalette(
    sky: [Color(0xFF7B68EE), Color(0xFFB4A5FF), Color(0xFFE6DEFF)],
    hills: [Color(0xFF9D8CF7), Color(0xFF6C5CE7), Color(0xFF4A3BC4)],
    sun: C.lime,
    accent: C.lime,
    emoji: ['📚', '💻', '🏆'],
    seal: 'LEARN • BUILD • SHIP • ',
    stars: false,
  ),
  ScenePalette(
    sky: [Color(0xFFFF8A65), Color(0xFFFFB38A), Color(0xFFFFE0B2)],
    hills: [Color(0xFFF4A07A), Color(0xFFE8613F), Color(0xFFB9452A)],
    sun: Color(0xFFFFF3C4),
    accent: C.lime,
    emoji: ['💼', '💡', '📈'],
    seal: 'GET DISCOVERED • GET HIRED • ',
    stars: false,
  ),
];

final rolePalettes = <Role, ScenePalette>{
  Role.student: const ScenePalette(
    sky: [Color(0xFF7B68EE), Color(0xFFA996FF), Color(0xFFE2D9FF)],
    hills: [Color(0xFF9D8CF7), Color(0xFF6C5CE7), Color(0xFF4A3BC4)],
    sun: C.lime,
    accent: C.lime,
    emoji: ['🎓', '⚡', '📚'],
    seal: 'STUDENT • LEARN • BUILD • ',
  ),
  Role.company: const ScenePalette(
    sky: [Color(0xFFFF7A59), Color(0xFFFFA77F), Color(0xFFFFDDB8)],
    hills: [Color(0xFFF59A76), Color(0xFFE8613F), Color(0xFFB0412A)],
    sun: Color(0xFFFFF3C4),
    accent: C.lime,
    emoji: ['💼', '🤝', '🏢'],
    seal: 'COMPANY • HIRE • BUILD • ',
  ),
  Role.investor: const ScenePalette(
    sky: [Color(0xFF120D3D), Color(0xFF2B2283), Color(0xFF5B4FCF)],
    hills: [Color(0xFF3A2FA0), Color(0xFF231A70), Color(0xFF130E45)],
    sun: Color(0xFFE9E4FF),
    accent: C.lilac,
    emoji: ['📈', '💡', '🚀'],
    seal: 'INVESTOR • BACK IDEAS EARLY • ',
    stars: true,
  ),
  Role.college: const ScenePalette(
    sky: [Color(0xFF5AA9E6), Color(0xFF8CC8FF), Color(0xFFD8EEFF)],
    hills: [Color(0xFF7DB8EC), Color(0xFF0A66C2), Color(0xFF08498C)],
    sun: Color(0xFFFFE680),
    accent: C.lime,
    emoji: ['🏛', '🏆', '🎤'],
    seal: 'COLLEGE • HOST • JUDGE • ',
  ),
  Role.admin: const ScenePalette(
    sky: [Color(0xFF0B2624), Color(0xFF14403B), Color(0xFF2F6B61)],
    hills: [Color(0xFF225A52), Color(0xFF123B36), Color(0xFF09211F)],
    sun: C.teal,
    accent: C.teal,
    emoji: ['🛡', '⚙️', '📊'],
    seal: 'ADMIN • MISSION CONTROL • ',
    stars: true,
  ),
};

/// Animated landscape: gradient sky, twinkling stars, halftone sun, drifting hills.
class Scene extends StatefulWidget {
  const Scene({super.key, required this.p, this.horizon = 0.62, this.showSun = true});
  final ScenePalette p;
  final double horizon;
  final bool showSun;
  @override
  State<Scene> createState() => _SceneState();
}

class _SceneState extends State<Scene> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 24))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(painter: _ScenePainter(_c, widget.p, widget.horizon, widget.showSun), size: Size.infinite),
  );
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.a, this.p, this.horizon, this.sun) : super(repaint: a);
  final Animation<double> a;
  final ScenePalette p;
  final double horizon;
  final bool sun;

  @override
  void paint(Canvas canvas, Size s) {
    final t = a.value * math.pi * 2;
    final rect = Offset.zero & s;
    canvas.drawRect(rect, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: p.sky).createShader(rect));
    // stars
    if (p.stars) {
      final r = math.Random(3);
      final sp = Paint()..color = Colors.white;
      for (var i = 0; i < 46; i++) {
        final x = r.nextDouble() * s.width, y = r.nextDouble() * s.height * horizon * 0.8;
        final tw = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(t * 3 + i));
        sp.color = Colors.white.withValues(alpha: tw * 0.9);
        canvas.drawCircle(Offset(x, y), 0.6 + r.nextDouble() * 1.3, sp);
      }
    }
    // halftone sun / moon
    if (sun) {
      final c = Offset(s.width * 0.76, s.height * horizon * 0.42 + math.sin(t) * 4), R = s.width * 0.17;
      canvas.drawCircle(
        c,
        R * 1.9,
        Paint()
          ..color = p.sun.withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
      );
      canvas.drawCircle(c, R, Paint()..color = p.sun);
      final dot = Paint()..color = Colors.black.withValues(alpha: 0.09);
      for (double y = -R; y <= R; y += 7) {
        for (double x = -R; x <= R; x += 7) {
          final d = math.sqrt(x * x + y * y);
          if (d > R - 2) continue;
          final k = ((x + y) / (2 * R) + 0.5).clamp(0.0, 1.0);
          canvas.drawCircle(c + Offset(x, y), 0.4 + k * 2.2, dot);
        }
      }
    }
    // hills (back → front), each drifting slowly
    for (var i = 0; i < p.hills.length; i++) {
      final base = s.height * (horizon + i * 0.07);
      final amp = s.height * (0.06 - i * 0.012), freq = 1.4 + i * 0.6, ph = t * (0.15 + i * 0.1) + i * 1.7;
      final path = Path()..moveTo(0, s.height);
      for (double x = 0; x <= s.width + 4; x += 4) {
        final y = base - amp * (0.6 * math.sin(x / s.width * math.pi * freq + ph) + 0.4 * math.sin(x / s.width * math.pi * freq * 2.3 - ph * 0.7));
        path.lineTo(x, y);
      }
      path
        ..lineTo(s.width, s.height)
        ..close();
      canvas.drawPath(path, Paint()..color = p.hills[i]);
      // halftone shading on the front hill
      if (i == p.hills.length - 1) {
        final sh = Paint()..color = Colors.black.withValues(alpha: 0.12);
        for (double y = base - amp; y < s.height; y += 9) {
          for (double x = (y ~/ 9).isEven ? 0 : 4.5; x < s.width; x += 9) {
            final k = ((y - base) / (s.height - base)).clamp(0.0, 1.0);
            canvas.drawCircle(Offset(x, y), 0.3 + k * 1.6, sh);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) => old.p != p;
}

/// Rotating starburst seal with text around the edge (like a sticker).
class Seal extends StatefulWidget {
  const Seal({super.key, required this.text, required this.color, this.size = 110, this.center = '✦', this.textColor = C.black});
  final String text, center;
  final Color color, textColor;
  final double size;
  @override
  State<Seal> createState() => _SealState();
}

class _SealState extends State<Seal> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: widget.size,
    height: widget.size,
    child: Stack(
      alignment: Alignment.center,
      children: [
        RotationTransition(
          turns: _c,
          child: CustomPaint(size: Size.square(widget.size), painter: _SealPainter(widget.text, widget.color, widget.textColor)),
        ),
        Text(widget.center, style: TextStyle(fontSize: widget.size * 0.26)),
      ],
    ),
  );
}

class _SealPainter extends CustomPainter {
  _SealPainter(this.text, this.color, this.textColor);
  final String text;
  final Color color, textColor;

  @override
  void paint(Canvas canvas, Size s) {
    final c = s.center(Offset.zero), R = s.width / 2;
    final path = Path();
    const n = 18;
    for (var i = 0; i <= n * 2; i++) {
      final a = i / (n * 2) * math.pi * 2, r = i.isEven ? R : R * 0.9;
      final p = c + Offset(math.cos(a), math.sin(a)) * r;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, Paint()..color = color);
    final chars = text.split('');
    final rr = R * 0.66;
    for (var i = 0; i < chars.length; i++) {
      final a = i / chars.length * math.pi * 2 - math.pi / 2;
      final tp = TextPainter(
        text: TextSpan(
          text: chars[i],
          style: TextStyle(fontSize: R * 0.16, fontWeight: FontWeight.w800, color: textColor, letterSpacing: 0),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      canvas.translate(c.dx + math.cos(a) * rr, c.dy + math.sin(a) * rr);
      canvas.rotate(a + math.pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SealPainter old) => old.text != text || old.color != color;
}

/// Emoji sticker that bobs gently.
class Sticker extends StatefulWidget {
  const Sticker(this.emoji, {super.key, this.size = 54, this.bg = Colors.white, this.delay = 0, this.rotate = -0.12});
  final String emoji;
  final double size, rotate;
  final Color bg;
  final int delay;
  @override
  State<Sticker> createState() => _StickerState();
}

class _StickerState extends State<Sticker> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200));
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _c.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, child) => Transform.translate(
      offset: Offset(0, -8 * Curves.easeInOut.transform(_c.value)),
      child: Transform.rotate(angle: widget.rotate + 0.08 * _c.value, child: child),
    ),
    child: Container(
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.bg,
        borderRadius: BorderRadius.circular(widget.size * 0.32),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 18, offset: Offset(0, 10))],
      ),
      child: Text(widget.emoji, style: TextStyle(fontSize: widget.size * 0.48)),
    ),
  );
}

/// The MSW logo. Picks the light or dark artwork for the background it sits on.
class Logo extends StatelessWidget {
  const Logo({super.key, this.height = 28, this.light});
  final double height;
  final bool? light;
  @override
  Widget build(BuildContext context) => Image.asset((light ?? darkMode.value) ? 'assets/brand/logo_light.png' : 'assets/brand/logo_dark.png', height: height, filterQuality: FilterQuality.medium);
}

/// Sun / moon button that flips the theme.
class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key, this.onImage = false});
  final bool onImage;
  @override
  Widget build(BuildContext context) {
    final d = darkMode.value;
    return GestureDetector(
      onTap: toggleTheme,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onImage ? Colors.white.withValues(alpha: 0.18) : C.paper,
          border: Border.all(color: onImage ? Colors.white30 : C.line),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (c, a) => RotationTransition(
            turns: Tween(begin: 0.6, end: 1.0).animate(a),
            child: FadeTransition(opacity: a, child: c),
          ),
          child: Icon(d ? Icons.dark_mode_rounded : Icons.light_mode_rounded, key: ValueKey(d), size: 20, color: onImage ? Colors.white : C.ink),
        ),
      ),
    );
  }
}
