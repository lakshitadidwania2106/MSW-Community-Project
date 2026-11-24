import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../api.dart';
import '../../data.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';
import '../details.dart';
import '../post.dart';
import 'common.dart';

/// ===================== INVESTOR (Nikhil Varma, angel) =====================
final _inv = roles[2];
Color get _c => _inv.color;
const _notes = [
  (Icons.trending_up_rounded, 'Krishi crossed 1,800 farmers onboarded'),
  (Icons.auto_awesome_outlined, '4 new ideas match your thesis'),
  (Icons.description_outlined, 'Ledgerly shared an updated pitch deck'),
];

class Holding {
  const Holding(this.name, this.invested, this.value, this.stage, this.change);
  final String name, stage;
  final double invested, value;
  final int change;
}

const holdings = [Holding('Krishi', 2.0, 3.4, 'Seed', 70), Holding('Ledgerly', 1.5, 2.1, 'Seed', 40), Holding('Nibble', 0.8, 0.95, 'Pre-seed', 19), Holding('Hive', 1.0, 0.7, 'Pre-seed', -30)];

/* ───────────── Home ───────────── */

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
          decoration: BoxDecoration(color: C.black, borderRadius: BorderRadius.circular(26)),
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
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Tag('+35%', bg: C.lime),
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
        Row(
          children: [
            Expanded(
              child: StatTile(label: 'Ideas backed', value: 4, accent: _c, delta: '1 new', icon: Icons.auto_awesome_outlined),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(label: 'New this week', value: ideas.length.toDouble(), accent: _c, delta: 'Match your thesis', icon: Icons.layers_outlined),
            ),
          ],
        ),
        SectionTitle('Hot', b: 'this week', action: 'Open deals', onAction: () => go(1)),
        for (final d in ideas.take(3))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Pressable(
              scale: 0.98,
              onTap: () => Navigator.of(context).push(fadeRoute(IdeaDetailScreen(idea: d, investor: true))),
              child: Card2(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    SizedBox(width: 64, height: 64, child: IdeaArt(idea: d, height: 64)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.name, style: sans(15, weight: FontWeight.w700)),
                          Text(
                            d.pitch,
                            style: sans(12, color: C.muted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '₹${d.ask.toStringAsFixed(0)}L for ${d.equity.toStringAsFixed(0)}% · ${(d.raised / d.ask * 100).round()}% committed',
                            style: sans(12, weight: FontWeight.w600, color: C.tealD),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: C.muted),
                  ],
                ),
              ),
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

/* ───────────── Deals — wheel + cover-flow ───────────── */

class InvestorDeals extends StatefulWidget {
  const InvestorDeals({super.key});
  @override
  State<InvestorDeals> createState() => _InvestorDealsState();
}

class _InvestorDealsState extends State<InvestorDeals> with TickerProviderStateMixin {
  final _wheel = PageController(viewportFraction: 0.22);
  double _p = 0;
  int _artPage = 0;
  late final AnimationController _stamp = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
  late final AnimationController _burst = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  int get _i => _p.round().clamp(0, ideas.length - 1);

  @override
  void initState() {
    super.initState();
    _wheel.addListener(() {
      final np = _wheel.page ?? 0;
      if (np.round() != _p.round()) {
        HapticFeedback.selectionClick();
        _artPage = 0;
      }
      setState(() => _p = np);
    });
  }

