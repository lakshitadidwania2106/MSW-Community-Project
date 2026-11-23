import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';
import '../widgets/halftone.dart';
import '../widgets/ui.dart';
import 'login.dart';

/// "Who are you?" — pick a portal. Halftone dots live in the background.
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
      body: Stack(children: [
        const Positioned.fill(child: Halftone(swirlY: 0.25)),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [C.bg.withValues(alpha: 0), C.bg.withValues(alpha: 0.6), C.bg], stops: const [0.25, 0.5, 0.62]),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(22, pad.top + 14, 22, pad.bottom + 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text.rich(TextSpan(children: [
                TextSpan(text: 'MSW ', style: serif(28)),
                TextSpan(text: 'Community', style: serif(28, italic: true)),
                TextSpan(text: '.', style: serif(28, color: C.tealD)),
              ])),
              const Spacer(),

            ]),
            const Spacer(flex: 3),
            Reveal(delay: 100, child: Text('THE STUDENT OPERATING SYSTEM', style: mono(11, color: C.ink))),
            const SizedBox(height: 10),
            const Reveal(delay: 200, child: Headline('Where students build, learn & get ', 'discovered.', size: 46)),
            const SizedBox(height: 22),
            Reveal(delay: 350, child: Text('Who’s joining?', style: sans(15, color: C.muted))),
            const SizedBox(height: 12),
            for (var i = 0; i < roles.length; i++)
              Reveal(
                delay: 420 + i * 70,
                child: Padding(padding: const EdgeInsets.only(bottom: 8), child: _roleTile(i)),
              ),
            const SizedBox(height: 10),
            Reveal(
              delay: 800,
              child: PrimaryButton(
                'Continue as ${roles[_sel].name}',
                onTap: () => Navigator.of(context).push(fadeRoute(LoginScreen(initial: _sel))),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _roleTile(int i) {
    final r = roles[i], on = _sel == i;
    return Pressable(
      onTap: () => setState(() => _sel = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: on ? 14 : 10),
        decoration: BoxDecoration(
          color: on ? C.ink : C.paper.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: on ? C.ink : C.line),
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 450),
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: on ? r.color : C.bg2, borderRadius: BorderRadius.circular(11)),
            child: Icon(r.icon, size: 18, color: on ? Colors.white : C.ink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.name, style: sans(15, weight: FontWeight.w600, color: on ? C.onDark : C.ink, height: 1.2)),
              Text(r.tagline, style: sans(12, color: on ? C.onDark.withValues(alpha: 0.6) : C.muted, height: 1.3)),
            ]),
          ),
          AnimatedRotation(
            turns: on ? 0 : -0.125,
            duration: const Duration(milliseconds: 450),
            child: Icon(Icons.arrow_forward_rounded, size: 18, color: on ? C.teal : C.muted),
          ),
        ]),
      ),
    );
  }
}
