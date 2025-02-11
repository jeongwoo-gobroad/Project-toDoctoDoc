import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

_onDbCreate(Database db, int version) async {
  await db.execute(
      '''
      CREATE TABLE chat_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        room_id TEXT NOT NULL,
        doctor_id TEXT NOT NULL,
        message TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        role TEXT NOT NULL
      )
      '''
  );
  await db.execute(
      '''
      CREATE TABLE chat_meta (
        room_id TEXT PRIMARY KEY,
        last_read_id INTEGER NOT NULL DEFAULT 1
      )
      '''
  );
}

initDatabase() async {
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  var dbPath = await getDatabasesPath();
  var joinPath = path.join(dbPath, 'chat_database.db');

  print('PATH ------------------ ');
  print(dbPath);
  print(joinPath);

  if (!kIsWeb) {
    var exists = await databaseExists(joinPath);

    if (!exists) {
      try {
        await Directory(path.dirname(joinPath)).create(recursive: true);
      } catch (_) {}
      ByteData data = await rootBundle.load(path.join("asset/db", "chat_database.db"));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(joinPath).writeAsBytes(bytes, flush: true);
    }
  }

  var db = await openDatabase(
  joinPath,
  version: 2,
  onCreate: _onDbCreate,
  onUpgrade: (db, oldVersion, newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        '''
        CREATE TABLE chat_meta (
          room_id TEXT PRIMARY KEY,
          last_read_id INTEGER NOT NULL DEFAULT 1
        )
        '''
      );
    }
  },
);
}

class ChatDatabase {
  late var db;

  ChatDatabase() {
    openDb();
  }

  openDb() async {
    var dbPath = await getDatabasesPath();
    db = await openDatabase(path.join(dbPath, 'chat_database.db'));
  }
  
  saveChat(String chatId, String doctorId, String message, DateTime time, String role) async {
    await db.insert('chat_messages', <String, dynamic>{'room_id':chatId, 'doctor_id':doctorId, 'message': message, 'timestamp': time.toString(), 'role': role});

    var i = await db.rawQuery('SELECT * from chat_messages');
    print('QUERY SaveChat function');
    print(i.toString());
  }

  loadChat(String chatId) async {
    var chatData = await db.rawQuery('SELECT * from chat_messages WHERE room_id = ?', [chatId]);
    print(chatData);
    return chatData;
  }
  Future<int> getLastReadId(String roomId) async {
  var result = await db.query('chat_meta', where: 'room_id = ?', whereArgs: [roomId]);
  if (result.isNotEmpty) {
    return result.first['last_read_id'] as int;
  } else {
    //존재하지 않으면 초기값 0
    await db.insert('chat_meta', {'room_id': roomId, 'last_read_id': 1});
    return 0;
  }

}
Future<void> updateLastReadId(String roomId, int newLastReadId) async {
  var count = await db.update('chat_meta', {'last_read_id': newLastReadId}, where: 'room_id = ?', whereArgs: [roomId]);
  if (count == 0) {
    await db.insert('chat_meta', {'room_id': roomId, 'last_read_id': newLastReadId});
  }
}
}


