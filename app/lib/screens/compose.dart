import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets/ui.dart';
import 'post.dart';

/// Platform badge (brand-style letters, no emojis).
class SourceBadge extends StatelessWidget {
  const SourceBadge(this.src, {super.key, this.size = 44});
  final String src;
  final double size;
  @override
  Widget build(BuildContext context) {
    final g = switch (src) {
      'X' => 'X',
      'Instagram' => 'IG',
      'LinkedIn' => 'in',
      'Reddit' => 'r/',
      'Threads' => '@',
      'Medium' => 'M',
      _ => '',
    };
    final ic = switch (src) {
      'YouTube' => Icons.play_arrow_rounded,
      'GitHub' => Icons.code_rounded,
      'Link' => Icons.link_rounded,
      'MSW' => Icons.auto_awesome_rounded,
      _ => null,
    };
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        color: src == 'Instagram' ? null : srcColor(src),
        border: srcColor(src) == Colors.black || srcColor(src).computeLuminance() < 0.02 ? Border.all(color: Colors.white24) : null,
        gradient: src == 'Instagram' ? const LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [Color(0xFFFDC468), Color(0xFFDF4996), Color(0xFF6A3AC9)]) : null,
      ),
      child: ic != null
          ? Icon(ic, color: Colors.white, size: size * 0.55)
          : Text(
              g,
              style: sans(size * 0.36, color: Colors.white, weight: FontWeight.w800, height: 1),
            ),
    );
  }
}

/// Student "Post" tab: drop a link from any platform, add a caption, tags and audience.
class ComposeScreen extends StatefulWidget {
  const ComposeScreen({super.key, required this.onPosted});
  final VoidCallback onPosted;
  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  final _link = TextEditingController();
  final _caption = TextEditingController();
  final _tags = <String>{};
  String _audience = 'Everyone';
  bool _posting = false;
  static const _platforms = ['X', 'Instagram', 'LinkedIn', 'Reddit', 'YouTube', 'Threads', 'Medium', 'GitHub'];
  static const _samples = {
    'X': 'https://x.com/aanya/status/1832491',
    'Instagram': 'https://instagram.com/p/C9xK2hackathon',
    'LinkedIn': 'https://linkedin.com/posts/rohan-k-intern',
    'Reddit': 'https://reddit.com/r/cscareers/comments/sd',
    'YouTube': 'https://youtube.com/watch?v=msw-labs-day12',
    'Threads': 'https://threads.net/@aanya/post/123',
    'Medium': 'https://medium.com/@aanya/3-hackathons',
    'GitHub': 'https://github.com/aanya-codes/krishi-lite',
  };
  static const _topics = ['AI', 'Hackathons', 'Internships', 'Startups', 'Web dev', 'Design', 'FinTech', 'Career'];

  String? get _src => detectSource(_link.text);

  @override
  void dispose() {
    _link.dispose();
    _caption.dispose();
    super.dispose();
  }

  Future<void> _pasteClipboard() async {
    final d = await Clipboard.getData('text/plain');
    if (d?.text != null && d!.text!.trim().isNotEmpty) setState(() => _link.text = d.text!.trim());
  }

