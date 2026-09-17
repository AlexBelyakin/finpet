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
