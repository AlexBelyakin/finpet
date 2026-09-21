import 'package:flutter/material.dart';

import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/domain/models.dart';
import 'package:finpet/presentation/screens/games/game_ui.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import 'package:finpet/presentation/widgets/common.dart';
import 'package:finpet/presentation/widgets/icons.dart';
import 'package:finpet/presentation/widgets/shell.dart';

class NeedWantGameScreen extends StatefulWidget {
  const NeedWantGameScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<NeedWantGameScreen> createState() => _NeedWantGameScreenState();
}

class _NeedWantItem {
  const _NeedWantItem(this.emoji, this.label, this.kind, this.why);
  final String emoji;
  final String label;
  final ExpenseKind kind;
  final String why;

  String explain(ExpenseKind picked) {
    if (kind == ExpenseKind.need) {
      return '$label — это нужное. $why Ты выбрал «хочу», а без этого обойтись трудно.';
    }
    return '$label — это желаемое. $why Ты выбрал «надо», но без этого можно обойтись.';
  }
}

class _NeedWantGameScreenState extends State<NeedWantGameScreen> {
  static const _pool = [
    _NeedWantItem('🍞', 'Хлеб', ExpenseKind.need, 'Это еда, без неё нельзя.'),
    _NeedWantItem(
      '🎮',
      'Новая игра',
      ExpenseKind.want,
      'Без новой игры можно жить.',
    ),
    _NeedWantItem(
      '🚌',
      'Проезд в школу',
      ExpenseKind.need,
      'Без проезда не добраться до школы.',
    ),
    _NeedWantItem(
      '🍭',
      'Леденец',
      ExpenseKind.want,
      'Сладость приятная, но не обязательная.',
    ),
    _NeedWantItem(
      '💊',
      'Лекарство',
      ExpenseKind.need,
      'Здоровье важнее игрушек.',
    ),
    _NeedWantItem(
      '🧸',
      'Игрушка',
      ExpenseKind.want,
      'Игрушка радует, но без неё можно.',
    ),
    _NeedWantItem(
      '📚',
      'Учебник',
      ExpenseKind.need,
      'Учебник нужен для учёбы.',
    ),
    _NeedWantItem(
      '🎈',
      'Шарик',
      ExpenseKind.want,
      'Шарик — это праздник, не необходимость.',
    ),
    _NeedWantItem(
      '🧦',
      'Тёплые носки',
      ExpenseKind.need,
      'Одежда защищает от холода.',
    ),
    _NeedWantItem(
      '🍦',
      'Лишнее мороженое',
      ExpenseKind.want,
      'Лишнее мороженое — это хотелка.',
    ),
    _NeedWantItem(
      '🪥',
      'Зубная щётка',
      ExpenseKind.need,
      'Гигиена нужна каждый день.',
    ),
    _NeedWantItem(
      '💎',
      'Блестящая наклейка',
      ExpenseKind.want,
      'Наклейка красивая, но без неё можно.',
    ),
    _NeedWantItem(
      '🥣',
      'Корм для питомца',
      ExpenseKind.need,
      'Питомец должен есть.',
    ),
    _NeedWantItem(
      '🎀',
      'Бантик',
      ExpenseKind.want,
      'Бантик украшает, но не кормит.',
    ),
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
    if (!ok) {
      if (mounted) {
        await showOkHint(
          context,
          title: 'Ой, не так',
          body: _items[_idx].explain(kind),
        );
      }
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
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
      return GameResultBody(
        title: 'Надо или хочу?',
        scoreLine: 'Правильно: $_score из ${_items.length}',
        coinsLine: '+${_score * 6} монет',
        onAgain: () => setState(() {
          _items = [..._pool]..shuffle();
          _items = _items.take(8).toList();
          _idx = 0;
          _score = 0;
          _done = false;
          _paid = false;
          _correct = null;
        }),
        onDone: () => Navigator.pop(context),
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
            child: Draggable<_NeedWantItem>(
              key: ValueKey(_idx),
              data: current,
              feedback: Material(
                color: Colors.transparent,
                child: Text(current.emoji, style: const TextStyle(fontSize: 72)),
              ),
              childWhenDragging: Opacity(
                opacity: 0.35,
                child: _itemCard(current, _correct),
              ),
              child: _itemCard(current, _correct),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Нажми или перетащи карточку в «надо» или «хочу»'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DragTarget<_NeedWantItem>(
                  onAcceptWithDetails: (_) => _answer(ExpenseKind.need),
                  builder: (context, cand, rej) {
                    final hot = cand.isNotEmpty;
                    return _KindBin(
                      label: 'Надо',
                      icon: FinniIcons.need,
                      color: const Color(0xFF5FCBB0),
                      hot: hot,
                      onTap: () => _answer(ExpenseKind.need),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DragTarget<_NeedWantItem>(
                  onAcceptWithDetails: (_) => _answer(ExpenseKind.want),
                  builder: (context, cand, rej) {
                    final hot = cand.isNotEmpty;
                    return _KindBin(
                      label: 'Хочу',
                      icon: FinniIcons.want,
                      color: const Color(0xFFF27BA0),
                      hot: hot,
                      onTap: () => _answer(ExpenseKind.want),
                    );
                  },
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _itemCard(_NeedWantItem current, bool? correct) {
    return Container(
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
          if (correct != null)
            DecoratedBox(
              decoration: BoxDecoration(
                color: (correct ? AppTheme.mint : AppTheme.peach)
                    .withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(
                child: Icon(
                  correct ? FinniIcons.check : FinniIcons.close,
                  size: 72,
                  color: correct ? const Color(0xFF2F7A5D) : Colors.red[800],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _KindBin extends StatelessWidget {
  const _KindBin({
    required this.label,
    required this.icon,
    required this.color,
    required this.hot,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool hot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      child: Material(
        color: color.withValues(alpha: hot ? 0.28 : 0.14),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                CircleGlyph(icon: icon, color: color, size: 56, iconSize: 28),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
