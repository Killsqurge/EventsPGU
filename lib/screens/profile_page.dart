import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../data/event_filters.dart';
import '../state/app_controller.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import '../widgets/filter_sheet.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.controller});

  final AppController controller;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController _server;

  @override
  void initState() {
    super.initState();
    _server = TextEditingController(text: widget.controller.serverUrl);
  }

  @override
  void dispose() {
    _server.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final user = controller.user;
        if (user == null) return const SizedBox.shrink();
        final colors = AppColors.of(context);
        final path = filterChipLabels(controller.filter);
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Text('Личный кабинет', style: TextStyle(color: colors.muted, fontSize: 12)),
            Text('Профиль', style: TextStyle(color: colors.text, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: colors.indigoDeep,
                    backgroundImage: user.photoUrl == null ? null : NetworkImage(user.photoUrl!),
                    child: user.photoUrl == null
                        ? Text(initials(user.name), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800))
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(user.name, style: TextStyle(color: colors.text, fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(user.email, style: TextStyle(color: colors.muted, fontSize: 13)),
                  if (controller.isAdmin)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('Администратор', style: TextStyle(color: colors.green, fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _stat('Избранных', '${controller.favorites.length}'),
                const SizedBox(width: 8),
                _stat('Участвую', '${controller.participating.length}'),
                const SizedBox(width: 8),
                _stat('Напоминание', remindLabel(controller.remindMinutes)),
              ],
            ),
            const SizedBox(height: 16),
            _section(
              'Тема',
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Тёмная'),
                    selected: !controller.lightTheme,
                    selectedColor: colors.indigoSoft,
                    labelStyle: TextStyle(
                      color: controller.lightTheme ? colors.muted : colors.indigo,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => controller.setLightTheme(false),
                  ),
                  ChoiceChip(
                    label: const Text('Светлая'),
                    selected: controller.lightTheme,
                    selectedColor: colors.indigoSoft,
                    labelStyle: TextStyle(
                      color: controller.lightTheme ? colors.indigo : colors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => controller.setLightTheme(true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _section(
              'Мой университет',
              path.isEmpty
                  ? Text('Филиал, кафедра, направление и курс ещё не выбраны', style: TextStyle(color: colors.muted))
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final chip in path)
                          Chip(
                            label: Text(chip),
                            backgroundColor: colors.indigo.withValues(alpha: 0.15),
                            labelStyle: TextStyle(color: colors.indigo),
                            side: BorderSide.none,
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => showFilterSheet(context, controller),
              child: const Text('Выбрать и сохранить'),
            ),
            const SizedBox(height: 16),
            _section(
              'Звук до начала',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Сигнал придёт только по тем мероприятиям, где нажато «Я участвую».',
                    style: TextStyle(color: colors.muted, fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final minutes in AppConfig.remindChoices)
                        ChoiceChip(
                          label: Text(remindLabel(minutes)),
                          selected: controller.remindMinutes == minutes,
                          selectedColor: colors.indigo.withValues(alpha: 0.25),
                          labelStyle: TextStyle(
                            color: controller.remindMinutes == minutes ? colors.indigo : colors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) => controller.setRemindMinutes(minutes),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _section(
              'Сервер мероприятий',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Администратор запускает сервер на компьютере и добавляет или удаляет мероприятия. Этот адрес нужен всем телефонам, которые должны видеть тот же список.',
                    style: TextStyle(color: colors.muted, fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _server,
                    style: TextStyle(color: colors.text),
                    decoration: InputDecoration(
                      hintText: 'http://192.168.0.10:8080',
                      hintStyle: TextStyle(color: colors.faint),
                      filled: true,
                      fillColor: colors.fill,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {
                        final error = await controller.setServerUrl(_server.text);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error ?? (controller.serverUrl.isEmpty ? 'Список снова берётся с телефона' : 'Подключено к серверу'))),
                        );
                      },
                      child: const Text('Сохранить адрес'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (controller.isAdmin)
              TextButton(
                onPressed: () => controller.setAdmin(false),
                child: const Text('Снять права администратора'),
              )
            else
              TextButton(
                onPressed: () => _askAdminCode(context),
                child: const Text('Войти как администратор'),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(foregroundColor: colors.danger, side: BorderSide(color: colors.dangerBorder)),
                onPressed: () async {
                  final leave = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: colors.card,
                      title: Text('Выйти из аккаунта?', style: TextStyle(color: colors.text)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Остаться')),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Выйти')),
                      ],
                    ),
                  );
                  if (leave == true) await controller.signOut();
                },
                child: const Text('Выйти из аккаунта'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _askAdminCode(BuildContext context) async {
    final code = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colors = AppColors.of(context);
        return AlertDialog(
          backgroundColor: colors.card,
          title: Text('Код администратора', style: TextStyle(color: colors.text)),
          content: TextField(
            controller: code,
            autofocus: true,
            obscureText: true,
            style: TextStyle(color: colors.text),
            decoration: const InputDecoration(hintText: 'Код'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Войти')),
          ],
        );
      },
    );
    if (ok == true && code.text.trim() == AppConfig.adminAccessCode) {
      await widget.controller.setAdmin(true);
    } else if (ok == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Неверный код')));
    }
    code.dispose();
  }

  Widget _stat(String label, String value) {
    final colors = AppColors.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.line),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: colors.indigo, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: colors.muted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, Widget child) {
    final colors = AppColors.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: colors.text, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
