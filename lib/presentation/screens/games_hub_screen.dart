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
                    CircleGlyph(
                      icon: FinniIcons.games,
                      color: const Color(0xFF4EA2FF),
                      size: 64,
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
                icon: FinniIcons.needWant,
                title: 'Надо или хочу?',
                subtitle: 'Жми или перетащи карточку в нужную сторону.',
                color: const Color(0xFF5FCBB0),
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
                color: const Color(0xFFE8B84A),
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
                color: const Color(0xFF4EA2FF),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SortJarsGameScreen(controller: controller),
                    ),
                  );
                },
              ),
              _GameCard(
                icon: FinniIcons.catcher,
                title: 'Копилка ловит',
                subtitle: 'Води копилку и лови монеты. Три уровня сложности.',
                color: const Color(0xFFF27BA0),
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
                subtitle: 'Открой две одинаковые карточки. Три уровня сложности.',
                color: const Color(0xFF8B7CFF),
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
          color: Colors.white,
          elevation: 2,
          shadowColor: AppTheme.ink.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleGlyph(icon: icon, color: color, size: 64, iconSize: 32),
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
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: AppTheme.ink.withValues(alpha: 0.68),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.ink.withValues(alpha: 0.35),
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.06, end: 0);
  }
}
