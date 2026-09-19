import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/presentation/screens/games/game_ui.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import 'package:finpet/presentation/widgets/icons.dart';
import 'package:finpet/presentation/widgets/shell.dart';

class _Drop {
  _Drop({
    required this.id,
    required this.x,
    required this.y,
    required this.good,
    required this.emoji,
  });

  final int id;
  double x;
  double y;
  final bool good;
  final String emoji;
}

class PiggyCatchGameScreen extends StatefulWidget {
  const PiggyCatchGameScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<PiggyCatchGameScreen> createState() => _PiggyCatchGameScreenState();
}

class _PiggyCatchGameScreenState extends State<PiggyCatchGameScreen> {
  final _rng = Random();
  final _drops = <_Drop>[];
  Timer? _loop;
  int _id = 1;
  int _score = 0;
  int _time = 22;
  double _piggy = 0.5;
  bool _running = false;
  bool _done = false;
  bool _paid = false;

  @override
  void dispose() {
    _loop?.cancel();
    super.dispose();
  }

  void _start() {
    _loop?.cancel();
    setState(() {
      _drops.clear();
      _score = 0;
      _time = 22;
      _piggy = 0.5;
      _running = true;
      _done = false;
      _paid = false;
    });
    var acc = 0;
    var clock = 0;
    _loop = Timer.periodic(const Duration(milliseconds: 40), (_) {
      if (!mounted || !_running) return;
      acc += 40;
      clock += 40;
      var shouldFinish = false;
      setState(() {
        for (final drop in _drops) {
          drop.y += 0.018;
        }
        _drops.removeWhere((d) {
          if (d.y < 0.88) return false;
          final caught = (d.x - _piggy).abs() < 0.12;
          if (caught) {
            _score = max(0, _score + (d.good ? 2 : -2));
          }
          return true;
        });
        if (acc >= 700) {
          acc = 0;
          _drops.add(
            _Drop(
              id: _id++,
              x: 0.08 + _rng.nextDouble() * 0.84,
              y: -0.05,
              good: _rng.nextDouble() > 0.28,
              emoji: _rng.nextDouble() > 0.28 ? '₽' : '🛍️',
            ),
          );
        }
        if (clock >= 1000) {
          clock = 0;
          _time -= 1;
          if (_time <= 0) shouldFinish = true;
        }
      });
      if (shouldFinish) {
        _finish();
      }
    });
  }

  Future<void> _finish() async {
    _loop?.cancel();
    final reward = min(80, _score);
    setState(() {
      _running = false;
      _done = true;
      _drops.clear();
    });
    if (!_paid) {
      _paid = true;
      await widget.controller.rewardMinigame(
        title: 'Игра «Копилка ловит»',
        coins: reward,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return GameResultBody(
        title: 'Копилка ловит',
        scoreLine: 'Очки: $_score',
        coinsLine: '+${min(80, _score)} монет',
        onAgain: _start,
        onDone: () => Navigator.pop(context),
      );
    }

    if (!_running) {
      return FinniScaffold(
        title: 'Копилка ловит',
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(FinniIcons.savings, size: 72, color: AppTheme.peach),
              const SizedBox(height: 12),
              const Text(
                'Води копилку влево-вправо. Лови монеты, не лови покупки.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
              const SizedBox(height: 20),
              FilledButton(onPressed: _start, child: const Text('Играть')),
            ],
          ),
        ),
      );
    }

    return FinniScaffold(
      title: 'Копилка ловит',
      body: Column(
        children: [
          Row(
            children: [
              Chip(label: Text('Очки: $_score')),
              const Spacer(),
              Chip(avatar: const Icon(FinniIcons.timer, size: 16), label: Text('$_time с')),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) {
                return GestureDetector(
                  onHorizontalDragUpdate: (d) {
                    setState(() {
                      _piggy = (_piggy + d.delta.dx / box.maxWidth).clamp(0.08, 0.92);
                    });
                  },
                  onTapDown: (d) {
                    setState(() {
                      _piggy = (d.localPosition.dx / box.maxWidth).clamp(0.08, 0.92);
                    });
                  },
                  child: SoftPlayField(
                    colors: const [Color(0xFFFFF1D6), Color(0xFFFFD9C6)],
                    child: Stack(
                      children: [
                        for (final drop in _drops)
                          Positioned(
                            left: drop.x * box.maxWidth - 22,
                            top: drop.y * box.maxHeight - 22,
                            child: Text(
                              drop.emoji,
                              style: const TextStyle(fontSize: 36),
                            ),
                          ),
                        Positioned(
                          left: _piggy * box.maxWidth - 44,
                          bottom: 12,
                          child: const Icon(
                            FinniIcons.savings,
                            size: 72,
                            color: Color(0xFFE36A8A),
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
