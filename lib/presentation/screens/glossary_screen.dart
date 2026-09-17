import 'package:flutter/material.dart';

import 'package:finpet/domain/content/catalog.dart';

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
          ...Catalog.glossary.map(
            (item) => Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$1,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(item.$2),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
