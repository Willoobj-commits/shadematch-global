import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/shade.dart';

class CatalogRepository {
  CatalogRepository._({
    required this.shades,
    required this.brands,
    required this.undertones,
    required this.release,
    required this.visualPolicy,
  }) : _shadeById = {for (final shade in shades) shade.id: shade};

  factory CatalogRepository.fromData({
    required List<Shade> shades,
    required List<BrandDirectoryEntry> brands,
    required List<UndertoneDefinition> undertones,
    Map<String, dynamic> release = const {},
    Map<String, dynamic> visualPolicy = const {},
  }) {
    return CatalogRepository._(
      shades: List.unmodifiable(shades),
      brands: List.unmodifiable(brands),
      undertones: List.unmodifiable(undertones),
      release: Map.unmodifiable(release),
      visualPolicy: Map.unmodifiable(visualPolicy),
    );
  }

  static Future<CatalogRepository> loadFromAssets() async {
    final raw = await rootBundle.loadString('assets/data/catalog_v1.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return CatalogRepository._(
      shades: (json['shades'] as List<dynamic>)
          .map((item) => Shade.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      brands: (json['brandDirectory'] as List<dynamic>)
          .map(
            (item) =>
                BrandDirectoryEntry.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
      undertones: (json['undertones'] as List<dynamic>)
          .map(
            (item) =>
                UndertoneDefinition.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
      release: Map<String, dynamic>.from(json['release'] as Map),
      visualPolicy: Map<String, dynamic>.from(json['visualPolicy'] as Map),
    );
  }

  final List<Shade> shades;
  final List<BrandDirectoryEntry> brands;
  final List<UndertoneDefinition> undertones;
  final Map<String, dynamic> release;
  final Map<String, dynamic> visualPolicy;
  final Map<String, Shade> _shadeById;

  Shade? shadeById(String id) => _shadeById[id];

  List<Shade> searchShades(
    String query, {
    int? depth,
    String? undertone,
    String? brand,
    bool currentOnly = true,
    int limit = 120,
  }) {
    final normalized = query.trim().toLowerCase();
    final terms =
        normalized.split(RegExp(r'\s+')).where((term) => term.isNotEmpty);
    final results = <Shade>[];
    for (final shade in shades) {
      if (currentOnly && !shade.isCurrent) continue;
      if (depth != null && shade.universalDepth != depth) continue;
      if (undertone != null && shade.undertoneCode != undertone) continue;
      if (brand != null && shade.brandName != brand) continue;
      if (terms.any((term) => !shade.searchText.contains(term))) continue;
      results.add(shade);
      if (results.length >= limit) break;
    }
    return results;
  }

  List<String> get verifiedBrands {
    final values = shades.map((shade) => shade.brandName).toSet().toList();
    values.sort();
    return values;
  }
}
