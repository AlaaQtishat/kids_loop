import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kids_loop/managers/theme_manager.dart';

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
  late TextEditingController _locController;

  String? _selectedCategory;
  String? _selectedCondition;
  String? _selectedAgeGroup;
  String? _selectedGender;

  final List<String> _categories = ["Clothes", "Shoes", "Toys", "Gear"];
  final List<String> _conditions = [
    "New with Tag",
    "Like New",
    "Used - Good",
    "Used - Fair",
  ];
  final List<String> _ageGroups = [
    "Newborn (0-3m)",
    "Infant (3-12m)",
    "Toddler (1-3y)",
    "Kids (4-7y)",
    "Junior (8-12y)",
  ];

  final List<String> _genders = ["Boy", "Girl", "Neutral"];

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    final data = widget.productDoc.data() as Map<String, dynamic>;

    _titleController = TextEditingController(text: data['title']);
    _priceController = TextEditingController(text: data['price'].toString());
    _descController = TextEditingController(text: data['description']);
    _locController = TextEditingController(text: data['location']);

    _selectedCategory = data['category'];
    _selectedCondition = data['condition'];
    _selectedAgeGroup = data['ageGroup'];
    _selectedGender = data['gender'];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _locController.dispose();
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
            'location': _locController.text.trim(),
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
      appBar: AppBar(title: const Text("Edit Listing"), centerTitle: true),
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

              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Price (JOD)",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: "Category",
                      value: _selectedCategory,
                      items: _categories,
                      onChanged: (val) =>
                          setState(() => _selectedCategory = val as String),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown(
                      label: "Condition",
                      value: _selectedCondition,
                      items: _conditions,
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
                      items: _ageGroups,
                      onChanged: (val) =>
                          setState(() => _selectedAgeGroup = val as String),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown(
                      label: "Gender",
                      value: _selectedGender,
                      items: _genders,
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _locController,
                maxLines: 1,
                decoration: const InputDecoration(
                  labelText: "Location",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
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
