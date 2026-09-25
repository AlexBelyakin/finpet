import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:finpet/app/pet_clips.dart';
import 'package:finpet/data/pet/pet_model_bridge.dart';
import 'package:finpet/data/pet/pet_model_runtime.dart';
import 'package:finpet/domain/content/catalog.dart';
import 'package:finpet/data/storage/profile_store.dart';
import 'package:finpet/domain/economy/engine.dart';
import 'package:finpet/domain/models.dart';

class GameController extends ChangeNotifier {
  GameController(this._store);

  final ProfileStore _store;
  GameProfile profile = GameProfile.empty();
  bool loaded = false;
  PetClip? _queuedClip;
  PetClip? _playingClip;
  Timer? _clipTimer;
  Timer? _needsTimer;
  DateTime? _clipStarted;

  PetClip get petClip {
    if (_playingClip != null) return _playingClip!;
    final pet = profile.pet;
    if (pet == null) return PetClip.idleGood;
    return PetClips.idleFor(pet);
  }

  /// Разовая реакция или смена стадии ещё на экране.
  bool get petActing => _playingClip != null;

  /// Клип после выхода на дом: покупка, задание, копилка, мини-игра.
  void queueEventClip(PetClip clip) {
    _clipTimer?.cancel();
    _clipTimer = null;
    _queuedClip = clip;
    unawaited(PetModelRuntime.instance.prefetch(clip));
    PetModelBridge.prepare(clip);
  }

  /// Сразу на доме: тап, закрытие недели.
  void playClipNow(PetClip clip) {
    _clipTimer?.cancel();
    _clipTimer = null;
    _queuedClip = null;
    _playingClip = clip;
    _clipStarted = DateTime.now();
    unawaited(PetModelRuntime.instance.prefetch(clip));
    notifyListeners();
    _armHold();
  }

  /// Дом снова на экране — запускаем отложенный клип события.
  void presentQueuedClip() {
    final queued = _queuedClip;
    if (queued == null) return;
    _queuedClip = null;
    _playingClip = queued;
    _clipStarted = DateTime.now();
    notifyListeners();
    _armHold();
  }

  void onActionClipFinished() {
    if (_playingClip == null) return;
    if (!PetClips.returnsToIdle(_playingClip!)) return;
    final started = _clipStarted;
    if (started != null &&
        DateTime.now().difference(started) < const Duration(milliseconds: 450)) {
      return;
    }
    _clipTimer?.cancel();
    _clipTimer = null;
    _playingClip = null;
    notifyListeners();
  }

  void _armHold() {
    if (_playingClip == null || !PetClips.returnsToIdle(_playingClip!)) return;
    _clipTimer = Timer(
      PetClips.holdOf(_playingClip!) + const Duration(milliseconds: 800),
      onActionClipFinished,
    );
  }

  void reactToPetTap() {
    final pet = profile.pet;
    if (pet == null) return;
    playClipNow(PetClips.reactFor(pet));
  }

  @override
  void dispose() {
    _clipTimer?.cancel();
    _needsTimer?.cancel();
    super.dispose();
  }

  Future<void> load() async {
    profile = await _store.read() ?? GameProfile.empty();
    loaded = true;
    await applyNeedsDrift();
    _armNeedsTimer();
    notifyListeners();
    final pet = profile.pet;
    if (pet != null) {
      unawaited(PetModelRuntime.instance.ensureBody(
        pet.look.body,
        idle: PetClips.idleFor(pet),
      ));
    }
  }

  void _armNeedsTimer() {
    _needsTimer?.cancel();
    _needsTimer = Timer.periodic(const Duration(minutes: 20), (_) {
      unawaited(applyNeedsDrift());
    });
  }

  Future<void> applyNeedsDrift() async {
    final next = Economy.settleNeeds(profile);
    final samePet = next.pet?.satiety == profile.pet?.satiety &&
        next.pet?.mood == profile.pet?.mood &&
        next.needsAt == profile.needsAt;
    if (samePet) return;
    profile = next;
    await _store.write(profile);
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

  Future<void> markHomeHintsSeen() async {
    profile = profile.copyWith(seenHomeHints: true);
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
    await PetModelRuntime.instance.ensureBody(
      look.body,
      idle: PetClip.idleGood,
      warm: true,
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
    final item = Catalog.itemById(itemId);
    final result = Economy.buy(profile, item);
    if (result.ok) {
      queueEventClip(PetClip.buyGood);
      await _commit(result);
    } else if (profile.pet != null && profile.coins < item.price) {
      queueEventClip(PetClip.buyNo);
    }
    return result;
  }

  Future<EngineResult> saveAmount(int amount) async {
    final result = Economy.transferToSavings(profile, amount);
    if (result.ok) {
      final goal = Catalog.goalById(result.profile.goalId);
      final reached = goal != null && result.profile.savings >= goal.cost;
      queueEventClip(reached ? PetClip.saveDone : PetClip.saveAdd);
      await _commit(result);
    }
    return result;
  }

  Future<EngineResult> withdrawAmount(int amount) async {
    final result = Economy.withdrawSavings(profile, amount);
    if (result.ok) await _commit(result);
    return result;
  }

  Future<EngineResult> completeTask(String taskId, TaskAnswer answer) async {
    final task = Catalog.taskById(taskId);
    final result = Economy.completeTask(profile, task, answer);
    if (result.ok) {
      final gained = result.profile.coins - profile.coins;
      final unlockedRoom2 =
          !profile.room2Unlocked && result.profile.room2Unlocked;
      queueEventClip(
        gained >= task.reward ? PetClip.taskRight : PetClip.taskWrong,
      );
      await _commit(result);
      if (unlockedRoom2) {
        profile = profile.copyWith(
          lastNextStep:
              'Открылась усадьба у сада. Сменить место можно в меню — прогресс сохранится.',
        );
        await _store.write(profile);
        notifyListeners();
      }
    }
    return result;
  }

  Future<EngineResult> rewardMinigame({
    required String title,
    required int coins,
  }) async {
    final result = Economy.rewardMinigame(
      profile,
      title: title,
      requested: coins,
    );
    if (result.ok) {
      queueEventClip(PetClip.reactJoy);
      await _commit(result);
    }
    return result;
  }

  Future<EngineResult> closePeriod() async {
    final oldStage = profile.pet?.stage;
    final result = Economy.closePeriod(profile);
    if (result.ok) {
      final stage = result.profile.pet?.stage;
      if (stage != null && stage != oldStage) {
        playClipNow(PetClips.stageFor(stage));
      } else {
        playClipNow(PetClip.reactJoy);
      }
      await _commit(result);
    }
    return result;
  }

  Future<bool> setPlace(PetPlace place) async {
    if (!profile.canUsePlace(place)) return false;
    profile = profile.copyWith(place: place);
    await _store.write(profile);
    notifyListeners();
    return true;
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

  Future<void> goToCreatePet() async {
    await _store.clear();
    profile = GameProfile.empty().copyWith(seenIntro: true);
    await _store.write(profile);
    notifyListeners();
  }
}
