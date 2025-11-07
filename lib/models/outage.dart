import 'power_status.dart';

class Outage {
  final String id;
  final PowerStatusType type;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final String affectedArea;
  final List<String> affectedBarangays;
  final double latitude;
  final double longitude;
  final String? reason;
  final String? description;
  final bool isScheduled;
  final int affectedUsers;

  Outage({
    required this.id,
    required this.type,
    required this.startTime,
    this.endTime,
    this.duration,
    required this.affectedArea,
    required this.affectedBarangays,
    required this.latitude,
    required this.longitude,
    this.reason,
    this.description,
    required this.isScheduled,
    required this.affectedUsers,
  });

  bool get isActive => endTime == null;

  Duration get actualDuration {
    if (duration != null) return duration!;
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return DateTime.now().difference(startTime);
  }

  factory Outage.fromJson(Map<String, dynamic> json) {
    return Outage(
      id: json['id'] as String,
      type: PowerStatusType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PowerStatusType.outage,
      ),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      duration: json['duration'] != null
          ? Duration(seconds: json['duration'] as int)
          : null,
      affectedArea: json['affectedArea'] as String,
      affectedBarangays: (json['affectedBarangays'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      reason: json['reason'] as String?,
      description: json['description'] as String?,
      isScheduled: json['isScheduled'] as bool? ?? false,
      affectedUsers: json['affectedUsers'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'duration': duration?.inSeconds,
      'affectedArea': affectedArea,
      'affectedBarangays': affectedBarangays,
      'latitude': latitude,
      'longitude': longitude,
      'reason': reason,
      'description': description,
      'isScheduled': isScheduled,
      'affectedUsers': affectedUsers,
    };
  }
}
