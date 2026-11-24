import 'package:flutter/material.dart';

import '../../api.dart';
import '../../data.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';
import '../details.dart';
import '../post.dart';
import 'common.dart';

/// ===================== COLLEGE (IIT Bombay E-Cell) =====================
final _col = roles[3];
Color get _c => _col.color;
const _org = 'IIT Bombay E-Cell';
const _notes = [
  (Icons.how_to_reg_outlined, 'Design Sprint is 94% full'),
  (Icons.campaign_outlined, 'Your announcement reached 3,200 students'),
  (Icons.check_circle_outline_rounded, 'Your event listing is live on MSW'),
];

const _themes = {
  'Indigo': [Color(0xFF1B1464), Color(0xFF6C5CE7), Color(0xFF00D2D3)],
  'Sunset': [Color(0xFFFF7A59), Color(0xFFFFD166), Color(0xFFEF476F)],
  'Forest': [Color(0xFF0F3D2E), Color(0xFF2F8F7A), Color(0xFFD4F56B)],
  'Ocean': [Color(0xFF0A66C2), Color(0xFF9FD3FF), Color(0xFF00D2D3)],
};

List<EventItem> get myEvents => events.where((e) => e.organiser.contains('IIT Bombay')).toList();

/* ───────────── Home ───────────── */

class CollegeHome extends StatefulWidget {
  const CollegeHome({super.key, required this.go});
  final ValueChanged<int> go;
  @override
  State<CollegeHome> createState() => _CollegeHomeState();
}

class _CollegeHomeState extends State<CollegeHome> {
  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    final live = myEvents;
    final regs = live.fold<int>(0, (a, e) => a + e.registered);
    final mine = announcements.where((a) => a.organiser == _org).toList();
    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 110),
      children: [
        DashHeader(role: _col, a: 'Your campus, ', b: 'on the map.', sub: '$_org · verified organiser', notes: _notes),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: QuickAction(
                Icons.add_rounded,
                'Host an\nevent',
                color: _c,
                onTap: () async {
                  await Navigator.of(context).push(fadeRoute(const HostEventScreen()));
                  setState(() {});
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: QuickAction(
                Icons.campaign_outlined,
                'Post an\nannouncement',
                color: C.tealD,
                onTap: () async {
                  await announceSheet(context);
                  setState(() {});
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.25,
          children: [
            StatTile(label: 'Live events', value: live.length.toDouble(), accent: _c, delta: 'On MSW now', icon: Icons.event_outlined),
            StatTile(label: 'Registrations', value: regs.toDouble(), accent: _c, delta: 'Across your events', icon: Icons.how_to_reg_outlined),
            StatTile(label: 'Announcements', value: mine.length.toDouble(), accent: _c, delta: 'Published', icon: Icons.campaign_outlined),
            StatTile(label: 'Reach', value: 12400, accent: _c, delta: 'Students on MSW', icon: Icons.visibility_outlined),
          ],
        ),
        if (live.isNotEmpty) ...[
          SectionTitle('Your', b: 'events', action: 'All', onAction: () => widget.go(1)),
          for (final e in live.take(2))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _EventPoster(e: e, h: 170),
            ),
        ],
        if (mine.isNotEmpty) ...[
          SectionTitle('Latest', b: 'announcements', action: 'All', onAction: () => widget.go(2)),
          for (final a in mine.take(2))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AnnouncementCard(a: a),
            ),
        ],
      ],
    );
  }
}

