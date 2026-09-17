import 'package:flutter/material.dart';

import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/domain/content/catalog.dart';
import 'package:finpet/domain/models.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import 'package:finpet/presentation/widgets/icons.dart';
import '../widgets/shell.dart';
import 'task_play_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  TaskTheme? _filter;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final tasks = Catalog.tasks.where((task) {
          return _filter == null || task.theme == _filter;
        });
        return FinniScaffold(
          title: 'Задания',
          body: ListView(
            children: [
              const Text(
                'Три темы: план, копилка, покупки. Это ситуации, не просто тест.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Все'),
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                  for (final theme in TaskTheme.values)
                    FilterChip(
                      avatar: Icon(FinniIcons.forTask(theme), size: 18),
                      label: Text(_label(theme)),
                      selected: _filter == theme,
                      onSelected: (_) => setState(() => _filter = theme),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ...tasks.map((task) {
                final done =
                    widget.controller.profile.doneTaskIds.contains(task.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SurfaceCard(
                    onTap: done
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => TaskPlayScreen(
                                  controller: widget.controller,
                                  task: task,
                                ),
                              ),
                            );
                          },
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.sky.withValues(alpha: 0.25),
                          child: Icon(
                            FinniIcons.forTask(task.theme),
                            color: AppTheme.ink,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text('${task.themeLabel} · награда ${task.reward}'),
                              if (done) const Text('Пройдено'),
                            ],
                          ),
                        ),
                        Icon(done ? Icons.check_circle : Icons.chevron_right),
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

  String _label(TaskTheme theme) => switch (theme) {
        TaskTheme.budget => 'План',
        TaskTheme.savings => 'Копилка',
        TaskTheme.purchases => 'Покупки',
      };
}
