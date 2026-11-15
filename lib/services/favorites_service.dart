import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';

class FavoritesService {
  static const String _key = 'favorite_cities';

  Future<List<CityLocation>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_key);
    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }

    return jsonList.map((item) {
      final Map<String, dynamic> map = json.decode(item);
      return CityLocation.fromJson(map);
    }).toList();
  }

  Future<bool> isFavorite(CityLocation city) async {
    final favorites = await getFavorites();
    return favorites.any((c) => c.name.toLowerCase() == city.name.toLowerCase());
  }

  Future<List<CityLocation>> toggleFavorite(CityLocation city) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    final index = favorites.indexWhere((c) => c.name.toLowerCase() == city.name.toLowerCase());
    if (index >= 0) {
      favorites.removeAt(index);
    } else {
      favorites.add(city);
    }

    final jsonList = favorites.map((c) => json.encode(c.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
    return favorites;
  }
}
