import 'package:flutter/material.dart';

import 'package:finpet/app/assets.dart';

/// Первый кадр после иконки: тот же фон, что и нативный Android splash.
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4EC4F5),
      body: SizedBox.expand(
        child: Image.asset(
          AppAssets.bgLaunch,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}
