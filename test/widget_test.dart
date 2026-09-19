import 'package:finpet/app/app.dart';
import 'package:finpet/data/storage/profile_store.dart';
import 'package:finpet/presentation/state/game_controller.dart';
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
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('про монеты'), findsOneWidget);
  });
}
