import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets/ui.dart';

void snack(BuildContext context, String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));

/// Share sheet used by posts, events, jobs and ideas.
void showShareSheet(BuildContext context, String title, String link) => showModalBottomSheet(
  context: context,
  backgroundColor: Colors.transparent,
  builder: (ctx) => Container(
    padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(ctx).padding.bottom + 20),
    decoration: BoxDecoration(
      color: C.paper,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: C.line2, borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(height: 16),
        Text('Share', style: serif(32)),
        Text(
          title,
          style: sans(13, color: C.muted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final o in const [
              (Icons.link_rounded, 'Copy link'),
              (Icons.send_rounded, 'Message'),
              (Icons.chat_outlined, 'WhatsApp'),
              (Icons.work_outline_rounded, 'LinkedIn'),
              (Icons.more_horiz_rounded, 'More'),
            ])
              GestureDetector(
                onTap: () {
                  if (o.$2 == 'Copy link') Clipboard.setData(ClipboardData(text: link));
                  Navigator.of(ctx).pop();
                  snack(context, o.$2 == 'Copy link' ? 'Link copied' : 'Shared via ${o.$2}');
                },
                child: Column(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(color: C.bg2, shape: BoxShape.circle),
                      child: Icon(o.$1, color: C.ink, size: 22),
                    ),
                    const SizedBox(height: 6),
                    Text(o.$2, style: sans(11, color: C.muted)),
                  ],
                ),
              ),
          ],
        ),
      ],
    ),
  ),
);

/// Animated icon action (like / save) with a count.
class ActionIcon extends StatelessWidget {
  const ActionIcon({super.key, required this.icon, required this.activeIcon, required this.active, required this.onTap, this.label, this.activeColor});
  final IconData icon, activeIcon;
  final bool active;
  final VoidCallback onTap;
  final String? label;
  final Color? activeColor;
  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (c, a) => ScaleTransition(
              scale: CurvedAnimation(parent: a, curve: Curves.elasticOut),
              child: c,
            ),
            child: Icon(active ? activeIcon : icon, key: ValueKey(active), size: 20, color: active ? (activeColor ?? C.ink) : C.muted),
          ),
          if (label != null) ...[
            const SizedBox(width: 5),
            Text(
              label!,
              style: sans(13, color: active ? (activeColor ?? C.ink) : C.muted, weight: FontWeight.w500),
            ),
          ],
        ],
      ),
    ),
  );
}

const _red = Color(0xFFE0245E);

/// Post card in the feed. Tap the card for detail, the author for their profile.
class PostCard extends StatefulWidget {
  const PostCard({super.key, required this.post, this.onChanged});
  final Post post;
  final VoidCallback? onChanged;
  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  late final AnimationController _burst = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

  @override
  void dispose() {
    _burst.dispose();
    super.dispose();
  }

  void _like({bool force = false}) {
    final p = widget.post;
    setState(() {
      if (force && p.liked) return;
      p.liked = !p.liked;
      p.likes += p.liked ? 1 : -1;
    });
    Api.like(p);
  }

