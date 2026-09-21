import 'package:flutter/material.dart';

import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/presentation/screens/games/game_ui.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import 'package:finpet/presentation/widgets/icons.dart';
import 'package:finpet/presentation/widgets/shell.dart';

class _Card {
  _Card(this.id, this.pair, this.emoji, this.label);
  final int id;
  final int pair;
  final String emoji;
  final String label;
  bool open = false;
  bool done = false;
}

class MemoryPairsGameScreen extends StatefulWidget {
  const MemoryPairsGameScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<MemoryPairsGameScreen> createState() => _MemoryPairsGameScreenState();
}

class _MemoryPairsGameScreenState extends State<MemoryPairsGameScreen> {
  static const _pool = [
    (0, '🥣', 'Корм'),
    (1, '🚌', 'Проезд'),
    (2, '🧸', 'Игрушка'),
    (3, '🐷', 'Копилка'),
    (4, '💊', 'Лекарство'),
    (5, '🎮', 'Игра'),
    (6, '🍦', 'Мороженое'),
    (7, '🏠', 'Домик'),
  ];

  MiniDifficulty? _level;
  late List<_Card> _cards;
  int? _first;
  bool _lock = false;
  int _moves = 0;
  bool _finished = false;
  bool _paid = false;

  int get _pairCount => switch (_level) {
        MiniDifficulty.easy => 4,
        MiniDifficulty.hard => 8,
        _ => 6,
      };

  int get _peekMs => switch (_level) {
        MiniDifficulty.easy => 900,
        MiniDifficulty.hard => 380,
        _ => 650,
      };

  int get _coins {
    final bonus = switch (_level) {
      MiniDifficulty.easy => 12,
      MiniDifficulty.hard => 22,
      _ => 16,
    };
    return (bonus - _moves).clamp(4, 28);
  }

  void _deal(MiniDifficulty level) {
    _level = level;
    final pairs = _pool.take(_pairCount).toList();
    final cards = <_Card>[];
    var i = 0;
    for (final p in pairs) {
      cards.add(_Card(i++, p.$1, p.$2, p.$3));
      cards.add(_Card(i++, p.$1, p.$2, p.$3));
    }
    cards.shuffle();
    _cards = cards;
    _first = null;
    _lock = false;
    _moves = 0;
    _finished = false;
    _paid = false;
  }

  Future<void> _tap(int index) async {
    if (_lock || _cards[index].open || _cards[index].done) return;
    setState(() => _cards[index].open = true);
    if (_first == null) {
      _first = index;
      return;
    }
    _lock = true;
    _moves += 1;
    final a = _first!;
    final b = index;
    await Future<void>.delayed(Duration(milliseconds: _peekMs));
    if (!mounted) return;
    if (_cards[a].pair == _cards[b].pair) {
      setState(() {
        _cards[a].done = true;
        _cards[b].done = true;
        _first = null;
        _lock = false;
      });
      if (_cards.every((c) => c.done)) {
        setState(() => _finished = true);
        if (!_paid) {
          _paid = true;
          await widget.controller.rewardMinigame(
            title: 'Игра «Пары»',
            coins: _coins,
          );
        }
      }
    } else {
      setState(() {
        _cards[a].open = false;
        _cards[b].open = false;
        _first = null;
        _lock = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_level == null) {
      return DifficultyStart(
        title: 'Найди пары',
        icon: Icons.grid_view_rounded,
        color: AppTheme.lilac,
        howTo: 'Открой две одинаковые карточки: нужное, желаемое или копилка.',
        onPick: (level) => setState(() => _deal(level)),
      );
    }

    if (_finished) {
      return GameResultBody(
        title: 'Найди пары',
        scoreLine: 'Ходы: $_moves · ${_level!.label}',
        coinsLine: '+$_coins монет',
        onAgain: () => setState(() => _level = null),
        onDone: () => Navigator.pop(context),
      );
    }

    return FinniScaffold(
      title: 'Найди пары',
      body: Column(
        children: [
          Text(
            'Открой две одинаковые карточки. Уровень: ${_level!.label}',
          ),
          const SizedBox(height: 8),
          Text(
            'Ходы: $_moves',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SoftPlayField(
              colors: const [Color(0xFFEDE4FF), Color(0xFFFFE8F2)],
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, i) {
                  final card = _cards[i];
                  final show = card.open || card.done;
                  return GestureDetector(
                    onTap: () => _tap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      decoration: BoxDecoration(
                        color: show ? AppTheme.card : AppTheme.lilac,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: card.done ? AppTheme.mint : Colors.white70,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: show
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    card.emoji,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                  Text(
                                    card.label,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              )
                            : const Icon(
                                FinniIcons.cards,
                                color: Colors.white,
                                size: 28,
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
