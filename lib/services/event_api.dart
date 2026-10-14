import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/event_item.dart';

class EventApiException implements Exception {
  EventApiException(this.message);
  final String message;
}

class EventApi {
  EventApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<EventItem>> fetchEvents(String baseUrl) async {
    final response = await _client.get(_uri(baseUrl, '/events')).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw EventApiException('Сервер ответил ${response.statusCode}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((item) => EventItem.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<void> createEvent(String baseUrl, EventItem event) async {
    final response = await _client
        .post(
          _uri(baseUrl, '/events'),
          headers: _adminHeaders,
          body: jsonEncode(event.toJson()),
        )
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw EventApiException('Не удалось добавить мероприятие (${response.statusCode})');
    }
  }

  Future<void> deleteEvent(String baseUrl, String id) async {
    final response = await _client
        .delete(_uri(baseUrl, '/events/$id'), headers: _adminHeaders)
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200 && response.statusCode != 404) {
      throw EventApiException('Не удалось удалить мероприятие (${response.statusCode})');
    }
  }

  Map<String, String> get _adminHeaders => {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Admin-Token': AppConfig.adminToken,
      };

  Uri _uri(String baseUrl, String path) => Uri.parse('$baseUrl$path');
}
