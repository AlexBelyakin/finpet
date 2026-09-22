import 'package:flutter/material.dart';

import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/presentation/screens/games/game_ui.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import 'package:finpet/presentation/widgets/common.dart';
import 'package:finpet/presentation/widgets/icons.dart';
import 'package:finpet/presentation/widgets/shell.dart';

enum _Bin { need, want, save }

class _Piece {
  const _Piece(this.emoji, this.label, this.bin, this.why);
  final String emoji;
  final String label;
  final _Bin bin;
  final String why;

  String get binLabel => switch (bin) {
        _Bin.need => 'Надо',
        _Bin.want => 'Хочу',
        _Bin.save => 'Копилка',
      };

  String explain(_Bin picked) {
    final pickedLabel = switch (picked) {
      _Bin.need => 'Надо',
      _Bin.want => 'Хочу',
      _Bin.save => 'Копилка',
    };
    return '$label сюда не подходит. $why Правильная баночка — «$binLabel», а ты положил в «$pickedLabel».';
  }
}

class SortJarsGameScreen extends StatefulWidget {
  const SortJarsGameScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<SortJarsGameScreen> createState() => _SortJarsGameScreenState();
}

class _SortJarsGameScreenState extends State<SortJarsGameScreen> {
  static const _pool = [
    _Piece('🥣', 'Корм', _Bin.need, 'Питомец должен есть — это нужное.'),
    _Piece('🚌', 'Проезд', _Bin.need, 'До школы нужно доехать.'),
    _Piece('💊', 'Лекарство', _Bin.need, 'Здоровье важнее хотелок.'),
    _Piece('🎮', 'Игра', _Bin.want, 'Игру можно купить позже.'),
    _Piece('🍦', 'Мороженое', _Bin.want, 'Мороженое приятное, но не обязательное.'),
    _Piece('🧸', 'Игрушка', _Bin.want, 'Игрушка — это желаемое.'),
    _Piece('🏠', 'На домик', _Bin.save, 'Домик — цель, монеты откладывают.'),
    _Piece('🐷', 'В копилку', _Bin.save, 'Это прямо про копилку.'),
    _Piece('🎯', 'На цель', _Bin.save, 'Цель копят, а не тратят сразу.'),
  ];

  late List<_Piece> _queue;
  final _placed = <_Bin, List<_Piece>>{
    _Bin.need: [],
    _Bin.want: [],
    _Bin.save: [],
  };
  int _score = 0;
  int _doneCount = 0;
  bool _finished = false;
  bool _paid = false;
  String? _flash;

  @override
  void initState() {
    super.initState();
    _queue = [..._pool]..shuffle();
  }

  Future<void> _drop(_Piece piece, _Bin bin) async {
    if (_finished) return;
    final ok = piece.bin == bin;
    if (!ok) {
      await showOkHint(
        context,
        title: 'Ой, не та баночка',
        body: piece.explain(bin),
      );
      return;
    }
    setState(() {
      _queue.remove(piece);
      _placed[bin]!.add(piece);
      _score += 1;
      _doneCount += 1;
      _flash = 'Верно!';
    });
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _flash = null);
    if (_doneCount >= _pool.length) {
      setState(() => _finished = true);
      if (!_paid) {
        _paid = true;
        await widget.controller.rewardMinigame(
          title: 'Игра «Три баночки»',
          coins: _score * 6,
        );
      }
    }
  }

  void _restart() {
    setState(() {
      _queue = [..._pool]..shuffle();
      for (final bin in _Bin.values) {
        _placed[bin]!.clear();
      }
      _score = 0;
      _doneCount = 0;
      _finished = false;
      _paid = false;
      _flash = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return GameResultBody(
        title: 'Три баночки',
        scoreLine: 'Верно: $_score из ${_pool.length}',
        coinsLine: '+${_score * 6} монет',
        onAgain: _restart,
        onDone: () => Navigator.pop(context),
      );
    }

    return FinniScaffold(
      title: 'Три баночки',
      body: Column(
        children: [
          Row(
            children: [
              Text('Перетащи в: нужное / хочу / копилка'),
              const Spacer(),
              Text('$_score/${_pool.length}'),
            ],
          ),
          if (_flash != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _flash!,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          const SizedBox(height: 10),
          SizedBox(
            height: 92,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final piece in _queue)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Draggable<_Piece>(
                      data: piece,
                      feedback: _chip(piece, lifting: true),
                      childWhenDragging: Opacity(opacity: 0.25, child: _chip(piece)),
                      child: _chip(piece),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              children: [
                _jar(_Bin.need, 'Надо', AppTheme.mint, FinniIcons.need),
                const SizedBox(width: 8),
                _jar(_Bin.want, 'Хочу', AppTheme.peach, FinniIcons.want),
                const SizedBox(width: 8),
                _jar(_Bin.save, 'Копилка', AppTheme.sky, FinniIcons.savings),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _jar(_Bin bin, String label, Color color, IconData icon) {
    return Expanded(
      child: DragTarget<_Piece>(
        onWillAcceptWithDetails: (_) => true,
        onAcceptWithDetails: (details) => _drop(details.data, bin),
        builder: (context, candidate, rejected) {
          final hot = candidate.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: hot ? 0.45 : 0.22),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: color, width: hot ? 3 : 1.5),
            ),
            child: Column(
              children: [
                CircleGlyph(icon: icon, color: color, size: 48, iconSize: 24),
                const SizedBox(height: 6),
                Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (final p in _placed[bin]!)
                        Text(p.emoji, style: const TextStyle(fontSize: 22)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _chip(_Piece piece, {bool lifting = false}) {
    return Material(
      elevation: lifting ? 8 : 1,
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(piece.emoji, style: const TextStyle(fontSize: 28)),
            Text(piece.label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
