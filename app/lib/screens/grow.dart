import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data.dart';
import '../links.dart';
import '../theme.dart';
import '../widgets/scene.dart';
import '../widgets/ui.dart';
import 'details.dart';
import 'post.dart';

/// Grow: one screen — MSW Labs (opens the site), refer & earn, blogs.
class GrowScreen extends StatefulWidget {
  const GrowScreen({super.key});
  @override
  State<GrowScreen> createState() => _GrowScreenState();
}

class _GrowScreenState extends State<GrowScreen> {
  void _writeBlog() {
    final t = TextEditingController(), b = TextEditingController();
    var cat = 'Hackathons';
    sheet(
      context,
      StatefulBuilder(
        builder: (ctx, setS) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Headline('Write your ', 'story.', size: 34),
            const SizedBox(height: 14),
            TextField(controller: t, decoration: fieldDec('Title')),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                for (final c in const ['Hackathons', 'Careers', 'Founders', 'Learning'])
                  ChoiceChip(
                    label: Text(c),
                    selected: cat == c,
                    onSelected: (_) => setS(() => cat = c),
                    showCheckmark: false,
                    selectedColor: C.ink,
                    labelStyle: sans(13, color: cat == c ? C.onInk : C.ink),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: b,
              maxLines: 6,
              decoration: fieldDec('Your story', hint: 'Hackathon wins, internship lessons, project breakdowns…'),
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              'Publish · +150 credits',
              onTap: () {
                setState(() => blogs.insert(0, Blog(t.text.isEmpty ? 'Untitled story' : t.text, cat, (b.text.split(' ').length / 200).ceil().clamp(1, 30), const [C.teal, C.sky], author: me.name)));
                Navigator.of(ctx).pop();
                snack(context, 'Published to the app and the MSW website');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 110),
      children: [
        Row(children: [const Label('Grow'), const Spacer(), const ThemeToggle()]),
        const SizedBox(height: 8),
        const Reveal(child: Headline('Level up, ', 'every day.', size: 44)),
        const SizedBox(height: 18),
        Reveal(delay: 80, child: _labs()),
        const SizedBox(height: 14),
        Reveal(delay: 140, child: _refer()),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Blogs', style: serif(30)),
            const Spacer(),
            Pressable(
              onTap: _writeBlog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(color: C.ink, borderRadius: BorderRadius.circular(99)),
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 15, color: C.onInk),
                    const SizedBox(width: 6),
                    Text(
                      'Write',
                      style: sans(13, color: C.onInk, weight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < blogs.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Reveal(delay: 200 + i * 70, child: _blogTile(blogs[i])),
          ),
      ],
    );
  }

  Widget _labs() => Pressable(
    onTap: openMswLabs,
    child: Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: C.black, borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Logo(light: true, height: 34),
              const Spacer(),
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(color: C.lime, shape: BoxShape.circle),
                child: const Icon(Icons.north_east_rounded, color: C.black),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Text('MSW LABS', style: mono(11, color: C.lime)),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '30-Day ',
                  style: serif(36, color: Colors.white),
                ),
                TextSpan(
                  text: 'Full-Stack Challenge',
                  style: serif(36, color: C.teal, italic: true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 12 / 30),
                  duration: const Duration(milliseconds: 1600),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(value: v, minHeight: 8, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation(C.teal)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Day 12 / 30',
                style: sans(13, color: Colors.white70, weight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Opens intern.mystartupwave.com', style: sans(12, color: Colors.white38)),
        ],
      ),
    ),
  );

  Widget _refer() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: C.lime, borderRadius: BorderRadius.circular(26)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('REFER & EARN', style: mono(11, color: C.black)),
            const Spacer(),
            const Icon(Icons.card_giftcard_rounded, color: C.black),
          ],
        ),
        const SizedBox(height: 10),
        CountUp(to: 2450, style: serif(60, color: C.black)),
        Text('credits earned · 7 friends joined · 350 per signup', style: sans(13, color: C.black)),
        const SizedBox(height: 14),
        Pressable(
          onTap: () {
            Clipboard.setData(const ClipboardData(text: 'https://msw.community/r/aanya'));
            snack(context, 'Invite link copied');
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                Text('MSW.COMMUNITY/R/AANYA', style: mono(11, color: C.black)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(color: C.black, borderRadius: BorderRadius.circular(9)),
                  child: Text(
                    'Copy',
                    style: sans(12, color: C.lime, weight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _blogTile(Blog b) => Card2(
    padding: const EdgeInsets.all(10),
    child: Row(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(colors: b.colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${b.cat.toUpperCase()} · ${b.mins} MIN', style: mono(10)),
              const SizedBox(height: 4),
              Text(b.title, style: serif(22, height: 1.05)),
              const SizedBox(height: 4),
              Text(b.author, style: sans(12, color: C.muted)),
            ],
          ),
        ),
      ],
    ),
  );
}
