// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/model/todo_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'todo_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todo(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        isDone INTEGER
      )
      ''');
  }

  Future<int> insertTodoItem(TodoItem item) async {
    final db = await database;
    return await db.insert(
      'todo',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TodoItem>> getTodoItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todo');

    return List.generate(maps.length, (i) {
      return TodoItem(
        id: maps[i]['id'],
        title: maps[i]['title'],
        isDone: maps[i]['isDone'] == 1,
      );
    });
  }

  Future<void> updateTodoItem(TodoItem item) async {
    final db = await database;
    await db.update(
      'todo',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteTodoItem(int id) async {
    final db = await database;
    await db.delete(
      'todo',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
