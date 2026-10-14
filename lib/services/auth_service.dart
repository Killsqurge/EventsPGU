import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_profile.dart';

class AuthFailure implements Exception {
  AuthFailure(this.message);
  final String message;
}

class AuthService {
  final GoogleSignIn _google = GoogleSignIn(scopes: const ['email', 'profile']);

  Future<UserProfile?> signIn() async {
    try {
      final account = await _google.signIn();
      if (account == null) return null;
      return _map(account);
    } catch (error) {
      throw AuthFailure(describeAuthError(error));
    }
  }

  Future<UserProfile?> silent() async {
    final account = await _google.signInSilently();
    if (account == null) return null;
    return _map(account);
  }

  Future<void> signOut() => _google.signOut();

  UserProfile _map(GoogleSignInAccount account) {
    final name = account.displayName?.trim();
    return UserProfile(
      id: account.id,
      name: name == null || name.isEmpty ? 'Студент' : name,
      email: account.email,
      photoUrl: account.photoUrl,
    );
  }
}

String describeAuthError(Object error) {
  final text = error.toString();
  if (text.contains('ApiException: 10') || text.contains(': 10,') || text.contains('DEVELOPER_ERROR')) {
    return 'Google не настроен для этого приложения. В Google Cloud создайте OAuth-клиент Android для пакета com.example.my_app и добавьте SHA-1 этого компьютера.';
  }
  if (error is PlatformException && error.code == 'network_error') {
    return 'Нет сети. Проверьте интернет и повторите вход.';
  }
  if (text.contains('network')) {
    return 'Нет сети. Проверьте интернет и повторите вход.';
  }
  return 'Не удалось войти через Google. Попробуйте ещё раз.';
}
