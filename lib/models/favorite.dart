import 'package:flutter/material.dart';
import 'package:pokepoke/db/favorites.dart';

class Favorite {
  final int pokeId;

  Favorite({
    required this.pokeId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': pokeId,
    };
  }
}

class FavoritesNotifier extends ChangeNotifier {
  final List<Favorite> _favs = [];

  FavoritesNotifier() {
    syncDb();
  }

  List<Favorite> get favs => _favs;

  void toggle(Favorite fav) {
    if (isExist(fav.pokeId)) {
      delete(fav.pokeId);
    } else {
      add(fav);
    }
  }

  bool isExist(int id) {
    print(favs.indexWhere((fav) => fav.pokeId == id));
    if (_favs.indexWhere((fav) => fav.pokeId == id) < 0) {
      return false;
    } else {
      return true;
    }
  }

  void syncDb() async {
    FavoritesDb.read().then(
      (val) => _favs
        ..clear()
        ..addAll(val),
    );
    notifyListeners();
  }

  void add(Favorite fav) async {
    await FavoritesDb.create(fav);
    syncDb();
  }

  void delete(int id) async {
    try {
      await FavoritesDb.delete(id);
      syncDb();
    } catch (e) {
      print(e);
    }
  }
}
