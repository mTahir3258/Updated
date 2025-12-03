import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ui_specification/core/theme/app_colors.dart';
import 'package:ui_specification/core/theme/app_dimensions.dart';
import 'package:ui_specification/core/widgets/custom_text_field.dart';
import 'package:ui_specification/features/quotations/providers/quotation_provider.dart';
import 'package:ui_specification/features/clients/providers/client_provider.dart';
import 'package:ui_specification/features/leads/providers/lead_provider.dart';
import 'package:ui_specification/features/setup/providers/master_data_provider.dart';
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
  late TextEditingController _teamController;
  String? _selectedEventType;
  late DateTime _eventDate;
  List<QuotationItemEntry> _items = [];
  dynamic _selectedPerson; // Can be Client or Lead

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.quotation?.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.quotation?.lastName ?? '',
    );
    _teamController = TextEditingController(text: widget.quotation?.team ?? '');
    _selectedEventType = widget.quotation?.eventType;
    _eventDate =
        widget.quotation?.eventDate ??
        DateTime.now().add(const Duration(days: 7));

    if (widget.quotation != null) {
      _items = widget.quotation!.items
          .map(
            (item) => QuotationItemEntry(
              selectedPackageId: null, // TODO: find by name
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
    _teamController.dispose();
    for (var item in _items) {
      item.quantity.dispose();
      item.price.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(
        QuotationItemEntry(
          selectedPackageId: null,
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
              CustomTextField(
                label: 'Second Name',
                controller: _lastNameController,
                prefixIcon: const Icon(Icons.person_outline),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
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
              CustomTextField(
                label: 'Team',
                controller: _teamController,
                hint: 'Enter team members',
                prefixIcon: const Icon(Icons.group),
              ),
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
                  child: Consumer<MasterDataProvider>(
                    builder: (context, masterProvider, child) =>
                        DropdownButtonFormField<String>(
                          value: item.selectedPackageId,
                          decoration: const InputDecoration(
                            labelText: 'Package',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.inventory),
                          ),
                          validator: (v) => v == null ? 'Required' : null,
                          items: masterProvider.packages
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p.id,
                                  child: Text(p.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              item.selectedPackageId = value;
                              if (value != null) {
                                final selectedPackage = masterProvider.packages
                                    .firstWhere((p) => p.id == value);
                                item.price.text = selectedPackage.price
                                    .toString();
                              }
                            });
                          },
                        ),
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
              description: entry.selectedPackageId != null
                  ? context
                        .read<MasterDataProvider>()
                        .packages
                        .firstWhere((p) => p.id == entry.selectedPackageId)
                        .name
                  : 'Custom Item',
              quantity: int.parse(entry.quantity.text),
              unitPrice: double.parse(entry.price.text),
            ),
          )
          .toList();

      final quotation = Quotation(
        id:
            widget.quotation?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        quotationNumber:
            'Q-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}',
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
        eventType: _selectedEventType ?? '',
        eventDate: _eventDate,
        team: _teamController.text.isEmpty ? null : _teamController.text,
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
  String? selectedPackageId;
  final TextEditingController quantity;
  final TextEditingController price;

  QuotationItemEntry({
    this.selectedPackageId,
    required this.quantity,
    required this.price,
  });
}
