import 'dart:async';

import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';
import 'post.dart';

/// Row of circular "what's happening" stories: AI, FinTech, markets, trending blogs…
class StoryRow extends StatefulWidget {
  const StoryRow({super.key});
  @override
  State<StoryRow> createState() => _StoryRowState();
}

class _StoryRowState extends State<StoryRow> with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  Future<void> _open(int i) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 380),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, _, _) => StoryViewer(start: i),
        transitionsBuilder: (_, a, _, c) => FadeTransition(
          opacity: a,
          child: ScaleTransition(
            scale: Tween(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
            child: c,
          ),
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 98,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: stories.length,
      separatorBuilder: (_, _) => const SizedBox(width: 14),
      itemBuilder: (_, i) {
        final s = stories[i];
        return GestureDetector(
          onTap: () => _open(i),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedBuilder(
                    animation: _spin,
                    builder: (_, child) => Container(
                      width: 66,
                      height: 66,
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: s.seen ? null : SweepGradient(colors: [...s.colors, s.colors.first], transform: GradientRotation(_spin.value * 6.283)),
                        color: s.seen ? C.line2 : null,
                      ),
                      child: child,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(color: C.bg, shape: BoxShape.circle),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: s.colors),
                        ),
                        child: Icon(s.icon, color: Colors.white, size: 26),
                      ),
                    ),
                  ),
                  if (s.trending && !s.seen)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5A5F),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: C.bg, width: 2),
                        ),
                        child: Text(
                          'HOT',
                          style: sans(8, color: Colors.white, weight: FontWeight.w800, height: 1.1),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                s.topic,
                style: sans(11, color: C.ink2, weight: FontWeight.w500),
              ),
            ],
          ),
        );
      },
    ),
  );
}

/// Full-screen story viewer: progress bars, tap left / right, hold to pause, swipe down to close.
class StoryViewer extends StatefulWidget {
  const StoryViewer({super.key, required this.start});
  final int start;
  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> with SingleTickerProviderStateMixin {
  late int _s = widget.start;
  int _slide = 0;
  double _dy = 0;
  late final AnimationController _t = AnimationController(vsync: this, duration: const Duration(seconds: 6))
    ..addStatusListener((st) {
      if (st == AnimationStatus.completed) _next();
    });

  @override
  void initState() {
    super.initState();
    stories[_s].seen = true;
    _t.forward();
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  void _next() {
    setState(() {
      if (_slide < stories[_s].slides.length - 1) {
        _slide++;
      } else if (_s < stories.length - 1) {
        _s++;
        _slide = 0;
        stories[_s].seen = true;
      } else {
        Navigator.of(context).maybePop();
        return;
      }
    });
    _t.forward(from: 0);
  }

  void _prev() {
    setState(() {
      if (_slide > 0) {
        _slide--;
      } else if (_s > 0) {
        _s--;
        _slide = 0;
      }
    });
    _t.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final s = stories[_s], sl = s.slides[_slide];
    final pad = MediaQuery.of(context).padding;
    return GestureDetector(
      onVerticalDragUpdate: (d) => setState(() => _dy = (_dy + d.delta.dy).clamp(0, 400)),
      onVerticalDragEnd: (_) => _dy > 120 ? Navigator.of(context).maybePop() : setState(() => _dy = 0),
      onLongPressStart: (_) => _t.stop(),
      onLongPressEnd: (_) => _t.forward(),
      onTapUp: (d) => d.localPosition.dx < MediaQuery.of(context).size.width / 3 ? _prev() : _next(),
      child: Transform.translate(
        offset: Offset(0, _dy),
        child: Opacity(
          opacity: (1 - _dy / 500).clamp(0.3, 1),
          child: Material(
            color: Colors.black,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [s.colors.first, Color.lerp(s.colors.last, Colors.black, 0.55)!]),
              ),
              child: Stack(
                children: [
                  Positioned.fill(child: CustomPaint(painter: _Dots())),
                  Positioned(
                    right: -40,
                    top: 160,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Icon(s.icon, key: ValueKey(_s), size: 260, color: Colors.white.withValues(alpha: 0.12)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, pad.top + 10, 16, pad.bottom + 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            for (var i = 0; i < s.slides.length; i++)
                              Expanded(
                                child: Container(
                                  height: 3,
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                                  alignment: Alignment.centerLeft,
                                  child: AnimatedBuilder(
                                    animation: _t,
                                    builder: (_, _) => FractionallySizedBox(
                                      widthFactor: i < _slide ? 1 : (i == _slide ? _t.value : 0),
                                      child: Container(
                                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                              child: Icon(s.icon, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              s.topic,
                              style: sans(14, color: Colors.white, weight: FontWeight.w700),
                            ),
                            const SizedBox(width: 8),
                            Text('MSW Pulse', style: sans(12, color: Colors.white60)),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.of(context).maybePop(),
                              icon: const Icon(Icons.close_rounded, color: Colors.white),
                            ),
                          ],
                        ),
                        const Spacer(),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 450),
                          transitionBuilder: (c, a) => FadeTransition(
                            opacity: a,
                            child: SlideTransition(
                              position: Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(a),
                              child: c,
                            ),
                          ),
                          child: Column(
                            key: ValueKey('$_s-$_slide'),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(99)),
                                child: Text(
                                  sl.kicker,
                                  style: mono(10, color: C.black, weight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(sl.headline, style: serif(46, color: Colors.white, height: 1.0)),
                              const SizedBox(height: 14),
                              Text(sl.body, style: sans(16, color: Colors.white.withValues(alpha: 0.85), height: 1.5)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(99),
                                  border: Border.all(color: Colors.white38),
                                ),
                                child: Text('Reply to this story…', style: sans(14, color: Colors.white60)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _round(Icons.favorite_border_rounded, () => snack(context, 'Liked')),
                            const SizedBox(width: 8),
                            _round(Icons.ios_share_rounded, () => showShareSheet(context, sl.headline, 'https://msw.community/s/${s.topic.toLowerCase()}')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _round(IconData ic, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white38),
      ),
      child: Icon(ic, color: Colors.white, size: 22),
    ),
  );
}

class _Dots extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.07);
    for (double y = 0; y < s.height; y += 14) {
      for (double x = (y ~/ 14).isEven ? 0 : 7; x < s.width; x += 14) {
        canvas.drawCircle(Offset(x, y), 0.4 + (x / s.width) * 2.4, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
