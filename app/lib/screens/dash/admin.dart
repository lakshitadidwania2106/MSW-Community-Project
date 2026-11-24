import 'dart:async';

import 'package:flutter/material.dart';

import '../../api.dart';
import '../../data.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';
import '../details.dart';
import '../post.dart';
import 'common.dart';

/// ===================== ADMIN — full control =====================
final _adm = roles[4];
Color get _c => _adm.color;
const _notes = [
  (Icons.flag_outlined, '3 posts reported in the last hour'),
  (Icons.person_add_alt_outlined, '612 new students this week'),
  (Icons.verified_outlined, 'Kite AI updated their company profile'),
];
const _danger = Color(0xFFE5484D);
String _slug(String n) => n.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');

Future<bool> confirm(BuildContext context, String title, String body, {String cta = 'Delete'}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: C.paper,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(title, style: serif(28)),
      content: Text(body, style: sans(14, color: C.ink2)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text('Cancel', style: sans(14, color: C.muted)),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(
            cta,
            style: sans(14, weight: FontWeight.w700, color: _danger),
          ),
        ),
      ],
    ),
  );
  return r ?? false;
}

/* ───────────── Control: total stats ───────────── */

class AdminHome extends StatefulWidget {
  const AdminHome({super.key, required this.go});
  final ValueChanged<int> go;
  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  static const _events = [
    (Icons.school_outlined, 'New student signed up', 'Ishaan M. · IIT Delhi'),
    (Icons.work_outline_rounded, 'Kite AI posted a role', 'ML Research Intern'),
    (Icons.trending_up_rounded, 'Idea backed', 'Nikhil V. → Krishi · ₹2L'),
    (Icons.task_alt_rounded, 'Task submitted', 'Rohan K. · Accessibility audit'),
    (Icons.local_fire_department_outlined, 'Day 30 completed', 'Sana K. finished MSW Labs'),
    (Icons.emoji_events_outlined, 'Hackathon registration', 'Team Byte Me · HackNova'),
    (Icons.psychology_outlined, 'IQ test finished', 'Dev S. scored 118'),
  ];
  final _feed = <(IconData, String, String, int)>[];
  int _k = 0;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 4; i++) {
      _push();
    }
    _t = Timer.periodic(const Duration(milliseconds: 2600), (_) => setState(_push));
  }

  void _push() {
    final e = _events[_k % _events.length];
    _feed.insert(0, (e.$1, e.$2, e.$3, _k++));
    if (_feed.length > 5) _feed.removeLast();
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    final comments = posts.fold<int>(0, (a, p) => a + p.comments.length);
    final stats = [
      ('Students', 12460.0, '612 this week', Icons.school_outlined),
      ('Companies', 640.0, '38 this week', Icons.business_outlined),
      ('Colleges', 124.0, '6 new', Icons.account_balance_outlined),
      ('Investors', 312.0, '₹4.2Cr committed', Icons.trending_up_rounded),
      ('Posts', 18240.0 + posts.length, '${posts.length} in feed now', Icons.dynamic_feed_outlined),
      ('Comments', 64110.0 + comments, '+1.2k today', Icons.mode_comment_outlined),
      ('Jobs & internships', opportunities.length + 860.0, '${opportunities.where((o) => o.live).length} featured live', Icons.work_outline_rounded),
      ('Hackathons & events', events.length + 210.0, '${events.length} upcoming', Icons.emoji_events_outlined),
      ('Tasks paid', 1420.0, '₹31.6L paid out', Icons.payments_outlined),
      ('Credits issued', 2840000.0, 'All-time', Icons.toll_outlined),
    ];
    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 110),
      children: [
        DashHeader(role: _adm, a: 'Mission ', b: 'control.', sub: 'Total stats across MSW Community', notes: _notes),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.35,
          children: [for (final s in stats) StatTile(label: s.$1, value: s.$2, accent: _c, delta: s.$3, icon: s.$4)],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: C.dark, borderRadius: BorderRadius.circular(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Live activity', style: serif(26, color: C.onDark)),
                  const Spacer(),
                  const _Pulse(),
                  const SizedBox(width: 6),
                  Text('LIVE', style: mono(10, color: C.teal)),
                ],
              ),
              const SizedBox(height: 10),
              for (final f in _feed)
                TweenAnimationBuilder<double>(
                  key: ValueKey(f.$4),
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, child) => Opacity(
                    opacity: v,
                    child: Transform.translate(offset: Offset(0, (1 - v) * -12), child: child),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(11)),
                          child: Icon(f.$1, size: 18, color: C.teal),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f.$2,
                                style: sans(14, color: C.onDark, weight: FontWeight.w600, height: 1.2),
                              ),
                              Text('${f.$3} · just now', style: sans(12, color: Colors.white54)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ChartCard(
          a: 'Sign-ups',
          b: 'this year',
          series: [
            ('Students', _c, const [180, 240, 210, 320, 380, 360, 440, 520, 480, 590, 640, 612]),
            ('Organisations', const Color(0xFF6C5CE7), const [8, 12, 10, 15, 18, 17, 22, 26, 24, 31, 36, 44]),
          ],
          labels: const ['Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov'],
        ),
        const SectionTitle('MSW Labs', b: 'funnel'),
        Card2(child: BarList(const [('Day 1', 9800), ('Day 7', 7200), ('Day 14', 5100), ('Day 21', 3900), ('Day 30', 2640)], color: _c)),
      ],
    );
  }
}

