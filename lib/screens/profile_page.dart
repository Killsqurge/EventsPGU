import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../data/event_filters.dart';
import '../state/app_controller.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import '../widgets/filter_sheet.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
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
                _stat(context, 'Избранных', '${controller.favorites.length}'),
                const SizedBox(width: 8),
                _stat(context, 'Участвую', '${controller.participating.length}'),
                const SizedBox(width: 8),
                _stat(context, 'Напоминание', remindLabel(controller.remindMinutes)),
              ],
            ),
            const SizedBox(height: 16),
            _section(
              context,
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
              context,
              'Мой университет',
              path.isEmpty
                  ? Text('Филиал, кафедра, направление и курс ещё не выбраны', style: TextStyle(color: colors.muted))
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final label in path)
                          Chip(
                            label: Text(label),
                            backgroundColor: colors.indigoSoft,
                            labelStyle: TextStyle(color: colors.chipText, fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => showFilterSheet(context, controller),
                child: const Text('Выбрать и сохранить'),
              ),
            ),
            const SizedBox(height: 8),
            _section(
              context,
              'Напоминания',
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
    final entered = await showDialog<String>(
      context: context,
      builder: (context) => const _AdminCodeDialog(),
    );
    if (!context.mounted || entered == null) return;
    if (entered.trim() == AppConfig.adminAccessCode) {
      await controller.setAdmin(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Неверный код')));
    }
  }

  Widget _stat(BuildContext context, String label, String value) {
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

  Widget _section(BuildContext context, String title, Widget child) {
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

class _AdminCodeDialog extends StatefulWidget {
  const _AdminCodeDialog();

  @override
  State<_AdminCodeDialog> createState() => _AdminCodeDialogState();
}

class _AdminCodeDialogState extends State<_AdminCodeDialog> {
  late final TextEditingController _code;

  @override
  void initState() {
    super.initState();
    _code = TextEditingController();
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return AlertDialog(
      backgroundColor: colors.card,
      title: Text('Код администратора', style: TextStyle(color: colors.text)),
      content: TextField(
        controller: _code,
        autofocus: true,
        obscureText: true,
        style: TextStyle(color: colors.text),
        decoration: const InputDecoration(hintText: 'Код'),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
        TextButton(onPressed: () => Navigator.pop(context, _code.text), child: const Text('Войти')),
      ],
    );
  }
}
