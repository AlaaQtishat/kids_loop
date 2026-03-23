import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kids_loop/bottom_navigation_pages/profile_screen/myListings.dart';
import 'package:kids_loop/services/favorite_provider.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:kids_loop/auth_screens/login_screen.dart';
import 'package:kids_loop/managers/theme_manager.dart';
import 'package:kids_loop/services/cloudinary_service.dart';
import 'package:kids_loop/services/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _phoneNumber = "";
  String _userName = "";
  String? _photoUrl;
  bool _isUploadingPic = false;

  @override
  void initState() {
    super.initState();
    _userName = "profile_screen.loading_name".tr();
    _phoneNumber = "profile_screen.loading_number".tr();
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
            _userName =
                data?['full_name'] ?? "profile_screen.default_member_name".tr();
            _phoneNumber =
                data?['phone_number'] ?? "profile_screen.no_number".tr();

            if (data?['photoUrl'] != null &&
                data!['photoUrl'].toString().isNotEmpty) {
              _photoUrl = data['photoUrl'];
            }
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _userName = "profile_screen.error_loading_name".tr();
            _phoneNumber = "profile_screen.error_loading_number".tr();
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
              SnackBar(
                content: Text("profile_screen.profile_pic_updated".tr()),
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
            content: Text("${'profile_screen.error_uploading_image'.tr()}$e"),
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
          title: Text(
            "profile_screen.change_phone_title".tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  return "profile_screen.phone_empty_error".tr();
                }
                final bool numberValid = RegExp(
                  r'^(07[789]\d{7})$',
                ).hasMatch(val);
                if (!numberValid) {
                  return "profile_screen.invalid_jordanian_number".tr();
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "profile_screen.cancel".tr(),
                style: TextStyle(color: Colors.grey),
              ),
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
                          SnackBar(
                            content: Text("profile_screen.phone_updated".tr()),
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
                          content: Text(
                            "${'profile_screen.error_prefix'.tr()}$e",
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                }
              },
              child: Text(
                "profile_screen.save".tr(),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final String userEmail = user?.email ?? "profile_screen.no_email".tr();
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildProfileHeader(_userName, userEmail, _photoUrl, _phoneNumber),

            const SizedBox(height: 15),

            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyListingsScreen()),
                  );
                },
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ThemeManager.primaryTeal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.grid_view_rounded,
                    color: ThemeManager.primaryTeal,
                  ),
                ),
                title: Text(
                  "profile_screen.my_listings".tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  "profile_screen.manage_items".tr(),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Align(
              alignment: context.locale.languageCode == 'ar'
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Text(
                "profile_screen.settings".tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
                      "profile_screen.language".tr(),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: _showLanguageBottomSheet,
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
                    title: Text("profile_screen.dark_mode".tr()),
                    trailing: Switch(
                      value: themeProvider.isDark,
                      activeColor: ThemeManager.primaryTeal,
                      onChanged: (value) => themeProvider.toggleTheme(),
                    ),
                  ),

                  const Divider(height: 1, indent: 20, endIndent: 20),

                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: Text(
                      "profile_screen.log_out".tr(),
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Text(
                              "profile_screen.log_out".tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ThemeManager.primaryTeal,
                              ),
                            ),
                            content: Text(
                              "profile_screen.log_out_content".tr(),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                },
                                child: Text(
                                  "profile_screen.cancel".tr(),
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              SizedBox(
                                width: 130,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ThemeManager.errorRed,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(dialogContext);

                                    OneSignal.logout();
                                    await FirebaseAuth.instance.signOut();
                                    context
                                        .read<FavoritesProvider>()
                                        .clearFavoritesLocally();

                                    if (context.mounted) {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen(),
                                        ),
                                        (Route<dynamic> route) => false,
                                      );
                                    }
                                  },
                                  child: Text("profile_screen.log_out".tr()),
                                ),
                              ),
                            ],
                          );
                        },
                      );
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              GestureDetector(
                onTap: _isUploadingPic ? null : _changeProfilePicture,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ThemeManager.primaryTeal,
                      width: 3,
                    ),

                    image: photoUrl != null && photoUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(photoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                  child: _isUploadingPic
                      ? const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(
                            color: ThemeManager.primaryTeal,
                            strokeWidth: 3,
                          ),
                        )
                      : (photoUrl == null || photoUrl!.isEmpty)
                      ? Icon(
                          Icons.person,
                          size: 50,
                          color: Theme.of(context).hintColor,
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 4,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: ThemeManager.primaryYellow,
                      shape: BoxShape.circle,
                    ),
                    child: _isUploadingPic
                        ? const SizedBox(width: 16, height: 16)
                        : const Icon(Icons.edit, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ThemeManager.primaryTeal,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          Text(
            userEmail,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: ThemeManager.primaryTeal.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.phone_android, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  phoneNumber,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: _showChangePhoneDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeManager.primaryTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "profile_screen.change_button".tr(),
                      style: TextStyle(
                        color: ThemeManager.primaryTeal,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text(
                  "English",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  context.setLocale(const Locale('en'));
                  OneSignal.User.setLanguage('en');
                  Navigator.pop(context);
                },
                trailing: context.locale.languageCode == 'en'
                    ? const Icon(
                        Icons.check_circle,
                        color: ThemeManager.primaryTeal,
                      )
                    : null,
              ),
              ListTile(
                title: const Text(
                  "العربية",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: context.locale.languageCode == 'ar'
                    ? const Icon(
                        Icons.check_circle,
                        color: ThemeManager.primaryTeal,
                      )
                    : null,
                onTap: () {
                  context.setLocale(const Locale('ar'));
                  OneSignal.User.setLanguage('ar');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
