import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';
import 'common.dart';

/// ===================== INVESTOR (Nikhil Varma, angel) =====================
final _inv = roles[2];
Color get _c => _inv.color;

class Deal {
  Deal(this.name, this.pitch, this.by, this.sector, this.stage, this.raised, this.goal, this.users, this.growth, this.color);
  final String name, pitch, by, sector, stage;
  double raised;
  final double goal;
  final int users;
  final List<double> growth;
  final Color color;
}

final deals = [
  Deal('Krishi', 'Soil health from a ₹200 sensor', 'Meera J. · IIT Kharagpur', 'AgriTech', 'Seed', 7.8, 10, 1840, [2, 3, 5, 6, 9, 12, 15, 21], C.tealD),
  Deal('Nibble', 'Exam prep in 5-minute bites', 'Arjun & Sana · DTU', 'EdTech', 'Pre-seed', 2.3, 5, 12400, [3, 4, 4, 7, 8, 11, 14, 19], const Color(0xFF6C5CE7)),
  Deal('Pulse', 'AI triage for rural clinics', 'Kabir N. · AIIMS', 'HealthTech', 'Idea', 1.1, 5, 1020, [1, 1, 2, 2, 3, 5, 6, 9], const Color(0xFFE8613F)),
  Deal('Ledgerly', 'UPI bookkeeping for kirana stores', 'Rhea P. · IIIT Hyd', 'FinTech', 'Seed', 6.4, 15, 3300, [4, 5, 7, 8, 8, 10, 13, 16], const Color(0xFF0A66C2)),
  Deal('Loop', 'Campus resale marketplace', 'Dev S. · VIT', 'Consumer', 'Pre-seed', 0.9, 3, 5600, [2, 4, 5, 5, 6, 8, 9, 12], const Color(0xFFC6A400)),
  Deal('Volt', 'Battery swapping for e-rickshaws', 'Ishaan M. · IIT Delhi', 'Climate', 'Idea', 0.4, 8, 140, [1, 1, 1, 2, 2, 3, 3, 4], C.teal),
];
final watchlist = <String>{'Krishi'};
const _notes = [('📈', 'Krishi crossed 1,800 farmers onboarded'), ('🎤', 'Pitch Day #7 starts Friday at 5 PM'), ('✨', '4 new ideas match your thesis')];

class InvestorHome extends StatelessWidget {
  const InvestorHome({super.key, required this.go});
  final ValueChanged<int> go;
  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 110),
      children: [
        DashHeader(role: _inv, a: 'Back ideas ', b: 'before they’re big.', notes: _notes),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF2B2283), Color(0xFF5B4FCF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PORTFOLIO VALUE', style: mono(10, color: C.lilac)),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 7.15),
                    duration: const Duration(milliseconds: 1600),
                    curve: Curves.easeOutQuart,
                    builder: (_, v, _) => Text('₹${v.toStringAsFixed(2)}L', style: serif(54, color: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Tag('↑ 35%', bg: C.lime),
                  ),
                ],
              ),
              Text('₹5.3L invested across 4 student startups', style: sans(13, color: Colors.white70)),
              const SizedBox(height: 14),
              SizedBox(
                height: 70,
                width: double.infinity,
                child: Spark(const [0.5, 0.9, 1.6, 2.2, 2.9, 3.4, 4.1, 4.6, 5.2, 5.9, 6.4, 7.15], color: C.lilac),
              ),
            ],
          ),
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
            StatTile(label: 'Ideas backed', value: 4, accent: _c, delta: '1 new', icon: Icons.auto_awesome_rounded),
            StatTile(label: 'New this week', value: 23, accent: _c, delta: '8 match you', icon: Icons.layers_rounded),
          ],
        ),
        SectionTitle('Hot', b: 'this week', action: 'Swipe deals →', onAction: () => go(1)),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, i) => SizedBox(width: 260, child: _DealCard(deals[i], compact: true)),
          ),
        ),
        const SectionTitle('By', b: 'sector'),
        Card2(
          child: Donut([('AgriTech', 2, C.tealD), ('FinTech', 1.5, const Color(0xFF0A66C2)), ('EdTech', 0.8, const Color(0xFF6C5CE7)), ('Consumer', 1, C.lime)], center: '4', sub: 'startups'),
        ),
      ],
    );
  }
}

