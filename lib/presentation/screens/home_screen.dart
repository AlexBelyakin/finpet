import 'package:flutter/material.dart';

import 'package:finpet/app/layout.dart';
import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/domain/content/catalog.dart';
import 'package:finpet/domain/economy/engine.dart';
import 'package:finpet/domain/models.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import 'package:finpet/presentation/widgets/icons.dart';
import '../widgets/common.dart';
import '../widgets/finni_pet.dart';
import '../widgets/shell.dart';
import 'adult_screen.dart';
import 'budget_screen.dart';
import 'games_hub_screen.dart';
import 'glossary_screen.dart';
import 'progress_screen.dart';
import 'savings_screen.dart';
import 'shop_screen.dart';
import 'tasks_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _bubble;
  int _line = 0;

  void _open(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  void _onPetTap(Pet pet) {
    final lines = <String>[
      if (pet.satiety < 40) 'Кажется, пора подумать про корм.',
      if (pet.mood < 40) 'Мне грустновато. Может, поиграем после нужных дел?',
      if (pet.mood >= 70) 'Мне хорошо! Спасибо, что заботишься.',
      'Давай сверим план: нужное, желаемое, копилка.',
      'Копилка тоже важна — цель ближе по чуть-чуть.',
    ];
    setState(() {
      _line = (_line + 1) % lines.length;
      _bubble = lines[_line];
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final p = widget.controller.profile;
        final pet = p.pet!;
        final wide = AppLayout.isWide(context);
        final petSize = AppLayout.petSize(context);
        final petBlock = Column(
          children: [
            if (_bubble != null) SpeechBubble(text: _bubble!),
            FinniPetView(
              pet: pet,
              size: petSize,
              onTap: () => _onPetTap(pet),
            ),
            Text(
              'Нажми на питомца — он откликнется',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.ink.withValues(alpha: 0.6),
              ),
            ),
          ],
        );
        final panel = _HomePanel(
          controller: widget.controller,
          onOpen: _open,
        );
        return Scaffold(
          body: RoomBackground(
            child: SafeArea(
              child: wide
                  ? Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: _headerAndPet(context, p, petBlock),
                        ),
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 12, 12),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppTheme.card.withValues(alpha: 0.96),
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: panel,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(child: _headerAndPet(context, p, petBlock)),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.sizeOf(context).height * 0.46,
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppTheme.card.withValues(alpha: 0.96),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(28),
                              ),
                            ),
                            child: panel,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _headerAndPet(BuildContext context, GameProfile p, Widget petBlock) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  p.playerName.isEmpty
                      ? 'Неделя ${p.periodIndex}'
                      : 'Привет, ${p.playerName}!',
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
                icon: const Icon(FinniIcons.help),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: CoinChip(label: 'Монеты', value: p.coins),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CoinChip(
                  label: 'Копилка',
                  value: p.savings,
                  icon: FinniIcons.savings,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Align(
            alignment: const Alignment(0, 0.35),
            child: SingleChildScrollView(child: petBlock),
          ),
        ),
      ],
    );
  }
}

class _HomePanel extends StatelessWidget {
  const _HomePanel({required this.controller, required this.onOpen});

  final GameController controller;
  final void Function(Widget page) onOpen;

  @override
  Widget build(BuildContext context) {
    final p = controller.profile;
    final pet = p.pet!;
    final goal = Catalog.goalById(p.goalId);
    final openTask = Catalog.tasks
        .where((task) => !p.doneTaskIds.contains(task.id))
        .firstOrNull;
    final cols = AppLayout.columns(context, phone: 3, tablet: 3);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text(
          'Неделя ${p.periodIndex} · ${_phaseLabel(p.phase)}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        StatBar(
          label: 'Сытость',
          value: pet.satiety,
          color: AppTheme.peach,
          icon: Icons.restaurant_rounded,
        ),
        const SizedBox(height: 10),
        StatBar(
          label: 'Настроение',
          value: pet.mood,
          color: AppTheme.mint,
          icon: Icons.favorite_rounded,
        ),
        const SizedBox(height: 8),
        Text(pet.moodReason),
        const SizedBox(height: 10),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal == null ? 'Цель не выбрана' : '${goal.emoji} ${goal.title}',
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
        Text(
          openTask == null
              ? 'Все задания пройдены. Новые уже в списке на следующей неделе контента.'
              : 'Задание: ${openTask.title}',
        ),
        const SizedBox(height: 10),
        FeedbackBanner(message: p.lastMessage, nextStep: p.lastNextStep),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: AppLayout.isTablet(context) ? 1.25 : 1.05,
          children: [
            AppNavTile(
              icon: FinniIcons.games,
              label: 'Игры',
              color: AppTheme.peach,
              onTap: () => onOpen(GamesHubScreen(controller: controller)),
            ),
            AppNavTile(
              icon: FinniIcons.plan,
              label: 'План',
              color: AppTheme.mint,
              onTap: () => onOpen(BudgetScreen(controller: controller)),
            ),
            AppNavTile(
              icon: FinniIcons.tasks,
              label: 'Задания',
              color: AppTheme.sky,
              onTap: () => onOpen(TasksScreen(controller: controller)),
            ),
            AppNavTile(
              icon: FinniIcons.shop,
              label: 'Покупки',
              color: AppTheme.peach,
              onTap: () => onOpen(ShopScreen(controller: controller)),
            ),
            AppNavTile(
              icon: FinniIcons.savings,
              label: 'Копилка',
              color: AppTheme.peach,
              onTap: () => onOpen(SavingsScreen(controller: controller)),
            ),
            AppNavTile(
              icon: FinniIcons.progress,
              label: 'Прогресс',
              color: AppTheme.sky,
              onTap: () => onOpen(ProgressScreen(controller: controller)),
            ),
            AppNavTile(
              icon: FinniIcons.adult,
              label: 'Взрослым',
              color: AppTheme.wave,
              onTap: () => onOpen(AdultScreen(controller: controller)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (p.phase == PeriodPhase.active && p.demoMode)
          FilledButton.icon(
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
            icon: const Icon(Icons.skip_next_rounded),
            label: const Text('Следующая неделя'),
          ),
      ],
    );
  }

  String _phaseLabel(PeriodPhase phase) => switch (phase) {
        PeriodPhase.planning => 'составляем план',
        PeriodPhase.active => 'неделя идёт',
        PeriodPhase.review => 'смотрим итог',
      };
}
