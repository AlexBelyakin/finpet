import 'package:finpet/app/pet_clips.dart';
import 'package:finpet/domain/models.dart';

class PetModelRuntime {
  PetModelRuntime._();
  static final instance = PetModelRuntime._();

  String? get baseUrl => null;

  Future<void> start() async {}

  Future<void> ensureBody(
    PetBody body, {
    PetClip? idle,
    bool warm = true,
  }) async {}

  Future<void> prefetch(PetClip clip, [PetBody? body]) async {}

  bool hasClip(PetClip clip, PetBody body) => false;
}
