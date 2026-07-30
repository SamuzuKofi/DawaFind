import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../../core/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkText),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: AppColors.white, size: 28),
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.welcomeBack,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Log in to access your saved pharmacies and searches',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.greyText),
              ),
              const SizedBox(height: 32),
              _field(
                label: 'Email',
                icon: Icons.email_outlined,
                controller: _emailController,
                validator: Validators.email,
              ),
              _field(
                label: AppStrings.password,
                icon: Icons.lock_outline,
                controller: _passwordController,
                obscure: _obscurePassword,
                validator: Validators.password,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    AppStrings.forgotPassword,
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await AuthService().logIn(
                          email: _emailController.text.trim(),
                          password: _passwordController.text,
                        );
                        await PreferencesService.saveUserType('patient');
                        if (!mounted) return;
                        navigator.pushReplacementNamed(AppRoutes.homePatient);
                      } on FirebaseAuthException catch (e) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(content: Text(e.message ?? 'Login failed')),
                        );
                      }
                    }
                  },
                  child: Text(
                    AppStrings.logInAsPatient,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.primaryGreen,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await AuthService().logIn(
                          email: _emailController.text.trim(),
                          password: _passwordController.text,
                        );
                        await PreferencesService.saveUserType('pharmacist');
                        if (!mounted) return;
                        navigator.pushReplacementNamed(
                          AppRoutes.homePharmacist,
                        );
                      } on FirebaseAuthException catch (e) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(content: Text(e.message ?? 'Login failed')),
                        );
                      }
                    }
                  },
                  child: Text(
                    AppStrings.logInAsPharmacist,
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or',
                      style: TextStyle(color: AppColors.greyText),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.lightGreyBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    final authService = AuthService();
                    final userCredential = await authService.signInWithGoogle();
                    if (userCredential != null) {
                      await PreferencesService.saveUserType('patient');
                      if (!mounted) return;
                      navigator.pushNamed(AppRoutes.homePatient);
                    } else {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Google sign-in cancelled'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.g_mobiledata,
                    color: AppColors.primaryGreen,
                    size: 28,
                  ),
                  label: Text(
                    AppStrings.continueWithGoogle,
                    style: const TextStyle(color: AppColors.darkText),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    await AuthService().sendPasswordReset(
                      _emailController.text.trim(),
                    );
                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Password reset email sent'),
                      ),
                    );
                  } on FirebaseAuthException catch (e) {
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(e.message ?? 'Password reset failed'),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Forgot your password?',
                  style: TextStyle(color: AppColors.primaryGreen),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextEditingController? controller,
    bool obscure = false,
    Widget? suffix,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightGreyBorder),
        ),
      ),
    ),
  );
}
