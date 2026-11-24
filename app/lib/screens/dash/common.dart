import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data.dart';
import '../../theme.dart';
import '../../widgets/halftone.dart';
import '../../widgets/scene.dart';
import '../../widgets/ui.dart';
import '../onboarding.dart';

extension SizedW on Widget {
  Widget sized(double w) => SizedBox(width: w, child: this);
}

String fmtD(double v, int dec) => dec == 0 ? fmtNum(v.round()) : v.toStringAsFixed(dec);

/// Header shared by every role dashboard: logo, role chip, theme toggle, bell, headline.
class DashHeader extends StatelessWidget {
  const DashHeader({super.key, required this.role, required this.a, required this.b, this.sub, this.notes = const []});
  final RoleInfo role;
  final String a, b;
  final String? sub;
  final List<(IconData, String)> notes;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Logo(height: 24),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: role.color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(99)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(role.icon, size: 13, color: role.color),
                const SizedBox(width: 5),
                Text(
                  role.name,
                  style: sans(12, weight: FontWeight.w600, color: role.color),
                ),
              ],
            ),
          ),
          const Spacer(),
          const ThemeToggle(),
          const SizedBox(width: 8),
          Pressable(
            onTap: () => showSheet(
              context,
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notifications', style: serif(34)),
                  const SizedBox(height: 12),
                  for (final n in notes)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card2(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(color: C.bg2, borderRadius: BorderRadius.circular(12)),
                              child: Icon(n.$1, size: 19, color: C.ink),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(n.$2, style: sans(14))),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: C.paper,
                    shape: BoxShape.circle,
                    border: Border.all(color: C.line),
                  ),
                  child: Icon(Icons.notifications_none_rounded, size: 20, color: C.ink),
                ),
                if (notes.isNotEmpty)
                  Positioned(
                    right: 9,
                    top: 9,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Color(0xFFFF5A5F), shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 18),
      Reveal(child: Headline(a, b, size: 40, italicColor: role.color)),
      if (sub != null) ...[const SizedBox(height: 6), Text(sub!, style: sans(14, color: C.muted))],
    ],
  );
}

/// Bottom sheet with the app's paper surface.
Future<T?> showSheet<T>(BuildContext context, Widget child) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (ctx) => Container(
    constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.88),
    padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(ctx).viewInsets.bottom + MediaQuery.of(ctx).padding.bottom + 20),
    decoration: BoxDecoration(
      color: C.paper,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: C.line2, borderRadius: BorderRadius.circular(4)),
            ),
          ),
          child,
        ],
      ),
    ),
  ),
);

void toast(BuildContext context, String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.a, {super.key, this.b, this.action, this.onAction});
  final String a;
  final String? b, action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: a, style: serif(28)),
              if (b != null) TextSpan(text: ' $b', style: serif(28, italic: true)),
            ],
          ),
        ),
        const Spacer(),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: sans(13, color: C.muted, weight: FontWeight.w500),
            ),
          ),
      ],
    ),
  );
}

/// Animated stat tile with a sparkline.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.accent,
    this.prefix = '',
    this.suffix = '',
    this.delta,
    this.down = false,
    this.spark = const [],
    this.dec = 0,
    this.icon,
  });
  final String label, prefix, suffix;
  final double value;
  final Color accent;
  final String? delta;
  final bool down;
  final List<double> spark;
  final int dec;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Card2(
    padding: const EdgeInsets.all(14),
    radius: 22,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[Icon(icon, size: 14, color: C.muted), const SizedBox(width: 6)],
            Expanded(
              child: Text(label.toUpperCase(), style: mono(9.5), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutQuart,
          builder: (_, v, _) => FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text('$prefix${fmtD(v, dec)}$suffix', style: serif(40)),
          ),
        ),
        if (delta != null) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: (down ? const Color(0xFFE5484D) : C.tealD).withValues(alpha: 0.14), borderRadius: BorderRadius.circular(99)),
            child: Text(
              '${down ? '↓' : '↑'} $delta',
              style: sans(11, weight: FontWeight.w600, color: down ? const Color(0xFFE5484D) : C.tealD),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        if (spark.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 34,
            width: double.infinity,
            child: Spark(spark, color: accent),
          ),
        ],
      ],
    ),
  );
}

