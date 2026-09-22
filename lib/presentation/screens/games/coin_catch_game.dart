import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/presentation/screens/games/game_ui.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import 'package:finpet/presentation/widgets/common.dart';
import 'package:finpet/presentation/widgets/icons.dart';
import 'package:finpet/presentation/widgets/shell.dart';

class _Token {
  _Token({
    required this.id,
    required this.dot,
    required this.kind,
  });

  final int id;
  final CatchDot dot;
  final _TokenKind kind;
}

enum _TokenKind { coin, gem, spend }

class CoinCatchGameScreen extends StatefulWidget {
  const CoinCatchGameScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<CoinCatchGameScreen> createState() => _CoinCatchGameScreenState();
}

class _CoinCatchGameScreenState extends State<CoinCatchGameScreen>
    with SingleTickerProviderStateMixin {
  static const _duration = 25;
  static const _maxTokens = 10;
  static const _spawnEvery = 0.72;
  static const _fall = 0.44;

  final _rng = Random();
  final _tokens = <_Token>[];
  final _dots = <CatchDot>[];
  final _ticks = ValueNotifier(0);
  final _scoreN = ValueNotifier(0);
  final _timeN = ValueNotifier(_duration);

  late final Ticker _ticker;
  Timer? _hintTimer;
  Duration _last = Duration.zero;
  double _spawnAcc = 0;
  double _clockAcc = 0;
  int _id = 1;
  bool _running = false;
  bool _done = false;
  bool _paid = false;
  String? _hint;

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
    _scoreN.dispose();
    _timeN.dispose();
    super.dispose();
  }

  void _start() {
    _ticker.stop();
    _hintTimer?.cancel();
    _tokens.clear();
    _dots.clear();
    _last = Duration.zero;
    _spawnAcc = 0;
    _clockAcc = 0;
    _scoreN.value = 0;
    _timeN.value = _duration;
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

    final live = <_Token>[];
    _dots.clear();
    final fall = _fall * dt;
    for (final token in _tokens) {
      token.dot.y += fall;
      if (token.dot.y <= 1.12) {
        live.add(token);
        _dots.add(token.dot);
      }
    }
    _tokens
      ..clear()
      ..addAll(live);

    _spawnAcc += dt;
    if (_spawnAcc >= _spawnEvery && _tokens.length < _maxTokens) {
      _spawnAcc = 0;
      final r = _rng.nextDouble();
      final kind = r > 0.82
          ? _TokenKind.gem
          : r > 0.62
              ? _TokenKind.spend
              : _TokenKind.coin;
      final token = _Token(
        id: _id++,
        kind: kind,
        dot: CatchDot(
          x: 0.08 + _rng.nextDouble() * 0.78,
          y: -0.08,
          fill: switch (kind) {
            _TokenKind.gem => AppTheme.sky,
            _TokenKind.spend => const Color(0xFFE36A8A),
            _TokenKind.coin => const Color(0xFFE8B84A),
          },
          mark: switch (kind) {
            _TokenKind.gem => CatchMark.gem,
            _TokenKind.spend => CatchMark.spend,
            _TokenKind.coin => CatchMark.coin,
          },
        ),
      );
      _tokens.add(token);
      _dots.add(token.dot);
    }

    _clockAcc += dt;
    if (_clockAcc >= 1) {
      _clockAcc -= 1;
      _timeN.value -= 1;
      if (_timeN.value <= 0) {
        _finish();
        return;
      }
    }
    _ticks.value++;
  }

  Future<void> _finish() async {
    _ticker.stop();
    final reward = min(80, _scoreN.value * 2);
    setState(() {
      _running = false;
      _tokens.clear();
      _dots.clear();
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

  void _tapAt(Offset local, Size size) {
    _Token? hit;
    var best = 32.0 * 32.0;
    for (final token in _tokens) {
      final dx = token.dot.x * size.width - local.dx;
      final dy = token.dot.y * size.height - local.dy;
      final d2 = dx * dx + dy * dy;
      if (d2 <= best) {
        best = d2;
        hit = token;
      }
    }
    if (hit == null) return;
    _tokens.remove(hit);
    _dots.remove(hit.dot);
    final delta = switch (hit.kind) {
      _TokenKind.gem => 3,
      _TokenKind.spend => -2,
      _TokenKind.coin => 1,
    };
    _scoreN.value = max(0, _scoreN.value + delta);
    _ticks.value++;
    if (hit.kind == _TokenKind.spend) {
      _showHint(
        'Это лишняя трата, не монета. Такие лучше не ловить — очки уходят.',
      );
    }
  }

  void _showHint(String text) {
    _hintTimer?.cancel();
    setState(() => _hint = text);
    _hintTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _hint = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return GameResultBody(
        title: 'Лови монетки',
        scoreLine: 'Собрано очков: ${_scoreN.value}',
        coinsLine: '+${min(80, _scoreN.value * 2)} монет',
        onAgain: _start,
        onDone: () => Navigator.pop(context),
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
                const CircleGlyph(
                  icon: FinniIcons.coins,
                  color: Color(0xFFE8B84A),
                  size: 96,
                  iconSize: 48,
                ),
                const SizedBox(height: 16),
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
              ValueListenableBuilder(
                valueListenable: _scoreN,
                builder: (_, score, _) => Chip(
                  backgroundColor: AppTheme.peach.withValues(alpha: 0.35),
                  label: Text('Очки: $score'),
                ),
              ),
              const Spacer(),
              ValueListenableBuilder(
                valueListenable: _timeN,
                builder: (_, time, _) => Chip(
                  backgroundColor: AppTheme.sky.withValues(alpha: 0.4),
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
                final size = Size(box.maxWidth, box.maxHeight);
                return ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (d) => _tapAt(d.localPosition, size),
                    child: SoftPlayField(
                      child: CustomPaint(
                        painter: CatchDotsPainter(dots: _dots, tick: _ticks),
                        child: const SizedBox.expand(),
                      ),
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
