import 'package:finpet/app/app.dart';
import 'package:finpet/app/assets.dart';
import 'package:finpet/data/storage/profile_store.dart';
import 'package:finpet/presentation/state/game_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('первый экран — знакомство', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = GameController(ProfileStore());
    await controller.load();
    await tester.pumpWidget(FinniApp(controller: controller));
    await tester.pump();
    await tester.pump(AppSplash.hold);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('Привет! Это игра'), findsOneWidget);
    expect(find.text('Играть!'), findsOneWidget);
<<<<<<< HEAD
    controller.dispose(); 
=======
    controller.dispose();
  });

  testWidgets('на планшете «Играть!» видно на приветствии и при создании', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(2560, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final controller = GameController(ProfileStore());
    await controller.load();
    await tester.pumpWidget(FinniApp(controller: controller));
    await tester.pump();
    await tester.pump(AppSplash.hold);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Играть!'), findsOneWidget);

    await tester.tap(find.text('Играть!'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Выбери персонажа и цвет'), findsOneWidget);
    expect(find.text('Играть!'), findsOneWidget);
    controller.dispose();
>>>>>>> main
  });
}
