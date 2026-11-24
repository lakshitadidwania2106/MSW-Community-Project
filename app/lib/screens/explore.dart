import 'dart:async';

import 'package:flutter/material.dart';

import '../api.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets/ui.dart';
import 'details.dart';
import 'pitch.dart';
import 'post.dart';

/// Explore: Community · Hackathons · Events · Jobs · Internships · Tasks · Ideas.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _seg = 0;
  static const _segs = ['Community', 'Events', 'Jobs', 'Internships', 'Tasks', 'Ideas'];
  String _type = 'All';
  static const _types = ['All', 'Hackathon', 'Workshop', 'Competition', 'Meetup', 'Webinar'];
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

  Future<void> _open(Widget page) async {
    await Navigator.of(context).push(fadeRoute(page));
    if (mounted) setState(() {});
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

  Widget _list(double bottom) => switch (_seg) {
    0 => _listOf(bottom, [for (final p in posts) PostCard(post: p)], header: _followRow()),
    1 => _eventsTab(bottom),
    2 => _listOf(bottom, [for (final o in opportunities.where((o) => !o.internship && o.live)) _oppTile(o)], gap: 10),
    3 => _listOf(bottom, [for (final o in opportunities.where((o) => o.internship && o.live)) _oppTile(o)], gap: 10),
    4 => _listOf(bottom, [for (final t in ctasks) _taskCard(t)], header: _myTasks()),
    _ => _listOf(bottom, [
      for (final i in ideas) _ideaCard(i),
    ], header: _banner('Got a startup idea? ', 'Pitch it.', 'Get it validated, find a mentor and reach investors.', Icons.lightbulb_outline_rounded, () => _open(const PitchScreen()))),
  };

  /// Unstop-style events: announcements, type filters, one list of everything colleges post.
  Widget _eventsTab(double bottom) {
    final list = events.where((e) => _type == 'All' || e.type == _type).toList();
    final anns = [...announcements]..sort((a, b) => (b.pinned ? 1 : 0) - (a.pinned ? 1 : 0));
    return ListView(
      padding: EdgeInsets.fromLTRB(0, 4, 0, bottom + 110),
      children: [
        if (anns.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.campaign_outlined, size: 18, color: C.ink),
                const SizedBox(width: 6),
                Text('Announcements', style: serif(24)),
                const Spacer(),
                Text('${anns.length}', style: mono(10)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 132,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: anns.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => _annSheet(anns[i]),
                child: SizedBox(width: 270, child: _annMini(anns[i])),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _types.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final on = _types[i] == _type;
              final n = _types[i] == 'All' ? events.length : events.where((e) => e.type == _types[i]).length;
              return GestureDetector(
                onTap: () => setState(() => _type = _types[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: on ? C.ink : C.card,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: on ? C.ink : C.line2),
                  ),
                  child: Text(
                    _types[i] == 'All' ? 'All · $n' : '${_types[i]}s · $n',
                    style: sans(12, weight: FontWeight.w600, color: on ? C.onInk : C.ink),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              for (var i = 0; i < list.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Reveal(delay: i * 60, child: _unstopCard(list[i])),
                ),
              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Text('Nothing here yet', style: sans(14, color: C.muted)),
                ),
              const SizedBox(height: 4),
              _banner('Running a club event? ', 'Post it.', 'Workshops, meetups and hackathons — listed for every student.', Icons.add_rounded, _postEvent),
            ],
          ),
        ),
      ],
    );
  }

  Widget _annMini(Announcement a) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: a.pinned ? C.black : C.card,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: a.pinned ? Colors.transparent : C.line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(a.pinned ? Icons.push_pin_rounded : Icons.campaign_outlined, size: 15, color: a.pinned ? C.lime : C.muted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                a.organiser,
                style: sans(11, weight: FontWeight.w600, color: a.pinned ? Colors.white70 : C.muted),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(a.time, style: sans(11, color: a.pinned ? Colors.white54 : C.muted)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          a.title,
          style: sans(15, weight: FontWeight.w700, height: 1.25, color: a.pinned ? Colors.white : C.ink),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const Spacer(),
        Text(
          a.body,
          style: sans(12, color: a.pinned ? Colors.white60 : C.muted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );

  void _annSheet(Announcement a) => sheet(
    context,
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Tag(a.category),
            const SizedBox(width: 8),
            Text('${a.organiser} · ${a.time}', style: sans(12, color: C.muted)),
          ],
        ),
        const SizedBox(height: 10),
        Text(a.title, style: serif(32, height: 1.05)),
        const SizedBox(height: 10),
        Text(a.body, style: sans(15, height: 1.55)),
        if (a.link.isNotEmpty) ...[const SizedBox(height: 14), PrimaryButton('Open link', icon: false, height: 50, onTap: () => snack(context, 'Opening ${a.link}'))],
      ],
    ),
  );

  Widget _unstopCard(EventItem e) {
    final days = (e.secondsLeft - _tick) ~/ 86400;
    final full = e.registered / e.seats;
    return Pressable(
      scale: 0.98,
      onTap: () => _open(EventDetailScreen(e: e)),
      child: Container(
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: C.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            SizedBox(
              height: 92,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Blobs(base: e.base, colors: e.blobs),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black.withValues(alpha: 0.5), Colors.transparent])),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            e.organiser.split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0]).join().toUpperCase(),
                            style: sans(15, weight: FontWeight.w800, color: C.black),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(99)),
                          child: Text(
                            e.type,
                            style: sans(11, weight: FontWeight.w700, color: C.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.title, style: sans(17, weight: FontWeight.w800, height: 1.2)),
                  const SizedBox(height: 2),
                  Text(e.organiser, style: sans(12, color: C.muted)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _meta(e.mode == 'Online' ? Icons.wifi_rounded : Icons.place_outlined, e.mode),
                      _meta(Icons.groups_outlined, e.teamSize),
                      _meta(Icons.calendar_today_outlined, e.dates.split(',').first),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (e.prizePool.isNotEmpty) ...[
                        Icon(Icons.emoji_events_outlined, size: 18, color: const Color(0xFFC6A400)),
                        const SizedBox(width: 4),
                        Text(e.prizePool, style: sans(14, weight: FontWeight.w800)),
                        const SizedBox(width: 12),
                      ],
                      Icon(Icons.people_alt_outlined, size: 16, color: C.muted),
                      const SizedBox(width: 4),
                      Text('${fmtNum(e.registered)} registered', style: sans(12, color: C.muted)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: (days <= 7 ? const Color(0xFFE5484D) : C.tealD).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(99)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule_rounded, size: 13, color: days <= 7 ? const Color(0xFFE5484D) : C.tealD),
                            const SizedBox(width: 4),
                            Text(
                              e.going ? 'Registered' : '${days < 0 ? 0 : days} days left',
                              style: sans(11, weight: FontWeight.w700, color: days <= 7 ? const Color(0xFFE5484D) : C.tealD),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: full.clamp(0, 1), minHeight: 4, backgroundColor: C.bg2, valueColor: AlwaysStoppedAnimation(full > 0.85 ? const Color(0xFFE5484D) : C.ink)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _meta(IconData ic, String t) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(ic, size: 15, color: C.muted),
      const SizedBox(width: 4),
      Text(t, style: sans(12, color: C.ink2)),
    ],
  );

  Widget _followRow() => SizedBox(
    height: 72,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        for (final p in people.values)
          Pressable(
            onTap: () => _open(PersonScreen(person: p)),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
              decoration: BoxDecoration(
                color: C.card,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: C.line),
              ),
              child: Row(
                children: [
                  GAvatar(p.initials, size: 40, colors: p.grad),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: sans(13, weight: FontWeight.w600, height: 1.2)),
                      Text(p.college, style: sans(11, color: C.muted)),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );

  Widget _banner(String a, String b, String sub, IconData ic, VoidCallback onTap) => Pressable(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: C.black, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Headline(a, b, size: 28, color: Colors.white, italicColor: C.teal),
                const SizedBox(height: 6),
                Text(sub, style: sans(13, color: Colors.white60)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(color: C.teal, shape: BoxShape.circle),
            child: Icon(ic, color: C.black),
          ),
        ],
      ),
    ),
  );

  void _postEvent() {
    final name = TextEditingController(text: 'Flutter Study Jam'),
        when = TextEditingController(text: 'Dec 18, 2026 · 6 PM'),
        where = TextEditingController(text: 'Online · Google Meet'),
        about = TextEditingController();
    var type = 'Workshop';
    sheet(
      context,
      StatefulBuilder(
        builder: (ctx, setS) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Headline('Post an ', 'event.', size: 34),
            const SizedBox(height: 14),
            TextField(
              controller: name,
              decoration: fieldDec('Event name', icon: Icons.event_outlined),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                for (final t in const ['Workshop', 'Meetup', 'Webinar', 'Hackathon'])
                  ChoiceChip(
                    label: Text(t),
                    selected: type == t,
                    onSelected: (_) => setS(() => type = t),
                    showCheckmark: false,
                    selectedColor: C.ink,
                    labelStyle: sans(13, color: type == t ? C.onInk : C.ink),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: when,
              decoration: fieldDec('Date & time', icon: Icons.calendar_today_outlined),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: where,
              decoration: fieldDec('Venue or link', icon: Icons.place_outlined),
            ),
            const SizedBox(height: 10),
            TextField(controller: about, maxLines: 3, decoration: fieldDec('What will people learn or do?')),
            const SizedBox(height: 16),
            PrimaryButton(
              'Submit for listing',
              onTap: () {
                setState(
                  () => events.add(
                    EventItem(
                      title: name.text,
                      tagline: 'Hosted by a student on MSW',
                      type: type,
                      organiser: me.name,
                      mode: where.text.toLowerCase().contains('online') ? 'Online' : 'In person',
                      venue: where.text,
                      dates: when.text,
                      regDeadline: when.text,
                      base: C.black,
                      blobs: const [C.tealD, C.lime, C.sky],
                      secondsLeft: 900000,
                      about: about.text.isEmpty ? 'Details coming soon.' : about.text,
                      mine: true,
                    ),
                  ),
                );
                Navigator.of(ctx).pop();
                Api.createEvent(events.last);
                snack(context, 'Sent to MSW for listing');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _oppTile(Opportunity o) => Pressable(
    scale: 0.98,
    onTap: () => _open(OpportunityDetailScreen(o: o)),
    child: Card2(
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
                decoration: BoxDecoration(color: o.color, borderRadius: BorderRadius.circular(13)),
                child: Text(
                  o.company[0],
                  style: sans(18, color: Colors.white, weight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.title, style: sans(15, weight: FontWeight.w600, height: 1.2)),
                    Text('${o.company} · ${o.workMode} · ${o.location}', style: sans(12, color: C.muted, height: 1.35)),
                  ],
                ),
              ),
              Icon(o.saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: C.muted, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 6, runSpacing: 6, children: [for (final s in o.skills.take(3)) Tag(s)]),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.payments_outlined, size: 16, color: C.muted),
              const SizedBox(width: 6),
              Text(o.pay, style: sans(13, weight: FontWeight.w700)),
              const SizedBox(width: 14),
              Icon(Icons.event_busy_outlined, size: 16, color: C.muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Apply by ${o.applyBy}',
                  style: sans(12, color: C.muted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (o.applied) Tag('Applied', bg: C.teal),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _taskCard(CTask t) => Pressable(
    scale: 0.98,
    onTap: () => _open(TaskDetailScreen(t: t)),
    child: Card2(
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
              if (t.myStatus != 'Open') Tag(t.myStatus, bg: t.myStatus == 'Submitted' ? C.peach : C.teal) else Text('${t.days}d left', style: mono(11)),
            ],
          ),
          const SizedBox(height: 12),
          Text(t.title, style: serif(26, height: 1.05)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.code_rounded, size: 15, color: C.muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(t.repo, style: mono(10), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(spacing: 6, children: [for (final s in t.stack) Tag(s)]),
          const SizedBox(height: 14),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('REWARD', style: mono(10)),
                  Text('₹${fmtNum(t.reward)}', style: serif(30, color: C.tealD)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(color: C.ink, borderRadius: BorderRadius.circular(99)),
                child: Text(
                  'View task',
                  style: sans(14, weight: FontWeight.w600, color: C.onInk),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _myTasks() {
    final active = ctasks.where((t) => t.myStatus == 'In progress' || t.myStatus == 'Submitted').length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: C.black, borderRadius: BorderRadius.circular(22)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MY TASKS', style: mono(10, color: C.teal)),
                const SizedBox(height: 4),
                Text('$active active', style: serif(30, color: Colors.white)),
                Text('₹7,400 earned this semester', style: sans(12, color: Colors.white54)),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(color: C.lime, shape: BoxShape.circle),
            child: const Icon(Icons.task_alt_rounded, color: C.black),
          ),
        ],
      ),
    );
  }

  Widget _ideaCard(Idea i) => Pressable(
    scale: 0.98,
    onTap: () => _open(IdeaDetailScreen(idea: i)),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: C.dark, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: i.color, borderRadius: BorderRadius.circular(12)),
                child: Icon(i.icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
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
                  style: serif(26, color: C.onDark),
                ),
                TextSpan(
                  text: i.pitch.toLowerCase(),
                  style: serif(26, color: C.teal, italic: true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text('BY ${i.founders.map((f) => f.name).join(' & ').toUpperCase()}', style: mono(9, color: Colors.white38)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(value: i.raised / i.ask, minHeight: 6, backgroundColor: Colors.white10, valueColor: const AlwaysStoppedAnimation(C.lime)),
          ),
          const SizedBox(height: 10),
          Text('₹${i.raised.toStringAsFixed(1)}L of ₹${i.ask.toStringAsFixed(0)}L · ${i.equity.toStringAsFixed(0)}% equity', style: sans(13, color: Colors.white70)),
        ],
      ),
    ),
  );
}
