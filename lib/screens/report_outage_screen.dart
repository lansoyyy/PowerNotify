import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../utils/colors.dart';
import '../widgets/custom_button.dart';
import '../services/report_service.dart';
import '../services/location_search_service.dart';
import '../services/auth_service.dart';
import '../models/user_report.dart';

class ReportOutageScreen extends StatefulWidget {
  const ReportOutageScreen({super.key});

  @override
  State<ReportOutageScreen> createState() => _ReportOutageScreenState();
}

class _ReportOutageScreenState extends State<ReportOutageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();
  final MapController _mapController = MapController();

  LatLng? _selectedLocation;
  String? _currentLocationAddress;
  bool _isLoading = false;
  bool _isGettingLocation = false;
  List<File> _selectedImages = [];
  List<LocationSuggestion> _searchResults = [];
  bool _showSearchResults = false;
  String _selectedOutageType = 'Complete Power Outage';
  bool _isEmergency = false;
  String _contactNumber = '';
  String _additionalInfo = '';

  final List<String> _outageTypes = [
    'Complete Power Outage',
    'Partial Power Outage',
    'Flickering Lights',
    'Low Voltage',
    'Power Surge',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      User? currentUser = AuthService().currentUser;
      if (currentUser != null) {
        // Load user profile data including contact number
        // This would typically come from your user service
        setState(() {
          _contactNumber = currentUser.phoneNumber ?? '';
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServicesDialog();
        setState(() => _isGettingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationPermissionDialog();
          setState(() => _isGettingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationPermissionDialog();
        setState(() => _isGettingLocation = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _isGettingLocation = false;
      });

      _mapController.move(_selectedLocation!, 15);
      _getAddressFromCoordinates(_selectedLocation!);
    } catch (e) {
      setState(() => _isGettingLocation = false);
      _showErrorSnackBar('Error getting location: $e');
    }
  }

  void _showLocationServicesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Services Disabled'),
        content:
            const Text('Please enable location services to use this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
            'Please grant location permission to report an outage at your current location.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _getCurrentLocation();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _getAddressFromCoordinates(LatLng coordinates) async {
    try {
      String? address =
          await LocationSearchService.getCurrentLocationAddress(coordinates);
      setState(() {
        _currentLocationAddress = address ?? 'Unknown Location';
      });
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _showSearchResults = false;
      });
      return;
    }

    try {
      List<LocationSuggestion> results =
          await LocationSearchService.searchPlaces(query);
      setState(() {
        _searchResults = results;
        _showSearchResults = true;
      });
    } catch (e) {
      print('Error searching location: $e');
    }
  }

  void _selectLocation(LocationSuggestion suggestion) {
    LatLng location = LatLng(suggestion.latitude, suggestion.longitude);
    setState(() {
      _selectedLocation = location;
      _currentLocationAddress = suggestion.description;
      _searchController.text = suggestion.description;
      _showSearchResults = false;
      _searchResults.clear();
    });
    _mapController.move(location, 15);
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    _getAddressFromCoordinates(location);
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images.map((image) => File(image.path)));
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking images: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);

      if (photo != null) {
        setState(() {
          _selectedImages.add(File(photo.path));
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error taking photo: $e');
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate() && _selectedLocation != null) {
      setState(() => _isLoading = true);

      try {
        User? currentUser = AuthService().currentUser;
        if (currentUser == null) {
          throw Exception('User not authenticated');
        }

        // Upload images and get URLs
        List<String> imagePaths =
            _selectedImages.map((file) => file.path).toList();

        Map<String, dynamic> result = await ReportService().submitUserReport(
          userId: currentUser.uid,
          latitude: _selectedLocation!.latitude,
          longitude: _selectedLocation!.longitude,
          description: _descriptionController.text,
          address: _currentLocationAddress ?? 'Unknown Location',
          imagePaths: imagePaths,
        );

        if (!result['success']) {
          throw Exception(result['message']);
        }

        if (mounted) {
          setState(() => _isLoading = false);

          // Show success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.check_circle,
                      color: Colors.green.shade600, size: 32),
                  const SizedBox(width: 12),
                  const Text(
                    'Report Submitted!',
                    style: TextStyle(fontFamily: 'Bold'),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your outage report has been successfully submitted.',
                    style: TextStyle(fontFamily: 'Regular'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Report ID: ${result['reportId']}',
                    style: const TextStyle(
                      fontFamily: 'Medium',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We will notify you once the status is updated.',
                    style: TextStyle(fontFamily: 'Regular'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to previous screen
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(fontFamily: 'Bold'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    _resetForm(); // Reset form for new report
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Report Another',
                    style: TextStyle(fontFamily: 'Bold'),
                  ),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Error submitting report: $e');
      }
    } else if (_selectedLocation == null) {
      _showErrorSnackBar('Please select a location on the map');
    }
  }

  void _resetForm() {
    setState(() {
      _descriptionController.clear();
      _selectedImages.clear();
      _selectedLocation = null;
      _currentLocationAddress = null;
      _selectedOutageType = 'Complete Power Outage';
      _isEmergency = false;
      _additionalInfo = '';
    });
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Report Outage',
          style: TextStyle(
            fontFamily: 'Bold',
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/report-history');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emergency Alert
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Report power outages quickly to help us respond faster.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontFamily: 'Regular',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Outage Type Selection
              const Text(
                'Outage Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Bold',
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedOutageType,
                    isExpanded: true,
                    items: _outageTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedOutageType = newValue!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Location Section
              const Text(
                'Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Bold',
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    // Search bar
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search for a location...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _isGettingLocation
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.my_location),
                                  onPressed: _getCurrentLocation,
                                ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              if (_searchController.text == value) {
                                _searchLocation(value);
                              }
                            });
                          } else {
                            setState(() {
                              _showSearchResults = false;
                              _searchResults.clear();
                            });
                          }
                        },
                      ),
                    ),

                    // Search results
                    if (_showSearchResults && _searchResults.isNotEmpty)
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                              top: BorderSide(color: Colors.grey.shade300)),
                        ),
                        child: ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final suggestion = _searchResults[index];
                            return ListTile(
                              leading: const Icon(Icons.location_on),
                              title: Text(suggestion.description),
                              onTap: () => _selectLocation(suggestion),
                            );
                          },
                        ),
                      ),

                    // Map
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(color: Colors.grey.shade300)),
                      ),
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _selectedLocation ??
                              const LatLng(14.5995, 120.9842),
                          initialZoom: 15,
                          onTap: (tapPosition, point) => _onMapTap(point),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.powernotify',
                          ),
                          if (_selectedLocation != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _selectedLocation!,
                                  width: 40,
                                  height: 40,
                                  child: GestureDetector(
                                    onTap: () {
                                      // Show location details
                                    },
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Current Location Address
              if (_currentLocationAddress != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _currentLocationAddress!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Medium',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Emergency Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _isEmergency,
                    onChanged: (value) {
                      setState(() {
                        _isEmergency = value!;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  const Text(
                    'This is an emergency',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Medium',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Description
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Bold',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Describe the power outage situation...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a description';
                  }
                  if (value.length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Additional Information
              const Text(
                'Additional Information (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Bold',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _additionalInfo,
                onChanged: (value) {
                  _additionalInfo = value;
                },
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Any additional details that might help...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 24),

              // Contact Number
              const Text(
                'Contact Number',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Bold',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _contactNumber,
                onChanged: (value) {
                  _contactNumber = value;
                },
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Your contact number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: const Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a contact number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Photos Section
              const Text(
                'Photos (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Bold',
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _showImagePickerOptions,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to add photos',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontFamily: 'Regular',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_selectedImages.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(_selectedImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // Submit Button
              CustomButton(
                text: 'Submit Report',
                onPressed: _isLoading ? null : _submitReport,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),

              // Emergency Hotline
              if (_isEmergency)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Emergency Hotline',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Bold',
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.phone, color: Colors.red),
                          const SizedBox(width: 8),
                          const Text(
                            '162',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Bold',
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'For life-threatening emergencies',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontFamily: 'Regular',
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
