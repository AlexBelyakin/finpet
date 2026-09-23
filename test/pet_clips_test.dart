import 'package:finpet/app/home_hints.dart';
import 'package:finpet/app/pet_clips.dart';
import 'package:finpet/domain/content/catalog.dart';
import 'package:finpet/domain/models.dart';
import 'package:finpet/presentation/widgets/common.dart';
import 'package:flutter/material.dart';
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

  test('подсказки дома покрывают значки', () {
    expect(HomeHints.steps.length, 6);
    expect(HomeHints.steps.first.title, 'Это твой дом');
  });

  test('вырез под питомца — прямоугольник на фигуре', () {
    final raw = Rect.fromLTWH(40, 80, 300, 300);
    final hole = HomeHints.holeOf(HintSpot.pet, raw);
    expect(hole.width, inInclusiveRange(raw.width * 0.32, raw.width * 0.48));
    expect(hole.height, inInclusiveRange(raw.height * 0.58, raw.height * 0.78));
    expect(hole.center.dx, closeTo(raw.center.dx, 0.5));
    expect(HomeHints.holeOf(HintSpot.wallet, raw), raw);
  });

  test('после задания хвалят и за успех, и за попытку', () {
    expect(
      taskPraiseTitle(good: true, taskId: 't1'),
      isIn(['Молодец!', 'Так держать!', 'Супер!', 'Умница!', 'Отлично!']),
    );
    expect(
      taskPraiseTitle(good: false, taskId: 't1'),
      isIn(['Ты справился!', 'Хорошая попытка!', 'Есть прогресс!']),
    );
  });

  test('в прогреве только частые клипы, не все 15', () {
    expect(PetClips.warmClips, contains(PetClip.idleGood));
    expect(PetClips.warmClips, contains(PetClip.reactJoy));
    expect(PetClips.warmClips.length, lessThan(PetClip.values.length));
  });
}
