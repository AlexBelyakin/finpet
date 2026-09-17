import 'package:flutter/material.dart';

import 'package:finpet/domain/content/catalog.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import '../widgets/shell.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final p = controller.profile;
    final goal = Catalog.goalById(p.goalId);
    return FinniScaffold(
      title: 'Прогресс',
      body: ListView(
        children: [
          SurfaceCard(
            child: Text(
              goal == null
                  ? 'Цель не выбрана.'
                  : 'Цель «${goal.title}»: ${p.savings} из ${goal.cost}.',
            ),
          ),
          const SizedBox(height: 12),
          const Text('Пройденные задания', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (p.doneTaskIds.isEmpty) const Text('Пока нет.'),
          ...Catalog.tasks.where((t) => p.doneTaskIds.contains(t.id)).map(
                (t) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.title),
                  subtitle: Text(t.themeLabel),
                ),
              ),
          const SizedBox(height: 12),
          const Text('Последняя неделя', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (p.history.isEmpty)
            const Text('Неделя ещё не закрыта. В демо на главной есть кнопка «Следующая неделя».')
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
            ),
          const SizedBox(height: 12),
          const Text('История монет', style: TextStyle(fontWeight: FontWeight.w700)),
          ...p.ledger.take(12).map(
                (e) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(e.title),
                  subtitle: Text(e.source),
                  trailing: Text('${e.isEarn ? '+' : '-'}${e.amount}'),
                ),
              ),
        ],
      ),
    );
  }
}
