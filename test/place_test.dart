import 'package:finpet/app/assets.dart';
import 'package:finpet/app/day_period.dart';
import 'package:finpet/data/storage/profile_store.dart';
import 'package:finpet/domain/content/catalog.dart';
import 'package:finpet/domain/economy/engine.dart';
import 'package:finpet/domain/models.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('утро, вечер и ночь по часам', () {
    expect(RoomDaytimes.of(DateTime(2026, 9, 21, 6)), RoomDaytime.morning);
    expect(RoomDaytimes.of(DateTime(2026, 9, 21, 15)), RoomDaytime.morning);
    expect(RoomDaytimes.of(DateTime(2026, 9, 21, 17)), RoomDaytime.evening);
    expect(RoomDaytimes.of(DateTime(2026, 9, 21, 21)), RoomDaytime.evening);
    expect(RoomDaytimes.of(DateTime(2026, 9, 21, 22)), RoomDaytime.night);
    expect(RoomDaytimes.of(DateTime(2026, 9, 21, 3)), RoomDaytime.night);
  });

  test('после создания персонажа локация ещё не выбрана', () {
    final start = Economy.startNewPlayer(
      playerName: 'Саша',
      petName: 'Финни',
      look: Catalog.looks.first,
    ).profile;
    expect(start.place, isNull);
  });

  test('старое сохранение с питомцем получает комнату', () {
    final start = Economy.startNewPlayer(
      playerName: 'Саша',
      petName: 'Финни',
      look: Catalog.looks.first,
    ).profile;
    final json = start.toJson()..remove('place');
    final loaded = GameProfile.fromJson(json);
    expect(loaded.place, PetPlace.room);
  });

  test('усадьба закрыта, пока нет 5 заданий', () {
    final start = Economy.startNewPlayer(
      playerName: 'Саша',
      petName: 'Финни',
      look: Catalog.looks.first,
    ).profile;
    expect(start.canUsePlace(PetPlace.room), isTrue);
    expect(start.canUsePlace(PetPlace.room2), isFalse);
    expect(start.place, isNull);

    final almost = start.copyWith(doneTaskIds: ['t1', 't2', 't3', 't4']);
    expect(almost.room2Unlocked, isFalse);

    final open = start.copyWith(
      doneTaskIds: ['t1', 't2', 't3', 't4', 't5'],
      coins: 40,
    );
    expect(open.canUsePlace(PetPlace.room2), isTrue);
    expect(open.coins, 40);
    expect(open.doneTaskIds, hasLength(5));
  });

  test('смена локации не сбрасывает задания и монеты', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = GameController(ProfileStore());
    await controller.load();
    await controller.createPet(
      playerName: 'Саша',
      petName: 'Финни',
      look: Catalog.looks.first,
    );
    expect(await controller.setPlace(PetPlace.room2), isFalse);
    expect(controller.profile.place, isNull);
    controller.profile = controller.profile.copyWith(
      doneTaskIds: ['t1', 't2', 't3', 't4', 't5'],
      coins: 55,
    );
    expect(await controller.setPlace(PetPlace.room2), isTrue);
    expect(controller.profile.place, PetPlace.room2);
    expect(controller.profile.doneTaskIds, hasLength(5));
    expect(controller.profile.coins, 55);
    expect(controller.profile.pet?.name, 'Финни');

    await controller.createPet(
      playerName: 'Саша',
      petName: 'Нори',
      look: Catalog.looks.last,
    );
    expect(controller.profile.place, isNull);
    expect(controller.profile.doneTaskIds, isEmpty);
    expect(controller.profile.canUsePlace(PetPlace.room2), isFalse);
  });

  test('вторая локация берёт фоны room2', () {
    expect(
      AppAssets.placeBackdrop(
        place: PetPlace.room2,
        period: RoomDaytime.morning,
        tablet: false,
      ),
      'assets/images/room2_morning.jpg',
    );
    expect(
      AppAssets.placeBackdrop(
        place: PetPlace.room2,
        period: RoomDaytime.night,
        tablet: true,
      ),
      'assets/images/room2_night_planshet.jpg',
    );
  });
}
