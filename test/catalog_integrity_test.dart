import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog carries a labeled visual fallback for every shade', () async {
    final file = File('assets/data/catalog_v1.json');
    final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final shades = data['shades'] as List<dynamic>;

    expect(shades, hasLength(1578));
    expect(shades.map((item) => (item as Map<String, dynamic>)['id']).toSet(),
        hasLength(1578));
    for (final item in shades) {
      final shade = item as Map<String, dynamic>;
      final visuals = shade['visualReferences'] as List<dynamic>;
      expect(visuals, isNotEmpty,
          reason: '${shade['id']} has no visual reference');
      final primary = visuals
          .cast<Map<String, dynamic>>()
          .where((visual) => visual['isPrimary'] == true)
          .toList(growable: false);
      expect(primary, hasLength(1));
      if (primary.single['kind'] == 'universal_profile_estimate') {
        expect(primary.single['matchEligible'], isFalse);
        expect(primary.single['disclaimer'], isNotEmpty);
      }
    }
  });
}
