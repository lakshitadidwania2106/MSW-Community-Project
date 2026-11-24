import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Shrinks slightly while pressed — every tappable thing in the app uses it.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.onTap, this.scale = 0.96});
  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(scale: _down ? widget.scale : 1, duration: const Duration(milliseconds: 180), curve: Curves.easeOutCubic, child: widget.child),
    );
  }
}

/// Fades + slides its child in after [delay] ms (staggered entrances).
class Reveal extends StatefulWidget {
  const Reveal({super.key, required this.child, this.delay = 0, this.offset = 28, this.ms = 800});
  final Widget child;
  final int delay, ms;
  final double offset;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: widget.ms),
  );
  late final Animation<double> _a = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _a,
    child: widget.child,
    builder: (_, child) => Opacity(
      opacity: _a.value,
      child: Transform.translate(offset: Offset(0, (1 - _a.value) * widget.offset), child: child),
    ),
  );
}

String fmtNum(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

class CountUp extends StatelessWidget {
  const CountUp({super.key, required this.to, required this.style, this.prefix = '', this.suffix = '', this.ms = 1600});
  final int to, ms;
  final TextStyle style;
  final String prefix, suffix;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: to.toDouble()),
    duration: Duration(milliseconds: ms),
    curve: Curves.easeOutQuart,
    builder: (_, v, _) => Text('$prefix${fmtNum(v.round())}$suffix', style: style),
  );
}

/// Serif headline with an italic second half — the signature MSW type style.
class Headline extends StatelessWidget {
  const Headline(this.a, this.b, {super.key, this.size = 44, this.color, this.italicColor, this.align = TextAlign.start});
  final String a, b;
  final double size;
  final Color? color, italicColor;
  final TextAlign align;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: a,
          style: serif(size, color: color),
        ),
        TextSpan(
          text: b,
          style: serif(size, color: italicColor ?? color, italic: true),
        ),
      ],
    ),
    textAlign: align,
  );
}

class Tag extends StatelessWidget {
  const Tag(this.text, {super.key, this.bg, this.fg});
  final String text;
  final Color? bg, fg;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: bg ?? C.bg2, borderRadius: BorderRadius.circular(99)),
    child: Text(
      text,
      style: sans(12, color: fg ?? (bg == null ? C.ink : C.black), weight: FontWeight.w500, height: 1.2),
    ),
  );
}

class GAvatar extends StatelessWidget {
  const GAvatar(this.initials, {super.key, this.colors = const [Color(0xFFFF9A76), Color(0xFFC86DD7)], this.size = 40, this.radius});
  final String initials;
  final List<Color> colors;
  final double size;
  final double? radius;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(radius ?? size / 2),
    ),
    child: Text(
      initials,
      style: sans(size * 0.32, color: Colors.white, weight: FontWeight.w600),
    ),
  );
}

/// Pill button; [loading] swaps the label for a sweeping bar.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton(this.label, {super.key, this.onTap, this.bg, this.fg, this.loading = false, this.icon = true, this.height = 58});
  final String label;
  final VoidCallback? onTap;
  final Color? bg, fg;
  final bool loading, icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bg = this.bg ?? C.ink, fg = this.fg ?? (this.bg == null ? C.onInk : Colors.white);
    return Pressable(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (loading) const Positioned.fill(child: _Sweep()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Row(
                    key: ValueKey(loading ? 'l' : label),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        loading ? 'One sec…' : label,
                        style: sans(height < 50 ? 14 : 16, color: fg, weight: FontWeight.w600),
                      ),
                      if (icon && !loading) ...[const SizedBox(width: 10), Icon(Icons.arrow_forward_rounded, color: fg, size: 18)],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sweep extends StatefulWidget {
  const _Sweep();
  @override
  State<_Sweep> createState() => _SweepState();
}

class _SweepState extends State<_Sweep> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, _) => FractionallySizedBox(
      alignment: Alignment(-1 + _c.value * 2, 0),
      widthFactor: 0.4,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.white.withValues(alpha: 0), Colors.white.withValues(alpha: 0.25), Colors.white.withValues(alpha: 0)])),
      ),
    ),
  );
}

/// Soft animated colour blobs — used behind hackathon cards & reels.
class Blobs extends StatefulWidget {
  const Blobs({super.key, required this.base, required this.colors, this.blur = true, this.square = true});
  final Color base;
  final List<Color> colors;
  final bool blur, square;

  @override
  State<Blobs> createState() => _BlobsState();
}

class _BlobsState extends State<Blobs> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(painter: _BlobPainter(_c, widget), size: Size.infinite),
  );
}

class _BlobPainter extends CustomPainter {
  _BlobPainter(this.a, this.w) : super(repaint: a);
  final Animation<double> a;
  final Blobs w;

  @override
  void paint(Canvas canvas, Size s) {
    canvas.drawRect(Offset.zero & s, Paint()..color = w.base);
    final t = a.value * math.pi * 2;
    final p = Paint();
    if (w.blur) p.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    final specs = [
      [0.85, 0.15, 0.42, 0.9, 1.0],
      [0.1, 0.5, 0.3, 1.3, 0.7],
      [0.5, 0.25, 0.16, 0.7, 1.6],
    ];
    for (var i = 0; i < w.colors.length && i < 3; i++) {
      final sp = specs[i];
      final cx = s.width * (sp[0] + 0.06 * math.sin(t * sp[3] + i));
      final cy = s.height * (sp[1] + 0.05 * math.cos(t * sp[4] + i * 2));
      final r = s.width * sp[2];
      p.color = w.colors[i];
      if (i == 2 && w.square) {
        canvas.save();
        canvas.translate(cx, cy);
        canvas.rotate(t * 0.3);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: r * 1.6, height: r * 1.6), const Radius.circular(10)), p);
        canvas.restore();
      } else {
        canvas.drawCircle(Offset(cx, cy), r, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Section label like "( THE PLATFORM )".
class Label extends StatelessWidget {
  const Label(this.text, {super.key, this.color});
  final String text;
  final Color? color;
  @override
  Widget build(BuildContext context) => Text('( ${text.toUpperCase()} )', style: mono(11, color: color));
}

class Card2 extends StatelessWidget {
  const Card2({super.key, required this.child, this.color, this.padding = const EdgeInsets.all(20), this.radius = 24, this.border = true});
  final Widget child;
  final Color? color;
  final EdgeInsets padding;
  final double radius;
  final bool border;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color ?? C.paper,
      borderRadius: BorderRadius.circular(radius),
      border: border ? Border.all(color: C.line) : null,
    ),
    child: child,
  );
}
