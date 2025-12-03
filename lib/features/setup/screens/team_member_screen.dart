import 'package:flutter/material.dart';
import 'package:ui_specification/core/theme/app_dimensions.dart';
import 'package:ui_specification/core/utils/responsive.dart';
import 'package:ui_specification/core/widgets/custom_card.dart';
import 'package:ui_specification/core/widgets/custom_text_field.dart';
import 'package:ui_specification/core/utils/validators.dart';

/// Team Member screen - master data management
class TeamMemberScreen extends StatefulWidget {
  const TeamMemberScreen({super.key});

  @override
  State<TeamMemberScreen> createState() => _TeamMemberScreenState();
}

class _TeamMemberScreenState extends State<TeamMemberScreen> {
  // Mock data
  List<Map<String, dynamic>> mockTeamMembers = [
    {
      'id': '1',
      'name': 'Rahul Sharma',
      'category': 'Photographer',
      'phone': '+91 98765 43210',
      'email': 'rahul@example.com',
      'whatsapp': '+91 98765 43210',
      'status': 'active',
    },
    {
      'id': '2',
      'name': 'Priya Singh',
      'category': 'Decorator',
      'phone': '+91 98765 43211',
      'email': 'priya@example.com',
      'whatsapp': '+91 98765 43211',
      'status': 'active',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Members'),
        actions: [
          IconButton(icon: const Icon(Icons.search_outlined), onPressed: () {}),
          if (!Responsive.isMobile(context))
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing8,
              ),
              child: ElevatedButton.icon(
                onPressed: () => _showAddEditDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Team Member'),
              ),
            ),
        ],
      ),
      floatingActionButton: Responsive.isMobile(context)
          ? FloatingActionButton(
              onPressed: () => _showAddEditDialog(),
              child: const Icon(Icons.add),
            )
          : null,
      body: Responsive(
        mobile: _buildMobileList(),
        tablet: _buildDataTable(),
        desktop: _buildDataTable(),
      ),
    );
  }

  Widget _buildMobileList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.spacing8),
      itemCount: mockTeamMembers.length,
      itemBuilder: (context, index) {
        final member = mockTeamMembers[index];
        return CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 24, child: Text(member['name'][0])),
                  const SizedBox(width: AppDimensions.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacing4),
                        Text(
                          '${member['category']} - ${member['role'] ?? 'N/A'}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showAddEditDialog(member: member),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing8),
              const Divider(),
              const SizedBox(height: AppDimensions.spacing4),
              Text(
                'Mobile: ${member['mobile'] ?? member['phone']}',
                style: const TextStyle(fontSize: 12),
              ),
              if (member['whatsapp'] != null &&
                  member['whatsapp'] != member['mobile'])
                Text(
                  'WhatsApp: ${member['whatsapp']}',
                  style: const TextStyle(fontSize: 12),
                ),
              if (member['email'] != null)
                Text(
                  'Email: ${member['email']}',
                  style: const TextStyle(fontSize: 12),
                ),
              if (member['joiningDate'] != null)
                Text(
                  'Joined: ${DateTime.parse(member['joiningDate']).day}/${DateTime.parse(member['joiningDate']).month}/${DateTime.parse(member['joiningDate']).year}',
                  style: const TextStyle(fontSize: 12),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Card(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Avatar')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Phone')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: mockTeamMembers.map((member) {
            return DataRow(
              cells: [
                DataCell(
                  CircleAvatar(radius: 16, child: Text(member['name'][0])),
                ),
                DataCell(Text(member['name'])),
                DataCell(Text(member['category'])),
                DataCell(Text(member['phone'])),
                DataCell(Text(member['email'] ?? '')),
                DataCell(
                  Switch(
                    value: member['status'] == 'active',
                    onChanged: (value) {},
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => _showAddEditDialog(member: member),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outlined, size: 20),
                        onPressed: () {},
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAddEditDialog({Map<String, dynamic>? member}) {
    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController(
      text: member?['firstName'] ?? '',
    );
    final lastNameController = TextEditingController(
      text: member?['lastName'] ?? '',
    );
    final mobileController = TextEditingController(
      text: member?['mobile'] ?? '',
    );
    final whatsappController = TextEditingController(
      text: member?['whatsapp'] ?? '',
    );
    final emailController = TextEditingController(text: member?['email'] ?? '');
    final roleController = TextEditingController(text: member?['role'] ?? '');
    String selectedCategory = member?['category'] ?? 'Photographer';
    DateTime? joiningDate = member?['joiningDate'] != null
        ? DateTime.parse(member!['joiningDate'])
        : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(member == null ? 'Add Team Member' : 'Edit Team Member'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: firstNameController,
                          label: 'First Name',
                          validator: (value) =>
                              Validators.required(value, 'First Name'),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacing16),
                      Expanded(
                        child: CustomTextField(
                          controller: lastNameController,
                          label: 'Last Name',
                          validator: (value) =>
                              Validators.required(value, 'Last Name'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  CustomTextField(
                    controller: mobileController,
                    label: 'Mobile Number',
                    keyboardType: TextInputType.phone,
                    validator: Validators.phone,
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  CustomTextField(
                    controller: whatsappController,
                    label: 'WhatsApp Number',
                    keyboardType: TextInputType.phone,
                    validator: Validators.phone,
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  CustomTextField(
                    controller: emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Photographer', 'Videographer']
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedCategory = value;
                      }
                    },
                    validator: (value) =>
                        value == null ? 'Please select a category' : null,
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: joiningDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => joiningDate = date);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date of Joining',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        joiningDate != null
                            ? '${joiningDate!.day}/${joiningDate!.month}/${joiningDate!.year}'
                            : 'Select date',
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  CustomTextField(
                    controller: roleController,
                    label: 'Role',
                    validator: (value) => Validators.required(value, 'Role'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final teamMember = {
                    'id':
                        member?['id'] ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    'firstName': firstNameController.text,
                    'lastName': lastNameController.text,
                    'name':
                        '${firstNameController.text} ${lastNameController.text}'
                            .trim(),
                    'mobile': mobileController.text,
                    'whatsapp': whatsappController.text,
                    'email': emailController.text,
                    'category': selectedCategory,
                    'joiningDate': joiningDate?.toIso8601String(),
                    'role': roleController.text,
                    'status': 'active',
                  };

                  setState(() {
                    if (member != null) {
                      final index = mockTeamMembers.indexWhere(
                        (m) => m['id'] == member['id'],
                      );
                      if (index != -1) {
                        mockTeamMembers[index] = teamMember;
                      }
                    } else {
                      mockTeamMembers.add(teamMember);
                    }
                  });

                  Navigator.of(context).pop();
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
