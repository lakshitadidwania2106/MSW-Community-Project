import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';
import '../widgets/ui.dart';

/// Home feed: stories, "paste a link → get a post" composer, posts.
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key, required this.role, required this.onOpenReels});
  final RoleInfo role;
  final VoidCallback onOpenReels;
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  static const _stories = ['MSW Labs', 'HackNova', 'Design', 'Climate', 'FinTech', 'Meetups'];

  void _openComposer() async {
    final post = await showModalBottomSheet<Post>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _PasteSheet(),
    );
    if (post != null) {
      setState(() => posts.insert(0, post));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Posted to the community ✓')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    final hour = DateTime.now().hour;
    final greet = hour < 12 ? 'Good morning' : (hour < 17 ? 'Good afternoon' : 'Good evening');
    return ListView(
      padding: EdgeInsets.fromLTRB(0, pad.top + 10, 0, pad.bottom + 110),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Text.rich(TextSpan(children: [
              TextSpan(text: 'MSW', style: serif(30)),
              TextSpan(text: '.', style: serif(30, color: C.tealD)),
            ])),
            const Spacer(),
            _iconBtn(Icons.search_rounded),
            const SizedBox(width: 8),
            Stack(clipBehavior: Clip.none, children: [
              _iconBtn(Icons.notifications_none_rounded),
              Positioned(right: 9, top: 9, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFFF5A5F), shape: BoxShape.circle))),
            ]),
          ]),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Reveal(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${greet.toUpperCase()}, AANYA', style: mono(11)),
              const SizedBox(height: 6),
              const Headline('What are you ', 'building today?', size: 40),
            ]),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _stories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (_, i) => Reveal(delay: 100 + i * 60, offset: 14, child: _story(i)),
          ),
        ),
        const SizedBox(height: 14),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Reveal(delay: 200, child: _composer())),
        const SizedBox(height: 14),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Reveal(delay: 260, child: _continueLearning())),
        const SizedBox(height: 6),
        for (var i = 0; i < posts.length; i++)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Reveal(delay: 320 + i * 90, child: PostCard(key: ObjectKey(posts[i]), post: posts[i])),
          ),
      ],
    );
  }

  Widget _iconBtn(IconData ic) => Pressable(
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(color: C.paper, shape: BoxShape.circle, border: Border.all(color: C.line)),
          child: Icon(ic, size: 20),
        ),
      );

  Widget _story(int i) => Pressable(
        onTap: i == 0 ? widget.onOpenReels : null,
        child: Column(children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(colors: i == 0 ? const [C.teal, C.lime, C.teal] : const [Color(0xFFFF7AD9), C.peach, C.lime, Color(0xFFFF7AD9)]),
            ),
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: const BoxDecoration(color: C.bg, shape: BoxShape.circle),
              child: ClipOval(
                child: i == 0
                    ? Container(color: C.ink, alignment: Alignment.center, child: Text('M.', style: serif(26, color: C.teal)))
                    : Image.network(photo(i + 3, w: 160, h: 160), fit: BoxFit.cover, errorBuilder: (_, _, _) => Container(color: C.bg2)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(_stories[i], style: sans(11, color: C.ink2, weight: FontWeight.w500)),
        ]),
      );

  Widget _composer() => Pressable(
        onTap: _openComposer,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          decoration: BoxDecoration(color: C.paper, borderRadius: BorderRadius.circular(20), border: Border.all(color: C.line)),
          child: Row(children: [
            const GAvatar('AS', size: 38),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Paste a link. Get a post.', style: sans(14, weight: FontWeight.w600, height: 1.2)),
                Text('From X, LinkedIn or Reddit', style: sans(12, color: C.muted, height: 1.3)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: C.ink, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [const Icon(Icons.link_rounded, color: C.teal, size: 16), const SizedBox(width: 6), Text('Paste', style: sans(13, color: Colors.white, weight: FontWeight.w500))]),
            ),
          ]),
        ),
      );

  Widget _continueLearning() => Pressable(
        onTap: widget.onOpenReels,
        child: Container(
          height: 104,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(22)),
          clipBehavior: Clip.antiAlias,
          child: Stack(children: [
            Positioned.fill(child: Blobs(base: const Color(0xFF06201B), colors: [C.tealD, const Color(0xFF1B5C4D), C.lime.withValues(alpha: 0.35)], square: false)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('MSW LABS · DAY 12 / 30', style: mono(10, color: C.lime)),
                    const SizedBox(height: 6),
                    Text('System design: the URL shortener', style: serif(24, color: Colors.white, height: 1.05)),
                  ]),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(color: C.lime, shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow_rounded, color: C.ink, size: 28),
                ),
              ]),
            ),
          ]),
        ),
      );
}

/// A post with double-tap-to-like heart burst and an animated like button.
class PostCard extends StatefulWidget {
  const PostCard({super.key, required this.post});
  final Post post;
  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  late final AnimationController _burst = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

  void _like({bool force = false}) {
    final p = widget.post;
    setState(() {
      if (force && p.liked) return;
      p.liked = !p.liked;
      p.likes += p.liked ? 1 : -1;
    });
  }

