import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shade_match_global/app.dart';
import 'package:shade_match_global/core/data/catalog_repository.dart';
import 'package:shade_match_global/core/data/favorites_store.dart';
import 'package:shade_match_global/core/models/shade.dart';
import 'package:shade_match_global/core/models/visual_reference.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders the ShadeMatch app shell', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repository = CatalogRepository.fromData(
      shades: const [
        Shade(
          id: 'fixture-shade',
          brandId: 'fixture-brand',
          brandName: 'Fixture Beauty',
          origin: 'Test',
          marketScope: 'Test',
          productId: 'fixture-product',
          productName: 'Fixture Foundation',
          productType: 'Foundation',
          shadeCode: 'D15N',
          universalDepth: 15,
          depthFamily: 'Medium',
          undertoneCode: 'N',
          undertoneName: 'Neutral',
          universalProfile: 'D15-N',
          status: 'Current',
          normalizationBasis: 'Test fixture',
          sourceUrl: 'https://example.com',
          sourceType: 'Test source',
          verifiedDate: '2026-09-01',
          qualityFlags: [],
          visualReferences: [
            VisualReference(
              id: 'fixture-visual',
              kind: 'universal_profile_estimate',
              label: 'Profile sample',
              displayHex: '#A47C65',
              verificationStatus: 'system_generated',
              rightsStatus: 'generated_in_app',
              matchEligible: false,
              isPrimary: true,
            ),
          ],
        ),
      ],
      brands: const [
        BrandDirectoryEntry(
          id: 'fixture-brand',
          name: 'Fixture Beauty',
          dataStatus: 'verified',
          sourceStatus: 'Test source',
        ),
      ],
      undertones: const [
        UndertoneDefinition(code: 'N', name: 'Neutral', vector: [0, 0]),
      ],
    );
    final favorites = await FavoritesStore.load();

    await tester.pumpWidget(
      ShadeMatchApp(repository: repository, favorites: favorites),
    );
    await tester.pump();

    expect(find.text('ShadeMatch Global'), findsOneWidget);
    expect(find.text('Match'), findsWidgets);
    expect(find.text('Shades'), findsOneWidget);
    expect(find.text('Brands'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
  });
}
