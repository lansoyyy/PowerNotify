import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/power_status.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<HistoryItem> _allHistory = [
    HistoryItem(
      type: PowerStatusType.outage,
      area: 'Barangay San Jose',
      startTime: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
      endTime: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
      reason: 'Transformer failure',
      affectedUsers: 450,
    ),
    HistoryItem(
      type: PowerStatusType.scheduled,
      area: 'Barangay Santa Cruz',
      startTime: DateTime.now().subtract(const Duration(days: 5)),
      endTime: DateTime.now().subtract(const Duration(days: 5)).add(const Duration(hours: 4)),
      reason: 'Line maintenance',
      affectedUsers: 320,
    ),
    HistoryItem(
      type: PowerStatusType.outage,
      area: 'Barangay Poblacion',
      startTime: DateTime.now().subtract(const Duration(days: 7, hours: 5)),
      endTime: DateTime.now().subtract(const Duration(days: 7, hours: 2)),
      reason: 'Weather-related damage',
      affectedUsers: 680,
    ),
    HistoryItem(
      type: PowerStatusType.scheduled,
      area: 'Barangay Del Pilar',
      startTime: DateTime.now().subtract(const Duration(days: 10)),
      endTime: DateTime.now().subtract(const Duration(days: 10)).add(const Duration(hours: 3)),
      reason: 'Substation upgrade',
      affectedUsers: 520,
    ),
    HistoryItem(
      type: PowerStatusType.outage,
      area: 'Barangay Riverside',
      startTime: DateTime.now().subtract(const Duration(days: 14, hours: 2)),
      endTime: DateTime.now().subtract(const Duration(days: 14)),
      reason: 'Equipment malfunction',
      affectedUsers: 390,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<HistoryItem> get _outageHistory =>
      _allHistory.where((item) => item.type == PowerStatusType.outage).toList();

  List<HistoryItem> get _scheduledHistory =>
      _allHistory.where((item) => item.type == PowerStatusType.scheduled).toList();

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
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
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
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHistoryList(_allHistory),
          _buildHistoryList(_outageHistory),
          _buildHistoryList(_scheduledHistory),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<HistoryItem> items) {
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
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildHistoryCard(items[index]);
      },
    );
  }

  Widget _buildHistoryCard(HistoryItem item) {
    final duration = item.endTime.difference(item.startTime);
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
          onTap: () => _showHistoryDetails(item),
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
                        color: _getStatusColor(item.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getStatusIcon(item.type),
                        color: _getStatusColor(item.type),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.area,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Bold',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM dd, yyyy • hh:mm a').format(item.startTime),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(item.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${hours}h ${minutes}m',
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(item.type),
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
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.reason,
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
                      '${item.affectedUsers} users affected',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: 'Regular',
                      ),
                    ),
                  ],
                ),
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

  void _showHistoryDetails(HistoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final duration = item.endTime.difference(item.startTime);
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
                      color: _getStatusColor(item.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getStatusIcon(item.type),
                      color: _getStatusColor(item.type),
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.area,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Bold',
                          ),
                        ),
                        Text(
                          item.type == PowerStatusType.outage
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
              _buildDetailItem('Start Time', DateFormat('MMM dd, yyyy • hh:mm a').format(item.startTime)),
              _buildDetailItem('End Time', DateFormat('MMM dd, yyyy • hh:mm a').format(item.endTime)),
              _buildDetailItem('Duration', '${duration.inHours}h ${duration.inMinutes % 60}m'),
              _buildDetailItem('Affected Users', '${item.affectedUsers} users'),
              _buildDetailItem('Reason', item.reason),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
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
}

class HistoryItem {
  final PowerStatusType type;
  final String area;
  final DateTime startTime;
  final DateTime endTime;
  final String reason;
  final int affectedUsers;

  HistoryItem({
    required this.type,
    required this.area,
    required this.startTime,
    required this.endTime,
    required this.reason,
    required this.affectedUsers,
  });
}