class _EventPoster extends StatelessWidget {
  const _EventPoster({required this.e, this.h = 190});
  final EventItem e;
  final double h;
  @override
  Widget build(BuildContext context) => Pressable(
    scale: 0.98,
    onTap: () => Navigator.of(context).push(fadeRoute(EventDetailScreen(e: e))),
    child: Container(
      height: h,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Blobs(base: e.base, colors: e.blobs),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Tag(e.type, bg: Colors.white, fg: C.black),
                    const Spacer(),
                    Text(
                      '${fmtNum(e.registered)} / ${fmtNum(e.seats)}',
                      style: sans(12, color: Colors.white, weight: FontWeight.w600),
                    ),
                  ],
                ),
                const Spacer(),
                Text('${e.dates} · ${e.mode}'.toUpperCase(), style: mono(10, color: Colors.white70)),
                Text(
                  e.title,
                  style: serif(34, color: Colors.white, height: 1.0),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (e.prizePool.isNotEmpty)
                  Text(
                    '${e.prizePool} prize pool',
                    style: sans(13, color: Colors.white, weight: FontWeight.w600),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/* ───────────── Events ───────────── */

class CollegeEvents extends StatefulWidget {
  const CollegeEvents({super.key});
  @override
  State<CollegeEvents> createState() => _CollegeEventsState();
}

class _CollegeEventsState extends State<CollegeEvents> {
  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    final list = myEvents;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 110),
      children: [
        DashHeader(role: _col, a: 'Hackathons ', b: '& events.', sub: '${list.length} listed on MSW', notes: _notes),
        const SizedBox(height: 16),
        PrimaryButton(
          'Host a hackathon or event',
          bg: _c,
          onTap: () async {
            await Navigator.of(context).push(fadeRoute(const HostEventScreen()));
            setState(() {});
          },
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < list.length; i++)
          Reveal(
            delay: i * 80,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  _EventPoster(e: list[i], h: 170),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${fmtNum(list[i].registered)} / ${fmtNum(list[i].seats)} registered · closes ${list[i].regDeadline}', style: sans(12, weight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(value: list[i].registered / list[i].seats, minHeight: 7, backgroundColor: C.bg2, valueColor: AlwaysStoppedAnimation(_c)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      PrimaryButton(
                        'Share',
                        bg: C.bg2,
                        fg: C.ink,
                        icon: false,
                        height: 42,
                        onTap: () => showShareSheet(context, list[i].title, 'https://msw.community/e/${list[i].title.hashCode.abs()}'),
                      ).sized(96),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Detailed hackathon / event form. Everything here shows up on the student's event page.
class HostEventScreen extends StatefulWidget {
  const HostEventScreen({super.key});
  @override
  State<HostEventScreen> createState() => _HostEventScreenState();
}

class _HostEventScreenState extends State<HostEventScreen> {
  String type = 'Hackathon', mode = 'In person', theme = 'Indigo', team = '1 – 4 members';
  final title = TextEditingController(text: 'Build for Bharat');
  final tagline = TextEditingController(text: '36 hours to fix something real.');
  final about = TextEditingController(text: 'Teams build products for problems faced by small businesses in India. Mentors from Lumen Labs and Kite AI.');
  final venue = TextEditingController(text: 'VMCC, IIT Bombay, Mumbai');
  final dates = TextEditingController(text: 'Mar 08 – 09, 2027');
  final deadline = TextEditingController(text: 'Mar 01, 2027');
  final prizePool = TextEditingController(text: '₹2,00,000');
  double seats = 400;
  final prizes = ['Winner — ₹1,00,000', 'Runner-up — ₹60,000', 'Best design — ₹40,000'];
  final tracks = ['FinTech', 'Commerce', 'Open innovation'];
  final timeline = ['Registrations close — Mar 01', 'Hacking starts — Mar 08 · 10 AM', 'Final demos — Mar 09 · 4 PM'];
  final eligibility = ['Open to all college students', 'Inter-college teams allowed'];
  final perks = ['Certificates for all', 'Internship interviews for finalists'];

  void _r() => setState(() {});

  void _publish() {
    final t = _themes[theme]!;
    (String, String) split(String s) {
      final i = s.indexOf('—');
      return i < 0 ? (s, '') : (s.substring(0, i).trim(), s.substring(i + 1).trim());
    }

    final ev = EventItem(
      title: title.text,
      tagline: tagline.text,
      type: type,
      organiser: _org,
      mode: mode,
      venue: venue.text,
      dates: dates.text,
      regDeadline: deadline.text,
      base: t[0],
      blobs: [t[1], t[2], Colors.white],
      secondsLeft: 1200000,
      about: about.text,
      prizePool: type == 'Hackathon' ? prizePool.text : '',
      prizes: type == 'Hackathon' ? prizes.map(split).toList() : const [],
      teamSize: team,
      eligibility: List.of(eligibility),
      tracks: type == 'Hackathon' ? List.of(tracks) : const [],
      timeline: timeline.map(split).toList(),
      perks: List.of(perks),
      seats: seats.round(),
    );
    events.insert(0, ev);
    Api.createEvent(ev);
    Navigator.of(context).pop();
    toast(context, 'Published. Students can register now.');
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    final t = _themes[theme]!;
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, pad.top + 8, 16, 8),
            child: Row(
              children: [
                const BackBtn(),
                const SizedBox(width: 12),
                Text('Host an event', style: serif(28)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              children: [
                Text('LIVE POSTER — HOW STUDENTS SEE IT', style: mono(9.5)),
                const SizedBox(height: 8),
                _EventPoster(
                  e: EventItem(
                    title: title.text,
                    tagline: tagline.text,
                    type: type,
                    organiser: _org,
                    mode: mode,
                    venue: venue.text,
                    dates: dates.text,
                    regDeadline: deadline.text,
                    base: t[0],
                    blobs: [t[1], t[2], Colors.white],
                    secondsLeft: 0,
                    about: '',
                    prizePool: type == 'Hackathon' ? prizePool.text : '',
                    seats: seats.round(),
                  ),
                ),
                const SizedBox(height: 16),
                FormSection(
                  1,
                  'Basics',
                  children: [
                    PillSelect(label: 'Type', options: const ['Hackathon', 'Workshop', 'Meetup', 'Webinar', 'Competition'], value: type, onChanged: (v) => setState(() => type = v)),
                    TextField(
                      controller: title,
                      onChanged: (_) => _r(),
                      decoration: fieldDec('Event name', icon: Icons.title_rounded),
                    ),
                    TextField(controller: tagline, onChanged: (_) => _r(), decoration: fieldDec('One-line tagline')),
                    TextField(controller: about, maxLines: 4, decoration: fieldDec('About the event')),
                    Text('POSTER THEME', style: mono(9.5)),
                    Row(
                      children: [
                        for (final th in _themes.keys)
                          GestureDetector(
                            onTap: () => setState(() => theme = th),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(right: 10),
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(colors: [_themes[th]![0], _themes[th]![1]]),
                                border: Border.all(color: theme == th ? C.ink : Colors.transparent, width: 3),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                FormSection(
                  2,
                  'When & where',
                  children: [
                    PillSelect(label: 'Mode', options: const ['In person', 'Online', 'Hybrid'], value: mode, onChanged: (v) => setState(() => mode = v)),
                    TextField(
                      controller: venue,
                      onChanged: (_) => _r(),
                      decoration: fieldDec(mode == 'Online' ? 'Platform / link' : 'Venue', icon: Icons.place_outlined),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(controller: dates, onChanged: (_) => _r(), decoration: fieldDec('Dates')),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(controller: deadline, onChanged: (_) => _r(), decoration: fieldDec('Register by')),
                        ),
                      ],
                    ),
                    Text('Seats · ${seats.round()}', style: sans(14, weight: FontWeight.w600)),
                    Slider(value: seats, min: 20, max: 3000, divisions: 149, activeColor: _c, onChanged: (v) => setState(() => seats = v)),
                    PillSelect(label: 'Team size', options: const ['Individual', '1 – 2 members', '1 – 4 members', '2 – 5 members'], value: team, onChanged: (v) => setState(() => team = v)),
                  ],
                ),
                if (type == 'Hackathon')
                  FormSection(
                    3,
                    'Prizes & tracks',
                    children: [
                      TextField(
                        controller: prizePool,
                        onChanged: (_) => _r(),
                        decoration: fieldDec('Total prize pool', icon: Icons.emoji_events_outlined),
                      ),
                      Text('PRIZE BREAKDOWN  (use “Name — Amount”)', style: mono(9.5)),
                      ChipsEditor(items: prizes, hint: 'e.g. Best AI hack — ₹20,000', numbered: true),
                      Text('TRACKS / THEMES', style: mono(9.5)),
                      ChipsEditor(items: tracks, hint: 'Add a track'),
                    ],
                  ),
                FormSection(
                  type == 'Hackathon' ? 4 : 3,
                  'Timeline',
                  children: [
                    Text('Use “Step — Date”', style: sans(12, color: C.muted)),
                    ChipsEditor(items: timeline, hint: 'e.g. Results — Mar 12', numbered: true),
                  ],
                ),
                FormSection(
                  type == 'Hackathon' ? 5 : 4,
                  'Who can join & perks',
                  children: [
                    Text('ELIGIBILITY', style: mono(9.5)),
                    ChipsEditor(items: eligibility, hint: 'Add a rule', numbered: true),
                    Text('PERKS', style: mono(9.5)),
                    ChipsEditor(items: perks, hint: 'Certificates, swag, interviews…'),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, pad.bottom + 12),
            decoration: BoxDecoration(
              color: C.paper,
              border: Border(top: BorderSide(color: C.line)),
            ),
            child: PrimaryButton('Publish event', bg: _c, onTap: _publish),
          ),
        ],
      ),
    );
  }
}

/* ───────────── Announcements ───────────── */

class CollegeAnnouncements extends StatefulWidget {
  const CollegeAnnouncements({super.key});
  @override
  State<CollegeAnnouncements> createState() => _CollegeAnnouncementsState();
}

class _CollegeAnnouncementsState extends State<CollegeAnnouncements> {
  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    final mine = announcements.where((a) => a.organiser == _org).toList();
    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 110),
      children: [
        DashHeader(role: _col, a: 'Your ', b: 'announcements.', sub: 'Shown to every student on MSW', notes: _notes),
        const SizedBox(height: 16),
        PrimaryButton(
          'New announcement',
          bg: _c,
          onTap: () async {
            await announceSheet(context);
            setState(() {});
          },
        ),
        const SizedBox(height: 14),
        if (mine.isEmpty)
          Padding(
            padding: const EdgeInsets.all(30),
            child: Center(
              child: Text('No announcements yet', style: sans(14, color: C.muted)),
            ),
          ),
        for (var i = 0; i < mine.length; i++)
          Reveal(
            delay: i * 70,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AnnouncementCard(
                a: mine[i],
                onDelete: () {
                  setState(() => announcements.remove(mine[i]));
                  Api.deleteAnnouncement(mine[i]);
                  toast(context, 'Announcement removed');
                },
              ),
            ),
          ),
      ],
    );
  }
}

Future<void> announceSheet(BuildContext context) {
  final title = TextEditingController(), body = TextEditingController(), link = TextEditingController();
  var cat = 'General';
  var pinned = false;
  return sheet(
    context,
    StatefulBuilder(
      builder: (ctx, setS) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Headline('New ', 'announcement.', size: 32, italicColor: _c),
          const SizedBox(height: 14),
          TextField(
            controller: title,
            decoration: fieldDec('Headline', icon: Icons.campaign_outlined),
          ),
          const SizedBox(height: 10),
          TextField(controller: body, maxLines: 4, decoration: fieldDec('Details')),
          const SizedBox(height: 10),
          TextField(
            controller: link,
            decoration: fieldDec('Link (optional)', icon: Icons.link_rounded),
          ),
          const SizedBox(height: 12),
          PillSelect(label: 'Category', options: const ['General', 'Event', 'Deadline', 'Opportunity', 'Result'], value: cat, onChanged: (v) => setS(() => cat = v)),
          const SizedBox(height: 8),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: pinned,
            activeTrackColor: _c,
            onChanged: (v) => setS(() => pinned = v),
            title: Text('Pin to top', style: sans(14, weight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            'Publish',
            bg: _c,
            onTap: () {
              if (title.text.trim().isEmpty) return;
              final a = Announcement(title: title.text.trim(), body: body.text.trim(), organiser: _org, time: 'now', category: cat, link: link.text.trim(), pinned: pinned);
              announcements.insert(0, a);
              Api.createAnnouncement(a);
              Navigator.of(ctx).pop();
              toast(context, 'Announcement published to students');
            },
          ),
        ],
      ),
    ),
  );
}

/// Announcement card (used by colleges and on the student Events tab).
class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({super.key, required this.a, this.onDelete});
  final Announcement a;
  final VoidCallback? onDelete;
  @override
  Widget build(BuildContext context) {
    final ic = switch (a.category) {
      'Event' => Icons.event_outlined,
      'Deadline' => Icons.timer_outlined,
      'Opportunity' => Icons.work_outline_rounded,
      'Result' => Icons.emoji_events_outlined,
      _ => Icons.campaign_outlined,
    };
    return Card2(
      color: C.card,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: const Color(0xFF0A66C2).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(13)),
            child: Icon(ic, color: const Color(0xFF0A66C2), size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (a.pinned) ...[Icon(Icons.push_pin_rounded, size: 14, color: C.muted), const SizedBox(width: 4)],
                    Expanded(
                      child: Text(
                        '${a.organiser} · ${a.time}',
                        style: sans(11, color: C.muted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Tag(a.category),
                  ],
                ),
                const SizedBox(height: 6),
                Text(a.title, style: sans(15, weight: FontWeight.w700, height: 1.25)),
                if (a.body.isNotEmpty) ...[const SizedBox(height: 4), Text(a.body, style: sans(13, color: C.ink2, height: 1.45))],
                if (a.link.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.link_rounded, size: 14, color: C.tealD),
                      const SizedBox(width: 4),
                      Text(
                        a.link,
                        style: sans(12, color: C.tealD, weight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
                if (onDelete != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onDelete,
                      child: Text(
                        'Remove',
                        style: sans(12, color: const Color(0xFFE5484D), weight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CollegeAccount extends StatelessWidget {
  const CollegeAccount({super.key});
  @override
  Widget build(BuildContext context) => AccountTab(role: _col, name: _org, sub: 'Organiser · Prof. Mehta', initials: 'IB');
}
