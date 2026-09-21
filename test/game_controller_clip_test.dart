import 'package:finpet/app/pet_clips.dart';
import 'package:finpet/data/storage/profile_store.dart';
import 'package:finpet/domain/content/catalog.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('клип задания стартует только после выхода на дом', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = GameController(ProfileStore());
    await controller.load();
    await controller.createPet(
      playerName: 'Саша',
      petName: 'Финни',
      look: Catalog.looks.first,
    );
    expect(controller.petClip, PetClip.idleGood);

    controller.queueEventClip(PetClip.taskRight);
    expect(controller.petClip, PetClip.idleGood);

    controller.presentQueuedClip();
    expect(controller.petClip, PetClip.taskRight);
  });
}
