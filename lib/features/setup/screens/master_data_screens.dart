import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui_specification/core/widgets/generic_master_data_screen.dart';
import 'package:ui_specification/features/setup/providers/master_data_provider.dart';
import 'package:ui_specification/models/master_data.dart';

class LeadSourceScreen extends StatelessWidget {
  const LeadSourceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MasterDataProvider>(
      builder: (context, provider, child) {
        return GenericMasterDataScreen<LeadSource>(
          title: 'Lead Sources',
          items: provider.leadSources,
          getName: (item) => item.name,
          onAdd: (name) => provider.addLeadSource(name),
          onEdit: (item, name) => provider.updateLeadSource(item, name),
          onDelete: (item) => provider.deleteLeadSource(item),
        );
      },
    );
  }
}

class EventTypeScreen extends StatelessWidget {
  const EventTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MasterDataProvider>(
      builder: (context, provider, child) {
        return GenericMasterDataScreen<EventType>(
          title: 'Event Types',
          items: provider.eventTypes,
          getName: (item) => item.name,
          onAdd: (name) => provider.addEventType(name),
          onEdit: (item, name) => provider.updateEventType(item, name),
          onDelete: (item) => provider.deleteEventType(item),
        );
      },
    );
  }
}

class TeamCategoryScreen extends StatelessWidget {
  const TeamCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MasterDataProvider>(
      builder: (context, provider, child) {
        return GenericMasterDataScreen<TeamCategory>(
          title: 'Team Categories',
          items: provider.teamCategories,
          getName: (item) => item.name,
          onAdd: (name) => provider.addTeamCategory(name),
          onEdit: (item, name) => provider.updateTeamCategory(item, name),
          onDelete: (item) => provider.deleteTeamCategory(item),
        );
      },
    );
  }
}

class ServiceScreen extends StatelessWidget {
  const ServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MasterDataProvider>(
      builder: (context, provider, child) {
        return GenericMasterDataScreen<Service>(
          title: 'Services',
          items: provider.services,
          getName: (item) => item.name,
          onAdd: (name) => provider.addService(name),
          onEdit: (item, name) => provider.updateService(item, name),
          onDelete: (item) => provider.deleteService(item),
        );
      },
    );
  }
}

class SubServiceScreen extends StatefulWidget {
  const SubServiceScreen({super.key});

  @override
  State<SubServiceScreen> createState() => _SubServiceScreenState();
}