class _Pulse extends StatefulWidget {
  const _Pulse();
  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _a = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _a,
    builder: (_, _) => Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: C.teal,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: C.teal.withValues(alpha: 0.6 * (1 - _a.value)),
            spreadRadius: 8 * _a.value,
          ),
        ],
      ),
    ),
  );
}

/* ───────────── Content: posts, comments, listings ───────────── */

class AdminContent extends StatefulWidget {
  const AdminContent({super.key});
  @override
  State<AdminContent> createState() => _AdminContentState();
}

class _AdminContentState extends State<AdminContent> {
  int _seg = 0;
  final _hidden = <Post>{}, _pinned = <Post>{};

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    final allComments = [
      for (final p in posts)
        for (final c in p.comments) (p, c),
    ];
    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 110),
      children: [
        DashHeader(role: _adm, a: 'Content ', b: 'control.', sub: 'Override or remove anything on the platform', notes: _notes),
        const SizedBox(height: 16),
        ChipBar(
          items: ['Posts · ${posts.length}', 'Comments · ${allComments.length}', 'Listings · ${opportunities.length + events.length + ctasks.length}'],
          sel: _seg,
          onSel: (i) => setState(() => _seg = i),
          color: _c,
        ),
        const SizedBox(height: 14),
        if (_seg == 0)
          for (final p in posts)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _hidden.contains(p) ? 0.45 : 1,
                child: Card2(
                  color: C.card,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AuthorRow(
                        person: p.author,
                        meta: '${p.author.college} · ${p.time}',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_pinned.contains(p))
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Icon(Icons.push_pin_rounded, size: 16, color: _c),
                              ),
                            if (_hidden.contains(p)) const Tag('Hidden', bg: C.peach),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(p.body, style: sans(14, height: 1.45)),
                      const SizedBox(height: 6),
                      Text('${p.likes} likes · ${p.comments.length} comments · via ${p.src}', style: sans(12, color: C.muted)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _act(Icons.visibility_outlined, 'View', () async {
                            await Navigator.of(context).push(fadeRoute(PostDetailScreen(post: p)));
                            setState(() {});
                          }),
                          _act(
                            _pinned.contains(p) ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                            _pinned.contains(p) ? 'Unpin' : 'Pin',
                            () => setState(() => _pinned.contains(p) ? _pinned.remove(p) : _pinned.add(p)),
                          ),
                          _act(
                            _hidden.contains(p) ? Icons.visibility_rounded : Icons.visibility_off_outlined,
                            _hidden.contains(p) ? 'Unhide' : 'Hide',
                            () => setState(() => _hidden.contains(p) ? _hidden.remove(p) : _hidden.add(p)),
                          ),
                          _act(Icons.delete_outline_rounded, 'Delete', () async {
                            if (await confirm(context, 'Delete post?', 'This removes the post by ${p.author.name} and all ${p.comments.length} comments for everyone.')) {
                              setState(() => posts.remove(p));
                              Api.deletePost(p);
                              if (context.mounted) toast(context, 'Post deleted');
                            }
                          }, danger: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        if (_seg == 1) ...[
          if (allComments.isEmpty) Text('No comments.', style: sans(14, color: C.muted)),
          for (final pc in allComments)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card2(
                color: C.card,
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GAvatar(pc.$2.author.initials, size: 36, colors: pc.$2.author.grad),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${pc.$2.author.name} on ${pc.$1.author.name.split(' ').first}’s post', style: sans(13, weight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(pc.$2.text, style: sans(14, height: 1.4)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        if (await confirm(context, 'Delete comment?', '“${pc.$2.text}”')) {
                          setState(() => pc.$1.comments.remove(pc.$2));
                          Api.deleteComment(pc.$2);
                          if (context.mounted) toast(context, 'Comment deleted');
                        }
                      },
                      icon: const Icon(Icons.delete_outline_rounded, color: _danger),
                    ),
                  ],
                ),
              ),
            ),
        ],
        if (_seg == 2) ...[
          for (final o in List.of(opportunities))
            _listing(Icons.work_outline_rounded, o.title, '${o.company} · ${o.internship ? 'Internship' : 'Job'}', () => Navigator.of(context).push(fadeRoute(OpportunityDetailScreen(o: o))), () {
              setState(() => opportunities.remove(o));
              Api.deleteOpportunity(o);
            }),
          for (final e in List.of(events))
            _listing(Icons.emoji_events_outlined, e.title, '${e.organiser} · ${e.type}', () => Navigator.of(context).push(fadeRoute(EventDetailScreen(e: e))), () {
              setState(() => events.remove(e));
              Api.deleteEvent(e);
            }),
          for (final t in List.of(ctasks))
            _listing(Icons.code_rounded, t.title, '${t.company} · Task · ₹${fmtNum(t.reward)}', () => Navigator.of(context).push(fadeRoute(TaskDetailScreen(t: t))), () {
              setState(() => ctasks.remove(t));
              Api.deleteTask(t);
            }),
        ],
      ],
    );
  }

  Widget _act(IconData ic, String label, VoidCallback onTap, {bool danger = false}) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(color: danger ? _danger.withValues(alpha: 0.1) : C.bg2, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(ic, size: 18, color: danger ? _danger : C.ink),
            const SizedBox(height: 2),
            Text(
              label,
              style: sans(11, weight: FontWeight.w600, color: danger ? _danger : C.ink),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _listing(IconData ic, String title, String sub, VoidCallback onView, VoidCallback onDelete) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Card2(
      color: C.card,
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: C.bg2, borderRadius: BorderRadius.circular(12)),
            child: Icon(ic, size: 19, color: C.ink),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: sans(14, weight: FontWeight.w600, height: 1.2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(sub, style: sans(12, color: C.muted)),
              ],
            ),
          ),
          IconButton(
            onPressed: onView,
            icon: Icon(Icons.visibility_outlined, color: C.muted),
          ),
          IconButton(
            onPressed: () async {
              if (await confirm(context, 'Take down listing?', '“$title” will be removed for everyone.', cta: 'Take down')) {
                onDelete();
                if (mounted) toast(context, 'Listing removed');
              }
            },
            icon: const Icon(Icons.delete_outline_rounded, color: _danger),
          ),
        ],
      ),
    ),
  );
}

