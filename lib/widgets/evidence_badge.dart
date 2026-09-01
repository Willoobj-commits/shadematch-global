import 'package:flutter/material.dart';

import '../core/models/visual_reference.dart';

class EvidenceBadge extends StatelessWidget {
  const EvidenceBadge({required this.visual, this.compact = false, super.key});

  final VisualReference? visual;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (label, icon, foreground, background) = switch (visual?.kind) {
      'spectrophotometer_measurement' => (
          'Measured colour',
          Icons.science_outlined,
          const Color(0xFF125B46),
          const Color(0xFFDDF7EC),
        ),
      'calibrated_standardized_swatch' => (
          'Calibrated swatch',
          Icons.tune,
          const Color(0xFF174C70),
          const Color(0xFFE0F1FA),
        ),
      'official_digital_swatch' || 'official_product_image' => (
          'Official visual',
          Icons.verified_outlined,
          const Color(0xFF5A3A08),
          const Color(0xFFFFF0C9),
        ),
      _ => (
          'Profile sample',
          Icons.palette_outlined,
          const Color(0xFF6C3B65),
          const Color(0xFFF6E8F2),
        ),
    };
    return Semantics(
      label: label,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: compact ? 13 : 15, color: foreground),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
