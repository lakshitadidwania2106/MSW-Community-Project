import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';
import 'explore.dart';
import 'feed.dart';
import 'grow.dart';
import 'profile.dart';
import 'reels.dart';

/// App frame: five tabs + a floating pill nav whose active item expands.
class Shell extends StatefulWidget {
  const Shell({super.key, required this.role});
  final RoleInfo role;
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _tab = 0;
  static const _items = [
    (Icons.dynamic_feed_rounded, 'Feed'),
    (Icons.explore_rounded, 'Explore'),
    (Icons.play_circle_fill_rounded, 'Reels'),
    (Icons.auto_graph_rounded, 'Grow'),
    (Icons.badge_rounded, 'ID'),
  ];

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    final pages = [
      FeedScreen(role: widget.role, onOpenReels: () => setState(() => _tab = 2)),
      const ExploreScreen(),
      ReelsScreen(active: _tab == 2),
      const GrowScreen(),
      ProfileScreen(role: widget.role),
    ];
    return Scaffold(
      extendBody: true,
      backgroundColor: _tab == 2 ? C.dark : C.bg,
      body: Stack(children: [
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            switchInCurve: Curves.easeOutCubic,
            transitionBuilder: (c, a) => FadeTransition(opacity: a, child: SlideTransition(position: Tween(begin: const Offset(0, 0.02), end: Offset.zero).animate(a), child: c)),
            child: KeyedSubtree(key: ValueKey(_tab), child: pages[_tab]),
          ),
        ),
        Positioned(left: 16, right: 16, bottom: pad.bottom + 10, child: _nav()),
      ]),
    );
  }

  Widget _nav() {
    final onReels = _tab == 2;
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: onReels ? Colors.white.withValues(alpha: 0.12) : C.ink,
        borderRadius: BorderRadius.circular(99),
        border: onReels ? Border.all(color: Colors.white24) : null,
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 30, offset: Offset(0, 12))],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        for (var i = 0; i < _items.length; i++)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _tab = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              height: 48,
              padding: EdgeInsets.symmetric(horizontal: i == _tab ? 16 : 12),
              decoration: BoxDecoration(color: i == _tab ? C.teal : Colors.transparent, borderRadius: BorderRadius.circular(99)),
              child: Row(children: [
                Icon(_items[i].$1, size: 22, color: i == _tab ? C.ink : C.onDark.withValues(alpha: 0.7)),
                AnimatedSize(
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
                  child: i == _tab
                      ? Padding(padding: const EdgeInsets.only(left: 8), child: Text(_items[i].$2, style: sans(13, weight: FontWeight.w600)))
                      : const SizedBox.shrink(),
                ),
              ]),
            ),
          ),
      ]),
    );
  }
}
