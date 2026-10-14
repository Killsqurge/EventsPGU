import 'package:flutter/material.dart';

import '../data/university_data.dart';
import '../state/app_controller.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';

Future<void> showEventDetail(BuildContext context, AppController controller, String eventId) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _EventDetail(controller: controller, eventId: eventId),
  );
}

class _EventDetail extends StatelessWidget {
  const _EventDetail({required this.controller, required this.eventId});

  final AppController controller;
  final String eventId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final colors = AppColors.of(context);
        final event = controller.eventById(eventId);
        if (event == null) {
          return Material(
            color: colors.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text('Мероприятие удалено', style: TextStyle(color: colors.text)),
            ),
          );
        }
        final style = colors.typeStyle(event.type);
        final branch = UniversityData.branch(event.branchId);
        final dept = UniversityData.departmentOfDirection(event.directionId);
        final dir = UniversityData.direction(event.directionId);
        final favorite = controller.favorites.contains(event.id);
        final joined = controller.participating.contains(event.id);
        final started = !event.start.isAfter(DateTime.now());

        return SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.92,
          child: Material(
              color: colors.card,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  Container(
                    height: 112,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      gradient: LinearGradient(colors: [style.color.withValues(alpha: 0.28), style.color.withValues(alpha: 0.05)]),
                    ),
                    child: Stack(
                      children: [
                        Positioned(top: 0, left: 0, right: 0, child: Container(height: 4, color: style.color)),
                        Positioned(
                          top: 16,
                          left: 12,
                          right: 12,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _roundButton(icon: Icons.chevron_left, color: colors.text, onTap: () => Navigator.pop(context)),
                              _roundButton(
                                icon: favorite ? Icons.star_rounded : Icons.star_border_rounded,
                                color: favorite ? colors.amber : colors.text,
                                onTap: () => controller.toggleFavorite(event.id),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 20,
                          bottom: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: style.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: style.color.withValues(alpha: 0.4)),
                            ),
                            child: Text(style.label, style: TextStyle(color: style.color, fontWeight: FontWeight.w700, fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event.title, style: TextStyle(color: colors.text, fontSize: 22, fontWeight: FontWeight.w800, height: 1.2)),
                        if (event.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(event.description, style: TextStyle(color: colors.muted, height: 1.4)),
                        ],
                        const SizedBox(height: 16),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 1.7,
                          children: [
                            _info(context, 'Начало', '${formatDay(event.start)}\n${formatTime(event.start)}', style.color),
                            _info(context, 'Окончание', '${formatDay(event.end)}\n${formatTime(event.end)}', style.color),
                            _info(context, 'Место', event.location.isEmpty ? '—' : event.location, style.color),
                            _info(context, 'Курс', '${event.course} курс', style.color),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.indigo.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.indigo.withValues(alpha: 0.16)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('УЧЕБНАЯ ПРИВЯЗКА', style: TextStyle(color: colors.indigo, fontSize: 11, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              _path(context, 'Филиал', branch == null ? '—' : '${branch.name} филиал'),
                              _path(context, 'Кафедра', dept?.name ?? '—'),
                              _path(context, 'Направление', dir?.name ?? '—'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Звук за ${remindLabel(controller.remindMinutes)} только если отметить участие. Время меняется в профиле.',
                          style: TextStyle(color: colors.muted, fontSize: 12, height: 1.4),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(
                              width: 56,
                              height: 52,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: favorite ? colors.amber : colors.text,
                                  side: BorderSide(color: favorite ? colors.amber.withValues(alpha: 0.4) : colors.line),
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () => controller.toggleFavorite(event.id),
                                child: Icon(favorite ? Icons.star_rounded : Icons.star_border_rounded),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: joined ? colors.joined : colors.indigoDeep,
                                  minimumSize: const Size.fromHeight(52),
                                ),
                                onPressed: started && !joined
                                    ? null
                                    : () async {
                                        final message = await controller.toggleParticipation(event.id);
                                        if (message != null && context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                                        }
                                      },
                                child: Text(joined ? 'Отменить участие' : (started ? 'Уже началось' : 'Я участвую')),
                              ),
                            ),
                          ],
                        ),
                        if (controller.isAdmin) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(foregroundColor: colors.danger, side: BorderSide(color: colors.dangerBorder)),
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: colors.card,
                                    title: Text('Удалить мероприятие?', style: TextStyle(color: colors.text)),
                                    content: Text(event.title, style: TextStyle(color: colors.muted)),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
                                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить')),
                                    ],
                                  ),
                                );
                                if (confirmed != true || !context.mounted) return;
                                final error = await controller.deleteEvent(event.id);
                                if (!context.mounted) return;
                                if (error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                                  return;
                                }
                                Navigator.pop(context);
                              },
                              child: const Text('Удалить мероприятие'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
        );
      },
    );
  }

  Widget _roundButton({required IconData icon, required VoidCallback onTap, required Color color}) {
    return Material(
      color: const Color(0x59000000),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(width: 40, height: 40, child: Icon(icon, color: color)),
      ),
    );
  }

  Widget _info(BuildContext context, String label, String value, Color color) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.fill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: colors.faint, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, height: 1.25)),
        ],
      ),
    );
  }

  Widget _path(BuildContext context, String label, String value) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: TextStyle(color: colors.faint, fontSize: 12))),
          Expanded(child: Text(value, textAlign: TextAlign.right, style: TextStyle(color: colors.chipText, fontWeight: FontWeight.w600, fontSize: 12))),
        ],
      ),
    );
  }
}
