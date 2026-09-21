import 'package:finpet/app/pet_clips.dart';
import 'package:finpet/domain/content/catalog.dart';
import 'package:finpet/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Pet pet({int satiety = 80, int mood = 80}) {
    return Pet(
      name: 'Финни',
      look: Catalog.looks.first,
      satiety: satiety,
      mood: mood,
      stage: 1,
      growthPoints: 0,
      moodReason: '',
    );
  }

  test('idle: сытость ниже 40 — needs', () {
    expect(PetClips.idleFor(pet(satiety: 20)), PetClip.idleNeeds);
  });

  test('idle: настроение ниже 50 — thoughtful', () {
    expect(PetClips.idleFor(pet(mood: 40)), PetClip.idleThoughtful);
  });

  test('idle: иначе good', () {
    expect(PetClips.idleFor(pet()), PetClip.idleGood);
  });

  test('разовые клипы возвращаются в idle', () {
    expect(PetClips.returnsToIdle(PetClip.buyGood), isTrue);
    expect(PetClips.returnsToIdle(PetClip.idleGood), isFalse);
  });

  test('клип второго тела — nori', () {
    expect(
      PetClips.asset(PetClip.idleGood, PetBody.nori),
      'assets/models/nori/idle_good.glb',
    );
  });
}
