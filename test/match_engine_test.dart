import 'package:flutter_test/flutter_test.dart';
import 'package:shade_match_global/core/models/shade.dart';
import 'package:shade_match_global/core/models/visual_reference.dart';
import 'package:shade_match_global/core/services/match_engine.dart';

void main() {
  const undertones = [
    UndertoneDefinition(code: 'N', name: 'Neutral', vector: [0, 0]),
    UndertoneDefinition(code: 'W', name: 'Warm', vector: [1, 0]),
    UndertoneDefinition(code: 'C', name: 'Cool', vector: [-1, 0.4]),
    UndertoneDefinition(code: 'U', name: 'Unknown'),
  ];
  const engine = MatchEngine(undertones);

  test('ranks an exact profile ahead of a nearby profile', () {
    final results = engine.bestPerBrand(
      referenceDepth: 15,
      referenceUndertone: 'N',
      shades: [
        shade('warm', brand: 'Warm Brand', depth: 15, undertone: 'W'),
        shade('exact', brand: 'Exact Brand', depth: 15, undertone: 'N'),
      ],
    );

    expect(results.first.shade.id, 'exact');
    expect(results.first.grade, 'Very close profile');
  });

  test('does not present a distant depth as a match', () {
    final results = engine.bestPerBrand(
      referenceDepth: 30,
      referenceUndertone: 'N',
      shades: [shade('far', brand: 'Far Brand', depth: 13, undertone: 'N')],
    );

    expect(results, isEmpty);
  });

  test('returns one best candidate per brand and can exclude source brand', () {
    final results = engine.bestPerBrand(
      referenceDepth: 12,
      referenceUndertone: 'N',
      excludeBrand: 'Source Brand',
      shades: [
        shade('source', brand: 'Source Brand', depth: 12, undertone: 'N'),
        shade('near', brand: 'Other Brand', depth: 13, undertone: 'N'),
        shade('best', brand: 'Other Brand', depth: 12, undertone: 'N'),
      ],
    );

    expect(results, hasLength(1));
    expect(results.single.shade.id, 'best');
  });

  test('marks unpublished undertones as limited evidence', () {
    final results = engine.bestPerBrand(
      referenceDepth: 12,
      referenceUndertone: 'N',
      shades: [shade('unknown', brand: 'Brand', depth: 12, undertone: 'U')],
    );

    expect(results.single.confidence, 'Limited evidence');
  });
}

Shade shade(
  String id, {
  required String brand,
  required int depth,
  required String undertone,
}) {
  return Shade(
    id: id,
    brandId: 'brand-$brand',
    brandName: brand,
    origin: 'Test',
    marketScope: 'Test',
    productId: 'product-$brand',
    productName: 'Test Foundation',
    productType: 'Foundation',
    shadeCode: id,
    universalDepth: depth,
    depthFamily: 'Test',
    undertoneCode: undertone,
    undertoneName: undertone,
    universalProfile: 'D${depth.toString().padLeft(2, '0')}-$undertone',
    status: 'Current',
    normalizationBasis: 'Test',
    sourceUrl: 'https://example.com',
    sourceType: 'Test source',
    verifiedDate: '2026-08-31',
    qualityFlags: const [],
    visualReferences: [
      VisualReference(
        id: 'visual-$id',
        kind: 'universal_profile_estimate',
        label: 'Profile sample',
        displayHex: '#A47C65',
        verificationStatus: 'system_generated',
        rightsStatus: 'generated_in_app',
        matchEligible: false,
        isPrimary: true,
      ),
    ],
  );
}
