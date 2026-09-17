import 'package:flutter/material.dart';

import 'package:finpet/domain/models.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import '../widgets/common.dart';
import '../widgets/shell.dart';

class TaskPlayScreen extends StatefulWidget {
  const TaskPlayScreen({
    super.key,
    required this.controller,
    required this.task,
  });

  final GameController controller;
  final TaskDef task;

  @override
  State<TaskPlayScreen> createState() => _TaskPlayScreenState();
}

class _TaskPlayScreenState extends State<TaskPlayScreen> {
  String? optionId;
  int need = 0;
  int want = 0;
  int save = 0;

  @override
  void initState() {
    super.initState();
    final total = widget.task.allocateTotal ?? 0;
    if (total > 0) {
      need = (total * 0.4).round();
      save = (total * 0.3).round();
      want = total - need - save;
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    return FinniScaffold(
      title: task.themeLabel,
      body: ListView(
        children: [
          Text(task.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(task.story),
          const SizedBox(height: 16),
          if (task.type == TaskType.choice)
            ...task.options.map(
              (option) => ListTile(
                selected: optionId == option.id,
                title: Text(option.label),
                leading: Icon(
                  optionId == option.id
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                ),
                onTap: () => setState(() => optionId = option.id),
              ),
            )
          else ...[
            Text('Нужное: $need'),
            Slider(
              value: need.toDouble(),
              max: task.allocateTotal!.toDouble(),
              onChanged: (v) {
                setState(() {
                  need = v.round();
                  _balance(task.allocateTotal!);
                });
              },
            ),
            Text('Желаемое: $want'),
            Slider(
              value: want.toDouble(),
              max: task.allocateTotal!.toDouble(),
              onChanged: (v) {
                setState(() {
                  want = v.round();
                  _balance(task.allocateTotal!, preferWant: true);
                });
              },
            ),
            Text('Копилка: $save'),
            Slider(
              value: save.toDouble(),
              max: task.allocateTotal!.toDouble(),
              onChanged: (v) {
                setState(() {
                  save = v.round();
                  _balance(task.allocateTotal!, preferSave: true);
                });
              },
            ),
            Text('Сумма: ${need + want + save} из ${task.allocateTotal}'),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              final answer = task.type == TaskType.choice
                  ? TaskAnswer(optionId: optionId)
                  : TaskAnswer(need: need, want: want, save: save);
              if (task.type == TaskType.choice && optionId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Выбери вариант.')),
                );
                return;
              }
              final result = await widget.controller.completeTask(task.id, answer);
              if (!context.mounted) return;
              showResult(
                context,
                message: result.message,
                next: result.nextStep,
              );
              if (result.ok) Navigator.of(context).pop();
            },
            child: const Text('Готово'),
          ),
        ],
      ),
    );
  }

  void _balance(int total, {bool preferWant = false, bool preferSave = false}) {
    var rest = total - need;
    if (preferWant) {
      save = (rest - want).clamp(0, rest);
      want = rest - save;
    } else if (preferSave) {
      want = (rest - save).clamp(0, rest);
      save = rest - want;
    } else {
      want = (rest * 0.5).round().clamp(0, rest);
      save = rest - want;
    }
  }
}
