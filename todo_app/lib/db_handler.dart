import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'package:todo_app/todo.dart';

class DbHandler {
  Future<Database> getDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    final db = await sql.openDatabase(path.join(dbPath, 'todo.db'),
        onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE todo_list(id TEXT PRIMARY KEY, title TEXT, description TEXT, date TEXT, time TEXT)');
    }, version: 1);

    return db;
  }

 

  Future<List<Todo>> getDataList() async {
    final db = await getDatabase();
    final data = await db.query('todo_list');
    final todo = data
        .map((row) => Todo(
            id: row['id'] as String,
            title: row['title'] as String,
            desc: row['description'] as String,
            date: row['date'] as String,
            time: row['time'] as String))
        .toList();

    return todo;
  }

  Future<void> deleteData(String id) async {
    final db = await getDatabase();
     await db.delete('todo_list', where: 'id = ?', whereArgs: [id]);
  }
}
