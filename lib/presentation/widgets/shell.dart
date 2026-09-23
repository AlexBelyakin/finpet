import 'package:flutter/material.dart';

import 'package:finpet/app/layout.dart';
import 'package:finpet/app/theme/app_theme.dart';
import 'package:finpet/presentation/screens/glossary_screen.dart';
import 'package:finpet/presentation/widgets/common.dart';
import 'package:finpet/presentation/widgets/icons.dart';

class FinniScaffold extends StatelessWidget {
  const FinniScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floating,
    this.alignment = Alignment.topCenter,   
  });

  final String title;
  final Widget body;
  final Widget? floating;
  final AlignmentGeometry alignment;        

  @override
  Widget build(BuildContext context) {
    final pad = AppLayout.pagePadding(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Подсказка',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const GlossaryScreen(),
                ),
              );
            },
            icon: const Icon(FinniIcons.help),
          ),
        ],
      ),
      floatingActionButton: floating,
      body: SafeArea(
        child: Align(
         alignment: alignment,                   // ← используем параметр
            child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppLayout.isWide(context) ? 980 : double.infinity,
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(pad.left, 0, pad.right, pad.bottom),
              child: body,
            ),
          ),
        ),
      ),
    );
  }
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.ink.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return PressScale(child: card);
    return PressScale(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: card,
        ),
      ),
    );
  }
}
