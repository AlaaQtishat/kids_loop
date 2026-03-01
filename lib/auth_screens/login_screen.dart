import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../feature_screens/main_layout_screen.dart';
import '../managers/auth_manager.dart';
import '../managers/theme_manager.dart';
import '../widgets/custom_text_field.dart';
import 'create_account_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final AuthManager _authManager = AuthManager();
  bool isLoading = false;

  Future<void> _performLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        await _authManager.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainLayoutScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message ?? "login_screen.fail_message".tr()),
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
                SizedBox(height: 80),

                Image.asset("assets/images/logo2.png", height: 180, width: 200),
                Text(
                  "login_screen.title".tr(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: ThemeManager.primaryTeal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "login_screen.subtitle".tr(),
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),

                CustomTextField(
                  hint: "login_screen.email_hint".tr(),
                  prefixIcon: Icons.email,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,

                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "login_screen.email_error_empty".tr();
                    }
                    final bool emailValid = RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                    ).hasMatch(val);

                    if (!emailValid) {
                      return "login_screen.email_error_invalid".tr();
                    }

                    return null;
                  },
                ),

                CustomTextField(
                  hint: "login_screen.password_hint".tr(),
                  prefixIcon: Icons.lock,
                  controller: _passwordController,
                  isPassword: true,
                  validator: (val) {
                    if (val == null || val.isEmpty)
                      return "login_screen.password_error_empty".tr();
                    if (val.length < 6)
                      return "login_screen.password_error_length".tr();
                    return null;
                  },
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "login_screen.forgot_password".tr(),
                      style: TextStyle(
                        color: ThemeManager.primaryYellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _performLogin,

                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "login_screen.log_in_button".tr(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("login_screen.no_account").tr(),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const CreateAccountScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "login_screen.create_account_button".tr(),
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
