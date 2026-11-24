import 'package:flutter/material.dart';

import '../../data.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';
import 'common.dart';

/// ===================== COMPANY (Lumen Labs) =====================
final _company = roles[1];
Color get _c => _company.color;

class Candidate {
  Candidate(this.name, this.college, this.iq, this.gh, this.lv, this.skills, this.stage, this.grad);
  final String name, college;
  final int iq, gh, lv;
  final List<String> skills;
  int stage; // 0 applied · 1 shortlisted · 2 interview · 3 hired
  final List<Color> grad;
  String get ini => name.split(' ').map((w) => w[0]).join();
}

final candidates = [
  Candidate('Meera Joshi', 'IIT KGP · AgE ’26', 133, 91, 17, ['IoT', 'Python', 'ML'], 0, [C.peach, const Color(0xFFC86DD7)]),
  Candidate('Arjun Rao', 'DTU · IT ’27', 118, 84, 12, ['Next.js', 'Node'], 0, [C.tealD, C.sky]),
  Candidate('Dev Shah', 'VIT · CSE ’28', 112, 66, 8, ['HTML', 'CSS', 'JS'], 0, [const Color(0xFF6C5CE7), const Color(0xFF00D2D3)]),
  Candidate('Rohan Kapoor', 'NIT Trichy · ECE ’27', 121, 79, 11, ['Flutter', 'Firebase'], 1, [C.tealD, C.lime]),
  Candidate('Sana Khan', 'BITS Pilani · CS ’26', 125, 89, 15, ['TypeScript', 'GraphQL'], 1, [C.sky, const Color(0xFF6C5CE7)]),
  Candidate('Aanya Sharma', 'IIT Delhi · CSE ’27', 128, 87, 14, ['React', 'Python', 'Figma'], 2, [const Color(0xFFFF9A76), const Color(0xFFC86DD7)]),
  Candidate('Rhea Pillai', 'IIIT Hyd · CSE ’26', 130, 93, 18, ['Rust', 'Go'], 3, [C.lime, C.tealD]),
];

class Posting {
  Posting(this.role, this.type, this.loc, this.pay, this.applicants, this.views, this.live);
  final String role, type, loc, pay;
  final int applicants, views;
  bool live;
}

final postings = [
  Posting('Frontend Intern', 'Internship', 'Remote', '₹40k/mo', 128, 2140, true),
  Posting('Backend Intern', 'Internship', 'Bengaluru', '₹45k/mo', 86, 1620, true),
  Posting('Product Designer', 'Full-time', 'Hybrid', '₹12 LPA', 42, 980, true),
  Posting('DevRel Intern', 'Internship', 'Remote', '₹30k/mo', 17, 410, false),
];

const _stages = ['Applied', 'Shortlisted', 'Interview', 'Hired'];
const _notes = [('👋', '23 new applicants for Frontend Intern'), ('📦', 'Rhea Pillai submitted the accessibility audit'), ('⭐', 'Your posting is trending at IIT Delhi')];

