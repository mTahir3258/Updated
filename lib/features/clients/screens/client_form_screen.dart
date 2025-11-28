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
  late TextEditingController _fullNameController;
  late TextEditingController _whatsappController;
  late TextEditingController _alternateNumberController;
  late TextEditingController _emailController;
  late TextEditingController _sourceController;
  late TextEditingController _createdByController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: widget.client?.fullName ?? '',
    );
    _whatsappController = TextEditingController(
      text: widget.client?.whatsappNumber ?? '',
    );
    _alternateNumberController = TextEditingController(
      text: widget.client?.alternateNumber ?? '',
    );
    _emailController = TextEditingController(text: widget.client?.email ?? '');
    _sourceController = TextEditingController(
      text: widget.client?.source ?? '',
    );
    _createdByController = TextEditingController(
      text: widget.client?.createdBy ?? '',
    );
    _notesController = TextEditingController(text: widget.client?.notes ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _whatsappController.dispose();
    _alternateNumberController.dispose();
    _emailController.dispose();
    _sourceController.dispose();
    _createdByController.dispose();
    _notesController.dispose();
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
          TextButton(
            onPressed: _saveClient,
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
            _buildSectionTitle('Client Information'),
            CustomTextField(
              label: 'Full Name',
              controller: _fullNameController,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              prefixIcon: const Icon(Icons.person_outline),
              hint: 'e.g., Rajesh & Priya',
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Contact Details'),
            CustomTextField(
              label: 'WhatsApp Number',
              controller: _whatsappController,
              keyboardType: TextInputType.phone,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              prefixIcon: const Icon(Icons.phone_outlined),
              hint: '+91 XXXXX XXXXX',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Alternate Number',
              controller: _alternateNumberController,
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone_android_outlined),
              hint: 'Optional',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined),
              hint: 'Optional',
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Source & Details'),
            CustomTextField(
              label: 'Source',
              controller: _sourceController,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              prefixIcon: const Icon(Icons.source_outlined),
              hint: 'e.g., Referral, Facebook, Instagram',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Created By',
              controller: _createdByController,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              prefixIcon: const Icon(Icons.person_add_outlined),
              hint: 'Your name or user ID',
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Additional Notes'),
            CustomTextField(
              label: 'Notes',
              controller: _notesController,
              maxLines: 3,
              prefixIcon: const Icon(Icons.note_outlined),
              hint: 'Optional notes about the client',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
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
        fullName: _fullNameController.text,
        whatsappNumber: _whatsappController.text,
        alternateNumber: _alternateNumberController.text.isEmpty
            ? null
            : _alternateNumberController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        source: _sourceController.text,
        createdBy: _createdByController.text,
        createdDate: widget.client?.createdDate ?? DateTime.now(),
        contactPersons: widget.client?.contactPersons ?? [],
        notes: _notesController.text.isEmpty ? null : _notesController.text,
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
