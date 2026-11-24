import 'package:flutter/material.dart';

import '../../api.dart';
import '../../data.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';
import '../details.dart';
import '../post.dart';
import 'common.dart';

/// ===================== COMPANY (Lumen Labs) =====================
final _company = roles[1];
Color get _c => _company.color;
const _me = 'Lumen Labs';
const _myColor = Color(0xFFFF7A59);
const _notes = [
  (Icons.people_alt_outlined, '23 new applicants for Frontend Developer Intern'),
  (Icons.inventory_2_outlined, 'Rohan Kapoor submitted the accessibility audit'),
  (Icons.trending_up_rounded, 'Your posting is trending at IIT Delhi'),
];

class Candidate {
  Candidate(this.p, this.stage);
  final Person p;
  int stage; // 0 applied · 1 shortlisted · 2 interview · 3 hired
}

final candidates = [
  Candidate(people['Meera Joshi']!, 0),
  Candidate(Person('Arjun Rao', 'DTU', 'B.Tech IT · 3rd year', 'Next.js developer', 'Ships fast, writes tests.', ['Next.js', 'Node'], const [C.tealD, C.sky], level: 12, iq: 118, gh: 84), 0),
  Candidate(
    Person('Dev Shah', 'VIT', 'B.Tech CSE · 2nd year', 'Frontend learner', 'MSW Labs Day 18.', ['HTML', 'CSS', 'JS'], const [Color(0xFF6C5CE7), Color(0xFF00D2D3)], level: 8, iq: 112, gh: 66),
    0,
  ),
  Candidate(people['Rohan Kapoor']!, 1),
  Candidate(people['Sana Khan']!, 1),
  Candidate(me, 2),
  Candidate(Person('Rhea Pillai', 'IIIT Hyderabad', 'B.Tech CSE · 4th year', 'Systems engineer', 'Rust & Go.', ['Rust', 'Go'], const [C.lime, C.tealD], level: 18, iq: 130, gh: 93), 3),
];
const _stages = ['Applied', 'Shortlisted', 'Interview', 'Hired'];

/* ───────────── Home ───────────── */

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
              child: QuickAction(Icons.add_rounded, 'Post a job\nor internship', color: _c, onTap: () => Navigator.of(context).push(fadeRoute(const PostOpportunityScreen()))),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: QuickAction(Icons.code_rounded, 'Post a\npaid task', color: C.tealD, onTap: () => Navigator.of(context).push(fadeRoute(const PostTaskScreen()))),
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
            StatTile(label: 'Applicants', value: 273, accent: _c, delta: '41% this week', spark: const [20, 34, 30, 55, 61, 80, 120, 140, 190, 273], icon: Icons.people_alt_outlined),
            StatTile(
              label: 'Open roles',
              value: opportunities.where((o) => o.company == _me && o.live).length.toDouble(),
              accent: _c,
              delta: 'Live now',
              spark: const [1, 1, 2, 2, 2, 3, 3],
              icon: Icons.work_outline_rounded,
            ),
            StatTile(
              label: 'Tasks live',
              value: ctasks.where((t) => t.company == _me).length.toDouble(),
              accent: _c,
              delta: 'Paid on approval',
              spark: const [2, 3, 3, 4, 4, 5, 6],
              icon: Icons.task_alt_rounded,
            ),
            StatTile(label: 'Days to hire', value: 9, suffix: 'd', accent: _c, delta: '3d faster', spark: const [21, 18, 17, 15, 14, 12, 11, 9], icon: Icons.timer_outlined),
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
      ],
    );
  }
}

/* ───────────── Jobs ───────────── */

class CompanyJobs extends StatefulWidget {
  const CompanyJobs({super.key});
  @override
  State<CompanyJobs> createState() => _CompanyJobsState();
}