  @override
  void dispose() {
    _burst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.post;
    return GestureDetector(
      onDoubleTap: () {
        _like(force: true);
        _burst.forward(from: 0);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: C.line)),
        child: Stack(clipBehavior: Clip.none, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              GAvatar(p.initials, size: 40, colors: p.initials == 'RK' ? const [C.tealD, C.sky] : (p.initials == 'MJ' ? const [C.peach, Color(0xFFC86DD7)] : const [Color(0xFFFF9A76), Color(0xFFC86DD7)])),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.name, style: sans(14, weight: FontWeight.w600, height: 1.2)),
                  Text(p.meta, style: sans(12, color: C.muted, height: 1.3)),
                ]),
              ),
              Tag(p.src, bg: srcColor(p.src), fg: Colors.white),
            ]),
            const SizedBox(height: 12),
            Text(p.body, style: sans(15, height: 1.45)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: C.bg, borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                Container(width: 64, height: 48, decoration: BoxDecoration(borderRadius: BorderRadius.circular(9), gradient: LinearGradient(colors: p.grad))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p.title, style: sans(14, weight: FontWeight.w600, height: 1.25), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(p.domain, style: mono(10)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            Row(children: [
              GestureDetector(
                onTap: _like,
                child: Row(children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (c, a) => ScaleTransition(scale: CurvedAnimation(parent: a, curve: Curves.elasticOut), child: c),
                    child: Icon(p.liked ? Icons.favorite_rounded : Icons.favorite_border_rounded, key: ValueKey(p.liked), size: 20, color: p.liked ? const Color(0xFFE0245E) : C.muted),
                  ),
                  const SizedBox(width: 5),
                  Text('${p.likes}', style: sans(13, color: p.liked ? const Color(0xFFE0245E) : C.muted, weight: FontWeight.w500)),
                ]),
              ),
              const SizedBox(width: 18),
              const Icon(Icons.mode_comment_outlined, size: 18, color: C.muted),
              const SizedBox(width: 5),
              Text('${p.comments}', style: sans(13, color: C.muted)),
              const SizedBox(width: 18),
              const Icon(Icons.ios_share_rounded, size: 18, color: C.muted),
              const Spacer(),
              const Icon(Icons.bookmark_border_rounded, size: 20, color: C.muted),
            ]),
          ]),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _burst,
                builder: (_, _) {
                  final v = _burst.value;
                  if (v == 0 || v == 1) return const SizedBox.shrink();
                  final s = Curves.elasticOut.transform(math.min(1, v * 1.6));
                  return Center(
                    child: Opacity(
                      opacity: (1 - math.max(0, v - 0.6) / 0.4).clamp(0, 1),
                      child: Transform.scale(scale: s * 1.1, child: const Icon(Icons.favorite_rounded, size: 96, color: Color(0xFFE0245E))),
                    ),
                  );
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

/// Bottom sheet: paste a URL → platform is detected → live preview → Post.
class _PasteSheet extends StatefulWidget {
  const _PasteSheet();
  @override
  State<_PasteSheet> createState() => _PasteSheetState();
}

class _PasteSheetState extends State<_PasteSheet> {
  final _ctl = TextEditingController();
  static const _samples = {
    'X': 'https://x.com/aanya/status/1832491',
    'LinkedIn': 'https://linkedin.com/posts/rohan-k-intern',
    'Reddit': 'https://reddit.com/r/cscareers/comments/sd',
  };

  String? get _src {
    final t = _ctl.text.toLowerCase();
    if (t.contains('x.com') || t.contains('twitter.com')) return 'X';
    if (t.contains('linkedin.com')) return 'LinkedIn';
    if (t.contains('reddit.com')) return 'Reddit';
    return null;
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final src = _src;
    final inset = MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, inset + 20),
      decoration: const BoxDecoration(color: C.paper, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: C.line2, borderRadius: BorderRadius.circular(4)))),
        const SizedBox(height: 18),
        const Headline('Paste a link. ', 'Get a post.', size: 34),
        const SizedBox(height: 16),
        TextField(
          controller: _ctl,
          onChanged: (_) => setState(() {}),
          style: mono(13, color: C.ink),
          decoration: InputDecoration(
            hintText: 'https://…',
            hintStyle: mono(13),
            prefixIcon: const Icon(Icons.link_rounded, color: C.muted),
            filled: true,
            fillColor: C.bg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(spacing: 8, children: [
          for (final e in _samples.entries)
            Pressable(
              onTap: () => setState(() => _ctl.text = e.value),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(99), border: Border.all(color: C.line2)),
                child: Text('Try ${e.key}', style: sans(12, weight: FontWeight.w500)),
              ),
            ),
        ]),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          transitionBuilder: (c, a) => FadeTransition(opacity: a, child: ScaleTransition(scale: Tween(begin: 0.94, end: 1.0).animate(a), child: c)),
          child: src == null
              ? Container(
                  key: const ValueKey('empty'),
                  height: 92,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: C.line2)),
                  child: Text('Preview appears here', style: sans(13, color: C.muted)),
                )
              : Container(
                  key: ValueKey(src),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: C.line)),
                  child: Row(children: [
                    Container(width: 68, height: 68, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: srcColor(src)), alignment: Alignment.center, child: Text(src == 'LinkedIn' ? 'in' : (src == 'Reddit' ? 'r/' : 'X'), style: sans(22, color: Colors.white, weight: FontWeight.w700))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Tag('Detected: $src', bg: C.bg, fg: srcColor(src)),
                        const SizedBox(height: 6),
                        Text('Link preview ready to share with the community', style: sans(14, weight: FontWeight.w600, height: 1.25)),
                      ]),
                    ),
                  ]),
                ),
        ),
        const SizedBox(height: 18),
        PrimaryButton(
          'Post to community',
          bg: src == null ? C.muted : C.ink,
          onTap: src == null
              ? null
              : () => Navigator.of(context).pop(Post(
                    name: 'Aanya Sharma',
                    initials: 'AS',
                    meta: 'IIT Delhi · now',
                    body: 'Sharing this from $src 👇',
                    src: src,
                    title: 'Shared from $src',
                    domain: Uri.tryParse(_ctl.text)?.host ?? src,
                    grad: [srcColor(src).withValues(alpha: 0.5), srcColor(src)],
                    likes: 0,
                    comments: 0,
                  )),
        ),
      ]),
    );
  }
}
