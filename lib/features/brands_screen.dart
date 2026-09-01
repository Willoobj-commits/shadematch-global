import 'package:flutter/material.dart';

import '../core/data/catalog_repository.dart';
import '../core/models/shade.dart';

class BrandsScreen extends StatefulWidget {
  const BrandsScreen({required this.repository, super.key});

  final CatalogRepository repository;

  @override
  State<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final shadeCountByBrand = <String, int>{};
    for (final shade in widget.repository.shades) {
      shadeCountByBrand.update(shade.brandName, (value) => value + 1,
          ifAbsent: () => 1);
    }
    final brands = widget.repository.brands
        .where(
            (brand) => brand.name.toLowerCase().contains(_query.toLowerCase()))
        .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Worldwide brand directory',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Only brands with verified shade-level data produce matches. Queued brands remain visible without fabricated results.',
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search brands',
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 28),
            itemCount: brands.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final brand = brands[index];
              return _BrandTile(
                brand: brand,
                shadeCount: shadeCountByBrand[brand.name] ?? 0,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BrandTile extends StatelessWidget {
  const _BrandTile({required this.brand, required this.shadeCount});

  final BrandDirectoryEntry brand;
  final int shadeCount;

  @override
  Widget build(BuildContext context) {
    final verified = brand.isVerified;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: verified
              ? const Color(0xFFE0F3E8)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(
            verified ? Icons.verified_outlined : Icons.schedule_outlined,
            color: verified ? const Color(0xFF286345) : null,
          ),
        ),
        title: Text(brand.name,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(
          verified
              ? '$shadeCount verified shades · matchable'
              : 'Directory listing · awaiting shade data',
        ),
        trailing: Text(
          verified ? 'VERIFIED' : 'QUEUED',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: verified
                    ? const Color(0xFF286345)
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}
