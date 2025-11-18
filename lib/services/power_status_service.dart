import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/power_status.dart';
import '../models/outage.dart';
import '../models/user_report.dart';

class PowerStatusService {
  static final PowerStatusService _instance = PowerStatusService._internal();
  factory PowerStatusService() => _instance;
  PowerStatusService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current power status
  Stream<PowerStatus?> getCurrentPowerStatus() {
    return _firestore
        .collection('power_status')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return PowerStatus.fromJson(snapshot.docs.first.data());
    });
  }

  // Get active outages
  Stream<List<Outage>> getActiveOutages() {
    return _firestore
        .collection('outages')
        .where('endTime', isNull: true)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Outage.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Get scheduled maintenance
  Stream<List<Outage>> getScheduledMaintenance() {
    DateTime now = DateTime.now();
    return _firestore
        .collection('outages')
        .where('isScheduled', isEqualTo: true)
        .where('startTime', isGreaterThan: now)
        .orderBy('startTime', descending: false)
        .limit(5)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Outage.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Get dashboard statistics
  Stream<Map<String, dynamic>> getDashboardStats() {
    return _firestore
        .collection('dashboard_stats')
        .doc('current')
        .snapshots()
        .map((doc) => doc.exists ? doc.data()! as Map<String, dynamic> : {});
  }

  // Calculate statistics from active outages and reports
  Future<Map<String, dynamic>> calculateStats() async {
    try {
      // Get active outages
      QuerySnapshot outageSnapshot = await _firestore
          .collection('outages')
          .where('endTime', isNull: true)
          .get();

      List<Outage> activeOutages = outageSnapshot.docs
          .map((doc) => Outage.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Get recent reports for affected users calculation
      QuerySnapshot reportSnapshot = await _firestore
          .collection('user_reports')
          .where('timestamp',
              isGreaterThan: DateTime.now().subtract(const Duration(days: 7)))
          .get();

      List<UserReport> recentReports = reportSnapshot.docs
          .map((doc) => UserReport.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Calculate statistics
      int activeOutageCount = activeOutages.length;
      int totalAffectedUsers =
          activeOutages.fold(0, (sum, outage) => sum + outage.affectedUsers);

      // Calculate average duration
      double avgDurationHours = 0;
      if (activeOutages.isNotEmpty) {
        double totalHours = activeOutages
            .map((outage) =>
                outage.actualDuration.inHours +
                outage.actualDuration.inMinutes % 60 / 60)
            .reduce((a, b) => a + b);
        avgDurationHours = totalHours / activeOutages.length;
      }

      // Update dashboard stats in Firestore
      Map<String, dynamic> stats = {
        'activeOutages': activeOutageCount,
        'affectedUsers': totalAffectedUsers,
        'avgDuration': avgDurationHours.toStringAsFixed(1),
        'lastUpdated': FieldValue.serverTimestamp(),
        'recentReports': recentReports.length,
      };

      await _firestore.collection('dashboard_stats').doc('current').set(stats);

      return stats;
    } catch (e) {
      throw Exception('Failed to calculate stats: $e');
    }
  }

  // Get recent user reports for alerts
  Stream<List<UserReport>> getRecentReports() {
    DateTime twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));
    return _firestore
        .collection('user_reports')
        .where('timestamp', isGreaterThan: twoHoursAgo)
        .where('status', isEqualTo: 'pending')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserReport.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Get all outages (both active and historical)
  Stream<List<Outage>> getAllOutages() {
    return _firestore
        .collection('outages')
        .orderBy('startTime', descending: true)
        .limit(50) // Limit to last 50 records for performance
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Outage.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Get historical outages (completed outages)
  Stream<List<Outage>> getHistoricalOutages(
      {DateTime? startDate, DateTime? endDate}) {
    Query query = _firestore.collection('outages').where('endTime',
        isGreaterThan: DateTime.fromMillisecondsSinceEpoch(0));

    if (startDate != null) {
      query = query.where('startTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('endTime',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    return query
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Outage.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Get completed scheduled maintenance
  Stream<List<Outage>> getCompletedMaintenance(
      {DateTime? startDate, DateTime? endDate}) {
    Query query = _firestore
        .collection('outages')
        .where('isScheduled', isEqualTo: true)
        .where('endTime',
            isGreaterThan: DateTime.fromMillisecondsSinceEpoch(0));

    if (startDate != null) {
      query = query.where('startTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('endTime',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    return query
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Outage.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Update power status (for admin)
  Future<void> updatePowerStatus({
    required PowerStatusType status,
    String? message,
    DateTime? estimatedRestoration,
    String? affectedArea,
  }) async {
    try {
      PowerStatus newStatus = PowerStatus(
        id: _firestore.collection('power_status').doc().id,
        status: status,
        timestamp: DateTime.now(),
        message: message,
        estimatedRestoration: estimatedRestoration,
        affectedArea: affectedArea,
      );

      await _firestore.collection('power_status').doc(newStatus.id).set({
        ...newStatus.toJson(),
        'timestamp': FieldValue.serverTimestamp(),
        if (newStatus.estimatedRestoration != null)
          'estimatedRestoration':
              Timestamp.fromDate(newStatus.estimatedRestoration!),
      });
    } catch (e) {
      throw Exception('Failed to update power status: $e');
    }
  }

  // Initialize default data if collection is empty
  Future<void> initializeDefaultData() async {
    try {
      QuerySnapshot statusSnapshot =
          await _firestore.collection('power_status').limit(1).get();

      if (statusSnapshot.docs.isEmpty) {
        // Create initial power status
        PowerStatus initialStatus = PowerStatus(
          id: _firestore.collection('power_status').doc().id,
          status: PowerStatusType.normal,
          timestamp: DateTime.now(),
          message: 'Power service is operating normally',
        );

        await _firestore.collection('power_status').doc(initialStatus.id).set({
          ...initialStatus.toJson(),
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // Initialize dashboard stats
      DocumentSnapshot statsDoc =
          await _firestore.collection('dashboard_stats').doc('current').get();

      if (!statsDoc.exists) {
        Map<String, dynamic> initialStats = {
          'activeOutages': 0,
          'affectedUsers': 0,
          'avgDuration': '0.0',
          'lastUpdated': FieldValue.serverTimestamp(),
          'recentReports': 0,
        };

        await _firestore
            .collection('dashboard_stats')
            .doc('current')
            .set(initialStats);
      }
    } catch (e) {
      throw Exception('Failed to initialize default data: $e');
    }
  }
}
