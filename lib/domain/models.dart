enum PetBody { finni, nori }

enum PetSpecies { cat, fox, bird }

enum PetColor { natural, peach, mint, sky, wave, lilac }

enum PetPlace {
  room,
  room2;

  String get label => switch (this) {
        PetPlace.room => 'Теремок на лужайке',
        PetPlace.room2 => 'Усадьба у сада',
      };

  String get blurb => switch (this) {
        PetPlace.room => 'Маленький домик среди холмов. Здесь тепло и спокойно.',
        PetPlace.room2 => 'Светлый дом рядом с тихим садом.',
      };
}

enum PeriodPhase { planning, active, review }

enum ExpenseKind { need, want }

enum TaskTheme { budget, savings, purchases }

enum TaskType { allocate, choice }

class PetLook {
  const PetLook({
    this.body = PetBody.finni,
    required this.species,
    required this.color,
  });

  final PetBody body;
  final PetSpecies species;
  final PetColor color;

  String get id => '${body.name}_${species.name}_${color.name}';

  String get bodyLabel => switch (body) {
        PetBody.finni => 'Финни',
        PetBody.nori => 'Нори',
      };

  String get speciesLabel => bodyLabel;

  bool get paints => color != PetColor.natural;

  String get colorLabel => switch (color) {
        PetColor.natural => 'Как есть',
        PetColor.peach => 'Персик',
        PetColor.mint => 'Мята',
        PetColor.sky => 'Небо',
        PetColor.wave => 'Волна',
        PetColor.lilac => 'Сирень',
      };

  Map<String, dynamic> toJson() => {
        'body': body.name,
        'species': species.name,
        'color': color.name,
      };

  factory PetLook.fromJson(Map<String, dynamic> json) => PetLook(
        body: json['body'] == null
            ? PetBody.finni
            : PetBody.values.byName(json['body'] as String),
        species: PetSpecies.values.byName(json['species'] as String),
        color: PetColor.values.asNameMap()[json['color'] as String?] ??
            PetColor.peach,
      );
}

class Pet {
  const Pet({
    required this.name,
    required this.look,
    required this.satiety,
    required this.mood,
    required this.stage,
    required this.growthPoints,
    required this.moodReason,
  });

  final String name;
  final PetLook look;
  final int satiety;
  final int mood;
  final int stage;
  final int growthPoints;
  final String moodReason;

  String get stageLabel => switch (stage) {
        1 => 'Малыш',
        2 => 'Растёт',
        _ => 'Настоящий друг',
      };

  Pet copyWith({
    String? name,
    PetLook? look,
    int? satiety,
    int? mood,
    int? stage,
    int? growthPoints,
    String? moodReason,
  }) {
    return Pet(
      name: name ?? this.name,
      look: look ?? this.look,
      satiety: satiety ?? this.satiety,
      mood: mood ?? this.mood,
      stage: stage ?? this.stage,
      growthPoints: growthPoints ?? this.growthPoints,
      moodReason: moodReason ?? this.moodReason,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'look': look.toJson(),
        'satiety': satiety,
        'mood': mood,
        'stage': stage,
        'growthPoints': growthPoints,
        'moodReason': moodReason,
      };

  factory Pet.fromJson(Map<String, dynamic> json) => Pet(
        name: json['name'] as String,
        look: PetLook.fromJson(json['look'] as Map<String, dynamic>),
        satiety: json['satiety'] as int,
        mood: json['mood'] as int,
        stage: json['stage'] as int,
        growthPoints: json['growthPoints'] as int,
        moodReason: json['moodReason'] as String,
      );
}

class BudgetSplit {
  const BudgetSplit({
    required this.need,
    required this.want,
    required this.save,
  });

  final int need;
  final int want;
  final int save;

  int get total => need + want + save;

  BudgetSplit copyWith({int? need, int? want, int? save}) {
    return BudgetSplit(
      need: need ?? this.need,
      want: want ?? this.want,
      save: save ?? this.save,
    );
  }

  Map<String, dynamic> toJson() => {
        'need': need,
        'want': want,
        'save': save,
      };

  factory BudgetSplit.fromJson(Map<String, dynamic> json) => BudgetSplit(
        need: json['need'] as int,
        want: json['want'] as int,
        save: json['save'] as int,
      );
}

class LedgerEntry {
  const LedgerEntry({
    required this.amount,
    required this.isEarn,
    required this.source,
    required this.title,
    required this.createdAt,
  });

  final int amount;
  final bool isEarn;
  final String source;
  final String title;
  final String createdAt;

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'isEarn': isEarn,
        'source': source,
        'title': title,
        'createdAt': createdAt,
      };

  factory LedgerEntry.fromJson(Map<String, dynamic> json) => LedgerEntry(
        amount: json['amount'] as int,
        isEarn: json['isEarn'] as bool,
        source: json['source'] as String,
        title: json['title'] as String,
        createdAt: json['createdAt'] as String,
      );
}

class PeriodSummary {
  const PeriodSummary({
    required this.index,
    required this.plan,
    required this.fact,
    required this.income,
    required this.note,
  });

