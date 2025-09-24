import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'task.dart';

class TaskDatabase {
  static final TaskDatabase instance = TaskDatabase._init();
  static Database? _database;

  TaskDatabase._init();

  // Lấy database, nếu chưa có thì tạo mới
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  // Khởi tạo database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath(); // đường dẫn mặc định
    final path = join(dbPath, filePath);

    // mở hoặc tạo mới database
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Hàm tạo bảng tasks trong SQLite
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        isDone INTEGER NOT NULL
      )
    ''');
  }

  // Thêm 1 task mới
  Future<int> insertTask(Task task) async {
    final db = await instance.database;
    return await db.insert('tasks', task.toMap());
  }

  // Lấy tất cả task trong database
  Future<List<Task>> getTasks() async {
    final db = await instance.database;
    final result = await db.query(
        'tasks',
        orderBy: 'id DESC',
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  // Cập nhật trạng thái hoặc nội dung của task
  Future<int> updateTask(Task task) async {
    final db = await instance.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Xóa 1 task theo id
  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Tìm task theo tiêu đề (có chứa từ khóa)
  Future<List<Task>> searchTasks(String keyword) async {
    final db = await instance.database;
    final result = await db.query(
      'tasks',
      where: 'title LIKE ?',
      whereArgs: ['%$keyword%'],
      orderBy: 'id DESC',
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  // Đóng database (giải phóng tài nguyên)
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
