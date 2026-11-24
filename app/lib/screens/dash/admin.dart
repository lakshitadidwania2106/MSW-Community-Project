import 'dart:async';

import 'package:flutter/material.dart';

import '../../data.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';
import 'common.dart';

/// ===================== ADMIN (mission control) =====================
final _adm = roles[4];
Color get _c => _adm.color;
const _notes = [('⚠️', '3 posts reported in the last hour'), ('🏛', 'IIT Bombay E-Cell requested a hackathon'), ('🏢', 'Kite AI is waiting for verification')];
const _students = ['Aanya Sharma', 'Rohan Kapoor', 'Meera Joshi', 'Arjun Rao', 'Sana Khan', 'Rhea Pillai'];

class ATask {
  ATask(this.title, this.src, this.prio, this.reward, this.stage, [this.who]);
  final String title, src, prio;
  final int reward;
  int stage; // 0 open · 1 assigned · 2 review · 3 done
  String? who;
}

final aTasks = [
  ATask('Write Day 14 challenge tests', 'MSW LABS', 'High', 1500, 0),
  ATask('Design HackNova certificate', 'EVENTS', 'Med', 2000, 0),
  ATask('Translate Day 1–5 reels to Hindi', 'MSW LABS', 'Low', 3000, 0),
  ATask('Moderate #InternshipSeason', 'COMMUNITY', 'Med', 800, 1, 'Sana Khan'),
  ATask('Fix checkout bug (Helio)', 'COMPANY', 'High', 3000, 1, 'Aanya Sharma'),
  ATask('Accessibility audit (Lumen Labs)', 'COMPANY', 'Med', 4500, 2, 'Rhea Pillai'),
  ATask('Data cleaning (Kite AI)', 'COMPANY', 'Low', 2200, 3, 'Meera Joshi'),
];

