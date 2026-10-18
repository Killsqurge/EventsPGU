/// Настройки сервера.
///
/// [adminToken] должен совпадать с `AppConfig.adminToken` в приложении.
/// [adminUser] / [adminPassword] — вход в веб-админку (браузер спросит логин и пароль).
abstract final class ServerConfig {
  static const port = 8080;
  static const adminToken = 'pgu-a8f3c9e2b7d14e6f90a2c5d8b1e4f7a3';
  static const adminUser = 'admin';
  static const adminPassword = 'pgu-Admin-Panel-7f3a';
  static const databaseFileName = 'events.db';
}
