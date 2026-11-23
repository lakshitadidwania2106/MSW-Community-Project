import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data.dart';
import '../theme.dart';
import '../widgets/ui.dart';
import '../links.dart';
import 'courses.dart';
import 'games.dart';
import 'pitch.dart';
import 'plans.dart';
import 'quiz.dart';
import 'resume.dart';

/// Grow: MSW Labs progress, quizzes & IQ tests, badges, GitHub analyser,
/// refer & earn credits, and blogs.
class GrowScreen extends StatelessWidget {
  const GrowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 110),
      children: [
        const Label('Grow'),
        const SizedBox(height: 8),
        const Reveal(child: Headline('Level up, ', 'every day.', size: 42)),
        const SizedBox(height: 18),
        const Reveal(delay: 80, child: _LabsCard()),
        const SizedBox(height: 14),
        Reveal(delay: 110, child: _toolkit(context)),
        const SizedBox(height: 22),
        _sectionTitle('Tests & quizzes', 'Shows up on your ID'),
        const SizedBox(height: 12),
        Reveal(delay: 140, child: _quizGrid(context)),
        const SizedBox(height: 22),
        _sectionTitle('Badges', '4 of 6 earned'),
        const SizedBox(height: 12),
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: badges.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => Reveal(delay: 200 + i * 60, offset: 14, child: _Badge(badges[i])),
          ),
        ),
        const SizedBox(height: 22),
        const Reveal(delay: 120, child: _GitCard()),
        const SizedBox(height: 14),
        const Reveal(delay: 160, child: _ReferCard()),
        const SizedBox(height: 22),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('Blogs', style: serif(28)),
          const Spacer(),
          Pressable(onTap: () => _writeBlog(context), child: const Tag('✍️  Write a blog', bg: C.ink, fg: Colors.white)),
        ]),
        const SizedBox(height: 12),
        for (var i = 0; i < blogs.length; i++) Padding(padding: const EdgeInsets.only(bottom: 10), child: Reveal(delay: 200 + i * 70, child: _blogTile(blogs[i]))),
      ],
    );
  }

  Widget _toolkit(BuildContext context) {
    final items = [
      ('Courses', 'Day 1–30', Icons.school_rounded, C.sky, const CoursesScreen() as Widget),
      ('Games', 'Earn credits', Icons.sports_esports_rounded, C.peach, const GamesScreen() as Widget),
      ('Resume', 'Auto-built', Icons.description_rounded, C.paper, const ResumeScreen() as Widget),
      ('Ideas', 'Pitch & fund', Icons.lightbulb_rounded, C.lilac, const PitchScreen() as Widget),
      ('Go Pro', '₹99 · ₹299', Icons.workspace_premium_rounded, C.lime, const PlansScreen() as Widget),
      ('MSW Labs', 'Open site ↗', Icons.open_in_new_rounded, C.ink, null),
    ];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.05,
      children: [
        for (final it in items)
          Pressable(
            onTap: () => it.$5 == null ? openMswLabs() : Navigator.of(context).push(fadeRoute(it.$5!)),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: it.$4, borderRadius: BorderRadius.circular(20), border: it.$4 == C.paper ? Border.all(color: C.line) : null),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(it.$3, size: 22, color: it.$4 == C.ink ? C.lime : C.ink),
                const Spacer(),
                Text(it.$1, style: serif(22, color: it.$4 == C.ink ? Colors.white : C.ink)),
                Text(it.$2, style: sans(11, color: it.$4 == C.ink ? Colors.white60 : C.ink2)),
              ]),
            ),
          ),
      ],
    );
  }

  void _writeBlog(BuildContext context) {
    final t = TextEditingController(), b = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(20, 18, 20, MediaQuery.of(ctx).viewInsets.bottom + MediaQuery.of(ctx).padding.bottom + 20),
        decoration: const BoxDecoration(color: C.paper, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Headline('Write your ', 'story.', size: 34),
          const SizedBox(height: 14),
          TextField(controller: t, decoration: InputDecoration(labelText: 'Title', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
          const SizedBox(height: 10),
          TextField(controller: b, maxLines: 6, decoration: InputDecoration(hintText: 'Hackathon wins, internship lessons, project breakdowns…', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
          const SizedBox(height: 14),
          PrimaryButton('Publish · +150 credits', onTap: () {
            Navigator.of(ctx).pop();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Blog published to the app and website ✍️')));
          }),
        ]),
      ),
    );
  }

  Widget _sectionTitle(String a, String b) => Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(a, style: serif(28)),
        const Spacer(),
        Text(b, style: sans(13, color: C.muted)),
      ]);

  Widget _quizGrid(BuildContext context) {
    const items = [
      ('IQ test', '5 Qs · 3 min', Icons.psychology_rounded, C.lilac),
      ('Reasoning', '10 Qs · 6 min', Icons.extension_rounded, C.peach),
      ('Daily quiz', 'New every day', Icons.bolt_rounded, C.sky),
      ('Aptitude', '15 Qs · 10 min', Icons.calculate_rounded, C.lime),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.25,
      children: [
        for (final it in items)
          Pressable(
            onTap: () => Navigator.of(context).push(fadeRoute(QuizScreen(title: it.$1))),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: it.$4, borderRadius: BorderRadius.circular(22)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 38, height: 38, decoration: BoxDecoration(color: C.ink, borderRadius: BorderRadius.circular(12)), child: Icon(it.$3, color: Colors.white, size: 20)),
                  const Spacer(),
                  const Icon(Icons.north_east_rounded, size: 18),
                ]),
                const Spacer(),
                Text(it.$1, style: serif(26)),
                Text(it.$2, style: sans(12, color: C.ink2)),
              ]),
            ),
          ),
      ],
    );
  }

  Widget _blogTile(Blog b) => Pressable(
        child: Card2(
          padding: const EdgeInsets.all(10),
          child: Row(children: [
            Container(width: 84, height: 84, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(colors: b.colors, begin: Alignment.topLeft, end: Alignment.bottomRight))),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${b.cat.toUpperCase()} · ${b.mins} MIN', style: mono(10)),
                const SizedBox(height: 4),
                Text(b.title, style: serif(22, height: 1.05)),
              ]),
            ),
          ]),
        ),
      );
}