class CompanyHome extends StatelessWidget {
  const CompanyHome({super.key, required this.go});
  final ValueChanged<int> go;
  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 110),
      children: [
        DashHeader(role: _company, a: 'Hiring, ', b: 'at a glance.', sub: 'Lumen Labs · verified company', notes: _notes),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: QuickAction(Icons.add_rounded, 'Post a\nrole', color: _c, onTap: () => postRoleSheet(context)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: QuickAction(Icons.task_alt_rounded, 'Allocate\na task', color: C.tealD, onTap: () => allocateTaskSheet(context)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: QuickAction(Icons.people_alt_rounded, 'Review\napplicants', color: C.lime, dark: true, onTap: () => go(2)),
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
          childAspectRatio: 1.05,
          children: [
            StatTile(label: 'Applicants', value: 273, accent: _c, delta: '41% this week', spark: const [20, 34, 30, 55, 61, 80, 120, 140, 190, 273], icon: Icons.people_alt_rounded),
            StatTile(label: 'Open roles', value: 3, accent: _c, delta: '1 new', spark: const [1, 1, 2, 2, 2, 3, 3], icon: Icons.work_rounded),
            StatTile(label: 'Tasks live', value: 6, accent: _c, delta: '₹18,300 committed', spark: const [2, 3, 3, 4, 4, 5, 6], icon: Icons.task_alt_rounded),
            StatTile(label: 'Days to hire', value: 9, suffix: 'd', accent: _c, delta: '3d faster', spark: const [21, 18, 17, 15, 14, 12, 11, 9], icon: Icons.timer_rounded),
          ],
        ),
        const SizedBox(height: 12),
        ChartCard(
          a: 'Applicants',
          b: 'over time',
          series: [
            ('Applied', _c, const [8, 14, 12, 22, 19, 31, 28, 36, 42, 39, 51, 47, 58, 63]),
            ('Shortlisted', C.tealD, const [2, 3, 3, 6, 5, 8, 7, 10, 12, 11, 14, 13, 17, 19]),
          ],
          labels: const ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7', 'W8', 'W9', 'W10', 'W11', 'W12', 'W13', 'Now'],
        ),
        const SectionTitle('Hiring', b: 'funnel'),
        Card2(child: BarList(const [('Viewed', 5150), ('Applied', 273), ('Shortlisted', 64), ('Interview', 18), ('Hired', 4)], color: _c)),
        SectionTitle('Top', b: 'candidates', action: 'Pipeline →', onAction: () => go(2)),
        for (final c in candidates.where((c) => c.stage < 3).take(3))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CandidateTile(c, onTap: () => candidateSheet(context, c)),
          ),
      ],
    );
  }
}

class _CandidateTile extends StatelessWidget {
  const _CandidateTile(this.c, {required this.onTap, this.trailing});
  final Candidate c;
  final VoidCallback onTap;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    scale: 0.98,
    child: Card2(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GAvatar(c.ini, size: 42, colors: c.grad),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name, style: sans(15, weight: FontWeight.w600, height: 1.2)),
                    Text(c.college, style: sans(12, color: C.muted)),
                  ],
                ),
              ),
              Tag('Lvl ${c.lv}', bg: C.lime),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in c.skills) Tag(s),
              Tag('IQ ${c.iq}', bg: C.lilac),
              Tag('GH ${c.gh}', bg: C.teal),
            ],
          ),
          if (trailing != null) ...[const SizedBox(height: 12), trailing!],
        ],
      ),
    ),
  );
}

void candidateSheet(BuildContext context, Candidate c, {VoidCallback? onAdvance}) => showSheet(
  context,
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          GAvatar(c.ini, size: 64, colors: c.grad),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name, style: serif(34)),
                Text(c.college, style: sans(13, color: C.muted)),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          for (final s in [('IQ', c.iq), ('GitHub', c.gh), ('Level', c.lv)])
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: C.bg2, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.$1.toUpperCase(), style: mono(9)),
                    CountUp(to: s.$2, style: serif(32)),
                  ],
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 16),
      Text('VERIFIED ON MSW ID', style: mono(10)),
      const SizedBox(height: 8),
      for (final v in const [('🏆', '2× hackathon finalist'), ('📚', 'MSW Labs Day 24 / 30'), ('⚡', '6 company tasks shipped · 4.9★')])
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Text(v.$1, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text(v.$2, style: sans(14)),
            ],
          ),
        ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: PrimaryButton(
              c.stage < 3 ? 'Move to ${_stages[c.stage + 1]}' : 'Hired 🎉',
              bg: _c,
              icon: false,
              height: 52,
              onTap: () {
                Navigator.of(context).pop();
                if (c.stage < 3) {
                  onAdvance?.call();
                  toast(context, '${c.name} → ${_stages[c.stage]}');
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: PrimaryButton('Message', icon: false, height: 52, bg: C.bg2, fg: C.ink, onTap: () => toast(context, 'Chat with ${c.name.split(' ').first} — coming soon')),
          ),
        ],
      ),
    ],
  ),
);

