import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../data/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.createAccount,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 24),
              _field(
                label: AppStrings.fullName,
                icon: Icons.person_outline,
                controller: _fullNameController,
                validator: Validators.required,
              ),
              _field(
                label: AppStrings.email,
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
              _field(
                label: AppStrings.confirmPassword,
                icon: Icons.lock_outline,
                controller: _confirmPasswordController,
                obscure: true,
                validator: _confirmPasswordValidator,
              ),
              const SizedBox(height: 16),
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
                      try {
                        await AuthService().signUp(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                          fullName: _fullNameController.text.trim(),
                        );
                        if (!context.mounted) return;
                        Navigator.pushNamed(context, AppRoutes.homePatient);
                      } catch (error) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error.toString())),
                        );
                      }
                    }
                  },
                  child: Text(
                    AppStrings.createAccount,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.login),
                  child: const Text(
                    'Already have an account? Log In',
                    style: TextStyle(color: AppColors.primaryGreen),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    if (value.trim() != _passwordController.text.trim()) {
      return 'Passwords do not match';
    }
    return null;
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