class _LabsCard extends StatelessWidget {
  const _LabsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: C.dark, borderRadius: BorderRadius.circular(26)),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('MSW LABS', style: mono(11, color: C.lime)),
            const SizedBox(height: 8),
            Text.rich(TextSpan(children: [
              TextSpan(text: '30-Day ', style: serif(30, color: C.onDark)),
              TextSpan(text: 'Full-Stack Challenge', style: serif(30, color: C.teal, italic: true)),
            ])),
            const SizedBox(height: 14),
            Pressable(
              onTap: openMswLabs,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                decoration: BoxDecoration(color: C.lime, borderRadius: BorderRadius.circular(99)),
                child: Text('Open MSW Labs ↗', style: sans(13, weight: FontWeight.w600)),
              ),
            ),
          ]),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 104,
          height: 104,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 12 / 30),
            duration: const Duration(milliseconds: 1800),
            curve: Curves.easeOutCubic,
            builder: (_, v, _) => Stack(alignment: Alignment.center, children: [
              SizedBox.expand(child: CircularProgressIndicator(value: v, strokeWidth: 8, backgroundColor: Colors.white10, color: C.teal, strokeCap: StrokeCap.round)),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${(v * 30).round()}', style: serif(40, color: C.onDark)),
                Text('of 30 days', style: sans(11, color: Colors.white54)),
              ]),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _Badge extends StatefulWidget {
  const _Badge(this.b);
  final BadgeItem b;
  @override
  State<_Badge> createState() => _BadgeState();
}

class _BadgeState extends State<_Badge> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.b;
    return SizedBox(
      width: 78,
      child: Column(children: [
        AnimatedBuilder(
          animation: _c,
          builder: (_, child) => Container(
            width: 70,
            height: 70,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: b.earned
                  ? SweepGradient(colors: const [C.teal, C.lime, C.peach, C.lilac, C.teal], transform: GradientRotation(_c.value * math.pi * 2))
                  : null,
              color: b.earned ? null : C.bg2,
            ),
            child: child,
          ),
          child: Container(
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: b.earned ? Text(b.emoji, style: const TextStyle(fontSize: 28)) : const Icon(Icons.lock_rounded, color: C.muted, size: 22),
          ),
        ),
        const SizedBox(height: 6),
        Text(b.name, textAlign: TextAlign.center, maxLines: 2, style: sans(11, color: b.earned ? C.ink : C.muted, weight: FontWeight.w500, height: 1.2)),
      ]),
    );
  }
}

