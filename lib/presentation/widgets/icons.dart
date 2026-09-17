import 'package:flutter/material.dart';

import 'package:finpet/domain/models.dart';

abstract final class FinniIcons {
  static const plan = Icons.pie_chart_rounded;
  static const tasks = Icons.extension_rounded;
  static const shop = Icons.storefront_rounded;
  static const savings = Icons.savings_rounded;
  static const progress = Icons.auto_graph_rounded;
  static const adult = Icons.family_restroom_rounded;
  static const help = Icons.menu_book_rounded;
  static const coins = Icons.currency_ruble_rounded;
  static const need = Icons.restaurant_rounded;
  static const want = Icons.favorite_rounded;
  static const save = Icons.savings_outlined;
  static const pet = Icons.pets_rounded;
  static const games = Icons.sports_esports_rounded;

  static IconData forTask(TaskTheme theme) => switch (theme) {
        TaskTheme.budget => plan,
        TaskTheme.savings => savings,
        TaskTheme.purchases => shop,
      };

  static IconData forShop(String id) => switch (id) {
        'n1' => Icons.ramen_dining_rounded,
        'n2' => Icons.water_drop_rounded,
        'n3' => Icons.brush_rounded,
        'n4' => Icons.soap_rounded,
        'n5' => Icons.bed_rounded,
        'n6' => Icons.medication_rounded,
        'w1' => Icons.sports_soccer_rounded,
        'w2' => Icons.cake_rounded,
        'w3' => Icons.auto_awesome_rounded,
        'w4' => Icons.sailing_rounded,
        'w5' => Icons.menu_book_rounded,
        'w6' => Icons.bubble_chart_rounded,
        _ => Icons.shopping_bag_rounded,
      };
}
