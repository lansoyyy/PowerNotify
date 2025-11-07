class UserReport {
  final String id;
  final String userId;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String? address;
  final String description;
  final List<String> photoUrls;
  final String status; // pending, verified, resolved
  final String? adminNotes;
  final DateTime? verifiedAt;

  UserReport({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.description,
    required this.photoUrls,
    required this.status,
    this.adminNotes,
    this.verifiedAt,
  });

  factory UserReport.fromJson(Map<String, dynamic> json) {
    return UserReport(
      id: json['id'] as String,
      userId: json['userId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      description: json['description'] as String,
      photoUrls: (json['photoUrls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      status: json['status'] as String? ?? 'pending',
      adminNotes: json['adminNotes'] as String?,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'description': description,
      'photoUrls': photoUrls,
      'status': status,
      'adminNotes': adminNotes,
      'verifiedAt': verifiedAt?.toIso8601String(),
    };
  }
}
