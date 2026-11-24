import 'dart:async';

import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';
import '../widgets/ui.dart';
import 'pitch.dart';

/// Explore: Hackathons · Jobs · Tasks · Ideas with a sliding segmented control.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _seg = 0;
  static const _segs = ['Hackathons', 'Events', 'Jobs', 'Internships', 'Tasks', 'Ideas'];
  final _done = <String>{};
  late final Timer _timer;
  int _tick = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _tick++));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _toggle(String id, String msg) {
    setState(() => _done.contains(id) ? _done.remove(id) : _done.add(id));
    if (_done.contains(id)) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Label('Opportunities'),
              const SizedBox(height: 8),
              const Reveal(child: Headline('Explore ', 'the community.', size: 42)),
              const SizedBox(height: 16),
              _segmented(),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (c, a) => FadeTransition(
              opacity: a,
              child: SlideTransition(
                position: Tween(begin: const Offset(0.04, 0), end: Offset.zero).animate(a),
                child: c,
              ),
            ),
            child: KeyedSubtree(key: ValueKey(_seg), child: _list(pad.bottom)),
          ),
        ),
      ],
    );
  }

  Widget _segmented() => SizedBox(
    height: 42,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      itemCount: _segs.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final on = i == _seg;
        return Pressable(
          onTap: () => setState(() => _seg = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: on ? C.ink : C.bg2, borderRadius: BorderRadius.circular(99)),
            child: Text(
              _segs[i],
              style: sans(13, weight: FontWeight.w600, color: on ? C.onInk : C.muted),
            ),
          ),
        );
      },
    ),
  );

  Widget _listOf(double bottom, List<Widget> items, {Widget? header, double gap = 12}) => ListView(
    padding: EdgeInsets.fromLTRB(20, 4, 20, bottom + 110),
    children: [
      if (header != null) ...[Reveal(child: header), SizedBox(height: gap + 2)],
      for (var i = 0; i < items.length; i++)
        Padding(
          padding: EdgeInsets.only(bottom: gap),
          child: Reveal(delay: 60 + i * 70, child: items[i]),
        ),
    ],
  );

  Widget _list(double bottom) {
    switch (_seg) {
      case 0:
        return _listOf(bottom, [for (final h in hackathons) _hackCard(h)], gap: 14);
      case 1:
        return _listOf(bottom, [
          for (final e in events) _eventTile(e),
        ], header: _banner('Host something?', 'Post an event.', 'Workshops, meetups, club hackathons — MSW lists them for everyone.', C.lime, C.ink, Icons.add_rounded, _postEvent));
      case 2:
        return _listOf(bottom, [for (final j in jobs.where((j) => !j.intern)) _jobTile(j)], gap: 10);
      case 3:
        return _listOf(bottom, [for (final j in jobs.where((j) => j.intern)) _jobTile(j)], gap: 10);
      case 4:
        return _listOf(bottom, [for (final t in tasks) _taskCard(t)], header: _myTasks());
      default:
        return _listOf(
          bottom,
          [for (final i in ideas) _ideaCard(i)],
          header: _banner(
            'Got a startup idea?',
            'Pitch it.',
            'Get it validated, find a mentor, and reach investors.',
            C.lilac,
            C.ink,
            Icons.lightbulb_rounded,
            () => Navigator.of(context).push(fadeRoute(const PitchScreen())),
          ),
        );
    }
  }

  Widget _banner(String a, String b, String sub, Color bg, Color fg, IconData ic, VoidCallback onTap) => Pressable(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Headline(a, ' $b', size: 28, color: fg),
                const SizedBox(height: 6),
                Text(sub, style: sans(13, color: fg.withValues(alpha: 0.7))),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: C.ink, shape: BoxShape.circle),
            child: Icon(ic, color: C.lime),
          ),
        ],
      ),
    ),
  );

  Widget _eventTile(EventItem e) => Card2(
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        Container(
          width: 58,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: e.color, borderRadius: BorderRadius.circular(16)),
          child: Text(
            e.when.split(' · ').first.replaceAll(' ', '\n'),
            textAlign: TextAlign.center,
            style: sans(13, color: Colors.white, weight: FontWeight.w700, height: 1.15),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Tag(e.type),
                  if (e.mine) ...[const SizedBox(width: 6), const Tag('In review', bg: C.lime)],
                ],
              ),
              const SizedBox(height: 6),
              Text(e.name, style: serif(24, height: 1.05)),
              Text('${e.when} · ${e.where}\nby ${e.host}', style: sans(12, color: C.muted, height: 1.4)),
            ],
          ),
        ),
        Pressable(
          onTap: () => _toggle(e.name, 'You’re going to ${e.name} 📅'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: _done.contains(e.name) ? C.tealD : C.ink, borderRadius: BorderRadius.circular(99)),
            child: Text(
              _done.contains(e.name) ? 'Going ✓' : 'RSVP',
              style: sans(12, color: Colors.white, weight: FontWeight.w600),
            ),
          ),
        ),
      ],
    ),
  );

  void _postEvent() {
    final name = TextEditingController(text: 'Flutter Study Jam'), when = TextEditingController(text: 'Dec 18 · 6 PM'), where = TextEditingController(text: 'Online');
    var type = 'Workshop';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          InputDecoration dec(String l) => InputDecoration(
            labelText: l,
            filled: true,
            fillColor: C.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: C.line2),
            ),
          );
          return Container(
            padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(ctx).viewInsets.bottom + MediaQuery.of(ctx).padding.bottom + 20),
            decoration: BoxDecoration(
              color: C.paper,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Headline('Post an ', 'event.', size: 34),
                const SizedBox(height: 14),
                TextField(controller: name, decoration: dec('Event name')),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final t in const ['Workshop', 'Meetup', 'Hackathon', 'Webinar'])
                      ChoiceChip(label: Text(t), selected: type == t, onSelected: (_) => setS(() => type = t), selectedColor: C.lime, showCheckmark: false),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(controller: when, decoration: dec('When')),
                const SizedBox(height: 10),
                TextField(controller: where, decoration: dec('Where')),
                const SizedBox(height: 16),
                PrimaryButton(
                  'Submit for listing',
                  onTap: () {
                    setState(() => events.insert(0, EventItem(name.text, type, when.text, where.text, 'You', C.ink, mine: true)));
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sent to MSW admins for approval 📅')));
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _myTasks() => Row(
    children: [
      Expanded(
        child: Container(
          height: 128,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: C.dark, borderRadius: BorderRadius.circular(22)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MY TASKS', style: mono(10, color: C.teal)),
              const Spacer(),
              Text('2 active', style: serif(30, color: C.onDark)),
              Text('₹7,400 earned', style: sans(12, color: Colors.white54)),
            ],
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Pressable(
          onTap: _contribute,
          child: Container(
            height: 128,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: C.lime, borderRadius: BorderRadius.circular(22)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('CONTRIBUTE', style: mono(10, color: C.black)),
                    const Spacer(),
                    const Icon(Icons.north_east_rounded, size: 18),
                  ],
                ),
                const Spacer(),
                Text('Help MSW', style: serif(30, color: C.black)),
                Text('Earn credits', style: sans(12, color: C.black)),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  void _contribute() => showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => Container(
        padding: EdgeInsets.fromLTRB(20, 18, 20, MediaQuery.of(ctx).padding.bottom + 20),
        decoration: BoxDecoration(
          color: C.paper,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Headline('Contribute ', 'to MSW.', size: 34),
            const SizedBox(height: 4),
            Text('Admins allocate these to you — finish them for credits.', style: sans(13, color: C.muted)),
            const SizedBox(height: 12),
            for (final c in contributions)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card2(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Text(c.$1, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.$2, style: sans(14, weight: FontWeight.w600, height: 1.2)),
                            Text('+${c.$3} credits', style: sans(12, color: C.tealD)),
                          ],
                        ),
                      ),
                      Pressable(
                        onTap: () {
                          setS(() => _done.add(c.$2));
                          setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: _done.contains(c.$2) ? C.tealD : C.ink, borderRadius: BorderRadius.circular(99)),
                          child: Text(
                            _done.contains(c.$2) ? 'Sent ✓' : 'I’m in',
                            style: sans(12, color: Colors.white, weight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );

  String _countdown(int secs) {
    final s = (secs - _tick).clamp(0, 1 << 31);
    final d = s ~/ 86400, h = (s % 86400) ~/ 3600, m = (s % 3600) ~/ 60, ss = s % 60;
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d}d ${two(h)}h ${two(m)}m ${two(ss)}s';
  }

  Widget _hackCard(Hackathon h) {
    final reg = _done.contains(h.name);
    return Pressable(
      scale: 0.98,
      child: Container(
        height: 300,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(26)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: Blobs(base: h.base, colors: h.blobs),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)], stops: const [0.35, 0.85]),
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(10)),
                child: Text(_countdown(h.secondsLeft), style: mono(11, color: Colors.white)),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${h.date} · ${h.where}'.toUpperCase(), style: mono(11, color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text(h.name, style: serif(44, color: Colors.white)),
                  Text(h.tagline, style: sans(14, color: Colors.white70)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            h.prize,
                            style: sans(16, color: Colors.white, weight: FontWeight.w700, height: 1.2),
                          ),
                          Text(h.team, style: sans(12, color: Colors.white60)),
                        ],
                      ),
                      const Spacer(),
                      Pressable(
                        onTap: () => _toggle(h.name, 'Registered for ${h.name} 🎉'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.easeOutBack,
                          padding: EdgeInsets.symmetric(horizontal: reg ? 16 : 20, vertical: 12),
                          decoration: BoxDecoration(color: reg ? C.lime : Colors.white, borderRadius: BorderRadius.circular(99)),
                          child: Text(
                            reg ? 'Registered ✓' : 'Register',
                            style: sans(14, color: C.black, weight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _jobTile(Job j) {
    final applied = _done.contains(j.role);
    return Card2(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: j.color, borderRadius: BorderRadius.circular(13)),
                child: Text(
                  j.logo,
                  style: sans(18, color: Colors.white, weight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(j.role, style: sans(15, weight: FontWeight.w600, height: 1.2)),
                    Text('${j.company} · ${j.meta}', style: sans(12, color: C.muted, height: 1.35)),
                  ],
                ),
              ),
              Icon(Icons.bookmark_border_rounded, color: C.muted, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final t in j.tags) Padding(padding: const EdgeInsets.only(right: 6), child: Tag(t)),
              const Spacer(),
              Text(j.pay, style: sans(14, weight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Pressable(
            onTap: () => _toggle(j.role, 'Applied to ${j.company} with your MSW ID ✓'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: applied ? C.tealD : C.ink, borderRadius: BorderRadius.circular(14)),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  applied ? 'Applied with MSW ID ✓' : 'One-tap apply',
                  key: ValueKey(applied),
                  style: sans(14, color: Colors.white, weight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskCard(TaskItem t) {
    final taken = _done.contains(t.title);
    return Card2(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Tag(t.company, bg: t.color, fg: Colors.white),
              const SizedBox(width: 8),
              Row(
                children: [
                  for (var i = 0; i < 3; i++)
                    Container(
                      margin: const EdgeInsets.only(right: 3),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: i < t.level ? C.ink : C.line2),
                    ),
                ],
              ),
              const Spacer(),
              Text('${t.days}d left', style: mono(11)),
            ],
          ),
          const SizedBox(height: 12),
          Text(t.title, style: serif(26, height: 1.05)),
          const SizedBox(height: 10),
          Wrap(spacing: 6, children: [for (final s in t.skills) Tag(s)]),
          const SizedBox(height: 14),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('REWARD', style: mono(10)),
                  Text(t.reward, style: serif(30, color: C.tealD)),
                ],
              ),
              const Spacer(),
              Pressable(
                onTap: () => _toggle(t.title, 'Task taken — the company has been notified'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutBack,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(color: taken ? C.lime : C.ink, borderRadius: BorderRadius.circular(99)),
                  child: Text(
                    taken ? 'In progress ⚡' : 'Take task',
                    style: sans(14, weight: FontWeight.w600, color: taken ? C.black : C.onInk),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ideaCard(Idea i) {
    final backed = _done.contains(i.name);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: C.dark, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Tag(i.sector, bg: Colors.white12, fg: C.onDark),
              const Spacer(),
              Text(i.stage.toUpperCase(), style: mono(10, color: Colors.white54)),
            ],
          ),
          const SizedBox(height: 14),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${i.name} — ',
                  style: serif(28, color: C.onDark),
                ),
                TextSpan(
                  text: i.pitch.toLowerCase(),
                  style: serif(28, color: C.teal, italic: true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text('BY ${i.by.toUpperCase()}', style: mono(10, color: Colors.white38)),
          const SizedBox(height: 16),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: i.raised / i.goal),
            duration: const Duration(milliseconds: 1600),
            curve: Curves.easeOutCubic,
            builder: (_, v, _) => Container(
              height: 7,
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(7)),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: v,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    gradient: const LinearGradient(colors: [C.teal, C.lime]),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '₹${i.raised}L',
                      style: sans(14, color: C.onDark, weight: FontWeight.w700),
                    ),
                    TextSpan(
                      text: ' of ₹${i.goal.toStringAsFixed(0)}L',
                      style: sans(14, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Pressable(
                onTap: () => _toggle(i.name, 'You backed ${i.name} 🚀'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: backed ? C.lime : C.onDark, borderRadius: BorderRadius.circular(99)),
                  child: Text(
                    backed ? 'Backed ✓' : 'Back idea',
                    style: sans(13, color: C.black, weight: FontWeight.w600),
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
