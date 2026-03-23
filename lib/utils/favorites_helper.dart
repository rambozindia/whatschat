import 'dart:convert';

import 'package:localstorage/localstorage.dart';

class FavoritesHelper {
  static const String _key = 'favorites';

  static List<String> getFavorites() {
    final data = localStorage.getItem(_key);
    if (data != null) {
      return List<String>.from(json.decode(data));
    }
    return [];
  }

  static bool isFavorite(String number) {
    return getFavorites().contains(number);
  }

  static void toggleFavorite(String number) {
    final favorites = getFavorites();
    if (favorites.contains(number)) {
      favorites.remove(number);
    } else {
      favorites.add(number);
    }
    localStorage.setItem(_key, json.encode(favorites));
  }

  static void addFavorite(String number) {
    final favorites = getFavorites();
    if (!favorites.contains(number)) {
      favorites.add(number);
      localStorage.setItem(_key, json.encode(favorites));
    }
  }

  static void removeFavorite(String number) {
    final favorites = getFavorites();
    favorites.remove(number);
    localStorage.setItem(_key, json.encode(favorites));
  }
}
