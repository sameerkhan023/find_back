import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class ReportLostItemScreen extends StatefulWidget {
  const ReportLostItemScreen({super.key});
  @override
  State<ReportLostItemScreen> createState() =>
      _ReportLostItemScreenState();
}

class _ReportLostItemScreenState
    extends State<ReportLostItemScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryBlue = Color(0xFF2F6BFF);
  static const Color borderGray = Color(0xFFE3E7EF);
  static const Color labelGray = Color(0xFF374151);
  static const Color hintGray = Color(0xFF9CA3AF);

  // ============================================================
  // FIREBASE
  // ============================================================

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseStorage _storage =
      FirebaseStorage.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ============================================================
  // IMAGE PICKER
  // ============================================================

  final ImagePicker _imagePicker = ImagePicker();

  final List<XFile> _selectedImages = [];

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _itemNameController =
  TextEditingController();

  final TextEditingController _descriptionController =
  TextEditingController();

  // ============================================================
  // VARIABLES
  // ============================================================

  String? _selectedCategory;
  String? _selectedLocation;

  DateTime? _selectedDateTime;

  double? _latitude;
  double? _longitude;

  bool _isSubmitting = false;
  bool _isGettingLocation = false;

  // ============================================================
  // CATEGORIES
  // ============================================================

  final List<String> _categories = const [
    'Wallets',
    'Bags & Backpacks',
    'Electronics',
    'Watches',
    'Keys',
    'Documents',
    'Jewelry',
    'Other',
  ];

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  30,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    // =================================================
                    // ADD PHOTOS
                    // =================================================

                    _buildAddPhotosBox(),

                    const SizedBox(height: 22),

                    // =================================================
                    // ITEM NAME
                    // =================================================

                    _buildLabel('Item Name'),

                    _buildTextField(
                      controller: _itemNameController,
                      hint: 'e.g. Black Wallet',
                    ),

                    const SizedBox(height: 18),

                    // =================================================
                    // CATEGORY
                    // =================================================

                    _buildLabel('Category'),

                    _buildDropdownField(
                      value: _selectedCategory,
                      hint: 'Select Category',
                      items: _categories,
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),

                    const SizedBox(height: 18),

                    // =================================================
                    // LOCATION
                    // =================================================

                    _buildLabel('Lost Location'),

                    _buildActionField(
                      hint: _selectedLocation ??
                          'Select Location on Map',
                      icon: Icons.location_on_outlined,
                      isFilled:
                      _selectedLocation != null,
                      onTap: _selectLocation,
                    ),

                    const SizedBox(height: 18),

                    // =================================================
                    // DATE & TIME
                    // =================================================

                    _buildLabel('Lost Date & Time'),

                    _buildActionField(
                      hint: _selectedDateTime == null
                          ? 'Select Date & Time'
                          : _formatDateTime(
                        _selectedDateTime!,
                      ),
                      icon: Icons.calendar_today_outlined,
                      isFilled:
                      _selectedDateTime != null,
                      onTap: _pickDateTime,
                    ),

                    const SizedBox(height: 18),

                    // =================================================
                    // DESCRIPTION
                    // =================================================

                    _buildLabel('Description'),

                    _buildTextField(
                      controller:
                      _descriptionController,
                      hint:
                      'Add any details about the item...',
                      maxLines: 4,
                    ),

                    const SizedBox(height: 28),

                    // =================================================
                    // SUBMIT
                    // =================================================

                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        8,
        8,
        20,
        8,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black87,
            ),
            onPressed: _isSubmitting
                ? null
                : () {
              Navigator.maybePop(context);
            },
          ),

          const Text(
            'Report Lost Item',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ADD PHOTOS
  // ============================================================

  Widget _buildAddPhotosBox() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _pickImages,
          child: Container(
            width: double.infinity,
            height: 110,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius:
              BorderRadius.circular(14),
              border: Border.all(
                color: borderGray,
                width: 1.2,
              ),
            ),
            child: const Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  color: primaryBlue,
                  size: 26,
                ),

                SizedBox(height: 8),

                Text(
                  '+ Add Photos',
                  style: TextStyle(
                    color: primaryBlue,
                    fontWeight:
                    FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),

        // =========================================================
        // SELECTED PHOTOS
        // =========================================================

        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 12),

          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:
              _selectedImages.length,
              itemBuilder: (context, index) {
                return _buildSelectedImage(
                  index,
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectedImage(int index) {
    return Container(
      width: 90,
      height: 90,
      margin: const EdgeInsets.only(
        right: 10,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius:
            BorderRadius.circular(10),
            child: Image.file(
              File(
                _selectedImages[index].path,
              ),
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedImages.removeAt(index);
                });
              },
              child: Container(
                height: 24,
                width: 24,
                decoration:
                const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PICK IMAGES
  // ============================================================

  Future<void> _pickImages() async {
    try {
      final List<XFile> images =
      await _imagePicker.pickMultiImage(
        imageQuality: 80,
      );

      if (images.isEmpty) {
        return;
      }

      setState(() {
        _selectedImages.addAll(images);
      });
    } catch (e) {
      _showMessage(
        'Unable to select photos.',
      );
    }
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(String text) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: labelGray,
        ),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: hintGray,
          fontSize: 14,
        ),
        filled: true,
        fillColor:
        const Color(0xFFF7F9FC),
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: borderGray,
          ),
        ),
        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: borderGray,
          ),
        ),
        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: primaryBlue,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget _buildDropdownField({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:
        const Color(0xFFF7F9FC),
        borderRadius:
        BorderRadius.circular(10),
        border: Border.all(
          color: borderGray,
        ),
      ),
      padding:
      const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: hintGray,
          ),
          hint: Text(
            hint,
            style: const TextStyle(
              color: hintGray,
              fontSize: 14,
            ),
          ),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
          items: items.map(
                (item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            },
          ).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ============================================================
  // ACTION FIELD
  // ============================================================

  Widget _buildActionField({
    required String hint,
    required IconData icon,
    required bool isFilled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius:
      BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color:
          const Color(0xFFF7F9FC),
          borderRadius:
          BorderRadius.circular(10),
          border: Border.all(
            color: borderGray,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hint,
                style: TextStyle(
                  fontSize: 14,
                  color: isFilled
                      ? Colors.black87
                      : hintGray,
                ),
              ),
            ),

            if (_isGettingLocation)
              const SizedBox(
                height: 20,
                width: 20,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                  color: primaryBlue,
                ),
              )
            else
              Icon(
                icon,
                color: hintGray,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOCATION
  // ============================================================

  Future<void> _selectLocation() async {
    if (_isGettingLocation) {
      return;
    }

    setState(() {
      _isGettingLocation = true;
    });

    try {
      bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          _isGettingLocation = false;
        });

        _showMessage(
          'Please turn on location services.',
        );

        await Geolocator.openLocationSettings();

        return;
      }

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission ==
          LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();
      }

      if (permission ==
          LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {
        setState(() {
          _isGettingLocation = false;
        });

        _showMessage(
          'Location permission is required.',
        );

        return;
      }

      final Position position =
      await Geolocator.getCurrentPosition(
        locationSettings:
        const LocationSettings(
          accuracy:
          LocationAccuracy.high,
        ),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      String locationName =
          'Current Location';

      try {
        final List<geo.Placemark> placemarks =
        await geo.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final geo.Placemark place =
              placemarks.first;

          final List<String> parts = [
            if (place.name != null &&
                place.name!.isNotEmpty)
              place.name!,
            if (place.locality != null &&
                place.locality!.isNotEmpty)
              place.locality!,
            if (place.country != null &&
                place.country!.isNotEmpty)
              place.country!,
          ];

          if (parts.isNotEmpty) {
            locationName =
                parts.join(', ');
          }
        }
      } catch (_) {
        // GPS coordinates still remain valid
      }

      setState(() {
        _selectedLocation =
            locationName;
        _isGettingLocation = false;
      });

      _showMessage(
        'Location selected successfully.',
      );
    } catch (e) {
      setState(() {
        _isGettingLocation = false;
      });

      _showMessage(
        'Unable to get your location.',
      );
    }
  }

  // ============================================================
  // DATE & TIME PICKER
  // ============================================================

  Future<void> _pickDateTime() async {
    final DateTime? date =
    await showDatePicker(
      context: context,
      initialDate:
      _selectedDateTime ??
          DateTime.now(),
      firstDate:
      DateTime(2020),
      lastDate:
      DateTime.now(),
    );

    if (date == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    final TimeOfDay? time =
    await showTimePicker(
      context: context,
      initialTime:
      _selectedDateTime != null
          ? TimeOfDay.fromDateTime(
        _selectedDateTime!,
      )
          : TimeOfDay.now(),
    );

    if (time == null) {
      return;
    }

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  // ============================================================
  // FORMAT DATE & TIME
  // ============================================================

  String _formatDateTime(
      DateTime dt) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final int hour =
    dt.hour % 12 == 0
        ? 12
        : dt.hour % 12;

    final String period =
    dt.hour >= 12
        ? 'PM'
        : 'AM';

    final String minute =
    dt.minute
        .toString()
        .padLeft(2, '0');

    return '${months[dt.month - 1]} '
        '${dt.day}, '
        '${dt.year} • '
        '$hour:$minute $period';
  }

  // ============================================================
  // SUBMIT BUTTON
  // ============================================================

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style:
        ElevatedButton.styleFrom(
          backgroundColor:
          primaryBlue,
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed:
        _isSubmitting
            ? null
            : _submitReport,
        child: _isSubmitting
            ? const SizedBox(
          height: 23,
          width: 23,
          child:
          CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : const Text(
          'Submit Report',
          style: TextStyle(
            fontSize: 15,
            fontWeight:
            FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUBMIT REPORT
  // ============================================================

  Future<void> _submitReport() async {
    // =========================================================
    // VALIDATION
    // =========================================================

    final String itemName =
    _itemNameController.text.trim();

    final String description =
    _descriptionController.text.trim();

    if (itemName.isEmpty) {
      _showMessage(
        'Please enter the item name.',
      );
      return;
    }

    if (_selectedCategory == null) {
      _showMessage(
        'Please select a category.',
      );
      return;
    }

    if (_selectedLocation == null) {
      _showMessage(
        'Please select the lost location.',
      );
      return;
    }

    if (_selectedDateTime == null) {
      _showMessage(
        'Please select the lost date and time.',
      );
      return;
    }

    if (description.isEmpty) {
      _showMessage(
        'Please add a description.',
      );
      return;
    }

    // =========================================================
    // CHECK USER
    // =========================================================

    final User? user =
        _auth.currentUser;

    if (user == null) {
      _showMessage(
        'Please login before submitting a report.',
      );
      return;
    }

    // =========================================================
    // START SUBMISSION
    // =========================================================

    setState(() {
      _isSubmitting = true;
    });

    try {
      // =======================================================
      // CREATE REPORT DOCUMENT ID
      // =======================================================

      final DocumentReference<Map<String, dynamic>>
      reportReference =
      _firestore
          .collection('lost_items')
          .doc();

      final String reportId =
          reportReference.id;

      // =======================================================
      // UPLOAD IMAGES
      // =======================================================

      final List<String> imageUrls = [];

      for (int i = 0;
      i < _selectedImages.length;
      i++) {
        final XFile image =
        _selectedImages[i];

        final Reference storageReference =
        _storage
            .ref()
            .child('lost_items')
            .child(user.uid)
            .child(reportId)
            .child(
          'image_$i.jpg',
        );

        final UploadTask uploadTask =
        storageReference.putFile(
          File(image.path),
          SettableMetadata(
            contentType: 'image/jpeg',
          ),
        );

        await uploadTask;

        final String downloadUrl =
        await storageReference
            .getDownloadURL();

        imageUrls.add(downloadUrl);
      }

      // =======================================================
      // SAVE REPORT IN FIRESTORE
      // =======================================================

      await reportReference.set({
        'reportId': reportId,

        'userId': user.uid,

        'userName':
        user.displayName ?? '',

        'userEmail':
        user.email ?? '',

        'itemName': itemName,

        'category':
        _selectedCategory,

        'description': description,

        'location':
        _selectedLocation,

        'latitude':
        _latitude,

        'longitude':
        _longitude,

        'lostDateTime':
        Timestamp.fromDate(
          _selectedDateTime!,
        ),

        'imageUrls':
        imageUrls,

        'status': 'lost',

        'createdAt':
        FieldValue.serverTimestamp(),

        'updatedAt':
        FieldValue.serverTimestamp(),
      });

      // =======================================================
      // SUCCESS
      // =======================================================

      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Report Submitted',
            ),
            content: const Text(
              'Your lost item report has been submitted successfully.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'OK',
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) {
        return;
      }

      // Return to previous screen
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });

      _showMessage(
        'Firebase error: ${e.message ?? e.code}',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });

      _showMessage(
        'Failed to submit report. Please try again.',
      );

      debugPrint(
        'Submit report error: $e',
      );
    }
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(
      String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
        SnackBarBehavior.floating,
      ),
    );
  }
}