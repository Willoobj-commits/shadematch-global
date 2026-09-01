import 'package:flutter/material.dart';

import '../core/data/catalog_repository.dart';
import '../core/data/favorites_store.dart';
import 'about_screen.dart';
import 'brands_screen.dart';
import 'explore_screen.dart';
import 'match_screen.dart';
import 'saved_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    required this.repository,
    required this.favorites,
    super.key,
  });

  final CatalogRepository repository;
  final FavoritesStore favorites;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      MatchScreen(repository: widget.repository, favorites: widget.favorites),
      ExploreScreen(repository: widget.repository, favorites: widget.favorites),
      BrandsScreen(repository: widget.repository),
      SavedScreen(repository: widget.repository, favorites: widget.favorites),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.water_drop_outlined, size: 21),
            SizedBox(width: 8),
            Text('ShadeMatch Global'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Method and evidence',
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => AboutScreen(repository: widget.repository),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.compare_arrows_outlined),
            selectedIcon: Icon(Icons.compare_arrows),
            label: 'Match',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Shades',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Brands',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Saved',
          ),
        ],
      ),
    );
  }
}