class AdminHome extends StatefulWidget {
  const AdminHome({super.key, required this.go});
  final ValueChanged<int> go;
  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  static const _events = [
    ('🎓', 'New student signed up', 'Ishaan M. · IIT Delhi'),
    ('💼', 'Kite AI posted a role', 'ML Research Intern'),
    ('🚀', 'Idea pledged', 'Nikhil V. → Krishi · ₹2L'),
    ('✅', 'Task submitted', 'Rhea P. · Accessibility audit'),
    ('🔥', 'Day 30 completed', 'Sana K. finished MSW Labs'),
    ('🏆', 'Hackathon registration', 'Team Byte Me · HackNova'),
    ('🧠', 'IQ test finished', 'Dev S. scored 118'),
  ];
  final _feed = <(String, String, String, int)>[];
  int _k = 0;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 4; i++) {
      _push();
    }
    _t = Timer.periodic(const Duration(milliseconds: 2600), (_) => setState(_push));
  }

  void _push() {
    final e = _events[_k % _events.length];
    _feed.insert(0, (e.$1, e.$2, e.$3, _k++));
    if (_feed.length > 5) _feed.removeLast();
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 110),
      children: [
        DashHeader(role: _adm, a: 'Mission ', b: 'control.', sub: 'Everything happening on MSW Community', notes: _notes),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.05,
          children: [
            StatTile(label: 'Students', value: 12460, accent: _c, delta: '612 this week', spark: const [4, 5, 6, 7, 8, 9, 10, 11, 12.4], icon: Icons.school_rounded),
            StatTile(label: 'Companies', value: 640, accent: _c, delta: '38 this week', spark: const [2, 3, 3, 4, 4, 5, 6, 6.4], icon: Icons.business_rounded),
            StatTile(label: 'Colleges', value: 124, accent: _c, delta: '6 new', spark: const [3, 4, 5, 7, 8, 10, 11, 12.4], icon: Icons.account_balance_rounded),
            StatTile(label: 'Investors', value: 312, accent: _c, delta: '₹4.2Cr pledged', spark: const [1, 1.5, 2, 2.2, 2.6, 2.9, 3.1], icon: Icons.trending_up_rounded),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: C.dark, borderRadius: BorderRadius.circular(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Live activity', style: serif(26, color: C.onDark)),
                  const Spacer(),
                  const _Pulse(),
                  const SizedBox(width: 6),
                  Text('LIVE', style: mono(10, color: C.teal)),
                ],
              ),
              const SizedBox(height: 10),
              for (final f in _feed)
                TweenAnimationBuilder<double>(
                  key: ValueKey(f.$4),
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, child) => Opacity(
                    opacity: v,
                    child: Transform.translate(offset: Offset(0, (1 - v) * -12), child: child),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(11)),
                          child: Text(f.$1, style: const TextStyle(fontSize: 17)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f.$2,
                                style: sans(14, color: C.onDark, weight: FontWeight.w600, height: 1.2),
                              ),
                              Text('${f.$3} · just now', style: sans(12, color: Colors.white54)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SectionTitle('Needs', b: 'you'),
        Row(
          children: [
            Expanded(child: _need('6', 'Approvals', C.lime, () => widget.go(2))),
            const SizedBox(width: 10),
            Expanded(child: _need('3', 'Reports', C.peach, () => widget.go(2))),
            const SizedBox(width: 10),
            Expanded(child: _need('${aTasks.where((t) => t.stage == 0).length}', 'Open tasks', C.sky, () => widget.go(1))),
          ],
        ),
        const SizedBox(height: 12),
        ChartCard(
          a: 'Sign-ups',
          b: 'this year',
          series: [
            ('Students', _c, const [180, 240, 210, 320, 380, 360, 440, 520, 480, 590, 640, 612]),
            ('Orgs', const Color(0xFF6C5CE7), const [8, 12, 10, 15, 18, 17, 22, 26, 24, 31, 36, 44]),
          ],
          labels: const ['Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov'],
        ),
        const SectionTitle('MSW Labs', b: 'funnel'),
        Card2(child: BarList(const [('Day 1', 9800), ('Day 7', 7200), ('Day 14', 5100), ('Day 21', 3900), ('Day 30', 2640)], color: _c)),
      ],
    );
  }

  Widget _need(String n, String l, Color bg, VoidCallback onTap) => Pressable(
    onTap: onTap,
    child: Container(
      height: 92,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(n, style: serif(36, color: C.black)),
          const Spacer(),
          Text(
            l,
            style: sans(12, color: C.black, weight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}

class _Pulse extends StatefulWidget {
  const _Pulse();
  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _a = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _a,
    builder: (_, _) => Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: C.teal,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: C.teal.withValues(alpha: 0.6 * (1 - _a.value)),
            spreadRadius: 8 * _a.value,
          ),
        ],
      ),
    ),
  );
}

class AdminTasks extends StatefulWidget {
  const AdminTasks({super.key});
  @override
  State<AdminTasks> createState() => _AdminTasksState();
}

class _AdminTasksState extends State<AdminTasks> {
  int _stage = 0;
  static const _stages = ['Open', 'Assigned', 'In review', 'Done'];

