// import 'package:dio/dio.dart';
// import '../models/outage.dart';
// import '../models/power_status.dart';
// import '../models/user_report.dart';
// import '../models/user.dart';

// class ApiService {
//   static final ApiService _instance = ApiService._internal();
//   factory ApiService() => _instance;
//   ApiService._internal();

//   final Dio _dio = Dio(
//     BaseOptions(
//       baseUrl: 'https://api.powernotify.com', // Replace with actual API URL
//       connectTimeout: const Duration(seconds: 10),
//       receiveTimeout: const Duration(seconds: 10),
//       headers: {
//         'Content-Type': 'application/json',
//       },
//     ),
//   );

//   String? _authToken;

//   void setAuthToken(String token) {
//     _authToken = token;
//     _dio.options.headers['Authorization'] = 'Bearer $token';
//   }

//   void clearAuthToken() {
//     _authToken = null;
//     _dio.options.headers.remove('Authorization');
//   }

//   // Authentication
//   Future<Map<String, dynamic>> login(String email, String password) async {
//     try {
//       final response = await _dio.post('/auth/login', data: {
//         'email': email,
//         'password': password,
//       });
//       return response.data as Map<String, dynamic>;
//     } catch (e) {
//       throw _handleError(e);
//     }
//   }

//   Future<Map<String, dynamic>> signup(String name, String email, String password) async {
//     try {
//       final response = await _dio.post('/auth/signup', data: {
//         'name': name,
//         'email': email,
//         'password': password,
//       });
//       return response.data as Map<String, dynamic>;
//     } catch (e) {
//       throw _handleError(e);
//     }
//   }

//   // Power Status
//   Future<PowerStatus> getCurrentPowerStatus() async {
//     try {
//       final response = await _dio.get('/power/status');
//       return PowerStatus.fromJson(response.data as Map<String, dynamic>);
//     } catch (e) {
//       throw _handleError(e);
//     }
//   }

//   // Outages
//   Future<List<Outage>> getActiveOutages() async {
//     try {
//       final response = await _dio.get('/outages/active');
//       return (response.data as List)
//           .map((json) => Outage.fromJson(json as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       throw _handleError(e);
//     }
//   }

//   Future<List<Outage>> getOutageHistory({int page = 1, int limit = 20}) async {
//     try {
//       final response = await _dio.get('/outages/history', queryParameters: {
//         'page': page,
//         'limit': limit,
//       });
//       return (response.data as List)
//           .map((json) => Outage.fromJson(json as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       throw _handleError(e);
//     }
//   }

//   Future<List<Outage>> getScheduledOutages() async {
//     try {
//       final response = await _dio.get('/outages/scheduled');
//       return (response.data as List)
//           .map((json) => Outage.fromJson(json as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       throw _handleError(e);
//     }
//   }

//   // User Reports
//   Future<UserReport> submitReport(UserReport report) async {
//     try {
//       final response = await _dio.post('/reports', data: report.toJson());
//       return UserReport.fromJson(response.data as Map<String, dynamic>);
//     } catch (e) {
//       throw _handleError(e);
//     }
//   }

//   Future<List<UserReport>> getUserReports() async {
//     try {
//       final response = await _dio.get('/reports/user');
//       return (response.data as List)
//           .map((json) => UserReport.fromJson(json as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       throw _handleError(e);
//     }
//   }

//   // User Profile
//   Future<User> getUserProfile() async {
//     try {
//       final response = await _dio.get('/user/profile');
//       return User.fromJson(response.data as Map<String, dynamic>);
//     } catch (e) {
//       throw _handleError(e);
//     }
//   }

//   Future<User> updateUserProfile(User user) async {
//     try {
//       final response = await _dio.put('/user/profile', data: user.toJson());
//       return User.fromJson(response.data as Map<String, dynamic>);
//     } catch (e) {
//       throw _handleError(e);
//     }
//   }

//   // Admin APIs
//   Future<Outage> createOutage(Outage outage) async {
//     try {
//       final response = await _dio.post('/admin/outages', data: outage.toJson());
//       return Outage.fromJson(response.data as Map<String, dynamic>);
//     } catch (e) {
//       throw _handleError(e);
//     }
//   }

//   Future<Outage> updateOutage(String id, Outage outage) async {
//     try {
//       final response = await _dio.put('/admin/outages/$id', data: outage.toJson());
//       return Outage.fromJson(response.data as Map<String, dynamic>);
//     } catch (e) {
//       throw _handleError(e);
//     }
//   }

//   Future<void> sendBroadcastNotification(String title, String message, List<String> userIds) async {
//     try {
//       await _dio.post('/admin/notifications/broadcast', data: {
//         'title': title,
//         'message': message,
//         'userIds': userIds,
//       });
//     } catch (e) {
//       throw _handleError(e);
//     }
//   }

//   Future<List<UserReport>> getAllReports({String? status}) async {
//     try {
//       final response = await _dio.get('/admin/reports', queryParameters: {
//         if (status != null) 'status': status,
//       });
//       return (response.data as List)
//           .map((json) => UserReport.fromJson(json as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       throw _handleError(e);
//     }
//   }

//   Future<UserReport> updateReportStatus(String reportId, String status, String? adminNotes) async {
//     try {
//       final response = await _dio.put('/admin/reports/$reportId', data: {
//         'status': status,
//         'adminNotes': adminNotes,
//       });
//       return UserReport.fromJson(response.data as Map<String, dynamic>);
//     } catch (e) {
//       throw _handleError(e);
//     }
//   }

//   // Statistics for AI prediction
//   Future<Map<String, dynamic>> getOutageStatistics({
//     DateTime? startDate,
//     DateTime? endDate,
//   }) async {
//     try {
//       final response = await _dio.get('/statistics/outages', queryParameters: {
//         if (startDate != null) 'startDate': startDate.toIso8601String(),
//         if (endDate != null) 'endDate': endDate.toIso8601String(),
//       });
//       return response.data as Map<String, dynamic>;
//     } catch (e) {
//       throw _handleError(e);
//     }
//   }

//   String _handleError(dynamic error) {
//     if (error is DioException) {
//       switch (error.type) {
//         case DioExceptionType.connectionTimeout:
//         case DioExceptionType.sendTimeout:
//         case DioExceptionType.receiveTimeout:
//           return 'Connection timeout. Please check your internet connection.';
//         case DioExceptionType.badResponse:
//           return error.response?.data['message'] ?? 'Server error occurred.';
//         case DioExceptionType.cancel:
//           return 'Request cancelled.';
//         default:
//           return 'Network error. Please try again.';
//       }
//     }
//     return error.toString();
//   }
// }
