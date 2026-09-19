import 'package:flutter/material.dart';

import 'package:finpet/app/app.dart';
import 'package:finpet/data/storage/profile_store.dart';
import 'package:finpet/presentation/state/game_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(FinniApp(controller: GameController(ProfileStore())));
}
