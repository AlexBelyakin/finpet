import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:finpet/app/layout.dart';
import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/domain/content/catalog.dart';
import 'package:finpet/domain/models.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import 'package:finpet/presentation/widgets/icons.dart';
import '../widgets/common.dart';
import '../widgets/shell.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final p = controller.profile;
        final cols = AppLayout.columns(context);
        return FinniScaffold(
          title: 'Покупки',
          body: ListView(
            children: [
              Text(
                'Монет: ${p.coins}. Сначала нужное, потом желаемое.',
              ),
              const SizedBox(height: 12),
              const _SectionTitle(
                icon: FinniIcons.need,
                label: 'Нужное',
              ),
              _ShopGrid(
                items: Catalog.shop.where((e) => e.kind == ExpenseKind.need),
                columns: cols,
                controller: controller,
              ),
              const SizedBox(height: 12),
              const _SectionTitle(
                icon: FinniIcons.want,
                label: 'Желаемое',
              ),
              _ShopGrid(
                items: Catalog.shop.where((e) => e.kind == ExpenseKind.want),
                columns: cols,
                controller: controller,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.mint),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ShopGrid extends StatelessWidget {
  const _ShopGrid({
    required this.items,
    required this.columns,
    required this.controller,
  });

  final Iterable<ShopItem> items;
  final int columns;
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final list = items.toList();
    if (columns == 1) {
      return Column(
        children: [
          for (final item in list) _ShopCard(item: item, controller: controller),
        ],
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisExtent: 168,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, i) =>
          _ShopCard(item: list[i], controller: controller),
    );
  }
}

class _ShopCard extends StatelessWidget {
  const _ShopCard({required this.item, required this.controller});

  final ShopItem item;
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SurfaceCard(
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: item.kind == ExpenseKind.need
                      ? [AppTheme.peach, AppTheme.peach.withValues(alpha: 0.7)]
                      : [AppTheme.sky, AppTheme.sky.withValues(alpha: 0.7)],
                ),
              ),
              child: Icon(FinniIcons.forShop(item.id), color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.emoji} ${item.name}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text('${item.kindLabel} · ${item.price} монет'),
                  Text(item.effectLabel),
                ],
              ),
            ),
            FilledButton(
              onPressed: () async {
                final ok = await confirmAction(
                  context,
                  title: 'Купить ${item.name}?',
                  body:
                      'Категория: ${item.kindLabel}. Цена: ${item.price}. ${item.effectLabel}. Спишется ${item.price} монет.',
                );
                if (!ok || !context.mounted) return;
                final result = await controller.buy(item.id);
                if (!context.mounted) return;
                showResult(
                  context,
                  message: result.message,
                  next: result.nextStep,
                );
              },
              child: const Text('Купить'),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.04, end: 0);
  }
}
