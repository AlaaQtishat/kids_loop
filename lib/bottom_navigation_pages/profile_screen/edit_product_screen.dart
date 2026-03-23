import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kids_loop/managers/theme_manager.dart';
import 'package:kids_loop/utilities/listing_options.dart';

class EditProductScreen extends StatefulWidget {
  final QueryDocumentSnapshot productDoc;

  const EditProductScreen({super.key, required this.productDoc});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descController;

  String? _selectedCategory;
  String? _selectedCondition;
  String? _selectedAgeGroup;
  String? _selectedGender;
  String? _selectedLocation;

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    final data = widget.productDoc.data() as Map<String, dynamic>;

    _titleController = TextEditingController(text: data['title']);
    _priceController = TextEditingController(text: data['price'].toString());
    _descController = TextEditingController(text: data['description']);

    _selectedCategory = data['category'];
    _selectedCondition = data['condition'];
    _selectedAgeGroup = data['ageGroup'];
    _selectedGender = data['gender'];
    _selectedLocation = data['location'];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descController.dispose();

    super.dispose();
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUpdating = true);

    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productDoc.id)
          .update({
            'title': _titleController.text.trim(),
            'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
            'description': _descController.text.trim(),
            'category': _selectedCategory,
            'condition': _selectedCondition,
            'ageGroup': _selectedAgeGroup,
            'gender': _selectedGender,
            'location': _selectedLocation,
          });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("edit_product_screen.success_message".tr()),
            backgroundColor: ThemeManager.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${'edit_product_screen.error_prefix'.tr()}$e"),
            backgroundColor: ThemeManager.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "edit_product_screen.title".tr(),
          style: TextStyle(color: ThemeManager.primaryTeal),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "edit_product_screen.title_label".tr(),
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val!.isEmpty ? "edit_product_screen.required".tr() : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "edit_product_screen.price_label".tr(),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (val) => val!.isEmpty
                          ? "edit_product_screen.required".tr()
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown(
                      label: "edit_product_screen.location_label".tr(),
                      value: _selectedLocation,
                      items: ListingOptions.locations,
                      onChanged: (val) =>
                          setState(() => _selectedLocation = val as String),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: "edit_product_screen.category_label".tr(),
                      value: _selectedCategory,
                      items: ListingOptions.categories,
                      onChanged: (val) =>
                          setState(() => _selectedCategory = val as String),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown(
                      label: "edit_product_screen.condition_label".tr(),
                      value: _selectedCondition,
                      items: ListingOptions.conditions,
                      onChanged: (val) =>
                          setState(() => _selectedCondition = val as String),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: "edit_product_screen.age_group_label".tr(),
                      value: _selectedAgeGroup,
                      items: ListingOptions.ageGroups,
                      onChanged: (val) =>
                          setState(() => _selectedAgeGroup = val as String),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown(
                      label: "edit_product_screen.gender_label".tr(),
                      value: _selectedGender,
                      items: ListingOptions.genders,
                      onChanged: (val) =>
                          setState(() => _selectedGender = val as String),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "edit_product_screen.description_label".tr(),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeManager.primaryTeal,
                  ),
                  onPressed: _isUpdating ? null : _updateProduct,
                  child: _isUpdating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "edit_product_screen.save_changes".tr(),
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(dynamic)? onChanged,
  }) {
    return DropdownButtonFormField(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            "listing_options.$item".tr(),
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (val) =>
          val == null ? "edit_product_screen.required".tr() : null,
    );
  }
}
