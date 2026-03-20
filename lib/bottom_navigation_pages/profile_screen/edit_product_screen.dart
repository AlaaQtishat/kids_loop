import 'package:cloud_firestore/cloud_firestore.dart';
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
          const SnackBar(
            content: Text("Listing updated successfully!"),
            backgroundColor: ThemeManager.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error updating: $e"),
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
        title: const Text(
          "Edit Listing",
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
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Price (JOD)",
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val!.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown(
                      label: "Location",
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
                      label: "Category",
                      value: _selectedCategory,
                      items: ListingOptions.categories,
                      onChanged: (val) =>
                          setState(() => _selectedCategory = val as String),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown(
                      label: "Condition",
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
                      label: "Age Group",
                      value: _selectedAgeGroup,
                      items: ListingOptions.ageGroups,
                      onChanged: (val) =>
                          setState(() => _selectedAgeGroup = val as String),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown(
                      label: "Gender",
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
                decoration: const InputDecoration(
                  labelText: "Description",
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
                      : const Text(
                          "Save Changes",
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
            item,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? "Required" : null,
    );
  }
}
