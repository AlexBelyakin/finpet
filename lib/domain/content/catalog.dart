import 'package:finpet/domain/models.dart';

abstract final class Catalog {
  static const startIncome = 100;
  static const periodIncome = 80;

  static const looks = [
    PetLook(species: PetSpecies.cat, color: PetColor.peach),
    PetLook(species: PetSpecies.cat, color: PetColor.mint),
    PetLook(species: PetSpecies.cat, color: PetColor.sky),
    PetLook(species: PetSpecies.fox, color: PetColor.peach),
    PetLook(species: PetSpecies.fox, color: PetColor.mint),
    PetLook(species: PetSpecies.fox, color: PetColor.sky),
    PetLook(species: PetSpecies.bird, color: PetColor.peach),
    PetLook(species: PetSpecies.bird, color: PetColor.mint),
    PetLook(species: PetSpecies.bird, color: PetColor.sky),
  ];

  static const shop = [
    ShopItem(
      id: 'n1',
      name: 'Корм',
      price: 20,
      kind: ExpenseKind.need,
      emoji: '🥣',
      effectLabel: 'Финни станет сытее',
      satietyDelta: 28,
      moodDelta: 4,
    ),
    ShopItem(
      id: 'n2',
      name: 'Вода',
      price: 10,
      kind: ExpenseKind.need,
      emoji: '💧',
      effectLabel: 'Немного сытости',
      satietyDelta: 12,
      moodDelta: 2,
    ),
    ShopItem(
      id: 'n3',
      name: 'Расчёска',
      price: 12,
      kind: ExpenseKind.need,
      emoji: '🪮',
      effectLabel: 'Уход, лучше настроение',
      satietyDelta: 0,
      moodDelta: 10,
    ),
    ShopItem(
      id: 'n4',
      name: 'Мыло',
      price: 15,
      kind: ExpenseKind.need,
      emoji: '🧼',
      effectLabel: 'Чистота и уют',
      satietyDelta: 0,
      moodDelta: 8,
    ),
    ShopItem(
      id: 'w1',
      name: 'Мячик',
      price: 25,
      kind: ExpenseKind.want,
      emoji: '⚽',
      effectLabel: 'Веселье, но не еда',
      satietyDelta: 0,
      moodDelta: 18,
    ),
    ShopItem(
      id: 'w2',
      name: 'Тортик',
      price: 35,
      kind: ExpenseKind.want,
      emoji: '🍰',
      effectLabel: 'Вкусно и радостно',
      satietyDelta: 8,
      moodDelta: 14,
    ),
    ShopItem(
      id: 'w3',
      name: 'Бантик',
      price: 30,
      kind: ExpenseKind.want,
      emoji: '🎀',
      effectLabel: 'Красиво, настроение вверх',
      satietyDelta: 0,
      moodDelta: 12,
    ),
    ShopItem(
      id: 'w4',
      name: 'Воздушный змей',
      price: 40,
      kind: ExpenseKind.want,
      emoji: '🎏',
      effectLabel: 'Большая радость',
      satietyDelta: 0,
      moodDelta: 20,
    ),
  ];

  static const goals = [
    GoalDef(id: 'g1', title: 'Уютный домик', cost: 180, emoji: '🏠'),
    GoalDef(id: 'g2', title: 'Костюм героя', cost: 260, emoji: '🦸'),
    GoalDef(id: 'g3', title: 'Запас лакомств', cost: 340, emoji: '🍬'),
  ];

