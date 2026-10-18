import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'config.dart';
import 'event.dart';
import 'seed.dart';

class EventDatabase {
  EventDatabase._(this._db);

  final Database _db;

  static Future<EventDatabase> open({Directory? dataDir}) async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dir = dataDir ?? Directory(p.join(Directory.current.path, 'data'));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    final path = p.join(dir.path, ServerConfig.databaseFileName);
    final db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (database, version) async {
          await database.execute('''
CREATE TABLE events (
  id TEXT PRIMARY KEY NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  start TEXT NOT NULL,
  end TEXT NOT NULL,
  location TEXT NOT NULL,
  type TEXT NOT NULL,
  direction_id TEXT NOT NULL,
  course INTEGER NOT NULL,
  branch_id TEXT NOT NULL
)
''');
          final batch = database.batch();
          for (final event in SeedEvents.all) {
            batch.insert('events', _toRow(event));
          }
          await batch.commit(noResult: true);
        },
      ),
    );
    return EventDatabase._(db);
  }

  Future<List<EventRecord>> listEvents() async {
    final rows = await _db.query('events', orderBy: 'start ASC, title ASC');
    return rows.map(_fromRow).toList();
  }

  Future<EventRecord?> getEvent(String id) async {
    final rows = await _db.query('events', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  Future<bool> insertEvent(EventRecord event) async {
    try {
      await _db.insert('events', _toRow(event), conflictAlgorithm: ConflictAlgorithm.abort);
      return true;
    } on DatabaseException catch (error) {
      if (error.isUniqueConstraintError()) return false;
      rethrow;
    }
  }

  Future<bool> deleteEvent(String id) async {
    final count = await _db.delete('events', where: 'id = ?', whereArgs: [id]);
    return count > 0;
  }

  Future<void> close() => _db.close();

  static Map<String, Object?> _toRow(EventRecord event) => {
        'id': event.id,
        'title': event.title,
        'description': event.description,
        'start': EventRecord.encodeDate(event.start),
        'end': EventRecord.encodeDate(event.end),
        'location': event.location,
        'type': event.type,
        'direction_id': event.directionId,
        'course': event.course,
        'branch_id': event.branchId,
      };

  static EventRecord _fromRow(Map<String, Object?> row) {
    return EventRecord(
      id: row['id']! as String,
      title: row['title']! as String,
      description: row['description']! as String,
      start: DateTime.parse(row['start']! as String),
      end: DateTime.parse(row['end']! as String),
      location: row['location']! as String,
      type: row['type']! as String,
      directionId: row['direction_id']! as String,
      course: row['course']! as int,
      branchId: row['branch_id']! as String,
    );
  }
}
