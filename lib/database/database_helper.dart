import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

import 'package:wallet_app/models/category_model.dart';
import 'package:wallet_app/models/transaction_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<void> initDatabaseFactory() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    await initDatabaseFactory();
    _database = await _initDB('wallet.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        type TEXT,
        amount REAL,
        category TEXT,
        description TEXT,
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT
      )
    ''');

    const uuid = Uuid();
    await db.insert('categories', {'id': uuid.v4(), 'name': 'Salário'});
    await db.insert('categories', {'id': uuid.v4(), 'name': 'Alimentação'});
    await db.insert('categories', {'id': uuid.v4(), 'name': 'Transporte'});
    await db.insert('categories', {'id': uuid.v4(), 'name': 'Lazer'});
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS transactions');
      await db.execute('DROP TABLE IF EXISTS categories');
      await _createDB(db, newVersion);
    }
  }

  Future<void> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    await db.insert('transactions', transaction.toMap());
  }

  Future<void> debugDates() async {
    final db = await database;
    final maps = await db.query('transactions');
    for (var map in maps) {
      print('ID: ${map['id']}, Date: ${map['date']}');
    }
  }

  Future<List<TransactionModel>> getTransactions() async {
    final db = await database;
    final maps = await db.query('transactions', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  Future<double> getBalance() async {
    final db = await database;
    final maps = await db.query('transactions');
    double balance = 0.0;
    for (var map in maps) {
      if (map['type'] == 'income') {
        balance += map['amount'] as double;
      } else {
        balance -= map['amount'] as double;
      }
    }
    return balance;
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final maps = await db.query('categories');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<void> insertCategory(Category category) async {
    final db = await database;
    await db.insert('categories', category.toMap());
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
