import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'config.dart';
import 'database.dart';
import 'event.dart';
import 'university.dart';

class EventsApi {
  EventsApi(this.db);

  final EventDatabase db;

  Router get router {
    final router = Router();
    router.get('/health', _health);
    router.get('/events', _list);
    router.post('/events', _create);
    router.delete('/events/<id>', _delete);
    router.get('/meta/university', _university);
    return router;
  }

  Response _health(Request request) {
    return _json({'ok': true, 'service': 'pgu_events_server'});
  }

  Future<Response> _list(Request request) async {
    final events = await db.listEvents();
    return _json(events.map((event) => event.toJson()).toList());
  }

  Future<Response> _create(Request request) async {
    if (!_isAdmin(request)) {
      return _json({'error': 'admin_only'}, status: 401);
    }

    Map<String, dynamic> body;
    try {
      body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return _json({'error': 'invalid_json'}, status: 400);
    }

    final event = EventRecord.fromJson(body);
    final validation = _validate(event);
    if (validation != null) {
      return _json({'error': validation}, status: 400);
    }

    final created = await db.insertEvent(event);
    if (!created) {
      return _json({'error': 'conflict'}, status: 409);
    }
    return _json(event.toJson(), status: 201);
  }

  Future<Response> _delete(Request request, String id) async {
    if (!_isAdmin(request)) {
      return _json({'error': 'admin_only'}, status: 401);
    }
    await db.deleteEvent(id);
    return _json({'ok': true});
  }

  Response _university(Request request) {
    return _json({
      'branches': UniversityCatalog.branches,
      'types': const [
        {'id': 'conference', 'label': 'Конференция'},
        {'id': 'olympiad', 'label': 'Олимпиада'},
        {'id': 'seminar', 'label': 'Семинар'},
        {'id': 'workshop', 'label': 'Воркшоп'},
        {'id': 'cultural', 'label': 'Культура'},
      ],
    });
  }

  bool _isAdmin(Request request) {
    return request.headers['x-admin-token'] == ServerConfig.adminToken;
  }

  String? _validate(EventRecord event) {
    if (event.id.trim().isEmpty) return 'missing_id';
    if (event.title.trim().isEmpty) return 'invalid_event';
    if (event.branchId.isEmpty || event.directionId.isEmpty) return 'invalid_event';
    if (!event.end.isAfter(event.start)) return 'bad_range';
    return null;
  }

  Response _json(Object body, {int status = 200}) {
    return Response(
      status,
      body: jsonEncode(body),
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }
}
