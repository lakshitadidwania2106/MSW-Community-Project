import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';
import '../widgets/scene.dart';
import '../widgets/ui.dart';
import 'onboarding.dart';
import 'courses.dart';
import 'games.dart';
import 'pitch.dart';
import 'quiz.dart';
import 'plans.dart';
import 'resume.dart';

/// Profile = a digital student ID. Drag to tilt (holographic foil follows),
/// tap to flip to the QR side.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.role});
  final RoleInfo role;

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 110),
      children: [
        Row(
          children: [
            const Label('Your profile'),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: role.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(99)),
              child: Row(
                children: [
                  Icon(role.icon, size: 14, color: role.color),
                  const SizedBox(width: 5),
                  Text(
                    role.name,
                    style: sans(12, color: role.color, weight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const ThemeToggle(),
          ],
        ),
        const SizedBox(height: 8),
        const Reveal(child: Headline('Not a résumé. ', 'A passport.', size: 40)),
        const SizedBox(height: 18),
        const Reveal(delay: 120, child: IdCard()),
        const SizedBox(height: 8),
        Center(child: Text('Drag to tilt · Tap to flip', style: mono(10))),
        const SizedBox(height: 18),
        Reveal(
          delay: 200,
          child: Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  'Share ID',
                  icon: false,
                  height: 52,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile link copied: msw.community/aanya'))),
                ),
              ),
              const SizedBox(width: 10),
              Pressable(
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: C.line2),
                  ),
                  child: const Icon(Icons.qr_code_2_rounded),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Reveal(
          delay: 260,
          child: Card2(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                _row(Icons.edit_outlined, 'Edit profile', 'Name, college, skills'),
                _row(Icons.school_outlined, 'Courses · Day 1–30', 'Full Stack Web Development', onTap: () => Navigator.of(context).push(fadeRoute(const CoursesScreen()))),
                _row(Icons.psychology_outlined, 'Quizzes, IQ & reasoning', 'Scores show up on your ID', onTap: () => Navigator.of(context).push(fadeRoute(const QuizScreen(title: 'IQ test')))),
                _row(Icons.sports_esports_outlined, 'Games', 'Play and earn credits', onTap: () => Navigator.of(context).push(fadeRoute(const GamesScreen()))),
                _row(Icons.military_tech_outlined, 'Badges', '4 of 6 earned', onTap: () => _badges(context)),
                _row(Icons.description_outlined, 'Resume', 'Auto-built from your ID · ATS 92', onTap: () => Navigator.of(context).push(fadeRoute(const ResumeScreen()))),
                _row(Icons.lightbulb_outline_rounded, 'My business ideas', 'Pitch, validate, get funded', onTap: () => Navigator.of(context).push(fadeRoute(const PitchScreen()))),
                _row(Icons.workspace_premium_outlined, 'Credits & plans', '2,450 credits · Starter', onTap: () => Navigator.of(context).push(fadeRoute(const PlansScreen()))),
                _row(
                  darkMode.value ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                  'Appearance',
                  darkMode.value ? 'Dark mode · tap for light' : 'Light mode · tap for dark',
                  onTap: toggleTheme,
                ),
                _row(Icons.logout_rounded, 'Log out', 'See you soon', last: true, onTap: () => Navigator.of(context).pushAndRemoveUntil(fadeRoute(const OnboardingScreen()), (_) => false)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _badges(BuildContext context) => showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      padding: EdgeInsets.fromLTRB(20, 18, 20, MediaQuery.of(ctx).padding.bottom + 20),
      decoration: BoxDecoration(
        color: C.paper,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Badges', style: serif(34)),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              for (final b in badges)
                Container(
                  decoration: BoxDecoration(color: b.earned ? C.black : C.bg2, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(b.earned ? b.icon : Icons.lock_outline_rounded, size: 30, color: b.earned ? C.lime : C.muted),
                      const SizedBox(height: 8),
                      Text(
                        b.name,
                        textAlign: TextAlign.center,
                        style: sans(11, weight: FontWeight.w600, color: b.earned ? Colors.white : C.muted, height: 1.2),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _row(IconData ic, String t, String s, {VoidCallback? onTap, bool last = false}) => Pressable(
    onTap: onTap,
    scale: 0.98,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: C.line)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: C.bg2, borderRadius: BorderRadius.circular(12)),
            child: Icon(ic, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t, style: sans(15, weight: FontWeight.w600, height: 1.2)),
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

class IdCard extends StatefulWidget {
  const IdCard({super.key});
  @override
  State<IdCard> createState() => _IdCardState();
}

class _IdCardState extends State<IdCard> with TickerProviderStateMixin {
  late final AnimationController _flip = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
  late final AnimationController _holo = AnimationController(vsync: this, duration: const Duration(seconds: 7))..repeat();
  Offset _tilt = Offset.zero;
  bool _drag = false;

  @override
  void dispose() {
    _flip.dispose();
    _holo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth, h = w / 0.68;
        return GestureDetector(
          onTap: () => _flip.status == AnimationStatus.completed || _flip.status == AnimationStatus.forward ? _flip.reverse() : _flip.forward(),
          onPanStart: (_) => setState(() => _drag = true),
          onPanUpdate: (d) => setState(() {
            _tilt = Offset(((d.localPosition.dx / w) - 0.5).clamp(-0.5, 0.5), ((d.localPosition.dy / h) - 0.5).clamp(-0.5, 0.5));
          }),
          onPanEnd: (_) => setState(() {
            _drag = false;
            _tilt = Offset.zero;
          }),
          child: TweenAnimationBuilder<Offset>(
            tween: Tween(end: _tilt),
            duration: Duration(milliseconds: _drag ? 90 : 900),
            curve: _drag ? Curves.linear : Curves.elasticOut,
            builder: (_, t, _) => AnimatedBuilder(
              animation: Listenable.merge([_flip, _holo]),
              builder: (_, _) {
                final f = Curves.easeInOutCubic.transform(_flip.value);
                final angle = f * math.pi;
                final showBack = angle > math.pi / 2;
                final m = Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateX(-t.dy * 0.5)
                  ..rotateY(t.dx * 0.6 + angle);
                return SizedBox(
                  height: h,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: m,
                    child: showBack ? Transform(alignment: Alignment.center, transform: Matrix4.rotationY(math.pi), child: _back(w, h)) : _front(w, h, t),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _front(double w, double h, Offset t) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF161616), Color(0xFF232826), Color(0xFF0F1412)]),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 40, offset: Offset(-t.dx * 30, 30 - t.dy * 20))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // holographic foil
          Positioned.fill(
            child: Opacity(
              opacity: 0.32 + t.distance * 0.3,
              child: ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: SweepGradient(
                      center: Alignment(t.dx * 2, t.dy * 2),
                      colors: const [Color(0xFFFF7AD9), Color(0xFF7AFCFF), Color(0xFFFFF38A), Color(0xFF8AFFB4), Color(0xFFB98AFF), Color(0xFFFF7AD9)],
                      transform: GradientRotation(_holo.value * math.pi * 2 + t.dx * 3),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(child: CustomPaint(painter: _Lines())),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Logo(light: true, height: 26),
                    const Spacer(),
                    Text('STUDENT · VERIFIED', style: mono(9, color: Colors.white70)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 96,
                      height: 114,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFF9A76), Color(0xFFC86DD7), Color(0xFF6C5CE7)]),
                      ),
                      child: Text('AS', style: serif(38, color: Colors.white)),
                    ),
                    const Spacer(),
                    Container(
                      width: 48,
                      height: 38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: const LinearGradient(colors: [Color(0xFFD9C27A), Color(0xFFF6E7B0), Color(0xFFB39448)]),
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text('Aanya Sharma', style: serif(40, color: Colors.white)),
                const SizedBox(height: 4),
                Text('B.Tech Computer Science · 3rd year', style: sans(13, color: Colors.white70)),
                Text('IIT DELHI', style: mono(10, color: C.teal)),
                const Spacer(),
                Row(
                  children: [
                    for (final s in const [('14', 'Level'), ('9', 'Hacks'), ('23', 'Badges'), ('128', 'IQ')])
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.$1, style: serif(24, color: Colors.white)),
                              Text(s.$2, style: sans(10, color: Colors.white60)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text('MSW-2026-0412', style: mono(10, color: Colors.white70)),
                    const Spacer(),
                    SizedBox(width: 110, height: 26, child: CustomPaint(painter: _Barcode())),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _back(double w, double h) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: C.paper,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: C.line),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 40, offset: const Offset(0, 30))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Logo(height: 26),
              const Spacer(),
              Text('SCAN TO VIEW PROFILE', style: mono(9)),
            ],
          ),
          const Spacer(),
          Container(
            width: w * 0.62,
            height: w * 0.62,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: C.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: C.line),
            ),
            child: CustomPaint(painter: _Qr()),
          ),
          const Spacer(),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              for (final s in const ['React', 'Python', 'Figma', 'ML', 'Public speaking']) Tag(s),
            ],
          ),
          const SizedBox(height: 14),
          Text('VALID WHILE YOU KEEP BUILDING · MSW.COMMUNITY/AANYA', textAlign: TextAlign.center, style: mono(9)),
        ],
      ),
    );
  }
}

