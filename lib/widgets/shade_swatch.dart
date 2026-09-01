import 'package:flutter/material.dart';

import '../core/models/shade.dart';
import '../core/services/profile_color.dart';
import 'evidence_badge.dart';

class ShadeSwatch extends StatelessWidget {
  const ShadeSwatch({
    required this.shade,
    this.height = 170,
    this.showEvidence = true,
    this.borderRadius = 24,
    super.key,
  });

  final Shade shade;
  final double height;
  final bool showEvidence;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final visual = shade.primaryVisual;
    final color = colorFromHex(visual?.displayHex);
    final foreground = readableTextColor(color);
    return Semantics(
      image: true,
      label:
          '${shade.brandName} ${shade.displayName}, ${shade.depthFamily}, ${shade.undertoneName}. ${visual?.label ?? 'Colour sample'}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: color),
              if (visual?.imageUrl != null)
                Image.network(
                  visual!.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => ColoredBox(color: color),
                ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        shade.universalProfile,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w900,
                          shadows: const [
                            Shadow(color: Colors.black26, blurRadius: 8),
                          ],
                        ),
                      ),
                    ),
                    if (showEvidence)
                      EvidenceBadge(visual: visual, compact: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileComparisonStrip extends StatelessWidget {
  const ProfileComparisonStrip({
    required this.referenceColor,
    required this.referenceLabel,
    required this.candidate,
    super.key,
  });

  final Color referenceColor;
  final String referenceLabel;
  final Shade candidate;

  @override
  Widget build(BuildContext context) {
    final candidateColor = colorFromHex(candidate.primaryVisual?.displayHex);
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 88,
        child: Row(
          children: [
            Expanded(
              child: _ComparisonColor(
                color: referenceColor,
                label: referenceLabel,
              ),
            ),
            Expanded(
              child: _ComparisonColor(
                color: candidateColor,
                label: candidate.displayName,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonColor extends StatelessWidget {
  const _ComparisonColor({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: readableTextColor(color),
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
      ),
    );
  }
}