class _CompanyJobsState extends State<CompanyJobs> {
  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    final mine = opportunities.where((o) => o.company == _me).toList();
    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 110),
      children: [
        DashHeader(role: _company, a: 'Jobs ', b: '& internships.', sub: '${mine.where((p) => p.live).length} live · ${mine.fold<int>(0, (a, p) => a + p.applicants)} applicants', notes: _notes),
        const SizedBox(height: 16),
        PrimaryButton(
          'Post a job or internship',
          bg: _c,
          onTap: () async {
            await Navigator.of(context).push(fadeRoute(const PostOpportunityScreen()));
            setState(() {});
          },
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < mine.length; i++)
          Reveal(
            delay: i * 80,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Pressable(
                scale: 0.98,
                onTap: () => Navigator.of(context).push(fadeRoute(OpportunityDetailScreen(o: mine[i]))),
                child: Card2(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Tag(mine[i].internship ? 'Internship' : 'Job', bg: mine[i].internship ? C.sky : C.lime),
                          const SizedBox(width: 6),
                          Tag(mine[i].workMode),
                          const Spacer(),
                          Switch.adaptive(
                            value: mine[i].live,
                            activeTrackColor: _c,
                            onChanged: (v) {
                              setState(() => mine[i].live = v);
                              Api.setLive(mine[i]);
                              toast(context, '${mine[i].title} ${v ? 'is live' : 'paused'}');
                            },
                          ),
                        ],
                      ),
                      Text(mine[i].title, style: serif(26, height: 1.05)),
                      Text('${mine[i].pay} · ${mine[i].duration} · apply by ${mine[i].applyBy}', style: sans(12, color: C.muted)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _mini('Applicants', '${mine[i].applicants}'),
                          _mini('Views', fmtNum(mine[i].views)),
                          _mini('Openings', '${mine[i].openings}'),
                          Text(
                            'Preview',
                            style: sans(13, weight: FontWeight.w600, color: _c),
                          ),
                          Icon(Icons.chevron_right_rounded, color: _c),
                        ],
                      ),
                    ],
                  ),
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

/// Unstop-style detailed posting form. Students see exactly these details.
class PostOpportunityScreen extends StatefulWidget {
  const PostOpportunityScreen({super.key});
  @override
  State<PostOpportunityScreen> createState() => _PostOpportunityScreenState();
}

class _PostOpportunityScreenState extends State<PostOpportunityScreen> {
  String type = 'Internship', mode = 'Remote', exp = 'Freshers welcome', payType = 'Fixed';
  final title = TextEditingController(text: 'Mobile Developer Intern');
  final location = TextEditingController(text: 'Bengaluru');
  final openings = TextEditingController(text: '2');
  final pay = TextEditingController(text: '₹35,000 / month');
  final duration = TextEditingController(text: '3 months');
  final start = TextEditingController(text: 'Jan 15, 2027');
  final deadline = TextEditingController(text: 'Dec 31, 2026');
  final about = TextEditingController(text: 'Build Lumen’s companion app in Flutter alongside our mobile lead.');
  final skills = ['Flutter', 'Dart', 'Firebase'];
  final eligibility = ['B.Tech / B.E. / BCA / MCA', 'Batch 2026, 2027'];
  final resp = ['Build screens from Figma in Flutter', 'Integrate REST APIs and Firebase', 'Write widget tests'];
  final perks = <String>['Certificate', 'Pre-placement offer'];
  final rounds = ['Profile screening (MSW ID)', 'Take-home task', 'Technical interview'];
  static const _perkOptions = ['Certificate', 'Pre-placement offer', 'Flexible hours', 'Letter of recommendation', 'Health insurance', 'Free meals', 'Learning budget', 'ESOPs'];

  void _r() => setState(() {});

