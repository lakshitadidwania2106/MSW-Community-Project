import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';
import '../widgets/halftone.dart';
import '../widgets/ui.dart';
import 'shell.dart';

/// Role-aware login: accent colour, headline, fields and CTA morph per portal.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.initial = 0});
  final int initial;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late int _i = widget.initial;
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1300));
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(fadeRoute(Shell(role: roles[_i])), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final r = roles[_i];
    final pad = MediaQuery.of(context).padding;
    return Scaffold(
      backgroundColor: C.paper,
      body: Stack(children: [
        const Positioned(top: 0, left: 0, right: 0, height: 260, child: Halftone(swirlY: 0.6, swirlX: 1.1)),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 270,
          child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [C.paper.withValues(alpha: 0), C.paper]))),
        ),
        ListView(
          padding: EdgeInsets.fromLTRB(22, pad.top + 8, 22, pad.bottom + 24),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Pressable(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: C.line)),
                  child: const Icon(Icons.arrow_back_rounded, size: 18),
                ),
              ),
            ),
            const SizedBox(height: 110),
            _roleSwitcher(),
            const SizedBox(height: 28),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              transitionBuilder: (c, a) => FadeTransition(opacity: a, child: SlideTransition(position: Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(a), child: c)),
              child: Column(
                key: ValueKey(_i),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${r.name.toUpperCase()} PORTAL', style: mono(11, color: r.color)),
                  const SizedBox(height: 8),
                  Headline(r.title, r.italic, size: 50, italicColor: r.color == C.ink ? C.ink : r.color),
                  const SizedBox(height: 22),
                  if (r.role == Role.company) _field('Company name'),
                  if (r.role == Role.investor) _field('Fund / Angel name'),
                  if (r.role == Role.college) _field('Institution or club'),
                  _field(r.emailLabel),
                  _field('Password', obscure: true),
                  if (r.role == Role.admin) _field('6-digit 2FA code'),
                ],
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Keep me signed in', style: sans(13, color: C.muted)),
              Text('Forgot password?', style: sans(13, weight: FontWeight.w500).copyWith(decoration: TextDecoration.underline)),
            ]),
            const SizedBox(height: 20),
            PrimaryButton(r.cta, loading: _loading, bg: _loading ? r.color : C.ink, onTap: _submit),
            const SizedBox(height: 18),
            if (r.role == Role.student) ...[
              Row(children: [
                const Expanded(child: Divider(color: C.line)),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('or continue with', style: sans(12, color: C.muted))),
                const Expanded(child: Divider(color: C.line)),
              ]),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _oauth('Google', Icons.g_mobiledata_rounded)),
                const SizedBox(width: 10),
                Expanded(child: _oauth('GitHub', Icons.code_rounded)),
              ]),
            ],
          ],
        ),
      ]),
    );
  }

  Widget _roleSwitcher() => LayoutBuilder(builder: (context, c) {
        final w = (c.maxWidth - 10) / roles.length;
        return Container(
          height: 48,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(color: C.bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: C.line)),
          child: Stack(children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 550),
              curve: Curves.easeOutBack,
              left: w * _i,
              top: 0,
              bottom: 0,
              width: w,
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 4))]),
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: 4),
                child: AnimatedContainer(duration: const Duration(milliseconds: 400), width: 18, height: 2, color: roles[_i].color),
              ),
            ),
            Row(children: [
              for (var i = 0; i < roles.length; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _i = i),
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: sans(12, weight: FontWeight.w600, color: i == _i ? C.ink : C.muted),
                        child: Text(roles[i].name),
                      ),
                    ),
                  ),
                ),
            ]),
          ]),
        );
      });

  Widget _field(String label, {bool obscure = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          obscureText: obscure,
          cursorColor: roles[_i].color,
          style: sans(16),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: sans(15, color: C.muted),
            floatingLabelStyle: sans(13, color: roles[_i].color),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: C.line2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: roles[_i].color, width: 1.6)),
          ),
        ),
      );

  Widget _oauth(String t, IconData ic) => Pressable(
        child: Container(
          height: 52,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: C.line2)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(ic, size: 22), const SizedBox(width: 6), Text(t, style: sans(14, weight: FontWeight.w500))]),
        ),
      );
}
