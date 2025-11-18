import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/user_report.dart';
import '../models/outage.dart';
import '../models/power_status.dart';
import 'notification_service.dart';

class ReportService {
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Submit a new user report
  Future<Map<String, dynamic>> submitUserReport({
    required String userId,
    required double latitude,
    required double longitude,
    required String description,
    String? address,
    List<String> imagePaths = const [],
  }) async {
    try {
      // Upload images to Firebase Storage
      List<String> photoUrls = [];
      for (int i = 0; i < imagePaths.length; i++) {
        try {
          String photoUrl = await _uploadImage(imagePaths[i],
              'report_${DateTime.now().millisecondsSinceEpoch}_$i.jpg');
          photoUrls.add(photoUrl);
        } catch (e) {
          print('Failed to upload image $i: $e');
        }
      }

      // Create report document
      String reportId = _firestore.collection('user_reports').doc().id;

      UserReport report = UserReport(
        id: reportId,
        userId: userId,
        timestamp: DateTime.now(),
        latitude: latitude,
        longitude: longitude,
        address: address,
        description: description,
        photoUrls: photoUrls,
        status: 'pending',
        adminNotes: null,
        verifiedAt: null,
      );

      await _firestore.collection('user_reports').doc(reportId).set({
        ...report.toJson(),
        'timestamp': FieldValue.serverTimestamp(),
        if (report.verifiedAt != null)
          'verifiedAt': Timestamp.fromDate(report.verifiedAt!),
      });

      return {
        'success': true,
        'message': 'Report submitted successfully',
        'reportId': reportId,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to submit report: ${e.toString()}',
      };
    }
  }

  // Upload image to Firebase Storage
  Future<String> _uploadImage(String imagePath, String fileName) async {
    try {
      Reference ref = _storage.ref().child('report_images/$fileName');
      UploadTask uploadTask = ref.putFile(imagePath as File);

      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Get all user reports for a specific user
  Future<List<UserReport>> getUserReports(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('user_reports')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserReport.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user reports: $e');
    }
  }

  // Get all pending reports (for admin)
  Future<List<UserReport>> getPendingReports() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('user_reports')
          .where('status', isEqualTo: 'pending')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserReport.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get pending reports: $e');
    }
  }

  // Update report status (for admin)
  Future<Map<String, dynamic>> updateReportStatus({
    required String reportId,
    required String status,
    String? adminNotes,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'status': status,
        'verifiedAt': FieldValue.serverTimestamp(),
      };

      if (adminNotes != null) {
        updateData['adminNotes'] = adminNotes;
      }

      await _firestore
          .collection('user_reports')
          .doc(reportId)
          .update(updateData);

      // Get user ID from report to send notification
      DocumentSnapshot reportDoc =
          await _firestore.collection('user_reports').doc(reportId).get();

      if (reportDoc.exists) {
        String userId = reportDoc['userId'];

        // Send notification to user about status update
        await NotificationService().sendReportStatusUpdate(
          userId: userId,
          reportId: reportId,
          newStatus: status,
          adminNotes: adminNotes,
        );
      }

      return {
        'success': true,
        'message': 'Report status updated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update report status: ${e.toString()}',
      };
    }
  }

  // Create an outage from verified reports (for admin)
  Future<Map<String, dynamic>> createOutage({
    required double latitude,
    required double longitude,
    required String affectedArea,
    required List<String> affectedBarangays,
    String? reason,
    String? description,
    bool isScheduled = false,
  }) async {
    try {
      String outageId = _firestore.collection('outages').doc().id;

      Outage outage = Outage(
        id: outageId,
        type: PowerStatusType.outage,
        startTime: DateTime.now(),
        endTime: null,
        duration: null,
        affectedArea: affectedArea,
        affectedBarangays: affectedBarangays,
        latitude: latitude,
        longitude: longitude,
        reason: reason,
        description: description,
        isScheduled: isScheduled,
        affectedUsers: 0, // Will be calculated based on user reports
      );

      await _firestore.collection('outages').doc(outageId).set({
        ...outage.toJson(),
        'startTime': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Outage created successfully',
        'outageId': outageId,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create outage: ${e.toString()}',
      };
    }
  }

  // Get active outages
  Future<List<Outage>> getActiveOutages() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('outages')
          .where('endTime', isNull: true)
          .orderBy('startTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Outage.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get active outages: $e');
    }
  }

  // Get all outages
  Future<List<Outage>> getAllOutages() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('outages')
          .orderBy('startTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Outage.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all outages: $e');
    }
  }
}
