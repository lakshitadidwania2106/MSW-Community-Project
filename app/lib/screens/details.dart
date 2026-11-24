import 'dart:async';

import 'package:flutter/material.dart';

import '../api.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets/ui.dart';
import 'post.dart';

/* ───────────────────────────── shared pieces ───────────────────────────── */

class DSection extends StatelessWidget {
  const DSection(this.title, {super.key, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: mono(10)),
        const SizedBox(height: 10),
        child,
      ],
    ),
  );
}

class Bullets extends StatelessWidget {
  const Bullets(this.items, {super.key, this.icon = Icons.check_rounded, this.color});
  final List<String> items;
  final IconData icon;
  final Color? color;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final i in items)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 1),
                width: 20,
                height: 20,
                decoration: BoxDecoration(color: (color ?? C.tealD).withValues(alpha: 0.14), shape: BoxShape.circle),
                child: Icon(icon, size: 13, color: color ?? C.tealD),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(i, style: sans(14, height: 1.45))),
            ],
          ),
        ),
    ],
  );
}

/// Grid of key facts (icon · label · value).
class FactGrid extends StatelessWidget {
  const FactGrid(this.facts, {super.key});
  final List<(IconData, String, String)> facts;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final w = (c.maxWidth - 10) / 2;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final f in facts)
            Container(
              width: w,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: C.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: C.line),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(f.$1, size: 18, color: C.muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.$2.toUpperCase(), style: mono(8.5)),
                        const SizedBox(height: 2),
                        Text(f.$3, style: sans(13, weight: FontWeight.w600, height: 1.25)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    },
  );
}

class BottomBar extends StatelessWidget {
  const BottomBar({super.key, required this.left, required this.button});
  final Widget left, button;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
    decoration: BoxDecoration(
      color: C.paper,
      border: Border(top: BorderSide(color: C.line)),
    ),
    child: Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        SizedBox(width: 170, child: button),
      ],
    ),
  );
}

InputDecoration fieldDec(String label, {IconData? icon, String? hint}) => InputDecoration(
  labelText: label,
  hintText: hint,
  hintStyle: sans(13, color: C.muted),
  labelStyle: sans(14, color: C.muted),
  floatingLabelStyle: sans(13, color: C.ink),
  prefixIcon: icon == null ? null : Icon(icon, color: C.muted, size: 20),
  filled: true,
  fillColor: C.card,
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: C.line2),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: C.ink, width: 1.3),
  ),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
);

Future<T?> sheet<T>(BuildContext context, Widget child) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (ctx) => Container(
    constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.9),
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

