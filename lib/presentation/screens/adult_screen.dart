import 'package:flutter/material.dart';

import 'package:finpet/domain/content/catalog.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import '../widgets/common.dart';
import '../widgets/shell.dart';

class AdultScreen extends StatefulWidget {
  const AdultScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<AdultScreen> createState() => _AdultScreenState();
}

class _AdultScreenState extends State<AdultScreen> {
  bool unlocked = false;
  final _answer = TextEditingController();

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!unlocked) {
      return FinniScaffold(
        title: 'Раздел для взрослого',
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Чтобы войти, реши пример. Так ребёнок не сбросит прогресс случайно.'),
            const SizedBox(height: 16),
            const Text('Сколько будет 8 + 5?'),
            const SizedBox(height: 8),
            TextField(
              controller: _answer,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Ответ',
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                if (_answer.text.trim() == '13') {
                  setState(() => unlocked = true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Пока неверно.')),
                  );
                }
              },
              child: const Text('Войти'),
            ),
          ],
        ),
      );
    }

    final p = widget.controller.profile;
    final themes = {
      for (final task in Catalog.tasks)
        if (p.doneTaskIds.contains(task.id)) task.themeLabel,
    };
    return FinniScaffold(
      title: 'Для взрослого',
      body: ListView(
        children: [
          const Text(
            'Цель приложения: ребёнок учится делить деньги на нужное, желаемое и копилку. Оценки «плохо» здесь нет.',
          ),
          const SizedBox(height: 12),
          SurfaceCard(
            child: Text(
              'Недель закрыто: ${p.history.length}\n'
              'Стадия питомца: ${p.pet?.stageLabel ?? '—'}\n'
              'Темы заданий: ${themes.isEmpty ? 'пока нет' : themes.join(', ')}',
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Демо-режим'),
            subtitle: const Text('Недели идут подряд, без ожидания дней.'),
            value: p.demoMode,
            onChanged: widget.controller.setDemoMode,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () async {
              final ok = await confirmAction(
                context,
                title: 'Сбросить профиль?',
                body: 'Прогресс, монеты и питомец удалятся. Это для проверки сценария.',
              );
              if (!ok || !context.mounted) return;
              await widget.controller.resetProfile();
              if (!context.mounted) return;
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Сбросить тестовый профиль'),
          ),
        ],
      ),
    );
  }
}
