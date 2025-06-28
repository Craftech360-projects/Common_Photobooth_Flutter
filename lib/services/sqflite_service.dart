// import 'package:path/path.dart';
// import 'package:photobooth_flutter/models/user_model.dart';
// import 'package:sqflite/sqflite.dart';

// class DatabaseService {
//   static final DatabaseService instance = DatabaseService._init();
//   static Database? _database;

//   DatabaseService._init();

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB('users.db');
//     return _database!;
//   }

//   Future<Database> _initDB(String filePath) async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, filePath);

//     return await openDatabase(path, version: 1, onCreate: _createDB);
//   }

//   Future _createDB(Database db, int version) async {
//     const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
//     const textType = 'TEXT NOT NULL';

//     await db.execute('''
// CREATE TABLE users ( 
//   id $idType, 
//   name $textType,
//   email $textType,
//   output_image_filename $textType
//   )
// ''');
//   }

//   Future<UserData> insertUser(UserData user) async {
//     final db = await instance.database;
//     final id = await db.insert('users', user.toMap());
//     return user.copyWith(id: id);
//   }

//   Future<List<UserData>> getAllUsers() async {
//     final db = await instance.database;
//     final result = await db.query('users', orderBy: 'id DESC');
//     return result.map((json) => UserData.fromMap(json)).toList();
//   }

//   Future<void> close() async {
//     final db = await instance.database;
//     db.close();
//   }
// }
