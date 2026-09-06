import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class FoundItemScreen extends StatefulWidget {
  const FoundItemScreen({super.key});

  @override
  State<FoundItemScreen> createState() => _FoundItemScreenState();
}

class _FoundItemScreenState extends State<FoundItemScreen> {
  static const Color primaryBlue = Color(0xFF2F6BFF);
  static const Color borderGray = Color(0xFFE3E7EF);
  static const Color labelGray = Color(0xFF374151);
  static const Color hintGray = Color(0xFF9CA3AF);

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _selectedImages = [];

  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedCategory;
  String? _selectedLocation;
  DateTime? _selectedDateTime;
  double? _latitude;
  double? _longitude;

  bool _isSubmitting = false;
  bool _isGettingLocation = false;

  final List<String> _categories = const [
    'Wallets', 'Bags & Backpacks', 'Electronics', 'Watches', 'Keys', 'Documents', 'Jewelry', 'Other',
  ];

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

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
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAddPhotosBox(),
                    const SizedBox(height: 18),
                    _buildLabel('Item Name'),
                    _buildTextField(controller: _itemNameController, hint: 'e.g. Smartphone'),
                    const SizedBox(height: 14),
                    _buildLabel('Category'),
                    _buildDropdownField(
                      value: _selectedCategory,
                      hint: 'Select Category',
                      items: _categories,
                      onChanged: (value) => setState(() => _selectedCategory = value),
                    ),
                    const SizedBox(height: 14),
                    _buildLabel('Found Location'),
                    _buildActionField(
                      hint: _selectedLocation ?? 'Select Location on Map',
                      icon: Icons.location_on_outlined,
                      isFilled: _selectedLocation != null,
                      onTap: _selectLocation,
                    ),
                    const SizedBox(height: 14),
                    _buildLabel('Found Date & Time'),
                    _buildActionField(
                      hint: _selectedDateTime == null ? 'Select Date & Time' : _formatDateTime(_selectedDateTime!),
                      icon: Icons.calendar_today_outlined,
                      isFilled: _selectedDateTime != null,
                      onTap: _pickDateTime,
                    ),
                    const SizedBox(height: 14),
                    _buildLabel('Description'),
                    _buildTextField(controller: _descriptionController, hint: 'Add any details...', maxLines: 4),
                    const SizedBox(height: 22),
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

  Widget _buildAppBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 4, 20, 10),
      decoration: const BoxDecoration(color: primaryBlue),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.maybePop(context)),
          const Text('Found Something?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildAddPhotosBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Add Photos', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: labelGray)),
        const SizedBox(height: 6),
        InkWell(
          onTap: _pickImages,
          child: Container(
            width: double.infinity, height: 80,
            decoration: BoxDecoration(color: const Color(0xFFF9FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: borderGray)),
            child: const Center(child: Icon(Icons.add_photo_alternate_outlined, color: primaryBlue)),
          ),
        ),
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Image.file(File(_selectedImages[index].path), width: 60, height: 60, fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(imageQuality: 80);
      if (images.isNotEmpty) setState(() => _selectedImages.addAll(images));
    } catch (_) {}
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 5), child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: labelGray)));

  Widget _buildTextField({required TextEditingController controller, required String hint, int maxLines = 1}) {
    return TextField(
      controller: controller, maxLines: maxLines,
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        hintText: hint, filled: true, fillColor: const Color(0xFFF7F9FC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderGray)),
      ),
    );
  }

  Widget _buildDropdownField({required String? value, required String hint, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: const Color(0xFFF7F9FC), borderRadius: BorderRadius.circular(8), border: Border.all(color: borderGray)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, isExpanded: true, hint: Text(hint, style: const TextStyle(fontSize: 12)),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildActionField({required String hint, required IconData icon, required bool isFilled, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(color: const Color(0xFFF7F9FC), borderRadius: BorderRadius.circular(8), border: Border.all(color: borderGray)),
        child: Row(
          children: [
            Expanded(child: Text(hint, style: TextStyle(fontSize: 12, color: isFilled ? Colors.black : hintGray))),
            if (_isGettingLocation) const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)) else Icon(icon, size: 18, color: hintGray),
          ],
        ),
      ),
    );
  }

  Future<void> _selectLocation() async {
    if (_isGettingLocation) return;
    setState(() => _isGettingLocation = true);
    try {
      Position pos = await Geolocator.getCurrentPosition();
      _latitude = pos.latitude; _longitude = pos.longitude;
      String name = 'Current Location';
      try {
        List<geo.Placemark> marks = await geo.placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (marks.isNotEmpty) name = '${marks.first.locality}, ${marks.first.country}';
      } catch (_) {}
      setState(() { _selectedLocation = name; _isGettingLocation = false; });
    } catch (_) { setState(() => _isGettingLocation = false); }
  }

  Future<void> _pickDateTime() async {
    DateTime? d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now());
    if (d == null) return;
    TimeOfDay? t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t == null) return;
    setState(() => _selectedDateTime = DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  String _formatDateTime(DateTime dt) => '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute}';

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity, height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
        onPressed: _isSubmitting ? null : _submit,
        child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Found Item', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Future<void> _submit() async {
    if (_itemNameController.text.isEmpty || _selectedCategory == null || _selectedLocation == null || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    final User? user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isSubmitting = true);
    try {
      final DatabaseReference ref = _dbRef.child('found_items').push();
      final String id = ref.key!;
      final List<String> urls = [];
      for (int i = 0; i < _selectedImages.length; i++) {
        final Reference s = _storage.ref().child('found_items').child(user.uid).child(id).child('img_$i.jpg');
        await s.putFile(File(_selectedImages[i].path));
        urls.add(await s.getDownloadURL());
      }
      await ref.set({
        'id': id, 'userId': user.uid, 'itemName': _itemNameController.text, 'category': _selectedCategory,
        'description': _descriptionController.text, 'location': _selectedLocation, 'latitude': _latitude, 'longitude': _longitude,
        'dateTime': _selectedDateTime!.millisecondsSinceEpoch, 'imageUrls': urls, 'status': 'found', 'createdAt': ServerValue.timestamp,
      });
      if (mounted) {
        setState(() => _isSubmitting = false);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) { setState(() => _isSubmitting = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
    }
  }
}
