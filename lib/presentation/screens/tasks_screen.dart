import 'package:flutter/material.dart';

import 'package:finpet/domain/content/catalog.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import '../widgets/shell.dart';
import 'task_play_screen.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return FinniScaffold(
          title: 'Задания',
          body: ListView(
            children: [
              const Text(
                'Три темы: план, копилка, покупки. Это ситуации, не просто тест.',
              ),
              const SizedBox(height: 12),
              ...Catalog.tasks.map((task) {
                final done = controller.profile.doneTaskIds.contains(task.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SurfaceCard(
                    onTap: done
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => TaskPlayScreen(
                                  controller: controller,
                                  task: task,
                                ),
                              ),
                            );
                          },
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              Text('${task.themeLabel} · награда ${task.reward}'),
                              if (done) const Text('Пройдено'),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