/// Tiny sparkline that draws itself in.
class Spark extends StatelessWidget {
  const Spark(this.data, {super.key, required this.color});
  final List<double> data;
  final Color color;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 1400),
    curve: Curves.easeOutCubic,
    builder: (_, k, _) => CustomPaint(painter: _LinePainter([data], [color], k, fill: true, grid: false)),
  );
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.series, this.colors, this.k, {this.fill = true, this.grid = true, this.gridColor});
  final List<List<double>> series;
  final List<Color> colors;
  final double k;
  final bool fill, grid;
  final Color? gridColor;

  @override
  void paint(Canvas canvas, Size s) {
    final all = series.expand((e) => e).toList();
    final mx = all.reduce(math.max) * 1.12, mn = grid ? 0.0 : all.reduce(math.min);
    if (grid) {
      final gp = Paint()
        ..color = gridColor ?? Colors.grey.withValues(alpha: 0.18)
        ..strokeWidth = 1;
      for (var g = 1; g <= 3; g++) {
        canvas.drawLine(Offset(0, s.height * g / 4), Offset(s.width, s.height * g / 4), gp);
      }
    }
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, -10, s.width * k, s.height + 20));
    for (var si = series.length - 1; si >= 0; si--) {
      final d = series[si];
      final pts = [for (var i = 0; i < d.length; i++) Offset(i / (d.length - 1) * s.width, s.height - (d[i] - mn) / (mx - mn == 0 ? 1 : mx - mn) * s.height)];
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (var i = 0; i < pts.length - 1; i++) {
        final p0 = i > 0 ? pts[i - 1] : pts[i], p1 = pts[i], p2 = pts[i + 1], p3 = i + 2 < pts.length ? pts[i + 2] : p2;
        path.cubicTo(p1.dx + (p2.dx - p0.dx) / 6, p1.dy + (p2.dy - p0.dy) / 6, p2.dx - (p3.dx - p1.dx) / 6, p2.dy - (p3.dy - p1.dy) / 6, p2.dx, p2.dy);
      }
      if (fill && si == 0) {
        final area = Path.from(path)
          ..lineTo(s.width, s.height)
          ..lineTo(0, s.height)
          ..close();
        canvas.drawPath(
          area,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colors[0].withValues(alpha: 0.28), colors[0].withValues(alpha: 0)],
            ).createShader(Offset.zero & s),
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = si == 0 ? colors[si] : colors[si].withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = si == 0 ? 2.4 : 1.8
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) => old.k != k || old.colors != colors;
}

/// Card with a multi-series line chart and legend.
class ChartCard extends StatelessWidget {
  const ChartCard({super.key, required this.a, required this.b, required this.series, required this.labels});
  final String a, b;
  final List<(String, Color, List<double>)> series;
  final List<String> labels;
  @override
  Widget build(BuildContext context) => Card2(
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: a, style: serif(26)),
              TextSpan(text: ' $b', style: serif(26, italic: true)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 14,
          children: [
            for (final s in series)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(color: s.$2, borderRadius: BorderRadius.circular(3)),
                  ),
                  const SizedBox(width: 6),
                  Text(s.$1, style: sans(12, color: C.muted)),
                ],
              ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 150,
          width: double.infinity,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1800),
            curve: Curves.easeOutCubic,
            builder: (_, k, _) => CustomPaint(painter: _LinePainter([for (final s in series) s.$3], [for (final s in series) s.$2], k, gridColor: C.line)),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [for (var i = 0; i < labels.length; i += (labels.length / 5).ceil()) Text(labels[i], style: mono(9))],
        ),
      ],
    ),
  );
}

/// Horizontal bars that grow in (sqrt scaling keeps small values visible).
class BarList extends StatelessWidget {
  const BarList(this.items, {super.key, required this.color});
  final List<(String, double)> items;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final mx = items.map((e) => e.$2).reduce(math.max);
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 86,
                  child: Text(items[i].$1, style: sans(13), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                Expanded(
                  child: Container(
                    height: 26,
                    decoration: BoxDecoration(color: C.bg2, borderRadius: BorderRadius.circular(8)),
                    alignment: Alignment.centerLeft,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: math.max(0.05, math.sqrt(items[i].$2 / mx))),
                      duration: Duration(milliseconds: 1200 + i * 150),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, _) => FractionallySizedBox(
                        widthFactor: v,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(colors: [color, C.teal]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 54,
                  child: Text(
                    fmtNum(items[i].$2.round()),
                    textAlign: TextAlign.right,
                    style: sans(13, weight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Donut with legend.
class Donut extends StatelessWidget {
  const Donut(this.segs, {super.key, required this.center, required this.sub});
  final List<(String, double, Color)> segs;
  final String center, sub;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 130,
        height: 130,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutCubic,
          builder: (_, k, _) => CustomPaint(
            painter: _DonutPainter(segs, k, C.bg2),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(center, style: serif(30)),
                  Text(sub, style: sans(10, color: C.muted)),
                ],
              ),
            ),
          ),
        ),
      ),
      const SizedBox(width: 18),
      Expanded(
        child: Column(
          children: [
            for (final s in segs)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: s.$3, borderRadius: BorderRadius.circular(3)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(s.$1, style: sans(13))),
                    Text(fmtNum(s.$2.round()), style: sans(13, weight: FontWeight.w700)),
                  ],
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.segs, this.k, this.track);
  final List<(String, double, Color)> segs;
  final double k;
  final Color track;
  @override
  void paint(Canvas canvas, Size s) {
    final rect = Rect.fromCircle(center: s.center(Offset.zero), radius: s.width / 2 - 10);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16;
    canvas.drawArc(rect, 0, math.pi * 2, false, p..color = track);
    final total = segs.fold<double>(0, (a, b) => a + b.$2);
    var start = -math.pi / 2;
    for (final sg in segs) {
      final sweep = sg.$2 / total * math.pi * 2 * k;
      canvas.drawArc(rect, start, sweep, false, p..color = sg.$3);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.k != k || old.track != track;
}

class QuickAction extends StatelessWidget {
  const QuickAction(this.icon, this.label, {super.key, required this.color, required this.onTap, this.dark = false});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool dark;
  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    child: Container(
      height: 96,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: dark ? C.dark : color, borderRadius: BorderRadius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: dark ? color : Colors.white, size: 22),
          const Spacer(),
          Text(
            label,
            style: sans(14, weight: FontWeight.w700, color: Colors.white, height: 1.2),
          ),
        ],
      ),
    ),
  );
}

