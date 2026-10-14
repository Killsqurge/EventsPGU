import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../config/app_config.dart';
import '../data/event_filters.dart';
import '../models/academic_filter.dart';
import '../models/event_item.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/event_api.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../utils/format.dart';

class AppController extends ChangeNotifier {
  AppController({
    required this.storage,
    required this.auth,
    required this.api,
    required this.notifications,
  });

  final StorageService storage;
  final AuthService auth;
  final EventApi api;
  final NotificationService notifications;

  var ready = false;
  UserProfile? user;
  List<EventItem> events = [];
  Set<String> favorites = {};
  Set<String> participating = {};
  AcademicFilter filter = AcademicFilter.empty;
  int remindMinutes = AppConfig.defaultRemindMinutes;
  String serverUrl = '';
  String? syncMessage;
  var lightTheme = false;
  var _adminFlag = false;

  bool get isAdmin {
    final email = user?.email.toLowerCase();
    if (email != null && AppConfig.adminEmails.contains(email)) return true;
    return _adminFlag;
  }

  List<EventItem> get visibleEvents => applyAcademicFilter(events, filter);

  List<EventItem> get favoriteEvents {
    final items = events.where((event) => favorites.contains(event.id)).toList();
    items.sort((a, b) => a.start.compareTo(b.start));
    return items;
  }

  EventItem? eventById(String id) {
    for (final event in events) {
      if (event.id == id) return event;
    }
    return null;
  }