  Future<void> _open() async {
    await Navigator.of(context).push(fadeRoute(PostDetailScreen(post: widget.post)));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.post;
    return GestureDetector(
      onTap: _open,
      onDoubleTap: () {
        _like(force: true);
        _burst.forward(from: 0);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: C.line),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthorRow(
                  person: p.author,
                  meta: '${p.author.college} · ${p.time}',
                  trailing: Tag(p.src, bg: srcColor(p.src), fg: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(p.body, style: sans(15, height: 1.45)),
                const SizedBox(height: 12),
                LinkPreview(post: p),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ActionIcon(icon: Icons.favorite_border_rounded, activeIcon: Icons.favorite_rounded, active: p.liked, activeColor: _red, label: '${p.likes}', onTap: _like),
                    const SizedBox(width: 18),
                    ActionIcon(icon: Icons.mode_comment_outlined, activeIcon: Icons.mode_comment_rounded, active: false, label: '${p.comments.length}', onTap: _open),
                    const SizedBox(width: 18),
                    ActionIcon(
                      icon: Icons.ios_share_rounded,
                      activeIcon: Icons.ios_share_rounded,
                      active: false,
                      label: '${p.shares}',
                      onTap: () => showShareSheet(context, p.title, 'https://msw.community/p/${p.title.hashCode.abs()}'),
                    ),
                    const Spacer(),
                    ActionIcon(
                      icon: Icons.bookmark_border_rounded,
                      activeIcon: Icons.bookmark_rounded,
                      active: p.saved,
                      onTap: () {
                        setState(() => p.saved = !p.saved);
                        Api.save(p);
                        snack(context, p.saved ? 'Saved to your collection' : 'Removed from saved');
                      },
                    ),
                  ],
                ),
              ],
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _burst,
                  builder: (_, _) {
                    final v = _burst.value;
                    if (v == 0 || v == 1) return const SizedBox.shrink();
                    return Center(
                      child: Opacity(
                        opacity: (1 - math.max(0, v - 0.6) / 0.4).clamp(0, 1),
                        child: Transform.scale(
                          scale: Curves.elasticOut.transform(math.min(1, v * 1.6)) * 1.1,
                          child: const Icon(Icons.favorite_rounded, size: 96, color: _red),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthorRow extends StatelessWidget {
  const AuthorRow({super.key, required this.person, required this.meta, this.trailing, this.size = 40});
  final Person person;
  final String meta;
  final Widget? trailing;
  final double size;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      GestureDetector(
        onTap: () => Navigator.of(context).push(fadeRoute(PersonScreen(person: person))),
        child: Row(
          children: [
            GAvatar(person.initials, size: size, colors: person.grad),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(person.name, style: sans(14, weight: FontWeight.w600, height: 1.2)),
                Text(meta, style: sans(12, color: C.muted, height: 1.3)),
              ],
            ),
          ],
        ),
      ),
      const Spacer(),
      ?trailing,
    ],
  );
}

class LinkPreview extends StatelessWidget {
  const LinkPreview({super.key, required this.post});
  final Post post;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(color: C.bg, borderRadius: BorderRadius.circular(14)),
    child: Row(
      children: [
        Container(
          width: 64,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            gradient: LinearGradient(colors: post.grad),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: sans(14, weight: FontWeight.w600, height: 1.25),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(post.domain, style: mono(10)),
            ],
          ),
        ),
        Icon(Icons.open_in_new_rounded, size: 16, color: C.muted),
      ],
    ),
  );
}

