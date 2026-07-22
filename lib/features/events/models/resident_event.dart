enum ResidentEventType { collection, rewardDistribution, unknown }

enum ResidentEventStatus { upcoming, active, completed, cancelled, unknown }

class ResidentEvent {
  const ResidentEvent({
    required this.id,
    required this.type,
    required this.status,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.description = '',
    this.barangayName,
  });
  factory ResidentEvent.fromJson(
    Map<String, Object?> j,
    ResidentEventType type,
  ) {
    final barangay = j['barangay'];
    return ResidentEvent(
      id: _i(j['id']),
      type: type,
      status: switch (j['status']) {
        'UPCOMING' => ResidentEventStatus.upcoming,
        'ACTIVE' => ResidentEventStatus.active,
        'COMPLETED' => ResidentEventStatus.completed,
        'CANCELLED' => ResidentEventStatus.cancelled,
        _ => ResidentEventStatus.unknown,
      },
      title: j['title'] as String,
      date: DateTime.parse(j['event_date'] as String),
      startTime: j['start_time'] as String,
      endTime: j['end_time'] as String,
      location: j['location'] as String,
      description: j['description'] is String
          ? j['description']! as String
          : '',
      barangayName: barangay is Map && barangay['name'] is String
          ? barangay['name']! as String
          : null,
    );
  }
  final int id;
  final ResidentEventType type;
  final ResidentEventStatus status;
  final String title, description, startTime, endTime, location;
  final String? barangayName;
  final DateTime date;
  static int _i(Object? v) {
    if (v is int) return v;
    throw const FormatException();
  }
}
