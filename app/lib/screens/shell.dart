import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';
import 'dash/admin.dart';
import 'dash/college.dart';
import 'dash/company.dart';
import 'dash/investor.dart';
import 'compose.dart';
import 'explore.dart';
import 'feed.dart';
import 'grow.dart';
import 'profile.dart';
import 'reels.dart';

typedef TabSpec = (IconData, String, Widget Function(bool active, ValueChanged<int> go));

/// Each role gets its own app: its own tabs, screens and accent colour.
class Shell extends StatelessWidget {
  const Shell({super.key, required this.role});
  final RoleInfo role;

  @override
  Widget build(BuildContext context) => switch (role.role) {
    Role.student => RoleShell(
      accent: C.teal,
      darkTab: 3,
      tabs: [
        (Icons.dynamic_feed_rounded, 'Feed', (a, go) => FeedScreen(role: role, onOpenReels: () => go(3))),
        (Icons.explore_rounded, 'Explore', (a, go) => const ExploreScreen()),
        (Icons.add_rounded, 'Post', (a, go) => ComposeScreen(onPosted: () => go(0))),
        (Icons.play_circle_fill_rounded, 'Reels', (a, go) => ReelsScreen(active: a)),
        (Icons.auto_graph_rounded, 'Grow', (a, go) => const GrowScreen()),
        (Icons.badge_rounded, 'ID', (a, go) => ProfileScreen(role: role)),
      ],
    ),
    Role.company => RoleShell(
      accent: role.color,
      tabs: [
        (Icons.space_dashboard_rounded, 'Home', (a, go) => CompanyHome(go: go)),
        (Icons.work_rounded, 'Jobs', (a, go) => const CompanyJobs()),
        (Icons.people_alt_rounded, 'People', (a, go) => const CompanyApplicants()),
        (Icons.task_alt_rounded, 'Tasks', (a, go) => const CompanyTasks()),
        (Icons.business_rounded, 'Account', (a, go) => const CompanyAccount()),
      ],
    ),
    Role.investor => RoleShell(
      accent: role.color,
      tabs: [
        (Icons.space_dashboard_rounded, 'Home', (a, go) => InvestorHome(go: go)),
        (Icons.style_rounded, 'Deals', (a, go) => const InvestorDeals()),
        (Icons.pie_chart_rounded, 'Portfolio', (a, go) => const InvestorPortfolio()),
        (Icons.person_rounded, 'Account', (a, go) => const InvestorAccount()),
      ],
    ),
    Role.college => RoleShell(
      accent: role.color,
      tabs: [
        (Icons.space_dashboard_outlined, 'Home', (a, go) => CollegeHome(go: go)),
        (Icons.event_outlined, 'Events', (a, go) => const CollegeEvents()),
        (Icons.campaign_outlined, 'Announce', (a, go) => const CollegeAnnouncements()),
        (Icons.account_balance_outlined, 'Account', (a, go) => const CollegeAccount()),
      ],
    ),
    Role.admin => RoleShell(
      accent: role.color,
      tabs: [
        (Icons.radar_rounded, 'Control', (a, go) => AdminHome(go: go)),
        (Icons.dynamic_feed_outlined, 'Content', (a, go) => const AdminContent()),
        (Icons.manage_accounts_outlined, 'Users', (a, go) => const AdminUsers()),
        (Icons.quiz_outlined, 'Quizzes', (a, go) => const AdminQuizzes()),
        (Icons.settings_outlined, 'Account', (a, go) => const AdminAccount()),
      ],
    ),
  };
}

/// Tab frame with a floating pill nav whose active item expands.
class RoleShell extends StatefulWidget {
  const RoleShell({super.key, required this.tabs, required this.accent, this.darkTab});
  final List<TabSpec> tabs;
  final Color accent;
  final int? darkTab;
  @override
  State<RoleShell> createState() => _RoleShellState();
}

class _RoleShellState extends State<RoleShell> {
  int _tab = 0;
  void _go(int i) => setState(() => _tab = i);

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    final onDarkTab = _tab == widget.darkTab;
    return Scaffold(
      extendBody: true,
      backgroundColor: onDarkTab ? C.dark : C.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              switchInCurve: Curves.easeOutCubic,
              transitionBuilder: (c, a) => FadeTransition(
                opacity: a,
                child: SlideTransition(
                  position: Tween(begin: const Offset(0, 0.02), end: Offset.zero).animate(a),
                  child: c,
                ),
              ),
              child: KeyedSubtree(key: ValueKey(_tab), child: widget.tabs[_tab].$3(true, _go)),
            ),
          ),
          Positioned(left: 16, right: 16, bottom: pad.bottom + 10, child: _nav(onDarkTab)),
        ],
      ),
    );
  }

  Widget _nav(bool onDarkTab) {
    final barColor = onDarkTab ? Colors.white.withValues(alpha: 0.12) : (darkMode.value ? const Color(0xFF26262C) : C.black);
    final selFg = widget.accent.computeLuminance() > 0.45 ? C.black : Colors.white;
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: barColor,
        borderRadius: BorderRadius.circular(99),
        border: onDarkTab || darkMode.value ? Border.all(color: Colors.white24) : null,
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 30, offset: Offset(0, 12))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < widget.tabs.length; i++)
            if (widget.tabs[i].$2 == 'Post' && i != _tab)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _go(i),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: C.lime,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: C.lime.withValues(alpha: 0.35), blurRadius: 12)],
                  ),
                  child: const Icon(Icons.add_rounded, color: C.black, size: 26),
                ),
              )
            else
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _go(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
                  height: 48,
                  padding: EdgeInsets.symmetric(horizontal: i == _tab ? 14 : (widget.tabs.length > 5 ? 9 : 12)),
                  decoration: BoxDecoration(color: i == _tab ? widget.accent : Colors.transparent, borderRadius: BorderRadius.circular(99)),
                  child: Row(
                    children: [
                      Icon(widget.tabs[i].$1, size: 22, color: i == _tab ? selFg : C.onDark.withValues(alpha: 0.7)),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeOutCubic,
                        child: i == _tab
                            ? Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  widget.tabs[i].$2,
                                  style: sans(13, color: selFg, weight: FontWeight.w600),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
