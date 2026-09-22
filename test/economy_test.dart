import 'package:finpet/domain/content/catalog.dart';
import 'package:finpet/domain/economy/engine.dart';
import 'package:finpet/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = Economy.startNewPlayer(
    playerName: 'Саша',
    petName: 'Финни',
    look: Catalog.looks.first,
  ).profile;

  test('новый игрок ещё не видел подсказки дома', () {
    expect(start.seenHomeHints, isFalse);
  });

  test('план не больше баланса', () {
    final result = Economy.confirmPlan(
      start,
      BudgetSplit(need: 80, want: 80, save: 80),
    );
    expect(result.ok, isFalse);
    expect(result.profile.coins, start.coins);
  });

  test('покупка без плана запрещена', () {
    final result = Economy.buy(start, Catalog.itemById('n1'));
    expect(result.ok, isFalse);
  });

  test('нельзя уйти в минус', () {
    var p = Economy.confirmPlan(
      start,
      const BudgetSplit(need: 40, want: 20, save: 20),
    ).profile;
    p = p.copyWith(coins: 5);
    final result = Economy.buy(p, Catalog.itemById('n1'));
    expect(result.ok, isFalse);
    expect(result.profile.coins, 5);
  });

  test('покупка списывает и меняет питомца', () {
    final planned = Economy.confirmPlan(
      start,
      const BudgetSplit(need: 40, want: 20, save: 20),
    ).profile;
    final result = Economy.buy(planned, Catalog.itemById('n1'));
    expect(result.ok, isTrue);
    expect(result.profile.coins, planned.coins - 20);
    expect(result.profile.spentNeed, 20);
    expect(result.profile.pet!.satiety, greaterThan(planned.pet!.satiety));
  });

  test('закрытие недели даёт доход и не обнуляет копилку', () {
    var p = Economy.confirmPlan(
      start,
      const BudgetSplit(need: 40, want: 20, save: 20),
    ).profile;
    p = Economy.buy(p, Catalog.itemById('n1')).profile;
    p = Economy.transferToSavings(p, 20).profile;
    final closed = Economy.closePeriod(p);
    expect(closed.ok, isTrue);
    expect(closed.profile.savings, 20);
    expect(closed.profile.coins, p.coins + Catalog.periodIncome);
    expect(closed.profile.periodIndex, 2);
    expect(closed.profile.phase, PeriodPhase.planning);
  });

  test('за ночь шкалы почти не падают', () {
    final evening = DateTime(2026, 9, 21, 21);
    final morning = DateTime(2026, 9, 22, 8);
    final p = start.copyWith(
      needsAt: evening.toIso8601String(),
      pet: start.pet!.copyWith(satiety: 70, mood: 78),
    );
    final next = Economy.settleNeeds(p, now: morning);
    expect(70 - next.pet!.satiety, lessThanOrEqualTo(3));
    expect(78 - next.pet!.mood, lessThanOrEqualTo(2));
    expect(next.pet!.satiety, greaterThanOrEqualTo(65));
    expect(next.pet!.mood, greaterThanOrEqualTo(75));
  });

  test('старое сохранение не обваливает шкалы сразу', () {
    final json = start.toJson()..remove('needsAt');
    final loaded = GameProfile.fromJson(json);
    final next = Economy.settleNeeds(
      loaded,
      now: DateTime(2026, 9, 22, 10),
    );
    expect(next.pet!.satiety, start.pet!.satiety);
    expect(next.pet!.mood, start.pet!.mood);
    expect(next.needsAt, isNotNull);
  });

  test('за трое суток сытость ещё не в плохом диапазоне', () {
    final from = DateTime(2026, 9, 18, 10);
    final now = DateTime(2026, 9, 21, 10);
    final p = start.copyWith(
      needsAt: from.toIso8601String(),
      pet: start.pet!.copyWith(satiety: 70, mood: 78),
    );
    final next = Economy.settleNeeds(p, now: now);
    expect(next.pet!.satiety, 70 - (72 ~/ Economy.satietyHoursPerPoint));
    expect(next.pet!.mood, 78 - (72 ~/ Economy.moodHoursPerPoint));
    expect(next.pet!.satiety, greaterThanOrEqualTo(50));
    expect(next.pet!.mood, greaterThanOrEqualTo(60));
  });

  test('мини-игра даёт монеты и не ломает копилку', () {
    final result = Economy.rewardMinigame(
      start,
      title: 'Игра «Надо или хочу?»',
      requested: 24,
    );
    expect(result.ok, isTrue);
    expect(result.profile.coins, start.coins + 24);
    expect(result.profile.gamesPlayed, 1);
    expect(result.profile.savings, start.savings);
  });
}
