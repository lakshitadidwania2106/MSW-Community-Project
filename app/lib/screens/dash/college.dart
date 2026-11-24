import 'package:flutter/material.dart';

import '../../data.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';
import 'common.dart';

/// ===================== COLLEGE (IIT Bombay E-Cell) =====================
final _col = roles[3];
Color get _c => _col.color;
const _notes = [('🎉', 'E-Summit Hackathon hit 472 registrations'), ('🎓', '4 students waiting for verification'), ('✅', 'MSW approved your event listing')];

const _themes = {
  'Indigo': [Color(0xFF1B1464), Color(0xFF6C5CE7), Color(0xFF00D2D3)],
  'Sunset': [Color(0xFFFF7A59), Color(0xFFFFD166), Color(0xFFEF476F)],
  'Forest': [Color(0xFF0F3D2E), Color(0xFF2F8F7A), Color(0xFFD4F56B)],
  'Neon': [Color(0xFF3A0CA3), Color(0xFFF72585), Color(0xFF4CC9F0)],
};

class CEvent {
  CEvent(this.name, this.date, this.mode, this.prize, this.seats, this.reg, this.status, this.theme);
  final String name, date, mode, prize, theme;
  final int seats, reg;
  String status;
}

final cEvents = [
  CEvent('E-Summit Hackathon', 'Jan 18–19', 'In person', '₹3,00,000', 600, 472, 'Live', 'Indigo'),
  CEvent('Design Sprint', 'Apr 02', 'In person', '₹1,50,000', 200, 188, 'Live', 'Sunset'),
  CEvent('Founders Fireside', 'Feb 07', 'Online', '—', 300, 0, 'Draft', 'Forest'),
  CEvent('Code Relay ’25', 'Oct 12', 'In person', '₹80,000', 250, 250, 'Completed', 'Neon'),
];

