import 'package:flutter/widgets.dart';

import 'package:fl_clash/views/dashboard/widgets/igallta_subscription.dart'
    show IgalltaColors, IgalltaPalette;

/// The empty state of the Igallta design: the line artwork above a short
/// message and one action.
class IgalltaEmptyState extends StatelessWidget {
  const IgalltaEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.action,
    this.artHeight = 240,
  });

  final String title;
  final String description;
  final Widget? action;
  final double artHeight;

  @override
  Widget build(BuildContext context) {
    final palette = IgalltaPalette.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: artHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: palette.line),
                ),
                padding: const EdgeInsets.all(14),
                child: Image.asset(
                  'assets/images/igallta-crisp-lineart.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 19,
                  color: palette.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.6,
                  color: palette.muted,
                ),
              ),
              if (action != null) ...[
                const SizedBox(height: 20),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A filled pill button in the Igallta palette, for empty states.
class IgalltaFilledButton extends StatelessWidget {
  const IgalltaFilledButton({
    super.key,
    required this.label,
    required this.onTap,
    this.glyph,
  });

  final String label;
  final VoidCallback onTap;
  final Widget? glyph;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: IgalltaColors.blue,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: IgalltaColors.blue.withValues(alpha: 0.22),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (glyph != null) ...[glyph!, const SizedBox(width: 8)],
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFFFFFFF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