  final int index;
  final BudgetSplit plan;
  final BudgetSplit fact;
  final int income;
  final String note;

  Map<String, dynamic> toJson() => {
        'index': index,
        'plan': plan.toJson(),
        'fact': fact.toJson(),
        'income': income,
        'note': note,
      };

  factory PeriodSummary.fromJson(Map<String, dynamic> json) => PeriodSummary(
        index: json['index'] as int,
        plan: BudgetSplit.fromJson(json['plan'] as Map<String, dynamic>),
        fact: BudgetSplit.fromJson(json['fact'] as Map<String, dynamic>),
        income: json['income'] as int,
        note: json['note'] as String,
      );
}

class ShopItem {
  const ShopItem({
    required this.id,
    required this.name,
    required this.price,
    required this.kind,
    required this.emoji,
    required this.effectLabel,
    required this.satietyDelta,
    required this.moodDelta,
  });

  final String id;
  final String name;
  final int price;
  final ExpenseKind kind;
  final String emoji;
  final String effectLabel;
  final int satietyDelta;
  final int moodDelta;

  String get kindLabel => kind == ExpenseKind.need ? 'Нужное' : 'Желаемое';
}

class GoalDef {
  const GoalDef({
    required this.id,
    required this.title,
    required this.cost,
    required this.emoji,
  });

  final String id;
  final String title;
  final int cost;
  final String emoji;
}

class TaskOption {
  const TaskOption({
    required this.id,
    required this.label,
    required this.good,
  });

  final String id;
  final String label;
  final bool good;
}

class TaskDef {
  const TaskDef({
    required this.id,
    required this.theme,
    required this.type,
    required this.title,
    required this.story,
    required this.reward,
    required this.explainGood,
    required this.explainOther,
    this.allocateTotal,
    this.minNeed,
    this.minSave,
    this.options = const [],
  });

  final String id;
  final TaskTheme theme;
  final TaskType type;
  final String title;
  final String story;
  final int reward;
  final String explainGood;
  final String explainOther;
  final int? allocateTotal;
  final int? minNeed;
  final int? minSave;
  final List<TaskOption> options;

  String get themeLabel => switch (theme) {
        TaskTheme.budget => 'План',
        TaskTheme.savings => 'Копилка',
        TaskTheme.purchases => 'Покупки',
      };
}

class TaskAnswer {
  const TaskAnswer({this.optionId, this.need, this.want, this.save});

  final String? optionId;
  final int? need;
  final int? want;
  final int? save;
}

class GameProfile {
  const GameProfile({
    required this.playerName,
    required this.seenIntro,
    this.seenHomeHints = false,
    required this.demoMode,
    this.pet,
    this.place,
    required this.coins,
    required this.savings,
    this.goalId,
    required this.periodIndex,
    required this.phase,
    this.plan,
    required this.spentNeed,
    required this.spentWant,
    required this.savedThisPeriod,
    required this.doneTaskIds,
    required this.ledger,
    required this.history,
    required this.lastMessage,
    required this.lastNextStep,
    this.gamesPlayed = 0,
    this.minigameCoinsThisPeriod = 0,
    this.needsAt,
  });

  final String playerName;
  final bool seenIntro;
  final bool seenHomeHints;
  final bool demoMode;
  final Pet? pet;
  final PetPlace? place;
  final int coins;
  final int savings;
  final String? goalId;
  final int periodIndex;
  final PeriodPhase phase;
  final BudgetSplit? plan;
  final int spentNeed;
  final int spentWant;
  final int savedThisPeriod;
  final List<String> doneTaskIds;
  final List<LedgerEntry> ledger;
  final List<PeriodSummary> history;
  final String lastMessage;
  final String lastNextStep;
  final int gamesPlayed;
  final int minigameCoinsThisPeriod;
  /// Когда в последний раз учли убывание сытости и настроения.
  final String? needsAt;

  static const room2TasksNeeded = 5;

  bool get room2Unlocked => doneTaskIds.length >= room2TasksNeeded;

  bool canUsePlace(PetPlace place) =>
      place == PetPlace.room || room2Unlocked;

  static GameProfile empty() {
    return const GameProfile(
      playerName: '',
      seenIntro: false,
      demoMode: true,
      coins: 0,
      savings: 0,
      periodIndex: 1,
      phase: PeriodPhase.planning,
      spentNeed: 0,
      spentWant: 0,
      savedThisPeriod: 0,
      doneTaskIds: [],
      ledger: [],
      history: [],
      lastMessage: '',
      lastNextStep: '',
      gamesPlayed: 0,
      minigameCoinsThisPeriod: 0,
    );
  }

