import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/presentation/screens/games/game_ui.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import 'package:finpet/presentation/widgets/icons.dart';
import 'package:finpet/presentation/widgets/shell.dart';

class _Drop {
  _Drop({
    required this.dot,
    required this.good,
  });

  final CatchDot dot;
  final bool good;
}

class PiggyCatchGameScreen extends StatefulWidget {
  const PiggyCatchGameScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<PiggyCatchGameScreen> createState() => _PiggyCatchGameScreenState();
}

class _PiggyCatchGameScreenState extends State<PiggyCatchGameScreen>
    with SingleTickerProviderStateMixin {
  static const _maxDrops = 8;

  final _rng = Random();
  final _drops = <_Drop>[];
  final _dots = <CatchDot>[];
  final _ticks = ValueNotifier(0);
  final _piggyN = ValueNotifier(0.5);
  final _scoreN = ValueNotifier(0);
  final _timeN = ValueNotifier(22);

  late final Ticker _ticker;
  Timer? _hintTimer;
  MiniDifficulty? _level;
  Duration _last = Duration.zero;
  double _spawnAcc = 0;
  double _clockAcc = 0;
  bool _running = false;
  bool _done = false;
  bool _paid = false;
  String? _hint;

  double get _fall => switch (_level) {
        MiniDifficulty.easy => 0.30,
        MiniDifficulty.hard => 0.65,
        _ => 0.45,
      };

  double get _spawnEvery => switch (_level) {
        MiniDifficulty.easy => 0.95,
        MiniDifficulty.hard => 0.55,
        _ => 0.75,
      };

  double get _goodChance => switch (_level) {
        MiniDifficulty.easy => 0.82,
        MiniDifficulty.hard => 0.5,
        _ => 0.72,
      };

  double get _catchRadius => switch (_level) {
        MiniDifficulty.easy => 0.16,
        MiniDifficulty.hard => 0.09,
        _ => 0.12,
      };

  int get _seconds => switch (_level) {
        MiniDifficulty.easy => 26,
        MiniDifficulty.hard => 16,
        _ => 22,
      };

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _hintTimer?.cancel();
    _ticks.dispose();
    _piggyN.dispose();
    _scoreN.dispose();
    _timeN.dispose();
    super.dispose();
  }

  void _showHint(String text) {
    _hintTimer?.cancel();
    setState(() => _hint = text);
    _hintTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _hint = null);
    });
  }

  void _start(MiniDifficulty level) {
    _ticker.stop();
    _hintTimer?.cancel();
    _drops.clear();
    _dots.clear();
    _last = Duration.zero;
    _spawnAcc = 0;
    _clockAcc = 0;
    _piggyN.value = 0.5;
    _scoreN.value = 0;
    _level = level;
    _timeN.value = _seconds;
    setState(() {
      _running = true;
      _done = false;
      _paid = false;
      _hint = null;
    });
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    if (!_running) return;
    var dt = _last == Duration.zero
        ? 0.0
        : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (dt <= 0) return;
    if (dt > 0.05) dt = 0.05;

    var caughtSpend = false;
    var shouldFinish = false;
    final piggy = _piggyN.value;
    final fall = _fall * dt;
    final live = <_Drop>[];
    _dots.clear();
    for (final drop in _drops) {
      drop.dot.y += fall;
      if (drop.dot.y < 0.88) {
        live.add(drop);
        _dots.add(drop.dot);
        continue;
      }
      if ((drop.dot.x - piggy).abs() < _catchRadius) {
        _scoreN.value = max(0, _scoreN.value + (drop.good ? 2 : -2));
        if (!drop.good) caughtSpend = true;
      }
    }
    _drops
      ..clear()
      ..addAll(live);

    _spawnAcc += dt;
    if (_spawnAcc >= _spawnEvery && _drops.length < _maxDrops) {
      _spawnAcc = 0;
      final good = _rng.nextDouble() < _goodChance;
      final drop = _Drop(
        good: good,
        dot: CatchDot(
          x: 0.08 + _rng.nextDouble() * 0.84,
          y: -0.05,
          fill: good ? const Color(0xFFE8B84A) : const Color(0xFFE36A8A),
          mark: good ? CatchMark.coin : CatchMark.spend,
        ),
      );
      _drops.add(drop);
      _dots.add(drop.dot);
    }

    _clockAcc += dt;
    if (_clockAcc >= 1) {
      _clockAcc -= 1;
      _timeN.value -= 1;
      if (_timeN.value <= 0) shouldFinish = true;
    }

    _ticks.value++;
    if (caughtSpend) {
      _showHint(
        'Это покупка, не монета. Копилка копит, а не тратит. Такие лучше пропускать.',
      );
    }
    if (shouldFinish) {
      _finish();
    }
  }

  Future<void> _finish() async {
    _ticker.stop();
    final reward = min(80, _scoreN.value);
    setState(() {
      _running = false;
      _done = true;
      _drops.clear();
      _dots.clear();
    });
    if (!_paid) {
      _paid = true;
      await widget.controller.rewardMinigame(
        title: 'Игра «Копилка ловит»',
        coins: reward,
      );
    }
  }

  void _backToLevels() {
    _ticker.stop();
    _hintTimer?.cancel();
    setState(() {
      _level = null;
      _running = false;
      _done = false;
      _hint = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return GameResultBody(
        title: 'Копилка ловит',
        scoreLine: 'Очки: ${_scoreN.value} · ${_level?.label ?? ''}',
        coinsLine: '+${min(80, _scoreN.value)} монет',
        onAgain: _backToLevels,
        onDone: () => Navigator.pop(context),
      );
    }

    if (!_running) {
      return DifficultyStart(
        title: 'Копилка ловит',
        icon: FinniIcons.savings,
        color: AppTheme.peach,
        howTo: 'Води копилку влево-вправо. Лови монеты, не лови покупки.',
        onPick: _start,
      );
    }

    return FinniScaffold(
      title: 'Копилка ловит',
      body: Column(
        children: [
          Row(
            children: [
              ValueListenableBuilder(
                valueListenable: _scoreN,
                builder: (_, score, _) => Chip(label: Text('Очки: $score')),
              ),
              const SizedBox(width: 8),
              Chip(label: Text(_level?.label ?? '')),
              const Spacer(),
              ValueListenableBuilder(
                valueListenable: _timeN,
                builder: (_, time, _) => Chip(
                  avatar: const Icon(FinniIcons.timer, size: 16),
                  label: Text('$time с'),
                ),
              ),
            ],
          ),
          if (_hint != null) ...[
            const SizedBox(height: 8),
            Text(
              _hint!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
          const SizedBox(height: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) {
                return GestureDetector(
                  onHorizontalDragUpdate: (d) {
                    _piggyN.value =
                        (_piggyN.value + d.delta.dx / box.maxWidth)
                            .clamp(0.08, 0.92);
                  },
                  onTapDown: (d) {
                    _piggyN.value = (d.localPosition.dx / box.maxWidth)
                        .clamp(0.08, 0.92);
                  },
                  child: SoftPlayField(
                    colors: const [Color(0xFFFFF1D6), Color(0xFFFFD9C6)],
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomPaint(
                          painter: CatchDotsPainter(dots: _dots, tick: _ticks),
                          child: const SizedBox.expand(),
                        ),
                        ValueListenableBuilder(
                          valueListenable: _piggyN,
                          builder: (_, piggy, icon) {
                            return Positioned(
                              left: piggy * box.maxWidth - 44,
                              bottom: 12,
                              child: icon!,
                            );
                          },
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
