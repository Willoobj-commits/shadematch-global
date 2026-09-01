import 'package:flutter/material.dart';

import '../core/data/catalog_repository.dart';
import '../core/data/favorites_store.dart';
import '../core/models/match_result.dart';
import '../core/models/shade.dart';
import '../core/services/match_engine.dart';
import '../core/services/profile_color.dart';
import '../widgets/shade_swatch.dart';
import 'shade_detail_screen.dart';

class MatchReference {
  const MatchReference({
    required this.depth,
    required this.undertone,
    required this.label,
    this.shade,
  });

  final int depth;
  final String undertone;
  final String label;
  final Shade? shade;

  Color get sampleColor => shade == null
      ? profileSampleColor(depth, undertone)
      : colorFromHex(shade!.primaryVisual?.displayHex);
}

class MatchResultsPage extends StatelessWidget {
  const MatchResultsPage({
    required this.repository,
    required this.favorites,
    required this.reference,
    super.key,
  });

  final CatalogRepository repository;
  final FavoritesStore favorites;
  final MatchReference reference;

  @override
  Widget build(BuildContext context) {
    final results = MatchEngine(repository.undertones).bestPerBrand(
      referenceDepth: reference.depth,
      referenceUndertone: reference.undertone,
      shades: repository.shades,
      excludeBrand: reference.shade?.brandName,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Cross-brand matches')),
      body: MatchResultsList(
        repository: repository,
        favorites: favorites,
        reference: reference,
        results: results,
      ),
    );
  }
}

class MatchResultsList extends StatelessWidget {
  const MatchResultsList({
    required this.repository,
    required this.favorites,
    required this.reference,
    required this.results,
    this.shrinkWrap = false,
    super.key,
  });

  final CatalogRepository repository;
  final FavoritesStore favorites;
  final MatchReference reference;
  final List<MatchResult> results;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Text(
            'No responsibly close candidate was found. Distant shades are hidden instead of being presented as matches.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      itemCount: results.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _ResultsIntro(reference: reference, count: results.length);
        }
        final result = results[index - 1];
        return _MatchCard(
          result: result,
          reference: reference,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => ShadeDetailScreen(
                repository: repository,
                favorites: favorites,
                shade: result.shade,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ResultsIntro extends StatelessWidget {
  const _ResultsIntro({required this.reference, required this.count});

  final MatchReference reference;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reference.label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'D${reference.depth.toString().padLeft(2, '0')}–${reference.undertone} · $count responsibly close brand candidates',
            ),
            const SizedBox(height: 10),
            Text(
              'Samples currently represent normalized profiles. They are clearly separated from official or measured swatches.',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({
    required this.result,
    required this.reference,
    required this.onTap,
  });

  final MatchResult result;
  final MatchReference reference;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileComparisonStrip(
                referenceColor: reference.sampleColor,
                referenceLabel: 'Your reference',
                candidate: result.shade,
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.shade.brandName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                        Text(
                          '${result.shade.displayName} · ${result.shade.productName}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      result.grade,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${result.confidence}\n${result.reason}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
