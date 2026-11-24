import 'package:flutter/material.dart';

import '../theme.dart';

/// The MSW logo. Picks the light or dark artwork for the background it sits on.
class Logo extends StatelessWidget {
  const Logo({super.key, this.height = 28, this.light});
  final double height;
  final bool? light;
  @override
  Widget build(BuildContext context) => Image.asset((light ?? darkMode.value) ? 'assets/brand/logo_light.png' : 'assets/brand/logo_dark.png', height: height, filterQuality: FilterQuality.medium);
}

/// Sun / moon button that flips the theme.
class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key, this.onImage = false});
  final bool onImage;
  @override
  Widget build(BuildContext context) {
    final d = darkMode.value;
    return GestureDetector(
      onTap: toggleTheme,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onImage ? Colors.white.withValues(alpha: 0.14) : C.paper,
          border: Border.all(color: onImage ? Colors.white24 : C.line),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (c, a) => RotationTransition(
            turns: Tween(begin: 0.6, end: 1.0).animate(a),
            child: FadeTransition(opacity: a, child: c),
          ),
          child: Icon(d ? Icons.dark_mode_outlined : Icons.light_mode_outlined, key: ValueKey(d), size: 19, color: onImage ? Colors.white : C.ink),
        ),
      ),
    );
  }
}
