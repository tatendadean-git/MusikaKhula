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
    // Linux/desktop support
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sales (
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
      CREATE TABLE inventory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_name TEXT NOT NULL,
        category TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        cost_price REAL NOT NULL,
        low_stock_threshold INTEGER DEFAULT 10,
        is_synced INTEGER DEFAULT 0
      )
    ''');
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

  Future<double> getTotalRevenue() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT SUM(unit_price * quantity) as total FROM sales');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalProfit() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT SUM((unit_price - cost_price) * quantity) as total FROM sales');
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
    return await db.insert('inventory', item.toMap());
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