  void _publish() {
    opportunities.insert(
      0,
      Opportunity(
        title: title.text,
        company: _me,
        color: _myColor,
        internship: type == 'Internship',
        workMode: mode,
        location: mode == 'Remote' ? '${location.text} (Remote)' : location.text,
        pay: payType == 'Unpaid' ? 'Unpaid' : pay.text,
        duration: type == 'Internship' ? duration.text : 'Full-time',
        startDate: start.text,
        applyBy: deadline.text,
        openings: int.tryParse(openings.text) ?? 1,
        experience: exp,
        skills: List.of(skills),
        eligibility: List.of(eligibility),
        about: about.text,
        responsibilities: List.of(resp),
        perks: List.of(perks),
        rounds: List.of(rounds),
        aboutCompany: 'Lumen Labs is a Series A design-tooling startup with 60 people across Bengaluru and Berlin.',
      ),
    );
    Navigator.of(context).pop();
    Api.createOpportunity(opportunities.first);
    toast(context, 'Published to MSW Careers. Matching students notified.');
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, pad.top + 8, 16, 8),
            child: Row(
              children: [
                const BackBtn(),
                const SizedBox(width: 12),
                Text('New opportunity', style: serif(28)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              children: [
                Text('LIVE PREVIEW — HOW STUDENTS SEE IT', style: mono(9.5)),
                const SizedBox(height: 8),
                _preview(),
                const SizedBox(height: 16),
                FormSection(
                  1,
                  'Basics',
                  children: [
                    PillSelect(label: 'Opportunity type', options: const ['Internship', 'Job'], value: type, onChanged: (v) => setState(() => type = v)),
                    TextField(
                      controller: title,
                      onChanged: (_) => _r(),
                      decoration: fieldDec('Role title', icon: Icons.badge_outlined),
                    ),
                    PillSelect(label: 'Work mode', options: const ['Remote', 'On-site', 'Hybrid'], value: mode, onChanged: (v) => setState(() => mode = v)),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: location,
                            onChanged: (_) => _r(),
                            decoration: fieldDec('City', icon: Icons.place_outlined),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: TextField(controller: openings, keyboardType: TextInputType.number, onChanged: (_) => _r(), decoration: fieldDec('Openings')),
                        ),
                      ],
                    ),
                  ],
                ),
                FormSection(
                  2,
                  'Compensation & dates',
                  children: [
                    PillSelect(
                      label: type == 'Internship' ? 'Stipend' : 'Salary',
                      options: const ['Fixed', 'Performance-based', 'Unpaid'],
                      value: payType,
                      onChanged: (v) => setState(() => payType = v),
                    ),
                    if (payType != 'Unpaid')
                      TextField(
                        controller: pay,
                        onChanged: (_) => _r(),
                        decoration: fieldDec(type == 'Internship' ? 'Stipend (e.g. ₹30,000 / month)' : 'CTC (e.g. ₹12 – 16 LPA)', icon: Icons.payments_outlined),
                      ),
                    if (type == 'Internship')
                      TextField(
                        controller: duration,
                        onChanged: (_) => _r(),
                        decoration: fieldDec('Duration', icon: Icons.schedule_outlined),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(controller: start, onChanged: (_) => _r(), decoration: fieldDec('Start date')),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(controller: deadline, onChanged: (_) => _r(), decoration: fieldDec('Apply by')),
                        ),
                      ],
                    ),
                  ],
                ),
                FormSection(
                  3,
                  'Who can apply',
                  children: [
                    PillSelect(label: 'Experience', options: const ['Freshers welcome', '0 – 1 years', '1 – 3 years', '3+ years'], value: exp, onChanged: (v) => setState(() => exp = v)),
                    Text('SKILLS REQUIRED', style: mono(9.5)),
                    ChipsEditor(items: skills, hint: 'Add a skill and press +', onChanged: _r),
                    Text('ELIGIBILITY', style: mono(9.5)),
                    ChipsEditor(items: eligibility, hint: 'Degree, batch, CGPA, MSW level…', numbered: true, onChanged: _r),
                  ],
                ),
                FormSection(
                  4,
                  'About the role',
                  children: [
                    TextField(controller: about, maxLines: 4, onChanged: (_) => _r(), decoration: fieldDec('Job description')),
                    Text('RESPONSIBILITIES', style: mono(9.5)),
                    ChipsEditor(items: resp, hint: 'Add a responsibility', numbered: true, onChanged: _r),
                  ],
                ),
                FormSection(
                  5,
                  'Perks',
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final p in _perkOptions)
                          FilterChip(
                            label: Text(p),
                            selected: perks.contains(p),
                            onSelected: (v) => setState(() => v ? perks.add(p) : perks.remove(p)),
                            showCheckmark: false,
                            selectedColor: C.ink,
                            labelStyle: sans(13, color: perks.contains(p) ? C.onInk : C.ink),
                          ),
                      ],
                    ),
                  ],
                ),
                FormSection(
                  6,
                  'Selection process',
                  children: [ChipsEditor(items: rounds, hint: 'Add a round (e.g. Coding test)', numbered: true, onChanged: _r)],
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
            child: PrimaryButton('Publish to MSW Careers', bg: _c, onTap: _publish),
          ),
        ],
      ),
    );
  }

  Widget _preview() => Card2(
    color: C.card,
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
              decoration: BoxDecoration(color: _myColor, borderRadius: BorderRadius.circular(13)),
              child: Text(
                'L',
                style: sans(18, color: Colors.white, weight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title.text, style: sans(15, weight: FontWeight.w600, height: 1.2)),
                  Text('$_me · $mode · ${location.text}', style: sans(12, color: C.muted)),
                ],
              ),
            ),
            Tag(type, bg: type == 'Internship' ? C.sky : C.lime),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(spacing: 6, runSpacing: 6, children: [for (final s in skills.take(4)) Tag(s)]),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.payments_outlined, size: 16, color: C.muted),
            const SizedBox(width: 6),
            Text(payType == 'Unpaid' ? 'Unpaid' : pay.text, style: sans(13, weight: FontWeight.w700)),
            const Spacer(),
            Text('Apply by ${deadline.text}', style: sans(12, color: C.muted)),
          ],
        ),
      ],
    ),
  );
}

