import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Account type the user asked for. The backend decides the role it actually
  // grants, so this is a request rather than a guarantee.
  String _requestedRole = 'patient';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  /// Stores the role the backend granted so the splash screen can route
  /// straight to the right home screen on every later launch.
  Future<void> _onRegistered(BuildContext context, String grantedRole) async {
    await PreferencesService.saveUserType(grantedRole);
    await PreferencesService.setLoggedIn(true);
    if (!context.mounted) return;

    if (_requestedRole == 'pharmacist' && grantedRole != 'pharmacist') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created as a patient. Pharmacist accounts must be approved by an admin.',
          ),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      grantedRole == 'pharmacist'
          ? AppRoutes.homePharmacist
          : AppRoutes.homePatient,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _onRegistered(context, state.role);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
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
                  const Text(
                    AppStrings.createAccount,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'I am signing up as',
                    style: TextStyle(fontSize: 13, color: AppColors.greyText),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'patient',
                        label: Text('Patient'),
                        icon: Icon(Icons.person_outline),
                      ),
                      ButtonSegment(
                        value: 'pharmacist',
                        label: Text('Pharmacist'),
                        icon: Icon(Icons.local_pharmacy_outlined),
                      ),
                    ],
                    selected: {_requestedRole},
                    onSelectionChanged: (selection) =>
                        setState(() => _requestedRole = selection.first),
                  ),
                  const SizedBox(height: 20),
                  _field(
                    label: AppStrings.fullName,
                    icon: Icons.person_outline,
                    controller: _nameController,
                    validator: Validators.required,
                  ),
                  _field(
                    label: AppStrings.phoneNumber,
                    icon: Icons.phone_outlined,
                    controller: _phoneController,
                    validator: Validators.phone,
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
                    obscure: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (v != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
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
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: AppColors.white,
                            )
                          : const Text(
                              AppStrings.createAccount,
                              style: TextStyle(
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
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
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
