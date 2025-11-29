import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui_specification/core/theme/app_colors.dart';
import 'package:ui_specification/core/theme/app_dimensions.dart';
import 'package:ui_specification/core/widgets/custom_text_field.dart';
import 'package:ui_specification/features/events/providers/event_provider.dart';
import 'package:ui_specification/models/event.dart';

class EventFormScreen extends StatefulWidget {
  final Event? event;

  const EventFormScreen({super.key, this.event});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _venueController;
  late TextEditingController _clientNameController;
  late TextEditingController _totalAmountController;
  late TextEditingController _paidAmountController;
  DateTime _selectedDate = DateTime.now();
  EventStatus _status = EventStatus.upcoming;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.event?.name ?? '');
    _typeController = TextEditingController(text: widget.event?.type ?? '');
    _venueController = TextEditingController(text: widget.event?.venue ?? '');
    _clientNameController = TextEditingController(
      text: widget.event?.clientName ?? '',
    );
    _totalAmountController = TextEditingController(
      text: widget.event?.totalAmount.toString() ?? '',
    );
    _paidAmountController = TextEditingController(
      text: widget.event?.paidAmount.toString() ?? '',
    );
    if (widget.event != null) {
      _selectedDate = widget.event!.date;
      _status = widget.event!.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _venueController.dispose();
    _clientNameController.dispose();
    _totalAmountController.dispose();
    _paidAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.event == null ? 'New Event' : 'Edit Event'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveEvent,
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
            _buildSectionCard('Event Details', [
              CustomTextField(
                label: 'Event Name',
                controller: _nameController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                prefixIcon: const Icon(Icons.event_outlined),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Event Type',
                controller: _typeController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                prefixIcon: const Icon(Icons.category_outlined),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Venue',
                controller: _venueController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Event Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: AppDimensions.spacing16),

            _buildSectionCard('Client & Financial Details', [
              CustomTextField(
                label: 'Client Name',
                controller: _clientNameController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                prefixIcon: const Icon(Icons.person_outlined),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Total Amount',
                      controller: _totalAmountController,
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                      prefixIcon: const Icon(Icons.attach_money_outlined),
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
              DropdownButtonFormField<EventStatus>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items: EventStatus.values
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.name.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _status = value);
                  }
                },
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

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveEvent() {
    if (_formKey.currentState?.validate() ?? false) {
      final event = Event(
        id:
            widget.event?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        type: _typeController.text,
        date: _selectedDate,
        venue: _venueController.text,
        clientId: widget.event?.clientId ?? 'CLT001', // Mock client ID
        clientName: _clientNameController.text,
        status: _status,
        totalAmount: double.tryParse(_totalAmountController.text) ?? 0.0,
        paidAmount: double.tryParse(_paidAmountController.text) ?? 0.0,
      );

      if (widget.event != null) {
        context.read<EventProvider>().updateEvent(event);
      } else {
        context.read<EventProvider>().addEvent(event);
      }

      Navigator.pop(context);
    }
  }
}
