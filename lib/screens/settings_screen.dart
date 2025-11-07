import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushEnabled = true;
  bool _smsEnabled = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _scheduledOutagesEnabled = true;
  bool _unscheduledOutagesEnabled = true;
  bool _restorationAlertsEnabled = true;
  
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 7, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Notification Settings',
          style: TextStyle(
            fontFamily: 'Bold',
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildSection(
              'Notification Channels',
              [
                _buildSwitchTile(
                  'Push Notifications',
                  'Receive push notifications on your device',
                  Icons.notifications_active,
                  _pushEnabled,
                  (value) => setState(() => _pushEnabled = value),
                ),
                _buildSwitchTile(
                  'SMS Alerts',
                  'Receive SMS text messages for critical alerts',
                  Icons.sms,
                  _smsEnabled,
                  (value) => setState(() => _smsEnabled = value),
                ),
              ],
            ),
            _buildSection(
              'Alert Preferences',
              [
                _buildSwitchTile(
                  'Sound',
                  'Play sound for notifications',
                  Icons.volume_up,
                  _soundEnabled,
                  (value) => setState(() => _soundEnabled = value),
                ),
                _buildSwitchTile(
                  'Vibration',
                  'Vibrate for notifications',
                  Icons.vibration,
                  _vibrationEnabled,
                  (value) => setState(() => _vibrationEnabled = value),
                ),
              ],
            ),
            _buildSection(
              'Alert Types',
              [
                _buildSwitchTile(
                  'Scheduled Outages',
                  'Get notified about planned maintenance',
                  Icons.schedule,
                  _scheduledOutagesEnabled,
                  (value) => setState(() => _scheduledOutagesEnabled = value),
                ),
                _buildSwitchTile(
                  'Unscheduled Outages',
                  'Get notified about unexpected power outages',
                  Icons.power_off,
                  _unscheduledOutagesEnabled,
                  (value) => setState(() => _unscheduledOutagesEnabled = value),
                ),
                _buildSwitchTile(
                  'Restoration Alerts',
                  'Get notified when power is restored',
                  Icons.check_circle,
                  _restorationAlertsEnabled,
                  (value) => setState(() => _restorationAlertsEnabled = value),
                ),
              ],
            ),
            _buildSection(
              'Quiet Hours',
              [
                _buildTimeTile(
                  'Start Time',
                  _quietHoursStart,
                  () => _selectTime(true),
                ),
                _buildTimeTile(
                  'End Time',
                  _quietHoursEnd,
                  () => _selectTime(false),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Notifications will be silenced during quiet hours, except for critical alerts.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontFamily: 'Regular',
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Settings saved successfully'),
                        backgroundColor: Colors.green.shade600,
                      ),
                    );
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
                    'Save Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Bold',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
                fontFamily: 'Bold',
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blue.shade700, size: 24),
          ),
          const SizedBox(width: 16),
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTile(String label, TimeOfDay time, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Regular',
                ),
              ),
              Row(
                children: [
                  Text(
                    time.format(context),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                      fontFamily: 'Bold',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _quietHoursStart : _quietHoursEnd,
    );
    
    if (picked != null) {
      setState(() {
        if (isStart) {
          _quietHoursStart = picked;
        } else {
          _quietHoursEnd = picked;
        }
      });
    }
  }
}
