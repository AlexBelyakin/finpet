import 'package:flutter/material.dart';

import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/presentation/screens/games/coin_catch_game.dart';
import 'package:finpet/presentation/screens/games/need_want_game.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import 'package:finpet/presentation/widgets/icons.dart';
import 'package:finpet/presentation/widgets/shell.dart';

class GamesHubScreen extends StatelessWidget {
  const GamesHubScreen({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return FinniScaffold(
          title: 'Игры',
          body: ListView(
            children: [
              const Text(
                'Играй и зарабатывай монеты для питомца. Это не задачки — можно тапать и сортировать.',
              ),
              const SizedBox(height: 12),
              SurfaceCard(
                child: Text('Сыграно игр: ${controller.profile.gamesPlayed}'),
              ),
              const SizedBox(height: 12),
              _GameCard(
                emoji: '⚖️',
                title: 'Надо или хочу?',
                subtitle: 'Сортируй покупки: нужное или желаемое.',
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
                emoji: '₽',
                title: 'Лови монетки',
                subtitle: 'Тапай монеты, не хватай лишние траты.',
                color: AppTheme.peach,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CoinCatchGameScreen(controller: controller),
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
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.card,
                  child: emoji == '₽'
                      ? const Icon(FinniIcons.coins, size: 32, color: AppTheme.ink)
                      : Text(emoji, style: const TextStyle(fontSize: 28)),
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
                const Icon(FinniIcons.games),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
