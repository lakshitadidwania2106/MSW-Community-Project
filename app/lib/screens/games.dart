import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/ui.dart';

/// Brain games that earn credits: Memory match + Reaction time.
class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});
  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  static const _em = ['🧠', '⚡', '🎯', '🧩', '🔥', '💎'];
  late List<String> _deck;
  final _open = <int>{}, _got = <int>{};
  int? _first;
  int _moves = 0;
  bool _lock = false;

  // reaction
  String _rState = 'idle';
  int? _rMs, _best;
  DateTime? _t0;
  Timer? _rTimer;

  @override
  void initState() {
    super.initState();
    _deal();
  }

  @override
  void dispose() {
    _rTimer?.cancel();
    super.dispose();
  }

  void _deal() => setState(() {
    _deck = [..._em, ..._em]..shuffle(math.Random());
    _open.clear();
    _got.clear();
    _first = null;
    _moves = 0;
  });

  void _tapCard(int i) {
    if (_lock || _open.contains(i) || _got.contains(i)) return;
    setState(() => _open.add(i));
    if (_first == null) {
      _first = i;
      return;
    }
    final a = _first!;
    _first = null;
    _moves++;
    if (_deck[a] == _deck[i]) {
      setState(() => _got.addAll([a, i]));
      if (_got.length == _deck.length) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Solved in $_moves moves — +${math.max(10, 60 - _moves * 2)} credits 🧠')));
    } else {
      _lock = true;
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() {
          _open.removeAll([a, i]);
          _lock = false;
        });
      });
    }
  }

  void _tapReaction() {
    switch (_rState) {
      case 'wait':
        _rTimer?.cancel();
        setState(() => _rState = 'early');
      case 'go':
        final ms = DateTime.now().difference(_t0!).inMilliseconds;
        setState(() {
          _rState = 'done';
          _rMs = ms;
          if (_best == null || ms < _best!) _best = ms;
        });
        if (ms < 250) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lightning reflexes — +20 credits ⚡')));
      default:
        setState(() => _rState = 'wait');
        _rTimer = Timer(Duration(milliseconds: 1200 + math.Random().nextInt(2200)), () {
          if (!mounted) return;
          setState(() {
            _rState = 'go';
            _t0 = DateTime.now();
          });
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, pad.top + 8, 20, pad.bottom + 30),
        children: [
          Row(
            children: [
              Pressable(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: C.card,
                    shape: BoxShape.circle,
                    border: Border.all(color: C.line),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, size: 18),
                ),
              ),
              const Spacer(),
              const Tag('+ credits', bg: C.lime),
            ],
          ),
          const SizedBox(height: 18),
          const Reveal(child: Headline('Play. Think. ', 'Earn credits.', size: 42)),
          const SizedBox(height: 20),
          Row(
            children: [
              Text('Memory match', style: serif(28)),
              const Spacer(),
              Text('$_moves MOVES', style: mono(11)),
              const SizedBox(width: 8),
              Pressable(onTap: _deal, child: const Icon(Icons.refresh_rounded)),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [for (var i = 0; i < _deck.length; i++) _card(i)],
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Text('Reaction time', style: serif(28)),
              const Spacer(),
              Text(_best == null ? 'BEST —' : 'BEST ${_best}MS', style: mono(11, color: C.tealD)),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTapDown: (_) => _tapReaction(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 200,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: switch (_rState) {
                  'wait' => const Color(0xFFE5484D),
                  'go' => C.lime,
                  _ => C.dark,
                },
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(switch (_rState) {
                'wait' => 'Wait for green…',
                'go' => 'TAP!',
                'early' => 'Too early! Tap to retry',
                'done' => '$_rMs ms',
                _ => 'Tap to start',
              }, style: serif(_rState == 'done' ? 64 : 34, color: _rState == 'go' ? C.black : Colors.white)),
            ),
          ),
          const SizedBox(height: 22),
          for (final g in const [('🔤', 'Word sprint'), ('🧮', 'Number ninja'), ('🗺', 'Logic grid')])
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card2(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Text(g.$1, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(g.$2, style: serif(24))),
                    const Tag('Coming soon'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _card(int i) {
    final shown = _open.contains(i) || _got.contains(i);
    return GestureDetector(
      onTap: () => _tapCard(i),
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: shown ? 1 : 0),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        builder: (_, v, _) {
          final front = v > 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..rotateY(v * math.pi),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: front ? (_got.contains(i) ? C.lime : Colors.white) : C.black,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: C.line),
              ),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(front ? math.pi : 0),
                child: front ? Text(_deck[i], style: const TextStyle(fontSize: 28)) : Text('M.', style: serif(22, color: C.teal)),
              ),
            ),
          );
        },
      ),
    );
  }
}
