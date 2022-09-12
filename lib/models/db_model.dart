import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import './todo_model.dart';

class DatabaseConnect {
  Database? _database;

  // veritabanını açmak için bir getter
  Future<Database> get database async {
    // veritabanımızın cihaz içindeki yeri
    final dbpath = await getDatabasesPath();
    const dbname = 'todo.db'; // veritabanının adı
    final path = join(dbpath, dbname); // veritabanının full adresi
    print("path : $path");

    // veritabanına ilk erişim
    _database = await openDatabase(path, version: 1, onCreate: _createDB);
    return _database!;
  }

  // tablo oluşturuluyor.
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todo (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        title TEXT, 
        creationDate TEXT, 
        isChecked INTEGER
      )
    ''');
  }

  // Veri ekleme fonksiyonu
  Future<void> insertTodo(Todo todo) async {
    final db = await database;
    // veri ekleme işlemi
    await db.insert(
      "todo", // tablo adı
      todo.toMap(), // oluşturduğumuz map verisi
      conflictAlgorithm: ConflictAlgorithm.replace, // tekrarlara yer vermiyor.
    );
  }

  // Veri silme fonksiyonu
  Future<void> deleteTodo(Todo todo) async {
    final db = await database;
    await db.delete(
      'todo',
      where: 'id == ?', // tabloda id var mı ? kontrolü
      whereArgs: [todo.id],
    );
  }

  // Fetch fonksiyonu
  Future<List<Todo>> getTodo() async{
    final db = await database;
    List<Map<String, dynamic>> items = await db.query(
      'todo',
      orderBy: 'id DESC',  // azalan sırada listeler
    );
    // en son toto item en başta listelenecek.
    // item 'ları map'ten, to do listesine çevirelim.
    return List.generate(
      items.length,
      (i) => Todo(
        id: items[i]['id'],
        title: items[i]['title'],
        // String formatı, tarih formatına dönüştü
        creationDate: DateTime.parse(items[i]['creationDate']),
        isChecked: items[i]['isChecked'] == 1 ? true : false,
      ),
    );
  }
}















