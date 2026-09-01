import 'package:flutter/material.dart';

import '../core/data/catalog_repository.dart';
import '../core/data/favorites_store.dart';
import '../core/models/shade.dart';
import '../widgets/shade_swatch.dart';
import 'shade_detail_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({
    required this.repository,
    required this.favorites,
    super.key,
  });

  final CatalogRepository repository;
  final FavoritesStore favorites;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: favorites,
      builder: (context, _) {
        final shades = favorites.ids
            .map(repository.shadeById)
            .whereType<Shade>()
            .toList(growable: false);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Saved shades',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                    ),
                  ),
                  if (shades.isNotEmpty)
                    TextButton(
                        onPressed: favorites.clear, child: const Text('Clear')),
                ],
              ),
            ),
            Expanded(
              child: shades.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(28),
                        child: Text(
                          'Save promising shades to compare them again later.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                      itemCount: shades.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final shade = shades[index];
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => ShadeDetailScreen(
                                  repository: repository,
                                  favorites: favorites,
                                  shade: shade,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShadeSwatch(
                                    shade: shade, height: 140, borderRadius: 0),
                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Text(
                                    '${shade.brandName} · ${shade.displayName}\n${shade.productName}',
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
