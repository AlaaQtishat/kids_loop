import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kids_loop/feature_screens/myListings.dart';
import 'package:provider/provider.dart';
import 'package:kids_loop/auth_screens/login_screen.dart';
import 'package:kids_loop/managers/theme_manager.dart';
import '../services/cloudinary_service.dart';
import '../services/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _phoneNumber = "Loading...";
  String _userName = "Loading...";
  String? _photoUrl;
  bool _isUploadingPic = false;

  @override
  void initState() {
    super.initState();
    _photoUrl = FirebaseAuth.instance.currentUser?.photoURL;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();

        if (mounted && doc.exists) {
          setState(() {
            final data = doc.data();
            _userName = data?['full_name'] ?? "KidsLoop Member";
            _phoneNumber = data?['phone_number'] ?? "No number";
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _userName = "Error loading name";
            _phoneNumber = "Error loading number";
          });
        }
      }
    }
  }

  Future<void> _changeProfilePicture() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile == null) return;

    setState(() {
      _isUploadingPic = true;
    });

    try {
      File imageFile = File(pickedFile.path);
      String? profilePicUrl = await CloudinaryService.uploadToCloudinary(
        imageFile,
      );

      if (profilePicUrl != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updateProfile(photoURL: profilePicUrl);

          await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .update({"photoUrl": profilePicUrl});

          setState(() {
            _photoUrl = profilePicUrl;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Profile picture updated!"),
                backgroundColor: ThemeManager.successGreen,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error uploading image: $e"),
            backgroundColor: ThemeManager.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPic = false;
        });
      }
    }
  }

  void _showChangePhoneDialog() {
    final TextEditingController phoneController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Change Phone Number",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "07XXXXXXXX",
                prefixIcon: const Icon(Icons.phone_android),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return "Please enter a phone number";
                }
                final bool numberValid = RegExp(
                  r'^(07[789]\d{7})$',
                ).hasMatch(val);
                if (!numberValid) {
                  return "Invalid Jordanian number";
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeManager.primaryTeal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(
                        color: ThemeManager.primaryTeal,
                      ),
                    ),
                  );

                  try {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(user.uid)
                          .update({
                            "phone_number": phoneController.text.trim(),
                          });

                      setState(() {
                        _phoneNumber = phoneController.text.trim();
                      });

                      if (context.mounted) {
                        Navigator.pop(context);

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Phone number updated successfully!"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error: $e"),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = FirebaseAuth.instance.currentUser;
    final String userEmail = user?.email ?? "No email linked";
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),

            _buildProfileHeader(_userName, userEmail, _photoUrl, _phoneNumber),

            const SizedBox(height: 15),

            _buildMenuOption(
              icon: Icons.grid_view_rounded,
              title: "My Listings",
              subtitle: "Manage your items for sale",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyListingsScreen()),
                );
              },
            ),

            _buildMenuOption(
              icon: Icons.favorite_rounded,
              title: "Favorites",
              subtitle: "Items you saved",
              onTap: () {},
            ),

            const SizedBox(height: 10),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Settings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.language, color: Colors.grey[600]),
                    title: Text(
                      "Language",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () {},
                  ),

                  const Divider(height: 1, indent: 20, endIndent: 20),

                  ListTile(
                    leading: Icon(
                      themeProvider.isDark
                          ? Icons.nightlight_round
                          : Icons.wb_sunny_rounded,
                      color: themeProvider.isDark
                          ? Colors.amber
                          : Colors.orangeAccent,
                    ),
                    title: const Text("Dark Mode"),
                    trailing: Switch(
                      value: themeProvider.isDark,
                      activeColor: ThemeManager.primaryTeal,
                      onChanged: (value) => themeProvider.toggleTheme(),
                    ),
                  ),

                  const Divider(height: 1, indent: 20, endIndent: 20),

                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: const Text(
                      "Log Out",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    String userName,
    String userEmail,
    String? photoUrl,
    String phoneNumber,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (theme.brightness == Brightness.light)
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: _isUploadingPic ? null : _changeProfilePicture,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ThemeManager.primaryTeal,
                      width: 2,
                    ),

                    image: _photoUrl != null && _photoUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(_photoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),

                  child: _isUploadingPic
                      ? const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(
                            color: ThemeManager.primaryTeal,
                            strokeWidth: 2.5,
                          ),
                        )
                      : (_photoUrl == null || _photoUrl!.isEmpty)
                      ? Icon(
                          Icons.person,
                          size: 40,
                          color: Theme.of(context).hintColor,
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: ThemeManager.primaryYellow,
                      shape: BoxShape.circle,
                    ),

                    child: _isUploadingPic
                        ? const SizedBox(width: 14, height: 14)
                        : const Icon(Icons.edit, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeManager.primaryTeal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  userEmail,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.phone_android,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      phoneNumber,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: _showChangePhoneDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeManager.primaryTeal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Change",
                          style: TextStyle(
                            color: ThemeManager.primaryTeal,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ThemeManager.primaryTeal.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: ThemeManager.primaryTeal),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 18,
          color: Colors.grey,
        ),
      ),
    );
  }
}
