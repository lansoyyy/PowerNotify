class User {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? address;
  final double? latitude;
  final double? longitude;
  final bool isAdmin;
  final NotificationSettings notificationSettings;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.address,
    this.latitude,
    this.longitude,
    required this.isAdmin,
    required this.notificationSettings,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      isAdmin: json['isAdmin'] as bool? ?? false,
      notificationSettings: json['notificationSettings'] != null
          ? NotificationSettings.fromJson(json['notificationSettings'] as Map<String, dynamic>)
          : NotificationSettings.defaultSettings(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'isAdmin': isAdmin,
      'notificationSettings': notificationSettings.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class NotificationSettings {
  final bool pushEnabled;
  final bool smsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool scheduledOutagesEnabled;
  final bool unscheduledOutagesEnabled;
  final bool restorationAlertsEnabled;
  final int quietHoursStart; // 0-23
  final int quietHoursEnd; // 0-23

  NotificationSettings({
    required this.pushEnabled,
    required this.smsEnabled,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.scheduledOutagesEnabled,
    required this.unscheduledOutagesEnabled,
    required this.restorationAlertsEnabled,
    required this.quietHoursStart,
    required this.quietHoursEnd,
  });

  factory NotificationSettings.defaultSettings() {
    return NotificationSettings(
      pushEnabled: true,
      smsEnabled: false,
      soundEnabled: true,
      vibrationEnabled: true,
      scheduledOutagesEnabled: true,
      unscheduledOutagesEnabled: true,
      restorationAlertsEnabled: true,
      quietHoursStart: 22,
      quietHoursEnd: 7,
    );
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushEnabled: json['pushEnabled'] as bool? ?? true,
      smsEnabled: json['smsEnabled'] as bool? ?? false,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      scheduledOutagesEnabled: json['scheduledOutagesEnabled'] as bool? ?? true,
      unscheduledOutagesEnabled: json['unscheduledOutagesEnabled'] as bool? ?? true,
      restorationAlertsEnabled: json['restorationAlertsEnabled'] as bool? ?? true,
      quietHoursStart: json['quietHoursStart'] as int? ?? 22,
      quietHoursEnd: json['quietHoursEnd'] as int? ?? 7,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushEnabled': pushEnabled,
      'smsEnabled': smsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'scheduledOutagesEnabled': scheduledOutagesEnabled,
      'unscheduledOutagesEnabled': unscheduledOutagesEnabled,
      'restorationAlertsEnabled': restorationAlertsEnabled,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
    };
  }

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? smsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? scheduledOutagesEnabled,
    bool? unscheduledOutagesEnabled,
    bool? restorationAlertsEnabled,
    int? quietHoursStart,
    int? quietHoursEnd,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      scheduledOutagesEnabled: scheduledOutagesEnabled ?? this.scheduledOutagesEnabled,
      unscheduledOutagesEnabled: unscheduledOutagesEnabled ?? this.unscheduledOutagesEnabled,
      restorationAlertsEnabled: restorationAlertsEnabled ?? this.restorationAlertsEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}
