import 'package:finpet/domain/content/catalog.dart';
import 'package:finpet/domain/models.dart';

abstract final class Economy {
  static const minNeedForPeriod = 15;

  /// Сытость −1 раз в 5 часов, настроение −1 раз в 8.
  /// За ночь 8–12 ч уходит 1–2 сытости и 1 настроение — утром ещё в порядке.
  static const satietyHoursPerPoint = 5;
  static const moodHoursPerPoint = 8;

  static int clampStat(int value) => value.clamp(15, 100);

  static GameProfile settleNeeds(GameProfile profile, {DateTime? now}) {
    final pet = profile.pet;
    final at = now ?? DateTime.now();
    if (pet == null) {
      return profile.needsAt == null
          ? profile
          : profile.copyWith(clearNeedsAt: true);
    }
    final raw = profile.needsAt;
    if (raw == null || raw.isEmpty) {
      return profile.copyWith(needsAt: at.toIso8601String());
    }
    final from = DateTime.tryParse(raw);
    if (from == null || at.isBefore(from)) {
      return profile.copyWith(needsAt: at.toIso8601String());
    }
    final hours = at.difference(from).inHours;
    final satietyDrop = hours ~/ satietyHoursPerPoint;
    final moodDrop = hours ~/ moodHoursPerPoint;
    if (satietyDrop == 0 && moodDrop == 0) return profile;

    var consumed = 0;
    if (satietyDrop > 0) consumed = satietyDrop * satietyHoursPerPoint;
    if (moodDrop > 0) {
      final moodHours = moodDrop * moodHoursPerPoint;
      if (moodHours > consumed) consumed = moodHours;
    }

    final satiety = clampStat(pet.satiety - satietyDrop);
    final mood = clampStat(pet.mood - moodDrop);
    var reason = pet.moodReason;
    if (satiety < 45) {
      reason = '${pet.name} проголодался. Загляни в нужное в магазине.';
    } else if (mood < 55) {
      reason = '${pet.name} скучает. Можно поиграть или купить что-то приятное.';
    } else if (satietyDrop >= 2 || moodDrop >= 2) {
      reason = '${pet.name} чуть проголодался — это нормально.';
    }

    return profile.copyWith(
      pet: pet.copyWith(satiety: satiety, mood: mood, moodReason: reason),
      needsAt: from.add(Duration(hours: consumed)).toIso8601String(),
    );
  }

  static int stageFor(int growth) {
    if (growth >= 6) return 3;
    if (growth >= 3) return 2;
    return 1;
  }

  static GameProfile withLedger(
    GameProfile profile, {
    required int amount,
    required bool isEarn,
    required String source,
    required String title,
  }) {
    final entry = LedgerEntry(
      amount: amount,
      isEarn: isEarn,
      source: source,
      title: title,
      createdAt: DateTime.now().toIso8601String(),
    );
    return profile.copyWith(
      ledger: [entry, ...profile.ledger].take(40).toList(),
    );
  }

  static EngineResult startNewPlayer({
    required String playerName,
    required String petName,
    required PetLook look,
  }) {
    final pet = Pet(
      name: petName.trim(),
      look: look,
      satiety: 70,
      mood: 78,
      stage: 1,
      growthPoints: 0,
      moodReason: '${petName.trim()} только появился и ждёт заботы.',
    );
    var profile = GameProfile.empty().copyWith(
      playerName: playerName.trim(),
      seenIntro: true,
      demoMode: true,
      pet: pet,
      needsAt: DateTime.now().toIso8601String(),
      coins: Catalog.startIncome,
      savings: 0,
      goalId: Catalog.goals.first.id,
      periodIndex: 1,
      phase: PeriodPhase.planning,
      lastMessage:
          'Стартовые монеты: ${Catalog.startIncome}. Сначала составь план на неделю.',
      lastNextStep: 'Открой «План» и разложи деньги на нужное, желаемое и копилку.',
    );
    profile = withLedger(
      profile,
      amount: Catalog.startIncome,
      isEarn: true,
      source: 'Доход',
      title: 'Стартовые монеты',
    );
    return EngineResult(
      profile: profile,
      ok: true,
      message: profile.lastMessage,
      nextStep: profile.lastNextStep,
    );
  }