class _DealCard extends StatelessWidget {
  const _DealCard(this.d, {this.compact = false});
  final Deal d;
  final bool compact;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: C.dark,
      borderRadius: BorderRadius.circular(26),
      boxShadow: compact ? null : const [BoxShadow(color: Color(0x40000000), blurRadius: 30, offset: Offset(0, 16))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Tag(d.sector, bg: d.color, fg: Colors.white),
            const SizedBox(width: 6),
            Tag(d.stage, bg: Colors.white12, fg: C.onDark),
            const Spacer(),
            if (watchlist.contains(d.name)) const Text('★', style: TextStyle(color: Color(0xFFE0B400), fontSize: 18)),
          ],
        ),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${d.name} — ',
                style: serif(compact ? 24 : 34, color: C.onDark),
              ),
              TextSpan(
                text: d.pitch.toLowerCase(),
                style: serif(compact ? 24 : 34, color: C.teal, italic: true),
              ),
            ],
          ),
          maxLines: compact ? 2 : 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text('BY ${d.by.toUpperCase()}', style: mono(9, color: Colors.white38)),
        if (!compact) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('USERS', style: mono(9, color: Colors.white38)),
                  Text(fmtNum(d.users), style: serif(30, color: C.onDark)),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(height: 46, child: Spark(d.growth, color: C.lilac)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              Tag('+${((d.growth.last / d.growth[d.growth.length - 2] - 1) * 100).round()}% MoM', bg: C.lime),
              Tag('Team of ${2 + d.name.length % 3}', bg: Colors.white12, fg: C.onDark),
              Tag('MSW verified ✓', bg: Colors.white12, fg: C.onDark),
            ],
          ),
          const SizedBox(height: 14),
          Text('Built at an MSW hackathon and now live with real users. Mentored by the MSW founder network.', style: sans(14, color: Colors.white70, height: 1.5)),
        ],
        const Spacer(),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(value: d.raised / d.goal, minHeight: 7, backgroundColor: Colors.white10, valueColor: AlwaysStoppedAnimation(C.lime)),
        ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '₹${d.raised}L',
                style: sans(14, color: C.onDark, weight: FontWeight.w700),
              ),
              TextSpan(
                text: ' of ₹${d.goal.toStringAsFixed(0)}L raised',
                style: sans(13, color: Colors.white54),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Swipe deck: right = save to watchlist, left = pass, button = back the idea.
class InvestorDeals extends StatefulWidget {
  const InvestorDeals({super.key});
  @override
  State<InvestorDeals> createState() => _InvestorDealsState();
}

class _InvestorDealsState extends State<InvestorDeals> with SingleTickerProviderStateMixin {
  int _top = 0;
  Offset _drag = Offset.zero;
  late final AnimationController _fly = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
  Offset _flyFrom = Offset.zero, _flyTo = Offset.zero;

  @override
  void dispose() {
    _fly.dispose();
    super.dispose();
  }

  Future<void> _decide(bool like) async {
    if (_top >= deals.length) return;
    final d = deals[_top];
    _flyFrom = _drag;
    _flyTo = Offset(like ? 600 : -600, _drag.dy + 40);
    await _fly.forward(from: 0);
    setState(() {
      if (like) watchlist.add(d.name);
      _top++;
      _drag = Offset.zero;
      _fly.reset();
    });
    if (mounted) toast(context, like ? '★ ${d.name} saved to watchlist' : 'Passed on ${d.name}');
  }

  void _back(Deal d) {
    var amt = 2.0;
    showSheet(
      context,
      StatefulBuilder(
        builder: (ctx, setS) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${d.sector.toUpperCase()} · ${d.stage.toUpperCase()}', style: mono(10, color: _c)),
            const SizedBox(height: 4),
            Headline('Back ', '${d.name}.', size: 38, italicColor: _c),
            Text(d.pitch, style: sans(14, color: C.muted)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Card2(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('YOUR PLEDGE', style: mono(9)),
                        Text('₹${amt.toStringAsFixed(1)}L', style: serif(40)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: C.dark, borderRadius: BorderRadius.circular(24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('EST. EQUITY', style: mono(9, color: C.lilac)),
                        Text('${(amt / 125 * 100).toStringAsFixed(1)}%', style: serif(40, color: C.onDark)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Slider(value: amt, min: 0.5, max: 10, divisions: 19, activeColor: _c, onChanged: (v) => setS(() => amt = v)),
            Text('Illustrative, at a ₹1.25Cr pre-money valuation. Final terms come in the term sheet.', style: sans(12, color: C.muted)),
            const SizedBox(height: 14),
            PrimaryButton(
              'Pledge ₹${amt.toStringAsFixed(1)}L',
              bg: _c,
              onTap: () {
                setState(() => d.raised = math.min(d.goal, d.raised + amt));
                Navigator.of(ctx).pop();
                toast(context, 'Pledged ₹${amt.toStringAsFixed(1)}L to ${d.name} — founders notified 🚀');
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
    final left = deals.length - _top;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashHeader(role: _inv, a: 'Deal ', b: 'flow.', sub: 'Swipe right to save · left to pass', notes: _notes),
          const SizedBox(height: 16),
          Expanded(
            child: left == 0
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('✨', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 8),
                        Text('You’re all caught up', style: serif(32)),
                        Text('${watchlist.length} ideas in your watchlist', style: sans(14, color: C.muted)),
                        const SizedBox(height: 16),
                        PrimaryButton('Start over', bg: _c, icon: false, onTap: () => setState(() => _top = 0)).sized(180),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, c) {
                      return Stack(clipBehavior: Clip.none, children: [for (var i = math.min(deals.length - 1, _top + 2); i >= _top; i--) _card(i, c)]);
                    },
                  ),
          ),
          const SizedBox(height: 14),
          if (left > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _round(Icons.close_rounded, const Color(0xFFE5484D), () => _decide(false)),
                const SizedBox(width: 14),
                Pressable(
                  onTap: () => _back(deals[_top]),
                  child: Container(
                    height: 62,
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _c,
                      borderRadius: BorderRadius.circular(99),
                      boxShadow: [BoxShadow(color: _c.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: Text(
                      'Back idea',
                      style: sans(15, color: Colors.white, weight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                _round(Icons.star_rounded, const Color(0xFFE0B400), () => _decide(true)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _round(IconData ic, Color c, VoidCallback onTap) => Pressable(
    onTap: onTap,
    scale: 0.85,
    child: Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: C.card,
        shape: BoxShape.circle,
        border: Border.all(color: C.line),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 16, offset: Offset(0, 6))],
      ),
      child: Icon(ic, color: c, size: 30),
    ),
  );

  Widget _card(int i, BoxConstraints c) {
    final depth = i - _top;
    final isTop = depth == 0;
    Widget card = _DealCard(deals[i]);
    if (!isTop) {
      return Positioned.fill(
        child: AnimatedScale(
          duration: const Duration(milliseconds: 300),
          scale: 1 - depth * 0.05,
          alignment: Alignment.topCenter,
          child: Transform.translate(
            offset: Offset(0, depth * -12.0),
            child: Opacity(opacity: 1 - depth * 0.25, child: card),
          ),
        ),
      );
    }
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _fly,
        builder: (_, child) {
          final o = _fly.isAnimating ? Offset.lerp(_flyFrom, _flyTo, Curves.easeIn.transform(_fly.value))! : _drag;
          final likeK = (o.dx / 120).clamp(-1.0, 1.0);
          return Transform.translate(
            offset: o,
            child: Transform.rotate(
              angle: o.dx / 1400,
              child: Stack(
                children: [
                  child!,
                  Positioned(
                    left: 20,
                    top: 24,
                    child: Opacity(opacity: likeK.clamp(0.0, 1.0), child: _stamp('SAVE ★', const Color(0xFFE0B400))),
                  ),
                  Positioned(
                    right: 20,
                    top: 24,
                    child: Opacity(opacity: (-likeK).clamp(0.0, 1.0), child: _stamp('PASS', const Color(0xFFE5484D))),
                  ),
                ],
              ),
            ),
          );
        },
        child: GestureDetector(
          onPanUpdate: (d) => setState(() => _drag += d.delta),
          onPanEnd: (d) {
            if (_drag.dx.abs() > 110 || d.velocity.pixelsPerSecond.dx.abs() > 800) {
              _decide(_drag.dx > 0);
            } else {
              setState(() => _drag = Offset.zero);
            }
          },
          child: card,
        ),
      ),
    );
  }

  Widget _stamp(String t, Color c) => Transform.rotate(
    angle: -0.2,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: c, width: 3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        t,
        style: sans(20, color: c, weight: FontWeight.w900),
      ),
    ),
  );
}

class InvestorPortfolio extends StatelessWidget {
  const InvestorPortfolio({super.key});
  static const _p = [('Krishi', 2.0, 3.4, 'Seed', 70), ('Ledgerly', 1.5, 2.1, 'Seed', 40), ('Nibble', 0.8, 0.95, 'Pre-seed', 19), ('Hive', 1.0, 0.7, 'Pre-seed', -30)];
  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 110),
      children: [
        DashHeader(role: _inv, a: 'Your ', b: 'portfolio.', notes: _notes),
        const SizedBox(height: 16),
        ChartCard(
          a: 'Value',
          b: 'vs invested',
          series: [
            ('Value', _c, const [0.5, 0.9, 1.6, 2.2, 2.9, 3.4, 4.1, 4.6, 5.2, 5.9, 6.4, 7.15]),
            ('Invested', C.sky, const [0.5, 0.8, 1.3, 1.8, 2.3, 2.8, 3.3, 3.8, 4.2, 4.6, 5, 5.3]),
          ],
          labels: const ['Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov'],
        ),
        const SectionTitle('Investments'),
        for (final p in _p)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Pressable(
              onTap: () => showSheet(
                context,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Founder updates', style: mono(10)),
                    Text(p.$1, style: serif(40)),
                    const SizedBox(height: 10),
                    for (final u in const [('NOV 18', 'Crossed a new usage milestone 🎉'), ('OCT 30', 'Hired our first engineer from MSW Careers'), ('OCT 02', 'Closed a pilot with a state agency')])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card2(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u.$1, style: mono(9)),
                              const SizedBox(height: 4),
                              Text(u.$2, style: sans(14)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              child: Card2(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: (deals.where((d) => d.name == p.$1).firstOrNull?.color ?? C.muted), borderRadius: BorderRadius.circular(14)),
                      child: Text(
                        p.$1[0],
                        style: sans(18, color: Colors.white, weight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.$1, style: sans(15, weight: FontWeight.w600, height: 1.2)),
                          Text('${p.$4} · invested ₹${p.$2}L', style: sans(12, color: C.muted)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹${p.$3}L', style: serif(24)),
                        Text(
                          '${p.$5 < 0 ? '↓' : '↑'} ${p.$5.abs()}%',
                          style: sans(12, weight: FontWeight.w700, color: p.$5 < 0 ? const Color(0xFFE5484D) : C.tealD),
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

class InvestorEvents extends StatefulWidget {
  const InvestorEvents({super.key});
  @override
  State<InvestorEvents> createState() => _InvestorEventsState();
}

class _InvestorEventsState extends State<InvestorEvents> {
  final _going = <int>{};
  static const _ev = [
    ('Pitch Day #7', 'Fri, Nov 28 · 5 PM', 'Online · 8 student startups', [Color(0xFF2B2283), Color(0xFF6C5CE7)]),
    ('Demo Day — HackNova ’26', 'Mar 16 · 3 PM', 'Online · top 10 hackathon teams', [Color(0xFF1B1464), Color(0xFF00D2D3)]),
    ('Climate Founders Night', 'Apr 21 · 7 PM', 'Bengaluru · in person', [Color(0xFF0F3D2E), Color(0xFF2F8F7A)]),
  ];
  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 110),
      children: [
        DashHeader(role: _inv, a: 'Pitch ', b: 'days.', notes: _notes),
        const SizedBox(height: 16),
        for (var i = 0; i < _ev.length; i++)
          Reveal(
            delay: i * 90,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(20),
              height: 190,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: _ev[i].$4, begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_ev[i].$2.toUpperCase(), style: mono(10, color: Colors.white70)),
                  const SizedBox(height: 6),
                  Text(_ev[i].$1, style: serif(34, color: Colors.white, height: 1.05)),
                  Text(_ev[i].$3, style: sans(13, color: Colors.white70)),
                  const Spacer(),
                  Pressable(
                    onTap: () {
                      setState(() => _going.contains(i) ? _going.remove(i) : _going.add(i));
                      if (_going.contains(i)) toast(context, 'Added to your calendar 📅');
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(color: _going.contains(i) ? C.lime : Colors.white, borderRadius: BorderRadius.circular(99)),
                      child: Text(
                        _going.contains(i) ? 'Going ✓' : 'RSVP',
                        style: sans(13, weight: FontWeight.w700, color: C.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SectionTitle('Watchlist'),
        for (final d in deals.where((d) => watchlist.contains(d.name)))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card2(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Text('★', style: TextStyle(color: Color(0xFFE0B400), fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('${d.name} — ${d.by}', style: sans(14, weight: FontWeight.w600)),
                  ),
                  Tag(d.stage),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class InvestorAccount extends StatelessWidget {
  const InvestorAccount({super.key});
  @override
  Widget build(BuildContext context) => AccountTab(
    role: _inv,
    name: 'Nikhil Varma',
    sub: 'Angel investor · Bengaluru',
    initials: 'NV',
    extra: [
      const SizedBox(height: 18),
      Text('INVESTMENT THESIS', style: mono(10)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final t in const ['EdTech', 'Climate', 'AgriTech', '₹1L – ₹10L tickets', 'Pre-seed & Seed']) Tag(t, bg: C.lilac),
        ],
      ),
    ],
  );
}