  static const tasks = [
    TaskDef(
      id: 't1',
      theme: TaskTheme.budget,
      type: TaskType.allocate,
      title: 'Разложи 30 монет',
      story:
          'У тебя 30 монет на день. Разложи их: нужное, желаемое и копилка. Сначала подумай про еду и уход.',
      reward: 20,
      allocateTotal: 30,
      minNeed: 10,
      minSave: 5,
      explainGood:
          'Ты оставил деньги и на нужное, и в копилку. Так расходы не съедают весь доход.',
      explainOther:
          'План слабый: мало на нужное или ничего в копилку. В жизни сначала закрывают важное, потом желания.',
    ),
    TaskDef(
      id: 't2',
      theme: TaskTheme.budget,
      type: TaskType.choice,
      title: 'Доход меньше желаний',
      story:
          'На неделю 80 монет. Корм стоит 20, игрушка 70, в копилку хочется 20. Что сделать?',
      reward: 18,
      options: [
        TaskOption(
          id: 'a',
          label: 'Купить корм, отложить 20, игрушку подождать',
          good: true,
        ),
        TaskOption(
          id: 'b',
          label: 'Купить игрушку сразу, корм потом как-нибудь',
          good: false,
        ),
        TaskOption(
          id: 'c',
          label: 'Потратить всё, чтобы ничего не осталось',
          good: false,
        ),
      ],
      explainGood:
          'Расходы не должны быть больше дохода. Нужное и копилка важнее большой игрушки.',
      explainOther:
          'Если купить всё желаемое сразу, на корм может не хватить. Лучше перенести игрушку.',
    ),
    TaskDef(
      id: 't3',
      theme: TaskTheme.savings,
      type: TaskType.choice,
      title: 'Копилка на домик',
      story:
          'Домик стоит 180. Ты можешь откладывать по 20 монет после нужных трат. Как быстрее и спокойнее?',
      reward: 22,
      options: [
        TaskOption(
          id: 'a',
          label: 'Каждую неделю класть по 20, даже если мало',
          good: true,
        ),
        TaskOption(
          id: 'b',
          label: 'Ждать, пока сразу появятся все 180',
          good: false,
        ),
        TaskOption(
          id: 'c',
          label: 'Забрать уже накопленное на тортик',
          good: false,
        ),
      ],
      explainGood:
          'Маленькие регулярные откладывания приближают цель. 20 за 20 — и домик ближе.',
      explainOther:
          'Ждать всю сумму сразу долго. Если забирать копилку на желаемое, цель отодвигается.',
    ),
    TaskDef(
      id: 't4',
      theme: TaskTheme.savings,
      type: TaskType.allocate,
      title: 'Спрячь часть в копилку',
      story:
          'Тебе дали 40 монет. Сколько пойдёт на нужное, желаемое и в копилку? Цель — не потратить всё.',
      reward: 20,
      allocateTotal: 40,
      minNeed: 10,
      minSave: 10,
      explainGood: 'Ты заплатил себе: часть денег сразу ушла в копилку.',
      explainOther:
          'Если в копилку ничего не класть, цель почти не двигается. Попробуй отложить хотя бы 10.',
    ),
    TaskDef(
      id: 't5',
      theme: TaskTheme.purchases,
      type: TaskType.choice,
      title: 'Два ценника',
      story:
          'Одинаковый корм: в одной лавке 20 монет, в другой 14. Что выгоднее для бюджета?',
      reward: 16,
      options: [
        TaskOption(id: 'a', label: 'Взять за 14 и сохранить 6', good: true),
        TaskOption(id: 'b', label: 'Взять за 20, потому что ярче коробка', good: false),
        TaskOption(id: 'c', label: 'Купить обе пачки сразу', good: false),
      ],
      explainGood:
          'Сравнивать цены — тоже финансовое решение. На нужное можно тратить меньше, если поискать.',
      explainOther:
          'Яркая коробка не значит, что корм лучше. Лишние 6 монет могли пойти в копилку.',
    ),
    TaskDef(
      id: 't6',
      theme: TaskTheme.purchases,
      type: TaskType.choice,
      title: 'Внезапная поездка',
      story:
          'Нужен проезд за 15 монет. В кармане мало, в копилке есть запас на домик. Что сделать?',
      reward: 24,
      options: [
        TaskOption(
          id: 'a',
          label: 'Отложить игрушку и оплатить проезд из обычных денег',
          good: true,
        ),
        TaskOption(
          id: 'b',
          label: 'Сразу сломать копилку без раздумий',
          good: false,
        ),
        TaskOption(
          id: 'c',
          label: 'Купить тортик, проезд подождёт',
          good: false,
        ),
      ],
      explainGood:
          'Непредвиденный расход закрывают из необязательного, а не первым делом из цели. Копилку трогают только осознанно.',
      explainOther:
          'Копилка — для цели. Если её снимать без подтверждения мысли, домик снова далеко. Желаемое можно перенести.',
    ),
  ];

  static const glossary = [
    ('Обязательные расходы', 'То, без чего питомцу плохо: еда и уход.'),
    ('Необязательные расходы', 'Приятное, но можно подождать: игрушка или тортик.'),
    ('Накопления', 'Деньги, которые ты отложил на цель и не тратишь просто так.'),
    ('План', 'Как ты заранее делишь деньги: нужное, желаемое, копилка.'),
    ('Факт', 'Как ты на самом деле потратил деньги за неделю.'),
    ('Игровая валюта', 'Монеты только в игре. Их нельзя обменять на настоящие деньги.'),
  ];

  static ShopItem itemById(String id) => shop.firstWhere((e) => e.id == id);

  static GoalDef? goalById(String? id) {
    if (id == null) return null;
    for (final goal in goals) {
      if (goal.id == id) return goal;
    }
    return null;
  }

  static TaskDef taskById(String id) => tasks.firstWhere((e) => e.id == id);
}