  static EngineResult confirmPlan(GameProfile profile, BudgetSplit plan) {
    if (profile.phase != PeriodPhase.planning) {
      return EngineResult(
        profile: profile,
        ok: false,
        message: 'План этой недели уже подтверждён.',
        nextStep: 'Можно покупать, копить и делать задания.',
      );
    }
    if (plan.need < 0 || plan.want < 0 || plan.save < 0) {
      return EngineResult(
        profile: profile,
        ok: false,
        message: 'Суммы не могут быть меньше нуля.',
        nextStep: 'Поставь 0, если в эту часть пока ничего не кладёшь.',
      );
    }
    if (plan.total > profile.coins) {
      return EngineResult(
        profile: profile,
        ok: false,
        message:
            'В плане ${plan.total} монет, а доступно только ${profile.coins}.',
        nextStep: 'Уменьши одну из частей, пока остаток не станет 0 или больше.',
      );
    }
    final next = profile.copyWith(
      plan: plan,
      phase: PeriodPhase.active,
      lastMessage:
          'План сохранён: нужное ${plan.need}, желаемое ${plan.want}, копилка ${plan.save}. Остаток ${profile.coins - plan.total} можно не тратить.',
      lastNextStep: 'Купи нужное, отложи в копилку и попробуй задание.',
    );
    return EngineResult(
      profile: next,
      ok: true,
      message: next.lastMessage,
      nextStep: next.lastNextStep,
    );
  }

  static EngineResult buy(GameProfile profile, ShopItem item) {
    if (profile.phase != PeriodPhase.active) {
      return EngineResult(
        profile: profile,
        ok: false,
        message: 'Сначала составь и подтверди план на неделю.',
        nextStep: 'Открой «План».',
      );
    }
    if (profile.coins < item.price) {
      final missing = item.price - profile.coins;
      return EngineResult(
        profile: profile,
        ok: false,
        message:
            'Не хватает $missing монет на «${item.name}». В минус уходить нельзя.',
        nextStep:
            'Сделай задание, отложи желаемое или купи более дешёвое нужное.',
      );
    }
    final pet = profile.pet;
    if (pet == null) {
      return EngineResult(
        profile: profile,
        ok: false,
        message: 'Сначала создай питомца.',
        nextStep: '',
      );
    }
    final spentNeed =
        profile.spentNeed + (item.kind == ExpenseKind.need ? item.price : 0);
    final spentWant =
        profile.spentWant + (item.kind == ExpenseKind.want ? item.price : 0);
    final updatedPet = pet.copyWith(
      satiety: clampStat(pet.satiety + item.satietyDelta),
      mood: clampStat(pet.mood + item.moodDelta),
      moodReason: item.kind == ExpenseKind.need
          ? '${pet.name} получил нужное: ${item.name}.'
          : '${pet.name} рад желаемому: ${item.name}. Но нужное всё равно важнее.',
    );
    var next = profile.copyWith(
      coins: profile.coins - item.price,
      pet: updatedPet,
      spentNeed: spentNeed,
      spentWant: spentWant,
      lastMessage:
          '−${item.price} монет. ${item.effectLabel}. Баланс: ${profile.coins - item.price}.',
      lastNextStep: item.kind == ExpenseKind.need
          ? 'Если план позволяет, отложи часть в копилку.'
          : 'Проверь, не съело ли желаемое план на нужное.',
    );
    next = withLedger(
      next,
      amount: item.price,
      isEarn: false,
      source: item.kindLabel,
      title: 'Покупка: ${item.name}',
    );
    return EngineResult(
      profile: next,
      ok: true,
      message: next.lastMessage,
      nextStep: next.lastNextStep,
    );
  }

  static EngineResult transferToSavings(GameProfile profile, int amount) {
    if (amount <= 0) {
      return EngineResult(
        profile: profile,
        ok: false,
        message: 'Нужно отложить хотя бы 1 монету.',
        nextStep: 'Выбери сумму поменьше или заработай ещё.',
      );
    }
    if (profile.phase != PeriodPhase.active) {
      return EngineResult(
        profile: profile,
        ok: false,
        message: 'Сначала подтверди план.',
        nextStep: 'Открой «План».',
      );
    }
    if (profile.coins < amount) {
      return EngineResult(
        profile: profile,
        ok: false,
        message: 'Не хватает монет. В минус нельзя.',
        nextStep: 'Отложи меньшую сумму или выполни задание.',
      );
    }
    final goal = Catalog.goalById(profile.goalId);
    var next = profile.copyWith(
      coins: profile.coins - amount,
      savings: profile.savings + amount,
      savedThisPeriod: profile.savedThisPeriod + amount,
      lastMessage:
          'В копилку +$amount. Всего накоплено ${profile.savings + amount}'
          '${goal == null ? '.' : ' из ${goal.cost} на «${goal.title}».'}',
      lastNextStep: 'Так цель становится ближе. Можно вернуться на главную.',
    );
    next = withLedger(
      next,
      amount: amount,
      isEarn: false,
      source: 'Накопления',
      title: 'Отложено в копилку',
    );
    return EngineResult(
      profile: next,
      ok: true,
      message: next.lastMessage,
      nextStep: next.lastNextStep,
    );
  }

