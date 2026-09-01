import 'package:flutter/material.dart';

import 'app.dart';
import 'core/data/catalog_repository.dart';
import 'core/data/favorites_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = await CatalogRepository.loadFromAssets();
  final favorites = await FavoritesStore.load();
  runApp(
    ShadeMatchApp(
      repository: repository,
      favorites: favorites,
    ),
  );
}
