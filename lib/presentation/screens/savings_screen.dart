import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:finpet/app/theme/app_theme.dart';
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
        final goalValue = goal == null || goal.cost == 0
            ? 0.0
            : (p.savings / goal.cost).clamp(0.0, 1.0);
        final percent = (goalValue * 100).round();
        return FinniScaffold(
          title: 'Копилка',
          body: ListView(
            children: [
              SurfaceCard(
                child: Column(
                  children: [
                    ProgressRing(
                      value: goalValue,
                      color: AppTheme.gold,
                      size: 148,
                      stroke: 14,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            goal?.emoji ?? '🐷',
                            style: const TextStyle(fontSize: 28),
                          ),
                          Text(
                            '$percent%',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Economy.goalEta(p),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 320.ms).scale(
                    begin: const Offset(0.94, 0.94),
                    duration: 380.ms,
                  ),
              const SizedBox(height: 12),
              const Text(
                'Выбери цель — копилка работает на неё.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ...Catalog.goals.asMap().entries.map((entry) {
                final item = entry.value;
                final selected = item.id == p.goalId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SurfaceCard(
                    onTap: () => widget.controller.setGoal(item.id),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected
                                ? AppTheme.gold.withValues(alpha: 0.35)
                                : AppTheme.sky.withValues(alpha: 0.18),
                          ),
                          child: Text(item.emoji, style: const TextStyle(fontSize: 26)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${item.title} · ${item.cost} монет',
                            style: TextStyle(
                              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (selected)
                          const Icon(Icons.check_circle, color: AppTheme.gold, size: 28),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 260.ms, delay: (40 * entry.key).ms)
                    .slideX(begin: 0.04);
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