  static EngineResult withdrawSavings(GameProfile profile, int amount) {
    if (amount <= 0) {
      return EngineResult(
        profile: profile,
        ok: false,
        message: 'Сумма снятия должна быть больше нуля.',
        nextStep: '',
      );
    }
    if (profile.savings < amount) {
      return EngineResult(
        profile: profile,
        ok: false,
        message: 'В копилке только ${profile.savings} монет.',
        nextStep: 'Сними меньше или оставь копилку для цели.',
      );
    }
    final goal = Catalog.goalById(profile.goalId);
    final left = profile.savings - amount;
    String delayNote = '';
    if (goal != null && amount > 0) {
      final remain = (goal.cost - left).clamp(0, goal.cost);
      delayNote = remain == 0
          ? ''
          : ' До цели останется $remain. Срок станет длиннее.';
    }
    var next = profile.copyWith(
      coins: profile.coins + amount,
      savings: left,
      lastMessage:
          'С копилки снято $amount. Накопления теперь $left.$delayNote',
      lastNextStep: 'Потрать эти монеты только если это правда нужно.',
    );
    next = withLedger(
      next,
      amount: amount,
      isEarn: true,
      source: 'Накопления',
      title: 'Снято с копилки',
    );
    return EngineResult(
      profile: next,
      ok: true,
      message: next.lastMessage,
      nextStep: next.lastNextStep,
    );
  }

  static EngineResult completeTask(
    GameProfile profile,
    TaskDef task,
    TaskAnswer answer,
  ) {
    if (profile.doneTaskIds.contains(task.id)) {
      return EngineResult(
        profile: profile,
        ok: false,
        message: 'Это задание уже пройдено.',
        nextStep: 'Выбери другое или открой магазин.',
      );
    }
    final good = _isGoodAnswer(task, answer);
    final reward = good ? task.reward : (task.reward / 2).round().clamp(5, task.reward);
    final message = good ? task.explainGood : task.explainOther;
    var next = profile.copyWith(
      coins: profile.coins + reward,
      doneTaskIds: [...profile.doneTaskIds, task.id],
      lastMessage: '$message  +$reward монет. Баланс: ${profile.coins + reward}.',
      lastNextStep: good
          ? 'Вернись на главную или открой покупки.'
          : 'Ошибку можно поправить: составь более аккуратный план и закрой нужное.',
    );
    next = withLedger(
      next,
      amount: reward,
      isEarn: true,
      source: 'Задание',
      title: task.title,
    );
    return EngineResult(
      profile: next,
      ok: true,
      message: next.lastMessage,
      nextStep: next.lastNextStep,
    );
  }

  static bool _isGoodAnswer(TaskDef task, TaskAnswer answer) {
    if (task.type == TaskType.allocate) {
      final need = answer.need ?? 0;
      final want = answer.want ?? 0;
      final save = answer.save ?? 0;
      if (need + want + save != task.allocateTotal) return false;
      if (task.minNeed != null && need < task.minNeed!) return false;
      if (task.minSave != null && save < task.minSave!) return false;
      return true;
    }
    final option = task.options.where((e) => e.id == answer.optionId);
    if (option.isEmpty) return false;
    return option.first.good;
  }

  static EngineResult closePeriod(GameProfile profile) {
    final plan = profile.plan;
    if (plan == null || profile.phase != PeriodPhase.active) {
      return EngineResult(
        profile: profile,
        ok: false,
        message: 'Сначала подтверди план и поиграй эту неделю.',
        nextStep: 'Открой «План».',
      );
    }
    final pet = profile.pet;
    if (pet == null) {
      return EngineResult(
        profile: profile,
        ok: false,
        message: 'Нет питомца.',
        nextStep: '',
      );
    }

    final fact = BudgetSplit(
      need: profile.spentNeed,
      want: profile.spentWant,
      save: profile.savedThisPeriod,
    );

    var growth = pet.growthPoints;
    var satiety = pet.satiety;
    var mood = pet.mood;
    final notes = <String>[];

    if (fact.need >= minNeedForPeriod) {
      growth += 1;
      satiety = clampStat(satiety + 8);
      notes.add('Нужное закрыто.');
    } else {
      satiety = clampStat(satiety - 12);
      mood = clampStat(mood - 6);
      notes.add('Нужного не хватило — в следующем плане положи больше на еду и уход.');
    }

    if (fact.save > 0) {
      growth += 1;
      mood = clampStat(mood + 6);
      notes.add('Ты копил. Цель ближе.');
    } else {
      notes.add('В копилку ничего не ушло. Можно исправить на следующей неделе.');
    }

    if (_planMatched(plan, fact)) {
      growth += 1;
      mood = clampStat(mood + 8);
      notes.add('Факт похож на план — ты держал слово самому себе.');
    } else {
      notes.add('Факт разошёлся с планом. В следующий раз сверяй покупки с планом.');
    }

    final stage = stageFor(growth);
    final stageChanged = stage != pet.stage;
    if (stageChanged) {
      notes.add('Новая стадия: ${Pet(
        name: pet.name,
        look: pet.look,
        satiety: satiety,
        mood: mood,
        stage: stage,
        growthPoints: growth,
        moodReason: '',
      ).stageLabel}.');
    }

