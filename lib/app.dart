import 'package:flutter/material.dart';

import 'core/data/catalog_repository.dart';
import 'core/data/favorites_store.dart';
import 'features/app_shell.dart';

class ShadeMatchApp extends StatelessWidget {
  const ShadeMatchApp({
    required this.repository,
    required this.favorites,
    super.key,
  });

  final CatalogRepository repository;
  final FavoritesStore favorites;

  @override
  Widget build(BuildContext context) {
    const plum = Color(0xFF61245B);
    final scheme = ColorScheme.fromSeed(
      seedColor: plum,
      brightness: Brightness.light,
    );
    return MaterialApp(
      title: 'ShadeMatch Global',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF9F7),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: AppShell(repository: repository, favorites: favorites),
    );
  }
}