/// Collapses + fades a list item away (approve / reject / dismiss).
class Removable extends StatelessWidget {
  const Removable({super.key, required this.removed, required this.child, this.left = false});
  final bool removed, left;
  final Widget child;
  @override
  Widget build(BuildContext context) => AnimatedSize(
    duration: const Duration(milliseconds: 450),
    curve: Curves.easeInOutCubic,
    child: AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (c, a) => FadeTransition(
        opacity: a,
        child: SlideTransition(
          position: Tween(begin: Offset(left ? -0.3 : 0.3, 0), end: Offset.zero).animate(a),
          child: c,
        ),
      ),
      child: removed ? const SizedBox(width: double.infinity, key: ValueKey('gone')) : KeyedSubtree(key: const ValueKey('here'), child: child),
    ),
  );
}

/// Pill chips with counts (used for stages / filters).
class ChipBar extends StatelessWidget {
  const ChipBar({super.key, required this.items, required this.sel, required this.onSel, required this.color});
  final List<String> items;
  final int sel;
  final ValueChanged<int> onSel;
  final Color color;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 40,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (_, i) => Pressable(
        onTap: () => onSel(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: i == sel ? color : C.bg2, borderRadius: BorderRadius.circular(99)),
          child: Text(
            items[i],
            style: sans(13, weight: FontWeight.w600, color: i == sel ? Colors.white : C.muted),
          ),
        ),
      ),
    ),
  );
}

