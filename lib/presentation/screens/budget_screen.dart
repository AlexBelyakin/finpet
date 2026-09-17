import 'package:flutter/material.dart';

import 'package:finpet/domain/models.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import '../widgets/common.dart';
import '../widgets/shell.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late int need;
  late int want;
  late int save;

  @override
  void initState() {
    super.initState();
    final plan = widget.controller.profile.plan;
    final coins = widget.controller.profile.coins;
    need = plan?.need ?? (coins * 0.4).round();
    want = plan?.want ?? (coins * 0.3).round();
    save = plan?.save ?? (coins * 0.2).round();
    _fit(coins);
  }

  void _fit(int coins) {
    var total = need + want + save;
    if (total <= coins) return;
    save = (save - (total - coins)).clamp(0, coins);
    total = need + want + save;
    if (total > coins) {
      want = (want - (total - coins)).clamp(0, coins);
    }
    total = need + want + save;
    if (total > coins) {
      need = coins;
      want = 0;
      save = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.controller.profile;
    final locked = p.phase != PeriodPhase.planning;
    final leftover = p.coins - (need + want + save);
    return FinniScaffold(
      title: 'План на неделю',
      body: ListView(
        children: [
          Text('Доступно: ${p.coins} монет. План не может быть больше этой суммы.'),
          const SizedBox(height: 12),
          if (locked && p.plan != null)
            SurfaceCard(
              child: Text(
                'План уже подтверждён.\nНужное ${p.plan!.need} · желаемое ${p.plan!.want} · копилка ${p.plan!.save}\n'
                'Факт сейчас: нужное ${p.spentNeed}, желаемое ${p.spentWant}, копилка ${p.savedThisPeriod}.',
              ),
            )
          else ...[
            _slider('Нужное (еда и уход)', need, p.coins, (v) {
              setState(() => need = v);
            }),
            _slider('Желаемое (игрушки и вкусности)', want, p.coins, (v) {
              setState(() => want = v);
            }),
            _slider('Копилка', save, p.coins, (v) {
              setState(() => save = v);
            }),
            Text(
              leftover < 0
                  ? 'Слишком много: ${-leftover} лишних.'
                  : 'Не распределено: $leftover. Это нормально — можно оставить запас.',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: leftover < 0 ? Colors.red[800] : null,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: leftover < 0
                  ? null
                  : () async {
                      final result = await widget.controller.confirmPlan(
                        BudgetSplit(need: need, want: want, save: save),
                      );
                      if (!context.mounted) return;
                      showResult(
                        context,
                        message: result.message,
                        next: result.nextStep,
                      );
                      if (result.ok) setState(() {});
                    },
              child: const Text('Подтвердить план'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _slider(
    String label,
    int value,
    int max,
    ValueChanged<int> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: $value'),
        Slider(
          value: value.toDouble().clamp(0, max.toDouble()),
          max: max.toDouble().clamp(1, double.infinity),
          divisions: max == 0 ? 1 : max,
          onChanged: (v) => onChanged(v.round()),
        ),
      ],
    );
  }
}