  Future<void> bootstrap() async {
    final underTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!underTest) await notifications.init();
    final session = await storage.loadSession();
    UserProfile? live;
    if (!underTest) {
      try {
        live = await auth.silent();
      } catch (_) {
        live = null;
      }
    }
    user = live ?? session;
    if (live != null) await storage.saveSession(live);
    serverUrl = await storage.loadServerUrl();
    lightTheme = await storage.loadLightTheme();
    _applyOverlay();
    if (user != null) await _loadUserData();
    await refreshEvents(reschedule: false);
    if (user != null) await _reschedule();
    ready = true;
    notifyListeners();
  }

  Future<void> signIn() async {
    final profile = await auth.signIn();
    if (profile == null) return;
    user = profile;
    await storage.saveSession(profile);
    await _loadUserData();
    await refreshEvents(reschedule: false);
    await _reschedule();
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (_) {}
    await storage.clearSession();
    await notifications.cancelAll();
    user = null;
    favorites = {};
    participating = {};
    filter = AcademicFilter.empty;
    _adminFlag = false;
    notifyListeners();
  }

  Future<void> refreshEvents({bool reschedule = true}) async {
    final url = serverUrl.trim();
    if (url.isEmpty) {
      events = await storage.loadEvents();
      events.sort((a, b) => a.start.compareTo(b.start));
      syncMessage = null;
    } else {
      try {
        final remote = await api.fetchEvents(url);
        remote.sort((a, b) => a.start.compareTo(b.start));
        events = remote;
        await storage.saveEvents(events);
        syncMessage = null;
      } catch (_) {
        events = await storage.loadEvents();
        events.sort((a, b) => a.start.compareTo(b.start));
        syncMessage = 'Нет связи с сервером. Показаны сохранённые мероприятия.';
      }
    }
    await _pruneMissing();
    notifyListeners();
    if (reschedule && user != null) await _reschedule();
  }

  Future<String?> addEvent(EventItem event) async {
    if (!isAdmin) return 'Добавлять мероприятия может только администратор';
    final url = serverUrl.trim();
    if (url.isEmpty) {
      events = [event, ...events];
      await storage.saveEvents(events);
      notifyListeners();
      return null;
    }
    try {
      await api.createEvent(url, event);
      await refreshEvents();
      return null;
    } on EventApiException catch (error) {
      return error.message;
    } catch (_) {
      return 'Сервер недоступен. Мероприятие не добавлено.';
    }
  }

  Future<String?> deleteEvent(String id) async {
    if (!isAdmin) return 'Удалять мероприятия может только администратор';
    final url = serverUrl.trim();
    if (url.isEmpty) {
      events = events.where((event) => event.id != id).toList();
      await storage.saveEvents(events);
      await _pruneMissing();
      notifyListeners();
      await _reschedule();
      return null;
    }
    try {
      await api.deleteEvent(url, id);
      await refreshEvents();
      return null;
    } on EventApiException catch (error) {
      return error.message;
    } catch (_) {
      return 'Сервер недоступен. Мероприятие не удалено.';
    }
  }

  Future<void> toggleFavorite(String id) async {
    final current = user;
    if (current == null) return;
    final next = {...favorites};
    if (!next.add(id)) next.remove(id);
    favorites = next;
    notifyListeners();
    await storage.saveIdSet(current.id, 'favorites', favorites);
  }

  /// Возвращает текст, если участие сохранено, но звук запланировать нельзя.
  Future<String?> toggleParticipation(String id) async {
    final current = user;
    final event = eventById(id);
    if (current == null || event == null) return null;
    final next = {...participating};
    final enabled = next.add(id);
    if (!enabled) next.remove(id);
    participating = next;
    notifyListeners();
    await storage.saveIdSet(current.id, 'participating', participating);
    if (!enabled) {
      await _reschedule();
      return null;
    }
    if (!event.start.isAfter(DateTime.now())) {
      return 'Участие сохранено. Напоминание не поставлено: мероприятие уже началось.';
    }
    final allowed = await notifications.ensurePermission();
    await _reschedule();
    final remindAt = event.start.subtract(Duration(minutes: remindMinutes));
    if (allowed && !remindAt.isAfter(DateTime.now())) {
      await notifications.showNow(event);
    }
    if (!allowed) {
      return 'Участие сохранено. Разрешите уведомления, чтобы прозвучал сигнал.';
    }
    return null;
  }

  Future<void> setFilter(AcademicFilter value) async {
    final current = user;
    if (current == null) return;
    filter = value;
    notifyListeners();
    await storage.saveFilter(current.id, value);
  }

  Future<void> setRemindMinutes(int minutes) async {
    final current = user;
    if (current == null) return;
    remindMinutes = minutes;
    notifyListeners();
    await storage.saveRemindMinutes(current.id, minutes);
    await _reschedule();
  }

  Future<void> setAdmin(bool value) async {
    final current = user;
    if (current == null) return;
    _adminFlag = value;
    notifyListeners();
    await storage.saveAdmin(current.id, value);
  }

  Future<void> setLightTheme(bool value) async {
    lightTheme = value;
    _applyOverlay();
    notifyListeners();
    await storage.saveLightTheme(value);
  }

  void _applyOverlay() {
    SystemChrome.setSystemUIOverlayStyle(lightTheme ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light);
  }

  Future<String?> setServerUrl(String raw) async {
    final normalized = normalizeServerUrl(raw);
    if (normalized == null) return 'Некорректный адрес сервера';
    serverUrl = normalized;
    await storage.saveServerUrl(serverUrl);
    await refreshEvents();
    return null;
  }

  Future<void> _loadUserData() async {
    final current = user;
    if (current == null) return;
    favorites = await storage.loadIdSet(current.id, 'favorites');
    participating = await storage.loadIdSet(current.id, 'participating');
    filter = await storage.loadFilter(current.id);
    remindMinutes = await storage.loadRemindMinutes(current.id, AppConfig.defaultRemindMinutes);
    _adminFlag = await storage.loadAdmin(current.id);
  }

  Future<void> _pruneMissing() async {
    final current = user;
    if (current == null) return;
    final ids = events.map((event) => event.id).toSet();
    final nextFavorites = favorites.where(ids.contains).toSet();
    final nextParticipating = participating.where(ids.contains).toSet();
    final favoritesChanged = nextFavorites.length != favorites.length;
    final participatingChanged = nextParticipating.length != participating.length;
    favorites = nextFavorites;
    participating = nextParticipating;
    if (favoritesChanged) {
      await storage.saveIdSet(current.id, 'favorites', favorites);
    }
    if (participatingChanged) {
      await storage.saveIdSet(current.id, 'participating', participating);
    }
  }

  Future<void> _reschedule() {
    return notifications.reschedule(
      events: events,
      participatingIds: participating,
      remindMinutes: remindMinutes,
    );
  }
}