class CompanyJobs extends StatefulWidget {
  const CompanyJobs({super.key});
  @override
  State<CompanyJobs> createState() => _CompanyJobsState();
}

class _CompanyJobsState extends State<CompanyJobs> {
  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 110),
      children: [
        DashHeader(role: _company, a: 'Your ', b: 'openings.', sub: '${postings.where((p) => p.live).length} live · ${postings.fold<int>(0, (a, p) => a + p.applicants)} applicants', notes: _notes),
        const SizedBox(height: 16),
        PrimaryButton(
          'Post a job or internship',
          bg: _c,
          onTap: () async {
            await postRoleSheet(context);
            setState(() {});
          },
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < postings.length; i++)
          Reveal(
            delay: i * 80,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card2(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: _c, borderRadius: BorderRadius.circular(13)),
                          child: Text(
                            'L',
                            style: sans(18, color: Colors.white, weight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(postings[i].role, style: sans(15, weight: FontWeight.w600, height: 1.2)),
                              Text('${postings[i].type} · ${postings[i].loc} · ${postings[i].pay}', style: sans(12, color: C.muted)),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: postings[i].live,
                          activeTrackColor: _c,
                          onChanged: (v) {
                            setState(() => postings[i].live = v);
                            toast(context, '${postings[i].role} ${v ? 'is live' : 'paused'}');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _mini('Applicants', '${postings[i].applicants}'),
                        _mini('Views', fmtNum(postings[i].views)),
                        _mini('Conversion', postings[i].views == 0 ? '—' : '${(postings[i].applicants / postings[i].views * 100).toStringAsFixed(1)}%'),
                        Tag(postings[i].live ? 'Live' : 'Paused', bg: postings[i].live ? C.teal : null),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _mini(String l, String v) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.toUpperCase(), style: mono(8.5)),
        Text(v, style: serif(24)),
      ],
    ),
  );
}

