import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/domain/content/catalog.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import 'package:finpet/presentation/widgets/common.dart';
import 'package:finpet/presentation/widgets/icons.dart';
import '../widgets/shell.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final p = controller.profile;
    final goal = Catalog.goalById(p.goalId);
    final goalValue = goal == null || goal.cost == 0
        ? 0.0
        : (p.savings / goal.cost).clamp(0.0, 1.0);
    final percent = (goalValue * 100).round();
    return FinniScaffold(
      title: 'Прогресс',
      body: ListView(
        children: [
          SurfaceCard(
            child: Column(
              children: [
                ProgressRing(
                  value: goalValue,
                  color: AppTheme.mint,
                  size: 188,
                  stroke: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        goal == null ? 'нет цели' : 'к цели',
                        style: TextStyle(
                          color: AppTheme.ink.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  goal == null
                      ? 'Выбери цель в копилке — круг заполнится.'
                      : '${goal.emoji} ${goal.title}\n${p.savings} из ${goal.cost} монет',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 350.ms).scale(
                begin: const Offset(0.94, 0.94),
                duration: 400.ms,
              ),
          const SizedBox(height: 16),
          const Text('Пройденные задания', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (p.doneTaskIds.isEmpty)
            const Text('Пока нет. Загляни в задания — круг цели тоже подрастёт.')
          else
            ...Catalog.tasks.where((t) => p.doneTaskIds.contains(t.id)).map(
                  (t) => SurfaceCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.mint.withValues(alpha: 0.22),
                        child: Icon(FinniIcons.forTask(t.theme), color: AppTheme.ink),
                      ),
                      title: Text(t.title),
                      subtitle: Text(t.themeLabel),
                    ),
                  ).animate().fadeIn(duration: 280.ms).slideX(begin: 0.04),
                ),
          const SizedBox(height: 16),
          const Text('Последняя неделя', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (p.history.isEmpty)
            const Text('Неделя ещё не закрыта. В демо на главной есть кнопка «Неделя».')
          else
            SurfaceCard(
              child: Builder(
                builder: (context) {
                  final last = p.history.last;
                  return Text(
                    'Неделя ${last.index}\n'
                    'План: нужное ${last.plan.need}, желаемое ${last.plan.want}, копилка ${last.plan.save}\n'
                    'Факт: нужное ${last.fact.need}, желаемое ${last.fact.want}, копилка ${last.fact.save}\n'
                    '${last.note}',
                  );
                },
              ),
            ).animate().fadeIn(duration: 320.ms),
          const SizedBox(height: 16),
          const Text('История монет', style: TextStyle(fontWeight: FontWeight.w700)),
          ...p.ledger.take(12).map(
                (e) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    e.isEarn ? Icons.add_circle_rounded : Icons.remove_circle_rounded,
                    color: e.isEarn ? AppTheme.mint : AppTheme.peach,
                    size: 32,
                  ),
                  title: Text(e.title),
                  subtitle: Text(e.source),
                  trailing: Text(
                    '${e.isEarn ? '+' : '-'}${e.amount}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ).animate().fadeIn(duration: 220.ms),
              ),
        ],
      ),
    );
  }
}
