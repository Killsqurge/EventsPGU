enum EventType {
  conference,
  olympiad,
  seminar,
  workshop,
  cultural;

  static EventType parse(String raw) {
    for (final type in EventType.values) {
      if (type.name == raw) return type;
    }
    return EventType.seminar;
  }
}

class EventItem {
  const EventItem({
    required this.id,
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    required this.location,
    required this.type,
    required this.directionId,
    required this.course,
    required this.branchId,
  });

  final String id;
  final String title;
  final String description;
  final DateTime start;
  final DateTime end;
  final String location;
  final EventType type;
  final String directionId;
  final int course;
  final String branchId;

  bool get isPast => !end.isAfter(DateTime.now());

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'start': _encodeDate(start),
        'end': _encodeDate(end),
        'location': location,
        'type': type.name,
        'directionId': directionId,
        'course': course,
        'branchId': branchId,
      };

  factory EventItem.fromJson(Map<String, dynamic> json) {
    return EventItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      start: _decodeDate(json['start'] as String),
      end: _decodeDate(json['end'] as String),
      location: json['location'] as String? ?? '',
      type: EventType.parse(json['type'] as String? ?? ''),
      directionId: json['directionId'] as String? ?? '',
      course: (json['course'] as num?)?.toInt() ?? 1,
      branchId: json['branchId'] as String? ?? '',
    );
  }
}

String _encodeDate(DateTime value) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${value.year}-${two(value.month)}-${two(value.day)}T${two(value.hour)}:${two(value.minute)}:00';
}

DateTime _decodeDate(String raw) => DateTime.parse(raw);
