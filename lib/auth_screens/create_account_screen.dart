import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../feature_screens/main_layout_screen.dart';
import '../managers/auth_manager.dart';
import '../managers/theme_manager.dart';
import '../widgets/custom_text_field.dart';
import 'login_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final AuthManager _authManager = AuthManager();
  bool isLoading = false;

  Future<void> _performRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        await _authManager.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("create_account_screen.success_message").tr(),
              backgroundColor: ThemeManager.successGreen,
              duration: const Duration(seconds: 1),
            ),
          );

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainLayoutScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.message ?? "create_account_screen.fail_message".tr(),
              ),
              backgroundColor: ThemeManager.errorRed,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().split(']').last.trim()),
              backgroundColor: ThemeManager.errorRed,
            ),
          );
        }
      } finally {
        if (context.mounted) setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeManager.backgroundGrey,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                Image.asset("assets/images/logo2.png", height: 160),
                Text(
                  "create_account_screen.title".tr(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: ThemeManager.primaryTeal,
                  ),
                ),
                Text(
                  "create_account_screen.subtitle".tr(),
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  hint: "create_account_screen.full_name_hint".tr(),
                  prefixIcon: Icons.person,
                  controller: _nameController,
                  validator: (val) {
                    if (val == null || val.isEmpty)
                      return "create_account_screen.full_name_error".tr();
                    return null;
                  },
                ),

                CustomTextField(
                  hint: "create_account_screen.email_hint".tr(),
                  prefixIcon: Icons.email,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,

                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "create_account_screen.email_error_empty".tr();
                    }
                    final bool emailValid = RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                    ).hasMatch(val);

                    if (!emailValid) {
                      return "create_account_screen.email_error_invalid".tr();
                    }

                    return null;
                  },
                ),

                CustomTextField(
                  hint: "create_account_screen.phone_hint".tr(),
                  prefixIcon: Icons.phone_android,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "create_account_screen.phone_error_empty".tr();
                    }
                    final bool numberValid = RegExp(
                      r'^(07[789]\d{7})$',
                    ).hasMatch(val);

                    if (!numberValid) {
                      return "create_account_screen.phone_error_invalid".tr();
                    }

                    return null;
                  },
                ),

                CustomTextField(
                  hint: "create_account_screen.password_hint".tr(),
                  prefixIcon: Icons.lock,
                  controller: _passwordController,
                  isPassword: true,
                  validator: (val) {
                    if (val == null || val.isEmpty)
                      return "create_account_screen.password_error_empty".tr();
                    if (val.length < 6)
                      return "create_account_screen.password_error_length".tr();
                    return null;
                  },
                ),

                CustomTextField(
                  hint: "create_account_screen.confirm_password_hint".tr(),
                  prefixIcon: Icons.lock_outline,
                  controller: _confirmPasswordController,
                  isPassword: true,
                  validator: (val) {
                    if (val == null || val.isEmpty)
                      return "create_account_screen.confirm_password_error_empty"
                          .tr();
                    if (_passwordController.text !=
                        _confirmPasswordController.text)
                      return "create_account_screen.confirm_password_error_match"
                          .tr();

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _performRegister,

                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "create_account_screen.sign_up_button".tr(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "create_account_screen.already_have_account",
                    ).tr(),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },

                      child: const Text(
                        "create_account_screen.log_in_button",
                        style: TextStyle(
                          color: ThemeManager.primaryYellow,

                          fontWeight: FontWeight.bold,
                        ),
                      ).tr(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
