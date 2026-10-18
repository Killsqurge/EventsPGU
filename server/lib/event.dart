class EventRecord {
  const EventRecord({
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
  final String type;
  final String directionId;
  final int course;
  final String branchId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'start': encodeDate(start),
        'end': encodeDate(end),
        'location': location,
        'type': type,
        'directionId': directionId,
        'course': course,
        'branchId': branchId,
      };

  factory EventRecord.fromJson(Map<String, dynamic> json) {
    return EventRecord(
      id: json['id'] as String,
      title: (json['title'] as String?)?.trim() ?? '',
      description: (json['description'] as String?)?.trim() ?? '',
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      location: (json['location'] as String?)?.trim() ?? '',
      type: (json['type'] as String?) ?? 'seminar',
      directionId: (json['directionId'] as String?) ?? '',
      course: (json['course'] as num?)?.toInt() ?? 1,
      branchId: (json['branchId'] as String?) ?? '',
    );
  }

  static String encodeDate(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)}T${two(value.hour)}:${two(value.minute)}:00';
  }
}
