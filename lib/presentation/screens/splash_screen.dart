import 'package:flutter/material.dart';

import 'package:finpet/app/assets.dart';
import 'package:finpet/app/layout.dart';

/// Первый кадр после иконки: телефон или планшет — свой фон, как native splash.
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final asset =
        AppLayout.isTablet(context) ? AppAssets.bgLaunchTablet : AppAssets.bgLaunch;
    return Scaffold(
      backgroundColor: const Color(0xFF4EC4F5),
      body: SizedBox.expand(
        child: Image.asset(
          asset,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}
