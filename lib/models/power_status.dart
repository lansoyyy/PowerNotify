enum PowerStatusType {
  normal, // Green - Power on
  outage, // Red - Power outage
  scheduled, // Yellow - Scheduled maintenance
}

class PowerStatus {
  final String id;
  final PowerStatusType status;
  final DateTime timestamp;
  final String? message;
  final DateTime? estimatedRestoration;
  final String? affectedArea;

  PowerStatus({
    required this.id,
    required this.status,
    required this.timestamp,
    this.message,
    this.estimatedRestoration,
    this.affectedArea,
  });

  factory PowerStatus.fromJson(Map<String, dynamic> json) {
    return PowerStatus(
      id: json['id'] as String,
      status: PowerStatusType.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PowerStatusType.normal,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      message: json['message'] as String?,
      estimatedRestoration: json['estimatedRestoration'] != null
          ? DateTime.parse(json['estimatedRestoration'] as String)
          : null,
      affectedArea: json['affectedArea'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'message': message,
      'estimatedRestoration': estimatedRestoration?.toIso8601String(),
      'affectedArea': affectedArea,
    };
  }
}