  void _newTask() {
    final t = TextEditingController(text: 'Record Day 15 reel voice-over');
    var src = 'MSW LABS', prio = 'Med';
    String? who;
    showSheet(
      context,
      StatefulBuilder(
        builder: (ctx, setS) {
          Widget chips(List<String?> o, String? sel, void Function(String?) on) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final x in o)
                ChoiceChip(
                  label: Text(x ?? 'Leave open'),
                  selected: sel == x,
                  onSelected: (_) => setS(() => on(x)),
                  selectedColor: C.lime,
                  showCheckmark: false,
                  labelStyle: sans(13, color: sel == x ? C.black : C.ink),
                ),
            ],
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Headline('New ', 'task.', size: 34, italicColor: _c),
              const SizedBox(height: 14),
              TextField(
                controller: t,
                decoration: InputDecoration(
                  labelText: 'Task',
                  filled: true,
                  fillColor: C.card,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              Text('SOURCE', style: mono(10)),
              const SizedBox(height: 6),
              chips(const ['MSW LABS', 'EVENTS', 'COMMUNITY', 'COMPANY'], src, (v) => src = v!),
              const SizedBox(height: 12),
              Text('PRIORITY', style: mono(10)),
              const SizedBox(height: 6),
              chips(const ['High', 'Med', 'Low'], prio, (v) => prio = v!),
              const SizedBox(height: 12),
              Text('ASSIGN TO', style: mono(10)),
              const SizedBox(height: 6),
              chips([null, ..._students.take(4)], who, (v) => who = v),
              const SizedBox(height: 16),
              PrimaryButton(
                'Create & allocate',
                bg: _c,
                onTap: () {
                  setState(() => aTasks.insert(0, ATask(t.text, src, prio, 1500, who == null ? 0 : 1, who)));
                  Navigator.of(ctx).pop();
                  toast(context, who == null ? 'Posted to the open board ⚡' : 'Allocated to $who ⚡');
                },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    final list = aTasks.where((t) => t.stage == _stage).toList();
    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 110),
      children: [
        DashHeader(role: _adm, a: 'Task ', b: 'allocation.', sub: 'Assign, review and pay out contributions', notes: _notes),
        const SizedBox(height: 16),
        PrimaryButton('Create a task', bg: _c, onTap: _newTask),
        const SizedBox(height: 14),
        ChipBar(items: [for (var i = 0; i < 4; i++) '${_stages[i]} · ${aTasks.where((t) => t.stage == i).length}'], sel: _stage, onSel: (i) => setState(() => _stage = i), color: _c),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: Column(
            key: ValueKey('$_stage-${list.length}'),
            children: [
              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text('Nothing here ✨', style: sans(14, color: C.muted)),
                ),
              for (var i = 0; i < list.length; i++)
                Reveal(
                  delay: i * 60,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card2(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Tag(list[i].prio, bg: list[i].prio == 'High' ? const Color(0xFFFFC9C9) : (list[i].prio == 'Med' ? C.peach : C.sky)),
                              const Spacer(),
                              Text(list[i].src, style: mono(9)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(list[i].title, style: serif(24, height: 1.05)),
                          const SizedBox(height: 4),
                          Text('${list[i].who != null ? '👤 ${list[i].who}' : 'Unassigned'} · ₹${fmtNum(list[i].reward)}', style: sans(12, color: C.muted)),
                          if (list[i].stage < 3) ...[
                            const SizedBox(height: 12),
                            PrimaryButton(
                              switch (list[i].stage) {
                                0 => 'Assign best match',
                                1 => 'Mark submitted',
                                _ => 'Approve & pay ₹${fmtNum(list[i].reward)}',
                              },
                              bg: list[i].stage == 2 ? C.lime : _c,
                              fg: list[i].stage == 2 ? C.black : Colors.white,
                              icon: false,
                              height: 44,
                              onTap: () {
                                final t = list[i];
                                setState(() {
                                  if (t.stage == 0) t.who = _students[t.title.length % _students.length];
                                  t.stage++;
                                });
                                toast(context, switch (t.stage) {
                                  1 => 'Auto-assigned to ${t.who} ⚡',
                                  2 => 'Moved to review',
                                  _ => '₹${fmtNum(t.reward)} paid to ${t.who} 💸',
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class AdminApprovals extends StatefulWidget {
  const AdminApprovals({super.key});
  @override
  State<AdminApprovals> createState() => _AdminApprovalsState();
}

class _AdminApprovalsState extends State<AdminApprovals> {
  int _seg = 0;
  final _gone = <String, bool>{};
  static const _items = [
    ('Contribution', '🎬', 'Day 15 reel script — Hooks deep-dive', 'Sana Khan · MSW Labs mentor'),
    ('Contribution', '🧩', '12 new reasoning questions', 'Ishaan M. · IIT Delhi'),
    ('Event', '🏛', 'E-Summit Hackathon (Jan 18–19)', 'IIT Bombay E-Cell · 600 seats'),
    ('Event', '🌱', 'Green Code Sprint', 'BITS Pilani ACM · online'),
    ('Verification', '🏢', 'Verify Kite AI', 'kite.ai · 40 employees · GST verified'),
    ('Verification', '💼', 'Verify Ananya Capital', 'Angel syndicate · 12 members'),
  ];
  static const _reports = [
    ('Spam', 'spam_bot_221', '🔥 Get 10,000 followers in 1 day!!! click here →', 14),
    ('Harassment', 'anon_user_77', 'Replying to Meera: nobody asked for your opinion lol', 6),
    ('Off-topic', 'Dev Shah', 'Selling my old cycle, DM me 🚲', 2),
  ];

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    final a = _items.where((x) => !_gone.containsKey(x.$3)).length, r = _reports.where((x) => !_gone.containsKey(x.$2)).length;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 110),
      children: [
        DashHeader(role: _adm, a: 'Approvals ', b: '& safety.', notes: _notes),
        const SizedBox(height: 16),
        ChipBar(items: ['Approvals · $a', 'Reports · $r'], sel: _seg, onSel: (i) => setState(() => _seg = i), color: _c),
        const SizedBox(height: 14),
        if (_seg == 0) ...[
          if (a == 0)
            Card2(
              child: Center(
                child: Text('Inbox zero ✨', style: sans(14, color: C.muted)),
              ),
            ),
          for (final x in _items)
            Removable(
              removed: _gone.containsKey(x.$3),
              left: _gone[x.$3] == false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card2(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Tag(x.$1, bg: x.$1 == 'Event' ? C.sky : (x.$1 == 'Contribution' ? C.lilac : C.peach)),
                          const Spacer(),
                          Text(x.$2, style: const TextStyle(fontSize: 26)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(x.$3, style: serif(24, height: 1.05)),
                      Text(x.$4, style: sans(12, color: C.muted)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              'Approve',
                              bg: _c,
                              icon: false,
                              height: 44,
                              onTap: () {
                                setState(() => _gone[x.$3] = true);
                                toast(context, 'Approved: ${x.$3}');
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: PrimaryButton(
                              'Decline',
                              bg: C.bg2,
                              fg: C.ink,
                              icon: false,
                              height: 44,
                              onTap: () {
                                setState(() => _gone[x.$3] = false);
                                toast(context, 'Declined: ${x.$3}');
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ] else ...[
          if (r == 0)
            Card2(
              child: Center(
                child: Text('No reports. The community is behaving 🌱', style: sans(14, color: C.muted)),
              ),
            ),
          for (final x in _reports)
            Removable(
              removed: _gone.containsKey(x.$2),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card2(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Tag(x.$1, bg: const Color(0xFFFFC9C9)),
                          const Spacer(),
                          Text('${x.$4} REPORTS', style: mono(9)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('@${x.$2}', style: sans(14, weight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: C.bg2, borderRadius: BorderRadius.circular(14)),
                        child: Text(x.$3, style: sans(14)),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              'Remove',
                              bg: const Color(0xFFE5484D),
                              icon: false,
                              height: 42,
                              onTap: () {
                                setState(() => _gone[x.$2] = true);
                                toast(context, 'Post removed 🛡');
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: PrimaryButton(
                              'Ban user',
                              bg: C.ink,
                              icon: false,
                              height: 42,
                              onTap: () {
                                setState(() => _gone[x.$2] = true);
                                toast(context, '@${x.$2} banned');
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: PrimaryButton(
                              'Keep',
                              bg: C.bg2,
                              fg: C.ink,
                              icon: false,
                              height: 42,
                              onTap: () {
                                setState(() => _gone[x.$2] = true);
                                toast(context, 'Kept — reporters notified');
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class AdminQuizzes extends StatefulWidget {
  const AdminQuizzes({super.key});
  @override
  State<AdminQuizzes> createState() => _AdminQuizzesState();
}

class _AdminQuizzesState extends State<AdminQuizzes> {
  final _quizzes = [
    ('IQ test', 5, 4210, true),
    ('Reasoning', 10, 2890, true),
    ('Daily quiz — Nov 23', 5, 1120, true),
    ('Aptitude', 15, 1840, true),
    ('React fundamentals', 12, 0, false),
  ].map((q) => [q.$1, q.$2, q.$3, q.$4]).toList();
  final _badges = [('🔥', '12-day streak', 3120), ('🏆', 'Hackathon winner', 214), ('🧠', 'IQ 120+', 1980), ('⚡', 'First task', 2400), ('🚀', 'Shipped capstone', 2640), ('💎', 'Top 1%', 124)];

  void _builder() {
    final name = TextEditingController(text: 'JavaScript basics');
    var qs = 2;
    showSheet(
      context,
      StatefulBuilder(
        builder: (ctx, setS) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Headline('Build a ', 'quiz.', size: 34, italicColor: _c),
            const SizedBox(height: 14),
            TextField(
              controller: name,
              decoration: InputDecoration(
                labelText: 'Quiz name',
                filled: true,
                fillColor: C.card,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 12),
            for (var q = 0; q < qs; q++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card2(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('QUESTION ${q + 1}', style: mono(9, color: _c)),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Type the question…',
                          hintStyle: sans(14, color: C.muted),
                          border: InputBorder.none,
                        ),
                      ),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final o in const ['A', 'B', 'C', 'D']) Tag('Option $o${o == 'A' ? ' ✓' : ''}', bg: o == 'A' ? C.lime : null),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            TextButton.icon(
              onPressed: () => setS(() => qs++),
              icon: Icon(Icons.add_rounded, color: _c),
              label: Text(
                'Add question',
                style: sans(14, color: _c, weight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              'Publish quiz',
              bg: _c,
              onTap: () {
                setState(() => _quizzes.insert(0, [name.text, qs, 0, true]));
                Navigator.of(ctx).pop();
                toast(context, 'Quiz published to the app & website 🧠');
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
        DashHeader(role: _adm, a: 'Quizzes ', b: '& badges.', notes: _notes),
        const SizedBox(height: 16),
        PrimaryButton('Build a quiz', bg: _c, onTap: _builder),
        const SizedBox(height: 14),
        for (final q in _quizzes)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card2(
              padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(q[0] as String, style: sans(15, weight: FontWeight.w600, height: 1.2)),
                        Text('${q[1]} questions · ${fmtNum(q[2] as int)} plays', style: sans(12, color: C.muted)),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: q[3] as bool,
                    activeTrackColor: _c,
                    onChanged: (v) {
                      setState(() => q[3] = v);
                      toast(context, '${q[0]} is ${v ? 'live' : 'hidden'}');
                    },
                  ),
                ],
              ),
            ),
          ),
        const SectionTitle('Badges'),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            for (final b in _badges)
              Card2(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(b.$1, style: const TextStyle(fontSize: 30)),
                    const SizedBox(height: 4),
                    Text(
                      b.$2,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: sans(11, weight: FontWeight.w600, height: 1.15),
                    ),
                    Text('${fmtNum(b.$3)} earned', style: sans(10, color: C.muted)),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class AdminAccount extends StatefulWidget {
  const AdminAccount({super.key});
  @override
  State<AdminAccount> createState() => _AdminAccountState();
}

class _AdminAccountState extends State<AdminAccount> {
  final _users = [
    ['Aanya Sharma', 'Student', 'Active'],
    ['Lumen Labs', 'Company', 'Verified'],
    ['Nikhil Varma', 'Investor', 'Verified'],
    ['IIT Bombay E-Cell', 'College', 'Verified'],
    ['Kite AI', 'Company', 'Pending'],
    ['spam_bot_221', 'Student', 'Suspended'],
  ];
  @override
  Widget build(BuildContext context) => AccountTab(
    role: _adm,
    name: 'MSW Admin',
    sub: 'Mission control · full access',
    initials: 'M.',
    extra: [
      const SectionTitle('Users'),
      for (final u in _users)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Card2(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            child: Row(
              children: [
                GAvatar(u[0][0], size: 36, colors: [_c, C.lilac]),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u[0], style: sans(14, weight: FontWeight.w600, height: 1.2)),
                      Text('${u[1]} · ${u[2]}', style: sans(12, color: u[2] == 'Suspended' ? const Color(0xFFE5484D) : C.muted)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => u[2] = u[2] == 'Suspended' ? 'Active' : 'Suspended');
                    toast(context, '${u[0]} ${u[2] == 'Suspended' ? 'suspended ⛔' : 'restored ✓'}');
                  },
                  child: Text(
                    u[2] == 'Suspended' ? 'Restore' : 'Suspend',
                    style: sans(13, weight: FontWeight.w600, color: u[2] == 'Suspended' ? C.tealD : const Color(0xFFE5484D)),
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}
