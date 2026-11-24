import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';
import '../links.dart';
import '../widgets/ui.dart';

/// Full-screen vertical reels — the MSW Labs 30-Day Full-Stack Challenge.
class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key, required this.active});
  final bool active;
  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> with SingleTickerProviderStateMixin {
  final _pc = PageController(initialPage: 11);
  int _page = 11;
  final _liked = <int>{}, _saved = <int>{}, _done = <int>{for (var i = 0; i < 11; i++) i};
  late final AnimationController _play = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();

  @override
  void dispose() {
    _pc.dispose();
    _play.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return ColoredBox(
      color: C.dark,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pc,
            scrollDirection: Axis.vertical,
            itemCount: reelTopics.length,
            onPageChanged: (p) {
              setState(() => _page = p);
              _play.forward(from: 0);
            },
            itemBuilder: (_, i) => _reel(i, pad),
          ),
          // top bar
          Positioned(
            top: pad.top + 8,
            left: 18,
            right: 18,
            child: Row(
              children: [
                Text('Reels', style: serif(30, color: Colors.white)),
                const SizedBox(width: 10),
                Pressable(
                  onTap: openMswLabs,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(99)),
                    child: Text('MSW LABS', style: mono(10, color: C.lime)),
                  ),
                ),
                const Spacer(),
                _streakRing(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _streakRing() {
    final k = _done.length / 30;
    return Row(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(end: k),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (_, v, _) => CircularProgressIndicator(value: v, strokeWidth: 3, backgroundColor: Colors.white12, color: C.teal, strokeCap: StrokeCap.round),
              ),
              Text(
                '${_done.length}',
                style: sans(12, color: Colors.white, weight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text('/30', style: mono(11, color: Colors.white54)),
      ],
    );
  }

  Widget _reel(int i, EdgeInsets pad) {
    final pal = reelPalettes[i % reelPalettes.length];
    final done = _done.contains(i);
    return Stack(
      children: [
        Positioned.fill(
          child: Blobs(base: pal[0], colors: [pal[1].withValues(alpha: 0.9), pal[2].withValues(alpha: 0.6), Colors.white.withValues(alpha: 0.08)], square: false),
        ),
        // giant day number watermark
        Positioned(
          top: pad.top + 70,
          left: -10,
          child: Text((i + 1).toString().padLeft(2, '0'), style: serif(240, color: Colors.white.withValues(alpha: 0.1), height: 1)),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.65)], stops: const [0.4, 0.9]),
            ),
          ),
        ),
        // right actions
        Positioned(
          right: 14,
          bottom: pad.bottom + 190,
          child: Column(
            children: [
              _action(
                _liked.contains(i) ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                '${1200 + i * 37 + (_liked.contains(i) ? 1 : 0)}',
                _liked.contains(i) ? const Color(0xFFFF4D6D) : Colors.white,
                () => setState(() => _liked.contains(i) ? _liked.remove(i) : _liked.add(i)),
              ),
              _action(Icons.mode_comment_rounded, '${80 + i * 3}', Colors.white, () {}),
              _action(
                _saved.contains(i) ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                'Save',
                _saved.contains(i) ? C.lime : Colors.white,
                () => setState(() => _saved.contains(i) ? _saved.remove(i) : _saved.add(i)),
              ),
              _action(Icons.ios_share_rounded, 'Share', Colors.white, () {}),
            ],
          ),
        ),
        // bottom content
        Positioned(
          left: 18,
          right: 80,
          bottom: pad.bottom + 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      'DAY ${(i + 1).toString().padLeft(2, '0')}',
                      style: mono(11, color: C.ink, weight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('60 SEC · FULL-STACK', style: mono(10, color: Colors.white70)),
                ],
              ),
              const SizedBox(height: 10),
              Text(reelTopics[i], style: serif(38, color: Colors.white, height: 1.02)),
              const SizedBox(height: 10),
              Row(
                children: [
                  GAvatar('M.', size: 26, colors: [C.ink, Color(0xFF333333)]),
                  const SizedBox(width: 8),
                  Text(
                    'MSW Labs',
                    style: sans(13, color: Colors.white, weight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  Text('· Mentor series', style: sans(13, color: Colors.white60)),
                ],
              ),
              const SizedBox(height: 14),
              Pressable(
                onTap: () => setState(() {
                  done ? _done.remove(i) : _done.add(i);
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutBack,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  decoration: BoxDecoration(
                    color: done ? C.lime : Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: done ? C.lime : Colors.white30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, size: 18, color: done ? C.ink : Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        done ? 'Day complete' : 'Mark day complete',
                        style: sans(13, weight: FontWeight.w600, color: done ? C.black : Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // playback progress
        Positioned(
          left: 18,
          right: 18,
          bottom: pad.bottom + 86,
          child: AnimatedBuilder(
            animation: _play,
            builder: (_, _) => Container(
              height: 2.5,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(3)),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: i == _page && widget.active ? _play.value : 0.0,
                child: Container(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _action(IconData ic, String label, Color color, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Pressable(
      onTap: onTap,
      scale: 0.8,
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (c, a) => ScaleTransition(
              scale: CurvedAnimation(parent: a, curve: Curves.elasticOut),
              child: c,
            ),
            child: Icon(
              ic,
              key: ValueKey('$ic$color'),
              size: 30,
              color: color,
              shadows: const [Shadow(blurRadius: 12, color: Colors.black38)],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: sans(11, color: Colors.white, weight: FontWeight.w500),
          ),
        ],
      ),
    ),
  );
}