Widget poster(String name, String date, String mode, String prize, int seats, String theme, {double h = 200, String? status}) {
  final t = _themes[theme]!;
  return Container(
    height: h,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: RadialGradient(center: const Alignment(0.8, -0.8), radius: 1.3, colors: [t[1], t[0]]),
    ),
    clipBehavior: Clip.antiAlias,
    child: Stack(
      children: [
        Positioned(
          right: -30,
          bottom: -40,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(color: t[2].withValues(alpha: 0.8), shape: BoxShape.circle),
          ),
        ),
        Positioned(
          right: 60,
          top: 10,
          child: Transform.rotate(
            angle: 0.5,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(99)),
              child: Text(
                status ?? 'IIT Bombay E-Cell × MSW',
                style: sans(11, color: Colors.white, weight: FontWeight.w600),
              ),
            ),
            const Spacer(),
            Text('$date · $mode'.toUpperCase(), style: mono(10, color: Colors.white70)),
            Text(
              name.isEmpty ? 'Event name' : name,
              style: serif(36, color: Colors.white, height: 1.0),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  prize,
                  style: sans(14, color: Colors.white, weight: FontWeight.w700),
                ),
                const Spacer(),
                Text('$seats seats', style: sans(12, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

class CollegeHome extends StatelessWidget {
  const CollegeHome({super.key, required this.go});
  final ValueChanged<int> go;
  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 110),
      children: [
        DashHeader(role: _col, a: 'Your campus, ', b: 'on the map.', sub: 'IIT Bombay E-Cell · verified organiser', notes: _notes),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: QuickAction(Icons.add_rounded, 'Host an\nevent', color: _c, onTap: () => hostEventSheet(context)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: QuickAction(Icons.verified_rounded, 'Verify\nstudents', color: C.tealD, onTap: () => go(3)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: QuickAction(Icons.gavel_rounded, 'Judge\nentries', color: C.lime, dark: true, onTap: () => go(2)),
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
            StatTile(label: 'Registrations', value: 3860, accent: _c, delta: '28% vs last sem', spark: const [300, 520, 800, 1300, 2100, 2900, 3860], icon: Icons.how_to_reg_rounded),
            StatTile(label: 'Events hosted', value: 14, accent: _c, delta: '3 this sem', spark: const [2, 4, 5, 7, 9, 11, 14], icon: Icons.emoji_events_rounded),
            StatTile(label: 'Verified', value: 1240, accent: _c, delta: '86 this week', spark: const [400, 600, 750, 900, 1050, 1180, 1240], icon: Icons.verified_rounded),
            StatTile(label: 'Placed via MSW', value: 63, suffix: '%', accent: _c, delta: '9 pts', spark: const [32, 38, 44, 49, 55, 58, 63], icon: Icons.work_rounded),
          ],
        ),
        SectionTitle('Live', b: 'now', action: 'All events →', onAction: () => go(1)),
        poster(cEvents[0].name, cEvents[0].date, cEvents[0].mode, cEvents[0].prize, cEvents[0].seats, cEvents[0].theme, status: '● LIVE · 472 / 600 registered'),
        const SizedBox(height: 12),
        ChartCard(
          a: 'Registrations',
          b: 'by week',
          series: [
            ('E-Summit', _c, const [40, 62, 58, 110, 145, 190, 240, 310, 290, 380, 420, 472]),
          ],
          labels: const ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7', 'W8', 'W9', 'W10', 'W11', 'Now'],
        ),
        const SectionTitle('Participants', b: 'by branch'),
        Card2(
          child: Donut([('CSE', 46, _c), ('EE', 18, C.tealD), ('Design', 14, const Color(0xFF9B87F5)), ('Others', 22, C.lime)], center: '472', sub: 'registered'),
        ),
      ],
    );
  }
}

class CollegeEvents extends StatefulWidget {
  const CollegeEvents({super.key});
  @override
  State<CollegeEvents> createState() => _CollegeEventsState();
}

class _CollegeEventsState extends State<CollegeEvents> {
  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 110),
      children: [
        DashHeader(role: _col, a: 'Hackathons ', b: '& events.', notes: _notes),
        const SizedBox(height: 16),
        PrimaryButton(
          'Host a hackathon / event',
          bg: _c,
          onTap: () async {
            await hostEventSheet(context);
            setState(() {});
          },
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < cEvents.length; i++)
          Reveal(
            delay: i * 80,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  poster(cEvents[i].name, cEvents[i].date, cEvents[i].mode, cEvents[i].prize, cEvents[i].seats, cEvents[i].theme, h: 170, status: cEvents[i].status),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${cEvents[i].reg} / ${cEvents[i].seats} registered', style: sans(13, weight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(value: cEvents[i].reg / cEvents[i].seats, minHeight: 7, backgroundColor: C.bg2, valueColor: AlwaysStoppedAnimation(_c)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (cEvents[i].status == 'Draft')
                        PrimaryButton(
                          'Publish',
                          bg: _c,
                          icon: false,
                          height: 42,
                          onTap: () {
                            setState(() => cEvents[i].status = 'Live');
                            toast(context, '${cEvents[i].name} is live 🚀');
                          },
                        ).sized(110)
                      else
                        PrimaryButton('Share', bg: C.bg2, fg: C.ink, icon: false, height: 42, onTap: () => toast(context, 'Registration link copied')).sized(100),
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

Future<void> hostEventSheet(BuildContext context) {
  final name = TextEditingController(text: 'Build for Bharat');
  var date = 'Mar 08–09', mode = 'In person', theme = 'Indigo';
  var seats = 400.0;
  return showSheet(
    context,
    StatefulBuilder(
      builder: (ctx, setS) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Headline('Host a ', 'hackathon.', size: 34, italicColor: _c),
          const SizedBox(height: 12),
          poster(name.text, date, mode, '₹2,00,000', seats.round(), theme, h: 190),
          const SizedBox(height: 14),
          TextField(
            controller: name,
            onChanged: (_) => setS(() {}),
            decoration: InputDecoration(
              labelText: 'Event name',
              filled: true,
              fillColor: C.card,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              for (final m in const ['In person', 'Online', 'Hybrid'])
                ChoiceChip(
                  label: Text(m),
                  selected: mode == m,
                  onSelected: (_) => setS(() => mode = m),
                  selectedColor: C.lime,
                  showCheckmark: false,
                  labelStyle: sans(13, color: mode == m ? C.black : C.ink),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text('POSTER THEME', style: mono(10)),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final t in _themes.keys)
                GestureDetector(
                  onTap: () => setS(() => theme = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 10),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [_themes[t]![0], _themes[t]![1]]),
                      border: Border.all(color: theme == t ? C.ink : Colors.transparent, width: 3),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Seats · ${seats.round()}', style: sans(13, color: C.muted)),
          Slider(value: seats, min: 50, max: 1000, divisions: 19, activeColor: _c, onChanged: (v) => setS(() => seats = v)),
          PrimaryButton(
            'Publish event',
            bg: _c,
            onTap: () {
              cEvents.insert(0, CEvent(name.text, date, mode, '₹2,00,000', seats.round(), 0, 'Live', theme));
              Navigator.of(ctx).pop();
              toast(context, 'Published — 12,400 students notified 🚀');
            },
          ),
        ],
      ),
    ),
  );
}

class CollegeJudging extends StatefulWidget {
  const CollegeJudging({super.key});
  @override
  State<CollegeJudging> createState() => _CollegeJudgingState();
}

class _CollegeJudgingState extends State<CollegeJudging> {
  final _subs = [
    ('Byte Me', 'Krishi Lite — soil reports over SMS', [8.0, 7.0, 9.0]),
    ('Ctrl Alt Elite', 'Campus Pulse — anonymous mental-health check-ins', [9.0, 8.0, 8.0]),
    ('Null Pointers', 'Queue-less — OPD tokens on WhatsApp', [7.0, 8.0, 7.0]),
  ];
  bool _locked = false;
  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    final ranked = [..._subs]..sort((a, b) => (b.$3.reduce((x, y) => x + y)).compareTo(a.$3.reduce((x, y) => x + y)));
    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 110),
      children: [
        DashHeader(role: _col, a: 'Judging ', b: 'panel.', sub: 'E-Summit Hackathon · finals', notes: _notes),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: C.dark, borderRadius: BorderRadius.circular(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('LIVE LEADERBOARD', style: mono(10, color: C.lime)),
              const SizedBox(height: 10),
              for (var i = 0; i < ranked.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: i == 0 ? 0.12 : 0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Text(['🥇', '🥈', '🥉'][i], style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          ranked[i].$1,
                          style: sans(15, color: C.onDark, weight: FontWeight.w600),
                        ),
                      ),
                      Text(ranked[i].$3.reduce((x, y) => x + y).round().toString(), style: serif(28, color: C.onDark)),
                    ],
                  ),
                ),
              const SizedBox(height: 6),
              PrimaryButton(
                _locked ? 'Winners announced ✓' : 'Lock scores & announce',
                bg: C.lime,
                fg: C.black,
                icon: false,
                height: 48,
                onTap: () {
                  setState(() => _locked = true);
                  toast(context, 'Winners announced — certificates issued 🏆');
                },
              ),
            ],
          ),
        ),
        const SectionTitle('Score', b: 'entries'),
        for (final s in _subs)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card2(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(s.$1, style: serif(26))),
                      Text('${s.$3.reduce((x, y) => x + y).round()}', style: serif(30, color: _c)),
                    ],
                  ),
                  Text(s.$2, style: sans(13, color: C.muted)),
                  const SizedBox(height: 8),
                  for (var j = 0; j < 3; j++)
                    Row(
                      children: [
                        SizedBox(
                          width: 82,
                          child: Text(['Innovation', 'Execution', 'Impact'][j], style: sans(12, color: C.muted)),
                        ),
                        Expanded(
                          child: Slider(value: s.$3[j], min: 0, max: 10, divisions: 10, activeColor: _c, onChanged: _locked ? null : (v) => setState(() => s.$3[j] = v)),
                        ),
                        SizedBox(
                          width: 22,
                          child: Text('${s.$3[j].round()}', style: sans(13, weight: FontWeight.w700)),
                        ),
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

class CollegeStudents extends StatefulWidget {
  const CollegeStudents({super.key});
  @override
  State<CollegeStudents> createState() => _CollegeStudentsState();
}

class _CollegeStudentsState extends State<CollegeStudents> {
  int _seg = 0;
  final _done = <int, bool>{};
  final _checked = <String>{'Null Pointers', 'Stack Smashers'};
  static const _queue = [('Zoya Ansari', 'B.Tech CSE · 2nd year'), ('Omkar Patil', 'M.Tech EE · 1st year'), ('Neha Rao', 'B.Des · 3rd year'), ('Varun Tiwari', 'B.Tech ME · 4th year')];
  static const _teams = [
    ('Byte Me', 'Aanya S., Rohan K., Dev S.'),
    ('Null Pointers', 'Meera J., Kabir N.'),
    ('Ctrl Alt Elite', 'Sana K., Arjun R., Rhea P.'),
    ('Git Happens', 'Priya M., Varun T.'),
    ('Stack Smashers', 'Neha R., Omkar P., Zoya A.'),
    ('404 Sleep', 'Kunal S., Tara D.'),
  ];

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    final waiting = _queue.length - _done.length;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 110),
      children: [
        DashHeader(role: _col, a: 'Students ', b: '& teams.', notes: _notes),
        const SizedBox(height: 16),
        ChipBar(items: ['Verify · $waiting', 'Check-in · ${_checked.length}/${_teams.length}'], sel: _seg, onSel: (i) => setState(() => _seg = i), color: _c),
        const SizedBox(height: 14),
        if (_seg == 0) ...[
          Card2(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(value: 0.82, strokeWidth: 6, backgroundColor: C.bg2, color: _c, strokeCap: StrokeCap.round),
                      ),
                      Text('82%', style: sans(13, weight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text('1,240 students verified. Verified students get the “✓ IIT Bombay” stamp on their MSW ID.', style: sans(13, color: C.muted)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (waiting == 0)
            Card2(
              child: Center(
                child: Text('Everyone is verified ✨', style: sans(14, color: C.muted)),
              ),
            ),
          for (var i = 0; i < _queue.length; i++)
            Removable(
              removed: _done.containsKey(i),
              left: _done[i] == false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card2(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      GAvatar(_queue[i].$1.split(' ').map((w) => w[0]).join(), size: 40, colors: [_c, C.sky]),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_queue[i].$1, style: sans(14, weight: FontWeight.w600, height: 1.2)),
                            Text(_queue[i].$2, style: sans(12, color: C.muted)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Color(0xFFE5484D)),
                        onPressed: () => setState(() => _done[i] = false),
                      ),
                      Pressable(
                        onTap: () {
                          setState(() => _done[i] = true);
                          toast(context, '${_queue[i].$1} verified — ID stamped ✓');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(color: _c, borderRadius: BorderRadius.circular(99)),
                          child: Text(
                            'Verify',
                            style: sans(12, color: Colors.white, weight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ] else
          for (final t in _teams)
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
                          Text(t.$1, style: sans(15, weight: FontWeight.w600, height: 1.2)),
                          Text(t.$2, style: sans(12, color: C.muted)),
                        ],
                      ),
                    ),
                    Pressable(
                      onTap: () => setState(() => _checked.contains(t.$1) ? _checked.remove(t.$1) : _checked.add(t.$1)),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(color: _checked.contains(t.$1) ? C.teal : C.bg2, borderRadius: BorderRadius.circular(99)),
                        child: Text(
                          _checked.contains(t.$1) ? 'Checked in ✓' : 'Check in',
                          style: sans(12, weight: FontWeight.w700, color: _checked.contains(t.$1) ? C.black : C.ink),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class CollegeAccount extends StatelessWidget {
  const CollegeAccount({super.key});
  @override
  Widget build(BuildContext context) => AccountTab(
    role: _col,
    name: 'IIT Bombay E-Cell',
    sub: 'Organiser · Prof. Mehta',
    initials: 'IB',
    extra: [
      const SectionTitle('Placements', b: 'via MSW'),
      Card2(child: BarList(const [('Lumen Labs', 38), ('Kite AI', 31), ('Parallax', 24), ('Helio', 19), ('Northwind', 12)], color: _c)),
    ],
  );
}
