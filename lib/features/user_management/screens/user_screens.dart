import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui_specification/core/theme/app_colors.dart';
import 'package:ui_specification/core/theme/app_dimensions.dart';
import 'package:ui_specification/core/widgets/custom_card.dart';
import 'package:ui_specification/core/widgets/custom_text_field.dart';
import 'package:ui_specification/features/user_management/providers/user_management_provider.dart';
import 'package:ui_specification/models/user_management.dart';
import 'package:ui_specification/core/widgets/filter_bar.dart';
import 'package:ui_specification/core/widgets/pagination_controls.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  // Filter & Pagination State
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = 'All';
  int _currentPage = 1;
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _currentPage = 1;
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedRole = filter;
      _currentPage = 1;
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _onRowsPerPageChanged(int rows) {
    setState(() {
      _rowsPerPage = rows;
      _currentPage = 1;
    });
  }

  List<User> _getFilteredUsers(List<User> allUsers, List<Role> allRoles) {
    return allUsers.where((user) {
      // Search Filter
      final query = _searchController.text.toLowerCase();
      final matchesSearch =
          user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);

      // Role Filter
      if (_selectedRole == 'All') return matchesSearch;

      final role = allRoles.firstWhere(
        (r) => r.id == user.roleId,
        orElse: () => Role(id: '', name: 'Unknown', permissions: []),
      );
      final matchesRole = role.name == _selectedRole;

      return matchesSearch && matchesRole;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagementProvider>(
      builder: (context, provider, child) {
        final roles = ['All', ...provider.roles.map((r) => r.name)];
        final filteredUsers = _getFilteredUsers(provider.users, provider.roles);
        final totalItems = filteredUsers.length;
        final totalPages = (totalItems / _rowsPerPage).ceil();
        final startIndex = (_currentPage - 1) * _rowsPerPage;
        final endIndex = (startIndex + _rowsPerPage < totalItems)
            ? startIndex + _rowsPerPage
            : totalItems;
        final paginatedUsers = filteredUsers.isEmpty
            ? <User>[]
            : filteredUsers.sublist(startIndex, endIndex);

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('Users'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    FilterBar(
                      searchController: _searchController,
                      filters: roles,
                      selectedFilter: _selectedRole,
                      onFilterChanged: _onFilterChanged,
                      onClearSearch: () {
                        _searchController.clear();
                        setState(() {
                          _currentPage = 1;
                        });
                      },
                    ),
                    Expanded(
                      child: filteredUsers.isEmpty
                          ? const Center(child: Text('No Users Found'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: paginatedUsers.length,
                              itemBuilder: (context, index) {
                                final user = paginatedUsers[index];
                                final role = provider.roles.firstWhere(
                                  (r) => r.id == user.roleId,
                                  orElse: () => Role(
                                    id: '',
                                    name: 'Unknown',
                                    permissions: [],
                                  ),
                                );

                                return CustomCard(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue.shade100,
                                      child: Text(
                                        user.name.substring(0, 1).toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      user.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(user.email),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            role.name,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                        ),
                                      ],
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
                                                  UserFormScreen(user: user),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                          ),
                                          onPressed: () =>
                                              _showDeleteConfirmation(
                                                context,
                                                provider,
                                                user,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    if (filteredUsers.isNotEmpty)
                      PaginationControls(
                        currentPage: _currentPage,
                        totalPages: totalPages > 0 ? totalPages : 1,
                        rowsPerPage: _rowsPerPage,
                        totalItems: totalItems,
                        onPageChanged: _onPageChanged,
                        onRowsPerPageChanged: _onRowsPerPageChanged,
                      ),
                  ],
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserFormScreen()),
            ),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add),
            label: const Text('Add User'),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    UserManagementProvider provider,
    User user,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteUser(user.id);
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

class RolesListScreen extends StatefulWidget {
  const RolesListScreen({super.key});

  @override
  State<RolesListScreen> createState() => _RolesListScreenState();
}

class _RolesListScreenState extends State<RolesListScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagementProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Roles'),
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
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
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Text(
                            role.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),
                        title: Text(
                          role.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${role.permissions.length} permissions',
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
            backgroundColor: AppColors.primary,
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
  List<String> _selectedPermissions = [];

  final List<String> _availablePermissions = [
    'Manage Users',
    'Manage Roles',
    'View Reports',
    'Edit Settings',
    'Delete Records',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.role?.name ?? '');
    _selectedPermissions = List.from(widget.role?.permissions ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.role != null ? 'Edit Role' : 'Add Role'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          ElevatedButton(
            onPressed: _saveRole,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
            ),
            child: const Text('SAVE'),
          ),
        ],
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
                    children: [
                      CustomTextField(
                        label: 'Role Name',
                        controller: _nameController,
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Permissions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._availablePermissions.map((permission) {
                        return CheckboxListTile(
                          title: Text(permission),
                          value: _selectedPermissions.contains(permission),
                          onChanged: (value) {
                            setState(() {
                              if (value ?? false) {
                                _selectedPermissions.add(permission);
                              } else {
                                _selectedPermissions.remove(permission);
                              }
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
        permissions: _selectedPermissions,
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

class UserFormScreen extends StatefulWidget {
  final User? user;

  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String? _selectedRoleId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _phoneController = TextEditingController(text: widget.user?.phone ?? '');
    _selectedRoleId = widget.user?.roleId;
    _isActive = widget.user?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserManagementProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.user != null ? 'Edit User' : 'Add User'),
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
                    children: [
                      CustomTextField(
                        label: 'Name',
                        controller: _nameController,
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Phone',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedRoleId,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(),
                        ),
                        items: provider.roles.map((role) {
                          return DropdownMenuItem(
                            value: role.id,
                            child: Text(role.name),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedRoleId = value),
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Active'),
                        value: _isActive,
                        onChanged: (value) => setState(() => _isActive = value),
                      ),
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
          onPressed: _saveUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Save User'),
        ),
      ),
    );
  }

  void _saveUser() {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = Provider.of<UserManagementProvider>(
        context,
        listen: false,
      );

      final user = User(
        id: widget.user?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        roleId: _selectedRoleId!,
        isActive: _isActive,
      );

      if (widget.user != null) {
        provider.updateUser(user);
      } else {
        provider.addUser(user);
      }

      Navigator.pop(context);
    }
  }
}
