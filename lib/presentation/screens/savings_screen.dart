import 'package:flutter/material.dart';

import 'package:finpet/domain/content/catalog.dart';
import 'package:finpet/domain/economy/engine.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import '../widgets/common.dart';
import '../widgets/shell.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  int amount = 10;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final p = widget.controller.profile;
        final goal = Catalog.goalById(p.goalId);
        final maxPut = p.coins;
        return FinniScaffold(
          title: 'Копилка',
          body: ListView(
            children: [
              Text(Economy.goalEta(p)),
              const SizedBox(height: 12),
              ...Catalog.goals.map((item) {
                final selected = item.id == p.goalId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SurfaceCard(
                    onTap: () => widget.controller.setGoal(item.id),
                    child: Row(
                      children: [
                        Text(item.emoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${item.title} · ${item.cost} монет',
                            style: TextStyle(
                              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (selected) const Icon(Icons.check),
                      ],
                    ),
                  ),
                );
              }),
              if (goal != null) ...[
                Text('Накоплено ${p.savings} из ${goal.cost}'),
                const SizedBox(height: 8),
                Text('Отложить: $amount'),
                Slider(
                  value: amount.clamp(0, maxPut == 0 ? 1 : maxPut).toDouble(),
                  max: (maxPut == 0 ? 1 : maxPut).toDouble(),
                  divisions: maxPut == 0 ? 1 : maxPut,
                  onChanged: maxPut == 0
                      ? null
                      : (v) => setState(() => amount = v.round()),
                ),
                FilledButton(
                  onPressed: maxPut == 0
                      ? null
                      : () async {
                          final result =
                              await widget.controller.saveAmount(amount);
                          if (!context.mounted) return;
                          showResult(
                            context,
                            message: result.message,
                            next: result.nextStep,
                          );
                        },
                  child: const Text('Положить в копилку'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: p.savings == 0
                      ? null
                      : () async {
                          final take = amount.clamp(1, p.savings);
                          final left = p.savings - take;
                          final remain = goal.cost - left;
                          final ok = await confirmAction(
                            context,
                            title: 'Снять с копилки?',
                            body:
                                'Снимется $take. Накопления станут $left. До цели останется ${remain < 0 ? 0 : remain}. Срок станет длиннее. Это откат цели, не «бесплатные» деньги.',
                          );
                          if (!ok || !context.mounted) return;
                          final result =
                              await widget.controller.withdrawAmount(take);
                          if (!context.mounted) return;
                          showResult(
                            context,
                            message: result.message,
                            next: result.nextStep,
                          );
                        },
                  child: const Text('Снять с копилки'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
