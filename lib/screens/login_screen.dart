import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../state/app_controller.dart';
import '../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: colors.isLight ? 'Тёмная тема' : 'Светлая тема',
                  onPressed: () => widget.controller.setLightTheme(!widget.controller.lightTheme),
                  icon: Icon(colors.isLight ? Icons.dark_mode_outlined : Icons.light_mode_outlined, color: colors.text),
                ),
              ),
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: Image.asset(
                  'assets/images/app_logo.png',
                  width: 168,
                  height: 168,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Мероприятия',
                style: TextStyle(color: colors.text, fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'ПГУ им. Т.Г. Шевченко',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.muted),
              ),
              const Spacer(),
              if (_error != null) ...[
                Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: colors.danger, height: 1.4)),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.googleButton,
                    foregroundColor: colors.googleButtonText,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _loading ? null : _signIn,
                  child: _loading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Войти через Google', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.controller.signIn();
    } on AuthFailure catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Не удалось войти через Google. Попробуйте ещё раз.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
