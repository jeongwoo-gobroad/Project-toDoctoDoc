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
}

initDatabase() async {
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }else {
    databaseFactory = databaseFactoryFfi;
    sqfliteFfiInit();
  }

  var dbPath = await getDatabasesPath();
  var db = await openDatabase(path.join(dbPath, 'chat_database'), version: 4, onCreate: _onDbCreate);
}

class ChatDatabase {
  late var db;

  ChatDatabase() {
    openDb();
  }


  openDb() async {
    var dbPath = await getDatabasesPath();
    db = await openDatabase(path.join(dbPath, 'chat_database'));
  }


  saveChat(String chatId, String doctorId, String message, DateTime time, String role) async {
    //await db?.execute('INSERT INTO chat_messages (room_id, doctor_id, message, timestamp) VALUES ("${chatId}", "${doctorId}", "${message}", "${time.toString()}")');

    await db.insert('chat_messages', <String, dynamic>{'room_id':chatId, 'doctor_id':doctorId, 'message': message, 'timestamp': time.toString(), 'role': role});

    var i = await db.rawQuery('SELECT * from chat_messages');
    print('QUERY');
    print(i.toString());

    //print(i['room_id']);
  }

  loadChat(String chatId) async {
    var chatData = await db.rawQuery('SELECT * from chat_messages WHERE room_id = ?', [chatId]);
    print(chatData);
    return chatData;
  }
}