Future<void> postRoleSheet(BuildContext context) {
  final role = TextEditingController(text: 'Mobile Developer Intern'), pay = TextEditingController(text: '₹35k/mo'), loc = TextEditingController(text: 'Remote');
  var type = 'Internship';
  var lvl = 8.0;
  return showSheet(
    context,
    StatefulBuilder(
      builder: (ctx, setS) {
        InputDecoration dec(String l) => InputDecoration(
          labelText: l,
          filled: true,
          fillColor: C.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: C.line2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: C.line2),
          ),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Headline('Post a ', 'role.', size: 34, italicColor: _c),
            const SizedBox(height: 14),
            Text('LIVE PREVIEW', style: mono(10)),
            const SizedBox(height: 8),
            Card2(
              color: C.card,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: _c, borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          'L',
                          style: sans(17, color: Colors.white, weight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(role.text, style: sans(15, weight: FontWeight.w600, height: 1.2)),
                            Text('Lumen Labs · ${loc.text} · ${pay.text}', style: sans(12, color: C.muted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Tag(type),
                      const SizedBox(width: 6),
                      Tag('Lvl ${lvl.round()}+', bg: C.lime),
                      const Spacer(),
                      Text(
                        'One-tap apply',
                        style: sans(12, weight: FontWeight.w600, color: _c),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            TextField(controller: role, onChanged: (_) => setS(() {}), decoration: dec('Role title')),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                for (final t in const ['Internship', 'Full-time', 'Part-time'])
                  ChoiceChip(
                    label: Text(t),
                    selected: type == t,
                    onSelected: (_) => setS(() => type = t),
                    selectedColor: C.lime,
                    showCheckmark: false,
                    labelStyle: sans(13, color: type == t ? C.black : C.ink),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(controller: loc, onChanged: (_) => setS(() {}), decoration: dec('Location')),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(controller: pay, onChanged: (_) => setS(() {}), decoration: dec('Pay')),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('Minimum MSW level · ${lvl.round()}', style: sans(13, color: C.muted)),
            Slider(value: lvl, min: 1, max: 20, activeColor: _c, onChanged: (v) => setS(() => lvl = v)),
            PrimaryButton(
              'Publish to MSW Careers',
              bg: _c,
              onTap: () {
                postings.insert(0, Posting(role.text, type, loc.text, pay.text, 0, 0, true));
                Navigator.of(ctx).pop();
                toast(context, 'Published — 1,240 matching students notified 🚀');
              },
            ),
          ],
        );
      },
    ),
  );
}

class CompanyApplicants extends StatefulWidget {
  const CompanyApplicants({super.key});
  @override
  State<CompanyApplicants> createState() => _CompanyApplicantsState();
}

class _CompanyApplicantsState extends State<CompanyApplicants> {
  int _stage = 0;
  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    final list = candidates.where((c) => c.stage == _stage).toList();
    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 110),
      children: [
        DashHeader(role: _company, a: 'Applicant ', b: 'pipeline.', sub: 'Frontend Intern · move people forward', notes: _notes),
        const SizedBox(height: 16),
        ChipBar(items: [for (var i = 0; i < 4; i++) '${_stages[i]} · ${candidates.where((c) => c.stage == i).length}'], sel: _stage, onSel: (i) => setState(() => _stage = i), color: _c),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < 4; i++)
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  height: 5,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(color: i <= _stage ? _c : C.line2, borderRadius: BorderRadius.circular(5)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: Column(
            key: ValueKey('$_stage-${list.length}'),
            children: list.isEmpty
                ? [
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text('No one here yet ✨', style: sans(14, color: C.muted)),
                    ),
                  ]
                : [
                    for (var i = 0; i < list.length; i++)
                      Reveal(
                        delay: i * 70,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _CandidateTile(
                            list[i],
                            onTap: () => candidateSheet(context, list[i], onAdvance: () => setState(() => list[i].stage++)),
                            trailing: Row(
                              children: [
                                if (list[i].stage < 3)
                                  Expanded(
                                    child: PrimaryButton(
                                      'Move to ${_stages[list[i].stage + 1]}',
                                      bg: _c,
                                      icon: false,
                                      height: 44,
                                      onTap: () {
                                        setState(() => list[i].stage++);
                                        toast(context, '${list[i].name} → ${_stages[list[i].stage]}${list[i].stage == 3 ? ' 🎉' : ''}');
                                      },
                                    ),
                                  ),
                                if (list[i].stage < 3) const SizedBox(width: 8),
                                Expanded(
                                  child: PrimaryButton(
                                    list[i].stage == 3 ? 'Send offer letter' : 'View ID',
                                    bg: C.bg2,
                                    fg: C.ink,
                                    icon: false,
                                    height: 44,
                                    onTap: () => list[i].stage == 3
                                        ? toast(context, 'Offer letter sent to ${list[i].name} ✉️')
                                        : candidateSheet(context, list[i], onAdvance: () => setState(() => list[i].stage++)),
                                  ),
                                ),
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

class CompanyTasks extends StatefulWidget {
  const CompanyTasks({super.key});
  @override
  State<CompanyTasks> createState() => _CompanyTasksState();
}

class _CompanyTasksState extends State<CompanyTasks> {
  final _gone = <int>{};
  static const _subs = [
    ('Rhea Pillai', 'Accessibility audit of dashboard', 'figma.com/file/a11y-audit', 4500),
    ('Arjun Rao', 'Fix checkout bug on mobile web', 'github.com/arjun/checkout-fix', 3000),
    ('Sana Khan', 'Landing hero animation', 'codepen.io/sana/hero', 2000),
  ];
  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    final left = _subs.length - _gone.length;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 110),
      children: [
        DashHeader(role: _company, a: 'Tasks ', b: '& reviews.', sub: 'Paid tasks solved by students', notes: _notes),
        const SizedBox(height: 16),
        PrimaryButton('Allocate a new task', bg: C.tealD, onTap: () => allocateTaskSheet(context)),
        SectionTitle('To', b: 'review', action: '$left waiting'),
        if (left == 0)
          Card2(
            child: Center(
              child: Text('All caught up ✨', style: sans(14, color: C.muted)),
            ),
          ),
        for (var i = 0; i < _subs.length; i++)
          Removable(
            removed: _gone.contains(i),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: C.dark, borderRadius: BorderRadius.circular(22)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_subs[i].$2, style: serif(24, color: C.onDark, height: 1.05)),
                    const SizedBox(height: 4),
                    Text('${_subs[i].$1} · ${_subs[i].$3}', style: sans(12, color: Colors.white54)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            'Approve & pay ₹${fmtNum(_subs[i].$4)}',
                            bg: C.lime,
                            fg: C.black,
                            icon: false,
                            height: 44,
                            onTap: () {
                              setState(() => _gone.add(i));
                              toast(context, '₹${fmtNum(_subs[i].$4)} paid to ${_subs[i].$1} 💸');
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        PrimaryButton(
                          'Changes',
                          bg: Colors.white12,
                          fg: Colors.white,
                          icon: false,
                          height: 44,
                          onTap: () {
                            setState(() => _gone.add(i));
                            toast(context, 'Feedback sent to ${_subs[i].$1}');
                          },
                        ).sized(110),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SectionTitle('Allocated', b: 'tasks'),
        for (final t in const [
          ('Fix checkout bug on mobile web', '₹3,000', 'Aanya Sharma', 'In progress'),
          ('Write onboarding email sequence', '₹1,800', 'Open to all', 'Open'),
          ('Accessibility audit of dashboard', '₹4,500', 'Rhea Pillai', 'Submitted'),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card2(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.$1, style: sans(14, weight: FontWeight.w600, height: 1.2)),
                        Text('${t.$2} · ${t.$3}', style: sans(12, color: C.muted)),
                      ],
                    ),
                  ),
                  Tag(t.$4, bg: t.$4 == 'Open' ? C.sky : (t.$4 == 'Submitted' ? C.peach : C.teal)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

Future<void> allocateTaskSheet(BuildContext context) {
  final t = TextEditingController(text: 'Build a pricing page in Next.js');
  var reward = 2500.0;
  String? who;
  return showSheet(
    context,
    StatefulBuilder(
      builder: (ctx, setS) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Headline('Allocate a ', 'task.', size: 34, italicColor: C.tealD),
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
          Text('Reward · ₹${fmtNum(reward.round())}', style: sans(13, color: C.muted)),
          Slider(value: reward, min: 500, max: 10000, divisions: 19, activeColor: C.tealD, onChanged: (v) => setS(() => reward = v)),
          Text('ASSIGN TO', style: mono(10)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final n in [null, ...candidates.map((c) => c.name).take(5)])
                ChoiceChip(
                  label: Text(n ?? 'Open to all'),
                  selected: who == n,
                  onSelected: (_) => setS(() => who = n),
                  selectedColor: C.lime,
                  showCheckmark: false,
                  labelStyle: sans(13, color: who == n ? C.black : C.ink),
                ),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            'Allocate task',
            bg: C.tealD,
            onTap: () {
              Navigator.of(ctx).pop();
              toast(context, who == null ? 'Task is live for all students ⚡' : 'Assigned to $who ⚡');
            },
          ),
        ],
      ),
    ),
  );
}

class CompanyAccount extends StatelessWidget {
  const CompanyAccount({super.key});
  @override
  Widget build(BuildContext context) => AccountTab(
    role: _company,
    name: 'Lumen Labs',
    sub: 'Hiring team · Bengaluru',
    initials: 'L',
    extra: [
      const SizedBox(height: 18),
      Text('PLAN', style: mono(10)),
      const SizedBox(height: 8),
      Card2(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hiring Pro', style: serif(28)),
                  Text('Unlimited postings · talent search', style: sans(12, color: C.muted)),
                ],
              ),
            ),
            Tag('Active', bg: C.teal),
          ],
        ),
      ),
    ],
  );
}
