import 'package:flutter/material.dart';

import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/domain/models.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import 'package:finpet/presentation/widgets/shell.dart';

class NeedWantGameScreen extends StatefulWidget {
  const NeedWantGameScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<NeedWantGameScreen> createState() => _NeedWantGameScreenState();
}

class _NeedWantItem {
  const _NeedWantItem(this.emoji, this.label, this.kind);
  final String emoji;
  final String label;
  final ExpenseKind kind;
}

class _NeedWantGameScreenState extends State<NeedWantGameScreen> {
  static const _pool = [
    _NeedWantItem('🍞', 'Хлеб', ExpenseKind.need),
    _NeedWantItem('🎮', 'Новая игра', ExpenseKind.want),
    _NeedWantItem('🚌', 'Проезд в школу', ExpenseKind.need),
    _NeedWantItem('🍭', 'Леденец', ExpenseKind.want),
    _NeedWantItem('💊', 'Лекарство', ExpenseKind.need),
    _NeedWantItem('🧸', 'Игрушка', ExpenseKind.want),
    _NeedWantItem('📚', 'Учебник', ExpenseKind.need),
    _NeedWantItem('🎈', 'Шарик', ExpenseKind.want),
    _NeedWantItem('🧦', 'Тёплые носки', ExpenseKind.need),
    _NeedWantItem('🍦', 'Лишнее мороженое', ExpenseKind.want),
    _NeedWantItem('🪥', 'Зубная щётка', ExpenseKind.need),
    _NeedWantItem('💎', 'Блестящая наклейка', ExpenseKind.want),
    _NeedWantItem('🥣', 'Корм для питомца', ExpenseKind.need),
    _NeedWantItem('🎀', 'Бантик', ExpenseKind.want),
  ];

  late List<_NeedWantItem> _items;
  int _idx = 0;
  int _score = 0;
  bool? _correct;
  bool _done = false;
  bool _paid = false;

  @override
  void initState() {
    super.initState();
    _items = [..._pool]..shuffle();
    _items = _items.take(8).toList();
  }

  Future<void> _answer(ExpenseKind kind) async {
    if (_correct != null || _done) return;
    final ok = _items[_idx].kind == kind;
    setState(() {
      _correct = ok;
      if (ok) _score += 1;
    });
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    if (_idx + 1 >= _items.length) {
      setState(() => _done = true);
      if (!_paid) {
        _paid = true;
        await widget.controller.rewardMinigame(
          title: 'Игра «Надо или хочу?»',
          coins: _score * 6,
        );
      }
      return;
    }
    setState(() {
      _idx += 1;
      _correct = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return FinniScaffold(
        title: 'Надо или хочу?',
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 8),
              Text('Правильно: $_score из ${_items.length}',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('+${_score * 6} монет'),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отлично'),
              ),
            ],
          ),
        ),
      );
    }

    final current = _items[_idx];
    return FinniScaffold(
      title: 'Надо или хочу?',
      body: Column(
        children: [
          Row(
            children: [
              Text('Вопрос ${_idx + 1}/${_items.length}'),
              const Spacer(),
              Text('Очки: $_score'),
            ],
          ),
          const Spacer(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Container(
              key: ValueKey(_idx),
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE5D4FF), Color(0xFFFFE4F2)],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(current.emoji, style: const TextStyle(fontSize: 64)),
                      const SizedBox(height: 8),
                      Text(
                        current.label,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (_correct != null)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: (_correct! ? AppTheme.mint : AppTheme.peach)
                            .withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Center(
                        child: Icon(
                          _correct! ? Icons.check_rounded : Icons.close_rounded,
                          size: 72,
                          color: _correct! ? const Color(0xFF2F7A5D) : Colors.red[800],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Это «надо» или «хочу»?'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2F7A5D),
                    minimumSize: const Size(48, 64),
                  ),
                  onPressed: () => _answer(ExpenseKind.need),
                  child: const Text('Надо'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE36A8A),
                    minimumSize: const Size(48, 64),
                  ),
                  onPressed: () => _answer(ExpenseKind.want),
                  child: const Text('Хочу'),
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