class _Lines extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 1;
    for (double x = -s.height; x < s.width; x += 7) {
      canvas.drawLine(Offset(x, s.height), Offset(x + s.height * 0.5, 0), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Barcode extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.85);
    final r = math.Random(12);
    double x = 0;
    while (x < s.width) {
      final w = 1.0 + r.nextInt(3);
      canvas.drawRect(Rect.fromLTWH(x, 0, w, s.height), p);
      x += w + 1 + r.nextInt(3);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Qr extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    const n = 21;
    final cell = s.width / n;
    final p = Paint()..color = C.ink;
    final r = math.Random(7);
    bool finder(int x, int y) {
      for (final o in const [(0, 0), (n - 7, 0), (0, n - 7)]) {
        final dx = x - o.$1, dy = y - o.$2;
        if (dx >= -1 && dy >= -1 && dx <= 7 && dy <= 7) {
          if (dx < 0 || dy < 0 || dx > 6 || dy > 6) return false;
          return dx == 0 || dy == 0 || dx == 6 || dy == 6 || (dx >= 2 && dx <= 4 && dy >= 2 && dy <= 4);
        }
      }
      return r.nextBool();
    }

    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        if (finder(x, y)) canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x * cell, y * cell, cell * 0.92, cell * 0.92), Radius.circular(cell * 0.2)), p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
