import 'package:flutter/material.dart';

import 'package:finpet/app/app.dart';
import 'package:finpet/data/storage/profile_store.dart';
import 'package:finpet/presentation/state/game_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = GameController(ProfileStore());
  await controller.load();
  runApp(FinniApp(controller: controller));
}
