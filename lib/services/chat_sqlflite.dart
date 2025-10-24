import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/chat_message.dart';
class ChatDatabase {
  static final ChatDatabase _instance = ChatDatabase._internal();
  factory ChatDatabase() => _instance;
  ChatDatabase._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final path = join(docsDir.path, 'chat_history.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE chats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        sender TEXT NOT NULL,
        isUser INTEGER NOT NULL DEFAULT 1,
        message TEXT NOT NULL,
        time TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldV, int newV) async {
    if (oldV < 2) {
      await db.execute(
          'ALTER TABLE chats ADD COLUMN userId TEXT DEFAULT ""');
    }
    if (oldV < 3) {
      await db.execute(
          'ALTER TABLE chats ADD COLUMN isUser INTEGER DEFAULT 1');
    }
  }

  Future<int> insertMessage(ChatMessage msg) async {
    final db = await database;
    return db.insert(
      'chats',
      msg.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Fetches the latest [limit] messages for a user (oldest → newest)
  Future<List<ChatMessage>> getLastMessages(String userId, int limit) async {
    final db = await database;
    final rows = await db.query(
      'chats',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'time DESC',
      limit: limit,
    );
    return rows.map(ChatMessage.fromMap).toList().reversed.toList();
  }

  /// Keeps only the last [keep] messages, deleting older ones
  Future<void> pruneToLastNForUser(String userId, int keep) async {
    final db = await database;
    final newest = await db.rawQuery(
      'SELECT id FROM chats WHERE userId = ? ORDER BY time DESC LIMIT ?',
      [userId, keep],
    );

    if (newest.isEmpty) return;

    final keepIds = newest.map((e) => e['id']).join(',');
    await db.rawDelete(
      'DELETE FROM chats WHERE userId = ? AND id NOT IN ($keepIds)',
      [userId],
    );
  }

  Future<void> clearUserMessages(String userId) async {
    final db = await database;
    await db.delete('chats', where: 'userId = ?', whereArgs: [userId]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _db = null;
  }
}



