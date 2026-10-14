const _months = [
  'янв.',
  'фев.',
  'мар.',
  'апр.',
  'мая',
  'июн.',
  'июл.',
  'авг.',
  'сен.',
  'окт.',
  'ноя.',
  'дек.',
];

const _weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

String formatDay(DateTime value) {
  return '${_weekdays[value.weekday - 1]}, ${value.day} ${_months[value.month - 1]}';
}

String formatTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String formatRange(DateTime start, DateTime end) {
  final sameDay = start.year == end.year && start.month == end.month && start.day == end.day;
  if (sameDay) return '${formatTime(start)}–${formatTime(end)}';
  return '${formatDay(start)} ${formatTime(start)} – ${formatDay(end)} ${formatTime(end)}';
}

String eventsCountLabel(int count) {
  final mod10 = count % 10;
  final mod100 = count % 100;
  if (mod10 == 1 && mod100 != 11) return '$count мероприятие';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
    return '$count мероприятия';
  }
  return '$count мероприятий';
}

String remindLabel(int minutes) {
  if (minutes % 60 == 0) {
    final hours = minutes ~/ 60;
    if (hours == 1) return '1 час';
    if (hours >= 2 && hours <= 4) return '$hours часа';
    return '$hours часов';
  }
  return '$minutes мин';
}

String initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  String letter(String word) => word[0].toUpperCase();
  if (parts.length == 1) return letter(parts.first);
  return '${letter(parts.first)}${letter(parts.last)}';
}

String? normalizeServerUrl(String raw) {
  var value = raw.trim();
  if (value.isEmpty) return '';
  if (!value.startsWith('http://') && !value.startsWith('https://')) {
    value = 'http://$value';
  }
  while (value.endsWith('/')) {
    value = value.substring(0, value.length - 1);
  }
  final uri = Uri.tryParse(value);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
  return value;
}
