import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/sale.dart';
import '../models/inventory_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('MusikaKhula.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await _createDB(db, version);
        await _seedInitialData(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _createDB(db, newVersion);
        await _seedInitialData(db);
      },
      onOpen: (db) async {
        await _createDB(db, 3);
        await _seedInitialData(db);
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_name TEXT NOT NULL,
        category TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        cost_price REAL NOT NULL,
        currency TEXT DEFAULT 'USD',
        payment_method TEXT DEFAULT 'Cash',
        sale_date TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS inventory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_name TEXT NOT NULL UNIQUE,
        category TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        cost_price REAL NOT NULL,
        low_stock_threshold INTEGER DEFAULT 10,
        is_synced INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _seedInitialData(Database db) async {
    try {
      final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM inventory');
      final count = Sqflite.firstIntValue(countResult) ?? 0;
      if (count == 0) {
        final initialItems = [
          {'product_name': 'banana', 'category': 'Groceries', 'quantity': 199, 'cost_price': 0.50, 'low_stock_threshold': 10},
          {'product_name': 'tomatoes', 'category': 'Groceries', 'quantity': 150, 'cost_price': 0.80, 'low_stock_threshold': 10},
          {'product_name': 'beans', 'category': 'Groceries', 'quantity': 60, 'cost_price': 1.20, 'low_stock_threshold': 10},
          {'product_name': 'chips', 'category': 'Groceries', 'quantity': 1870, 'cost_price': 0.30, 'low_stock_threshold': 10},
          {'product_name': 'bread', 'category': 'Groceries', 'quantity': 20, 'cost_price': 1.00, 'low_stock_threshold': 10},
          {'product_name': 'lacto', 'category': 'Groceries', 'quantity': 600, 'cost_price': 1.50, 'low_stock_threshold': 10},
        ];
        for (var item in initialItems) {
          await db.insert('inventory', item, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
    } catch (e) {
      // Handle seeding error gracefully if table is not yet ready
    }
  }

  // SALES

  Future<int> insertSale(Sale sale) async {
    final db = await database;
    final id = await db.insert('sales', sale.toMap());
    await _decrementStock(sale.productName, sale.quantity);
    return id;
  }

  Future<List<Sale>> getAllSales() async {
    final db = await database;
    final maps = await db.query('sales', orderBy: 'sale_date DESC');
    return maps.map((m) => Sale.fromMap(m)).toList();
  }

  Future<List<Sale>> getTodaysSales() async {
    final db = await database;
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).toIso8601String();
    final end = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();
    final maps = await db.query(
      'sales',
      where: 'sale_date BETWEEN ? AND ?',
      whereArgs: [start, end],
      orderBy: 'sale_date DESC',
    );
    return maps.map((m) => Sale.fromMap(m)).toList();
  }

  Future<List<Sale>> getUnsyncedSales() async {
    final db = await database;
    final maps = await db.query('sales', where: 'is_synced = 0');
    return maps.map((m) => Sale.fromMap(m)).toList();
  }

  Future<void> markSaleSynced(int id) async {
    final db = await database;
    await db.update('sales', {'is_synced': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  // Exclude 'Credit given (Chikwereti)' so dashboard reflects actual liquid cash flow
  Future<double> getTotalRevenue() async {
    final db = await database;
    final result = await db.rawQuery(
        "SELECT SUM(unit_price * quantity) as total FROM sales WHERE payment_method != 'Credit given (Chikwereti)'");
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalProfit() async {
    final db = await database;
    final result = await db.rawQuery(
        "SELECT SUM((unit_price - cost_price) * quantity) as total FROM sales WHERE payment_method != 'Credit given (Chikwereti)'");
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalExpenses() async {
    final db = await database;
    final result = await db.rawQuery(
        "SELECT SUM(cost_price * quantity) as total FROM sales WHERE payment_method != 'Credit given (Chikwereti)'");
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> getTotalUnitsSold() async {
    final db = await database;
    final result =
    await db.rawQuery('SELECT SUM(quantity) as total FROM sales');
    return (result.first['total'] as int?) ?? 0;
  }

  // INVENTORY

  Future<int> insertInventoryItem(InventoryItem item) async {
    final db = await database;
    return await db.insert(
      'inventory',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<InventoryItem>> getAllInventory() async {
    final db = await database;
    final maps = await db.query('inventory', orderBy: 'product_name ASC');
    return maps.map((m) => InventoryItem.fromMap(m)).toList();
  }

  Future<void> updateStock(int id, int newQuantity) async {
    final db = await database;
    await db.update('inventory', {'quantity': newQuantity, 'is_synced': 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateInventoryItem(InventoryItem item) async {
    final db = await database;
    return await db.update(
      'inventory',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteInventoryItem(int id) async {
    final db = await database;
    return await db.delete(
      'inventory',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> _decrementStock(String productName, int soldQty) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE inventory SET quantity = MAX(0, quantity - ?), is_synced = 0 WHERE product_name = ?',
      [soldQty, productName],
    );
  }

  Future<int> getTotalProductCount() async {
    final db = await database;
    final result =
    await db.rawQuery('SELECT COUNT(*) as count FROM inventory');
    return (result.first['count'] as int?) ?? 0;
  }
}