/* ───────────── Users: every account ───────────── */

class Account {
  Account(this.name, this.type, this.where, this.status);
  final String name, type, where;
  String status; // Active · Verified · Suspended
  bool admin = false;
}

final accounts = [
  Account('Aanya Sharma', 'Student', 'IIT Delhi', 'Verified'),
  Account('Rohan Kapoor', 'Student', 'NIT Trichy', 'Verified'),
  Account('Meera Joshi', 'Student', 'IIT Kharagpur', 'Verified'),
  Account('Dev Shah', 'Student', 'VIT', 'Active'),
  Account('spam_bot_221', 'Student', '—', 'Suspended'),
  Account('Lumen Labs', 'Company', 'Bengaluru', 'Verified'),
  Account('Kite AI', 'Company', 'Bengaluru', 'Active'),
  Account('Nikhil Varma', 'Investor', 'Angel · Bengaluru', 'Verified'),
  Account('IIT Bombay E-Cell', 'College', 'Mumbai', 'Verified'),
];

class AdminUsers extends StatefulWidget {
  const AdminUsers({super.key});
  @override
  State<AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends State<AdminUsers> {
  int _f = 0;
  String _q = '';
  static const _filters = ['All', 'Student', 'Company', 'Investor', 'College'];

  void _manage(Account a) => sheet(
    context,
    StatefulBuilder(
      builder: (ctx, setS) {
        void act(String msg, VoidCallback fn) {
          setState(fn);
          setS(() {});
          toast(context, msg);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(a.type.toUpperCase(), style: mono(10)),
            Text(a.name, style: serif(34)),
            Text('${a.where} · ${a.status}${a.admin ? ' · Admin' : ''}', style: sans(13, color: C.muted)),
            const SizedBox(height: 16),
            for (final o in [
              (
                Icons.verified_outlined,
                a.status == 'Verified' ? 'Remove verification' : 'Verify account',
                () => act('${a.name} ${a.status == 'Verified' ? 'unverified' : 'verified'}', () {
                  a.status = a.status == 'Verified' ? 'Active' : 'Verified';
                  Api.patchUser(_slug(a.name), {'status': a.status});
                }),
              ),
              (
                Icons.block_rounded,
                a.status == 'Suspended' ? 'Restore account' : 'Suspend account',
                () => act('${a.name} ${a.status == 'Suspended' ? 'restored' : 'suspended'}', () {
                  a.status = a.status == 'Suspended' ? 'Active' : 'Suspended';
                  Api.patchUser(_slug(a.name), {'status': a.status});
                }),
              ),
              (
                Icons.admin_panel_settings_outlined,
                a.admin ? 'Remove admin rights' : 'Make admin',
                () => act(a.admin ? 'Admin rights removed' : '${a.name} is now an admin', () {
                  a.admin = !a.admin;
                  Api.patchUser(_slug(a.name), {'is_admin': a.admin});
                }),
              ),
              (Icons.lock_reset_rounded, 'Force password reset', () => act('Reset link sent to ${a.name}', () {})),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Pressable(
                  onTap: o.$3,
                  child: Card2(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Icon(o.$1, color: C.ink),
                        const SizedBox(width: 12),
                        Text(o.$2, style: sans(14, weight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 4),
            PrimaryButton(
              'Delete account',
              bg: _danger,
              icon: false,
              onTap: () async {
                if (await confirm(ctx, 'Delete ${a.name}?', 'Their profile, posts, comments and applications are removed permanently.')) {
                  setState(() {
                    accounts.remove(a);
                    Api.deleteUser(_slug(a.name));
                    posts.removeWhere((p) => p.author.name == a.name);
                  });
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  if (mounted) toast(context, '${a.name} deleted');
                }
              },
            ),
          ],
        );
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    final list = accounts.where((a) => (_f == 0 || a.type == _filters[_f]) && a.name.toLowerCase().contains(_q.toLowerCase())).toList();
    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 110),
      children: [
        DashHeader(role: _adm, a: 'Every ', b: 'account.', sub: '${accounts.length} shown · full permissions', notes: _notes),
        const SizedBox(height: 16),
        TextField(
          onChanged: (v) => setState(() => _q = v),
          decoration: fieldDec('Search accounts', icon: Icons.search_rounded),
        ),
        const SizedBox(height: 12),
        ChipBar(items: _filters, sel: _f, onSel: (i) => setState(() => _f = i), color: _c),
        const SizedBox(height: 14),
        for (final a in list)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Pressable(
              scale: 0.98,
              onTap: () => _manage(a),
              child: Card2(
                color: C.card,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    GAvatar(a.name[0].toUpperCase(), size: 40, colors: [_c, C.lilac]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  a.name,
                                  style: sans(14, weight: FontWeight.w600, height: 1.2),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (a.status == 'Verified')
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Icon(Icons.verified_rounded, size: 15, color: C.tealD),
                                ),
                              if (a.admin)
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Icon(Icons.admin_panel_settings_rounded, size: 15, color: _c),
                                ),
                            ],
                          ),
                          Text('${a.type} · ${a.where}', style: sans(12, color: C.muted)),
                        ],
                      ),
                    ),
                    Tag(a.status, bg: a.status == 'Suspended' ? const Color(0xFFFFC9C9) : (a.status == 'Verified' ? C.teal : null)),
                    Icon(Icons.more_vert_rounded, color: C.muted),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/* ───────────── Quizzes & badges ───────────── */

class AdminQuizzes extends StatefulWidget {
  const AdminQuizzes({super.key});
  @override
  State<AdminQuizzes> createState() => _AdminQuizzesState();
}

class _AdminQuizzesState extends State<AdminQuizzes> {
  final _quizzes = [
    ['IQ test', 5, 4210, true],
    ['Reasoning', 10, 2890, true],
    ['Daily quiz — Nov 24', 5, 1120, true],
    ['Aptitude', 15, 1840, true],
    ['React fundamentals', 12, 0, false],
  ];

  void _builder() {
    final name = TextEditingController(text: 'JavaScript basics');
    var qs = 2;
    sheet(
      context,
      StatefulBuilder(
        builder: (ctx, setS) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Headline('Build a ', 'quiz.', size: 34, italicColor: _c),
            const SizedBox(height: 14),
            TextField(controller: name, decoration: fieldDec('Quiz name')),
            const SizedBox(height: 12),
            for (var q = 0; q < qs; q++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card2(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('QUESTION ${q + 1}', style: mono(9, color: _c)),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Type the question…',
                          hintStyle: sans(14, color: C.muted),
                          border: InputBorder.none,
                        ),
                      ),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final o in const ['A', 'B', 'C', 'D']) Tag(o == 'A' ? 'Option $o · correct' : 'Option $o', bg: o == 'A' ? C.lime : null),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            TextButton.icon(
              onPressed: () => setS(() => qs++),
              icon: Icon(Icons.add_rounded, color: _c),
              label: Text(
                'Add question',
                style: sans(14, color: _c, weight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              'Publish quiz',
              bg: _c,
              onTap: () {
                setState(() => _quizzes.insert(0, [name.text, qs, 0, true]));
                Navigator.of(ctx).pop();
                toast(context, 'Quiz published to the app');
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
    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 110),
      children: [
        DashHeader(role: _adm, a: 'Quizzes ', b: '& badges.', notes: _notes),
        const SizedBox(height: 16),
        PrimaryButton('Build a quiz', bg: _c, onTap: _builder),
        const SizedBox(height: 14),
        for (final q in _quizzes)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card2(
              padding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(q[0] as String, style: sans(15, weight: FontWeight.w600, height: 1.2)),
                        Text('${q[1]} questions · ${fmtNum(q[2] as int)} plays', style: sans(12, color: C.muted)),
                      ],
                    ),
                  ),
                  Switch.adaptive(value: q[3] as bool, activeTrackColor: _c, onChanged: (v) => setState(() => q[3] = v)),
                  IconButton(
                    onPressed: () async {
                      if (await confirm(context, 'Delete quiz?', '“${q[0]}” and its scores will be removed.')) setState(() => _quizzes.remove(q));
                    },
                    icon: const Icon(Icons.delete_outline_rounded, color: _danger),
                  ),
                ],
              ),
            ),
          ),
        const SectionTitle('Badges'),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            for (final b in badges)
              Card2(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(b.icon, size: 28, color: _c),
                    const SizedBox(height: 6),
                    Text(
                      b.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: sans(11, weight: FontWeight.w600, height: 1.15),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class AdminAccount extends StatelessWidget {
  const AdminAccount({super.key});
  @override
  Widget build(BuildContext context) => AccountTab(role: _adm, name: 'MSW Admin', sub: 'Full access · all permissions', initials: 'MA');
}
