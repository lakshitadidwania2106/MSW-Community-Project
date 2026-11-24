import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';
import '../widgets/ui.dart';

/// Timed quiz / IQ test with instant right-wrong feedback and an animated result dial.
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.title});
  final String title;
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  int _q = 0, _correct = 0;
  int? _picked;
  bool _finished = false;
  late final AnimationController _timer = AnimationController(vsync: this, duration: const Duration(seconds: 20))
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed && _picked == null) _pick(-1);
    })
    ..forward();

  @override
  void dispose() {
    _timer.dispose();
    super.dispose();
  }

  void _pick(int i) async {
    if (_picked != null) return;
    _timer.stop();
    setState(() {
      _picked = i;
      if (i == iqQuestions[_q].answer) _correct++;
    });
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() {
      if (_q == iqQuestions.length - 1) {
        _finished = true;
      } else {
        _q++;
        _picked = null;
        _timer.forward(from: 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return Scaffold(
      backgroundColor: C.bg,
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, pad.top + 8, 20, pad.bottom + 20),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (c, a) => FadeTransition(
            opacity: a,
            child: SlideTransition(
              position: Tween(begin: const Offset(0.06, 0), end: Offset.zero).animate(a),
              child: c,
            ),
          ),
          child: _finished ? _result() : _question(),
        ),
      ),
    );
  }

  Widget _question() {
    final q = iqQuestions[_q];
    return Column(
      key: ValueKey(_q),
      crossAxisAlignment: CrossAxisAlignment.start,
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
                child: const Icon(Icons.close_rounded, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Text(widget.title.toUpperCase(), style: mono(11, color: C.ink)),
            const Spacer(),
            SizedBox(
              width: 46,
              height: 46,
              child: AnimatedBuilder(
                animation: _timer,
                builder: (_, _) {
                  final left = (20 * (1 - _timer.value)).ceil();
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: 1 - _timer.value,
                          strokeWidth: 3.5,
                          backgroundColor: C.bg2,
                          color: left <= 5 ? const Color(0xFFE5484D) : C.ink,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text('$left', style: sans(14, weight: FontWeight.w700)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            for (var i = 0; i < iqQuestions.length; i++)
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 4,
                  decoration: BoxDecoration(color: i <= _q ? C.ink : C.line2, borderRadius: BorderRadius.circular(4)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 34),
        Text('QUESTION ${_q + 1} OF ${iqQuestions.length}', style: mono(11)),
        const SizedBox(height: 10),
        Text(q.q, style: serif(36, height: 1.08)),
        const Spacer(),
        for (var i = 0; i < q.options.length; i++)
          Reveal(
            delay: i * 70,
            offset: 16,
            child: Padding(padding: const EdgeInsets.only(bottom: 10), child: _option(q, i)),
          ),
      ],
    );
  }

  Widget _option(Question q, int i) {
    final picked = _picked != null;
    final isAns = i == q.answer, isPick = i == _picked;
    Color bg = Colors.white, fg = C.ink, border = C.line2;
    if (picked && isAns) {
      bg = C.tealD;
      fg = Colors.white;
      border = C.tealD;
    } else if (picked && isPick) {
      bg = const Color(0xFFE5484D);
      fg = Colors.white;
      border = bg;
    }
    return Pressable(
      onTap: () => _pick(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: picked && (isAns || isPick) ? Colors.white24 : C.bg),
              child: Text(
                String.fromCharCode(65 + i),
                style: sans(13, weight: FontWeight.w700, color: fg),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                q.options[i],
                style: sans(16, color: fg, weight: FontWeight.w500),
              ),
            ),
            if (picked && isAns) const Icon(Icons.check_rounded, color: Colors.white),
            if (picked && isPick && !isAns) const Icon(Icons.close_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _result() {
    final score = 92 + _correct * 8;
    return Column(
      key: const ValueKey('result'),
      children: [
        const Spacer(),
        Text('YOUR RESULT', style: mono(11)),
        const SizedBox(height: 16),
        SizedBox(
          width: 230,
          height: 230,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: score / 140),
            duration: const Duration(milliseconds: 2000),
            curve: Curves.easeOutCubic,
            builder: (_, v, _) => CustomPaint(
              painter: _Dial(v),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${(v * 140).round()}', style: serif(84)),
                    Text('${widget.title} score', style: sans(13, color: C.muted)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('$_correct / ${iqQuestions.length} correct', style: sans(15, weight: FontWeight.w600)),
        const SizedBox(height: 18),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: const Interval(0.5, 1, curve: Curves.elasticOut),
          builder: (_, v, child) => Transform.scale(scale: v, child: child),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: C.ink, borderRadius: BorderRadius.circular(99)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.psychology_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Badge unlocked: Sharp Mind',
                  style: sans(14, color: C.onInk, weight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        PrimaryButton(
          'Add to my ID',
          onTap: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$score added to your MSW ID')));
          },
        ),
        const SizedBox(height: 10),
        PrimaryButton(
          'Try again',
          bg: Colors.transparent,
          fg: C.ink,
          icon: false,
          onTap: () => setState(() {
            _q = 0;
            _correct = 0;
            _picked = null;
            _finished = false;
            _timer.forward(from: 0);
          }),
        ),
      ],
    );
  }
}

class _Dial extends CustomPainter {
  _Dial(this.v);
  final double v;

  @override
  void paint(Canvas canvas, Size s) {
    final rect = Rect.fromCircle(center: s.center(Offset.zero), radius: s.width / 2 - 10);
    const start = math.pi * 0.75, sweep = math.pi * 1.5;
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..color = C.bg2;
    canvas.drawArc(rect, start, sweep, false, base);
    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(colors: [C.teal, C.lime, C.tealD], startAngle: 0, endAngle: math.pi * 2, transform: GradientRotation(math.pi * 0.7)).createShader(rect);
    canvas.drawArc(rect, start, sweep * v.clamp(0, 1), false, fg);
    // tick dots
    final dot = Paint()..color = C.muted.withValues(alpha: 0.4);
    for (var i = 0; i <= 20; i++) {
      final a = start + sweep * i / 20;
      canvas.drawCircle(s.center(Offset.zero) + Offset(math.cos(a), math.sin(a)) * (s.width / 2 - 30), 1.5, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _Dial old) => old.v != v;
}
