import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';
import '../widgets/halftone.dart';
import '../widgets/scene.dart';
import '../widgets/ui.dart';
import 'login.dart';

/// "Who's joining?" — black & white, halftone dots, matching the website.
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
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Halftone(color: C.ink, swirlY: 0.25)),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [C.bg.withValues(alpha: 0), C.bg.withValues(alpha: 0.7), C.bg],
                    stops: const [0.22, 0.46, 0.6],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(22, pad.top + 12, 22, pad.bottom + 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [Logo(height: 30), Spacer(), ThemeToggle()]),
                const Spacer(flex: 3),
                Reveal(
                  delay: 100,
                  child: Text('THE STUDENT OPERATING SYSTEM', style: mono(11, color: C.ink)),
                ),
                const SizedBox(height: 10),
                const Reveal(delay: 200, child: Headline('Where students build, learn & get ', 'discovered.', size: 44)),
                const SizedBox(height: 20),
                Reveal(
                  delay: 320,
                  child: Text('Who’s joining?', style: sans(15, color: C.muted)),
                ),
                const SizedBox(height: 10),
                for (var i = 0; i < roles.length; i++)
                  Reveal(
                    delay: 380 + i * 60,
                    child: Padding(padding: const EdgeInsets.only(bottom: 8), child: _tile(i)),
                  ),
                const SizedBox(height: 8),
                Reveal(
                  delay: 760,
                  child: PrimaryButton('Continue as ${roles[_sel].name}', onTap: () => Navigator.of(context).push(fadeRoute(LoginScreen(initial: _sel)))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(int i) {
    final r = roles[i], on = _sel == i;
    return Pressable(
      onTap: () => setState(() => _sel = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: on ? 14 : 10),
        decoration: BoxDecoration(
          color: on ? C.ink : C.paper.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: on ? C.ink : C.line),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 420),
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: on ? C.teal : C.bg2, borderRadius: BorderRadius.circular(12)),
              child: Icon(r.icon, size: 19, color: on ? C.black : C.ink),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.name,
                    style: sans(15, weight: FontWeight.w600, color: on ? C.onInk : C.ink, height: 1.2),
                  ),
                  Text(r.tagline, style: sans(12, color: on ? C.onInk.withValues(alpha: 0.6) : C.muted, height: 1.3)),
                ],
              ),
            ),
            AnimatedRotation(
              turns: on ? 0 : -0.125,
              duration: const Duration(milliseconds: 420),
              child: Icon(Icons.arrow_forward_rounded, size: 18, color: on ? C.teal : C.muted),
            ),
          ],
        ),
      ),
    );
  }
}
