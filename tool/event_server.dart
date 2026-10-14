import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:my_app/config/app_config.dart';
import 'package:my_app/data/seed_events.dart';
import 'package:my_app/models/event_item.dart';

/// Сервер мероприятий для администратора.
///
/// Запуск из корня проекта:
///   dart run tool/event_server.dart
///
/// Телефоны в той же сети открывают http://IP-компьютера:8080
/// Эмулятор Android — http://10.0.2.2:8080
Future<void> main() async {
  final file = File('tool/data/events.json');
  if (!file.existsSync()) {
    await file.parent.create(recursive: true);
    final seed = SeedEvents.all.map((event) => event.toJson()).toList();
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(seed));
  }

  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  stdout.writeln('Сервер мероприятий слушает порт 8080');
  stdout.writeln('На этом компьютере: http://127.0.0.1:8080');
  stdout.writeln('Эмулятор Android: http://10.0.2.2:8080');
  for (final interface in await NetworkInterface.list()) {
    for (final address in interface.addresses) {
      if (address.type == InternetAddressType.IPv4 && !address.isLoopback) {
        stdout.writeln('Телефон в этой сети: http://${address.address}:8080');
      }
    }
  }

  await for (final request in server) {
    unawaited(_handle(request, file));
  }
}

Future<void> _queue = Future<void>.value();

Future<T> _sync<T>(Future<T> Function() action) {
  final result = _queue.then((_) => action());
  _queue = result.then((_) {}, onError: (_) {});
  return result;
}

Future<void> _handle(HttpRequest request, File file) async {
  final response = request.response;
  response.headers.set('Access-Control-Allow-Origin', '*');
  response.headers.set('Access-Control-Allow-Headers', 'Content-Type, X-Admin-Token');
  response.headers.set('Access-Control-Allow-Methods', 'GET, POST, DELETE, OPTIONS');
  response.headers.contentType = ContentType.json;

  try {
    if (request.method == 'OPTIONS') {
      response.statusCode = HttpStatus.noContent;
      await response.close();
      return;
    }

    final segments = request.uri.pathSegments;
    if (segments.isEmpty || segments.first != 'events' || segments.length > 2) {
      response.statusCode = HttpStatus.notFound;
      response.write(jsonEncode({'error': 'not_found'}));
      await response.close();
      return;
    }

    if (request.method == 'GET' && segments.length == 1) {
      final events = await _sync(() => _read(file));
      response.write(jsonEncode(events));
      await response.close();
      return;
    }

    if (!_isAdmin(request)) {
      response.statusCode = HttpStatus.unauthorized;
      response.write(jsonEncode({'error': 'admin_only'}));
      await response.close();
      return;
    }

    if (request.method == 'POST' && segments.length == 1) {
      final body = await utf8.decoder.bind(request).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final event = EventItem.fromJson(json);
      if (event.title.trim().isEmpty || event.branchId.isEmpty || event.directionId.isEmpty) {
        response.statusCode = HttpStatus.badRequest;
        response.write(jsonEncode({'error': 'invalid_event'}));
        await response.close();
        return;
      }
      if (!event.end.isAfter(event.start)) {
        response.statusCode = HttpStatus.badRequest;
        response.write(jsonEncode({'error': 'bad_range'}));
        await response.close();
        return;
      }
      final created = await _sync(() async {
        final events = await _read(file);
        if (events.any((item) => item['id'] == event.id)) return false;
        events.add(event.toJson());
        await _write(file, events);
        return true;
      });
      response.statusCode = created ? HttpStatus.created : HttpStatus.conflict;
      response.write(jsonEncode(event.toJson()));
      await response.close();
      return;
    }

    if (request.method == 'DELETE' && segments.length == 2) {
      final id = segments[1];
      await _sync(() async {
        final events = await _read(file);
        events.removeWhere((item) => item['id'] == id);
        await _write(file, events);
      });
      response.write(jsonEncode({'ok': true}));
      await response.close();
      return;
    }

    response.statusCode = HttpStatus.methodNotAllowed;
    response.write(jsonEncode({'error': 'method'}));
    await response.close();
  } catch (error) {
    stderr.writeln(error);
    response.statusCode = HttpStatus.internalServerError;
    response.write(jsonEncode({'error': 'server'}));
    await response.close();
  }
}

bool _isAdmin(HttpRequest request) {
  return request.headers.value('X-Admin-Token') == AppConfig.adminToken;
}

Future<List<Map<String, dynamic>>> _read(File file) async {
  final raw = await file.readAsString();
  final list = jsonDecode(raw) as List<dynamic>;
  return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
}

Future<void> _write(File file, List<Map<String, dynamic>> events) async {
  await file.writeAsString(const JsonEncoder.withIndent('  ').convert(events));
}
