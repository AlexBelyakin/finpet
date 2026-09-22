import 'package:finpet/domain/models.dart';

abstract final class Catalog {
  static const startIncome = 100;
  static const periodIncome = 80;

  static const looks = [
    PetLook(
      body: PetBody.finni,
      species: PetSpecies.cat,
      color: PetColor.peach,
    ),
    PetLook(
      body: PetBody.nori,
      species: PetSpecies.fox,
      color: PetColor.mint,
    ),
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
    ShopItem(
      id: 'n5',
      name: 'Подушка',
      price: 18,
      kind: ExpenseKind.need,
      emoji: '🛏️',
      effectLabel: 'Сон и уют',
      satietyDelta: 0,
      moodDelta: 9,
    ),
    ShopItem(
      id: 'n6',
      name: 'Витамины',
      price: 22,
      kind: ExpenseKind.need,
      emoji: '💊',
      effectLabel: 'Немного сытости и бодрости',
      satietyDelta: 10,
      moodDelta: 6,
    ),
    ShopItem(
      id: 'w5',
      name: 'Книжка',
      price: 28,
      kind: ExpenseKind.want,
      emoji: '📘',
      effectLabel: 'Интересно, но не еда',
      satietyDelta: 0,
      moodDelta: 16,
    ),
    ShopItem(
      id: 'w6',
      name: 'Мыльные пузыри',
      price: 22,
      kind: ExpenseKind.want,
      emoji: '🫧',
      effectLabel: 'Весёлая игра',
      satietyDelta: 0,
      moodDelta: 14,
    ),
    ShopItem(
      id: 'n7',
      name: 'Лекарство',
      price: 24,
      kind: ExpenseKind.need,
      emoji: '🩹',
      effectLabel: 'Если питомцу нездоровится',
      satietyDelta: 6,
      moodDelta: 8,
    ),
    ShopItem(
      id: 'n8',
      name: 'Наполнитель',
      price: 16,
      kind: ExpenseKind.need,
      emoji: '📦',
      effectLabel: 'Чисто и спокойно дома',
      satietyDelta: 0,
      moodDelta: 7,
    ),
    ShopItem(
      id: 'n9',
      name: 'Тёплая накидка',
      price: 20,
      kind: ExpenseKind.need,
      emoji: '🧣',
      effectLabel: 'Не замёрзнуть вечером',
      satietyDelta: 0,
      moodDelta: 10,
    ),
    ShopItem(
      id: 'n10',
      name: 'Зубная щётка',
      price: 11,
      kind: ExpenseKind.need,
      emoji: '🪥',
      effectLabel: 'Уход за собой',
      satietyDelta: 0,
      moodDelta: 6,
    ),
    ShopItem(
      id: 'n11',
      name: 'Миска',
      price: 14,
      kind: ExpenseKind.need,
      emoji: '🍽️',
      effectLabel: 'Удобно есть и пить',
      satietyDelta: 4,
      moodDelta: 5,
    ),
    ShopItem(
      id: 'n12',
      name: 'Поводок',
      price: 18,
      kind: ExpenseKind.need,
      emoji: '🦮',
      effectLabel: 'Безопасная прогулка',
      satietyDelta: 3,
      moodDelta: 8,
    ),
    ShopItem(
      id: 'w7',
      name: 'Краски',
      price: 26,
      kind: ExpenseKind.want,
      emoji: '🎨',
      effectLabel: 'Рисовать и радоваться',
      satietyDelta: 0,
      moodDelta: 15,
    ),
    ShopItem(
      id: 'w8',
      name: 'Пазл',
      price: 32,
      kind: ExpenseKind.want,
      emoji: '🧩',
      effectLabel: 'Долгая тихая игра',
      satietyDelta: 0,
      moodDelta: 17,
    ),
    ShopItem(
      id: 'w9',
      name: 'Мороженое',
      price: 20,
      kind: ExpenseKind.want,
      emoji: '🍦',
      effectLabel: 'Сладко, но не вместо еды',
      satietyDelta: 5,
      moodDelta: 12,
    ),
    ShopItem(
      id: 'w10',
      name: 'Барабан',
      price: 38,
      kind: ExpenseKind.want,
      emoji: '🥁',
      effectLabel: 'Шумно и весело',
      satietyDelta: 0,
      moodDelta: 18,
    ),
    ShopItem(
      id: 'w11',
      name: 'Наклейки',
      price: 15,
      kind: ExpenseKind.want,
      emoji: '🌟',
      effectLabel: 'Маленькая радость',
      satietyDelta: 0,
      moodDelta: 10,
    ),
    ShopItem(
      id: 'w12',
      name: 'Фонарик',
      price: 24,
      kind: ExpenseKind.want,
      emoji: '🔦',
      effectLabel: 'Играть в исследователя',
      satietyDelta: 0,
      moodDelta: 11,
    ),
  ];

