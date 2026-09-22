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
  static String clipName(PetClip clip) => switch (clip) {
        PetClip.idleGood => 'idle_good',
        PetClip.idleThoughtful => 'idle_thoughtful',
        PetClip.idleNeeds => 'idle_needs',
        PetClip.reactJoy => 'react_joy',
        PetClip.reactThink => 'react_think',
        PetClip.reactSupport => 'react_support',
        PetClip.buyGood => 'buy_good',
        PetClip.buyNo => 'buy_no',
        PetClip.saveAdd => 'save_add',
        PetClip.saveDone => 'save_done',
        PetClip.taskRight => 'task_right',
        PetClip.taskWrong => 'task_wrong',
        PetClip.stageBaby => 'stage_baby',
        PetClip.stageTeen => 'stage_teen',
        PetClip.stageAdult => 'stage_adult',
      };

  static String asset(PetClip clip, [PetBody body = PetBody.finni]) =>
      'assets/models/${body.name}/${clipName(clip)}.glb';

  static String fileKey(PetClip clip, [PetBody body = PetBody.finni]) =>
      '${body.name}/${clipName(clip)}';

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

  /// То, что держим в RAM до первого действия: три idle и частая реакция.
  static const warmClips = <PetClip>[
    PetClip.idleGood,
    PetClip.idleThoughtful,
    PetClip.idleNeeds,
    PetClip.reactJoy,
  ];
}
