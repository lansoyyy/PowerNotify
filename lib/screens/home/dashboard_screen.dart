import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/power_status.dart';
import '../../utils/colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  PowerStatusType _currentStatus = PowerStatusType.normal;
  DateTime? _estimatedRestoration;
  Duration _outageDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    // Simulate different statuses for demo
    _currentStatus = PowerStatusType.normal;
    _estimatedRestoration = DateTime.now().add(const Duration(hours: 2));
    _outageDuration = const Duration(hours: 1, minutes: 30);
  }

  Color _getStatusColor() {
    switch (_currentStatus) {
      case PowerStatusType.normal:
        return Colors.green;
      case PowerStatusType.outage:
        return Colors.red;
      case PowerStatusType.scheduled:
        return Colors.amber;
    }
  }

  String _getStatusText() {
    switch (_currentStatus) {
      case PowerStatusType.normal:
        return 'Power On';
      case PowerStatusType.outage:
        return 'Power Outage';
      case PowerStatusType.scheduled:
        return 'Scheduled Maintenance';
    }
  }

  IconData _getStatusIcon() {
    switch (_currentStatus) {
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
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
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
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getStatusColor(),
            _getStatusColor().withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor().withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _getStatusIcon(),
            size: 80,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            _getStatusText(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Bold',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: ${DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.now())}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              fontFamily: 'Regular',
            ),
          ),
          if (_currentStatus != PowerStatusType.normal) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
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
                        '${_outageDuration.inHours}h ${_outageDuration.inMinutes % 60}m',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Bold',
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  if (_estimatedRestoration != null) ...[
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
                          DateFormat('hh:mm a').format(_estimatedRestoration!),
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

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Active Outages',
              '3',
              Icons.power_off,
              Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Affected Users',
              '1.2K',
              Icons.people,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Avg. Duration',
              '2.5h',
              Icons.timer,
              Colors.blue,
            ),
          ),
        ],
      ),
    );
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
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAlertItem(
            'Power Outage',
            'Barangay San Jose - Estimated 2 hours',
            Colors.red,
            Icons.power_off,
          ),
          const Divider(height: 24),
          _buildAlertItem(
            'Scheduled Maintenance',
            'Barangay Santa Cruz - Tomorrow 8:00 AM',
            Colors.amber,
            Icons.schedule,
          ),
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
          _buildMaintenanceItem(
            'Nov 10, 2025',
            '8:00 AM - 12:00 PM',
            'Barangay Santa Cruz, San Jose',
            'Transformer upgrade',
          ),
          const Divider(height: 24),
          _buildMaintenanceItem(
            'Nov 15, 2025',
            '6:00 AM - 10:00 AM',
            'Barangay Poblacion',
            'Line maintenance',
          ),
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
