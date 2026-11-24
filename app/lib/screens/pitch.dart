import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/ui.dart';

/// Business ideas: pitch → validation score → mentor → investors.
class PitchScreen extends StatefulWidget {
  const PitchScreen({super.key});
  @override
  State<PitchScreen> createState() => _PitchScreenState();
}

class _PitchScreenState extends State<PitchScreen> {
  final _name = TextEditingController(text: 'HostelHub');
  final _line = TextEditingController(text: 'Order food, laundry and rides inside your hostel');
  final _problem = TextEditingController(text: 'Hostel students waste hours coordinating everyday errands over WhatsApp.');
  String _sector = 'Consumer', _stage = 'Just an idea';
  int _phase = 0; // 0 form · 1 validating · 2 result
  int _score = 0, _step = 0;
  bool _mentor = false, _investors = false;

  Future<void> _submit() async {
    setState(() => _phase = 1);
    await Future.delayed(const Duration(milliseconds: 1700));
    if (!mounted) return;
    setState(() {
      _phase = 2;
      _score = 72 + math.Random().nextInt(20);
      _step = 1;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _line.dispose();
    _problem.dispose();
    super.dispose();
  }

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
              const Spacer(),
              const Tag('Business ideas', bg: C.lilac),
            ],
          ),
          const SizedBox(height: 18),
          const Reveal(child: Headline('Pitch it. ', 'Get it funded.', size: 42)),
          const SizedBox(height: 18),
          _journey(),
          const SizedBox(height: 18),
          AnimatedSwitcher(duration: const Duration(milliseconds: 500), child: _phase == 2 ? _result() : _form()),
        ],
      ),
    );
  }

  Widget _journey() {
    const steps = ['Pitch', 'Validate', 'Mentor', 'Investors'];
    return Row(
      children: [
        for (var i = 0; i < steps.length; i++)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  height: 5,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(color: i <= _step ? const Color(0xFF6C5CE7) : C.line2, borderRadius: BorderRadius.circular(5)),
                ),
                const SizedBox(height: 6),
                Text(
                  steps[i],
                  style: sans(11, color: i <= _step ? C.ink : C.muted, weight: FontWeight.w600),
                ),
              ],
            ),
          ),
      ],
    );
  }

  InputDecoration _dec(String l) => InputDecoration(
    labelText: l,
    filled: true,
    fillColor: C.card,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: C.line2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: C.line2),
    ),
  );

  Widget _chips(List<String> opts, String sel, ValueChanged<String> on) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final o in opts)
        Pressable(
          onTap: () => setState(() => on(o)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: o == sel ? C.ink : Colors.white,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: o == sel ? C.ink : C.line2),
            ),
            child: Text(
              o,
              style: sans(13, weight: FontWeight.w500, color: o == sel ? C.onInk : C.ink),
            ),
          ),
        ),
    ],
  );

  Widget _form() => Column(
    key: const ValueKey('form'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(controller: _name, decoration: _dec('Idea name')),
      const SizedBox(height: 10),
      TextField(controller: _line, decoration: _dec('One-liner')),
      const SizedBox(height: 10),
      TextField(controller: _problem, maxLines: 3, decoration: _dec('The problem')),
      const SizedBox(height: 14),
      Text('SECTOR', style: mono(10)),
      const SizedBox(height: 8),
      _chips(const ['EdTech', 'FinTech', 'HealthTech', 'AgriTech', 'Consumer', 'Climate'], _sector, (v) => _sector = v),
      const SizedBox(height: 14),
      Text('STAGE', style: mono(10)),
      const SizedBox(height: 8),
      _chips(const ['Just an idea', 'Prototype', 'Early users'], _stage, (v) => _stage = v),
      const SizedBox(height: 22),
      PrimaryButton(_phase == 1 ? 'Validating…' : 'Submit for validation', loading: _phase == 1, bg: _phase == 1 ? const Color(0xFF6C5CE7) : C.ink, onTap: _submit),
    ],
  );

  Widget _result() => Column(
    key: const ValueKey('result'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: C.dark, borderRadius: BorderRadius.circular(26)),
        child: Row(
          children: [
            SizedBox(
              width: 104,
              height: 104,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: _score / 100),
                duration: const Duration(milliseconds: 1600),
                curve: Curves.easeOutCubic,
                builder: (_, v, _) => Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(value: v, strokeWidth: 8, backgroundColor: Colors.white10, color: C.lilac, strokeCap: StrokeCap.round),
                    ),
                    Text('${(v * 100).round()}', style: serif(40, color: C.onDark)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('VALIDATION SCORE', style: mono(10, color: C.lilac)),
                  const SizedBox(height: 4),
                  Text(_name.text, style: serif(28, color: C.onDark)),
                  Text('Strong problem · crowded market. Community votes will refine this.', style: sans(12, color: Colors.white60)),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      _action(Icons.how_to_vote_rounded, 'Open for community validation', '146 students in $_sector will vote', true, null),
      _action(
        Icons.school_rounded,
        _mentor ? 'Mentor requested — Sana Khan' : 'Request a mentor',
        'Included in Pro+ · or 400 credits',
        _mentor,
        () => setState(() {
          _mentor = true;
          _step = math.max(_step, 2);
        }),
      ),
      _action(
        Icons.trending_up_rounded,
        _investors ? 'Shared with 312 investors' : 'Share with investors',
        'Goes into the investor deal flow',
        _investors,
        () => setState(() {
          _investors = true;
          _step = 3;
        }),
      ),
      const SizedBox(height: 8),
      PrimaryButton(
        'Done',
        onTap: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_name.text} is live on MSW 💡')));
        },
      ),
    ],
  );

  Widget _action(IconData ic, String t, String s, bool done, VoidCallback? onTap) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Pressable(
      onTap: done ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: done ? const Color(0xFFECE6FF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: done ? const Color(0xFF6C5CE7) : C.line),
        ),
        child: Row(
          children: [
            Icon(ic, color: const Color(0xFF6C5CE7)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t, style: sans(14, weight: FontWeight.w600, height: 1.2)),
                  Text(s, style: sans(12, color: C.muted)),
                ],
              ),
            ),
            Icon(done ? Icons.check_circle_rounded : Icons.arrow_forward_rounded, color: done ? const Color(0xFF6C5CE7) : C.muted),
          ],
        ),
      ),
    ),
  );
}
