import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStore extends ChangeNotifier {
  FavoritesStore._(this._preferences, this._ids);

  static const _key = 'favorite_shade_ids_v1';

  static Future<FavoritesStore> load() async {
    final preferences = await SharedPreferences.getInstance();
    return FavoritesStore._(
      preferences,
      (preferences.getStringList(_key) ?? const []).toSet(),
    );
  }

  final SharedPreferences _preferences;
  final Set<String> _ids;

  Set<String> get ids => Set.unmodifiable(_ids);

  bool contains(String id) => _ids.contains(id);

  Future<void> toggle(String id) async {
    if (!_ids.add(id)) _ids.remove(id);
    await _preferences.setStringList(_key, _ids.toList(growable: false));
    notifyListeners();
  }

  Future<void> clear() async {
    _ids.clear();
    await _preferences.remove(_key);
    notifyListeners();
  }
}
