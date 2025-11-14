import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import '../../utils/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = _authService.currentUserId;
      if (userId != null) {
        final userData = await _authService.getUserData(userId);
        if (mounted) {
          setState(() {
            _currentUser = userData;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load user data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Bold',
            color: AppColors.textWhite,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _currentUser == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Unable to load profile',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontFamily: 'Medium',
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadUserData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 4),
                              ),
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _currentUser!.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Bold',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentUser!.email,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                                fontFamily: 'Regular',
                              ),
                            ),
                            if (_currentUser!.phoneNumber != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                _currentUser!.phoneNumber!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  fontFamily: 'Regular',
                                ),
                              ),
                            ],
                            if (_currentUser!.isAdmin) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'ADMIN',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontFamily: 'Bold',
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_currentUser!.address != null ||
                          _currentUser!.latitude != null ||
                          _currentUser!.longitude != null)
                        _buildUserDetailsSection(context),
                      _buildSection(
                        context,
                        'Account',
                        [
                          _buildMenuItem(
                            context,
                            Icons.person_outline,
                            'Edit Profile',
                            () async {
                              final result = await Navigator.pushNamed(
                                context,
                                '/edit_profile',
                              );
                              if (result == true) {
                                // Profile was updated, refresh data
                                _loadUserData();
                              }
                            },
                          ),
                          if (_currentUser!.latitude != null &&
                              _currentUser!.longitude != null)
                            _buildMenuItem(
                              context,
                              Icons.location_on_outlined,
                              'My Location',
                              () {
                                Navigator.pushNamed(context, '/map');
                              },
                            ),
                          _buildMenuItem(
                            context,
                            Icons.notifications_outlined,
                            'Notification Settings',
                            () {
                              Navigator.pushNamed(context, '/settings');
                            },
                          ),
                        ],
                      ),
                      _buildSection(
                        context,
                        'Reports',
                        [
                          _buildMenuItem(
                            context,
                            Icons.report_outlined,
                            'My Reports',
                            () {},
                          ),
                          _buildMenuItem(
                            context,
                            Icons.history,
                            'Report History',
                            () {},
                          ),
                        ],
                      ),
                      _buildSection(
                        context,
                        'Support',
                        [
                          _buildMenuItem(
                            context,
                            Icons.help_outline,
                            'Help & FAQ',
                            () {},
                          ),
                          _buildMenuItem(
                            context,
                            Icons.info_outline,
                            'About',
                            () {},
                          ),
                          _buildMenuItem(
                            context,
                            Icons.privacy_tip_outlined,
                            'Privacy Policy',
                            () {},
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () {
                              _showLogoutDialog(context);
                            },
                            style: OutlinedButton.styleFrom(
                              side:
                                  const BorderSide(color: Colors.red, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red,
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

  Widget _buildUserDetailsSection(BuildContext context) {
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
              'User Details',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
                fontFamily: 'Bold',
              ),
            ),
          ),
          if (_currentUser!.address != null)
            _buildDetailItem(
              Icons.location_on,
              'Address',
              _currentUser!.address!,
            ),
          if (_currentUser!.latitude != null && _currentUser!.longitude != null)
            _buildDetailItem(
              Icons.gps_fixed,
              'Coordinates',
              '${_currentUser!.latitude!.toStringAsFixed(6)}, ${_currentUser!.longitude!.toStringAsFixed(6)}',
            ),
          _buildDetailItem(
            Icons.calendar_today,
            'Member Since',
            '${_currentUser!.createdAt.day}/${_currentUser!.createdAt.month}/${_currentUser!.createdAt.year}',
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontFamily: 'Medium',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Regular',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> items) {
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
          ...items,
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey.shade700),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Regular',
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(fontFamily: 'Bold'),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontFamily: 'Regular'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Medium'),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _authService.signOut();
                // AuthWrapper will automatically handle navigation to login screen
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to logout: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontFamily: 'Bold'),
            ),
          ),
        ],
      ),
    );
  }
}