/* ───────────── Applicants ───────────── */

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
        DashHeader(role: _company, a: 'Applicant ', b: 'pipeline.', sub: 'Frontend Developer Intern', notes: _notes),
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
        if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Text('No one here yet', style: sans(14, color: C.muted)),
            ),
          ),
        for (var i = 0; i < list.length; i++)
          Reveal(
            delay: i * 70,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card2(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AuthorRow(
                      person: list[i].p,
                      meta: '${list[i].p.college} · ${list[i].p.course}',
                      trailing: Tag('Lvl ${list[i].p.level}', bg: C.lime),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final s in list[i].p.skills) Tag(s),
                        Tag('IQ ${list[i].p.iq}', bg: C.lilac),
                        Tag('GitHub ${list[i].p.gh}', bg: C.teal),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
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
                                toast(context, '${list[i].p.name} moved to ${_stages[list[i].stage]}');
                              },
                            ),
                          ),
                        if (list[i].stage < 3) const SizedBox(width: 8),
                        Expanded(
                          child: PrimaryButton(
                            list[i].stage == 3 ? 'Send offer letter' : 'View profile',
                            bg: C.bg2,
                            fg: C.ink,
                            icon: false,
                            height: 44,
                            onTap: () => list[i].stage == 3 ? toast(context, 'Offer letter sent to ${list[i].p.name}') : Navigator.of(context).push(fadeRoute(PersonScreen(person: list[i].p))),
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
    );
  }
}

/* ───────────── Tasks ───────────── */

class CompanyTasks extends StatefulWidget {
  const CompanyTasks({super.key});
  @override
  State<CompanyTasks> createState() => _CompanyTasksState();
}