/* ───────────────────────────── hackathons & events ───────────────────────────── */

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key, required this.e});
  final EventItem e;
  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late final Timer _t;
  int _tick = 0;
  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _tick++));
  }

  @override
  void dispose() {
    _t.cancel();
    super.dispose();
  }

  String _cd() {
    final s = (widget.e.secondsLeft - _tick).clamp(0, 1 << 31);
    String two(int v) => v.toString().padLeft(2, '0');
    return '${s ~/ 86400}d ${two((s % 86400) ~/ 3600)}h ${two((s % 3600) ~/ 60)}m ${two(s % 60)}s';
  }

  void _register() {
    final e = widget.e;
    final team = TextEditingController(), mates = TextEditingController();
    var track = e.tracks.isNotEmpty ? e.tracks.first : '';
    sheet(
      context,
      StatefulBuilder(
        builder: (ctx, setS) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Headline('Register for ', '${e.title}.', size: 32),
            const SizedBox(height: 6),
            Text('Your MSW ID (name, college, skills) is attached automatically.', style: sans(13, color: C.muted)),
            const SizedBox(height: 16),
            if (e.isHackathon) ...[
              TextField(
                controller: team,
                decoration: fieldDec('Team name', icon: Icons.groups_outlined),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: mates,
                decoration: fieldDec('Invite teammates (MSW usernames or emails)', icon: Icons.person_add_alt_outlined),
              ),
              const SizedBox(height: 12),
            ],
            if (e.tracks.isNotEmpty) ...[
              Text('TRACK', style: mono(10)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in e.tracks)
                    ChoiceChip(
                      label: Text(t),
                      selected: track == t,
                      onSelected: (_) => setS(() => track = t),
                      showCheckmark: false,
                      selectedColor: C.ink,
                      labelStyle: sans(13, color: track == t ? C.onInk : C.ink),
                    ),
                ],
              ),
              const SizedBox(height: 14),
            ],
            PrimaryButton(
              'Confirm registration',
              onTap: () {
                Navigator.of(ctx).pop();
                setState(() {
                  e.going = true;
                  e.registered++;
                });
                Api.register(e, team: team.text, track: track);
                snack(context, 'Registered for ${e.title}. Details sent to your email.');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.e;
    final pad = MediaQuery.of(context).padding;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: 300,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Blobs(base: e.base, colors: e.blobs),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black12, Colors.black.withValues(alpha: 0.65)]),
                          ),
                        ),
                      ),
                      Positioned(
                        top: pad.top + 8,
                        left: 16,
                        right: 16,
                        child: Row(
                          children: [
                            const BackBtn(onImage: true),
                            const Spacer(),
                            IconButton(
                              onPressed: () => showShareSheet(context, e.title, 'https://msw.community/e/${e.title.hashCode.abs()}'),
                              icon: const Icon(Icons.ios_share_rounded, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Tag(e.type, bg: Colors.white, fg: C.black),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(99)),
                                  child: Text(_cd(), style: mono(10, color: Colors.white)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(e.title, style: serif(46, color: Colors.white)),
                            Text(e.tagline, style: sans(15, color: Colors.white70)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.verified_outlined, size: 16, color: C.tealD),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text('Organised by ${e.organiser}', style: sans(13, color: C.muted)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      FactGrid([
                        (Icons.calendar_today_outlined, 'Dates', e.dates),
                        (Icons.event_busy_outlined, 'Register by', e.regDeadline),
                        (Icons.place_outlined, 'Where', e.venue),
                        (Icons.groups_outlined, 'Team size', e.teamSize),
                        if (e.prizePool.isNotEmpty) (Icons.emoji_events_outlined, 'Prize pool', e.prizePool),
                        (Icons.how_to_reg_outlined, 'Registered', '${fmtNum(e.registered)} / ${fmtNum(e.seats)}'),
                      ]),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(value: e.registered / e.seats, minHeight: 6, backgroundColor: C.bg2, valueColor: AlwaysStoppedAnimation(C.tealD)),
                      ),
                      DSection('About', child: Text(e.about, style: sans(15, height: 1.55))),
                      if (e.prizes.isNotEmpty)
                        DSection(
                          'Prizes',
                          child: Column(
                            children: [
                              for (var i = 0; i < e.prizes.length; i++)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: i == 0 ? C.black : C.card,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: i == 0 ? Colors.transparent : C.line),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(i == 0 ? Icons.emoji_events_rounded : Icons.workspace_premium_outlined, color: i == 0 ? C.lime : C.muted, size: 22),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          e.prizes[i].$1,
                                          style: sans(14, weight: FontWeight.w600, color: i == 0 ? Colors.white : C.ink),
                                        ),
                                      ),
                                      Text(
                                        e.prizes[i].$2,
                                        style: sans(14, weight: FontWeight.w700, color: i == 0 ? C.lime : C.ink),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      if (e.tracks.isNotEmpty) DSection('Tracks', child: Wrap(spacing: 8, runSpacing: 8, children: [for (final t in e.tracks) Tag(t)])),
                      if (e.timeline.isNotEmpty)
                        DSection(
                          'Timeline',
                          child: Column(
                            children: [
                              for (var i = 0; i < e.timeline.length; i++)
                                IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            margin: const EdgeInsets.only(top: 4),
                                            decoration: BoxDecoration(
                                              color: i == 0 ? C.tealD : C.card,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: C.tealD, width: 2),
                                            ),
                                          ),
                                          if (i < e.timeline.length - 1) Expanded(child: Container(width: 2, color: C.line2)),
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(e.timeline[i].$1, style: sans(14, weight: FontWeight.w600, height: 1.2)),
                                              Text(e.timeline[i].$2, style: sans(12, color: C.muted)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      if (e.eligibility.isNotEmpty) DSection('Eligibility', child: Bullets(e.eligibility)),
                      if (e.perks.isNotEmpty) DSection('Perks', child: Bullets(e.perks, icon: Icons.card_giftcard_rounded)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          BottomBar(
            left: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(e.prizePool.isNotEmpty ? e.prizePool : 'Free', style: serif(28)),
                Text(e.prizePool.isNotEmpty ? 'prize pool' : '${e.seats - e.registered} seats left', style: sans(12, color: C.muted)),
              ],
            ),
            button: PrimaryButton(e.going ? 'Registered' : 'Register', icon: !e.going, height: 52, bg: e.going ? C.tealD : null, fg: e.going ? Colors.white : null, onTap: e.going ? null : _register),
          ),
        ],
      ),
    );
  }
}

/* ───────────────────────────── jobs & internships ───────────────────────────── */

class OpportunityDetailScreen extends StatefulWidget {
  const OpportunityDetailScreen({super.key, required this.o});
  final Opportunity o;
  @override
  State<OpportunityDetailScreen> createState() => _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState extends State<OpportunityDetailScreen> {
  void _apply() {
    final o = widget.o;
    final why = TextEditingController(), link = TextEditingController(text: 'github.com/aanya-codes');
    sheet(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Headline('Apply to ', '${o.company}.', size: 32),
          Text(o.title, style: sans(14, color: C.muted)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: C.bg2, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                GAvatar(me.initials, size: 40, colors: me.grad),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MSW ID attached', style: sans(14, weight: FontWeight.w600)),
                      Text('Resume · Level ${me.level} · IQ ${me.iq} · GitHub ${me.gh}', style: sans(12, color: C.muted)),
                    ],
                  ),
                ),
                Icon(Icons.check_circle_rounded, color: C.tealD),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: link,
            decoration: fieldDec('Portfolio / GitHub', icon: Icons.link_rounded),
          ),
          const SizedBox(height: 10),
          TextField(controller: why, maxLines: 3, decoration: fieldDec('Why are you a good fit? (optional)')),
          const SizedBox(height: 16),
          PrimaryButton(
            'Submit application',
            onTap: () {
              Navigator.of(context).pop();
              setState(() {
                o.applied = true;
                o.applicants++;
              });
              Api.apply(o, link: link.text, note: why.text);
              snack(context, 'Applied to ${o.company}. Track it in your ID tab.');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.o;
    final pad = MediaQuery.of(context).padding;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20, pad.top + 8, 20, 24),
              children: [
                Row(
                  children: [
                    const BackBtn(),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        setState(() => o.saved = !o.saved);
                        snack(context, o.saved ? 'Saved' : 'Removed from saved');
                      },
                      icon: Icon(o.saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: C.ink),
                    ),
                    IconButton(
                      onPressed: () => showShareSheet(context, o.title, 'https://msw.community/j/${o.title.hashCode.abs()}'),
                      icon: Icon(Icons.ios_share_rounded, color: C.ink),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: o.color, borderRadius: BorderRadius.circular(16)),
                      child: Text(
                        o.company[0],
                        style: sans(24, color: Colors.white, weight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(o.company, style: sans(15, weight: FontWeight.w600)),
                          Row(
                            children: [
                              Icon(Icons.verified_rounded, size: 14, color: C.tealD),
                              const SizedBox(width: 4),
                              Text('Verified company', style: sans(12, color: C.muted)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Tag(o.internship ? 'Internship' : 'Job', bg: o.internship ? C.sky : C.lime),
                  ],
                ),
                const SizedBox(height: 14),
                Text(o.title, style: serif(40, height: 1.02)),
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 6, children: [Tag(o.workMode), Tag(o.location), Tag('${o.openings} opening${o.openings > 1 ? 's' : ''}')]),
                const SizedBox(height: 16),
                FactGrid([
                  (Icons.payments_outlined, o.internship ? 'Stipend' : 'Salary', o.pay),
                  (Icons.schedule_outlined, 'Duration', o.duration),
                  (Icons.play_circle_outline_rounded, 'Start date', o.startDate),
                  (Icons.event_busy_outlined, 'Apply by', o.applyBy),
                  (Icons.work_history_outlined, 'Experience', o.experience),
                  (Icons.people_alt_outlined, 'Applicants', fmtNum(o.applicants)),
                ]),
                DSection(
                  'Skills required',
                  child: Wrap(spacing: 8, runSpacing: 8, children: [for (final s in o.skills) Tag(s, bg: C.teal)]),
                ),
                DSection('Eligibility', child: Bullets(o.eligibility)),
                DSection('About the role', child: Text(o.about, style: sans(15, height: 1.55))),
                DSection('Responsibilities', child: Bullets(o.responsibilities, icon: Icons.arrow_forward_rounded)),
                if (o.perks.isNotEmpty)
                  DSection(
                    'Perks',
                    child: Wrap(spacing: 8, runSpacing: 8, children: [for (final p in o.perks) Tag(p, bg: C.lilac)]),
                  ),
                if (o.rounds.isNotEmpty)
                  DSection(
                    'Selection process',
                    child: Column(
                      children: [
                        for (var i = 0; i < o.rounds.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(color: C.ink, shape: BoxShape.circle),
                                  child: Text(
                                    '${i + 1}',
                                    style: sans(12, color: C.onInk, weight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(o.rounds[i], style: sans(14))),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                if (o.aboutCompany.isNotEmpty)
                  DSection(
                    'About ${o.company}',
                    child: Text(o.aboutCompany, style: sans(14, color: C.ink2, height: 1.5)),
                  ),
              ],
            ),
          ),
          BottomBar(
            left: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  o.pay,
                  style: sans(15, weight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text('Apply by ${o.applyBy}', style: sans(12, color: C.muted)),
              ],
            ),
            button: PrimaryButton(
              o.applied ? 'Applied' : 'Apply now',
              icon: !o.applied,
              height: 52,
              bg: o.applied ? C.tealD : null,
              fg: o.applied ? Colors.white : null,
              onTap: o.applied ? null : _apply,
            ),
          ),
        ],
      ),
    );
  }
}

/* ───────────────────────────── company tasks ───────────────────────────── */

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key, required this.t});
  final CTask t;
  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  void _submit() {
    final t = widget.t;
    final repo = TextEditingController(), demo = TextEditingController(), notes = TextEditingController();
    final shots = <int>[];
    sheet(
      context,
      StatefulBuilder(
        builder: (ctx, setS) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Headline('Submit your ', 'work.', size: 34),
            const SizedBox(height: 6),
            Text('${t.company} reviews submissions within 48 hours.', style: sans(13, color: C.muted)),
            const SizedBox(height: 16),
            TextField(
              controller: repo,
              decoration: fieldDec('Pull request / updated repo link', icon: Icons.merge_type_rounded, hint: 'github.com/you/${t.repo.split('/').last}/pull/1'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: demo,
              decoration: fieldDec('Live demo or video link (optional)', icon: Icons.play_circle_outline_rounded),
            ),
            const SizedBox(height: 10),
            TextField(controller: notes, maxLines: 3, decoration: fieldDec('What did you change? Any notes for the reviewer')),
            const SizedBox(height: 14),
            Text('SCREENSHOTS', style: mono(10)),
            const SizedBox(height: 8),
            SizedBox(
              height: 132,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final s in shots)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          MockShot(s),
                          Positioned(
                            right: -6,
                            top: -6,
                            child: GestureDetector(
                              onTap: () => setS(() => shots.remove(s)),
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(color: C.ink, shape: BoxShape.circle),
                                child: Icon(Icons.close_rounded, size: 14, color: C.onInk),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  GestureDetector(
                    onTap: () => setS(() => shots.add(shots.length + t.title.length)),
                    child: Container(
                      width: 96,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: C.line2, width: 1.5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, color: C.muted),
                          const SizedBox(height: 6),
                          Text('Upload', style: sans(12, color: C.muted)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              'Submit for review',
              onTap: () {
                t.submissions.add(
                  Submission(
                    me,
                    repo.text.isEmpty ? 'github.com/aanya-codes/${t.repo.split('/').last}/pull/1' : repo.text,
                    demo.text,
                    notes.text.isEmpty ? 'Submitted via MSW.' : notes.text,
                    List.of(shots),
                  ),
                );
                Navigator.of(ctx).pop();
                setState(() => t.myStatus = 'Submitted');
                Api.submit(t, t.submissions.last);
                snack(context, 'Submitted. ${t.company} has been notified.');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final pad = MediaQuery.of(context).padding;
    final mine = t.submissions.where((s) => s.student == me).toList();
    const levels = ['Easy', 'Medium', 'Hard'];
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20, pad.top + 8, 20, 24),
              children: [
                Row(
                  children: [
                    const BackBtn(),
                    const Spacer(),
                    Tag(t.myStatus, bg: t.myStatus == 'Open' ? null : (t.myStatus == 'Submitted' ? C.peach : C.teal)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: t.color, borderRadius: BorderRadius.circular(13)),
                      child: Text(
                        t.company[0],
                        style: sans(18, color: Colors.white, weight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(t.company, style: sans(15, weight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(t.title, style: serif(38, height: 1.03)),
                const SizedBox(height: 14),
                FactGrid([
                  (Icons.payments_outlined, 'Reward', '₹${fmtNum(t.reward)}'),
                  (Icons.timer_outlined, 'Deadline', '${t.days} days'),
                  (Icons.signal_cellular_alt_rounded, 'Difficulty', levels[t.level - 1]),
                  (Icons.people_alt_outlined, 'Submissions', '${t.submissions.length}'),
                ]),
                DSection(
                  'Repository',
                  child: Pressable(
                    onTap: () => snack(context, 'Opening ${t.repo}'),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: C.black, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          const Icon(Icons.code_rounded, color: C.lime),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(t.repo, style: mono(12, color: Colors.white)),
                          ),
                          const Icon(Icons.open_in_new_rounded, color: Colors.white54, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
                DSection('The brief', child: Text(t.description, style: sans(15, height: 1.55))),
                DSection('Tech stack', child: Wrap(spacing: 8, runSpacing: 8, children: [for (final s in t.stack) Tag(s)])),
                DSection('Deliverables', child: Bullets(t.deliverables, icon: Icons.inventory_2_outlined)),
                DSection('Acceptance criteria', child: Bullets(t.acceptance)),
                DSection(
                  'How it works',
                  child: Bullets(
                    const ['Fork the repo and create a branch', 'Open a pull request with your changes', 'Submit the PR link, notes and screenshots here', 'Get paid to your UPI once approved'],
                    icon: Icons.arrow_forward_rounded,
                    color: C.muted,
                  ),
                ),
                if (mine.isNotEmpty)
                  DSection(
                    'Your submission',
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: C.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: C.line),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.merge_type_rounded, size: 18, color: C.muted),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(mine.last.repo, style: mono(11, color: C.ink)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(mine.last.notes, style: sans(13, color: C.ink2)),
                          if (mine.last.shots.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Wrap(spacing: 8, children: [for (final s in mine.last.shots) MockShot(s, w: 70, h: 96)]),
                          ],
                          const SizedBox(height: 8),
                          Tag(mine.last.status, bg: C.peach),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          BottomBar(
            left: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('₹${fmtNum(t.reward)}', style: serif(28, color: C.tealD)),
                Text('paid on approval', style: sans(12, color: C.muted)),
              ],
            ),
            button: switch (t.myStatus) {
              'Open' => PrimaryButton(
                'Take task',
                height: 52,
                onTap: () {
                  setState(() => t.myStatus = 'In progress');
                  snack(context, '${t.company} has been notified. Good luck.');
                },
              ),
              'In progress' => PrimaryButton('Submit work', height: 52, onTap: _submit),
              _ => PrimaryButton(t.myStatus, icon: false, height: 52, bg: C.bg2, fg: C.ink),
            },
          ),
        ],
      ),
    );
  }
}

/* ───────────────────────────── startup ideas ───────────────────────────── */

class IdeaDetailScreen extends StatefulWidget {
  const IdeaDetailScreen({super.key, required this.idea, this.investor = false});
  final Idea idea;
  final bool investor;
  @override
  State<IdeaDetailScreen> createState() => _IdeaDetailScreenState();
}

class _IdeaDetailScreenState extends State<IdeaDetailScreen> {
  void _back() {
    final d = widget.idea;
    var amt = d.minTicket < 1 ? 1.0 : d.minTicket;
    sheet(
      context,
      StatefulBuilder(
        builder: (ctx, setS) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${d.sector.toUpperCase()} · ${d.stage.toUpperCase()}', style: mono(10)),
            const SizedBox(height: 4),
            Headline('Back ', '${d.name}.', size: 36),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Card2(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('YOUR CHEQUE', style: mono(9)),
                        Text('₹${amt.toStringAsFixed(1)}L', style: serif(36)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Card2(
                    color: C.black,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('YOUR EQUITY', style: mono(9, color: C.teal)),
                        Text('${(amt / d.valuation * 100).toStringAsFixed(2)}%', style: serif(36, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Slider(value: amt, min: d.minTicket, max: d.ask, divisions: ((d.ask - d.minTicket) * 2).round().clamp(1, 60), activeColor: C.ink, onChanged: (v) => setS(() => amt = v)),
            Text('Post-money valuation ₹${(d.valuation / 100).toStringAsFixed(2)} Cr · minimum cheque ₹${d.minTicket}L. Final terms in the term sheet.', style: sans(12, color: C.muted)),
            const SizedBox(height: 14),
            PrimaryButton(
              'Commit ₹${amt.toStringAsFixed(1)}L',
              onTap: () {
                Navigator.of(ctx).pop();
                setState(() {
                  d.raised = (d.raised + amt).clamp(0, d.ask);
                  d.decision = 'backed';
                  d.myCheque = amt;
                });
                Api.decide(d);
                snack(context, 'Commitment sent to ${d.name}. Founders will share the term sheet.');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.idea;
    final pad = MediaQuery.of(context).padding;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20, pad.top + 8, 20, 24),
              children: [
                Row(
                  children: [
                    const BackBtn(),
                    const Spacer(),
                    IconButton(
                      onPressed: () => setState(() => d.saved = !d.saved),
                      icon: Icon(d.saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: C.ink),
                    ),
                    IconButton(
                      onPressed: () => showShareSheet(context, d.name, 'https://msw.community/i/${d.name.toLowerCase()}'),
                      icon: Icon(Icons.ios_share_rounded, color: C.ink),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                IdeaArt(idea: d, height: 200),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 6,
                  children: [
                    Tag(d.sector),
                    Tag(d.stage, bg: C.teal),
                    Tag('MSW verified'),
                  ],
                ),
                const SizedBox(height: 10),
                Text(d.name, style: serif(46)),
                Text(d.pitch, style: sans(16, color: C.ink2, height: 1.45)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: C.black, borderRadius: BorderRadius.circular(22)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('THE ASK', style: mono(10, color: C.teal)),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹${d.ask.toStringAsFixed(0)}L', style: serif(44, color: Colors.white)),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text('for ${d.equity.toStringAsFixed(0)}% equity', style: sans(14, color: Colors.white70)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(value: d.raised / d.ask, minHeight: 7, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation(C.lime)),
                      ),
                      const SizedBox(height: 8),
                      Text('₹${d.raised.toStringAsFixed(1)}L committed of ₹${d.ask.toStringAsFixed(0)}L', style: sans(12, color: Colors.white60)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          for (final s in [('Valuation', '₹${(d.valuation / 100).toStringAsFixed(2)}Cr'), ('Min cheque', '₹${d.minTicket}L'), ('Instrument', 'Equity')])
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.$1.toUpperCase(), style: mono(8.5, color: Colors.white54)),
                                  Text(
                                    s.$2,
                                    style: sans(14, color: Colors.white, weight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                FactGrid([
                  (Icons.people_alt_outlined, 'Users', fmtNum(d.users)),
                  (Icons.trending_up_rounded, 'Growth', '+${d.growth.toStringAsFixed(0)}% MoM'),
                  (Icons.payments_outlined, 'Revenue', d.revenue),
                  (Icons.public_rounded, 'Market', d.market),
                ]),
                DSection('Problem', child: Text(d.problem, style: sans(15, height: 1.55))),
                DSection('Solution', child: Text(d.solution, style: sans(15, height: 1.55))),
                DSection('Business model', child: Text(d.model, style: sans(15, height: 1.55))),
                DSection(
                  'Use of funds',
                  child: Column(
                    children: [
                      for (final u in d.useOfFunds)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              SizedBox(width: 110, child: Text(u.$1, style: sans(13))),
                              Expanded(
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: u.$2 / 100),
                                  duration: const Duration(milliseconds: 1200),
                                  curve: Curves.easeOutCubic,
                                  builder: (_, v, _) => ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(value: v, minHeight: 10, backgroundColor: C.bg2, valueColor: AlwaysStoppedAnimation(d.color)),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 44,
                                child: Text(
                                  '${u.$2}%',
                                  textAlign: TextAlign.right,
                                  style: sans(13, weight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                DSection('Milestones with this round', child: Bullets(d.milestones, icon: Icons.flag_outlined)),
                DSection(
                  'Founders',
                  child: Column(
                    children: [
                      for (final f in d.founders)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card2(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                GAvatar(f.name.split(' ').map((w) => w[0]).join(), size: 42, colors: [d.color, C.lilac]),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(f.name, style: sans(14, weight: FontWeight.w600)),
                                      Text('${f.role} · ${f.college}', style: sans(12, color: C.muted)),
                                    ],
                                  ),
                                ),
                                Icon(Icons.verified_rounded, size: 18, color: C.tealD),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                DSection(
                  'Documents',
                  child: Column(
                    children: [
                      for (final doc in const [
                        (Icons.slideshow_outlined, 'Pitch deck', 'PDF · 14 slides'),
                        (Icons.table_chart_outlined, 'Financial model', 'XLSX · 3-year plan'),
                        (Icons.description_outlined, 'Cap table', 'PDF'),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Pressable(
                            onTap: () => snack(context, widget.investor ? 'Opening ${doc.$2}' : 'Documents are visible to verified investors'),
                            child: Card2(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Icon(doc.$1, color: C.ink),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(doc.$2, style: sans(14, weight: FontWeight.w600)),
                                  ),
                                  Text(doc.$3, style: sans(12, color: C.muted)),
                                  const SizedBox(width: 6),
                                  Icon(widget.investor ? Icons.download_rounded : Icons.lock_outline_rounded, size: 18, color: C.muted),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (widget.investor)
            BottomBar(
              left: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('₹${d.ask.toStringAsFixed(0)}L · ${d.equity.toStringAsFixed(0)}%', style: sans(15, weight: FontWeight.w700)),
                  Text(
                    '${((d.raised / d.ask) * 100).round()}% committed',
                    style: sans(12, color: C.tealD, weight: FontWeight.w600),
                  ),
                ],
              ),
              button: PrimaryButton('Back this idea', icon: false, height: 52, onTap: _back),
            ),
        ],
      ),
    );
  }
}

/// Illustrated cover for an idea: gradient, halftone dots, big icon, mini chart.
class IdeaArt extends StatelessWidget {
  const IdeaArt({super.key, required this.idea, this.height = 260, this.page = 0});
  final Idea idea;
  final double height;
  final int page;
  @override
  Widget build(BuildContext context) {
    final d = idea;
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [d.color, Color.lerp(d.color, Colors.black, 0.55)!]),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _DotsPainter())),
          if (page == 0)
            Center(
              child: Icon(d.icon, size: height * 0.38, color: Colors.white.withValues(alpha: 0.92)),
            ),
          if (page == 1)
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TRACTION', style: mono(10, color: Colors.white70)),
                  Text('${fmtNum(d.users)} users', style: serif(36, color: Colors.white)),
                  Text('+${d.growth.toStringAsFixed(0)}% month on month', style: sans(13, color: Colors.white70)),
                  const Spacer(),
                  SizedBox(
                    height: height * 0.4,
                    width: double.infinity,
                    child: CustomPaint(painter: _BarsPainter(d.spark)),
                  ),
                ],
              ),
            ),
          if (page == 2)
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('THE TEAM', style: mono(10, color: Colors.white70)),
                  const SizedBox(height: 8),
                  for (final f in d.founders) Text(f.name, style: serif(30, color: Colors.white)),
                  Text(d.founders.map((f) => f.college).toSet().join(' · '), style: sans(13, color: Colors.white70)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.10);
    for (double y = 0; y < s.height; y += 12) {
      for (double x = ((y ~/ 12).isEven ? 0 : 6); x < s.width; x += 12) {
        final k = (x / s.width + y / s.height) / 2;
        canvas.drawCircle(Offset(x, y), 0.4 + k * 2.4, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BarsPainter extends CustomPainter {
  _BarsPainter(this.d);
  final List<double> d;
  @override
  void paint(Canvas canvas, Size s) {
    final mx = d.reduce((a, b) => a > b ? a : b);
    final w = s.width / d.length;
    final p = Paint()..color = Colors.white.withValues(alpha: 0.85);
    for (var i = 0; i < d.length; i++) {
      final h = d[i] / mx * s.height;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(i * w + w * 0.18, s.height - h, w * 0.64, h), const Radius.circular(4)),
        p..color = Colors.white.withValues(alpha: i == d.length - 1 ? 1 : 0.55),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
