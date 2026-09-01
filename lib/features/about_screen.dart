import 'package:flutter/material.dart';

import '../core/data/catalog_repository.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({required this.repository, super.key});

  final CatalogRepository repository;

  @override
  Widget build(BuildContext context) {
    final release = repository.release;
    return Scaffold(
      appBar: AppBar(title: const Text('Method and visual evidence')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            'Know what each colour means',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 10),
          const Text(
            'ShadeMatch separates a useful visual reference from evidence that is strong enough to drive colour matching.',
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Stat(value: '${release['shadeCount']}', label: 'shade records'),
              _Stat(
                  value: '${release['verifiedBrandCount']}',
                  label: 'matchable brands'),
              _Stat(
                  value: '${release['directoryBrandCount']}',
                  label: 'directory brands'),
            ],
          ),
          const SizedBox(height: 18),
          const _MethodCard(
            icon: Icons.science_outlined,
            title: 'Measured colour',
            body:
                'Spectrophotometer or controlled, calibrated swatch data. This is preferred for numerical colour distance.',
          ),
          const SizedBox(height: 10),
          const _MethodCard(
            icon: Icons.verified_outlined,
            title: 'Official visual',
            body:
                'A manufacturer swatch or product image. It helps recognition but can still vary by screen, lighting and editing.',
          ),
          const SizedBox(height: 10),
          const _MethodCard(
            icon: Icons.palette_outlined,
            title: 'Universal profile sample',
            body:
                'A generated colour associated with the normalized depth and undertone profile. It is never treated as measured product colour.',
          ),
          const SizedBox(height: 18),
          Card(
            color: const Color(0xFFFFF2E5),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current release limitation',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'The source workbook contains manufacturer shade names, depth/undertone normalization and official product-page sources, but no licensed shade images or laboratory colour measurements. Every current chip is therefore labeled as a profile sample.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Matching safeguards',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
              '• Distant depth candidates are hidden instead of being called matches.'),
          const Text(
              '• Match grade and evidence confidence are shown separately.'),
          const Text('• Retired products are excluded by default.'),
          const Text('• Unpublished undertones reduce confidence.'),
          const Text(
              '• Formula, finish, oxidation and regional variants remain material.'),
          const SizedBox(height: 18),
          Text(
            'Dataset verified through ${release['verifiedThrough']}.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900)),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard(
      {required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