class _SubServiceScreenState extends State<SubServiceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<MasterDataProvider>(
      builder: (context, provider, child) {
        final filteredItems = provider.subServices
            .where(
              (item) =>
                  item.name.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

        return Scaffold(
          backgroundColor: Colors.grey[50], // AppColors.background
          appBar: AppBar(
            title: const Text('Sub Services'),
            backgroundColor: Colors.white, // AppColors.surface
            foregroundColor: Colors.black, // AppColors.textPrimary
            elevation: 0,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16), // AppDimensions.spacing16
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Sub Services...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white, // AppColors.surface
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              Expanded(
                child: filteredItems.isEmpty
                    ? const Center(
                        child: Text('No Sub Services Found'),
                      ) // Placeholder for EmptyState
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          final parentService = provider.services.firstWhere(
                            (s) => s.id == item.serviceId,
                            orElse: () => Service(id: '', name: 'Unknown'),
                          );

                          return Card(
                            // CustomCard placeholder
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(parentService.name),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: Colors.blue,
                                    ), // AppColors.primary
                                    onPressed: () => _showFormDialog(
                                      context,
                                      provider,
                                      item: item,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        provider.deleteSubService(item),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showFormDialog(context, provider),
            backgroundColor: Colors.blue, // AppColors.primary
            icon: const Icon(Icons.add),
            label: const Text('Add Sub Service'),
          ),
        );
      },
    );
  }

  void _showFormDialog(
    BuildContext context,
    MasterDataProvider provider, {
    SubService? item,
  }) {
    final nameController = TextEditingController(text: item?.name ?? '');
    String? selectedServiceId =
        item?.serviceId ??
        (provider.services.isNotEmpty ? provider.services.first.id : null);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(item != null ? 'Edit Sub Service' : 'Add Sub Service'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedServiceId,
                  decoration: const InputDecoration(
                    labelText: 'Parent Service',
                  ),
                  items: provider.services
                      .map(
                        (s) =>
                            DropdownMenuItem(value: s.id, child: Text(s.name)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedServiceId = value),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  // CustomTextField placeholder
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  autofocus: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  if (item != null) {
                    provider.updateSubService(
                      item,
                      selectedServiceId!,
                      nameController.text,
                    );
                  } else {
                    provider.addSubService(
                      selectedServiceId!,
                      nameController.text,
                    );
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminNotificationScreen extends StatelessWidget {
  const AdminNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MasterDataProvider>(
      builder: (context, provider, child) {
        return GenericMasterDataScreen<AdminNotification>(
          title: 'Admin Notifications',
          items: provider.adminNotifications,
          getName: (item) => '${item.name} (${item.number})',
          onAdd: (name) => provider.addAdminNotification(
            name,
            '',
          ), // Simplified for generic, might need custom
          onEdit: (item, name) =>
              provider.updateAdminNotification(item, name, item.number),
          onDelete: (item) => provider.deleteAdminNotification(item),
          // Note: Status switch would be added here if we had a custom form builder
        );
      },
    );
  }
}

class NotificationTemplateScreen extends StatelessWidget {
  const NotificationTemplateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MasterDataProvider>(
      builder: (context, provider, child) {
        return GenericMasterDataScreen<NotificationTemplate>(
          title: 'Notification Templates',
          items: provider.notificationTemplates,
          getName: (item) => item.name,
          onAdd: (name) =>
              provider.addNotificationTemplate(name, ''), // Simplified
          onEdit: (item, name) =>
              provider.updateNotificationTemplate(item, name, item.content),
          onDelete: (item) => provider.deleteNotificationTemplate(item),
          // Note: In a real app, we would override the form builder here to include
          // Type (Dropdown), Trigger (Dropdown), Subject, and Variables support.
          // Since GenericMasterDataScreen is limited, we'd need to refactor it or
          // create a custom screen like PackageScreen.
          // For this demo, we acknowledge the limitation.
        );
      },
    );
  }
}

class PackageScreen extends StatefulWidget {
  const PackageScreen({super.key});

  @override
  State<PackageScreen> createState() => _PackageScreenState();
}

class _PackageScreenState extends State<PackageScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<MasterDataProvider>(
      builder: (context, provider, child) {
        final filteredItems = provider.packages
            .where(
              (item) =>
                  item.name.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('Packages'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Packages...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              Expanded(
                child: filteredItems.isEmpty
                    ? const Center(child: Text('No Packages Found'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(item.description),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '\$${item.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () => _showFormDialog(
                                      context,
                                      provider,
                                      item: item,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        provider.deletePackage(item),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showFormDialog(context, provider),
            backgroundColor: Colors.blue,
            icon: const Icon(Icons.add),
            label: const Text('Add Package'),
          ),
        );
      },
    );
  }

  void _showFormDialog(
    BuildContext context,
    MasterDataProvider provider, {
    Package? item,
  }) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final priceController = TextEditingController(
      text: item?.price.toString() ?? '',
    );
    final descController = TextEditingController(text: item?.description ?? '');
    final durationController = TextEditingController(); // Add duration
    final termsController = TextEditingController(); // Add terms
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item != null ? 'Edit Package' : 'Add Package'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (e.g. 4 hours)',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: termsController,
                decoration: const InputDecoration(
                  labelText: 'Terms & Conditions',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // Placeholder for Image Picker
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, color: Colors.grey),
                      Text(
                        'Add Display Image',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final price = double.tryParse(priceController.text) ?? 0.0;
                if (item != null) {
                  provider.updatePackage(
                    item,
                    nameController.text,
                    price,
                    descController.text,
                  );
                } else {
                  provider.addPackage(
                    nameController.text,
                    price,
                    descController.text,
                  );
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