  Future<void> _post() async {
    final src = _src;
    if (src == null && _caption.text.trim().isEmpty) return;
    setState(() => _posting = true);
    final host = Uri.tryParse(_link.text.trim())?.host.replaceFirst('www.', '') ?? '';
    final tagLine = _tags.isEmpty ? '' : '\n\n${_tags.map((t) => '#${t.replaceAll(' ', '')}').join(' ')}';
    final p = Post(
      author: me,
      time: 'now',
      body: (_caption.text.trim().isEmpty ? 'Sharing this.' : _caption.text.trim()) + tagLine,
      src: src ?? 'MSW',
      title: src == null ? 'Post on MSW' : '$src · ${host.isEmpty ? 'link' : host}',
      domain: host.isEmpty ? 'msw.community' : host,
      grad: [srcColor(src ?? 'MSW').withValues(alpha: 0.55), srcColor(src ?? 'MSW')],
      likes: 0,
      shares: 0,
    )..url = _link.text.trim();
    posts.insert(0, p);
    await Api.createPost(p);
    if (!mounted) return;
    setState(() {
      _posting = false;
      _link.clear();
      _caption.clear();
      _tags.clear();
    });
    snack(context, 'Posted to the community');
    widget.onPosted();
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    final src = _src;
    final canPost = src != null || _caption.text.trim().isNotEmpty;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, pad.bottom + 110),
      children: [
        const Label('New post'),
        const SizedBox(height: 8),
        const Reveal(child: Headline('Share something ', 'worth reading.', size: 40)),
        const SizedBox(height: 18),
        // platform strip
        SizedBox(
          height: 70,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _platforms.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final on = src == _platforms[i];
              return GestureDetector(
                onTap: () => setState(() => _link.text = _samples[_platforms[i]]!),
                child: AnimatedScale(
                  scale: on ? 1.12 : 1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  child: Column(
                    children: [
                      AnimatedOpacity(opacity: src == null || on ? 1 : 0.35, duration: const Duration(milliseconds: 300), child: SourceBadge(_platforms[i])),
                      const SizedBox(height: 6),
                      Text(
                        _platforms[i],
                        style: sans(10, color: on ? C.ink : C.muted, weight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        // link field
        TextField(
          controller: _link,
          onChanged: (_) => setState(() {}),
          style: mono(13, color: C.ink),
          decoration: InputDecoration(
            hintText: 'Paste a link from any platform',
            hintStyle: sans(14, color: C.muted),
            prefixIcon: Icon(Icons.link_rounded, color: C.muted),
            suffixIcon: _link.text.isEmpty
                ? TextButton(
                    onPressed: _pasteClipboard,
                    child: Text('Paste', style: sans(13, weight: FontWeight.w700)),
                  )
                : IconButton(
                    onPressed: () => setState(_link.clear),
                    icon: Icon(Icons.close_rounded, color: C.muted),
                  ),
            filled: true,
            fillColor: C.card,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: C.line2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: C.ink, width: 1.4),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // live preview
        AnimatedSize(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          child: src == null
              ? const SizedBox(width: double.infinity)
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
                      SourceBadge(src, size: 52),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.check_circle_rounded, size: 15, color: C.tealD),
                                const SizedBox(width: 5),
                                Text('$src link detected', style: sans(13, weight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(Uri.tryParse(_link.text.trim())?.host ?? '', style: mono(10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 12),
        // caption
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: C.line2),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GAvatar(me.initials, size: 36, colors: me.grad),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _caption,
                      onChanged: (_) => setState(() {}),
                      maxLines: 5,
                      minLines: 3,
                      maxLength: 500,
                      style: sans(15, height: 1.45),
                      decoration: InputDecoration(
                        hintText: 'Write a caption…',
                        hintStyle: sans(15, color: C.muted),
                        border: InputBorder.none,
                        counterStyle: mono(9),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('TOPICS', style: mono(10)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in _topics)
              GestureDetector(
                onTap: () => setState(() => _tags.contains(t) ? _tags.remove(t) : _tags.add(t)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _tags.contains(t) ? C.ink : C.card,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: _tags.contains(t) ? C.ink : C.line2),
                  ),
                  child: Text(
                    '#$t',
                    style: sans(13, weight: FontWeight.w600, color: _tags.contains(t) ? C.onInk : C.ink),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text('WHO CAN SEE THIS', style: mono(10)),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final a in const [(Icons.public_rounded, 'Everyone'), (Icons.account_balance_outlined, 'My college'), (Icons.group_outlined, 'Followers')])
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _audience = a.$2),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _audience == a.$2 ? C.ink : C.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _audience == a.$2 ? C.ink : C.line2),
                    ),
                    child: Column(
                      children: [
                        Icon(a.$1, size: 20, color: _audience == a.$2 ? C.onInk : C.ink),
                        const SizedBox(height: 4),
                        Text(
                          a.$2,
                          style: sans(11, weight: FontWeight.w600, color: _audience == a.$2 ? C.onInk : C.ink),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        PrimaryButton(_posting ? 'Posting…' : 'Post', loading: _posting, bg: canPost ? null : C.muted, onTap: canPost ? _post : null),
      ],
    );
  }
}
