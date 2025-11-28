import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui_specification/core/theme/app_colors.dart';
import 'package:ui_specification/core/theme/app_dimensions.dart';
import 'package:ui_specification/core/utils/responsive.dart';
import 'package:ui_specification/core/utils/validators.dart';
import 'package:ui_specification/core/widgets/custom_text_field.dart';
import 'package:ui_specification/core/widgets/loading_indicator.dart';
import 'package:ui_specification/features/auth/providers/auth_provider.dart';

/// Forgot password screen with responsive layout
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.forgotPassword(_emailController.text);

    if (success && mounted) {
      setState(() {
        _emailSent = true;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Failed to send reset email'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
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
              // Icon
              Icon(
                Icons.lock_reset,
                size: AppDimensions.iconXXLarge * 2,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppDimensions.spacing16),
              Text(
                'Reset Your Password',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacing16),
              Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacing48),

              // Forgot Password Form
              _buildForgotPasswordForm(),
            ],
          ),
        ),
      ),
    );
  }

  // Desktop Layout - Centered card
  Widget _buildDesktopLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacing48),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            elevation: AppDimensions.elevation2,
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacing32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Icon(
                    Icons.lock_reset,
                    size: AppDimensions.iconXLarge * 2,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  Text(
                    'Reset Your Password',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  Text(
                    'Enter your email address and we\'ll send you a link to reset your password.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacing32),

                  // Forgot Password Form
                  _buildForgotPasswordForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordForm() {
    if (_emailSent) {
      return _buildSuccessMessage();
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const LoadingIndicator(message: 'Sending reset email...');
        }

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Email Field
              CustomTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              const SizedBox(height: AppDimensions.spacing24),

              // Send Reset Email Button
              ElevatedButton(
                onPressed: _handleForgotPassword,
                child: const Text('Send Reset Email'),
              ),
              const SizedBox(height: AppDimensions.spacing16),

              // Back to Login
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: AppDimensions.iconXLarge * 2,
          color: AppColors.success,
        ),
        const SizedBox(height: AppDimensions.spacing16),
        Text(
          'Reset Email Sent!',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: AppColors.success),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacing16),
        Text(
          'We\'ve sent a password reset link to ${_emailController.text}. Please check your email and follow the instructions.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacing32),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Back to Login'),
        ),
        const SizedBox(height: AppDimensions.spacing16),
        TextButton(
          onPressed: () {
            setState(() {
              _emailSent = false;
            });
          },
          child: const Text('Try Different Email'),
        ),
      ],
    );
  }
}
