import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/domain/economy/engine.dart';
import 'package:finpet/presentation/screens/games/coin_catch_game.dart';
import 'package:finpet/presentation/screens/games/memory_pairs_game.dart';
import 'package:finpet/presentation/screens/games/need_want_game.dart';
import 'package:finpet/presentation/screens/games/piggy_catch_game.dart';
import 'package:finpet/presentation/screens/games/sort_jars_game.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import 'package:finpet/presentation/widgets/icons.dart';
import 'package:finpet/presentation/widgets/common.dart';
import 'package:finpet/presentation/widgets/shell.dart';

class GamesHubScreen extends StatelessWidget {
  const GamesHubScreen({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final left = Economy.maxMinigameCoinsPerPeriod -
            controller.profile.minigameCoinsThisPeriod;
        return FinniScaffold(
          title: 'Игры',
          body: ListView(
            children: [
              const Text(
                'Тапай, лови и раскладывай. Это не задачки — живые мини-игры про монеты.',
              ),
              const SizedBox(height: 12),
              SurfaceCard(
                child: Row(
                  children: [
                    ProgressRing(
                      value: Economy.maxMinigameCoinsPerPeriod == 0
                          ? 0
                          : left / Economy.maxMinigameCoinsPerPeriod,
                      color: AppTheme.peach,
                      size: 72,
                      stroke: 8,
                      child: Icon(FinniIcons.games, color: AppTheme.peach, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Сыграно: ${controller.profile.gamesPlayed}\n'
                        'Монет за игры на этой неделе ещё можно взять: $left из ${Economy.maxMinigameCoinsPerPeriod}',
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 280.ms).scale(
                    begin: const Offset(0.96, 0.96),
                    duration: 320.ms,
                  ),
              const SizedBox(height: 12),
              _GameCard(
                icon: FinniIcons.need,
                title: 'Надо или хочу?',
                subtitle: 'Жми или перетащи карточку в нужную сторону.',
                color: AppTheme.mint,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => NeedWantGameScreen(controller: controller),
                    ),
                  );
                },
              ),
              _GameCard(
                icon: FinniIcons.coins,
                title: 'Лови монетки',
                subtitle: 'Монеты падают. Тапай их, не хватай лишние траты.',
                color: AppTheme.gold,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CoinCatchGameScreen(controller: controller),
                    ),
                  );
                },
              ),
              _GameCard(
                icon: FinniIcons.jars,
                title: 'Три баночки',
                subtitle: 'Разложи: надо, хочу и копилка.',
                color: AppTheme.sky,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SortJarsGameScreen(controller: controller),
                    ),
                  );
                },
              ),
              _GameCard(
                icon: FinniIcons.savings,
                title: 'Копилка ловит',
                subtitle: 'Води копилку и лови монеты, не покупки.',
                color: AppTheme.peach,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PiggyCatchGameScreen(controller: controller),
                    ),
                  );
                },
              ),
              _GameCard(
                icon: FinniIcons.cards,
                title: 'Найди пары',
                subtitle: 'Открой две одинаковые карточки.',
                color: AppTheme.lilac,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MemoryPairsGameScreen(controller: controller),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PressScale(
        child: Material(
          color: color.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [color, color.withValues(alpha: 0.7)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.45),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(icon, size: 36, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        Text(subtitle),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: AppTheme.ink.withValues(alpha: 0.5), size: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.06, end: 0);
  }
}
