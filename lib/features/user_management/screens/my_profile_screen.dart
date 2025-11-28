import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui_specification/core/theme/app_colors.dart';
import 'package:ui_specification/core/theme/app_dimensions.dart';
import 'package:ui_specification/core/widgets/custom_card.dart';
import 'package:ui_specification/core/widgets/custom_text_field.dart';
import 'package:ui_specification/features/auth/providers/auth_provider.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  // Personal Info Controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  // Password Controllers
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Notification Preferences
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;

  bool _isEditing = false;
  bool _isChangingPassword = false;

  @override
  void initState() {
    super.initState();
    // In a real app, load from AuthProvider
    _firstNameController = TextEditingController(text: 'Admin');
    _lastNameController = TextEditingController(text: 'User');
    _phoneController = TextEditingController(text: '+1234567890');
    _emailController = TextEditingController(text: 'admin@example.com');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(icon: const Icon(Icons.check), onPressed: _saveProfile),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: AppDimensions.spacing16),
            _buildPersonalInfoSection(),
            const SizedBox(height: AppDimensions.spacing16),
            _buildChangePasswordSection(),
            const SizedBox(height: AppDimensions.spacing16),
            _buildNotificationPreferences(),
            const SizedBox(height: AppDimensions.spacing24),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing24),
        child: Column(
          children: [
            Stack(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    'A',
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 18),
                        onPressed: () {
                          // TODO: Implement image picker
                        },
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing16),
            Text(
              '${_firstNameController.text} ${_lastNameController.text}',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _emailController.text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Administrator',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personal Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDimensions.spacing16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'First Name',
                      controller: _firstNameController,
                      enabled: _isEditing,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacing16),
                  Expanded(
                    child: CustomTextField(
                      label: 'Last Name',
                      controller: _lastNameController,
                      enabled: _isEditing,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing16),
              CustomTextField(
                label: 'Email',
                controller: _emailController,
                enabled: false, // Email usually read-only
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppDimensions.spacing16),
              CustomTextField(
                label: 'Phone Number',
                controller: _phoneController,
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChangePasswordSection() {
    return CustomCard(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: const Text(
            'Change Password',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacing16),
              child: Form(
                key: _passwordFormKey,
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Current Password',
                      controller: _currentPasswordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: AppDimensions.spacing16),
                    CustomTextField(
                      label: 'New Password',
                      controller: _newPasswordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: AppDimensions.spacing16),
                    CustomTextField(
                      label: 'Confirm New Password',
                      controller: _confirmPasswordController,
                      obscureText: true,
                      validator: (v) {
                        if (v != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.spacing16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Update Password'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationPreferences() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Preferences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacing8),
            SwitchListTile(
              title: const Text('Email Notifications'),
              value: _emailNotifications,
              onChanged: _isEditing
                  ? (v) => setState(() => _emailNotifications = v)
                  : null,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Push Notifications'),
              value: _pushNotifications,
              onChanged: _isEditing
                  ? (v) => setState(() => _pushNotifications = v)
                  : null,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('SMS Notifications'),
              value: _smsNotifications,
              onChanged: _isEditing
                  ? (v) => setState(() => _smsNotifications = v)
                  : null,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          Provider.of<AuthProvider>(context, listen: false).logout();
          Navigator.of(context).pushReplacementNamed('/login');
        },
        style: TextButton.styleFrom(
          foregroundColor: AppColors.error,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Log Out'),
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Call API to update profile
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  void _changePassword() {
    if (_passwordFormKey.currentState?.validate() ?? false) {
      // TODO: Call API to change password
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );
    }
  }
}
