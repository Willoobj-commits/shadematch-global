import 'package:flutter/material.dart';

import '../core/data/catalog_repository.dart';
import '../core/models/shade.dart';
import '../core/services/profile_color.dart';

Future<Shade?> showShadePicker(
  BuildContext context,
  CatalogRepository repository,
) {
  return showModalBottomSheet<Shade>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (_) => _ShadePicker(repository: repository),
  );
}

Future<({int depth, String undertone})?> showManualProfilePicker(
  BuildContext context,
  CatalogRepository repository, {
  int initialDepth = 15,
  String initialUndertone = 'N',
}) {
  return showModalBottomSheet<({int depth, String undertone})>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (_) => _ManualProfilePicker(
      repository: repository,
      initialDepth: initialDepth,
      initialUndertone: initialUndertone,
    ),
  );
}

class _ShadePicker extends StatefulWidget {
  const _ShadePicker({required this.repository});

  final CatalogRepository repository;

  @override
  State<_ShadePicker> createState() => _ShadePickerState();
}

class _ShadePickerState extends State<_ShadePicker> {
  late List<Shade> _results;

  @override
  void initState() {
    super.initState();
    _results =
        widget.repository.searchShades('', currentOnly: false, limit: 80);
  }

  void _search(String value) {
    setState(() {
      _results = widget.repository.searchShades(
        value,
        currentOnly: false,
        limit: 100,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose a shade you already wear',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 12),
                TextField(
                  autofocus: true,
                  onChanged: _search,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Try Revlon Caramel, MAC NC45, Fenty 420…',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _results.isEmpty
                ? const Center(child: Text('No verified shade found.'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                    itemCount: _results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final shade = _results[index];
                      final color =
                          colorFromHex(shade.primaryVisual?.displayHex);
                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        tileColor: Colors.white,
                        leading: Semantics(
                          label: '${shade.displayName} profile colour sample',
                          child: CircleAvatar(backgroundColor: color),
                        ),
                        title: Text(
                          '${shade.brandName} · ${shade.displayName}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          '${shade.productName}\n${shade.universalProfile} · ${shade.undertoneName}${shade.isCurrent ? '' : ' · ${shade.status}'}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        isThreeLine: true,
                        onTap: () => Navigator.pop(context, shade),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ManualProfilePicker extends StatefulWidget {
  const _ManualProfilePicker({
    required this.repository,
    required this.initialDepth,
    required this.initialUndertone,
  });

  final CatalogRepository repository;
  final int initialDepth;
  final String initialUndertone;

  @override
  State<_ManualProfilePicker> createState() => _ManualProfilePickerState();
}

class _ManualProfilePickerState extends State<_ManualProfilePicker> {
  late int _depth;
  late String _undertone;

  @override
  void initState() {
    super.initState();
    _depth = widget.initialDepth;
    _undertone = widget.initialUndertone;
  }

  @override
  Widget build(BuildContext context) {
    final sample = profileSampleColor(_depth, _undertone);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Build your universal profile',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use this when you do not know a current product shade. The colour below is an approximate profile sample.',
            ),
            const SizedBox(height: 20),
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: sample,
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(16),
              child: Text(
                'D${_depth.toString().padLeft(2, '0')}–$_undertone',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: readableTextColor(sample),
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Depth D${_depth.toString().padLeft(2, '0')}'),
            Slider(
              value: _depth.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              label: 'D${_depth.toString().padLeft(2, '0')}',
              onChanged: (value) => setState(() => _depth = value.round()),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _undertone,
              decoration: const InputDecoration(labelText: 'Undertone'),
              items: widget.repository.undertones
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.code,
                      child: Text('${item.code} · ${item.name}'),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) setState(() => _undertone = value);
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.pop(
                context,
                (depth: _depth, undertone: _undertone),
              ),
              icon: const Icon(Icons.check),
              label: const Text('Use this profile'),
            ),
          ],
        ),
      ),
    );
  }
}
