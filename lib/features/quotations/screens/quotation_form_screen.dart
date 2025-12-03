import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ui_specification/core/theme/app_colors.dart';
import 'package:ui_specification/core/theme/app_dimensions.dart';
import 'package:ui_specification/core/widgets/custom_text_field.dart';
import 'package:ui_specification/features/quotations/providers/quotation_provider.dart';
import 'package:ui_specification/features/clients/providers/client_provider.dart';
import 'package:ui_specification/features/leads/providers/lead_provider.dart';
import 'package:ui_specification/models/quotation.dart';
import 'package:ui_specification/models/client.dart';
import 'package:ui_specification/models/lead.dart';

class QuotationFormScreen extends StatefulWidget {
  final Quotation? quotation;

  const QuotationFormScreen({super.key, this.quotation});

  @override
  State<QuotationFormScreen> createState() => _QuotationFormScreenState();
}

class _QuotationFormScreenState extends State<QuotationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _eventNameController;
  late TextEditingController _quotationNumberController;
  String? _selectedEventType;
  late DateTime _eventDate;
  List<QuotationItemEntry> _items = [];
  dynamic _selectedPerson; // Can be Client or Lead
  List<Map<String, dynamic>> _selectedTeamMembers = [];
  List<Map<String, dynamic>> _mockTeamMembers = [
    {
      'id': '1',
      'name': 'Rahul Sharma',
      'category': 'Photographer',
      'phone': '+91 98765 43210',
      'email': 'rahul@example.com',
      'status': 'active',
    },
    {
      'id': '2',
      'name': 'Priya Singh',
      'category': 'Photographer',
      'phone': '+91 98765 43211',
      'email': 'priya@example.com',
      'status': 'active',
    },
    {
      'id': '3',
      'name': 'Vikram Patel',
      'category': 'Videographer',
      'phone': '+91 98765 43212',
      'email': 'vikram@example.com',
      'status': 'active',
    },
  ];

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.quotation?.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.quotation?.lastName ?? '',
    );
    _eventNameController = TextEditingController(
      text: widget.quotation?.eventName ?? '',
    );
    _quotationNumberController = TextEditingController(
      text: widget.quotation?.quotationNumber ?? '',
    );
    _selectedEventType = widget.quotation?.eventType;
    _eventDate =
        widget.quotation?.eventDate ??
        DateTime.now().add(const Duration(days: 7));

    if (widget.quotation != null) {
      _items = widget.quotation!.items
          .map(
            (item) => QuotationItemEntry(
              description: TextEditingController(text: item.description),
              quantity: TextEditingController(text: item.quantity.toString()),
              price: TextEditingController(text: item.unitPrice.toString()),
            ),
          )
          .toList();
    } else {
      _addItem();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _eventNameController.dispose();
    _quotationNumberController.dispose();
    for (var item in _items) {
      item.description.dispose();
      item.quantity.dispose();
      item.price.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(
        QuotationItemEntry(
          description: TextEditingController(),
          quantity: TextEditingController(text: '1'),
          price: TextEditingController(text: '0'),
        ),
      );
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _selectEventDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null) {
      setState(() => _eventDate = date);
    }
  }

  double get _totalAmount {
    return _items.fold(0, (sum, item) {
      final qty = int.tryParse(item.quantity.text) ?? 0;
      final price = double.tryParse(item.price.text) ?? 0;
      return sum + (qty * price);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.quotation == null ? 'New Quotation' : 'Edit Quotation',
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          ElevatedButton(
            onPressed: _saveQuotation,
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
            _buildSectionCard('Client Details', [
              Builder(
                builder: (context) {
                  final clients = Client.generateMockList(5);
                  final leads = Lead.getMockLeads();

                  // Combine clients and leads into one list
                  final combinedPersons = [
                    ...clients.map((c) => {'type': 'client', 'person': c}),
                    ...leads.map((l) => {'type': 'lead', 'person': l}),
                  ];

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<Map<String, dynamic>>(
                              value: null,
                              decoration: const InputDecoration(
                                labelText: 'Select Client/Lead',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              items: combinedPersons.map((personMap) {
                                final person = personMap['person'];
                                final type = personMap['type'];
                                final displayName = type == 'client'
                                    ? 'Client: ${(person as Client).fullName}'
                                    : 'Lead: ${(person as Lead).fullName}';
                                return DropdownMenuItem<Map<String, dynamic>>(
                                  value: personMap,
                                  child: Text(displayName),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedPerson = value?['person'];
                                  if (_selectedPerson != null) {
                                    if (_selectedPerson is Client) {
                                      _firstNameController.text =
                                          (_selectedPerson as Client).firstName;
                                      _lastNameController.text =
                                          (_selectedPerson as Client).lastName;
                                    } else if (_selectedPerson is Lead) {
                                      _firstNameController.text =
                                          (_selectedPerson as Lead).firstName;
                                      _lastNameController.text =
                                          (_selectedPerson as Lead).lastName;
                                    }
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              label: 'First Name',
                              controller: _firstNameController,
                              prefixIcon: const Icon(Icons.person_outline),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Last Name',
                      controller: _lastNameController,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: 'Event Name',
                      controller: _eventNameController,
                      prefixIcon: const Icon(Icons.event_outlined),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedEventType,
                      decoration: const InputDecoration(
                        labelText: 'Event Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.event_note),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                      items: const [
                        DropdownMenuItem(
                          value: 'Wedding Photography',
                          child: Text('Wedding Photography'),
                        ),
                        DropdownMenuItem(
                          value: 'Portrait Session',
                          child: Text('Portrait Session'),
                        ),
                        DropdownMenuItem(
                          value: 'Corporate Event',
                          child: Text('Corporate Event'),
                        ),
                        DropdownMenuItem(
                          value: 'Engagement Shoot',
                          child: Text('Engagement Shoot'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedEventType = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: 'Quotation Number',
                      controller: _quotationNumberController,
                      prefixIcon: const Icon(Icons.receipt_long),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectEventDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('MMM dd, yyyy').format(_eventDate),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Team Member Selection Section
              const SizedBox(height: AppDimensions.spacing16),
              _buildSectionCard('Team Assignment', [
                Text(
                  'Select Team Members for Quotation',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ..._mockTeamMembers.map((member) {
                  final isSelected = _selectedTeamMembers.any(
                    (m) => m['id'] == member['id'],
                  );
                  return CheckboxListTile(
                    title: Text('${member['name']} (${member['category']})'),
                    subtitle: Text('${member['phone']} | ${member['email']}'),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedTeamMembers.add(member);
                        } else {
                          _selectedTeamMembers.removeWhere(
                            (m) => m['id'] == member['id'],
                          );
                        }
                      });
                    },
                  );
                }).toList(),
                if (_selectedTeamMembers.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Selected Team: ${_selectedTeamMembers.map((m) => m['name']).join(", ")}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ]),
            ]),
            const SizedBox(height: AppDimensions.spacing16),

            _buildSectionCard('Items', [
              ..._items
                  .asMap()
                  .entries
                  .map((entry) => _buildItemRow(entry.key, entry.value))
                  .toList(),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
            ]),
            const SizedBox(height: AppDimensions.spacing16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    NumberFormat.currency(symbol: '₹').format(_totalAmount),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
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

  Widget _buildItemRow(int index, QuotationItemEntry item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Description',
                    controller: item.description,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removeItem(index),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    label: 'Quantity',
                    controller: item.quantity,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    label: 'Unit Price',
                    controller: item.price,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.currency_rupee),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.centerRight,
                    child: Text(
                      NumberFormat.compactCurrency(symbol: '₹').format(
                        (int.tryParse(item.quantity.text) ?? 0) *
                            (double.tryParse(item.price.text) ?? 0),
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveQuotation() {
    if (_formKey.currentState?.validate() ?? false) {
      final items = _items
          .map(
            (entry) => QuotationItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              description: entry.description.text,
              quantity: int.parse(entry.quantity.text),
              unitPrice: double.parse(entry.price.text),
            ),
          )
          .toList();

      final quotation = Quotation(
        id:
            widget.quotation?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        quotationNumber: _quotationNumberController.text.isEmpty
            ? 'Q-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}'
            : _quotationNumberController.text,
        clientId: _selectedPerson is Client
            ? _selectedPerson.id
            : 'temp_client_id',
        clientName: _selectedPerson is Client
            ? _selectedPerson.fullName
            : '${_firstNameController.text} ${_lastNameController.text}'.trim(),
        firstName: _firstNameController.text.isEmpty
            ? null
            : _firstNameController.text,
        lastName: _lastNameController.text.isEmpty
            ? null
            : _lastNameController.text,
        eventName: _eventNameController.text.isEmpty
            ? null
            : _eventNameController.text,
        eventType: _selectedEventType ?? '',
        eventDate: _eventDate,
        team: _selectedTeamMembers.isEmpty
            ? null
            : _selectedTeamMembers.map((m) => m['name']).join(", "),
        items: items,
        status: widget.quotation?.status ?? QuotationStatus.draft,
        createdAt: widget.quotation?.createdAt ?? DateTime.now(),
      );

      if (widget.quotation != null) {
        context.read<QuotationProvider>().updateQuotation(quotation);
      } else {
        context.read<QuotationProvider>().addQuotation(quotation);
      }

      Navigator.pop(context);
    }
  }
}

class QuotationItemEntry {
  final TextEditingController description;
  final TextEditingController quantity;
  final TextEditingController price;

  QuotationItemEntry({
    required this.description,
    required this.quantity,
    required this.price,
  });
}
