import 'package:flutter/material.dart';

enum HintSpot { pet, wallet, topRight, leftHud, rightHud, bottomBar }

class HomeHint {
  const HomeHint({
    required this.title,
    required this.body,
    required this.spot,
    required this.card,
  });

  final String title;
  final String body;
  final HintSpot spot;

  /// Куда сдвинуть карточку, чтобы не закрывать подсвеченные кнопки.
  final Alignment card;
}

/// Короткие подсказки по значкам дома, один раз после создания питомца.
abstract final class HomeHints {
  static const steps = [
    HomeHint(
      title: 'Это твой дом',
      body:
          'Здесь живёт питомец. Нажми на него — он ответит в облачке. Дальше покажем значки.',
      spot: HintSpot.pet,
      card: Alignment(0, -0.82),
    ),
    HomeHint(
      title: 'Монеты и копилка',
      body:
          'Слева сверху: монеты в кармане — ими платят в магазине. Рядом копилка — уже отложенное на цель. Динамик включает музыку.',
      spot: HintSpot.wallet,
      card: Alignment(0, -0.52),
    ),
    HomeHint(
      title: 'Кнопки справа сверху',
      body:
          'Меню — новый питомец или выход. Человечки — раздел «Взрослым». Книжка — словарь слов.',
      spot: HintSpot.topRight,
      card: Alignment(-0.15, -0.52),
    ),
    HomeHint(
      title: 'План и задания',
      body:
          'Слева два кружка. План — разложить монеты на нужное, желаемое и копилку. Задания — короткие истории, за них дают монеты.',
      spot: HintSpot.leftHud,
      card: Alignment(0.2, -0.72),
    ),
    HomeHint(
      title: 'Покупки и копилка',
      body:
          'Справа два кружка. Сумка — магазин, сначала бери нужное. Свинка — копилка и цель.',
      spot: HintSpot.rightHud,
      card: Alignment(-0.2, -0.72),
    ),
    HomeHint(
      title: 'Нижний ряд',
      body:
          'Игры и прогресс. Сердце — настроение, вилка — сытость, звезда — сколько уже накоплено до цели.',
      spot: HintSpot.bottomBar,
      card: Alignment(0, 0.05),
    ),
  ];
}
