import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:exasignmt/models/repomodel.dart';
import 'dart:convert';

class DatabaseHelper {
  static const _databaseName = "RepoDatabase.db";
  static const _databaseVersion = 1;
  static const table = 'github_repos';
  static const columnId = 'id'; // Assuming a single row, so a fixed id
  static const columnData = 'data';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnData TEXT NOT NULL
      )
    ''');
  }

  // Insert the entire RepoModel object
  Future<void> insertRepos(RepoModel repoModel) async {
    Database db = await database;
    String serializedData = json.encode(repoModel.toJson());
    await db.insert(table, {columnId: 0, columnData: serializedData},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Retrieve the RepoModel object
  Future<RepoModel?> getRepos() async {
    Database db = await database;
    List<Map> maps = await db.query(table,
        columns: [columnId, columnData], where: '$columnId = 0');
    if (maps.isNotEmpty) {
      return RepoModel.fromJson(json.decode(maps.first[columnData]));
    }
    return null;
  }

  // Delete the RepoModel object (if needed)
  Future<void> deleteRepos() async {
    Database db = await database;
    await db.delete(table, where: '$columnId = 0');
  }
}