/// Shared "Account" tab: profile card, appearance (light/dark), settings, log out.
class AccountTab extends StatelessWidget {
  const AccountTab({super.key, required this.role, required this.name, required this.sub, required this.initials, this.extra = const []});
  final RoleInfo role;
  final String name, sub, initials;
  final List<Widget> extra;

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 110),
      children: [
        DashHeader(role: role, a: 'Your ', b: 'account.'),
        const SizedBox(height: 18),
        Container(
          height: 170,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(26)),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(child: Container(color: C.black)),
              Positioned.fill(child: Halftone(color: Colors.white.withValues(alpha: 0.85), band: false, swirlX: 1.05, swirlY: 0.3, spacing: 9)),
              Positioned(
                left: 18,
                bottom: 18,
                right: 18,
                child: Row(
                  children: [
                    GAvatar(initials, size: 58, colors: [role.color, C.teal]),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: serif(30, color: Colors.white)),
                          Text(sub, style: sans(13, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Positioned(left: 18, top: 18, child: Logo(light: true, height: 22)),
              Positioned(
                right: 16,
                top: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(99)),
                  child: Row(
                    children: [
                      Icon(role.icon, size: 13, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(role.name.toUpperCase(), style: mono(9, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text('APPEARANCE', style: mono(10)),
        const SizedBox(height: 8),
        _Appearance(color: role.color),
        ...extra,
        const SizedBox(height: 18),
        Text('SETTINGS', style: mono(10)),
        const SizedBox(height: 8),
        Card2(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              _row(context, Icons.edit_rounded, 'Edit profile', 'Name, logo, details'),
              _row(context, Icons.notifications_active_rounded, 'Notifications', 'Push & email'),
              _row(context, Icons.lock_rounded, 'Privacy & security', '2FA, sessions'),
              _row(context, Icons.help_outline_rounded, 'Help & support', 'support@mystartupwave.com'),
              _row(context, Icons.logout_rounded, 'Log out', 'See you soon', last: true, onTap: () => Navigator.of(context).pushAndRemoveUntil(fadeRoute(const OnboardingScreen()), (_) => false)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, IconData ic, String t, String s, {VoidCallback? onTap, bool last = false}) => Pressable(
    onTap: onTap ?? () => toast(context, '$t — coming soon'),
    scale: 0.98,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: C.line)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: C.bg2, borderRadius: BorderRadius.circular(11)),
            child: Icon(ic, size: 18, color: C.ink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t, style: sans(14, weight: FontWeight.w600, height: 1.2)),
                Text(
                  s,
                  style: sans(12, color: C.muted, height: 1.3),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: C.muted),
        ],
      ),
    ),
  );
}

class _Appearance extends StatelessWidget {
  const _Appearance({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) {
    final d = darkMode.value;
    Widget opt(bool dark, String label, IconData ic) => Expanded(
      child: Pressable(
        onTap: () => darkMode.value = dark,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          height: 86,
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF16161A) : const Color(0xFFF7F6F3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: d == dark ? color : C.line, width: d == dark ? 2 : 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(ic, color: dark ? C.onDark : C.black),
              const SizedBox(height: 6),
              Text(
                label,
                style: sans(13, weight: FontWeight.w600, color: dark ? C.onDark : C.black),
              ),
            ],
          ),
        ),
      ),
    );
    return Row(children: [opt(false, 'Light', Icons.light_mode_rounded), const SizedBox(width: 10), opt(true, 'Dark', Icons.dark_mode_rounded)]);
  }
}

/// Add / remove items as chips (skills, perks, rounds, tracks…).
class ChipsEditor extends StatefulWidget {
  const ChipsEditor({super.key, required this.items, required this.hint, this.onChanged, this.numbered = false});
  final List<String> items;
  final String hint;
  final VoidCallback? onChanged;
  final bool numbered;
  @override
  State<ChipsEditor> createState() => _ChipsEditorState();
}

class _ChipsEditorState extends State<ChipsEditor> {
  final _ctl = TextEditingController();
  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _add() {
    final v = _ctl.text.trim();
    if (v.isEmpty) return;
    setState(() => widget.items.add(v));
    _ctl.clear();
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (widget.numbered)
        for (var i = 0; i < widget.items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: C.ink, shape: BoxShape.circle),
                  child: Text(
                    '${i + 1}',
                    style: sans(11, color: C.onInk, weight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(widget.items[i], style: sans(14))),
                GestureDetector(
                  onTap: () {
                    setState(() => widget.items.removeAt(i));
                    widget.onChanged?.call();
                  },
                  child: Icon(Icons.close_rounded, size: 18, color: C.muted),
                ),
              ],
            ),
          )
      else
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final it in List.of(widget.items))
              Container(
                padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
                decoration: BoxDecoration(color: C.bg2, borderRadius: BorderRadius.circular(99)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(it, style: sans(13)),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        setState(() => widget.items.remove(it));
                        widget.onChanged?.call();
                      },
                      child: Icon(Icons.close_rounded, size: 16, color: C.muted),
                    ),
                  ],
                ),
              ),
          ],
        ),
      const SizedBox(height: 8),
      TextField(
        controller: _ctl,
        onSubmitted: (_) => _add(),
        style: sans(14),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: sans(13, color: C.muted),
          isDense: true,
          filled: true,
          fillColor: C.card,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          suffixIcon: IconButton(
            onPressed: _add,
            icon: Icon(Icons.add_circle_rounded, color: C.ink),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: C.line2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: C.ink),
          ),
        ),
      ),
    ],
  );
}

/// Labelled form section used by the long posting forms.
class FormSection extends StatelessWidget {
  const FormSection(this.n, this.title, {super.key, required this.children});
  final int n;
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: C.paper,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: C.line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: C.ink, shape: BoxShape.circle),
              child: Text(
                '$n',
                style: sans(12, color: C.onInk, weight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 10),
            Text(title, style: serif(24)),
          ],
        ),
        const SizedBox(height: 14),
        for (final c in children) Padding(padding: const EdgeInsets.only(bottom: 10), child: c),
      ],
    ),
  );
}

/// Single-select pill row.
class PillSelect extends StatelessWidget {
  const PillSelect({super.key, required this.options, required this.value, required this.onChanged, this.label});
  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;
  final String? label;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (label != null) ...[Text(label!.toUpperCase(), style: mono(9.5)), const SizedBox(height: 6)],
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final o in options)
            GestureDetector(
              onTap: () => onChanged(o),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: o == value ? C.ink : C.card,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: o == value ? C.ink : C.line2),
                ),
                child: Text(
                  o,
                  style: sans(13, weight: FontWeight.w500, color: o == value ? C.onInk : C.ink),
                ),
              ),
            ),
        ],
      ),
    ],
  );
}
