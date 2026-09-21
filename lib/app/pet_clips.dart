import 'package:finpet/domain/models.dart';

/// Клипы из мини-руководства: idle по кругу, остальное — разово.
enum PetClip {
  idleGood,
  idleThoughtful,
  idleNeeds,
  reactJoy,
  reactThink,
  reactSupport,
  buyGood,
  buyNo,
  saveAdd,
  saveDone,
  taskRight,
  taskWrong,
  stageBaby,
  stageTeen,
  stageAdult,
}

abstract final class PetClips {
  static const idleGood = 'assets/models/finni/idle_good.glb';
  static const idleThoughtful = 'assets/models/finni/idle_thoughtful.glb';
  static const idleNeeds = 'assets/models/finni/idle_needs.glb';
  static const reactJoy = 'assets/models/finni/react_joy.glb';
  static const reactThink = 'assets/models/finni/react_think.glb';
  static const reactSupport = 'assets/models/finni/react_support.glb';
  static const buyGood = 'assets/models/finni/buy_good.glb';
  static const buyNo = 'assets/models/finni/buy_no.glb';
  static const saveAdd = 'assets/models/finni/save_add.glb';
  static const saveDone = 'assets/models/finni/save_done.glb';
  static const taskRight = 'assets/models/finni/task_right.glb';
  static const taskWrong = 'assets/models/finni/task_wrong.glb';
  static const stageBaby = 'assets/models/finni/stage_baby.glb';
  static const stageTeen = 'assets/models/finni/stage_teen.glb';
  static const stageAdult = 'assets/models/finni/stage_adult.glb';

  static bool isLoop(PetClip clip) => switch (clip) {
        PetClip.idleGood ||
        PetClip.idleThoughtful ||
        PetClip.idleNeeds ||
        PetClip.stageBaby ||
        PetClip.stageTeen ||
        PetClip.stageAdult =>
          true,
        _ => false,
      };

  static String fileKey(PetClip clip) =>
      asset(clip).split('/').last.replaceAll('.glb', '');

  static String asset(PetClip clip) => switch (clip) {
        PetClip.idleGood => idleGood,
        PetClip.idleThoughtful => idleThoughtful,
        PetClip.idleNeeds => idleNeeds,
        PetClip.reactJoy => reactJoy,
        PetClip.reactThink => reactThink,
        PetClip.reactSupport => reactSupport,
        PetClip.buyGood => buyGood,
        PetClip.buyNo => buyNo,
        PetClip.saveAdd => saveAdd,
        PetClip.saveDone => saveDone,
        PetClip.taskRight => taskRight,
        PetClip.taskWrong => taskWrong,
        PetClip.stageBaby => stageBaby,
        PetClip.stageTeen => stageTeen,
        PetClip.stageAdult => stageAdult,
      };

  static bool returnsToIdle(PetClip clip) => !switch (clip) {
        PetClip.idleGood ||
        PetClip.idleThoughtful ||
        PetClip.idleNeeds =>
          true,
        _ => false,
      };

  static Duration holdOf(PetClip clip) {
    final ms = switch (clip) {
      PetClip.idleGood => 4542,
      PetClip.idleThoughtful => 5042,
      PetClip.idleNeeds => 7042,
      PetClip.saveDone || PetClip.taskWrong => 2542,
      PetClip.stageBaby || PetClip.stageTeen => 4042,
      PetClip.stageAdult => 5542,
      _ => 2042,
    };
    return Duration(milliseconds: ms + 400);
  }

  static PetClip idleFor(Pet pet) {
    if (pet.satiety < 40) return PetClip.idleNeeds;
    if (pet.mood < 50) return PetClip.idleThoughtful;
    return PetClip.idleGood;
  }

  static PetClip reactFor(Pet pet) {
    if (pet.satiety < 40 || pet.mood < 40) return PetClip.reactSupport;
    if (pet.mood < 60) return PetClip.reactThink;
    return PetClip.reactJoy;
  }

  static PetClip stageFor(int stage) => switch (stage) {
        1 => PetClip.stageBaby,
        2 => PetClip.stageTeen,
        _ => PetClip.stageAdult,
      };
}
