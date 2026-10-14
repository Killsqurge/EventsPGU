import 'package:flutter/material.dart';

import '../state/app_controller.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import '../widgets/event_detail_sheet.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final colors = AppColors.of(context);
        final events = controller.favoriteEvents;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Сохранённые', style: TextStyle(color: colors.muted, fontSize: 12)),
                  Text('Избранное', style: TextStyle(color: colors.text, fontSize: 22, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            Expanded(
              child: events.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_border_rounded, color: colors.amber, size: 40),
                            const SizedBox(height: 12),
                            Text('Список пуст', style: TextStyle(color: colors.faint, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Text(
                              'Нажмите звезду на карточке, чтобы оставить мероприятие в избранном',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colors.muted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: events.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final event = events[index];
                        final style = colors.typeStyle(event.type);
                        return Material(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => showEventDetail(context, controller, event.id),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                              child: Row(
                                children: [
                                  Container(width: 4, height: 42, decoration: BoxDecoration(color: style.color, borderRadius: BorderRadius.circular(4))),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: colors.text, fontWeight: FontWeight.w700)),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${formatDay(event.start)} · ${formatRange(event.start, event.end)}',
                                          style: TextStyle(color: colors.muted, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Убрать из избранного',
                                    onPressed: () => controller.toggleFavorite(event.id),
                                    icon: Icon(Icons.star_rounded, color: colors.amber),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
