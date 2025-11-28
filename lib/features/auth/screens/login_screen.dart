import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui_specification/core/theme/app_colors.dart';
import 'package:ui_specification/core/theme/app_dimensions.dart';
import 'package:ui_specification/core/utils/responsive.dart';
import 'package:ui_specification/core/utils/validators.dart';
import 'package:ui_specification/core/widgets/custom_text_field.dart';
import 'package:ui_specification/core/widgets/loading_indicator.dart';
import 'package:ui_specification/core/constants/routes.dart';
import 'package:ui_specification/features/auth/providers/auth_provider.dart';

/// Login screen with responsive layout
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Login failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive(
        mobile: _buildMobileLayout(),
        tablet: _buildDesktopLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  // Mobile Layout - Full screen form
  Widget _buildMobileLayout() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spacing24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Icon(
                Icons.event_available,
                size: AppDimensions.iconXXLarge * 2,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppDimensions.spacing16),
              Text(
                'Event Management',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppDimensions.spacing48),

              // Login Form
              _buildLoginForm(),
            ],
          ),
        ),
      ),
    );
  }

  // Desktop Layout - Split screen
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Promotional Section (Left)
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_available,
                    size: 120,
                    color: AppColors.textOnPrimary,
                  ),
                  const SizedBox(height: AppDimensions.spacing24),
                  Text(
                    'Event Management System',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing48,
                    ),
                    child: Text(
                      'Manage your events, leads, clients, and teams all in one place',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textOnPrimary.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Login Form (Right)
        Expanded(
          child: Container(
            color: AppColors.background,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spacing48),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: _buildLoginForm(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const LoadingIndicator(message: 'Signing in...');
        }

        return Card(
          elevation: AppDimensions.elevation2,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sign In',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacing24),

                  // Email Field
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  const SizedBox(height: AppDimensions.spacing16),

                  // Password Field
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    obscureText: _obscurePassword,
                    validator: Validators.password,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing24),

                  // Sign In Button
                  ElevatedButton(
                    onPressed: _handleLogin,
                    child: const Text('Sign In'),
                  ),
                  const SizedBox(height: AppDimensions.spacing8),

                  // Forgot Password
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(Routes.forgotPassword);
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