    final note = notes.join(' ');
    final summary = PeriodSummary(
      index: profile.periodIndex,
      plan: plan,
      fact: fact,
      income: profile.periodIndex == 1 ? Catalog.startIncome : Catalog.periodIncome,
      note: note,
    );

    final updatedPet = pet.copyWith(
      satiety: satiety,
      mood: mood,
      stage: stage,
      growthPoints: growth,
      moodReason: note,
    );

    var next = profile.copyWith(
      pet: updatedPet,
      coins: profile.coins + Catalog.periodIncome,
      periodIndex: profile.periodIndex + 1,
      phase: PeriodPhase.planning,
      clearPlan: true,
      spentNeed: 0,
      spentWant: 0,
      savedThisPeriod: 0,
      minigameCoinsThisPeriod: 0,
      history: [...profile.history, summary],
      lastMessage:
          'Неделя ${profile.periodIndex} закрыта. $note  Монеты +${Catalog.periodIncome}. Баланс: ${profile.coins + Catalog.periodIncome}.',
      lastNextStep: 'Составь новый план. Так питомец растёт от серии решений, не от одной покупки.',
    );
    next = withLedger(
      next,
      amount: Catalog.periodIncome,
      isEarn: true,
      source: 'Доход',
      title: 'Монеты за новую неделю',
    );
    return EngineResult(
      profile: next,
      ok: true,
      message: next.lastMessage,
      nextStep: next.lastNextStep,
    );
  }

  static bool _planMatched(BudgetSplit plan, BudgetSplit fact) {
    bool close(int a, int b) {
      final diff = (a - b).abs();
      return diff <= 10 || diff <= (a * 0.35).round();
    }

    return close(plan.need, fact.need) &&
        close(plan.want, fact.want) &&
        close(plan.save, fact.save);
  }

  static const maxMinigameCoinsPerPeriod = 80;

  static EngineResult rewardMinigame(
    GameProfile profile, {
    required String title,
    required int requested,
  }) {
    if (profile.pet == null) {
      return EngineResult(
        profile: profile,
        ok: false,
        message: 'Сначала создай питомца.',
        nextStep: 'Вернись к созданию питомца.',
      );
    }
    final room =
        (maxMinigameCoinsPerPeriod - profile.minigameCoinsThisPeriod).clamp(0, maxMinigameCoinsPerPeriod);
    final coins = requested.clamp(0, 80).clamp(0, room);
    final pet = profile.pet!;
    final nextPet = pet.copyWith(mood: clampStat(pet.mood + 6));
    var next = profile.copyWith(
      pet: nextPet,
      coins: profile.coins + coins,
      gamesPlayed: profile.gamesPlayed + 1,
      minigameCoinsThisPeriod: profile.minigameCoinsThisPeriod + coins,
      lastMessage: coins == 0
          ? 'Игра пройдена. На этой неделе монет за игры уже максимум — можно играть просто так.'
          : '$title: +$coins монет. Баланс: ${profile.coins + coins}.',
      lastNextStep: 'Монеты копятся к плану, покупкам и копилке.',
    );
    if (coins > 0) {
      next = withLedger(
        next,
        amount: coins,
        isEarn: true,
        source: 'Игра',
        title: title,
      );
    }
    return EngineResult(
      profile: next,
      ok: true,
      message: next.lastMessage,
      nextStep: next.lastNextStep,
    );
  }

  static String goalEta(GameProfile profile) {
    final goal = Catalog.goalById(profile.goalId);
    if (goal == null) return 'Выбери цель.';
    final left = (goal.cost - profile.savings).clamp(0, goal.cost);
    if (left == 0) return 'Цель собрана!';
    final samples = profile.history.map((e) => e.fact.save).where((e) => e > 0);
    final avg = samples.isEmpty
        ? (profile.savedThisPeriod > 0 ? profile.savedThisPeriod : 20)
        : (samples.reduce((a, b) => a + b) / samples.length).round();
    if (avg <= 0) return 'Откладывай регулярно — тогда появится срок.';
    final weeks = (left / avg).ceil();
    return 'Если класть около $avg монет в неделю, цель через $weeks нед.';
  }
}
