import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';
import '../widgets/scene.dart';
import '../widgets/ui.dart';
import 'shell.dart';

/// Login: an illustrated header in the role's world + a clean form card.
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
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(fadeRoute(Shell(role: roles[_i]), ms: 800), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final r = roles[_i], p = rolePalettes[r.role]!;
    final pad = MediaQuery.of(context).padding;
    final size = MediaQuery.of(context).size;
    final headerH = size.height * 0.42;
    return Scaffold(
      backgroundColor: C.paper,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerH + 40,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: Scene(key: ValueKey(_i), p: p, horizon: 0.55),
            ),
          ),
          Positioned(
            right: 18,
            top: headerH - 118,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Seal(key: ValueKey(_i), text: p.seal, color: p.accent, size: 96, center: r.emoji),
            ),
          ),
          Positioned(
            left: size.width * 0.58,
            top: headerH - 70,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Sticker(p.emoji[2], key: ValueKey('s$_i'), size: 46, delay: 200),
            ),
          ),
          Positioned(
            top: pad.top + 8,
            left: 18,
            right: 18,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30),
                    ),
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                  ),
                ),
                const Spacer(),
                const Logo(light: true, height: 30),
                const Spacer(),
                const ThemeToggle(onImage: true),
              ],
            ),
          ),
          Positioned(
            top: pad.top + 84,
            left: 22,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              transitionBuilder: (c, a) => FadeTransition(
                opacity: a,
                child: SlideTransition(
                  position: Tween(begin: const Offset(-0.06, 0), end: Offset.zero).animate(a),
                  child: c,
                ),
              ),
              child: Text(
                r.headline,
                key: ValueKey(_i),
                style: display(50, color: Colors.white),
              ),
            ),
          ),
          Positioned.fill(
            top: headerH,
            child: Container(
              decoration: BoxDecoration(
                color: C.paper,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
                boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 40, offset: Offset(0, -10))],
              ),
              child: ListView(
                padding: EdgeInsets.fromLTRB(22, 18, 22, pad.bottom + 24),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: C.line2, borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _roleRow(),
                  const SizedBox(height: 18),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: Column(
                      key: ValueKey('$_i$_signup'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${r.name.toUpperCase()} PORTAL', style: mono(11, color: r.color)),
                        const SizedBox(height: 6),
                        Text(_signup ? 'Create your account' : 'Welcome back', style: serif(36)),
                        const SizedBox(height: 16),
                        if (_signup) _field(r.role == Role.student ? 'Full name' : 'Your name', Icons.person_outline_rounded),
                        if (r.role == Role.company) _field('Company name', Icons.business_rounded),
                        if (r.role == Role.investor) _field('Fund / angel name', Icons.account_balance_wallet_outlined),
                        if (r.role == Role.college) _field('Institution or club', Icons.account_balance_outlined),
                        _field(r.emailLabel, Icons.alternate_email_rounded),
                        _field('Password', Icons.lock_outline_rounded, obscure: true),
                        if (r.role == Role.admin) _field('6-digit 2FA code', Icons.shield_outlined),
                      ],
                    ),
                  ),
                  if (!_signup)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Forgot password?',
                        style: sans(13, weight: FontWeight.w600, color: r.color),
                      ),
                    ),
                  const SizedBox(height: 16),
                  PrimaryButton(_signup ? 'Create account' : r.cta, loading: _loading, bg: r.color, onTap: _submit),
                  if (r.role == Role.student || r.role == Role.company) ...[
                    const SizedBox(height: 16),
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
                        Expanded(child: _oauth('Google', 'G')),
                        const SizedBox(width: 10),
                        Expanded(child: _oauth(r.role == Role.student ? 'GitHub' : 'LinkedIn', r.role == Role.student ? '⌘' : 'in')),
                      ],
                    ),
                  ],
                  const SizedBox(height: 18),
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
                              style: sans(14, weight: FontWeight.w700, color: r.color),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleRow() => SizedBox(
    height: 40,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: roles.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final on = i == _i;
        return Pressable(
          onTap: () => setState(() => _i = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: on ? roles[i].color : C.bg,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: on ? roles[i].color : C.line),
            ),
            child: Row(
              children: [
                Text(roles[i].emoji, style: const TextStyle(fontSize: 15)),
                const SizedBox(width: 6),
                Text(
                  roles[i].name,
                  style: sans(13, weight: FontWeight.w600, color: on ? Colors.white : C.ink),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  Widget _field(String label, IconData ic, {bool obscure = false}) {
    final c = roles[_i].color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        obscureText: obscure && _hide,
        cursorColor: c,
        style: sans(16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: sans(15, color: C.muted),
          floatingLabelStyle: sans(13, color: c),
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
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: C.line2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: c, width: 1.6),
          ),
        ),
      ),
    );
  }

  Widget _oauth(String t, String g) => Pressable(
    child: Container(
      height: 52,
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: C.line2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(g, style: sans(16, weight: FontWeight.w800)),
          const SizedBox(width: 8),
          Text(t, style: sans(14, weight: FontWeight.w500)),
        ],
      ),
    ),
  );
}
