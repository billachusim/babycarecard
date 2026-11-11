import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('baby_care_card.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE children (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        ageGroup TEXT NOT NULL,
        allergies TEXT,
        sex TEXT,
        birthDate TEXT,
        weight REAL,
        photoPath TEXT,
        personality TEXT,
        importantNotes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE feeding_schedules (
        id TEXT PRIMARY KEY,
        childId TEXT NOT NULL,
        name TEXT NOT NULL,
        time TEXT NOT NULL,
        amount TEXT NOT NULL,
        instructions TEXT,
        FOREIGN KEY (childId) REFERENCES children (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE care_routines (
        id TEXT PRIMARY KEY,
        childId TEXT NOT NULL,
        title TEXT NOT NULL,
        instructions TEXT NOT NULL,
        schedule TEXT,
        FOREIGN KEY (childId) REFERENCES children (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE medications (
        id TEXT PRIMARY KEY,
        childId TEXT NOT NULL,
        name TEXT NOT NULL,
        instructions TEXT NOT NULL,
        time TEXT NOT NULL,
        frequency TEXT,
        startDate TEXT,
        endDate TEXT,
        notes TEXT,
        FOREIGN KEY (childId) REFERENCES children (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE reminders (
        id TEXT PRIMARY KEY,
        childId TEXT NOT NULL,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        time TEXT NOT NULL,
        repeatRule TEXT,
        enabled INTEGER NOT NULL,
        FOREIGN KEY (childId) REFERENCES children (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE emergency_contacts (
        id TEXT PRIMARY KEY,
        childId TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        relationship TEXT,
        FOREIGN KEY (childId) REFERENCES children (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE pediatricians (
        id TEXT PRIMARY KEY,
        childId TEXT NOT NULL,
        name TEXT NOT NULL,
        clinic TEXT,
        phone TEXT,
        address TEXT,
        FOREIGN KEY (childId) REFERENCES children (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