  static const goals = [
    GoalDef(id: 'g1', title: 'Уютный домик', cost: 180, emoji: '🏠'),
    GoalDef(id: 'g2', title: 'Костюм героя', cost: 260, emoji: '🦸'),
    GoalDef(id: 'g3', title: 'Запас лакомств', cost: 340, emoji: '🍬'),
    GoalDef(id: 'g4', title: 'Самокат', cost: 420, emoji: '🛴'),
    GoalDef(id: 'g5', title: 'Палатка во дворе', cost: 300, emoji: '⛺'),
    GoalDef(id: 'g6', title: 'Велосипед', cost: 500, emoji: '🚲'),
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
          'Нужен проезд за 15 монет. Монет мало, в копилке есть запас на домик. Что сделать?',
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
    TaskDef(
      id: 't7',
      theme: TaskTheme.budget,
      type: TaskType.choice,
      title: 'Друг зовёт в кино',
      story:
          'Билет 50 монет. На корм осталось ровно 20, в копилке цель. Как поступить?',
      reward: 18,
      options: [
        TaskOption(
          id: 'a',
          label: 'Сначала корм, кино — если останется',
          good: true,
        ),
        TaskOption(
          id: 'b',
          label: 'Купить билет, корм как-нибудь потом',
          good: false,
        ),
        TaskOption(
          id: 'c',
          label: 'Снять всю копилку на билеты двоим',
          good: false,
        ),
      ],
      explainGood:
          'Нужное не отменяют из‑за желаемого. Друга можно позвать позже, когда план позволит.',
      explainOther:
          'Если потратить последнее на кино, питомцу может не хватить еды. Копилку не ломают ради одного вечера.',
    ),
    TaskDef(
      id: 't8',
      theme: TaskTheme.purchases,
      type: TaskType.choice,
      title: 'Реклама «успей купить»',
      story:
          'На экране яркая игрушка: «осталась одна». Ты её не планировал. Что сделать?',
      reward: 16,
      options: [
        TaskOption(
          id: 'a',
          label: 'Подождать день и сверить с планом',
          good: true,
        ),
        TaskOption(
          id: 'b',
          label: 'Купить сразу, пока не забрали',
          good: false,
        ),
        TaskOption(
          id: 'c',
          label: 'Купить две, вдруг пригодится',
          good: false,
        ),
      ],
      explainGood:
          'Спешка — частый трюк. Пауза помогает отличить желание от нужного.',
      explainOther:
          '«Успей» давит, чтобы не подумать. Лишняя покупка бьёт по корму и копилке.',
    ),
    TaskDef(
      id: 't9',
      theme: TaskTheme.savings,
      type: TaskType.allocate,
      title: 'Подарок на день рождения',
      story:
          'Тебе дали 50 монет. Часть хочется сразу потратить, часть — к цели. Разложи: нужное, желаемое, копилка.',
      reward: 22,
      allocateTotal: 50,
      minNeed: 10,
      minSave: 15,
      explainGood:
          'Подарок тоже можно планировать: часть себе сейчас, часть — будущей цели.',
      explainOther:
          'Если всё уйдёт в желаемое, цель почти не двинется. Попробуй отложить хотя бы 15.',
    ),
    TaskDef(
      id: 't10',
      theme: TaskTheme.budget,
      type: TaskType.choice,
      title: 'Обед или игра в телефоне',
      story:
          'На счету 25 монет. Обед стоит 18, новая игра — 25. До вечера ещё далеко. Что выбрать?',
      reward: 18,
      options: [
        TaskOption(
          id: 'a',
          label: 'Обед сейчас, игру — когда будут лишние монеты',
          good: true,
        ),
        TaskOption(
          id: 'b',
          label: 'Игру сразу: поесть можно потом как-нибудь',
          good: false,
        ),
        TaskOption(
          id: 'c',
          label: 'Потратить всё на обед и ещё на сладость в долг',
          good: false,
        ),
      ],
      explainGood:
          'Еда — нужное. Игру можно подождать. Так ты не остаёшься голодным из‑за желания.',
      explainOther:
          'Игра не кормит. Если потратить всё на неё, на обед не хватит — это слабый план.',
    ),
    TaskDef(
      id: 't11',
      theme: TaskTheme.savings,
      type: TaskType.allocate,
      title: 'Нашёл 25 монет',
      story:
          'На прогулке нашлось 25 монет. Их не ждали. Разложи: нужное, желаемое и копилка.',
      reward: 20,
      allocateTotal: 25,
      minNeed: 5,
      minSave: 10,
      explainGood:
          'Нежданные деньги легко «сжечь». Часть в копилку — и находка работает на цель.',
      explainOther:
          'Если всё уйдёт в желаемое, находка исчезнет за минуту. Отложи хотя бы 10.',
    ),
    TaskDef(
      id: 't12',
      theme: TaskTheme.purchases,
      type: TaskType.choice,
      title: 'Три цены на воду',
      story:
          'Одинаковая вода: 8, 12 и 15 монет. Жажда есть, лишних денег мало. Что взять?',
      reward: 16,
      options: [
        TaskOption(id: 'a', label: 'За 8: та же вода, больше останется', good: true),
        TaskOption(id: 'b', label: 'За 15: бутылка блестит сильнее', good: false),
        TaskOption(id: 'c', label: 'Купить все три «на запас»', good: false),
      ],
      explainGood:
          'Сравнивать три ценника полезнее, чем два. Нужное можно закрыть дешевле.',
      explainOther:
          'Блеск не делает воду лучше. Три бутылки сразу — это уже лишнее, не жажда.',
    ),
    TaskDef(
      id: 't13',
      theme: TaskTheme.budget,
      type: TaskType.choice,
      title: 'Сломалась расчёска',
      story:
          'Расчёска сломалась. Простая стоит 12, с блёстками — 40. На счету 45, в плане — корм.',
      reward: 18,
      options: [
        TaskOption(
          id: 'a',
          label: 'Простую: уход нужен, блёстки подождут',
          good: true,
        ),
        TaskOption(
          id: 'b',
          label: 'С блёстками, корм перенесём',
          good: false,
        ),
        TaskOption(
          id: 'c',
          label: 'Купить обе, чтобы выбрать дома',
          good: false,
        ),
      ],
      explainGood:
          'Нужное закрывают простой вещью. Красивая доплата — уже желаемое.',
      explainOther:
          'Блёстки не расчёсывают лучше. Если из‑за них не хватит на корм, план сломан.',
    ),
    TaskDef(
      id: 't14',
      theme: TaskTheme.savings,
      type: TaskType.choice,
      title: 'Почти накопил',
      story:
          'До цели осталось 20 монет. Друг зовёт на двоих за мороженое за 22. Как быть?',
      reward: 22,
      options: [
        TaskOption(
          id: 'a',
          label: 'Докопить цель, мороженое — на следующей неделе',
          good: true,
        ),
        TaskOption(
          id: 'b',
          label: 'Снять копилку: цель и так почти готова',
          good: false,
        ),
        TaskOption(
          id: 'c',
          label: 'Купить мороженое в долг у друга',
          good: false,
        ),
      ],
      explainGood:
          'Когда цель рядом, её легко бросить «на чуть-чуть». Лучше дойти и потом гулять.',
      explainOther:
          '«Почти» — не «уже». Снять копилку или занять — цель снова далеко.',
    ),
    TaskDef(
      id: 't15',
      theme: TaskTheme.purchases,
      type: TaskType.allocate,
      title: 'День на рынке',
      story:
          'На рынке 35 монет. Нужны фрукты, хочется сладость, копилка ждёт. Разложи сумму.',
      reward: 20,
      allocateTotal: 35,
      minNeed: 12,
      minSave: 8,
      explainGood:
          'На рынке легко схватить всё подряд. Ты оставил и еду, и запас.',
      explainOther:
          'Яркие прилавки толкают к желаемому. Без нужного и копилки день на рынке пустой.',
    ),
    TaskDef(
      id: 't16',
      theme: TaskTheme.budget,
      type: TaskType.choice,
      title: '«Каждую неделю само»',
      story:
          'Приложение предлагает стикеры за 10 монет каждую неделю сами. Ты не просил. Что сделать?',
      reward: 19,
      options: [
        TaskOption(
          id: 'a',
          label: 'Отказаться: это незапланированный расход',
          good: true,
        ),
        TaskOption(
          id: 'b',
          label: 'Включить: «всего десять, само спишется»',
          good: false,
        ),
        TaskOption(
          id: 'c',
          label: 'Включить два набора, вдруг пригодится',
          good: false,
        ),
      ],
      explainGood:
          'Повторный платёж легко забыть. Если его не было в плане — лучше не включать.',
      explainOther:
          '«Само» значит: каждую неделю без спроса. Маленькая сумма копится в большую дыру.',
    ),
    TaskDef(
      id: 't17',
      theme: TaskTheme.purchases,
      type: TaskType.choice,
      title: 'Старая игрушка или новая',
      story:
          'Старый мячик ещё прыгает. Новый стоит 40 и блестит в витрине. Копилка на самокат.',
      reward: 17,
      options: [
        TaskOption(
          id: 'a',
          label: 'Играть старым, новый — когда будет цель или лишнее',
          good: true,
        ),
        TaskOption(
          id: 'b',
          label: 'Купить новый: старый «уже не модный»',
          good: false,
        ),
        TaskOption(
          id: 'c',
          label: 'Купить новый и выбросить старый сразу',
          good: false,
        ),
      ],
      explainGood:
          'Если вещь ещё служит, покупка — желание, не нужда. Самокат важнее блеска.',
      explainOther:
          'Модность не чинит мячик. Выбросить рабочее и купить новое бьёт по цели.',
    ),
  ];

  static const glossary = [
    ('Обязательные расходы', 'То, без чего питомцу плохо: еда и уход.'),
    ('Необязательные расходы', 'Приятное, но можно подождать: игрушка или тортик.'),
    ('Накопления', 'Деньги, которые ты отложил на цель и не тратишь просто так.'),
    ('План', 'Как ты заранее делишь деньги: нужное, желаемое, копилка.'),
    ('Факт', 'Как ты на самом деле потратил деньги за неделю.'),
    ('Игровая валюта', 'Монеты только в игре. Их нельзя обменять на настоящие деньги.'),
    ('Нужное', 'Еда, вода, уход — то, без чего питомец слабеет.'),
    ('Желаемое', 'Игрушки и вкусности. Их можно перенести на потом.'),
    ('Цель', 'Большая покупка из копилки: домик, костюм, запас, самокат.'),
    ('Неделя', 'Игровой период: сначала план, потом покупки и копилка.'),
    ('Демо-режим', 'Недели идут подряд, без ожидания настоящих дней. Это для учёбы.'),
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
