import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:finpet/app/layout.dart';
import 'package:finpet/data/pet/pet_model_bridge.dart';
import 'package:finpet/app/home_hints.dart';
import 'package:finpet/app/pet_clips.dart';
import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/data/audio/music_service.dart';
import 'package:finpet/domain/content/catalog.dart';
import 'package:finpet/domain/economy/engine.dart';
import 'package:finpet/domain/models.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import 'package:finpet/presentation/widgets/icons.dart';
import '../widgets/common.dart';
import '../widgets/home_spotlight.dart';
import '../widgets/pet/finni_pet.dart';
import 'adult_screen.dart';
import 'budget_screen.dart';
import 'games_hub_screen.dart';
import 'glossary_screen.dart';
import 'progress_screen.dart';
import 'savings_screen.dart';
import 'shop_screen.dart';
import 'tasks_screen.dart';
import 'place_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _hintsRunning = false;
  int? _hintIndex;
  Rect? _hintHole;
  String? _speech;
  var _speechIdx = 0;
  Timer? _speechTimer;
  final _overlayKey = GlobalKey();
  final _spots = {for (final spot in HintSpot.values) spot: GlobalKey()};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowHints());
  }

  @override
  void dispose() {
    _speechTimer?.cancel();
    super.dispose();
  }

  List<String> _speechLines(Pet pet) {
    return [
      'Привет! Я ${pet.name}!',
      'Давай сегодня придумаем, как лучше распорядиться монетами?',
      'Мне нравится, когда ты рядом.',
      'Не забудь про план и копилку — я подожду.',
      if (pet.moodReason.isNotEmpty) pet.moodReason,
    ];
  }

  void _say(String text) {
    _speechTimer?.cancel();
    setState(() => _speech = text);
    _speechTimer = Timer(const Duration(seconds: 7), () {
      if (mounted) setState(() => _speech = null);
    });
  }

  void _onPetTap() {
    final pet = widget.controller.profile.pet;
    if (pet == null) return;
    widget.controller.reactToPetTap();
    final lines = _speechLines(pet);
    _speechIdx = (_speechIdx + 1) % lines.length;
    _say(lines[_speechIdx]);
  }

  Future<void> _maybeShowHints() async {
    if (!mounted || _hintsRunning) return;
    final pet = widget.controller.profile.pet;
    if (pet == null) return;
    if (widget.controller.profile.seenHomeHints) {
      _say(_speechLines(pet).first);
      return;
    }
    _hintsRunning = true;
    setState(() => _hintIndex = 0);
    _measureHole();
  }

  void _measureHole() {
    void read() {
      if (!mounted || _hintIndex == null) return;
      final spot = HomeHints.steps[_hintIndex!].spot;
      final box =
          _spots[spot]?.currentContext?.findRenderObject() as RenderBox?;
      final overlay =
          _overlayKey.currentContext?.findRenderObject() as RenderBox?;
      Rect? hole;
      if (box != null && box.hasSize && overlay != null && overlay.hasSize) {
        final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
        final bottomRight = box.localToGlobal(
          box.size.bottomRight(Offset.zero),
          ancestor: overlay,
        );
        hole = HomeHints.holeOf(
          spot,
          Rect.fromPoints(topLeft, bottomRight),
        );
      }
      if (hole != _hintHole) setState(() => _hintHole = hole);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      read();
      WidgetsBinding.instance.addPostFrameCallback((_) => read());
    });
  }

  Future<void> _hintOk() async {
    final next = (_hintIndex ?? 0) + 1;
    if (next >= HomeHints.steps.length) {
      setState(() {
        _hintIndex = null;
        _hintHole = null;
        _hintsRunning = false;
      });
      await widget.controller.markHomeHintsSeen();
      final pet = widget.controller.profile.pet;
      if (pet != null && mounted) _say(_speechLines(pet).first);
      return;
    }
    setState(() {
      _hintIndex = next;
      _hintHole = null;
    });
    _measureHole();
  }

  Widget _spot(HintSpot spot, Widget child) {
    final on = _hintIndex != null &&
        HomeHints.steps[_hintIndex!].spot == spot;
    return KeyedSubtree(
      key: _spots[spot],
      child: spot == HintSpot.pet
          ? child
          : SpotGlow(active: on, child: child),
    );
  }

  Future<void> _open(Widget page) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
    if (!mounted) return;
    widget.controller.presentQueuedClip();
    PetModelBridge.resume();
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
                leading: const Icon(Icons.weekend_rounded, color: AppTheme.sky),
                title: const Text('Сменить локацию'),
                subtitle: Text(
                  widget.controller.profile.room2Unlocked
                      ? 'Теремок на лужайке или усадьба у сада. Прогресс сохранится.'
                      : 'Усадьба откроется после ${GameProfile.room2TasksNeeded} заданий.',
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PlaceScreen(
                        controller: widget.controller,
                        firstPick: false,
                      ),
                    ),
                  );
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
        final goalPercent = goal == null || goal.cost <= 0
            ? 0.0
            : (p.savings / goal.cost).clamp(0.0, 1.0);
        final petSize = AppLayout.petSize(context, phone: 300, tablet: 440);
        final hint = _hintIndex == null ? null : HomeHints.steps[_hintIndex!];

        return Scaffold(
          backgroundColor: AppTheme.cream,
          body: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              RoomBackground(
                place: p.place ?? PetPlace.room,
                child: const SizedBox.expand(),
              ),
              Align(
                alignment: const Alignment(0, 0.36),
                child: _spot(
                  HintSpot.pet,
                  _HomePet(
                    controller: widget.controller,
                    size: petSize,
                    onTap: _onPetTap,
                  ),
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
                          _spot(
                            HintSpot.wallet,
                            Row(
                              children: [
                                _WalletPill(coins: p.coins, savings: p.savings),
                                const SizedBox(width: 8),
                                const _MusicHud(),
                              ],
                            ),
                          ),
                          const Spacer(),
                          _spot(
                            HintSpot.topRight,
                            _GlassBar(
                              child: Row(
                                children: [
                                  if (p.phase == PeriodPhase.active &&
                                      p.demoMode)
                                    _IconBtn(
                                      icon: Icons.skip_next_rounded,
                                      tooltip: 'Неделя',
                                      onTap: _closeWeek,
                                    ),
                                  _IconBtn(
                                    icon: Icons.menu_rounded,
                                    tooltip: 'Меню',
                                    onTap: () => _openSessionMenu(context),
                                  ),
                                  _IconBtn(
                                    icon: FinniIcons.adult,
                                    tooltip: 'Взрослым',
                                    onTap: () => _open(
                                      AdultScreen(
                                        controller: widget.controller,
                                      ),
                                    ),
                                  ),
                                  _IconBtn(
                                    icon: FinniIcons.help,
                                    tooltip: 'Словарь',
                                    onTap: () =>
                                        _open(const GlossaryScreen()),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (openTask != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                        child: _TaskBanner(
                          title: openTask.title,
                          done: p.doneTaskIds.length,
                          total: Catalog.tasks.length,
                          onTap: () => _open(
                            TasksScreen(controller: widget.controller),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _spot(
                              HintSpot.leftHud,
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _RoundHud(
                                    icon: FinniIcons.plan,
                                    tooltip: 'План',
                                    color: const Color(0xFF5FCBB0),
                                    onTap: () => _open(
                                      BudgetScreen(
                                        controller: widget.controller,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  _RoundHud(
                                    icon: FinniIcons.tasks,
                                    tooltip: 'Задания',
                                    color: const Color(0xFF9B7EE8),
                                    badge: openTask == null ? null : '!',
                                    onTap: () => _open(
                                      TasksScreen(
                                        controller: widget.controller,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            _spot(
                              HintSpot.rightHud,
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _RoundHud(
                                    icon: FinniIcons.shop,
                                    tooltip: 'Покупки',
                                    color: const Color(0xFFF5A24A),
                                    onTap: () => _open(
                                      ShopScreen(
                                        controller: widget.controller,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  _RoundHud(
                                    icon: FinniIcons.savings,
                                    tooltip: 'Копилка',
                                    color: const Color(0xFFF27BA0),
                                    onTap: () => _open(
                                      SavingsScreen(
                                        controller: widget.controller,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _spot(
                      HintSpot.bottomBar,
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xF7FFFBF3),
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.ink.withValues(alpha: 0.1),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(6, 10, 6, 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _NavHud(
                                    icon: FinniIcons.games,
                                    label: 'Игры',
                                    color: const Color(0xFF5B9BFF),
                                    onTap: () => _open(
                                      GamesHubScreen(
                                        controller: widget.controller,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: _NavHud(
                                    icon: FinniIcons.progress,
                                    label: 'Прогресс',
                                    color: const Color(0xFF9B7EE8),
                                    onTap: () => _open(
                                      ProgressScreen(
                                        controller: widget.controller,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: _StatHud(
                                    icon: Icons.favorite_rounded,
                                    label: 'Настроение',
                                    percent: pet.mood,
                                    tooltip: 'Настроение ${pet.mood}',
                                    color: const Color(0xFF4CC38A),
                                    iconColor: const Color(0xFFE85D6A),
                                  ),
                                ),
                                Expanded(
                                  child: _StatHud(
                                    icon: Icons.restaurant_rounded,
                                    label: 'Сытость',
                                    percent: pet.satiety,
                                    tooltip: 'Сытость ${pet.satiety}',
                                    color: const Color(0xFFF5A24A),
                                  ),
                                ),
                                Expanded(
                                  child: _StarHud(
                                    label: 'Накоплено',
                                    value: p.savings,
                                    progress: goalPercent,
                                    tooltip: goal == null
                                        ? 'Цель не выбрана'
                                        : '${goal.title}: ${p.savings} из ${goal.cost}. ${Economy.goalEta(p)}',
                                    onTap: () => _open(
                                      SavingsScreen(
                                        controller: widget.controller,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_speech != null && hint == null)
                IgnorePointer(
                  child: SafeArea(
                    child: Align(
                      alignment: const Alignment(0.62, -0.08),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(96, 8, 78, 0),
                        child: SpeechBubble(
                          key: ValueKey(_speech),
                          text: _speech!,
                        ),
                      ),
                    ),
                  ),
                ),
              if (hint != null)
                HomeSpotlight(
                  paintKey: _overlayKey,
                  hint: hint,
                  hole: _hintHole,
                  step: (_hintIndex ?? 0) + 1,
                  total: HomeHints.steps.length,
                  onOk: _hintOk,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _GlassBar extends StatelessWidget {
  const _GlassBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xF2EEF6FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.ink.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: child,
      ),
    );
  }
}

class _WalletPill extends StatelessWidget {
  const _WalletPill({required this.coins, required this.savings});

  final int coins;
  final int savings;

  @override
  Widget build(BuildContext context) {
    return _GlassBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 11,
              backgroundColor: Color(0xFFE8B84A),
              child: Text(
                '₽',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$coins',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppTheme.ink,
              ),
            ),
            Container(
              width: 1,
              height: 18,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: AppTheme.ink.withValues(alpha: 0.12),
            ),
            const Icon(FinniIcons.savings, size: 18, color: Color(0xFFF27BA0)),
            const SizedBox(width: 4),
            Text(
              '$savings',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppTheme.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, color: const Color(0xFF5A7A9A), size: 22),
    );
  }
}

class _MusicHud extends StatelessWidget {
  const _MusicHud();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: MusicService.instance,
      builder: (context, _) {
        final music = MusicService.instance;
        return _GlassBar(
          child: _IconBtn(
            icon: music.muted
                ? Icons.volume_off_rounded
                : Icons.volume_up_rounded,
            tooltip: 'Громкость',
            onTap: () => _openVolumeSheet(context),
          ),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
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

class _RoundHud extends StatelessWidget {
  const _RoundHud({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.38),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 30),
                  ),
                  if (badge != null)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 18,
                        height: 18,
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
              const SizedBox(height: 6),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xF2FFFFFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  child: Text(
                    tooltip,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: AppTheme.ink,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavHud extends StatelessWidget {
  const _NavHud({
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
    return PressScale(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: AppTheme.ink.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatHud extends StatelessWidget {
  const _StatHud({
    required this.icon,
    required this.label,
    required this.percent,
    required this.tooltip,
    required this.color,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final int percent;
  final String tooltip;
  final Color color;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: ProgressRing(
            value: percent / 100,
            color: color,
            size: 48,
            stroke: 4,
            child: Icon(icon, color: iconColor ?? color, size: 22),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 10,
            color: AppTheme.ink.withValues(alpha: 0.72),
          ),
        ),
        Text(
          '$percent%',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 11,
            color: color,
          ),
        ),
      ],
    );
    return PressScale(
      child: Tooltip(
        message: tooltip,
        child: body,
      ),
    );
  }
}

class _StarHud extends StatelessWidget {
  const _StarHud({
    required this.label,
    required this.value,
    required this.progress,
    required this.tooltip,
    this.onTap,
  });

  final String label;
  final int value;
  final double progress;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const star = Color(0xFF2BB673);
    const ring = Color(0xFFE8B84A);
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: ProgressRing(
            value: progress,
            color: ring,
            size: 48,
            stroke: 4,
            child: const Icon(Icons.star_rounded, color: star, size: 26),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 10,
            color: AppTheme.ink.withValues(alpha: 0.72),
          ),
        ),
        Text(
          '$value',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 11,
            color: star,
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
  const _HomePet({
    required this.controller,
    required this.size,
    required this.onTap,
  });

  final GameController controller;
  final double size;
  final VoidCallback onTap;

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
      showCaption: false,
      clip: _clip,
      onTap: widget.onTap,
      onOneShotFinished: widget.controller.onActionClipFinished,
    );
  }
}

class _TaskBanner extends StatelessWidget {
  const _TaskBanner({
    required this.title,
    required this.done,
    required this.total,
    required this.onTap,
  });

  final String title;
  final int done;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final value = total <= 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
    return PressScale(
      child: Material(
        color: const Color(0xF2EEF6FF),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 12,
                      backgroundColor: Color(0xFFE8B84A),
                      child: Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Задание: $title',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$done / $total',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: AppTheme.ink.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF5A534E),
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(1.5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFD5DDE4),
                      color: const Color(0xFF4CC38A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}