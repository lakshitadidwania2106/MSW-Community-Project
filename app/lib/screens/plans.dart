import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/ui.dart';

/// Credits & plans: Starter (free) · Pro ₹99 · Pro+ ₹299 — or unlock with credits.
class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});
  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  static const credits = 2450;
  String _plan = 'Starter';
  static const _plans = [
    ('Starter', '₹0', 'forever', 0, ['Feed, posts, blogs & reels', 'MSW Labs Day 1–7', 'Hackathons & events', '5 applications a month']),
    ('Pro', '₹99', '/month', 2000, ['Full MSW Labs Day 1–30 + certificate', 'Unlimited jobs, internships & tasks', 'All quizzes, IQ & reasoning', 'Resume builder & GitHub analyser']),
    ('Pro+', '₹299', '/month', 5000, ['Everything in Pro', 'Pitch ideas to investors', '2 mentor sessions a month', 'Mock interviews']),
  ];

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, pad.top + 8, 20, pad.bottom + 30),
        children: [
          Row(
            children: [
              Pressable(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: C.card,
                    shape: BoxShape.circle,
                    border: Border.all(color: C.line),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Reveal(child: Headline('Free to start. ', 'Credits to grow.', size: 40)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: C.lime, borderRadius: BorderRadius.circular(22)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('YOUR CREDITS', style: mono(10, color: C.black)),
                      CountUp(
                        to: credits,
                        style: serif(52, color: C.black),
                      ),
                      Text('Earn by posting, learning, playing & referring', style: sans(12, color: C.black)),
                    ],
                  ),
                ),
                const Text('🪙', style: TextStyle(fontSize: 44)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < _plans.length; i++)
            Reveal(
              delay: 100 + i * 90,
              child: Padding(padding: const EdgeInsets.only(bottom: 12), child: _card(_plans[i])),
            ),
        ],
      ),
    );
  }

  Widget _card((String, String, String, int, List<String>) p) {
    final dark = p.$1 == 'Pro', current = _plan == p.$1;
    final fg = dark ? C.onDark : C.ink;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: dark ? C.dark : C.paper,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: current ? C.tealD : (dark ? Colors.transparent : C.line), width: current ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(p.$1.toUpperCase(), style: mono(11, color: dark ? C.teal : C.muted)),
              if (dark) ...[const SizedBox(width: 8), const Tag('Most popular', bg: C.lime)],
              const Spacer(),
              if (current) const Tag('Current', bg: C.teal, fg: Colors.white),
            ],
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: p.$2,
                  style: serif(56, color: fg),
                ),
                TextSpan(
                  text: '  ${p.$3}',
                  style: sans(13, color: dark ? Colors.white54 : C.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          for (final f in p.$5)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(Icons.check_rounded, size: 16, color: dark ? C.teal : C.tealD),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(f, style: sans(13, color: fg)),
                  ),
                ],
              ),
            ),
          if (p.$4 > 0 && !current) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton('Upgrade · ${p.$2}', height: 48, icon: false, bg: dark ? C.teal : C.ink, fg: dark ? C.black : C.onInk, onTap: () => _choose(p.$1, 'Welcome to ${p.$1} 🎉')),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PrimaryButton(
                    '${p.$4} credits',
                    height: 48,
                    icon: false,
                    bg: Colors.transparent,
                    fg: fg,
                    onTap: () {
                      if (credits >= p.$4) {
                        _choose(p.$1, '${p.$1} unlocked with credits 🎉');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You need ${p.$4 - credits} more credits 🔒')));
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _choose(String plan, String msg) {
    setState(() => _plan = plan);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
