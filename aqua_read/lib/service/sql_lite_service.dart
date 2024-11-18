import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../entities/results.dart';

class LocalDatabaseHelper {
  static final _databaseName = "TestResults.db";
  static final _databaseVersion = 1;

  static final table = 'test_results';
  static final columnId = 'id';
  static final columnTestDate = 'testDate';

  // 14 water quality test result columns
  static final columnPH = 'pH';
  static final columnTotalAlkalinity = 'totalAlkalinity';
  static final columnHardness = 'hardness';
  static final columnLead = 'lead';
  static final columnCopper = 'copper';
  static final columnIron = 'iron';
  static final columnChromiumCrVI = 'chromiumCrVI';
  static final columnFreeChlorine = 'freeChlorine';
  static final columnBromine = 'bromine';
  static final columnNitrate = 'nitrate';
  static final columnNitrite = 'nitrite';
  static final columnMercury = 'mercury';
  static final columnSulfite = 'sulfite';
  static final columnFluoride = 'fluoride';
  static final columnDetails = 'details';

  LocalDatabaseHelper._privateConstructor();
  static final LocalDatabaseHelper instance = LocalDatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTestDate TEXT NOT NULL,
        $columnPH TEXT,
        $columnTotalAlkalinity TEXT,
        $columnHardness TEXT,
        $columnLead TEXT,
        $columnCopper TEXT,
        $columnIron TEXT,
        $columnChromiumCrVI TEXT,
        $columnFreeChlorine TEXT,
        $columnBromine TEXT,
        $columnNitrate TEXT,
        $columnNitrite TEXT,
        $columnMercury TEXT,
        $columnSulfite TEXT,
        $columnFluoride TEXT,
        $columnDetails TEXT
      )
    ''');
  }

  // Insert a test result with all 14 parameters
  Future<int> insertTestResult(Result result) async {
    Database db = await database;
    return await db.insert(table, result.toMap());
  }

  // Get all test results
  Future<List<Map<String, dynamic>>> getTestResults() async {
    Database db = await database;
    return await db.query(table);
  }

  // Update a test result
  Future<int> updateTestResult(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Delete a test result
  Future<int> deleteTestResult(int id) async {
    Database db = await database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
