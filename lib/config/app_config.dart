/// Общие настройки приложения и сервера мероприятий.
///
/// [serverUrl] — адрес бэкенда, зашит в приложение (поле ввода в профиле убрано).
/// Для теста по USB: `http://127.0.0.1:8080` и `adb reverse tcp:8080 tcp:8080`.
/// Для эмулятора: `http://10.0.2.2:8080`.
/// Для Play Market / интернета: `https://ваш-домен`.
///
/// [adminAccessCode] вводится в профиле после входа через Google.
/// [adminToken] должен совпадать с `server/lib/config.dart` → `ServerConfig.adminToken`.
class AppConfig {
  static const serverUrl = 'http://127.0.0.1:8080';

  static const adminAccessCode = 'pgu-admin';
  static const adminToken = 'pgu-a8f3c9e2b7d14e6f90a2c5d8b1e4f7a3';

  /// Google-почты, которым роль администратора выдаётся сразу, без кода.
  static const adminEmails = <String>[];

  static const defaultRemindMinutes = 30;
  static const remindChoices = <int>[15, 30, 60, 120];
}
