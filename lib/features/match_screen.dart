import 'package:flutter/material.dart';

import '../core/data/catalog_repository.dart';
import '../core/data/favorites_store.dart';
import '../core/models/match_result.dart';
import '../core/models/shade.dart';
import '../core/services/match_engine.dart';
import '../core/services/profile_color.dart';
import '../widgets/shade_swatch.dart';
import 'match_results.dart';
import 'shade_picker.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({
    required this.repository,
    required this.favorites,
    super.key,
  });

  final CatalogRepository repository;
  final FavoritesStore favorites;

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  Shade? _shade;
  int? _manualDepth;
  String? _manualUndertone;

  MatchReference? get _reference {
    if (_shade != null) {
      return MatchReference(
        depth: _shade!.universalDepth,
        undertone: _shade!.undertoneCode,
        label: '${_shade!.brandName} · ${_shade!.displayName}',
        shade: _shade,
      );
    }
    if (_manualDepth != null && _manualUndertone != null) {
      return MatchReference(
        depth: _manualDepth!,
        undertone: _manualUndertone!,
        label: 'Your manual universal profile',
      );
    }
    return null;
  }

  Future<void> _pickShade() async {
    final value = await showShadePicker(context, widget.repository);
    if (value == null) return;
    setState(() {
      _shade = value;
      _manualDepth = null;
      _manualUndertone = null;
    });
  }

  Future<void> _pickManual() async {
    final value = await showManualProfilePicker(
      context,
      widget.repository,
      initialDepth: _manualDepth ?? 15,
      initialUndertone: _manualUndertone ?? 'N',
    );
    if (value == null) return;
    setState(() {
      _shade = null;
      _manualDepth = value.depth;
      _manualUndertone = value.undertone;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reference = _reference;
    final List<MatchResult> results = reference == null
        ? const <MatchResult>[]
        : MatchEngine(widget.repository.undertones).bestPerBrand(
            referenceDepth: reference.depth,
            referenceUndertone: reference.undertone,
            shades: widget.repository.shades,
            excludeBrand: reference.shade?.brandName,
          );
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          sliver: SliverList.list(
            children: [
              Text(
                'Find your shade across brands',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start with a product you already wear or choose a depth and undertone profile.',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _pickShade,
                      icon: const Icon(Icons.search),
                      label: const Text('Known shade'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: _pickManual,
                      icon: const Icon(Icons.tune),
                      label: const Text('Manual profile'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (reference == null)
                _EmptyReference(onKnown: _pickShade, onManual: _pickManual)
              else
                _ReferenceCard(reference: reference),
              const SizedBox(height: 16),
            ],
          ),
        ),
        if (reference != null)
          SliverToBoxAdapter(
            child: MatchResultsList(
              repository: widget.repository,
              favorites: widget.favorites,
              reference: reference,
              results: results,
              shrinkWrap: true,
            ),
          ),
      ],
    );
  }
}

class _ReferenceCard extends StatelessWidget {
  const _ReferenceCard({required this.reference});

  final MatchReference reference;

  @override
  Widget build(BuildContext context) {
    final shade = reference.shade;
    if (shade != null) {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShadeSwatch(shade: shade, height: 180),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                reference.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
          ],
        ),
      );
    }
    final color = profileSampleColor(reference.depth, reference.undertone);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 190,
        color: color,
        padding: const EdgeInsets.all(18),
        alignment: Alignment.bottomLeft,
        child: Text(
          'D${reference.depth.toString().padLeft(2, '0')}–${reference.undertone}\nProfile sample',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: readableTextColor(color),
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
    );
  }
}

class _EmptyReference extends StatelessWidget {
  const _EmptyReference({required this.onKnown, required this.onManual});

  final VoidCallback onKnown;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.colorize_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Choose a reference to see clear side-by-side colour samples.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: onKnown,
                  child: const Text('Search known shade'),
                ),
                TextButton(
                  onPressed: onManual,
                  child: const Text('Choose manually'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
