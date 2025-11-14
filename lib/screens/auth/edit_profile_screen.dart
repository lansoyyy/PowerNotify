import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import '../../widgets/custom_button.dart';
import '../../utils/colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isLoadingLocation = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;

  User? _currentUser;
  bool _locationEnabled = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadUserData();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = _authService.currentUserId;
      if (userId != null) {
        final userData = await _authService.getUserData(userId);
        if (mounted && userData != null) {
          setState(() {
            _currentUser = userData;
            _populateControllers(userData);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _populateControllers(User user) {
    _nameController.text = user.name;
    _emailController.text = user.email;
    _phoneController.text = user.phoneNumber ?? '';
    _addressController.text = user.address ?? '';
    _latitudeController.text = user.latitude?.toString() ?? '';
    _longitudeController.text = user.longitude?.toString() ?? '';
    _locationEnabled = user.latitude != null && user.longitude != null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception(
            'Location services are disabled. Please enable them in settings.');
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = _formatAddress(place);

        setState(() {
          _latitudeController.text = position.latitude.toStringAsFixed(6);
          _longitudeController.text = position.longitude.toStringAsFixed(6);
          _addressController.text = address;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatAddress(Placemark place) {
    String address = '';

    if (place.street?.isNotEmpty == true) address += place.street!;
    if (place.subLocality?.isNotEmpty == true) {
      if (address.isNotEmpty) address += ', ';
      address += place.subLocality!;
    }
    if (place.locality?.isNotEmpty == true) {
      if (address.isNotEmpty) address += ', ';
      address += place.locality!;
    }
    if (place.administrativeArea?.isNotEmpty == true) {
      if (address.isNotEmpty) address += ', ';
      address += place.administrativeArea!;
    }
    if (place.postalCode?.isNotEmpty == true) {
      if (address.isNotEmpty) address += ', ';
      address += place.postalCode!;
    }

    return address;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _authService.currentUserId;
      if (userId != null) {
        final result = await _authService.updateUserProfile(
          userId: userId,
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          latitude: _locationEnabled && _latitudeController.text.isNotEmpty
              ? double.tryParse(_latitudeController.text)
              : null,
          longitude: _locationEnabled && _longitudeController.text.isNotEmpty
              ? double.tryParse(_longitudeController.text)
              : null,
        );

        if (mounted) {
          if (result['success']) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(
                context, true); // Return true to indicate profile was updated
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message']),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontFamily: 'Bold',
            color: AppColors.textWhite,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.textWhite),
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontFamily: 'Bold',
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: _currentUser == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture Section
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: AppColors.primary, width: 3),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Name Field
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),

                    // Email Field (Read-only)
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                      enabled: false,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),

                    // Phone Field
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          if (!RegExp(r'^[\d\s\-\+\(\)]+$').hasMatch(value)) {
                            return 'Please enter a valid phone number';
                          }
                        }
                        return null;
                      },
                    ),

                    // Address Section
                    const SizedBox(height: 24),
                    Text(
                      'Location Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontFamily: 'Bold',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Address Field
                    _buildTextField(
                      controller: _addressController,
                      label: 'Address',
                      icon: Icons.location_on,
                      maxLines: 2,
                    ),

                    // Location Toggle
                    Row(
                      children: [
                        Switch(
                          value: _locationEnabled,
                          onChanged: (value) {
                            setState(() {
                              _locationEnabled = value;
                              if (!value) {
                                _latitudeController.clear();
                                _longitudeController.clear();
                              }
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Enable GPS Coordinates',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Medium',
                          ),
                        ),
                      ],
                    ),

                    if (_locationEnabled) ...[
                      const SizedBox(height: 16),

                      // Get Current Location Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed:
                              _isLoadingLocation ? null : _getCurrentLocation,
                          icon: _isLoadingLocation
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.gps_fixed),
                          label: Text(_isLoadingLocation
                              ? 'Getting Location...'
                              : 'Use Current Location'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Latitude and Longitude Fields
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _latitudeController,
                              label: 'Latitude',
                              icon: Icons.gps_fixed,
                              keyboardType: TextInputType.number,
                              enabled: _locationEnabled,
                              validator: _locationEnabled
                                  ? (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Required';
                                      }
                                      final lat = double.tryParse(value);
                                      if (lat == null ||
                                          lat < -90 ||
                                          lat > 90) {
                                        return 'Invalid latitude';
                                      }
                                      return null;
                                    }
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _longitudeController,
                              label: 'Longitude',
                              icon: Icons.gps_fixed,
                              keyboardType: TextInputType.number,
                              enabled: _locationEnabled,
                              validator: _locationEnabled
                                  ? (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Required';
                                      }
                                      final lng = double.tryParse(value);
                                      if (lng == null ||
                                          lng < -180 ||
                                          lng > 180) {
                                        return 'Invalid longitude';
                                      }
                                      return null;
                                    }
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Save Button
                    CustomButton(
                      text: 'Save Changes',
                      onPressed: _isLoading ? null : _saveProfile,
                      isLoading: _isLoading,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'Regular',
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey.shade100,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
