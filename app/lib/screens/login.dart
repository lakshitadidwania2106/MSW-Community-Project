import 'package:flutter/material.dart';

import '../api.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets/halftone.dart';
import '../widgets/scene.dart';
import '../widgets/ui.dart';
import 'shell.dart';

/// Role-aware login in the black & white website style.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.initial = 0});
  final int initial;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late int _i = widget.initial;
  bool _loading = false, _signup = false, _hide = true;

  Future<void> _submit() async {
    setState(() => _loading = true);
    final started = DateTime.now();
    await Api.login(roles[_i].role);
    await Api.bootstrap();
    final wait = 900 - DateTime.now().difference(started).inMilliseconds;
    if (wait > 0) await Future.delayed(Duration(milliseconds: wait));
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(fadeRoute(Shell(role: roles[_i]), ms: 800), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final r = roles[_i];
    final pad = MediaQuery.of(context).padding;
    return Scaffold(
      backgroundColor: C.paper,
      body: Stack(
        children: [
          Positioned(top: 0, left: 0, right: 0, height: 270, child: Halftone(color: C.ink, swirlY: 0.6, swirlX: 1.1)),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [C.paper.withValues(alpha: 0), C.paper]),
                ),
              ),
            ),
          ),
          ListView(
            padding: EdgeInsets.fromLTRB(22, pad.top + 8, 22, pad.bottom + 24),
            children: [
              Row(
                children: [
                  Pressable(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: C.card,
                        shape: BoxShape.circle,
                        border: Border.all(color: C.line),
                      ),
                      child: Icon(Icons.arrow_back_rounded, size: 18, color: C.ink),
                    ),
                  ),
                  const Spacer(),
                  const Logo(height: 28),
                  const Spacer(),
                  const ThemeToggle(),
                ],
              ),
              const SizedBox(height: 92),
              _roleSwitcher(),
              const SizedBox(height: 26),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 420),
                transitionBuilder: (c, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(a),
                    child: c,
                  ),
                ),
                child: Column(
                  key: ValueKey('$_i$_signup'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${r.name.toUpperCase()} PORTAL', style: mono(11, color: C.tealD)),
                    const SizedBox(height: 8),
                    _signup ? const Headline('Create your ', 'account.', size: 46) : Headline(r.title, r.italic, size: 46),
                    const SizedBox(height: 20),
                    if (_signup) _field('Full name', Icons.person_outline_rounded),
                    if (r.role == Role.company) _field('Company name', Icons.business_outlined),
                    if (r.role == Role.investor) _field('Fund / angel name', Icons.account_balance_wallet_outlined),
                    if (r.role == Role.college) _field('Institution or club', Icons.account_balance_outlined),
                    _field(r.emailLabel, Icons.alternate_email_rounded),
                    _field('Password', Icons.lock_outline_rounded, obscure: true),
                    if (r.role == Role.admin) _field('6-digit 2FA code', Icons.shield_outlined),
                  ],
                ),
              ),
              if (!_signup)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_box_rounded, size: 18, color: C.ink),
                        const SizedBox(width: 6),
                        Text('Keep me signed in', style: sans(13, color: C.muted)),
                      ],
                    ),
                    Text(
                      'Forgot password?',
                      style: sans(13, weight: FontWeight.w600).copyWith(decoration: TextDecoration.underline),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              PrimaryButton(_signup ? 'Create account' : r.cta, loading: _loading, onTap: _submit),
              if (r.role == Role.student || r.role == Role.company) ...[
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: Divider(color: C.line)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or continue with', style: sans(12, color: C.muted)),
                    ),
                    Expanded(child: Divider(color: C.line)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _oauth('Google', Icons.g_mobiledata_rounded)),
                    const SizedBox(width: 10),
                    Expanded(child: _oauth(r.role == Role.student ? 'GitHub' : 'LinkedIn', r.role == Role.student ? Icons.code_rounded : Icons.work_outline_rounded)),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => setState(() => _signup = !_signup),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: _signup ? 'Already have an account? ' : 'New here? ',
                          style: sans(14, color: C.muted),
                        ),
                        TextSpan(
                          text: _signup ? 'Sign in' : 'Create an account',
                          style: sans(14, weight: FontWeight.w700).copyWith(decoration: TextDecoration.underline),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _roleSwitcher() => LayoutBuilder(
    builder: (context, c) {
      final w = (c.maxWidth - 10) / roles.length;
      return Container(
        height: 50,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: C.bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.line),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 550),
              curve: Curves.easeOutBack,
              left: w * _i,
              top: 0,
              bottom: 0,
              width: w,
              child: Container(
                decoration: BoxDecoration(
                  color: C.card,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 4))],
                ),
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: 4),
                child: Container(width: 18, height: 2, color: C.tealD),
              ),
            ),
            Row(
              children: [
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
              ],
            ),
          ],
        ),
      );
    },
  );

  Widget _field(String label, IconData ic, {bool obscure = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      obscureText: obscure && _hide,
      cursorColor: C.ink,
      style: sans(16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: sans(15, color: C.muted),
        floatingLabelStyle: sans(13, color: C.ink),
        prefixIcon: Icon(ic, color: C.muted, size: 20),
        suffixIcon: obscure
            ? IconButton(
                icon: Icon(_hide ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: C.muted, size: 20),
                onPressed: () => setState(() => _hide = !_hide),
              )
            : null,
        filled: true,
        fillColor: C.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: C.line2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: C.ink, width: 1.4),
        ),
      ),
    ),
  );

  Widget _oauth(String t, IconData ic) => Pressable(
    child: Container(
      height: 52,
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.line2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(ic, size: 22, color: C.ink),
          const SizedBox(width: 6),
          Text(t, style: sans(14, weight: FontWeight.w500)),
        ],
      ),
    ),
  );
}
