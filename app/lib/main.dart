import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/splash.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(const MswApp());
}

class MswApp extends StatelessWidget {
  const MswApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MSW Community',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      // let mouse & trackpad drag horizontal rows (tabs, stories, badges) on web/desktop
      scrollBehavior: const MaterialScrollBehavior().copyWith(dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad, PointerDeviceKind.stylus}),
      // On wide screens (desktop / web preview) show the app inside a phone frame.
      builder: (context, child) => LayoutBuilder(builder: (context, c) {
        if (c.maxWidth < 600) return child!;
        final h = (c.maxHeight - 40).clamp(500.0, 880.0);
        final mq = MediaQuery.of(context);
        return ColoredBox(
          color: C.dark,
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
                child: child!,
              ),
            ),
          ),
        );
      }),
      home: const SplashScreen(),
    );
  }
}
