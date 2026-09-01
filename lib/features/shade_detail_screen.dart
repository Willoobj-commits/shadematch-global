import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/data/catalog_repository.dart';
import '../core/data/favorites_store.dart';
import '../core/models/shade.dart';
import '../widgets/evidence_badge.dart';
import '../widgets/shade_swatch.dart';
import 'match_results.dart';

class ShadeDetailScreen extends StatelessWidget {
  const ShadeDetailScreen({
    required this.repository,
    required this.favorites,
    required this.shade,
    super.key,
  });

  final CatalogRepository repository;
  final FavoritesStore favorites;
  final Shade shade;

  Future<void> _openSource() async {
    final uri = Uri.tryParse(shade.sourceUrl);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shade.brandName),
        actions: [
          AnimatedBuilder(
            animation: favorites,
            builder: (context, _) {
              final saved = favorites.contains(shade.id);
              return IconButton(
                tooltip: saved ? 'Remove from saved shades' : 'Save shade',
                onPressed: () => favorites.toggle(shade.id),
                icon: Icon(saved ? Icons.favorite : Icons.favorite_border),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Hero(
            tag: 'shade-${shade.id}',
            child: ShadeSwatch(shade: shade, height: 250),
          ),
          const SizedBox(height: 18),
          Text(
            shade.displayName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            shade.productName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 18),
          _EvidencePanel(shade: shade),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _InfoRow(
                      label: 'Universal profile',
                      value: shade.universalProfile),
                  _InfoRow(
                      label: 'Depth',
                      value:
                          '${shade.depthFamily} · D${shade.universalDepth.toString().padLeft(2, '0')}'),
                  _InfoRow(
                      label: 'Undertone',
                      value: '${shade.undertoneCode} · ${shade.undertoneName}'),
                  if (shade.manufacturerDepth != null)
                    _InfoRow(
                        label: 'Brand depth', value: shade.manufacturerDepth!),
                  if (shade.manufacturerUndertone != null)
                    _InfoRow(
                        label: 'Brand undertone',
                        value: shade.manufacturerUndertone!),
                  _InfoRow(label: 'Market', value: shade.marketScope),
                  _InfoRow(label: 'Origin', value: shade.origin),
                  _InfoRow(label: 'Product status', value: shade.status),
                  _InfoRow(label: 'Source type', value: shade.sourceType),
                  _InfoRow(
                      label: 'Verified',
                      value: shade.verifiedDate,
                      isLast: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => MatchResultsPage(
                  repository: repository,
                  favorites: favorites,
                  reference: MatchReference(
                    depth: shade.universalDepth,
                    undertone: shade.undertoneCode,
                    label: '${shade.brandName} · ${shade.displayName}',
                    shade: shade,
                  ),
                ),
              ),
            ),
            icon: const Icon(Icons.compare_arrows),
            label: const Text('Find cross-brand matches'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _openSource,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open recorded source page'),
          ),
          const SizedBox(height: 14),
          Text(
            'Normalization basis: ${shade.normalizationBasis}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          if (shade.sourceCoverageNote != null) ...[
            const SizedBox(height: 6),
            Text(
              'Source note: ${shade.sourceCoverageNote}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EvidencePanel extends StatelessWidget {
  const _EvidencePanel({required this.shade});

  final Shade shade;

  @override
  Widget build(BuildContext context) {
    final visual = shade.primaryVisual;
    final isEstimate = visual?.isProfileEstimate ?? true;
    return Card(
      color: isEstimate
          ? const Color(0xFFFFF2E5)
          : Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EvidenceBadge(visual: visual),
            const SizedBox(height: 12),
            Text(
              isEstimate
                  ? 'This is a universal profile colour sample—not an official or measured product swatch.'
                  : visual?.label ?? 'Verified visual reference',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              isEstimate
                  ? 'Use it to compare depth and undertone direction. Product formula, finish, lighting and oxidation can change the real appearance.'
                  : visual?.disclaimer ??
                      'Review the evidence type before relying on this visual.',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 126,
            child: Text(
              label,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
