import 'package:flutter/material.dart';

import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/domain/content/catalog.dart';
import 'package:finpet/domain/economy/engine.dart';
import 'package:finpet/domain/models.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import '../widgets/common.dart';
import '../widgets/finni_pet.dart';
import '../widgets/shell.dart';
import 'adult_screen.dart';
import 'budget_screen.dart';
import 'glossary_screen.dart';
import 'progress_screen.dart';
import 'savings_screen.dart';
import 'shop_screen.dart';
import 'tasks_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final p = controller.profile;
    final pet = p.pet!;
    final goal = Catalog.goalById(p.goalId);
    final openTask = Catalog.tasks
        .where((task) => !p.doneTaskIds.contains(task.id))
        .firstOrNull;
    return Scaffold(
      body: RoomBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Неделя ${p.periodIndex}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Подсказка',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const GlossaryScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.help_outline),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(child: CoinChip(label: 'В кармане', value: p.coins)),
                  const SizedBox(width: 8),
                  Expanded(child: CoinChip(label: 'Копилка', value: p.savings)),
                ],
              ),
              const SizedBox(height: 12),
              FinniPetView(pet: pet),
              const SizedBox(height: 8),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatBar(
                      label: 'Сытость',
                      value: pet.satiety,
                      color: AppTheme.peach,
                    ),
                    const SizedBox(height: 10),
                    StatBar(
                      label: 'Настроение',
                      value: pet.mood,
                      color: AppTheme.mint,
                    ),
                    const SizedBox(height: 8),
                    Text(pet.moodReason),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal == null
                          ? 'Цель не выбрана'
                          : '${goal.emoji} ${goal.title}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    if (goal != null)
                      LinearProgressIndicator(
                        minHeight: 10,
                        value: (p.savings / goal.cost).clamp(0, 1),
                        color: AppTheme.sky,
                        backgroundColor: AppTheme.sky.withValues(alpha: 0.2),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      goal == null
                          ? 'Выбери цель в копилке.'
                          : 'Накоплено ${p.savings} из ${goal.cost}. ${Economy.goalEta(p)}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SurfaceCard(
                child: Text(
                  openTask == null
                      ? 'Все задания пройдены. Можно открыть новые в следующей версии контента.'
                      : 'Задание: ${openTask.title}',
                ),
              ),
              const SizedBox(height: 10),
              FeedbackBanner(message: p.lastMessage, nextStep: p.lastNextStep),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _NavChip(
                    label: 'План',
                    onTap: () => _open(context, BudgetScreen(controller: controller)),
                  ),
                  _NavChip(
                    label: 'Задания',
                    onTap: () => _open(context, TasksScreen(controller: controller)),
                  ),
                  _NavChip(
                    label: 'Покупки',
                    onTap: () => _open(context, ShopScreen(controller: controller)),
                  ),
                  _NavChip(
                    label: 'Копилка',
                    onTap: () => _open(context, SavingsScreen(controller: controller)),
                  ),
                  _NavChip(
                    label: 'Прогресс',
                    onTap: () => _open(context, ProgressScreen(controller: controller)),
                  ),
                  _NavChip(
                    label: 'Взрослым',
                    onTap: () => _open(context, AdultScreen(controller: controller)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (p.phase == PeriodPhase.active && p.demoMode)
                FilledButton(
                  onPressed: () async {
                    final ok = await confirmAction(
                      context,
                      title: 'Закрыть неделю?',
                      body:
                          'Сравним план и факт. Питомец изменится по серии решений. Это демо: ждать настоящие дни не нужно.',
                    );
                    if (!ok || !context.mounted) return;
                    final result = await controller.closePeriod();
                    if (!context.mounted) return;
                    showResult(
                      context,
                      message: result.message,
                      next: result.nextStep,
                    );
                  },
                  child: const Text('Следующая неделя'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}

class _NavChip extends StatelessWidget {
  const _NavChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
    );
  }
}
