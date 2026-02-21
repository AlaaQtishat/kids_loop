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
            const SnackBar(
              content: Text("Account Created Successfully!"),
              backgroundColor: ThemeManager.successGreen,
              duration: Duration(seconds: 1),
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
              content: Text(e.message ?? "Registration failed"),
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
                Image.asset("images/logo2.png", height: 160),
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: ThemeManager.primaryTeal,
                  ),
                ),
                const Text(
                  "Sign up to get started!",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  hint: "Full Name",
                  prefixIcon: Icons.person,
                  controller: _nameController,
                  validator: (val) {
                    if (val == null || val.isEmpty)
                      return "*Full name is required";
                    return null;
                  },
                ),

                CustomTextField(
                  hint: "Email",
                  prefixIcon: Icons.email,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,

                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "*Email is required";
                    }
                    final bool emailValid = RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                    ).hasMatch(val);

                    if (!emailValid) {
                      return "Please enter a valid email (e.g. name@example.com)";
                    }

                    return null;
                  },
                ),

                CustomTextField(
                  hint: "Phone Number (07xxxxxxxx)",
                  prefixIcon: Icons.phone_android,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Phone Number is required";
                    }
                    final bool numberValid = RegExp(
                      r'^(07[789]\d{7})$',
                    ).hasMatch(val);

                    if (!numberValid) {
                      return "Enter a valid JO number (07xxxxxxxx)";
                    }

                    return null;
                  },
                ),

                CustomTextField(
                  hint: "Password",
                  prefixIcon: Icons.lock,
                  controller: _passwordController,
                  isPassword: true,
                  validator: (val) {
                    if (val == null || val.isEmpty)
                      return "*Password is required";
                    if (val.length < 6)
                      return "Password must be at least 6 characters";
                    return null;
                  },
                ),

                CustomTextField(
                  hint: "Confirm Password",
                  prefixIcon: Icons.lock_outline,
                  controller: _confirmPasswordController,
                  isPassword: true,
                  validator: (val) {
                    if (val == null || val.isEmpty)
                      return "*Confirmation is required";
                    if (_passwordController.text !=
                        _confirmPasswordController.text)
                      return "Password do not match";

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
                        : const Text(
                            "SIGN UP",
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
                    const Text("Already have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },

                      child: const Text(
                        "Log In",
                        style: TextStyle(
                          color: ThemeManager.primaryYellow,

                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
