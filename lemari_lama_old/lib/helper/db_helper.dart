import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> initDB() async {
    if (_database != null) return _database!;
    String path = join(await getDatabasesPath(), 'lemari_lama.db');
    
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE log_block_user(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_user TEXT,
            alasan TEXT,
            created_at TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE log_delete_product(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_produk TEXT,
            alasan TEXT,
            created_at TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE log_report_product(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_pelapor TEXT,
            id_produk TEXT,
            alasan TEXT,
            created_at TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE log_collection_product(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_user TEXT,
            id_produk TEXT,
            created_at TEXT
          )
        ''');
      },
    );
    return _database!;
  }
  
  // log_block_user
  static Future<int> insertLogBlockUser(Map<String, dynamic> data) async {
    final db = await initDB();
    return await db.insert('log_block_user', data);
  }
  static Future<List<Map<String, dynamic>>> getAllBlockedUsersLog() async {
    final db = await initDB();
    return await db.query('log_block_user', orderBy: 'created_at DESC');
  }

  // log_delete_product
  static Future<int> insertLogDeleteProduct(Map<String, dynamic> data) async {
    final db = await initDB();
    return await db.insert('log_delete_product', data);
  }
  static Future<List<Map<String, dynamic>>> getAllDeletedProductsLog() async {
    final db = await initDB();
    return await db.query('log_delete_product', orderBy: 'created_at DESC');
  }

  // log_report_product
  static Future<int> insertLogReportProduct(Map<String, dynamic> data) async {
    final db = await initDB();
    return await db.insert('log_report_product', data);
  }
  static Future<List<Map<String, dynamic>>> getAllReportedProductsLog() async {
    final db = await initDB();
    return await db.query('log_report_product', orderBy: 'created_at DESC');
  }

  // log_collection_product
  static Future<int> insertLogCollectionProduct(Map<String, dynamic> data) async {
    final db = await initDB();
    return await db.insert('log_collection_product', data);
  }
  static Future<List<Map<String, dynamic>>> getAllCollectionProductsLogByUser(String uid) async {
    final db = await initDB();
    return await db.query('log_collection_product', where: "id_user = ?", whereArgs: [uid], orderBy: 'created_at DESC');
  }
  static Future<int> deleteLogCollectionProduct(String uid, String pid) async {
    final db = await initDB();
    return await db.delete('log_collection_product', where: "id_user = ? AND id_produk = ?", whereArgs: [uid, pid],
    );
  }
}
