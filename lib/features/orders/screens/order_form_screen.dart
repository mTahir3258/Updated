import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui_specification/core/theme/app_colors.dart';
import 'package:ui_specification/core/theme/app_dimensions.dart';
import 'package:ui_specification/core/widgets/custom_text_field.dart';
import 'package:ui_specification/features/orders/providers/order_provider.dart';
import 'package:ui_specification/models/order.dart';

class OrderFormScreen extends StatefulWidget {
  final Order? order;

  const OrderFormScreen({super.key, this.order});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _clientNameController;
  late TextEditingController _clientIdController;
  late TextEditingController _eventNameController;
  late TextEditingController _eventTypeController;
  late TextEditingController _venueController;
  late TextEditingController _totalAmountController;
  late TextEditingController _paidAmountController;
  late TextEditingController _notesController;

  DateTime? _eventDate;
  String _status = 'pending';
  String _paymentStatus = 'pending';

  @override
  void initState() {
    super.initState();
    _clientNameController = TextEditingController(
      text: widget.order?.clientName ?? '',
    );
    _clientIdController = TextEditingController(
      text: widget.order?.clientId ?? '',
    );
    _eventNameController = TextEditingController(
      text: widget.order?.eventName ?? '',
    );
    _eventTypeController = TextEditingController(
      text: widget.order?.eventType ?? '',
    );
    _venueController = TextEditingController(text: widget.order?.venue ?? '');
    _totalAmountController = TextEditingController(
      text: widget.order?.totalAmount.toString() ?? '',
    );
    _paidAmountController = TextEditingController(
      text: widget.order?.paidAmount.toString() ?? '',
    );
    _notesController = TextEditingController(text: widget.order?.notes ?? '');

    _eventDate = widget.order?.eventDate;
    if (widget.order != null) {
      _status = widget.order!.status;
      _paymentStatus = widget.order!.paymentStatus;
    }
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientIdController.dispose();
    _eventNameController.dispose();
    _eventTypeController.dispose();
    _venueController.dispose();
    _totalAmountController.dispose();
    _paidAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.order == null ? 'New Order' : 'Edit Order'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveOrder,
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
            _buildSectionTitle('Client Details'),
            CustomTextField(
              label: 'Client Name',
              controller: _clientNameController,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              prefixIcon: const Icon(Icons.person_outline),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Client ID',
              controller: _clientIdController,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              prefixIcon: const Icon(Icons.badge_outlined),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Event Details'),
            CustomTextField(
              label: 'Event Name',
              controller: _eventNameController,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              prefixIcon: const Icon(Icons.event_outlined),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Event Type',
              controller: _eventTypeController,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              prefixIcon: const Icon(Icons.category_outlined),
              hint: 'e.g., Wedding, Birthday, Corporate',
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectEventDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Event Date',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  errorText: _eventDate == null ? 'Required' : null,
                ),
                child: Text(
                  _eventDate == null
                      ? 'Select date'
                      : '${_eventDate!.day}/${_eventDate!.month}/${_eventDate!.year}',
                  style: TextStyle(
                    color: _eventDate == null
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Venue',
              controller: _venueController,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              prefixIcon: const Icon(Icons.location_on_outlined),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Order Status'),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Order Status',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: ['confirmed', 'pending', 'cancelled', 'completed']
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(s.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _status = value);
                }
              },
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Payment Details'),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Total Amount',
                    controller: _totalAmountController,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                    prefixIcon: const Icon(Icons.currency_rupee),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    label: 'Paid Amount',
                    controller: _paidAmountController,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                    prefixIcon: const Icon(Icons.payment_outlined),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _paymentStatus,
              decoration: const InputDecoration(
                labelText: 'Payment Status',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
              items: ['paid', 'partial', 'pending', 'overdue']
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(s.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _paymentStatus = value);
                }
              },
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Additional Notes'),
            CustomTextField(
              label: 'Notes',
              controller: _notesController,
              maxLines: 3,
              prefixIcon: const Icon(Icons.note_outlined),
              hint: 'Optional notes about the order',
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

  Future<void> _selectEventDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null && picked != _eventDate) {
      setState(() {
        _eventDate = picked;
      });
    }
  }

  void _saveOrder() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_eventDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an event date'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final totalAmount = double.tryParse(_totalAmountController.text) ?? 0.0;
      final paidAmount = double.tryParse(_paidAmountController.text) ?? 0.0;

      final order = Order(
        id:
            widget.order?.id ??
            'ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        clientName: _clientNameController.text,
        clientId: _clientIdController.text,
        eventName: _eventNameController.text,
        eventType: _eventTypeController.text,
        eventDate: _eventDate!,
        venue: _venueController.text,
        status: _status,
        paymentStatus: _paymentStatus,
        totalAmount: totalAmount,
        paidAmount: paidAmount,
        services: widget.order?.services ?? [],
        payments: widget.order?.payments ?? [],
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        createdDate: widget.order?.createdDate ?? DateTime.now(),
      );

      if (widget.order != null) {
        context.read<OrderProvider>().updateOrder(order);
      } else {
        context.read<OrderProvider>().addOrder(order);
      }

      Navigator.pop(context);
    }
  }
}
