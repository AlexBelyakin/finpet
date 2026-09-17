import 'package:flutter/material.dart';

import 'package:finpet/domain/content/catalog.dart';
import 'package:finpet/domain/models.dart';
import 'package:finpet/presentation/state/game_controller.dart';
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
        return FinniScaffold(
          title: 'Покупки',
          body: ListView(
            children: [
              Text('В кармане: ${p.coins}. Сначала нужное, потом желаемое.'),
              const SizedBox(height: 12),
              const Text('Нужное', style: TextStyle(fontWeight: FontWeight.w700)),
              ...Catalog.shop.where((e) => e.kind == ExpenseKind.need).map(
                    (item) => _item(context, item),
                  ),
              const SizedBox(height: 12),
              const Text('Желаемое', style: TextStyle(fontWeight: FontWeight.w700)),
              ...Catalog.shop.where((e) => e.kind == ExpenseKind.want).map(
                    (item) => _item(context, item),
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget _item(BuildContext context, ShopItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SurfaceCard(
        child: Row(
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
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
                      'Категория: ${item.kindLabel}. Цена: ${item.price}. ${item.effectLabel}. С кармана спишется ${item.price} монет.',
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
    );
  }
}
