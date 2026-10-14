/// Общие настройки приложения и сервера мероприятий.
///
/// [adminAccessCode] вводится в профиле после входа через Google.
/// [adminToken] отправляется на сервер и должен совпадать с проверкой в
/// `tool/event_server.dart` (сервер читает это же значение).
class AppConfig {
  static const adminAccessCode = 'pgu-admin';
  static const adminToken = 'pgu-admin-token';

  /// Google-почты, которым роль администратора выдаётся сразу, без кода.
  static const adminEmails = <String>[];

  static const defaultRemindMinutes = 30;
  static const remindChoices = <int>[15, 30, 60, 120];
}
