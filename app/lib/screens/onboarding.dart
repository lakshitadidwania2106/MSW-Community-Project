import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';
import '../widgets/scene.dart';
import '../widgets/ui.dart';
import 'login.dart';

/// Three illustrated welcome slides (inspired by "Welcome / discover…" onboarding).
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _pc = PageController();
  int _page = 0;
  static const _slides = [
    ('Welcome', 'One community for students, colleges, companies and investors.'),
    ('Learn.\nBuild.', '30-day courses in reels, weekend hackathons and real company tasks.'),
    ('Get\ndiscovered.', 'Jobs, internships, mentors and investors — all from one digital ID.'),
  ];

  void _next() {
    if (_page < _slides.length - 1) {
      _pc.nextPage(duration: const Duration(milliseconds: 700), curve: Curves.easeInOutCubic);
    } else {
      Navigator.of(context).pushReplacement(fadeRoute(const OnboardingScreen(), ms: 800));
    }
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF0E2A2C),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pc,
            itemCount: _slides.length,
            onPageChanged: (p) => setState(() => _page = p),
            itemBuilder: (_, i) {
              final p = welcomePalettes[i];
              return Stack(
                children: [
                  Positioned.fill(child: Scene(p: p, horizon: 0.5)),
                  Positioned(left: size.width * 0.08, top: size.height * 0.43, child: Sticker(p.emoji[0], delay: 0, rotate: -0.18)),
                  Positioned(right: size.width * 0.1, top: size.height * 0.52, child: Sticker(p.emoji[1], size: 62, delay: 500, rotate: 0.14)),
                  Positioned(left: size.width * 0.4, top: size.height * 0.58, child: Sticker(p.emoji[2], size: 46, delay: 900, rotate: -0.05)),
                  Positioned(
                    right: -18,
                    top: size.height * 0.27,
                    child: Seal(text: p.seal, color: p.accent, size: 116, center: i == 0 ? '👋' : (i == 1 ? '⚡' : '🚀')),
                  ),
                ],
              );
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: size.height * 0.42,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)]),
                ),
              ),
            ),
          ),
          Positioned(
            top: pad.top + 14,
            left: 24,
            right: 24,
            child: IgnorePointer(
              child: Column(
                children: [
                  const Logo(light: true, height: 40),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (c, a) => FadeTransition(
                      opacity: a,
                      child: SlideTransition(
                        position: Tween(begin: const Offset(0, 0.15), end: Offset.zero).animate(a),
                        child: c,
                      ),
                    ),
                    child: Text(
                      _slides[_page].$1,
                      key: ValueKey(_page),
                      textAlign: TextAlign.center,
                      style: display(58, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 28,
            right: 28,
            bottom: pad.bottom + 24,
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    _slides[_page].$2,
                    key: ValueKey(_page),
                    textAlign: TextAlign.center,
                    style: sans(18, color: Colors.white, height: 1.4, weight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < _slides.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _page ? 26 : 8,
                        height: 8,
                        decoration: BoxDecoration(color: i == _page ? Colors.white : Colors.white38, borderRadius: BorderRadius.circular(8)),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                PrimaryButton(_page == _slides.length - 1 ? 'Get started' : 'Next', bg: Colors.white, fg: C.black, onTap: _next),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacement(fadeRoute(const OnboardingScreen())),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Already have an account? ',
                          style: sans(14, color: Colors.white70),
                        ),
                        TextSpan(
                          text: 'Sign in',
                          style: sans(14, color: Colors.white, weight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Who's joining?" — every role gets its own illustrated world.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _sel = 0;

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    final size = MediaQuery.of(context).size;
    final r = roles[_sel], p = rolePalettes[r.role]!;
    return Scaffold(
      backgroundColor: p.sky.first,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 700),
              child: Scene(key: ValueKey(_sel), p: p, horizon: 0.34),
            ),
          ),
          Positioned(
            top: pad.top + 10,
            left: 20,
            right: 20,
            child: const Row(children: [Logo(light: true, height: 30), Spacer(), ThemeToggle(onImage: true)]),
          ),
          Positioned(
            top: pad.top + 74,
            left: 22,
            right: 22,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Text('WHO’S\nJOINING?', style: display(60, color: Colors.white)),
                Positioned(
                  right: 4,
                  top: 128,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Seal(key: ValueKey(_sel), text: p.seal, color: p.accent, size: 104, center: r.emoji),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: size.width * 0.08,
            top: pad.top + 230,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Sticker(p.emoji[1], key: ValueKey('a$_sel'), size: 48, delay: 300, rotate: 0.16),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 22, 20, pad.bottom + 18),
              decoration: BoxDecoration(
                color: C.paper,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
                boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 40, offset: Offset(0, -10))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PICK YOUR PORTAL', style: mono(11)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (var i = 0; i < roles.length; i++)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: i < roles.length - 1 ? 6 : 0),
                            child: Pressable(
                              onTap: () => setState(() => _sel = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 450),
                                curve: Curves.easeOutCubic,
                                height: 78,
                                decoration: BoxDecoration(
                                  color: i == _sel ? roles[i].color : C.bg,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: i == _sel ? roles[i].color : C.line),
                                  boxShadow: i == _sel ? [BoxShadow(color: roles[i].color.withValues(alpha: 0.4), blurRadius: 18, offset: const Offset(0, 8))] : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedScale(
                                      scale: i == _sel ? 1.2 : 1,
                                      duration: const Duration(milliseconds: 400),
                                      curve: Curves.easeOutBack,
                                      child: Text(roles[i].emoji, style: const TextStyle(fontSize: 24)),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      roles[i].name,
                                      style: sans(11, weight: FontWeight.w600, color: i == _sel ? Colors.white : C.ink),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (c, a) => FadeTransition(
                      opacity: a,
                      child: SlideTransition(
                        position: Tween(begin: const Offset(0.05, 0), end: Offset.zero).animate(a),
                        child: c,
                      ),
                    ),
                    child: Column(
                      key: ValueKey(_sel),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.tagline, style: serif(32, height: 1.05)),
                        const SizedBox(height: 10),
                        for (final f in r.features)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(color: r.color.withValues(alpha: 0.16), shape: BoxShape.circle),
                                  child: Icon(Icons.check_rounded, size: 13, color: r.color),
                                ),
                                const SizedBox(width: 10),
                                Text(f, style: sans(14, color: C.ink2)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    'Continue as ${r.name}',
                    bg: r.color,
                    onTap: () => Navigator.of(context).push(fadeRoute(LoginScreen(initial: _sel))),
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
