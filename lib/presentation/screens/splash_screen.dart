import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:finpet/app/assets.dart';
import 'package:finpet/app/layout.dart';
import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/presentation/widgets/finni_pet.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SplashBackground(
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                const Spacer(),
                Image.asset(AppAssets.logo, height: AppLayout.isTablet(context) ? 132 : 96)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .scale(begin: const Offset(0.92, 0.92)),
                const SizedBox(height: 8),
                Text(
                  'Питомец Финни',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Забота, план и копилка',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.ink.withValues(alpha: 0.72),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
