import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/power_status.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  
  // Sample outage locations
  final List<OutageMarker> _outageMarkers = [
    OutageMarker(
      position: const LatLng(14.5995, 120.9842), // Manila
      type: PowerStatusType.outage,
      area: 'Barangay San Jose',
      affectedUsers: 450,
    ),
    OutageMarker(
      position: const LatLng(14.6091, 120.9823),
      type: PowerStatusType.scheduled,
      area: 'Barangay Santa Cruz',
      affectedUsers: 320,
    ),
    OutageMarker(
      position: const LatLng(14.5932, 120.9762),
      type: PowerStatusType.outage,
      area: 'Barangay Poblacion',
      affectedUsers: 580,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Outage Map',
          style: TextStyle(
            fontFamily: 'Bold',
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.white),
            onPressed: () {
              // Center map on user location
              _mapController.move(const LatLng(14.5995, 120.9842), 13);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(14.5995, 120.9842),
              initialZoom: 13.0,
              minZoom: 10.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.powernotify.app',
              ),
              MarkerLayer(
                markers: _outageMarkers.map((outage) {
                  return Marker(
                    point: outage.position,
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () => _showOutageDetails(outage),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getMarkerColor(outage.type),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getMarkerIcon(outage.type),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildLegend(),
          ),
        ],
      ),
    );
  }

  Color _getMarkerColor(PowerStatusType type) {
    switch (type) {
      case PowerStatusType.outage:
        return Colors.red;
      case PowerStatusType.scheduled:
        return Colors.amber;
      case PowerStatusType.normal:
        return Colors.green;
    }
  }

  IconData _getMarkerIcon(PowerStatusType type) {
    switch (type) {
      case PowerStatusType.outage:
        return Icons.power_off;
      case PowerStatusType.scheduled:
        return Icons.schedule;
      case PowerStatusType.normal:
        return Icons.check;
    }
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Legend',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Bold',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem(Colors.red, 'Outage'),
              _buildLegendItem(Colors.amber, 'Scheduled'),
              _buildLegendItem(Colors.green, 'Normal'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'Regular',
          ),
        ),
      ],
    );
  }

  void _showOutageDetails(OutageMarker outage) {
    showModalBottomSheet(
      context: context,
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getMarkerColor(outage.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getMarkerIcon(outage.type),
                      color: _getMarkerColor(outage.type),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          outage.area,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Bold',
                          ),
                        ),
                        Text(
                          outage.type == PowerStatusType.outage
                              ? 'Active Outage'
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
              _buildDetailRow(
                Icons.people,
                'Affected Users',
                '${outage.affectedUsers} users',
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.access_time,
                'Duration',
                '2 hours 30 minutes',
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.schedule,
                'Est. Restoration',
                '4:30 PM',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontFamily: 'Regular',
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Bold',
          ),
        ),
      ],
    );
  }
}

class OutageMarker {
  final LatLng position;
  final PowerStatusType type;
  final String area;
  final int affectedUsers;

  OutageMarker({
    required this.position,
    required this.type,
    required this.area,
    required this.affectedUsers,
  });
}
