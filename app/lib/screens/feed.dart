import 'package:flutter/material.dart';

import '../api.dart';
import '../data.dart';
import 'stories.dart';
import '../theme.dart';
import '../widgets/scene.dart';
import '../widgets/ui.dart';
import 'post.dart';

/// Home feed: stories, "paste a link → get a post" composer, posts.
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key, required this.role, required this.onOpenReels});
  final RoleInfo role;
  final VoidCallback onOpenReels;
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  Future<void> _openComposer() async {
    final post = await showModalBottomSheet<Post>(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const PasteSheet());
    if (post != null) {
      setState(() => posts.insert(0, post));
      Api.createPost(post);
      if (mounted) snack(context, 'Posted to the community');
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
          child: Row(
            children: [
              const Logo(height: 30),
              const Spacer(),
              const ThemeToggle(),
              const SizedBox(width: 8),
              _iconBtn(Icons.search_rounded),
              const SizedBox(width: 8),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _iconBtn(Icons.notifications_none_rounded),
                  Positioned(
                    right: 9,
                    top: 9,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Color(0xFFFF5A5F), shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Reveal(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${greet.toUpperCase()}, ${me.name.split(' ').first.toUpperCase()}', style: mono(11)),
                const SizedBox(height: 6),
                const Headline('What are you ', 'building today?', size: 40),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Reveal(delay: 100, offset: 14, child: StoryRow()),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Reveal(delay: 200, child: _composer()),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Reveal(delay: 260, child: _continueLearning()),
        ),
        const SizedBox(height: 6),
        for (var i = 0; i < posts.length; i++)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Reveal(
              delay: 320 + i * 90,
              child: PostCard(key: ObjectKey(posts[i]), post: posts[i]),
            ),
          ),
      ],
    );
  }

  Widget _iconBtn(IconData ic) => Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      color: C.paper,
      shape: BoxShape.circle,
      border: Border.all(color: C.line),
    ),
    child: Icon(ic, size: 20, color: C.ink),
  );

  Widget _composer() => Pressable(
    onTap: _openComposer,
    child: Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: C.paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: C.line),
      ),
      child: Row(
        children: [
          GAvatar(me.initials, size: 38, colors: me.grad),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Paste a link. Get a post.', style: sans(14, weight: FontWeight.w600, height: 1.2)),
                Text('From X, LinkedIn or Reddit', style: sans(12, color: C.muted, height: 1.3)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: C.ink, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.link_rounded, color: C.onInk, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Paste',
                  style: sans(13, color: C.onInk, weight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _continueLearning() => Pressable(
    onTap: widget.onOpenReels,
    child: Container(
      height: 104,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Blobs(base: const Color(0xFF06201B), colors: [C.tealD, const Color(0xFF1B5C4D), C.lime.withValues(alpha: 0.35)], square: false),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('MSW LABS · DAY 12 / 30', style: mono(10, color: C.lime)),
                      const SizedBox(height: 6),
                      Text('System design: the URL shortener', style: serif(24, color: Colors.white, height: 1.05)),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(color: C.lime, shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow_rounded, color: C.black, size: 28),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Bottom sheet: paste a URL → platform is detected → live preview → Post.
class PasteSheet extends StatefulWidget {
  const PasteSheet({super.key});
  @override
  State<PasteSheet> createState() => _PasteSheetState();
}

class _PasteSheetState extends State<PasteSheet> {
  final _ctl = TextEditingController();
  final _note = TextEditingController();
  static const _samples = {'X': 'https://x.com/aanya/status/1832491', 'LinkedIn': 'https://linkedin.com/posts/rohan-k-intern', 'Reddit': 'https://reddit.com/r/cscareers/comments/sd'};

  String? get _src {
    final t = _ctl.text.toLowerCase();
    if (t.contains('x.com') || t.contains('twitter.com')) return 'X';
    if (t.contains('linkedin.com')) return 'LinkedIn';
    if (t.contains('reddit.com')) return 'Reddit';
    if (t.startsWith('http')) return 'Link';
    return null;
  }

  @override
  void dispose() {
    _ctl.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final src = _src;
    final inset = MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom;
    InputDecoration dec(String h, IconData? ic) => InputDecoration(
      hintText: h,
      hintStyle: sans(13, color: C.muted),
      prefixIcon: ic == null ? null : Icon(ic, color: C.muted),
      filled: true,
      fillColor: C.bg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    );
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, inset + 20),
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
          const SizedBox(height: 18),
          const Headline('Paste a link. ', 'Get a post.', size: 34),
          const SizedBox(height: 16),
          TextField(
            controller: _ctl,
            onChanged: (_) => setState(() {}),
            style: mono(13, color: C.ink),
            decoration: dec('https://…', Icons.link_rounded),
          ),
          const SizedBox(height: 10),
          TextField(controller: _note, maxLines: 2, style: sans(14), decoration: dec('Say something about it (optional)', null)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              for (final e in _samples.entries)
                Pressable(
                  onTap: () => setState(() => _ctl.text = e.value),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: C.line2),
                    ),
                    child: Text('Try ${e.key}', style: sans(12, weight: FontWeight.w500)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            transitionBuilder: (c, a) => FadeTransition(
              opacity: a,
              child: ScaleTransition(scale: Tween(begin: 0.94, end: 1.0).animate(a), child: c),
            ),
            child: src == null
                ? Container(
                    key: const ValueKey('empty'),
                    height: 80,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: C.line2),
                    ),
                    child: Text('Preview appears here', style: sans(13, color: C.muted)),
                  )
                : Container(
                    key: ValueKey(src),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: C.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: C.line),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: srcColor(src)),
                          alignment: Alignment.center,
                          child: Text(
                            src == 'LinkedIn' ? 'in' : (src == 'Reddit' ? 'r/' : (src == 'X' ? 'X' : '')),
                            style: sans(20, color: Colors.white, weight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Tag('Detected: $src'),
                              const SizedBox(height: 6),
                              Text('Link preview ready to share', style: sans(14, weight: FontWeight.w600, height: 1.25)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            'Post to community',
            bg: src == null ? C.muted : null,
            onTap: src == null
                ? null
                : () => Navigator.of(context).pop(
                    Post(
                      author: me,
                      time: 'now',
                      body: _note.text.trim().isEmpty ? 'Sharing this from $src.' : _note.text.trim(),
                      src: src,
                      title: 'Shared from $src',
                      domain: Uri.tryParse(_ctl.text)?.host ?? src,
                      grad: [srcColor(src).withValues(alpha: 0.5), srcColor(src)],
                      likes: 0,
                      shares: 0,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
