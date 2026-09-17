import 'package:flutter/foundation.dart';

import 'package:finpet/domain/content/catalog.dart';
import 'package:finpet/data/storage/profile_store.dart';
import 'package:finpet/domain/economy/engine.dart';
import 'package:finpet/domain/models.dart';

class GameController extends ChangeNotifier {
  GameController(this._store);

  final ProfileStore _store;
  GameProfile profile = GameProfile.empty();
  bool loaded = false;

  Future<void> load() async {
    profile = await _store.read() ?? GameProfile.empty();
    loaded = true;
    notifyListeners();
  }

  Future<void> _commit(EngineResult result) async {
    profile = result.profile.copyWith(
      lastMessage: result.message,
      lastNextStep: result.nextStep,
    );
    await _store.write(profile);
    notifyListeners();
  }

  Future<void> markIntroSeen() async {
    profile = profile.copyWith(seenIntro: true);
    await _store.write(profile);
    notifyListeners();
  }

  Future<EngineResult> createPet({
    required String playerName,
    required String petName,
    required PetLook look,
  }) async {
    final result = Economy.startNewPlayer(
      playerName: playerName,
      petName: petName,
      look: look,
    );
    await _commit(result);
    return result;
  }

  Future<EngineResult> confirmPlan(BudgetSplit plan) async {
    final result = Economy.confirmPlan(profile, plan);
    if (result.ok) await _commit(result);
    return result;
  }

  Future<EngineResult> buy(String itemId) async {
    final result = Economy.buy(profile, Catalog.itemById(itemId));
    if (result.ok) await _commit(result);
    return result;
  }

  Future<EngineResult> saveAmount(int amount) async {
    final result = Economy.transferToSavings(profile, amount);
    if (result.ok) await _commit(result);
    return result;
  }

  Future<EngineResult> withdrawAmount(int amount) async {
    final result = Economy.withdrawSavings(profile, amount);
    if (result.ok) await _commit(result);
    return result;
  }

  Future<EngineResult> completeTask(String taskId, TaskAnswer answer) async {
    final result = Economy.completeTask(
      profile,
      Catalog.taskById(taskId),
      answer,
    );
    if (result.ok) await _commit(result);
    return result;
  }

  Future<EngineResult> closePeriod() async {
    final result = Economy.closePeriod(profile);
    if (result.ok) await _commit(result);
    return result;
  }

  Future<void> setGoal(String goalId) async {
    profile = profile.copyWith(
      goalId: goalId,
      lastMessage: 'Цель выбрана: ${Catalog.goalById(goalId)?.title}.',
      lastNextStep: 'Пополняй копилку после нужных трат.',
    );
    await _store.write(profile);
    notifyListeners();
  }

  Future<void> setDemoMode(bool value) async {
    profile = profile.copyWith(demoMode: value);
    await _store.write(profile);
    notifyListeners();
  }

  Future<void> resetProfile() async {
    await _store.clear();
    profile = GameProfile.empty();
    notifyListeners();
  }
}
