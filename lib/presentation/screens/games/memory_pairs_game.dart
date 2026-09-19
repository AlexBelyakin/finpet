import 'package:flutter/material.dart';

import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/presentation/screens/games/game_ui.dart';
import 'package:finpet/presentation/state/game_controller.dart';
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
  late List<_Card> _cards;
  int? _first;
  bool _lock = false;
  int _moves = 0;
  bool _finished = false;
  bool _paid = false;

  @override
  void initState() {
    super.initState();
    _deal();
  }

  void _deal() {
    const pairs = [
      (0, '🥣', 'Корм'),
      (1, '🚌', 'Проезд'),
      (2, '🧸', 'Игрушка'),
      (3, '🐷', 'Копилка'),
    ];
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
    await Future<void>.delayed(const Duration(milliseconds: 650));
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
          final coins = (12 - _moves).clamp(4, 24);
          await widget.controller.rewardMinigame(
            title: 'Игра «Пары»',
            coins: coins,
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
    if (_finished) {
      final coins = (12 - _moves).clamp(4, 24);
      return GameResultBody(
        title: 'Найди пары',
        scoreLine: 'Ходы: $_moves',
        coinsLine: '+$coins монет',
        onAgain: () => setState(_deal),
        onDone: () => Navigator.pop(context),
      );
    }

    return FinniScaffold(
      title: 'Найди пары',
      body: Column(
        children: [
          const Text('Открой две одинаковые карточки: нужное, желаемое или копилка.'),
          const SizedBox(height: 8),
          Text('Ходы: $_moves', style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Expanded(
            child: SoftPlayField(
              colors: const [Color(0xFFEDE4FF), Color(0xFFFFE8F2)],
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                  Text(card.emoji, style: const TextStyle(fontSize: 28)),
                                  Text(
                                    card.label,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              )
                            : const Icon(Icons.help_rounded, color: Colors.white),
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
