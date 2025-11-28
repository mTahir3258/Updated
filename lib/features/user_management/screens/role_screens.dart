import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui_specification/core/widgets/custom_card.dart';
import 'package:ui_specification/core/widgets/custom_text_field.dart';
import 'package:ui_specification/features/user_management/providers/user_management_provider.dart';
import 'package:ui_specification/models/user_management.dart';

class RoleListScreen extends StatelessWidget {
  const RoleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagementProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('Roles'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.roles.length,
                  itemBuilder: (context, index) {
                    final role = provider.roles[index];
                    return CustomCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          role.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${role.permissions.length} Permissions',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.blue,
                              ),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RoleFormScreen(role: role),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () => _showDeleteConfirmation(
                                context,
                                provider,
                                role,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RoleFormScreen()),
            ),
            backgroundColor: Colors.blue,
            icon: const Icon(Icons.add),
            label: const Text('Add Role'),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    UserManagementProvider provider,
    Role role,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Role'),
        content: Text('Are you sure you want to delete ${role.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteRole(role.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class RoleFormScreen extends StatefulWidget {
  final Role? role;

  const RoleFormScreen({super.key, this.role});

  @override
  State<RoleFormScreen> createState() => _RoleFormScreenState();
}

class _RoleFormScreenState extends State<RoleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  final List<String> _availablePermissions = [
    'read_dashboard',
    'read_leads',
    'write_leads',
    'read_clients',
    'write_clients',
    'read_events',
    'write_events',
    'read_quotations',
    'write_quotations',
    'read_orders',
    'write_orders',
    'read_users',
    'write_users',
    'read_setup',
    'write_setup',
  ];
  late Set<String> _selectedPermissions;

  List<Widget> _buildGroupedPermissions() {
    final Map<String, List<String>> grouped = {};
    for (var p in _availablePermissions) {
      final module = p
          .split('_')
          .last; // e.g., 'dashboard' from 'read_dashboard'
      if (!grouped.containsKey(module)) {
        grouped[module] = [];
      }
      grouped[module]!.add(p);
    }

    return grouped.entries.map((entry) {
      final moduleName = entry.key.toUpperCase();
      final permissions = entry.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              moduleName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: permissions.map((permission) {
              final isSelected = _selectedPermissions.contains(permission);
              return FilterChip(
                label: Text(
                  permission.split('_').first.toUpperCase(),
                ), // READ/WRITE
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedPermissions.add(permission);
                    } else {
                      _selectedPermissions.remove(permission);
                    }
                  });
                },
                selectedColor: Colors.blue.shade100,
                checkmarkColor: Colors.blue,
              );
            }).toList(),
          ),
          const Divider(),
        ],
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.role?.name ?? '');
    _selectedPermissions = Set.from(widget.role?.permissions ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.role != null ? 'Edit Role' : 'Add Role'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        label: 'Role Name',
                        controller: _nameController,
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Permissions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._buildGroupedPermissions(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _saveRole,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Save Role'),
        ),
      ),
    );
  }

  void _saveRole() {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = Provider.of<UserManagementProvider>(
        context,
        listen: false,
      );

      final role = Role(
        id: widget.role?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        permissions: _selectedPermissions.toList(),
      );

      if (widget.role != null) {
        provider.updateRole(role);
      } else {
        provider.addRole(role);
      }

      Navigator.pop(context);
    }
  }
}
