import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ui_specification/core/theme/app_colors.dart';
import 'package:ui_specification/core/theme/app_dimensions.dart';
import 'package:ui_specification/core/widgets/custom_text_field.dart';
import 'package:ui_specification/features/quotations/providers/quotation_provider.dart';
import 'package:ui_specification/models/quotation.dart';

class QuotationFormScreen extends StatefulWidget {
  final Quotation? quotation;

  const QuotationFormScreen({super.key, this.quotation});

  @override
  State<QuotationFormScreen> createState() => _QuotationFormScreenState();
}

class _QuotationFormScreenState extends State<QuotationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _clientNameController;
  late TextEditingController _eventTypeController;
  late DateTime _eventDate;
  List<QuotationItemEntry> _items = [];

  @override
  void initState() {
    super.initState();
    _clientNameController = TextEditingController(
      text: widget.quotation?.clientName ?? '',
    );
    _eventTypeController = TextEditingController(
      text: widget.quotation?.eventType ?? '',
    );
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
          TextButton(
            onPressed: _saveQuotation,
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
              CustomTextField(
                label: 'Client Name',
                controller: _clientNameController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                prefixIcon: const Icon(Icons.person_outline),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Event Type',
                controller: _eventTypeController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                prefixIcon: const Icon(Icons.event_note),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _eventDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  );
                  if (date != null) {
                    setState(() => _eventDate = date);
                  }
                },
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
            ]),
            const SizedBox(height: AppDimensions.spacing16),

            _buildSectionCard('Items', [
              ..._items.asMap().entries.map(
                (entry) => _buildItemRow(entry.key, entry.value),
              ),
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
                  flex: 3,
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
                  flex: 3,
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
        quotationNumber:
            widget.quotation?.quotationNumber ??
            'Q-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}',
        clientId: 'temp_client_id', // In real app, select from client list
        clientName: _clientNameController.text,
        eventType: _eventTypeController.text,
        eventDate: _eventDate,
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
