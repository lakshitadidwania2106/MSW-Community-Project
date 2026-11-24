import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Light / dark switch for the whole app. Flip it with [toggleTheme].
final darkMode = ValueNotifier<bool>(false);
void toggleTheme() => darkMode.value = !darkMode.value;

/// MSW Community design tokens — mirrors the website.
/// Adaptive colours are getters (they change with [darkMode]);
/// brand accents are constants and look the same in both themes.
class C {
  static bool get _d => darkMode.value;

  // surfaces
  static Color get bg => _d ? const Color(0xFF0E0E10) : const Color(0xFFF3F2EF);
  static Color get bg2 => _d ? const Color(0xFF1D1D21) : const Color(0xFFEBE9E4);
  static Color get paper => _d ? const Color(0xFF161619) : const Color(0xFFFBFAF8);
  static Color get card => _d ? const Color(0xFF1E1E23) : Colors.white;
  // text
  static Color get ink => _d ? const Color(0xFFECEBE6) : const Color(0xFF121212);
  static Color get ink2 => _d ? const Color(0xFFC9C7C0) : const Color(0xFF2A2A2A);
  static Color get onInk => _d ? const Color(0xFF121212) : Colors.white;
  static Color get muted => _d ? const Color(0xFF8F8D87) : const Color(0xFF6D6B67);
  static Color get line => _d ? const Color(0x1FFFFFFF) : const Color(0x1A121212);
  static Color get line2 => _d ? const Color(0x33FFFFFF) : const Color(0x2E121212);
  // always-dark surfaces (slightly lifted in dark mode so they read as cards)
  static Color get dark => _d ? const Color(0xFF1A1A1F) : const Color(0xFF0C0C0D);
  static Color get dark2 => _d ? const Color(0xFF24242A) : const Color(0xFF161617);

  // fixed colours
  static const black = Color(0xFF121212); // text on pastel / bright surfaces
  static const onDark = Color(0xFFECEBE6);
  static const teal = Color(0xFF7FD1BD);
  static const tealD = Color(0xFF2F8F7A);
  static const lime = Color(0xFFD4F56B);
  static const peach = Color(0xFFFFB38A);
  static const lilac = Color(0xFFC9B8FF);
  static const sky = Color(0xFF9FD3FF);
}

TextStyle serif(double size, {Color? color, bool italic = false, double height = 1.0}) =>
    GoogleFonts.instrumentSerif(fontSize: size, color: color ?? C.ink, fontStyle: italic ? FontStyle.italic : FontStyle.normal, height: height, letterSpacing: -size * 0.02);

TextStyle sans(double size, {Color? color, FontWeight weight = FontWeight.w400, double height = 1.4}) => GoogleFonts.inter(fontSize: size, color: color ?? C.ink, fontWeight: weight, height: height);

/// Bold display grotesk (used on the welcome / login screens).
TextStyle display(double size, {Color? color, double height = 0.92}) =>
    GoogleFonts.bricolageGrotesque(fontSize: size, color: color ?? C.ink, fontWeight: FontWeight.w800, height: height, letterSpacing: -size * 0.03);

TextStyle mono(double size, {Color? color, FontWeight weight = FontWeight.w500}) => GoogleFonts.jetBrainsMono(fontSize: size, color: color ?? C.muted, fontWeight: weight, letterSpacing: size * 0.08);

ThemeData buildTheme() {
  final d = darkMode.value;
  final base = ThemeData(useMaterial3: true, brightness: d ? Brightness.dark : Brightness.light, scaffoldBackgroundColor: C.bg);
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(primary: C.ink, secondary: C.tealD, surface: C.bg),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    textSelectionTheme: TextSelectionThemeData(cursorColor: C.ink),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: sans(15, color: C.muted),
      hintStyle: sans(14, color: C.muted),
    ),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.transparent),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: d ? C.onDark : C.black,
      contentTextStyle: sans(14, color: d ? C.black : C.onDark),
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
