import 'package:flutter/material.dart';

import '../models/event_item.dart';
import '../state/app_controller.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import 'event_detail_sheet.dart';

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, required this.controller});

  final EventItem event;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final style = colors.typeStyle(event.type);
    final favorite = controller.favorites.contains(event.id);
    final joined = controller.participating.contains(event.id);
    return Opacity(
      opacity: event.isPast ? 0.55 : 1,
      child: Material(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => showEventDetail(context, controller, event.id),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: style.color,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: style.background,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    style.label,
                                    style: TextStyle(color: style.color, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  event.title,
                                  style: TextStyle(color: colors.text, fontWeight: FontWeight.w700, height: 1.25),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: favorite ? 'Убрать из избранного' : 'В избранное',
                            onPressed: () => controller.toggleFavorite(event.id),
                            icon: Icon(
                              favorite ? Icons.star_rounded : Icons.star_border_rounded,
                              color: favorite ? colors.amber : colors.muted,
                            ),
                          ),
                        ],
                      ),
                      if (event.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            event.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: colors.muted, fontSize: 12, height: 1.4),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          _meta(colors, Icons.calendar_today_outlined, formatDay(event.start)),
                          _meta(colors, Icons.schedule, formatRange(event.start, event.end)),
                          if (event.location.isNotEmpty) _meta(colors, Icons.place_outlined, event.location),
                          if (joined) _meta(colors, Icons.notifications_active_outlined, 'Участвую'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _meta(AppPalette colors, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colors.meta),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: colors.meta, fontSize: 12)),
      ],
    );
  }
}
