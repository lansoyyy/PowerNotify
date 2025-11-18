import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/power_status.dart';
import '../../models/outage.dart';
import '../../models/user_report.dart';
import '../../utils/colors.dart';
import '../../services/power_status_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PowerStatusService _powerStatusService = PowerStatusService();

  PowerStatus? _currentPowerStatus;
  List<Outage> _activeOutages = [];
  List<Outage> _scheduledMaintenance = [];
  List<UserReport> _recentReports = [];
  Map<String, dynamic> _dashboardStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // Initialize default data if needed
      await _powerStatusService.initializeDefaultData();

      // Calculate initial statistics
      await _powerStatusService.calculateStats();
    } catch (e) {
      print('Error initializing data: $e');
    }
  }

  Color _getStatusColor(PowerStatusType status) {
    switch (status) {
      case PowerStatusType.normal:
        return Colors.green;
      case PowerStatusType.outage:
        return Colors.red;
      case PowerStatusType.scheduled:
        return Colors.amber;
    }
  }

  String _getStatusText(PowerStatusType status) {
    switch (status) {
      case PowerStatusType.normal:
        return 'Power On';
      case PowerStatusType.outage:
        return 'Power Outage';
      case PowerStatusType.scheduled:
        return 'Scheduled Maintenance';
    }
  }

  IconData _getStatusIcon(PowerStatusType status) {
    switch (status) {
      case PowerStatusType.normal:
        return Icons.check_circle;
      case PowerStatusType.outage:
        return Icons.power_off;
      case PowerStatusType.scheduled:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'PowerNotify',
          style: TextStyle(
            fontFamily: 'Bold',
            color: AppColors.textWhite,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: AppColors.textWhite),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),
      body: StreamBuilder<PowerStatus?>(
        stream: _powerStatusService.getCurrentPowerStatus(),
        builder: (context, statusSnapshot) {
          return StreamBuilder<List<Outage>>(
            stream: _powerStatusService.getActiveOutages(),
            builder: (context, activeOutagesSnapshot) {
              return StreamBuilder<List<Outage>>(
                stream: _powerStatusService.getScheduledMaintenance(),
                builder: (context, scheduledSnapshot) {
                  return StreamBuilder<List<UserReport>>(
                    stream: _powerStatusService.getRecentReports(),
                    builder: (context, reportsSnapshot) {
                      return StreamBuilder<Map<String, dynamic>>(
                        stream: _powerStatusService.getDashboardStats(),
                        builder: (context, statsSnapshot) {
                          // Update state when data changes
                          if (statusSnapshot.hasData) {
                            _currentPowerStatus = statusSnapshot.data;
                          }
                          if (activeOutagesSnapshot.hasData) {
                            _activeOutages = activeOutagesSnapshot.data!;
                          }
                          if (scheduledSnapshot.hasData) {
                            _scheduledMaintenance = scheduledSnapshot.data!;
                          }
                          if (reportsSnapshot.hasData) {
                            _recentReports = reportsSnapshot.data!;
                          }
                          if (statsSnapshot.hasData) {
                            _dashboardStats = statsSnapshot.data!;
                          }

                          // Set loading state
                          _isLoading = !statusSnapshot.hasData &&
                              !activeOutagesSnapshot.hasData &&
                              !scheduledSnapshot.hasData &&
                              !reportsSnapshot.hasData &&
                              !statsSnapshot.hasData;

                          return RefreshIndicator(
                            onRefresh: () async {
                              await _powerStatusService.calculateStats();
                              setState(() {});
                            },
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                children: [
                                  _buildStatusCard(),
                                  const SizedBox(height: 16),
                                  _buildQuickStats(),
                                  const SizedBox(height: 16),
                                  _buildActiveAlerts(),
                                  const SizedBox(height: 16),
                                  _buildScheduledMaintenance(),
                                  const SizedBox(height: 100), // Space for FAB
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/report');
        },
        backgroundColor: Colors.red.shade600,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusCard() {
    if (_currentPowerStatus == null) {
      return _buildLoadingCard();
    }

    PowerStatusType status = _currentPowerStatus!.status;
    Color statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor,
            statusColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _getStatusIcon(status),
            size: 80,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            _getStatusText(status),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Bold',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: ${DateFormat('MMM dd, yyyy hh:mm a').format(_currentPowerStatus!.timestamp)}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              fontFamily: 'Regular',
            ),
          ),
          if (_currentPowerStatus!.message != null) ...[
            const SizedBox(height: 8),
            Text(
              _currentPowerStatus!.message!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                fontFamily: 'Regular',
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (status != PowerStatusType.normal) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  if (_activeOutages.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Duration:',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Medium',
                          ),
                        ),
                        Text(
                          '${_activeOutages.first.actualDuration.inHours}h ${_activeOutages.first.actualDuration.inMinutes % 60}m',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Bold',
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_currentPowerStatus!.estimatedRestoration != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Est. Restoration:',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Medium',
                          ),
                        ),
                        Text(
                          DateFormat('hh:mm a').format(
                              _currentPowerStatus!.estimatedRestoration!),
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Bold',
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _buildQuickStats() {
    if (_dashboardStats.isEmpty) {
      return _buildLoadingStats();
    }

    String activeOutages = _dashboardStats['activeOutages']?.toString() ?? '0';
    String affectedUsers =
        _formatAffectedUsers(_dashboardStats['affectedUsers']?.toInt() ?? 0);
    String avgDuration =
        '${_dashboardStats['avgDuration']?.toString() ?? '0.0'}h';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Active Outages',
              activeOutages,
              Icons.power_off,
              Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Affected Users',
              affectedUsers,
              Icons.people,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Avg. Duration',
              avgDuration,
              Icons.timer,
              Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildLoadingStatCard()),
          const SizedBox(width: 12),
          Expanded(child: _buildLoadingStatCard()),
          const SizedBox(width: 12),
          Expanded(child: _buildLoadingStatCard()),
        ],
      ),
    );
  }

  Widget _buildLoadingStatCard() {
    return Container(
      height: 100,
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
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  String _formatAffectedUsers(int users) {
    if (users >= 1000) {
      return '${(users / 1000).toStringAsFixed(1)}K';
    }
    return users.toString();
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'Bold',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontFamily: 'Regular',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveAlerts() {
    List<Widget> alertItems = [];

    // Add active outages
    for (var outage in _activeOutages.take(3)) {
      alertItems.add(_buildAlertItem(
        'Power Outage',
        '${outage.affectedArea} - ${outage.affectedBarangays.join(", ")}',
        Colors.red,
        Icons.power_off,
      ));
      if (outage != _activeOutages.last) {
        alertItems.add(const Divider(height: 24));
      }
    }

    // Add recent reports if no active outages
    if (_activeOutages.isEmpty && _recentReports.isNotEmpty) {
      for (var report in _recentReports.take(2)) {
        alertItems.add(_buildAlertItem(
          'New Report',
          report.description.length > 50
              ? '${report.description.substring(0, 50)}...'
              : report.description,
          Colors.orange,
          Icons.report_problem,
        ));
        if (report != _recentReports.last) {
          alertItems.add(const Divider(height: 24));
        }
      }
    }

    // Show placeholder if no alerts
    if (alertItems.isEmpty) {
      alertItems.add(
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'No active alerts at this time',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontFamily: 'Regular',
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Alerts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Bold',
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/history');
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...alertItems,
        ],
      ),
    );
  }

  Widget _buildAlertItem(
      String title, String subtitle, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Bold',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontFamily: 'Regular',
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: Colors.grey.shade400),
      ],
    );
  }

  Widget _buildScheduledMaintenance() {
    List<Widget> maintenanceItems = [];

    // Add scheduled maintenance items
    for (var maintenance in _scheduledMaintenance.take(3)) {
      maintenanceItems.add(_buildMaintenanceItem(
        DateFormat('MMM dd, yyyy').format(maintenance.startTime),
        '${DateFormat('hh:mm a').format(maintenance.startTime)} - ${maintenance.endTime != null ? DateFormat('hh:mm a').format(maintenance.endTime!) : 'Ongoing'}',
        maintenance.affectedArea,
        maintenance.reason ?? 'Scheduled maintenance',
      ));

      if (maintenance != _scheduledMaintenance.last) {
        maintenanceItems.add(const Divider(height: 24));
      }
    }

    // Show placeholder if no scheduled maintenance
    if (maintenanceItems.isEmpty) {
      maintenanceItems.add(
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'No scheduled maintenance at this time',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontFamily: 'Regular',
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Maintenance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Bold',
            ),
          ),
          const SizedBox(height: 16),
          ...maintenanceItems,
        ],
      ),
    );
  }

  Widget _buildMaintenanceItem(
      String date, String time, String location, String reason) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                date,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.amber,
                  fontFamily: 'Bold',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              time,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontFamily: 'Medium',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          location,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: 'Bold',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          reason,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontFamily: 'Regular',
          ),
        ),
      ],
    );
  }
}
