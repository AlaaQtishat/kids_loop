import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kids_loop/managers/theme_manager.dart';
import 'package:kids_loop/services/cloudinary_service.dart';
import 'package:kids_loop/utilities/listing_options.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();

  bool _isLoading = false;

  String? _selectedCategory;
  String? _selectedCondition;
  String? _selectedAgeGroup;
  String? _selectedGender;
  String? _selectedLocation;

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage(
      imageQuality: 70,
      maxWidth: 1080,
      maxHeight: 1080,
    );

    if (images.isNotEmpty) {
      int availableSlots = 3 - _selectedImages.length;

      if (images.length > availableSlots && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "You can only select up to 3 images. Extra images were ignored.",
            ),
          ),
        );
      }

      setState(() {
        for (var img in images) {
          if (_selectedImages.length < 3) {
            _selectedImages.add(File(img.path));
          }
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sell an Item",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: ThemeManager.primaryTeal,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Photos (Up to 3)"),

              _selectedImages.isEmpty
                  ? GestureDetector(
                      onTap: _pickImages,
                      child: _buildImagePickerBox(
                        height: 180,
                        width: double.infinity,
                      ),
                    )
                  : _buildImagePreviewList(),

              const SizedBox(height: 24),

              _buildSectionTitle("Title"),
              _buildTextField(
                controller: _titleController,
                hint: "What are you selling? (e.g. Zara Jacket)",
                icon: Icons.title,
              ),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Price (JD)"),
                        _buildTextField(
                          controller: _priceController,
                          hint: "0.00",
                          icon: Icons.attach_money,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Category"),
                        _buildDropdown(
                          hint: "Select",
                          value: _selectedCategory,
                          items: ListingOptions.categories,
                          onChanged: (val) =>
                              setState(() => _selectedCategory = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Condition"),
                        _buildDropdown(
                          hint: "Select",
                          value: _selectedCondition,
                          items: ListingOptions.conditions,
                          onChanged: (val) =>
                              setState(() => _selectedCondition = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Age Group"),
                        _buildDropdown(
                          hint: "Select",
                          value: _selectedAgeGroup,
                          items: ListingOptions.ageGroups,
                          onChanged: (val) =>
                              setState(() => _selectedAgeGroup = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Gender"),
                        _buildDropdown(
                          hint: "Select",
                          value: _selectedGender,
                          items: ListingOptions.genders,
                          onChanged: (val) =>
                              setState(() => _selectedGender = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Location"),
                        _buildDropdown(
                          hint: "Select",
                          value: _selectedLocation,
                          items: ListingOptions.locations,
                          onChanged: (val) =>
                              setState(() => _selectedLocation = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              _buildSectionTitle("Description"),
              _buildTextField(
                controller: _descController,
                hint: "Describe your item...",
                icon: Icons.description_outlined,
                maxLines: 4,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_selectedImages.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please add at least one photo"),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });

                            try {
                              final currentUser =
                                  FirebaseAuth.instance.currentUser;
                              final currentUid = currentUser?.uid;

                              String sellerName = "KidsLoop User";

                              if (currentUid != null) {
                                final userDoc = await FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(currentUid)
                                    .get();
                                if (userDoc.exists) {
                                  sellerName =
                                      userDoc.data()?['full_name'] ??
                                      "KidsLoop User";
                                }
                              }

                              List<String> uploadedImageUrls = [];
                              for (var imageFile in _selectedImages) {
                                final imgUrl =
                                    await CloudinaryService.uploadToCloudinary(
                                      imageFile,
                                    );
                                if (imgUrl != null) {
                                  uploadedImageUrls.add(imgUrl);
                                }
                              }

                              await FirebaseFirestore.instance
                                  .collection("products")
                                  .doc()
                                  .set({
                                    "title": _titleController.text.trim(),
                                    "price":
                                        double.tryParse(
                                          _priceController.text.trim(),
                                        ) ??
                                        0.0,
                                    "category": _selectedCategory,
                                    "condition": _selectedCondition,
                                    "ageGroup": _selectedAgeGroup,
                                    "gender": _selectedGender,
                                    "description": _descController.text.trim(),
                                    "location": _selectedLocation,
                                    "images": uploadedImageUrls,
                                    "userUid": currentUid,
                                    "sellerName": sellerName,
                                    "createdAt": DateTime.now()
                                        .toIso8601String(),
                                    "status": "available",
                                    "likes": 0,
                                  });

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      "Item posted successfully! ",
                                    ),
                                    backgroundColor: Colors.grey[900],
                                  ),
                                );

                                _titleController.clear();
                                _priceController.clear();
                                _descController.clear();

                                setState(() {
                                  _selectedCategory = null;
                                  _selectedCondition = null;
                                  _selectedAgeGroup = null;
                                  _selectedGender = null;
                                  _selectedImages.clear();
                                  _selectedLocation = null;
                                });
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Error: $e"),
                                    backgroundColor: ThemeManager.errorRed,
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
                        },
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Post Item",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 10.0),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) => value == null || value.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: maxLines == 1 ? Icon(icon) : null,
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: value,
      dropdownColor: theme.cardColor,
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? "Required" : null,
      decoration: InputDecoration(hintText: hint),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: theme.iconTheme.color,
      ),
    );
  }

  Widget _buildImagePickerBox({required double height, required double width}) {
    final theme = Theme.of(context);

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.transparent
              : const Color(0xFFEEEEEE),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo_rounded,
            size: height > 150 ? 50 : 35,
            color: ThemeManager.primaryTeal.withOpacity(0.7),
          ),
          if (height > 150) ...[
            const SizedBox(height: 10),
            Text(
              "Tap to upload photos",
              style: TextStyle(color: theme.hintColor),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagePreviewList() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length < 3 ? _selectedImages.length + 1 : 3,
        itemBuilder: (context, index) {
          if (index == _selectedImages.length) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: _pickImages,

                child: _buildImagePickerBox(height: 120, width: 120),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    _selectedImages[index],
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
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
    );
  }
}
