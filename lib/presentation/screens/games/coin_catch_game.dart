import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/presentation/screens/games/game_ui.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import 'package:finpet/presentation/widgets/icons.dart';
import 'package:finpet/presentation/widgets/shell.dart';

class CoinCatchGameScreen extends StatefulWidget {
  const CoinCatchGameScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<CoinCatchGameScreen> createState() => _CoinCatchGameScreenState();
}

enum _TokenKind { coin, gem, spend }

class _Token {
  _Token({
    required this.id,
    required this.x,
    required this.y,
    required this.kind,
  });

  final int id;
  final double x;
  double y;
  final _TokenKind kind;
}

class _CoinCatchGameScreenState extends State<CoinCatchGameScreen> {
  static const _duration = 25;

  final _rng = Random();
  final _tokens = <_Token>[];
  Timer? _spawn;
  Timer? _tick;
  Timer? _clock;
  int _id = 1;
  int _score = 0;
  int _time = _duration;
  bool _running = false;
  bool _done = false;
  bool _paid = false;

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }

  void _stopTimers() {
    _spawn?.cancel();
    _tick?.cancel();
    _clock?.cancel();
    _spawn = null;
    _tick = null;
    _clock = null;
  }

  void _start() {
    _stopTimers();
    setState(() {
      _tokens.clear();
      _score = 0;
      _time = _duration;
      _running = true;
      _done = false;
      _paid = false;
    });
    _spawn = Timer.periodic(const Duration(milliseconds: 620), (_) {
      if (!mounted || !_running) return;
      final r = _rng.nextDouble();
      final kind = r > 0.82
          ? _TokenKind.gem
          : r > 0.62
              ? _TokenKind.spend
              : _TokenKind.coin;
      final token = _Token(
        id: _id++,
        x: 0.08 + _rng.nextDouble() * 0.78,
        y: -0.08,
        kind: kind,
      );
      setState(() => _tokens.add(token));
    });
    _tick = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted || !_running) return;
      setState(() {
        for (final token in _tokens) {
          token.y += 0.022;
        }
        _tokens.removeWhere((e) => e.y > 1.12);
      });
    });
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_running) return;
      if (_time <= 1) {
        _finish();
        return;
      }
      setState(() => _time -= 1);
    });
  }

  Future<void> _finish() async {
    _stopTimers();
    final reward = min(80, _score * 2);
    setState(() {
      _running = false;
      _tokens.clear();
      _done = true;
    });
    if (!_paid) {
      _paid = true;
      await widget.controller.rewardMinigame(
        title: 'Игра «Лови монетки»',
        coins: reward,
      );
    }
  }

  void _tap(_Token token) {
    setState(() {
      _tokens.removeWhere((e) => e.id == token.id);
      final delta = switch (token.kind) {
        _TokenKind.gem => 3,
        _TokenKind.spend => -2,
        _TokenKind.coin => 1,
      };
      _score = max(0, _score + delta);
    });
  }

  Widget _tokenView(_TokenKind kind) {
    final color = switch (kind) {
      _TokenKind.gem => AppTheme.sky,
      _TokenKind.spend => const Color(0xFFE36A8A),
      _TokenKind.coin => const Color(0xFFE8B84A),
    };
    return CircleAvatar(
      radius: 24,
      backgroundColor: color,
      child: Icon(
        kind == _TokenKind.gem ? Icons.diamond_rounded : FinniIcons.coins,
        color: Colors.white,
        size: 26,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return FinniScaffold(
        title: 'Лови монетки',
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 8),
              Text('Собрано очков: $_score',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('+${min(80, _score * 2)} монет'),
              const SizedBox(height: 20),
              FilledButton(onPressed: _start, child: const Text('Ещё раз')),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Готово'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_running) {
      return FinniScaffold(
        title: 'Лови монетки',
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(FinniIcons.coins, size: 72, color: Color(0xFFE8B84A)),
                const SizedBox(height: 12),
                Text(
                  'Тапай монеты и алмазы. Не трогай купюры — это лишние траты.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                FilledButton(onPressed: _start, child: const Text('Играть')),
              ],
            ),
          ),
        ),
      );
    }

    return FinniScaffold(
      title: 'Лови монетки',
      body: Column(
        children: [
          Row(
            children: [
              Chip(
                backgroundColor: AppTheme.peach.withValues(alpha: 0.35),
                label: Text('Очки: $_score'),
              ),
              const Spacer(),
              Chip(
                backgroundColor: AppTheme.sky.withValues(alpha: 0.4),
                label: Text('$_time с'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) {
                final h = box.maxHeight;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: SoftPlayField(
                    child: Stack(
                      children: [
                        for (final token in _tokens)
                          Positioned(
                            left: token.x * box.maxWidth - 28,
                            top: token.y * h - 28,
                            child: GestureDetector(
                              onTapDown: (_) => _tap(token),
                              child: SizedBox(
                                width: 56,
                                height: 56,
                                child: AnimatedScale(
                                  scale: 1,
                                  duration: const Duration(milliseconds: 120),
                                  child: _tokenView(token.kind),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
