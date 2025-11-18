import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/power_status.dart';
import '../../models/outage.dart';
import '../../models/user_report.dart';
import '../../services/power_status_service.dart';
import '../../services/report_service.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PowerStatusService _powerStatusService = PowerStatusService();
  final ReportService _reportService = ReportService();
  final AuthService _authService = AuthService();

  List<Outage> _allOutages = [];
  List<UserReport> _userReports = [];
  bool _isLoading = true;
  String _searchQuery = '';
  DateTimeRange? _dateRange;
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription? _outageSubscription;
  StreamSubscription? _reportSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadHistoryData();
  }

  Future<void> _loadHistoryData() async {
    try {
      // Load all outages (both active and historical)
      _outageSubscription =
          _powerStatusService.getAllOutages().listen((outages) {
        setState(() {
          _allOutages = outages;
          _isLoading = false;
        });
      });

      // Load user reports (for authenticated users)
      String? userId = _authService.currentUserId;
      if (userId != null) {
        _reportSubscription =
            _reportService.getUserReportsStream(userId).listen((reports) {
          setState(() {
            _userReports = reports;
          });
        });
      } else {
        // If not logged in, load all reports (for demo purposes)
        _reportSubscription =
            _reportService.getAllUserReportsStream().listen((reports) {
          setState(() {
            _userReports = reports.take(10).toList(); // Limit to 10 for demo
          });
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading history data: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _outageSubscription?.cancel();
    _reportSubscription?.cancel();
    super.dispose();
  }

  List<Outage> get _outageHistory => _allOutages
      .where((outage) => outage.type == PowerStatusType.outage)
      .toList();

  List<Outage> get _scheduledHistory => _allOutages
      .where((outage) =>
          outage.type == PowerStatusType.scheduled || outage.isScheduled)
      .toList();

  List<Outage> get _filteredOutages {
    List<Outage> filtered = _allOutages;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((outage) =>
              outage.affectedArea
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              outage.reason
                      ?.toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ==
                  true ||
              outage.affectedBarangays.any((barangay) =>
                  barangay.toLowerCase().contains(_searchQuery.toLowerCase())))
          .toList();
    }

    // Apply date range filter
    if (_dateRange != null) {
      filtered = filtered
          .where((outage) =>
              outage.startTime.isAfter(
                  _dateRange!.start.subtract(const Duration(days: 1))) &&
              (outage.endTime?.isBefore(
                          _dateRange!.end.add(const Duration(days: 1))) ==
                      true ||
                  outage.startTime
                      .isBefore(_dateRange!.end.add(const Duration(days: 1)))))
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(
            fontFamily: 'Bold',
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: _exportHistoryData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontFamily: 'Bold',
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Outages'),
            Tab(text: 'Scheduled'),
            Tab(text: 'Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHistoryList(_filteredOutages),
          _buildHistoryList(_outageHistory),
          _buildHistoryList(_scheduledHistory),
          _buildReportsHistory(),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search History'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search by area, reason, or barangay...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter History'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Date Range'),
                subtitle: Text(_dateRange != null
                    ? '${DateFormat('MMM dd, yyyy').format(_dateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_dateRange!.end)}'
                    : 'All dates'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          primaryColor: AppColors.primary,
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _dateRange = picked;
                    });
                    this.setState(() {});
                  }
                },
              ),
              if (_dateRange != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _dateRange = null;
                    });
                    this.setState(() {});
                  },
                  child: const Text('Clear Date Filter'),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportHistoryData() async {
    try {
      // Determine which tab is active
      int currentIndex = _tabController.index;
      List<Map<String, dynamic>> exportData = [];
      String fileName = '';

      switch (currentIndex) {
        case 0: // All
          exportData = _allOutages.map((outage) => outage.toJson()).toList();
          fileName = 'all_outage_history';
          break;
        case 1: // Outages
          exportData = _outageHistory.map((outage) => outage.toJson()).toList();
          fileName = 'outage_history';
          break;
        case 2: // Scheduled
          exportData =
              _scheduledHistory.map((outage) => outage.toJson()).toList();
          fileName = 'scheduled_maintenance_history';
          break;
        case 3: // Reports
          exportData = _userReports.map((report) => report.toJson()).toList();
          fileName = 'user_reports_history';
          break;
      }

      if (exportData.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No data available to export'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Preparing export...'),
            ],
          ),
        ),
      );

      // Create CSV content
      String csvContent = _generateCsvContent(exportData, currentIndex);

      // Close loading dialog
      Navigator.pop(context);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export prepared: ${exportData.length} records'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () => _showExportPreview(csvContent, fileName),
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _generateCsvContent(List<Map<String, dynamic>> data, int tabIndex) {
    if (data.isEmpty) return '';

    List<String> headers = [];
    List<List<String>> rows = [];

    // Define headers based on data type
    if (tabIndex == 3) {
      // Reports
      headers = [
        'ID',
        'Date',
        'Status',
        'Description',
        'Address',
        'Photo Count'
      ];
      for (var item in data) {
        rows.add([
          item['id']?.toString() ?? '',
          _formatDate(item['timestamp']),
          item['status']?.toString() ?? '',
          _escapeCsvField(item['description']?.toString() ?? ''),
          _escapeCsvField(item['address']?.toString() ?? ''),
          (item['photoUrls'] as List?)?.length.toString() ?? '0',
        ]);
      }
    } else {
      // Outages
      headers = [
        'ID',
        'Start Time',
        'End Time',
        'Duration',
        'Area',
        'Type',
        'Affected Users',
        'Reason'
      ];
      for (var item in data) {
        DateTime startTime =
            (item['startTime'] as Timestamp?)?.toDate() ?? DateTime.now();
        DateTime? endTime = (item['endTime'] as Timestamp?)?.toDate();
        Duration duration =
            endTime != null ? endTime.difference(startTime) : Duration.zero;

        rows.add([
          item['id']?.toString() ?? '',
          _formatDate(item['startTime']),
          _formatDate(item['endTime']),
          '${duration.inHours}h ${duration.inMinutes % 60}m',
          _escapeCsvField(item['affectedArea']?.toString() ?? ''),
          item['type']?.toString() ?? '',
          item['affectedUsers']?.toString() ?? '0',
          _escapeCsvField(item['reason']?.toString() ?? ''),
        ]);
      }
    }

    // Convert to CSV
    String csv = headers.join(',') + '\n';
    for (var row in rows) {
      csv += row.join(',') + '\n';
    }

    return csv;
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is DateTime) {
      date = timestamp;
    } else {
      return '';
    }
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  void _showExportPreview(String csvContent, String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Preview: $fileName'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: SelectableText(
              csvContent.length > 1000
                  ? '${csvContent.substring(0, 1000)}...\n\n(Truncated for preview)'
                  : csvContent,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // In a real app, you would save this to a file
              // For now, just show a message
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'CSV data copied to clipboard (in real app, would save file)'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Copy to Clipboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<Outage> items) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No history found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontFamily: 'Medium',
              ),
            ),
            const SizedBox(height: 8),
            if (_searchQuery.isNotEmpty || _dateRange != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _dateRange = null;
                    _searchController.clear();
                  });
                },
                child: const Text('Clear Filters'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh data
        await _loadHistoryData();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildOutageCard(items[index]);
        },
      ),
    );
  }

  Widget _buildReportsHistory() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    String? userId = _authService.currentUserId;
    bool isLoggedIn = userId != null;

    if (_userReports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.report_problem,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              isLoggedIn ? 'No reports found' : 'Sign in to view your reports',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontFamily: 'Medium',
              ),
            ),
            const SizedBox(height: 8),
            if (!isLoggedIn)
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text('Sign In'),
              )
            else
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/report');
                },
                child: const Text('Submit a Report'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh data
        await _loadHistoryData();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _userReports.length,
        itemBuilder: (context, index) {
          return _buildReportCard(_userReports[index]);
        },
      ),
    );
  }

  Widget _buildOutageCard(Outage outage) {
    final duration = outage.actualDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showOutageDetails(outage),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getStatusColor(outage.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getStatusIcon(outage.type),
                        color: _getStatusColor(outage.type),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            outage.affectedArea,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Bold',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM dd, yyyy • hh:mm a')
                                .format(outage.startTime),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontFamily: 'Regular',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(outage.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${hours}h ${minutes}m',
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(outage.type),
                          fontFamily: 'Bold',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (outage.reason != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            outage.reason!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              fontFamily: 'Regular',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${outage.affectedUsers} users affected',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: 'Regular',
                      ),
                    ),
                  ],
                ),
                if (outage.affectedBarangays.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          outage.affectedBarangays.take(3).join(', ') +
                              (outage.affectedBarangays.length > 3
                                  ? '...'
                                  : ''),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontFamily: 'Regular',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(UserReport report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showReportDetails(report),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.report_problem,
                        color: Colors.orange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'User Report',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Bold',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM dd, yyyy • hh:mm a')
                                .format(report.timestamp),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontFamily: 'Regular',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColorFromStatus(report.status)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        report.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColorFromStatus(report.status),
                          fontFamily: 'Bold',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          report.description.length > 100
                              ? '${report.description.substring(0, 100)}...'
                              : report.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            fontFamily: 'Regular',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (report.address != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          report.address!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontFamily: 'Regular',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(PowerStatusType type) {
    switch (type) {
      case PowerStatusType.outage:
        return Colors.red;
      case PowerStatusType.scheduled:
        return Colors.amber;
      case PowerStatusType.normal:
        return Colors.green;
    }
  }

  IconData _getStatusIcon(PowerStatusType type) {
    switch (type) {
      case PowerStatusType.outage:
        return Icons.power_off;
      case PowerStatusType.scheduled:
        return Icons.schedule;
      case PowerStatusType.normal:
        return Icons.check_circle;
    }
  }

  void _showOutageDetails(Outage outage) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final duration = outage.actualDuration;
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getStatusColor(outage.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getStatusIcon(outage.type),
                      color: _getStatusColor(outage.type),
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          outage.affectedArea,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Bold',
                          ),
                        ),
                        Text(
                          outage.type == PowerStatusType.outage
                              ? 'Power Outage'
                              : 'Scheduled Maintenance',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontFamily: 'Regular',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailItem(
                  'Start Time',
                  DateFormat('MMM dd, yyyy • hh:mm a')
                      .format(outage.startTime)),
              if (outage.endTime != null)
                _buildDetailItem(
                    'End Time',
                    DateFormat('MMM dd, yyyy • hh:mm a')
                        .format(outage.endTime!)),
              _buildDetailItem('Duration',
                  '${duration.inHours}h ${duration.inMinutes % 60}m'),
              _buildDetailItem(
                  'Affected Users', '${outage.affectedUsers} users'),
              if (outage.reason != null)
                _buildDetailItem('Reason', outage.reason!),
              if (outage.affectedBarangays.isNotEmpty)
                _buildDetailItem(
                    'Affected Areas', outage.affectedBarangays.join(', ')),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Bold',
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReportDetails(UserReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.report_problem,
                      color: Colors.orange,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Report',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Bold',
                          ),
                        ),
                        Text(
                          'Status: ${report.status.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontFamily: 'Regular',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailItem(
                  'Report Date',
                  DateFormat('MMM dd, yyyy • hh:mm a')
                      .format(report.timestamp)),
              if (report.address != null)
                _buildDetailItem('Location', report.address!),
              _buildDetailItem('Description', report.description),
              if (report.photoUrls.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Photos:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Bold',
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: report.photoUrls.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(report.photoUrls[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (report.adminNotes != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Admin Notes:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Bold',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.adminNotes!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontFamily: 'Regular',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Bold',
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontFamily: 'Regular',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Bold',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColorFromStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'verified':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