class _CompanyTasksState extends State<CompanyTasks> {
  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    final mine = ctasks.where((t) => t.company == _me).toList();
    final waiting = mine.fold<int>(0, (a, t) => a + t.submissions.where((s) => s.status == 'In review').length);
    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 110),
      children: [
        DashHeader(role: _company, a: 'Tasks ', b: '& reviews.', sub: '$waiting submission${waiting == 1 ? '' : 's'} waiting for review', notes: _notes),
        const SizedBox(height: 16),
        PrimaryButton(
          'Post a paid task',
          bg: C.tealD,
          onTap: () async {
            await Navigator.of(context).push(fadeRoute(const PostTaskScreen()));
            setState(() {});
          },
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < mine.length; i++)
          Reveal(
            delay: i * 80,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Pressable(
                scale: 0.98,
                onTap: () async {
                  await Navigator.of(context).push(fadeRoute(TaskReviewScreen(t: mine[i])));
                  setState(() {});
                },
                child: Card2(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.code_rounded, size: 16, color: C.muted),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(mine[i].repo, style: mono(10), overflow: TextOverflow.ellipsis),
                          ),
                          Text(
                            '₹${fmtNum(mine[i].reward)}',
                            style: sans(14, weight: FontWeight.w700, color: C.tealD),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(mine[i].title, style: serif(24, height: 1.05)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Tag('${mine[i].submissions.length} submissions'),
                          const SizedBox(width: 6),
                          if (mine[i].submissions.any((s) => s.status == 'In review')) Tag('${mine[i].submissions.where((s) => s.status == 'In review').length} to review', bg: C.peach),
                          const Spacer(),
                          Text(
                            'Review',
                            style: sans(13, weight: FontWeight.w600, color: C.tealD),
                          ),
                          Icon(Icons.chevron_right_rounded, color: C.tealD),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Company posts a task tied to a GitHub repo.
class PostTaskScreen extends StatefulWidget {
  const PostTaskScreen({super.key});
  @override
  State<PostTaskScreen> createState() => _PostTaskScreenState();
}

class _PostTaskScreenState extends State<PostTaskScreen> {
  final title = TextEditingController(text: 'Add dark mode to the marketing site');
  final repo = TextEditingController(text: 'github.com/lumen-labs/marketing-site');
  final desc = TextEditingController(text: 'Add a light / dark toggle that respects the system setting and remembers the user’s choice.');
  final stack = ['Next.js', 'Tailwind CSS'];
  final deliverables = ['Pull request against main', 'Screenshots of both themes'];
  final acceptance = ['No flash of the wrong theme on load', 'Lighthouse scores unchanged'];
  double reward = 3500, days = 5;
  String level = 'Medium';

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, pad.top + 8, 16, 8),
            child: Row(
              children: [
                const BackBtn(),
                const SizedBox(width: 12),
                Text('New paid task', style: serif(28)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              children: [
                FormSection(
                  1,
                  'The task',
                  children: [
                    TextField(
                      controller: title,
                      decoration: fieldDec('Task title', icon: Icons.title_rounded),
                    ),
                    TextField(
                      controller: repo,
                      decoration: fieldDec('GitHub repository', icon: Icons.code_rounded, hint: 'github.com/org/repo'),
                    ),
                    TextField(controller: desc, maxLines: 4, decoration: fieldDec('Brief — what needs to be done and why')),
                  ],
                ),
                FormSection(
                  2,
                  'Scope',
                  children: [
                    Text('TECH STACK', style: mono(9.5)),
                    ChipsEditor(items: stack, hint: 'Add a technology'),
                    Text('DELIVERABLES', style: mono(9.5)),
                    ChipsEditor(items: deliverables, hint: 'e.g. PR link, screenshots, Loom video', numbered: true),
                    Text('ACCEPTANCE CRITERIA', style: mono(9.5)),
                    ChipsEditor(items: acceptance, hint: 'How will you judge it?', numbered: true),
                  ],
                ),
                FormSection(
                  3,
                  'Reward & deadline',
                  children: [
                    Text('Reward · ₹${fmtNum(reward.round())}', style: sans(14, weight: FontWeight.w600)),
                    Slider(value: reward, min: 500, max: 20000, divisions: 39, activeColor: C.tealD, onChanged: (v) => setState(() => reward = v)),
                    Text('Deadline · ${days.round()} days', style: sans(14, weight: FontWeight.w600)),
                    Slider(value: days, min: 1, max: 21, divisions: 20, activeColor: C.tealD, onChanged: (v) => setState(() => days = v)),
                    PillSelect(label: 'Difficulty', options: const ['Easy', 'Medium', 'Hard'], value: level, onChanged: (v) => setState(() => level = v)),
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
            child: PrimaryButton(
              'Publish task · ₹${fmtNum(reward.round())}',
              bg: C.tealD,
              onTap: () {
                ctasks.insert(
                  0,
                  CTask(
                    title: title.text,
                    company: _me,
                    color: _myColor,
                    reward: reward.round(),
                    days: days.round(),
                    level: ['Easy', 'Medium', 'Hard'].indexOf(level) + 1,
                    stack: List.of(stack),
                    repo: repo.text,
                    description: desc.text,
                    deliverables: List.of(deliverables),
                    acceptance: List.of(acceptance),
                  ),
                );
                Navigator.of(context).pop();
                Api.createTask(ctasks.first);
                toast(context, 'Task live for all students');
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Review submissions: PR / repo, demo, notes and screenshots → approve & pay or request changes.
class TaskReviewScreen extends StatefulWidget {
  const TaskReviewScreen({super.key, required this.t});
  final CTask t;
  @override
  State<TaskReviewScreen> createState() => _TaskReviewScreenState();
}

class _TaskReviewScreenState extends State<TaskReviewScreen> {
  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final pad = MediaQuery.of(context).padding;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, pad.top + 8, 20, pad.bottom + 30),
        children: [
          Row(
            children: [
              const BackBtn(),
              const Spacer(),
              Tag('₹${fmtNum(t.reward)}', bg: C.teal),
            ],
          ),
          const SizedBox(height: 14),
          Text(t.title, style: serif(34, height: 1.05)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.code_rounded, size: 16, color: C.muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(t.repo, style: mono(11, color: C.ink)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(t.description, style: sans(14, color: C.ink2, height: 1.5)),
          DSection('Acceptance criteria', child: Bullets(t.acceptance)),
          DSection(
            'Submissions · ${t.submissions.length}',
            child: t.submissions.isEmpty
                ? Text('No submissions yet. Students who take the task will appear here.', style: sans(14, color: C.muted))
                : Column(
                    children: [
                      for (final s in t.submissions)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: C.card,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: C.line),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AuthorRow(
                                person: s.student,
                                meta: '${s.student.college} · Level ${s.student.level}',
                                trailing: Tag(s.status, bg: s.status == 'Approved' ? C.teal : (s.status == 'In review' ? C.peach : C.lilac)),
                              ),
                              const SizedBox(height: 12),
                              _link(Icons.merge_type_rounded, 'Pull request', s.repo),
                              if (s.demo.isNotEmpty) _link(Icons.play_circle_outline_rounded, 'Live demo', s.demo),
                              const SizedBox(height: 6),
                              Text(s.notes, style: sans(14, height: 1.45)),
                              if (s.shots.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text('SCREENSHOTS', style: mono(9.5)),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 132,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      for (final sh in s.shots)
                                        Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: GestureDetector(
                                            onTap: () => showDialog(
                                              context: context,
                                              builder: (_) => Dialog(backgroundColor: Colors.transparent, child: MockShot(sh, w: 300, h: 420)),
                                            ),
                                            child: MockShot(sh),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                              if (s.status == 'In review') ...[
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: PrimaryButton(
                                        'Approve & pay ₹${fmtNum(t.reward)}',
                                        bg: C.tealD,
                                        icon: false,
                                        height: 46,
                                        onTap: () {
                                          setState(() => s.status = 'Approved');
                                          Api.review(s);
                                          toast(context, '₹${fmtNum(t.reward)} paid to ${s.student.name}');
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    PrimaryButton('Changes', bg: C.bg2, fg: C.ink, icon: false, height: 46, onTap: () => _changes(s)).sized(110),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _link(IconData ic, String label, String url) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Pressable(
      onTap: () => toast(context, 'Opening $url'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: C.bg2, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(ic, size: 18, color: C.ink),
            const SizedBox(width: 8),
            Text(label, style: sans(12, color: C.muted)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                url,
                style: mono(10.5, color: C.ink),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.open_in_new_rounded, size: 16, color: C.muted),
          ],
        ),
      ),
    ),
  );

  void _changes(Submission s) {
    final note = TextEditingController();
    sheet(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Headline('Request ', 'changes.', size: 32),
          const SizedBox(height: 12),
          TextField(controller: note, maxLines: 4, decoration: fieldDec('What should ${s.student.name.split(' ').first} fix?')),
          const SizedBox(height: 14),
          PrimaryButton(
            'Send feedback',
            onTap: () {
              Navigator.of(context).pop();
              setState(() => s.status = 'Changes requested');
              Api.review(s);
              toast(context, 'Feedback sent to ${s.student.name}');
            },
          ),
        ],
      ),
    );
  }
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
            const Tag('Active', bg: C.teal),
          ],
        ),
      ),
    ],
  );
}