/// Full post with comments.
class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.post});
  final Post post;
  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _ctl = TextEditingController();
  final _liked = <Comment>{};

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _send() {
    if (_ctl.text.trim().isEmpty) return;
    final c = Comment(me, _ctl.text.trim(), 'now');
    setState(() => widget.post.comments.add(c));
    Api.comment(widget.post, c);
    _ctl.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.post;
    final pad = MediaQuery.of(context).padding;
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, pad.top + 8, 16, 8),
            child: Row(
              children: [
                BackBtn(),
                const SizedBox(width: 12),
                Text('Post', style: serif(28)),
                const Spacer(),
                IconButton(
                  onPressed: () => showShareSheet(context, p.title, 'https://msw.community/p/${p.title.hashCode.abs()}'),
                  icon: Icon(Icons.ios_share_rounded, color: C.ink),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              children: [
                AuthorRow(
                  person: p.author,
                  meta: '${p.author.headline}\n${p.time} ago · via ${p.src}',
                  size: 48,
                  trailing: FollowButton(person: p.author),
                ),
                const SizedBox(height: 16),
                Text(p.body, style: sans(17, height: 1.5)),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    color: C.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: C.line),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: p.grad, begin: Alignment.topLeft, end: Alignment.bottomRight),
                        ),
                        child: Center(child: Icon(Icons.link_rounded, size: 40, color: Colors.white.withValues(alpha: 0.8))),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.domain.toUpperCase(), style: mono(10)),
                            const SizedBox(height: 4),
                            Text(p.title, style: serif(24, height: 1.1)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.symmetric(horizontal: BorderSide(color: C.line)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ActionIcon(
                        icon: Icons.favorite_border_rounded,
                        activeIcon: Icons.favorite_rounded,
                        active: p.liked,
                        activeColor: _red,
                        label: '${p.likes} likes',
                        onTap: () {
                          setState(() {
                            p.liked = !p.liked;
                            p.likes += p.liked ? 1 : -1;
                          });
                          Api.like(p);
                        },
                      ),
                      ActionIcon(icon: Icons.mode_comment_outlined, activeIcon: Icons.mode_comment_rounded, active: false, label: '${p.comments.length}', onTap: () {}),
                      ActionIcon(
                        icon: Icons.ios_share_rounded,
                        activeIcon: Icons.ios_share_rounded,
                        active: false,
                        label: 'Share',
                        onTap: () => showShareSheet(context, p.title, 'https://msw.community/p/${p.title.hashCode.abs()}'),
                      ),
                      ActionIcon(
                        icon: Icons.bookmark_border_rounded,
                        activeIcon: Icons.bookmark_rounded,
                        active: p.saved,
                        label: p.saved ? 'Saved' : 'Save',
                        onTap: () {
                          setState(() => p.saved = !p.saved);
                          Api.save(p);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('Comments · ${p.comments.length}', style: mono(11)),
                const SizedBox(height: 10),
                if (p.comments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text('Be the first to comment.', style: sans(14, color: C.muted)),
                  ),
                for (final c in p.comments)
                  Reveal(
                    offset: 10,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(fadeRoute(PersonScreen(person: c.author))),
                            child: GAvatar(c.author.initials, size: 34, colors: c.author.grad),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: C.bg2, borderRadius: BorderRadius.circular(16)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(c.author.name, style: sans(13, weight: FontWeight.w600)),
                                      const Spacer(),
                                      Text(c.time, style: sans(11, color: C.muted)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(c.text, style: sans(14, height: 1.4)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          ActionIcon(
                            icon: Icons.favorite_border_rounded,
                            activeIcon: Icons.favorite_rounded,
                            active: _liked.contains(c),
                            activeColor: _red,
                            label: '${c.likes}',
                            onTap: () => setState(() {
                              _liked.contains(c) ? _liked.remove(c) : _liked.add(c);
                              c.likes += _liked.contains(c) ? 1 : -1;
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 10, 10, pad.bottom + 10),
            decoration: BoxDecoration(
              color: C.paper,
              border: Border(top: BorderSide(color: C.line)),
            ),
            child: Row(
              children: [
                GAvatar(me.initials, size: 34, colors: me.grad),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _ctl,
                    onSubmitted: (_) => _send(),
                    style: sans(14),
                    decoration: InputDecoration(
                      hintText: 'Add a comment…',
                      hintStyle: sans(14, color: C.muted),
                      filled: true,
                      fillColor: C.bg2,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(99), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _send,
                  icon: Icon(Icons.send_rounded, color: C.ink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BackBtn extends StatelessWidget {
  const BackBtn({super.key, this.onImage = false});
  final bool onImage;
  @override
  Widget build(BuildContext context) => Pressable(
    onTap: () => Navigator.of(context).maybePop(),
    child: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: onImage ? Colors.black26 : C.card,
        shape: BoxShape.circle,
        border: Border.all(color: onImage ? Colors.white24 : C.line),
      ),
      child: Icon(Icons.arrow_back_rounded, size: 18, color: onImage ? Colors.white : C.ink),
    ),
  );
}

class FollowButton extends StatefulWidget {
  const FollowButton({super.key, required this.person});
  final Person person;
  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  @override
  Widget build(BuildContext context) {
    if (widget.person == me) return const SizedBox.shrink();
    final on = widget.person.followed;
    return Pressable(
      onTap: () => setState(() => widget.person.followed = !on),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(color: on ? C.bg2 : C.ink, borderRadius: BorderRadius.circular(99)),
        child: Text(
          on ? 'Following' : 'Follow',
          style: sans(13, weight: FontWeight.w600, color: on ? C.ink : C.onInk),
        ),
      ),
    );
  }
}

/// Public profile of any community member.
class PersonScreen extends StatelessWidget {
  const PersonScreen({super.key, required this.person});
  final Person person;

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    final theirPosts = posts.where((p) => p.author == person).toList();
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, pad.top + 8, 20, pad.bottom + 30),
        children: [
          Row(
            children: [
              BackBtn(),
              const Spacer(),
              IconButton(
                onPressed: () => showShareSheet(context, person.name, 'https://msw.community/${person.name.split(' ').first.toLowerCase()}'),
                icon: Icon(Icons.ios_share_rounded, color: C.ink),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF161616), Color(0xFF232826), Color(0xFF0F1412)]),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GAvatar(person.initials, size: 72, radius: 20, colors: person.grad),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.verified_rounded, color: C.teal, size: 16),
                        const SizedBox(width: 4),
                        Text('VERIFIED · ${person.college.toUpperCase()}', style: mono(9, color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(person.name, style: serif(38, color: Colors.white)),
                Text(person.headline, style: sans(14, color: Colors.white70)),
                Text(person.course, style: mono(10, color: C.teal)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    for (final s in [('Level', '${person.level}'), ('IQ', '${person.iq}'), ('GitHub', '${person.gh}'), ('Hacks', '${person.hackathons}')])
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.$2, style: serif(24, color: Colors.white)),
                              Text(s.$1, style: sans(10, color: Colors.white60)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (person != me) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _FollowWide(person: person)),
                const SizedBox(width: 10),
                Expanded(
                  child: PrimaryButton('Message', bg: C.bg2, fg: C.ink, icon: false, height: 50, onTap: () => snack(context, 'Chat with ${person.name.split(' ').first} — coming soon')),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          Text('ABOUT', style: mono(10)),
          const SizedBox(height: 6),
          Text(person.bio, style: sans(15, height: 1.5)),
          const SizedBox(height: 14),
          Wrap(spacing: 6, runSpacing: 6, children: [for (final s in person.skills) Tag(s)]),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('${fmtNum(person.followers + (person.followed ? 1 : 0))} followers', style: sans(13, weight: FontWeight.w600)),
              const SizedBox(width: 14),
              Text('${person.hackathons} hackathons', style: sans(13, color: C.muted)),
            ],
          ),
          const SizedBox(height: 20),
          Text('POSTS', style: mono(10)),
          const SizedBox(height: 10),
          if (theirPosts.isEmpty) Text('No posts yet.', style: sans(14, color: C.muted)),
          for (final p in theirPosts)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PostCard(post: p),
            ),
        ],
      ),
    );
  }
}

class _FollowWide extends StatefulWidget {
  const _FollowWide({required this.person});
  final Person person;
  @override
  State<_FollowWide> createState() => _FollowWideState();
}

class _FollowWideState extends State<_FollowWide> {
  @override
  Widget build(BuildContext context) => PrimaryButton(
    widget.person.followed ? 'Following' : 'Follow',
    icon: false,
    height: 50,
    bg: widget.person.followed ? C.bg2 : null,
    fg: widget.person.followed ? C.ink : null,
    onTap: () => setState(() => widget.person.followed = !widget.person.followed),
  );
}

/// Fake "screenshot" thumbnail for uploaded work (UI prototype).
class MockShot extends StatelessWidget {
  const MockShot(this.seed, {super.key, this.w = 96, this.h = 132});
  final int seed;
  final double w, h;
  @override
  Widget build(BuildContext context) {
    const tints = [C.teal, C.lilac, C.peach, C.sky, C.lime];
    final t = tints[seed % tints.length];
    return Container(
      width: w,
      height: h,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.line2),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (final c in const [Color(0xFFFF5F57), Color(0xFFFEBC2E), Color(0xFF28C840)])
                Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.only(right: 3),
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: h * 0.28,
            decoration: BoxDecoration(color: t, borderRadius: BorderRadius.circular(6)),
          ),
          const SizedBox(height: 6),
          for (final f in [0.9, 0.6, 0.75, 0.5])
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              height: 4,
              width: (w - 12) * f,
              decoration: BoxDecoration(color: const Color(0xFFE6E4DF), borderRadius: BorderRadius.circular(2)),
            ),
          const Spacer(),
          Container(
            height: 10,
            width: (w - 12) * 0.45,
            decoration: BoxDecoration(color: const Color(0xFF121212), borderRadius: BorderRadius.circular(5)),
          ),
        ],
      ),
    );
  }
}
