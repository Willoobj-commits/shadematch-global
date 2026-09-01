import 'package:flutter/material.dart';

import '../core/data/catalog_repository.dart';
import '../core/data/favorites_store.dart';
import '../core/models/shade.dart';
import '../widgets/shade_swatch.dart';
import 'shade_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    required this.repository,
    required this.favorites,
    super.key,
  });

  final CatalogRepository repository;
  final FavoritesStore favorites;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _query = '';
  int? _depth;
  String? _undertone;

  Future<void> _chooseDepth() async {
    final value = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Filter by universal depth'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 0),
            child: const Text('Any depth'),
          ),
          ...List.generate(
            30,
            (index) => SimpleDialogOption(
              onPressed: () => Navigator.pop(context, index + 1),
              child: Text('D${(index + 1).toString().padLeft(2, '0')}'),
            ),
          ),
        ],
      ),
    );
    if (value == null) return;
    setState(() => _depth = value == 0 ? null : value);
  }

  Future<void> _chooseUndertone() async {
    final value = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Filter by undertone'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, '*'),
            child: const Text('Any undertone'),
          ),
          ...widget.repository.undertones.map(
            (item) => SimpleDialogOption(
              onPressed: () => Navigator.pop(context, item.code),
              child: Text('${item.code} · ${item.name}'),
            ),
          ),
        ],
      ),
    );
    if (value == null) return;
    setState(() => _undertone = value == '*' ? null : value);
  }

  @override
  Widget build(BuildContext context) {
    final results = widget.repository.searchShades(
      _query,
      depth: _depth,
      undertone: _undertone,
      limit: 2000,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explore verified shades',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Brand, product, shade or profile',
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    selected: _depth != null,
                    label: Text(
                      _depth == null
                          ? 'Any depth'
                          : 'D${_depth.toString().padLeft(2, '0')}',
                    ),
                    onSelected: (_) => _chooseDepth(),
                  ),
                  FilterChip(
                    selected: _undertone != null,
                    label: Text(
                        _undertone == null ? 'Any undertone' : _undertone!),
                    onSelected: (_) => _chooseUndertone(),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Text('${results.length} shown'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: results.isEmpty
              ? const Center(child: Text('No shade matches these filters.'))
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 260,
                    mainAxisExtent: 286,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: results.length,
                  itemBuilder: (context, index) => _ShadeTile(
                    shade: results[index],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => ShadeDetailScreen(
                          repository: widget.repository,
                          favorites: widget.favorites,
                          shade: results[index],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _ShadeTile extends StatelessWidget {
  const _ShadeTile({required this.shade, required this.onTap});

  final Shade shade;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: 'shade-${shade.id}',
              child: ShadeSwatch(
                shade: shade,
                height: 158,
                borderRadius: 0,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shade.brandName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      shade.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shade.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
