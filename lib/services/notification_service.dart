import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/event_item.dart';
import '../utils/format.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  var _ready = false;

  Future<void> init() async {
    try {
      tzdata.initializeTimeZones();
      try {
        final name = await FlutterTimezone.getLocalTimezone().timeout(const Duration(seconds: 2));
        tz.setLocalLocation(tz.getLocation(name));
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('Europe/Chisinau'));
      }
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_stat_notify'),
      );
      await _plugin.initialize(settings).timeout(const Duration(seconds: 3));
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  Future<bool> ensurePermission() async {
    if (!_ready) return false;
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
    return granted ?? true;
  }

  Future<void> reschedule({
    required List<EventItem> events,
    required Set<String> participatingIds,
    required int remindMinutes,
  }) async {
    if (!_ready) return;
    await _plugin.cancelAll();
    final now = tz.TZDateTime.now(tz.local);
    for (final event in events) {
      if (!participatingIds.contains(event.id)) continue;
      final start = tz.TZDateTime.from(event.start, tz.local);
      if (!start.isAfter(now)) continue;
      final fireAt = start.subtract(Duration(minutes: remindMinutes));
      if (!fireAt.isAfter(now)) continue;
      final id = notificationId(event.id);
      final details = _details;
      try {
        await _plugin.zonedSchedule(
          id,
          'Скоро начнётся',
          _body(event),
          fireAt,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: event.id,
        );
      } catch (_) {
        try {
          await _plugin.zonedSchedule(
            id,
            'Скоро начнётся',
            _body(event),
            fireAt,
            details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            payload: event.id,
          );
        } catch (_) {}
      }
    }
  }

  Future<void> showNow(EventItem event) async {
    if (!_ready) return;
    await _plugin.show(
      notificationId(event.id),
      'Скоро начнётся',
      _body(event),
      _details,
    );
  }

  Future<void> cancelAll() async {
    if (!_ready) return;
    await _plugin.cancelAll();
  }
}

NotificationDetails get _details => const NotificationDetails(
      android: AndroidNotificationDetails(
        'pgu_event_reminders_v1',
        'Напоминания о мероприятиях',
        channelDescription: 'Звуковой сигнал перед началом мероприятия, в котором вы участвуете',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        category: AndroidNotificationCategory.reminder,
      ),
    );

String _body(EventItem event) {
  final place = event.location.isEmpty ? '' : ' · ${event.location}';
  return '${event.title} · ${formatTime(event.start)}$place';
}

int notificationId(String id) {
  return id.codeUnits.fold<int>(0, (hash, unit) => (hash * 31 + unit) & 0x7fffffff);
}