class _GitCard extends StatefulWidget {
  const _GitCard();
  @override
  State<_GitCard> createState() => _GitCardState();
}

class _GitCardState extends State<_GitCard> {
  final _r = math.Random();
  late List<int> _cells = List.generate(7 * 18, (_) => _lvl());
  late final Timer _t;

  int _lvl() {
    final x = _r.nextDouble();
    return x < 0.35 ? 0 : x < 0.6 ? 1 : x < 0.8 ? 2 : x < 0.93 ? 3 : 4;
  }

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(milliseconds: 600), (_) => setState(() {
          _cells = [..._cells];
          for (var k = 0; k < 5; k++) {
            _cells[_r.nextInt(_cells.length)] = _lvl();
          }
        }));
  }

  @override
  void dispose() {
    _t.cancel();
    super.dispose();
  }

  static const _colors = [Color(0x10FFFFFF), Color(0x4D7FD1BD), Color(0x8C7FD1BD), C.teal, C.lime];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: C.dark, borderRadius: BorderRadius.circular(26)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Tag('GitHub analyser', bg: Colors.white12, fg: C.onDark), const Spacer(), Text('@aanya-codes', style: mono(10, color: Colors.white38))]),
        const SizedBox(height: 14),
        Text.rich(TextSpan(children: [
          TextSpan(text: 'Your code, ', style: serif(32, color: C.onDark)),
          TextSpan(text: 'decoded.', style: serif(32, color: C.teal, italic: true)),
        ])),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 18,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 3,
          crossAxisSpacing: 3,
          children: [
            for (final c in _cells)
              AnimatedContainer(duration: const Duration(milliseconds: 500), decoration: BoxDecoration(color: _colors[c], borderRadius: BorderRadius.circular(2))),
          ],
        ),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CountUp(to: 87, style: serif(56, color: C.lime)),
            Text('/100 profile score', style: sans(11, color: Colors.white54)),
          ]),
          const SizedBox(width: 18),
          Expanded(
            child: Column(children: [
              for (final l in const [('TypeScript', 0.46), ('Python', 0.28), ('Go', 0.14)])
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: l.$2 / 0.46),
                    duration: const Duration(milliseconds: 1400),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, _) => Stack(children: [
                      FractionallySizedBox(widthFactor: v, child: Container(height: 24, decoration: BoxDecoration(color: C.teal.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(6)))),
                      Container(height: 24, alignment: Alignment.centerLeft, padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('${l.$1}  ${(l.$2 * 100).round()}%', style: sans(11, color: C.onDark))),
                    ]),
                  ),
                ),
            ]),
          ),
        ]),
      ]),
    );
  }
}

class _ReferCard extends StatelessWidget {
  const _ReferCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: C.lime, borderRadius: BorderRadius.circular(26)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Tag('Refer & earn', bg: Color(0x14000000)),
          const Spacer(),
          SizedBox(
            width: 92,
            height: 34,
            child: Stack(children: [
              for (var i = 0; i < 4; i++)
                Positioned(
                  left: i * 19.0,
                  child: Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(colors: [Color(0xFFFFF6B0), Color(0xFFE2B100), Color(0xFFA07C00)], center: Alignment(-0.3, -0.4)),
                      border: Border.all(color: const Color(0xFF8A6A00), width: 1.5),
                    ),
                    child: Text('₹', style: sans(14, color: const Color(0xFF7A5C00), weight: FontWeight.w700)),
                  ),
                ),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        CountUp(to: 2450, style: serif(64)),
        Text('credits earned · 7 friends joined', style: sans(13)),
        const SizedBox(height: 14),
        Pressable(
          onTap: () {
            Clipboard.setData(const ClipboardData(text: 'https://msw.community/r/aanya'));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invite link copied ✓')));
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Text('MSW.COMMUNITY/R/AANYA', style: mono(11, color: C.ink)),
              const Spacer(),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: C.ink, borderRadius: BorderRadius.circular(9)), child: Text('Copy', style: sans(12, color: C.lime, weight: FontWeight.w600))),
            ]),
          ),
        ),
      ]),
    );
  }
}
