import 'package:path/path.dart';
import 'package:pokepoke/const/db.dart';
import 'package:pokepoke/models/favorite.dart';
import 'package:sqflite/sqflite.dart';

class FavoritesDb {
  static Future<Database> openDb() async {
    return await openDatabase(
      join(await getDatabasesPath(), favFileName),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE $favTableName(id INTGER PRIMARY KEY)',
        );
      },
      version: 1,
    );
  }

  static Future<void> create(Favorite fav) async {
    var db = await openDb();
    await db.insert(
      favTableName,
      fav.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Favorite>> read() async {
    var db = await openDb();
    final List<Map<String, dynamic>> maps = await db.query(favTableName);
    return List.generate(maps.length, (index) {
      return Favorite(
        pokeId: maps[index]['id'],
      );
    });
  }

  static Future<void> delete(int pokeId) async {
    var db = await openDb();
    await db.delete(
      favTableName,
      where: 'id = ?',
      whereArgs: [pokeId],
    );
  }
}
