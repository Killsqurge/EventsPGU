import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pgu_events_server/api.dart';
import 'package:pgu_events_server/config.dart';
import 'package:pgu_events_server/database.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';

Future<void> main(List<String> args) async {
  final root = _packageRoot();
  Directory.current = root;

  final db = await EventDatabase.open(dataDir: Directory(p.join(root.path, 'data')));
  final api = EventsApi(db).router;
  final adminFile = File(p.join(root.path, 'web', 'admin.html'));

  Future<Response> adminPage(Request request) async {
    if (!_isAdminBasic(request)) {
      return Response(
        HttpStatus.unauthorized,
        body: 'Нужен логин и пароль администратора',
        headers: {
          'WWW-Authenticate': 'Basic realm="PGU Events Admin"',
          'content-type': 'text/plain; charset=utf-8',
        },
      );
    }
    return Response.ok(
      await adminFile.readAsString(),
      headers: {'content-type': 'text/html; charset=utf-8'},
    );
  }

  final router = Router()
    ..get('/', adminPage)
    ..get('/admin', adminPage)
    ..get('/admin/', adminPage);
  final mounted = Cascade().add(router.call).add(api.call).handler;

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(
        corsHeaders(
          headers: {
            ACCESS_CONTROL_ALLOW_ORIGIN: '*',
            ACCESS_CONTROL_ALLOW_METHODS: 'GET,POST,DELETE,OPTIONS',
            ACCESS_CONTROL_ALLOW_HEADERS: 'Content-Type, X-Admin-Token',
          },
        ),
      )
      .addHandler(mounted);

  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, ServerConfig.port);
  stdout.writeln('Сервер мероприятий ПГУ запущен');
  stdout.writeln('База SQLite: ${p.join(root.path, 'data', ServerConfig.databaseFileName)}');
  stdout.writeln('Админка: http://127.0.0.1:${server.port}/admin');
  stdout.writeln('  логин: ${ServerConfig.adminUser}');
  stdout.writeln('  пароль: ${ServerConfig.adminPassword}');
  stdout.writeln('API:     http://127.0.0.1:${server.port}/events');
  stdout.writeln('Эмулятор Android: http://10.0.2.2:${server.port}');
  for (final interface in await NetworkInterface.list()) {
    for (final address in interface.addresses) {
      if (address.type == InternetAddressType.IPv4 && !address.isLoopback) {
        stdout.writeln('Телефон в этой сети: http://${address.address}:${server.port}');
      }
    }
  }
  stdout.writeln('Адрес в приложении задаётся в lib/config/app_config.dart → serverUrl');
  stdout.writeln('Окно не закрывайте, пока телефоны должны видеть общий список.');
}

bool _isAdminBasic(Request request) {
  final header = request.headers['authorization'];
  if (header == null || !header.startsWith('Basic ')) return false;
  try {
    final decoded = utf8.decode(base64Decode(header.substring(6)));
    final parts = decoded.split(':');
    if (parts.length < 2) return false;
    final user = parts.first;
    final password = parts.sublist(1).join(':');
    return user == ServerConfig.adminUser && password == ServerConfig.adminPassword;
  } catch (_) {
    return false;
  }
}

Directory _packageRoot() {
  final script = Platform.script.toFilePath();
  return Directory(p.normalize(p.join(p.dirname(script), '..')));
}
