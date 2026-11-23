import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// MSW Community design tokens — mirrors the website.
class C {
  static const bg = Color(0xFFF3F2EF);
  static const bg2 = Color(0xFFEBE9E4);
  static const paper = Color(0xFFFBFAF8);
  static const ink = Color(0xFF121212);
  static const ink2 = Color(0xFF2A2A2A);
  static const muted = Color(0xFF6D6B67);
  static const line = Color(0x1A121212);
  static const line2 = Color(0x2E121212);
  static const dark = Color(0xFF0C0C0D);
  static const dark2 = Color(0xFF161617);
  static const onDark = Color(0xFFECEBE6);
  static const teal = Color(0xFF7FD1BD);
  static const tealD = Color(0xFF2F8F7A);
  static const lime = Color(0xFFD4F56B);
  static const peach = Color(0xFFFFB38A);
  static const lilac = Color(0xFFC9B8FF);
  static const sky = Color(0xFF9FD3FF);
}

TextStyle serif(double size, {Color? color, bool italic = false, double height = 1.0}) => GoogleFonts.instrumentSerif(
      fontSize: size,
      color: color ?? C.ink,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      height: height,
      letterSpacing: -size * 0.02,
    );

TextStyle sans(double size, {Color? color, FontWeight weight = FontWeight.w400, double height = 1.4}) =>
    GoogleFonts.inter(fontSize: size, color: color ?? C.ink, fontWeight: weight, height: height);

TextStyle mono(double size, {Color? color, FontWeight weight = FontWeight.w500}) =>
    GoogleFonts.jetBrainsMono(fontSize: size, color: color ?? C.muted, fontWeight: weight, letterSpacing: size * 0.08);

ThemeData buildTheme() {
  final base = ThemeData(useMaterial3: true, brightness: Brightness.light, scaffoldBackgroundColor: C.bg);
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(primary: C.ink, secondary: C.tealD, surface: C.bg),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: C.ink,
      contentTextStyle: sans(14, color: C.onDark),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

/// Smooth fade + slight scale page transition used across the app.
Route<T> fadeRoute<T>(Widget page, {int ms = 650}) => PageRouteBuilder<T>(
      transitionDuration: Duration(milliseconds: ms),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, a, _, child) {
        final c = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: c,
          child: ScaleTransition(scale: Tween(begin: 1.04, end: 1.0).animate(c), child: child),
        );
      },
    );

/// Placeholder community photos (swap with real MSW photos later).
String photo(int i, {int w = 400, int h = 530}) => 'https://picsum.photos/seed/msw-community-${i + 1}/$w/$h?grayscale';
