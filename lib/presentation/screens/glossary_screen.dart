import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/domain/content/catalog.dart';
import 'package:finpet/presentation/widgets/icons.dart';
import 'package:finpet/presentation/widgets/shell.dart';

class GlossaryScreen extends StatelessWidget {
  const GlossaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Подсказка')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Три решения в игре: потратить на нужное, потратить на желаемое, отложить в копилку.',
            style: TextStyle(fontSize: 16, height: 1.35),
          ),
          const SizedBox(height: 12),
          ...Catalog.glossary.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SurfaceCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.sky.withValues(alpha: 0.28),
                      ),
                      child: const Icon(FinniIcons.help, color: AppTheme.ink),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.value.$1,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(entry.value.$2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 260.ms, delay: (50 * entry.key).ms)
                .slideY(begin: 0.04),
          ),
        ],
      ),
    );
  }
}
