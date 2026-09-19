import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
        }).toList();
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
              ...tasks.asMap().entries.map((entry) {
                final task = entry.value;
                final done =
                    widget.controller.profile.doneTaskIds.contains(task.id);
                final color = switch (task.theme) {
                  TaskTheme.budget => AppTheme.mint,
                  TaskTheme.savings => AppTheme.gold,
                  TaskTheme.purchases => AppTheme.peach,
                };
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
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [color, color.withValues(alpha: 0.7)],
                            ),
                          ),
                          child: Icon(
                            FinniIcons.forTask(task.theme),
                            color: Colors.white,
                            size: 28,
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
                        Icon(
                          done ? Icons.check_circle : Icons.chevron_right,
                          color: done ? AppTheme.mint : AppTheme.ink.withValues(alpha: 0.45),
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 280.ms, delay: (40 * entry.key).ms)
                    .slideX(begin: 0.05);
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
