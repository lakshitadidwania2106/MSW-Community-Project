import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/splash.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // start in the phone's theme; the user can flip it anywhere with the sun/moon button
  darkMode.value = PlatformDispatcher.instance.platformBrightness == Brightness.dark;
  runApp(const MswApp());
}

class MswApp extends StatelessWidget {
  const MswApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkMode,
      builder: (context, dark, _) {
        SystemChrome.setSystemUIOverlayStyle((dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(statusBarColor: Colors.transparent));
        return MaterialApp(
          title: 'MSW Community',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(),
          themeAnimationDuration: const Duration(milliseconds: 350),
          // let mouse & trackpad drag horizontal rows (tabs, stories, badges) on web/desktop
          scrollBehavior: const MaterialScrollBehavior().copyWith(dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad, PointerDeviceKind.stylus}),
          builder: (context, child) => _ThemeRebuilder(child: _PhoneFrame(child: child!)),
          home: const SplashScreen(),
        );
      },
    );
  }
}

/// Colours are read at build time, so when the theme flips we ask every
/// element to rebuild — state (tabs, scroll, navigation) is kept.
class _ThemeRebuilder extends StatefulWidget {
  const _ThemeRebuilder({required this.child});
  final Widget child;
  @override
  State<_ThemeRebuilder> createState() => _ThemeRebuilderState();
}

class _ThemeRebuilderState extends State<_ThemeRebuilder> {
  @override
  void initState() {
    super.initState();
    darkMode.addListener(_rebuildAll);
  }

  @override
  void dispose() {
    darkMode.removeListener(_rebuildAll);
    super.dispose();
  }

  void _rebuildAll() {
    void visit(Element e) {
      e.markNeedsBuild();
      e.visitChildren(visit);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) (context as Element).visitChildren(visit);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// On wide screens (desktop / web preview) show the app inside a phone frame.
class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      if (c.maxWidth < 600) return child;
      final h = (c.maxHeight - 40).clamp(500.0, 880.0);
      final mq = MediaQuery.of(context);
      return ColoredBox(
        color: const Color(0xFF0C0C0D),
        child: Center(
          child: Container(
            width: 400,
            height: h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(44),
              border: Border.all(color: const Color(0xFF2A2A2C), width: 8),
              boxShadow: [BoxShadow(color: C.teal.withValues(alpha: 0.18), blurRadius: 80, spreadRadius: -10)],
            ),
            clipBehavior: Clip.antiAlias,
            child: MediaQuery(
              data: mq.copyWith(size: Size(384, h - 16), padding: const EdgeInsets.only(top: 34, bottom: 18)),
              child: child,
            ),
          ),
        ),
      );
    },
  );
}