  @override
  void dispose() {
    _wheel.dispose();
    _stamp.dispose();
    _burst.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_i < ideas.length - 1) _wheel.animateToPage(_i + 1, duration: const Duration(milliseconds: 650), curve: Curves.easeInOutCubic);
  }

  Future<void> _pass() async {
    final d = ideas[_i];
    HapticFeedback.lightImpact();
    setState(() {
      if (d.decision == 'backed') d.raised = (d.raised - d.myCheque).clamp(0, d.ask);
      d.decision = 'passed';
      d.myCheque = 0;
    });
    Api.decide(d);
    _stamp.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) _goNext();
  }

  void _undo() {
    final d = ideas[_i];
    setState(() {
      if (d.decision == 'backed') d.raised = (d.raised - d.myCheque).clamp(0, d.ask);
      d.decision = null;
      d.myCheque = 0;
    });
    Api.decide(d);
  }

  void _back() {
    final d = ideas[_i];
    var amt = d.minTicket <= 1 ? 1.0 : d.minTicket;
    final chips = <double>{d.minTicket, 1, 2, 5}.where((t) => t >= d.minTicket && t <= d.ask).toList()..sort();
    sheet(
      context,
      StatefulBuilder(
        builder: (ctx, setS) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: d.color, borderRadius: BorderRadius.circular(14)),
                  child: Icon(d.icon, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text('Back ${d.name}', style: serif(32))),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                for (final t in chips)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setS(() => amt = t);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: amt == t ? _blue : C.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: amt == t ? _blue : C.line2),
                        ),
                        child: Column(
                          children: [
                            Text(
                              t < 1 ? '₹${(t * 100).round()}K' : '₹${t.toStringAsFixed(0)}L',
                              style: sans(16, weight: FontWeight.w800, color: amt == t ? Colors.white : C.ink),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${(t / d.valuation * 100).toStringAsFixed(2)}%',
                              style: sans(11, weight: FontWeight.w600, color: amt == t ? Colors.white70 : C.tealD),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _sheetStat(Icons.pie_chart_outline_rounded, '${(amt / d.valuation * 100).toStringAsFixed(2)}%', 'equity'),
                _sheetStat(Icons.account_balance_outlined, '₹${(d.valuation / 100).toStringAsFixed(1)}Cr', 'valuation'),
                _sheetStat(Icons.description_outlined, 'Equity', 'instrument'),
              ],
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              'Back with ₹${amt < 1 ? '${(amt * 100).round()}K' : '${amt.toStringAsFixed(0)}L'}',
              bg: _blue,
              fg: Colors.white,
              onTap: () async {
                Navigator.of(ctx).pop();
                HapticFeedback.mediumImpact();
                setState(() {
                  if (d.decision == 'backed') d.raised = (d.raised - d.myCheque).clamp(0, d.ask);
                  d.decision = 'backed';
                  d.myCheque = amt;
                  d.raised = (d.raised + amt).clamp(0, d.ask);
                });
                Api.decide(d);
                _stamp.forward(from: 0);
                _burst.forward(from: 0);
                await Future.delayed(const Duration(milliseconds: 1100));
                if (mounted) _goNext();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetStat(IconData ic, String v, String l) => Expanded(
    child: Column(
      children: [
        Icon(ic, color: C.muted, size: 20),
        const SizedBox(height: 4),
        Text(v, style: sans(15, weight: FontWeight.w800)),
        Text(l, style: sans(11, color: C.muted)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    final size = MediaQuery.of(context).size;
    final lo = _p.floor().clamp(0, ideas.length - 1), hi = _p.ceil().clamp(0, ideas.length - 1);
    final bg = Color.lerp(ideas[lo].color, ideas[hi].color, _p - _p.floor())!;
    final reviewed = ideas.where((i) => i.decision != null).length;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color.lerp(bg, Colors.black, 0.45)!, Color.lerp(bg, Colors.black, 0.8)!]),
      ),
      child: Column(
        children: [
          SizedBox(height: pad.top + 8),
          // header: progress
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text('Deals', style: serif(30, color: Colors.white)),
                const Spacer(),
                for (final d in ideas)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(left: 4),
                    width: d == ideas[_i] ? 18 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: d.decision == 'backed' ? C.lime : (d.decision == 'passed' ? Colors.white30 : (d == ideas[_i] ? Colors.white : Colors.white54)),
                    ),
                  ),
                const SizedBox(width: 10),
                Text('$reviewed/${ideas.length}', style: mono(10, color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // cover-flow cards
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                final order = [for (var k = 0; k < ideas.length; k++) k]..sort((a, b) => (b - _p).abs().compareTo((a - _p).abs()));
                return Stack(
                  children: [
                    for (final k in order)
                      if ((k - _p).abs() < 1.6) _card(k, k - _p, w, c.maxHeight),
                  ],
                );
              },
            ),
          ),
          // wheel
          SizedBox(
            height: 118,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(child: CustomPaint(painter: _ArcPainter())),
                PageView.builder(
                  controller: _wheel,
                  itemCount: ideas.length,
                  itemBuilder: (_, k) {
                    final d = k - _p;
                    final ad = d.abs();
                    final sc = (1 - ad * 0.2).clamp(0.55, 1.0);
                    return GestureDetector(
                      onTap: () => _wheel.animateToPage(k, duration: const Duration(milliseconds: 550), curve: Curves.easeInOutCubic),
                      child: Transform.translate(
                        offset: Offset(0, ad * ad * 9 + (ad > 0.5 ? 6 : 0)),
                        child: Transform.rotate(
                          angle: d * 0.12,
                          child: Transform.scale(
                            scale: sc,
                            child: Opacity(opacity: (1 - ad * 0.25).clamp(0.35, 1), child: _thumb(ideas[k], ad < 0.5)),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: pad.bottom + 76),
          SizedBox(width: size.width, height: 0),
        ],
      ),
    );
  }

  Widget _thumb(Idea d, bool center) => Center(
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 78,
          height: 78,
          padding: EdgeInsets.all(center ? 4 : 0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: center ? 3 : 0),
            boxShadow: center ? [BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 8))] : null,
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [d.color, Color.lerp(d.color, Colors.black, 0.45)!]),
            ),
            child: Icon(d.icon, color: Colors.white, size: 30),
          ),
        ),
        if (d.decision != null)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: d.decision == 'backed' ? C.lime : const Color(0xFFE5484D),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(d.decision == 'backed' ? Icons.check_rounded : Icons.close_rounded, size: 14, color: d.decision == 'backed' ? C.black : Colors.white),
            ),
          ),
      ],
    ),
  );

  Widget _card(int k, double d, double w, double h) {
    final idea = ideas[k];
    final ad = d.abs();
    final isTop = ad < 0.5;
    final m = Matrix4.identity()
      ..setEntry(3, 2, 0.0012)
      ..translateByDouble(d * w * 0.78, ad * 18, 0, 1)
      ..rotateY(-d * 0.55)
      ..scaleByDouble(1 - ad * 0.12, 1 - ad * 0.12, 1, 1);
    return Positioned(
      left: 14,
      right: 14,
      top: 0,
      bottom: 4,
      child: IgnorePointer(
        ignoring: !isTop,
        child: Opacity(
          opacity: (1 - ad * 0.55).clamp(0, 1),
          child: Transform(alignment: Alignment.center, transform: m, child: _cardBody(idea, isTop, h)),
        ),
      ),
    );
  }

  Future<void> _openDetail(Idea d) async {
    HapticFeedback.selectionClick();
    await Navigator.of(context).push(fadeRoute(IdeaDetailScreen(idea: d, investor: true)));
    if (mounted) setState(() {});
  }

  /// The whole card is tappable — full details open only on tap.
  Widget _cardBody(Idea d, bool isTop, double h) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isTop ? () => _openDetail(d) : null,
        child: _cardInner(d, isTop, h),
      );

  Widget _cardInner(Idea d, bool isTop, double h) {
    const stages = ['Idea', 'Pre-seed', 'Seed', 'Series A'];
    final si = stages.indexOf(d.stage);
    final artH = (h * 0.42).clamp(150.0, 250.0);
    return Container(
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 30, offset: Offset(0, 18))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            children: [
              // art carousel
              Container(
                color: darkMode.value ? C.card : const Color(0xFFF7F7F8),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                child: Column(
                  children: [
                    SizedBox(
                      height: artH,
                      child: Stack(
                        children: [
                          PageView(
                            onPageChanged: (pg) => setState(() => _artPage = pg),
                            children: [
                              for (var pg = 0; pg < 3; pg++)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 26),
                                  child: IdeaArt(idea: d, height: artH, page: pg),
                                ),
                            ],
                          ),
                          Positioned(left: 0, top: 0, child: _circle(Icons.open_in_full_rounded, () => _openDetail(d))),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Column(
                              children: [
                                _circle(d.saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, () {
                                  HapticFeedback.selectionClick();
                                  setState(() => d.saved = !d.saved);
                                }, filled: d.saved),
                                const SizedBox(height: 8),
                                _circle(Icons.ios_share_rounded, () => showShareSheet(context, d.name, 'https://msw.community/i/${d.name.toLowerCase()}')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var pg = 0; pg < 3; pg++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: isTop && pg == _artPage ? 16 : 6,
                            height: 6,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: isTop && pg == _artPage ? _blue : C.line2),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(d.name, style: sans(24, weight: FontWeight.w800, height: 1.1)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: d.color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(99)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(d.icon, size: 13, color: d.color),
                                const SizedBox(width: 4),
                                Text(
                                  d.sector,
                                  style: sans(12, weight: FontWeight.w700, color: d.color),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        d.pitch,
                        style: sans(14, color: C.muted, height: 1.35),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(children: [
                        Text('Tap for full details', style: sans(12, weight: FontWeight.w700, color: _blue)),
                        const Icon(Icons.chevron_right_rounded, size: 18, color: _blue),
                      ]),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _stat(Icons.people_alt_outlined, fmtNum(d.users)),
                          _stat(Icons.trending_up_rounded, '+${d.growth.toStringAsFixed(0)}%'),
                          _stat(Icons.groups_outlined, '${d.founders.length}'),
                          _stat(Icons.verified_outlined, 'MSW'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // stage track
                      Row(
                        children: [
                          for (var x = 0; x < stages.length; x++) ...[
                            Container(
                              width: x == si ? 14 : 10,
                              height: x == si ? 14 : 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: x <= si ? _blue : C.line2,
                                border: x == si ? Border.all(color: _blue.withValues(alpha: 0.3), width: 3) : null,
                              ),
                            ),
                            if (x < stages.length - 1) Expanded(child: Container(height: 2, color: x < si ? _blue : C.line2)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (var x = 0; x < stages.length; x++)
                            Text(
                              stages[x],
                              style: sans(10, weight: x == si ? FontWeight.w800 : FontWeight.w500, color: x == si ? _blue : C.muted),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // bottom bar
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 12, 12),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: C.line)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 46,
                      height: 46,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: d.raised / d.ask),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, _) => Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox.expand(
                              child: CircularProgressIndicator(value: v, strokeWidth: 4, backgroundColor: C.line2, color: const Color(0xFF14A44D), strokeCap: StrokeCap.round),
                            ),
                            Text('${(v * 100).round()}%', style: sans(10, weight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('₹${d.ask.toStringAsFixed(0)}L', style: sans(20, weight: FontWeight.w800, height: 1.1)),
                          Text('for ${d.equity.toStringAsFixed(0)}% equity', style: sans(12, color: C.muted)),
                        ],
                      ),
                    ),
                    if (d.decision != null)
                      GestureDetector(
                        onTap: _undo,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(color: C.bg2, borderRadius: BorderRadius.circular(99)),
                          child: Row(
                            children: [
                              Icon(Icons.undo_rounded, size: 16, color: C.ink),
                              const SizedBox(width: 4),
                              Text('Undo', style: sans(13, weight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      _actionBtn(Icons.close_rounded, const Color(0xFFE5484D), _pass, light: true),
                      const SizedBox(width: 10),
                      _actionBtn(Icons.favorite_rounded, _blue, _back, label: 'BACK'),
                    ],
                  ],
                ),
              ),
            ],
          ),
          // decision stamp
          if (d.decision != null)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _stamp,
                  builder: (_, _) {
                    final v = isTop ? Curves.elasticOut.transform(_stamp.value.clamp(0.0, 1.0)) : 1.0;
                    final backed = d.decision == 'backed';
                    final c = backed ? const Color(0xFF14A44D) : const Color(0xFFE5484D);
                    return Align(
                      alignment: const Alignment(0, -0.35),
                      child: Transform.rotate(
                        angle: -0.22,
                        child: Transform.scale(
                          scale: _stamp.isAnimating || !isTop ? 2.2 - 1.2 * v : 1,
                          child: Opacity(
                            opacity: (v).clamp(0, 1).toDouble(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                              decoration: BoxDecoration(
                                color: C.card.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: c, width: 4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(backed ? Icons.favorite_rounded : Icons.close_rounded, color: c, size: 28),
                                  const SizedBox(width: 6),
                                  Text(
                                    backed ? 'BACKED' : 'PASSED',
                                    style: sans(28, weight: FontWeight.w900, color: c, height: 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          // confetti burst
          if (isTop)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _burst,
                  builder: (_, _) => CustomPaint(painter: _BurstPainter(_burst.value, d.color)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _stat(IconData ic, String v) => Expanded(
    child: Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: C.bg2, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Icon(ic, size: 17, color: C.ink),
          const SizedBox(height: 2),
          Text(v, style: sans(12, weight: FontWeight.w700)),
        ],
      ),
    ),
  );

  Widget _actionBtn(IconData ic, Color c, VoidCallback onTap, {String? label, bool light = false}) => Pressable(
    onTap: onTap,
    scale: 0.88,
    child: Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: label == null ? 0 : 20),
      width: label == null ? 50 : null,
      decoration: BoxDecoration(
        color: light ? c.withValues(alpha: 0.12) : c,
        borderRadius: BorderRadius.circular(99),
        boxShadow: light ? null : [BoxShadow(color: c.withValues(alpha: 0.4), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ic, color: light ? c : Colors.white, size: 22),
          if (label != null) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: sans(15, weight: FontWeight.w800, color: Colors.white),
            ),
          ],
        ],
      ),
    ),
  );

  Widget _circle(IconData ic, VoidCallback onTap, {bool filled = false}) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: filled ? const Color(0xFFE9DCCB) : C.card.withValues(alpha: 0.92),
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 10)],
      ),
      child: Icon(ic, size: 19, color: filled ? C.black : C.ink),
    ),
  );
}

const _blue = Color(0xFF0B5FFF);

/// Faint curved track behind the wheel.
class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final r = Rect.fromCenter(center: Offset(s.width / 2, -s.width * 1.05 + s.height * 0.5), width: s.width * 2.6, height: s.width * 2.6);
    canvas.drawArc(r, 0.9, 1.34, false, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Dots that burst out from the centre when an idea is backed.
class _BurstPainter extends CustomPainter {
  _BurstPainter(this.t, this.color);
  final double t;
  final Color color;
  @override
  void paint(Canvas canvas, Size s) {
    if (t == 0 || t == 1) return;
    final c = Offset(s.width / 2, s.height * 0.32);
    final e = Curves.easeOutCubic.transform(t);
    final cols = [color, C.lime, const Color(0xFF0B5FFF), C.peach, C.teal];
    for (var i = 0; i < 36; i++) {
      final a = i / 36 * 6.283 + i * 0.3;
      final dist = 40 + e * (120 + (i % 5) * 28);
      final pos = c + Offset(dist * math.cos(a), dist * math.sin(a) + e * e * 60);
      canvas.drawCircle(pos, (1 - t) * (3 + i % 3 * 1.5), Paint()..color = cols[i % cols.length].withValues(alpha: 1 - t));
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter old) => old.t != t;
}

/* ───────────── Portfolio (+ watchlist) ───────────── */

class InvestorPortfolio extends StatefulWidget {
  const InvestorPortfolio({super.key});
  @override
  State<InvestorPortfolio> createState() => _InvestorPortfolioState();
}

class _InvestorPortfolioState extends State<InvestorPortfolio> {
  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    final saved = ideas.where((i) => i.saved).toList();
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
        for (final p in holdings)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Pressable(
              scale: 0.98,
              onTap: () {
                final idea = ideas.where((i) => i.name == p.name).firstOrNull;
                if (idea != null) Navigator.of(context).push(fadeRoute(IdeaDetailScreen(idea: idea, investor: true)));
              },
              child: Card2(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: ideas.where((d) => d.name == p.name).firstOrNull?.color ?? C.muted, borderRadius: BorderRadius.circular(14)),
                      child: Icon(ideas.where((d) => d.name == p.name).firstOrNull?.icon ?? Icons.hive_outlined, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, style: sans(15, weight: FontWeight.w600, height: 1.2)),
                          Text('${p.stage} · invested ₹${p.invested}L', style: sans(12, color: C.muted)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹${p.value}L', style: serif(24)),
                        Text(
                          '${p.change < 0 ? '−' : '+'}${p.change.abs()}%',
                          style: sans(12, weight: FontWeight.w700, color: p.change < 0 ? const Color(0xFFE5484D) : C.tealD),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        SectionTitle('Watchlist', action: '${saved.length} saved'),
        if (saved.isEmpty) Text('Save ideas from Deals with the bookmark button.', style: sans(14, color: C.muted)),
        for (final d in saved)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Pressable(
              onTap: () => Navigator.of(context).push(fadeRoute(IdeaDetailScreen(idea: d, investor: true))),
              child: Card2(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.bookmark_rounded, color: C.ink, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('${d.name} — ${d.founders.first.name}', style: sans(14, weight: FontWeight.w600)),
                    ),
                    Tag(d.stage),
                  ],
                ),
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
          for (final t in const ['EdTech', 'Climate', 'AgriTech', '₹50K – ₹10L cheques', 'Pre-seed & Seed']) Tag(t, bg: C.lilac),
        ],
      ),
    ],
  );
}