  GameProfile copyWith({
    String? playerName,
    bool? seenIntro,
    bool? demoMode,
    Pet? pet,
    bool? seenHomeHints,
    bool clearPet = false,
    PetPlace? place,
    bool clearPlace = false,
    int? coins,
    int? savings,
    String? goalId,
    bool clearGoal = false,
    int? periodIndex,
    PeriodPhase? phase,
    BudgetSplit? plan,
    bool clearPlan = false,
    int? spentNeed,
    int? spentWant,
    int? savedThisPeriod,
    List<String>? doneTaskIds,
    List<LedgerEntry>? ledger,
    List<PeriodSummary>? history,
    String? lastMessage,
    String? lastNextStep,
    int? gamesPlayed,
    int? minigameCoinsThisPeriod,
    String? needsAt,
    bool clearNeedsAt = false,
  }) {
    return GameProfile(
      playerName: playerName ?? this.playerName,
      seenIntro: seenIntro ?? this.seenIntro,
      seenHomeHints: seenHomeHints ?? this.seenHomeHints,
      demoMode: demoMode ?? this.demoMode,
      pet: clearPet ? null : (pet ?? this.pet),
      place: clearPlace ? null : (place ?? this.place),
      coins: coins ?? this.coins,
      savings: savings ?? this.savings,
      goalId: clearGoal ? null : (goalId ?? this.goalId),
      periodIndex: periodIndex ?? this.periodIndex,
      phase: phase ?? this.phase,
      plan: clearPlan ? null : (plan ?? this.plan),
      spentNeed: spentNeed ?? this.spentNeed,
      spentWant: spentWant ?? this.spentWant,
      savedThisPeriod: savedThisPeriod ?? this.savedThisPeriod,
      doneTaskIds: doneTaskIds ?? this.doneTaskIds,
      ledger: ledger ?? this.ledger,
      history: history ?? this.history,
      lastMessage: lastMessage ?? this.lastMessage,
      lastNextStep: lastNextStep ?? this.lastNextStep,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      minigameCoinsThisPeriod:
          minigameCoinsThisPeriod ?? this.minigameCoinsThisPeriod,
      needsAt: clearNeedsAt ? null : (needsAt ?? this.needsAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'playerName': playerName,
        'seenIntro': seenIntro,
        'demoMode': demoMode,
        'pet': pet?.toJson(),
        'seenHomeHints': seenHomeHints,
        'place': place?.name,
        'coins': coins,
        'savings': savings,
        'goalId': goalId,
        'periodIndex': periodIndex,
        'phase': phase.name,
        'plan': plan?.toJson(),
        'spentNeed': spentNeed,
        'spentWant': spentWant,
        'savedThisPeriod': savedThisPeriod,
        'doneTaskIds': doneTaskIds,
        'ledger': ledger.map((e) => e.toJson()).toList(),
        'history': history.map((e) => e.toJson()).toList(),
        'lastMessage': lastMessage,
        'lastNextStep': lastNextStep,
        'gamesPlayed': gamesPlayed,
        'minigameCoinsThisPeriod': minigameCoinsThisPeriod,
        'needsAt': needsAt,
      };

  factory GameProfile.fromJson(Map<String, dynamic> json) {
    return GameProfile(
      playerName: json['playerName'] as String? ?? '',
      seenIntro: json['seenIntro'] as bool? ?? false,
      seenHomeHints: json['seenHomeHints'] as bool? ?? json['pet'] != null,
      demoMode: json['demoMode'] as bool? ?? true,
      pet: json['pet'] == null
          ? null
          : Pet.fromJson(json['pet'] as Map<String, dynamic>),
      place: _placeFromJson(json),
      coins: json['coins'] as int? ?? 0,
      savings: json['savings'] as int? ?? 0,
      goalId: json['goalId'] as String?,
      periodIndex: json['periodIndex'] as int? ?? 1,
      phase: PeriodPhase.values.byName(
        json['phase'] as String? ?? PeriodPhase.planning.name,
      ),
      plan: json['plan'] == null
          ? null
          : BudgetSplit.fromJson(json['plan'] as Map<String, dynamic>),
      spentNeed: json['spentNeed'] as int? ?? 0,
      spentWant: json['spentWant'] as int? ?? 0,
      savedThisPeriod: json['savedThisPeriod'] as int? ?? 0,
      doneTaskIds: List<String>.from(json['doneTaskIds'] as List? ?? const []),
      ledger: (json['ledger'] as List? ?? const [])
          .map((e) => LedgerEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      history: (json['history'] as List? ?? const [])
          .map((e) => PeriodSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastMessage: json['lastMessage'] as String? ?? '',
      lastNextStep: json['lastNextStep'] as String? ?? '',
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      minigameCoinsThisPeriod: json['minigameCoinsThisPeriod'] as int? ?? 0,
      needsAt: json['needsAt'] as String?,
    );
  }
}

PetPlace? _placeFromJson(Map<String, dynamic> json) {
  final raw = json['place'] as String?;
  if (raw != null) {
    if (raw == 'yard' || raw == 'room2') return PetPlace.room2;
    for (final value in PetPlace.values) {
      if (value.name == raw) return value;
    }
  }
  if (json['pet'] != null) return PetPlace.room;
  return null;
}

class EngineResult {
  const EngineResult({
    required this.profile,
    required this.ok,
    required this.message,
    required this.nextStep,
  });

  final GameProfile profile;
  final bool ok;
  final String message;
  final String nextStep;
}
