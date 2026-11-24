import 'package:flutter/material.dart';

import '../data.dart';
import '../links.dart';
import '../theme.dart';
import '../widgets/ui.dart';

/// Courses → Full Stack Web Development → Day 1 to 30 (MSW Labs).
class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});
  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  int _done = 12;

  void _open(int d) {
    final st = d < _done
        ? 'done'
        : d == _done
        ? 'now'
        : 'lock';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(20, 18, 20, MediaQuery.of(ctx).padding.bottom + 20),
        decoration: BoxDecoration(
          color: C.paper,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DAY ${(d + 1).toString().padLeft(2, '0')} OF 30', style: mono(11, color: C.tealD)),
            const SizedBox(height: 6),
            Text(reelTopics[d], style: serif(34, height: 1.05)),
            const SizedBox(height: 14),
            for (final r in const [
              (Icons.play_circle_rounded, 'Watch the reel', '60 sec'),
              (Icons.menu_book_rounded, 'Read the lesson', '10 min'),
              (Icons.code_rounded, 'Code challenge', 'In the MSW Labs editor'),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(r.$1, color: st == 'lock' ? C.muted : C.tealD),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(r.$2, style: sans(14, weight: FontWeight.w600)),
                    ),
                    Text(r.$3, style: sans(12, color: C.muted)),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            if (st == 'now')
              PrimaryButton(
                'Mark Day ${d + 1} complete',
                onTap: () {
                  setState(() => _done++);
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Day ${d + 1} complete — +50 XP 🔥')));
                },
              ),
            if (st == 'lock') PrimaryButton('Locked — finish Day ${_done + 1} first', bg: C.muted, icon: false),
            const SizedBox(height: 10),
            PrimaryButton('Open on MSW Labs ↗', bg: C.lime, fg: C.ink, icon: false, onTap: openMswLabs),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, pad.top + 8, 20, pad.bottom + 30),
        children: [
          Row(
            children: [
              Pressable(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: C.card,
                    shape: BoxShape.circle,
                    border: Border.all(color: C.line),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, size: 18),
                ),
              ),
              const Spacer(),
              const Tag('MSW Labs', bg: C.lime),
            ],
          ),
          const SizedBox(height: 18),
          Text('COURSES', style: mono(11)),
          const SizedBox(height: 6),
          const Reveal(child: Headline('Full Stack ', 'Web Development.', size: 42)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: C.dark, borderRadius: BorderRadius.circular(24)),
            child: Row(
              children: [
                SizedBox(
                  width: 78,
                  height: 78,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: _done / 30),
                    duration: const Duration(milliseconds: 900),
                    builder: (_, v, _) => Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.expand(
                          child: CircularProgressIndicator(value: v, strokeWidth: 7, backgroundColor: Colors.white10, color: C.teal, strokeCap: StrokeCap.round),
                        ),
                        Text('$_done', style: serif(30, color: C.onDark)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$_done of 30 days done', style: serif(24, color: C.onDark)),
                      const SizedBox(height: 8),
                      Pressable(
                        onTap: openMswLabs,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(color: C.lime, borderRadius: BorderRadius.circular(99)),
                          child: Text(
                            'Open MSW Labs ↗',
                            style: sans(13, color: C.black, weight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              for (var d = 0; d < 30; d++)
                Reveal(
                  delay: d * 25,
                  offset: 10,
                  child: Pressable(
                    onTap: () => _open(d),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: d < _done ? C.ink : (d == _done ? C.lime : C.paper),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: d < _done ? C.ink : C.line),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text((d + 1).toString().padLeft(2, '0'), style: serif(24, color: d < _done ? C.onDark : (d > _done ? C.muted : C.ink))),
                          Text(d < _done ? 'DONE' : (d == _done ? 'TODAY' : '🔒'), style: mono(7, color: d < _done ? C.teal : C.muted)),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
