import 'package:flutter/material.dart';

import 'package:finpet/app/layout.dart';
import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/data/audio/music_service.dart';
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
  void _open(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final p = widget.controller.profile;
        final pet = p.pet!;
        final petSize = AppLayout.petSize(context);
        return Scaffold(
          backgroundColor: AppTheme.cream,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _headerAndPet(
                    context,
                    p,
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SpeechBubble(
                          text: pet.moodReason.isEmpty
                              ? 'Привет! Я ${pet.name}'
                              : pet.moodReason,
                        ),
                        FinniPetView(
                          pet: pet,
                          size: petSize,
                        ),
                      ],
                    ),
                  ),
                ),
                _HomeStatus(
                  controller: widget.controller,
                ),
                _HomeDock(
                  controller: widget.controller,
                  onOpen: _open,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _headerAndPet(BuildContext context, GameProfile p, Widget petBlock) {
    return ClipRRect(
      child: RoomBackground(
        child: Column(
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            shadows: const [
                              Shadow(color: Colors.white, blurRadius: 12),
                            ],
                          ),
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
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: AppLayout.petFloorPad(context),
                    left: 8,
                    right: 8,
                  ),
                  child: petBlock,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeStatus extends StatelessWidget {
  const _HomeStatus({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final p = controller.profile;
    final pet = p.pet!;
    final goal = Catalog.goalById(p.goalId);
    final openTask = Catalog.tasks
        .where((task) => !p.doneTaskIds.contains(task.id))
        .firstOrNull;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Неделя ${p.periodIndex} · ${_phaseLabel(p.phase)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            StatBar(
              label: 'Сытость',
              value: pet.satiety,
              color: AppTheme.peach,
              icon: Icons.restaurant_rounded,
            ),
            const SizedBox(height: 8),
            StatBar(
              label: 'Настроение',
              value: pet.mood,
              color: AppTheme.mint,
              icon: Icons.favorite_rounded,
            ),
            const SizedBox(height: 8),
            Text(
              goal == null
                  ? 'Цель не выбрана. Открой копилку.'
                  : '${goal.emoji} ${goal.title}: ${p.savings} из ${goal.cost}. ${Economy.goalEta(p)}',
            ),
            const SizedBox(height: 4),
            Text(
              openTask == null
                  ? 'Все задания пройдены.'
                  : 'Задание: ${openTask.title}',
            ),
            const SizedBox(height: 8),
            FeedbackBanner(message: p.lastMessage, nextStep: p.lastNextStep),
            if (p.phase == PeriodPhase.active && p.demoMode) ...[
              const SizedBox(height: 8),
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
          ],
        ),
      ),
    );
  }

  String _phaseLabel(PeriodPhase phase) => switch (phase) {
        PeriodPhase.planning => 'составляем план',
        PeriodPhase.active => 'неделя идёт',
        PeriodPhase.review => 'смотрим итог',
      };
}

class _HomeDock extends StatelessWidget {
  const _HomeDock({required this.controller, required this.onOpen});

  final GameController controller;
  final void Function(Widget page) onOpen;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.card.withValues(alpha: 0.98),
      elevation: 8,
      shadowColor: AppTheme.ink.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListenableBuilder(
              listenable: MusicService.instance,
              builder: (context, _) {
                final music = MusicService.instance;
                final muted = music.muted;
                final percent = (music.volume * 100).round();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      tooltip: 'Тише',
                      onPressed: () =>
                          music.nudgeVolume(-MusicService.volumeStep),
                      icon: const Icon(Icons.volume_down_rounded),
                    ),
                    IconButton(
                      tooltip: muted ? 'Включить музыку' : 'Выключить музыку',
                      onPressed: music.toggleMuted,
                      icon: Icon(
                        muted
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Громче',
                      onPressed: () =>
                          music.nudgeVolume(MusicService.volumeStep),
                      icon: const Icon(Icons.volume_up_rounded),
                    ),
                    Text(
                      muted ? 'тихо' : '$percent%',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                );
              },
            ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: [
                _DockIcon(
                  icon: FinniIcons.games,
                  label: 'Игры',
                  color: AppTheme.peach,
                  onTap: () => onOpen(GamesHubScreen(controller: controller)),
                ),
                _DockIcon(
                  icon: FinniIcons.plan,
                  label: 'План',
                  color: AppTheme.mint,
                  onTap: () => onOpen(BudgetScreen(controller: controller)),
                ),
                _DockIcon(
                  icon: FinniIcons.tasks,
                  label: 'Задания',
                  color: AppTheme.sky,
                  onTap: () => onOpen(TasksScreen(controller: controller)),
                ),
                _DockIcon(
                  icon: FinniIcons.shop,
                  label: 'Покупки',
                  color: AppTheme.peach,
                  onTap: () => onOpen(ShopScreen(controller: controller)),
                ),
                _DockIcon(
                  icon: FinniIcons.savings,
                  label: 'Копилка',
                  color: AppTheme.gold,
                  onTap: () => onOpen(SavingsScreen(controller: controller)),
                ),
                _DockIcon(
                  icon: FinniIcons.progress,
                  label: 'Прогресс',
                  color: AppTheme.sky,
                  onTap: () => onOpen(ProgressScreen(controller: controller)),
                ),
                _DockIcon(
                  icon: FinniIcons.adult,
                  label: 'Взрослым',
                  color: AppTheme.wave,
                  onTap: () => onOpen(AdultScreen(controller: controller)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DockIcon extends StatelessWidget {
  const _DockIcon({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 56,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
