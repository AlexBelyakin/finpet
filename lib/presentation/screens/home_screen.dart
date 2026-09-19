import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:finpet/app/layout.dart';
import 'package:finpet/app/pet_clips.dart';
import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/data/audio/music_service.dart';
import 'package:finpet/domain/content/catalog.dart';
import 'package:finpet/domain/economy/engine.dart';
import 'package:finpet/domain/models.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import 'package:finpet/presentation/widgets/icons.dart';
import '../widgets/common.dart';
import '../widgets/pet/finni_pet.dart';
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
  Future<void> _open(Widget page) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
    if (mounted) widget.controller.presentQueuedClip();
  }

  Future<void> _closeWeek() async {
    final ok = await confirmAction(
      context,
      title: 'Закрыть неделю?',
      body:
          'Сравним план и факт. Питомец изменится по серии решений. Это демо: ждать настоящие дни не нужно.',
    );
    if (!ok || !mounted) return;
    final result = await widget.controller.closePeriod();
    if (!mounted) return;
    showResult(context, message: result.message, next: result.nextStep);
  }

  Future<void> _openSessionMenu(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppTheme.card,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.pets_rounded, color: AppTheme.mint),
                title: const Text('Новый питомец'),
                subtitle: const Text('Откроется создание персонажа'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final ok = await confirmAction(
                    context,
                    title: 'Создать нового питомца?',
                    body:
                        'Текущий питомец, монеты и прогресс сбросятся. Дальше откроется создание персонажа.',
                  );
                  if (!ok || !context.mounted) return;
                  await widget.controller.goToCreatePet();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppTheme.ink),
                title: const Text('Выйти из игры'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  SystemNavigator.pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final p = widget.controller.profile;
        final pet = p.pet!;
        final goal = Catalog.goalById(p.goalId);
        final openTask = Catalog.tasks
            .where((task) => !p.doneTaskIds.contains(task.id))
            .firstOrNull;
        final goalPercent = goal == null
            ? 0
            : ((p.savings / goal.cost) * 100).clamp(0, 100).round();
        final petSize = AppLayout.petSize(context, phone: 300, tablet: 420);

        return Scaffold(
          backgroundColor: AppTheme.cream,
          body: Stack(
            fit: StackFit.expand,
            children: [
              const RoomBackground(child: SizedBox.expand()),
              Align(
                alignment: const Alignment(0, 0.38),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 72),
                      child: SpeechBubble(
                        text: pet.moodReason.isEmpty
                            ? 'Привет! Я ${pet.name}'
                            : pet.moodReason,
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scaleXY(begin: 1, end: 1.03, duration: 1600.ms),
                    ),
                    _HomePet(
                      controller: widget.controller,
                      size: petSize,
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CoinBadge(
                            icon: FinniIcons.coins,
                            value: p.coins,
                            tooltip: 'Монеты',
                          ),
                          const SizedBox(width: 8),
                          _CoinBadge(
                            icon: FinniIcons.savings,
                            value: p.savings,
                            tooltip: 'Копилка',
                          ),
                          const SizedBox(width: 8),
                          _MusicHud(),
                          const Spacer(),
                          if (p.phase == PeriodPhase.active && p.demoMode)
                            _RoundHud(
                              icon: Icons.skip_next_rounded,
                              tooltip: 'Неделя',
                              color: AppTheme.gold,
                              size: 42,
                              showLabel: false,
                              onTap: _closeWeek,
                            ),
                          _RoundHud(
                            icon: Icons.menu_rounded,
                            tooltip: 'Меню',
                            color: AppTheme.ink,
                            size: 42,
                            showLabel: false,
                            onTap: () => _openSessionMenu(context),
                          ),
                          _RoundHud(
                            icon: FinniIcons.adult,
                            tooltip: 'Взрослым',
                            color: AppTheme.wave,
                            size: 42,
                            showLabel: false,
                            onTap: () =>
                                _open(AdultScreen(controller: widget.controller)),
                          ),
                          _RoundHud(
                            icon: FinniIcons.help,
                            tooltip: 'Словарь',
                            color: AppTheme.sky,
                            size: 42,
                            showLabel: false,
                            onTap: () => _open(const GlossaryScreen()),
                          ),
                        ],
                      ),
                    ),
                    if (openTask != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _HintChip(
                            text: 'Задание: ${openTask.title}',
                            onTap: () => _open(
                              TasksScreen(controller: widget.controller),
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _RoundHud(
                                  icon: FinniIcons.plan,
                                  tooltip: 'План',
                                  color: AppTheme.mint,
                                  onTap: () => _open(
                                    BudgetScreen(controller: widget.controller),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _RoundHud(
                                  icon: FinniIcons.tasks,
                                  tooltip: 'Задания',
                                  color: AppTheme.sky,
                                  badge: openTask == null ? null : '!',
                                  onTap: () => _open(
                                    TasksScreen(controller: widget.controller),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _RoundHud(
                                  icon: FinniIcons.shop,
                                  tooltip: 'Покупки',
                                  color: AppTheme.peach,
                                  onTap: () => _open(
                                    ShopScreen(controller: widget.controller),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _RoundHud(
                                  icon: FinniIcons.savings,
                                  tooltip: 'Копилка',
                                  color: AppTheme.gold,
                                  onTap: () => _open(
                                    SavingsScreen(controller: widget.controller),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xF2FFF8E8),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: AppTheme.ink.withValues(alpha: 0.14),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.ink.withValues(alpha: 0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: _RoundHud(
                                    icon: FinniIcons.games,
                                    tooltip: 'Игры',
                                    color: AppTheme.peach,
                                    size: 52,
                                    onTap: () => _open(
                                      GamesHubScreen(
                                        controller: widget.controller,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: _RoundHud(
                                    icon: FinniIcons.progress,
                                    tooltip: 'Прогресс',
                                    color: AppTheme.sky,
                                    size: 52,
                                    onTap: () => _open(
                                      ProgressScreen(
                                        controller: widget.controller,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: _StatHud(
                                    icon: Icons.favorite_rounded,
                                    percent: pet.mood,
                                    tooltip: 'Настроение ${pet.mood}',
                                    color: AppTheme.mint,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: _StatHud(
                                    icon: Icons.restaurant_rounded,
                                    percent: pet.satiety,
                                    tooltip: 'Сытость ${pet.satiety}',
                                    color: AppTheme.peach,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: _StatHud(
                                    icon: FinniIcons.savings,
                                    percent: goalPercent,
                                    tooltip: goal == null
                                        ? 'Цель не выбрана'
                                        : '${goal.title}: ${p.savings} из ${goal.cost}. ${Economy.goalEta(p)}',
                                    color: AppTheme.gold,
                                    onTap: () => _open(
                                      SavingsScreen(
                                        controller: widget.controller,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MusicHud extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: MusicService.instance,
      builder: (context, _) {
        final music = MusicService.instance;
        return _RoundHud(
          icon: music.muted
              ? Icons.volume_off_rounded
              : Icons.volume_up_rounded,
          tooltip: 'Громкость',
          color: AppTheme.ink,
          size: 42,
          showLabel: false,
          onTap: () => _openVolumeSheet(context),
        );
      },
    );
  }

  void _openVolumeSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppTheme.card,
      builder: (context) {
        return ListenableBuilder(
          listenable: MusicService.instance,
          builder: (context, _) {
            final music = MusicService.instance;
            final percent = music.muted ? 0 : (music.volume * 100).round();
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    music.muted ? 'Музыка выключена' : 'Громкость $percent%',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Тише',
                        onPressed: () =>
                            music.nudgeVolume(-MusicService.volumeStep),
                        icon: const Icon(Icons.volume_down_rounded),
                      ),
                      Expanded(
                        child: Slider(
                          value: music.muted ? 0 : music.volume,
                          onChanged: music.setVolume,
                          min: 0,
                          max: 1,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Громче',
                        onPressed: () =>
                            music.nudgeVolume(MusicService.volumeStep),
                        icon: const Icon(Icons.volume_up_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  FilledButton.icon(
                    onPressed: music.toggleMuted,
                    icon: Icon(
                      music.muted
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                    ),
                    label: Text(music.muted ? 'Включить' : 'Тихо'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CoinBadge extends StatelessWidget {
  const _CoinBadge({
    required this.icon,
    required this.value,
    required this.tooltip,
  });

  final IconData icon;
  final int value;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: PressScale(
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppTheme.ink.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.ink.withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppTheme.gold, size: 20),
              const SizedBox(width: 6),
              Text(
                '$value',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundHud extends StatelessWidget {
  const _RoundHud({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
    this.badge,
    this.size = 72,
    this.showLabel = true,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;
  final String? badge;
  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [color, color.withValues(alpha: 0.72)],
                        ),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.28),
                          width: 1.1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: size * 0.48),
                    ),
                    if (badge != null)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE85D4C),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                if (showLabel) ...[
                  const SizedBox(height: 4),
                  Text(
                    tooltip,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      shadows: [Shadow(color: Colors.white, blurRadius: 8)],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatHud extends StatelessWidget {
  const _StatHud({
    required this.icon,
    required this.percent,
    required this.tooltip,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final int percent;
  final String tooltip;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ring = Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.card.withValues(alpha: 0.96),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.28),
          width: 1.1,
        ),
      ),
      child: ProgressRing(
        value: percent / 100,
        color: color,
        size: 46,
        stroke: 6,
        child: Icon(icon, color: color, size: 20),
      ),
    );
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ring,
        const SizedBox(height: 2),
        Text(
          '$percent%',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 11,
            shadows: [Shadow(color: Colors.white, blurRadius: 8)],
          ),
        ),
      ],
    );
    return PressScale(
      child: Tooltip(
        message: tooltip,
        child: onTap == null
            ? body
            : InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(40),
                child: body,
              ),
      ),
    );
  }
}

class _HomePet extends StatefulWidget {
  const _HomePet({required this.controller, required this.size});

  final GameController controller;
  final double size;

  @override
  State<_HomePet> createState() => _HomePetState();
}

class _HomePetState extends State<_HomePet> {
  late Pet _pet;
  late PetClip _clip;

  @override
  void initState() {
    super.initState();
    _pet = widget.controller.profile.pet!;
    _clip = widget.controller.petClip;
    widget.controller.addListener(_onCtrl);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onCtrl);
    super.dispose();
  }

  void _onCtrl() {
    final pet = widget.controller.profile.pet;
    if (pet == null || !mounted) return;
    final clip = widget.controller.petClip;
    if (identical(pet, _pet) && clip == _clip) return;
    if (clip == _clip &&
        pet.name == _pet.name &&
        pet.stage == _pet.stage &&
        pet.look.id == _pet.look.id) {
      return;
    }
    setState(() {
      _pet = pet;
      _clip = clip;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FinniPetView(
      pet: _pet,
      size: widget.size,
      clip: _clip,
      onTap: widget.controller.reactToPetTap,
      onOneShotFinished: widget.controller.onActionClipFinished,
    );
  }
}

class _HintChip extends StatelessWidget {
  const _HintChip({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      child: Material(
        color: AppTheme.card.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ),
      ),
    );
  }
}
