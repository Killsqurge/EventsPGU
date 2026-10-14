import 'package:flutter/material.dart';

import '../data/event_filters.dart';
import '../models/academic_filter.dart';
import '../state/app_controller.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import '../widgets/event_card.dart';
import '../widgets/filter_sheet.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final colors = AppColors.of(context);
        final events = controller.visibleEvents;
        final chips = filterChipLabels(controller.filter);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset('assets/images/app_logo.png', width: 44, height: 44, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ПГУ им. Т.Г. Шевченко', style: TextStyle(color: colors.muted, fontSize: 12)),
                        Text('Мероприятия', style: TextStyle(color: colors.text, fontSize: 22, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: controller.filter.isActive ? colors.indigo : colors.meta,
                      backgroundColor: controller.filter.isActive ? colors.indigoSoft : colors.fill,
                    ),
                    onPressed: () => showFilterSheet(context, controller),
                    icon: const Icon(Icons.filter_alt_outlined, size: 18),
                    label: const Text('Фильтр'),
                  ),
                ],
              ),
            ),
            if (chips.isNotEmpty)
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    for (final chip in chips)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text(chip),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: colors.indigoSoft,
                          labelStyle: TextStyle(color: colors.indigo, fontSize: 12, fontWeight: FontWeight.w600),
                          side: BorderSide.none,
                        ),
                      ),
                    ActionChip(
                      label: const Text('Сброс'),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => controller.setFilter(AcademicFilter.empty),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(eventsCountLabel(events.length), style: TextStyle(color: colors.faint, fontSize: 12)),
            ),
            if (controller.syncMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(controller.syncMessage!, style: TextStyle(color: colors.amber, fontSize: 12)),
              ),
            Expanded(
              child: RefreshIndicator(
                color: colors.indigo,
                onRefresh: controller.refreshEvents,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    if (!controller.filter.isActive)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Выберите филиал, кафедру, направление и курс. Выбор сохранится и откроется сам при следующем входе.',
                          style: TextStyle(color: colors.muted, fontSize: 12, height: 1.4),
                        ),
                      ),
                    if (events.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 48),
                        child: Column(
                          children: [
                            Icon(Icons.search, color: colors.faint, size: 36),
                            const SizedBox(height: 12),
                            Text('Мероприятий не найдено', style: TextStyle(color: colors.faint, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('Попробуйте изменить фильтр', style: TextStyle(color: colors.muted, fontSize: 12)),
                          ],
                        ),
                      )
                    else
                      for (final event in events) ...[
                        EventCard(event: event, controller: controller),
                        const SizedBox(height: 12),
                      ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
