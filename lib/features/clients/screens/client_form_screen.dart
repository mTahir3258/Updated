import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui_specification/core/theme/app_colors.dart';
import 'package:ui_specification/core/theme/app_dimensions.dart';
import 'package:ui_specification/core/widgets/custom_text_field.dart';
import 'package:ui_specification/features/clients/providers/client_provider.dart';
import 'package:ui_specification/models/client.dart';

class ClientFormScreen extends StatefulWidget {
  final Client? client;

  const ClientFormScreen({super.key, this.client});

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _mobileNumberController;
  late TextEditingController _whatsappController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _sourceController;
  late TextEditingController _createdByController;

  @override
  void initState() {
    super.initState();

    // Parse fullName into first and last name components
    final fullName = widget.client?.fullName ?? '';
    final nameParts = fullName.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
    _mobileNumberController = TextEditingController(
      text: widget.client?.mobileNumber ?? '',
    );

    _whatsappController = TextEditingController(
      text: widget.client?.whatsappNumber ?? '',
    );
    _addressController = TextEditingController(
      text: widget.client?.address ?? '',
    );
    _emailController = TextEditingController(text: widget.client?.email ?? '');
    _sourceController = TextEditingController(
      text: widget.client?.source ?? '',
    );
    _createdByController = TextEditingController(
      text: widget.client?.createdBy ?? '',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileNumberController.dispose();
    _whatsappController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _sourceController.dispose();
    _createdByController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.client == null ? 'New Client' : 'Edit Client'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          ElevatedButton(
            onPressed: _saveClient,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
            ),
            child: const Text(
              'SAVE',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          children: [
            _buildSectionCard('Client Information', [
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'First Name',
                      controller: _firstNameController,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                      prefixIcon: const Icon(Icons.person_outline),
                      hint: 'First name',
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacing12),
                  Expanded(
                    child: CustomTextField(
                      label: 'Last Name',
                      controller: _lastNameController,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                      prefixIcon: const Icon(Icons.person_outline),
                      hint: 'Last name',
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: AppDimensions.spacing16),

            _buildSectionCard('Contact Details', [
              CustomTextField(
                label: 'Mobile Number',
                controller: _mobileNumberController,
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                prefixIcon: const Icon(Icons.phone_android_outlined),
                hint: '+91 XXXXX XXXXX',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'WhatsApp Number',
                controller: _whatsappController,
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                prefixIcon: const Icon(Icons.phone_outlined),
                hint: '+91 XXXXX XXXXX',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
                hint: 'Optional',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Address',
                controller: _addressController,
                maxLines: 3,
                prefixIcon: const Icon(Icons.location_on_outlined),
                hint: 'Full address with city, state, pincode',
              ),
            ]),
            const SizedBox(height: AppDimensions.spacing16),

            _buildSectionCard('Source & Details', [
              CustomTextField(
                label: 'Source',
                controller: _sourceController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                prefixIcon: const Icon(Icons.source_outlined),
                hint: 'e.g., Referral, Facebook, Instagram',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Created By',
                controller: _createdByController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                prefixIcon: const Icon(Icons.person_add_outlined),
                hint: 'Your name or user ID',
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      elevation: AppDimensions.elevation1,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            ...children,
          ],
        ),
      ),
    );
  }

  void _saveClient() {
    if (_formKey.currentState?.validate() ?? false) {
      final client = Client(
        id:
            widget.client?.id ??
            'CLT${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        mobileNumber: _mobileNumberController.text,
        whatsappNumber: _whatsappController.text,
        address: _addressController.text.isEmpty
            ? null
            : _addressController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        source: _sourceController.text,
        createdBy: _createdByController.text,
        createdDate: widget.client?.createdDate ?? DateTime.now(),
        contactPersons: widget.client?.contactPersons ?? [],
      );

      if (widget.client != null) {
        context.read<ClientProvider>().updateClient(client);
      } else {
        context.read<ClientProvider>().addClient(client);
      }

      Navigator.pop(context);
    }
  }
}
