import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui_specification/core/theme/app_colors.dart';
import 'package:ui_specification/core/theme/app_dimensions.dart';
import 'package:ui_specification/core/widgets/custom_card.dart';
import 'package:ui_specification/features/leads/providers/lead_provider.dart';
import 'package:ui_specification/models/lead.dart';

class IncompleteLeadsScreen extends StatefulWidget {
  const IncompleteLeadsScreen({super.key});

  @override
  State<IncompleteLeadsScreen> createState() => _IncompleteLeadsScreenState();
}

class _IncompleteLeadsScreenState extends State<IncompleteLeadsScreen> {
  final Set<String> _selectedFilters = {'All'};

  final List<String> _filterOptions = [
    'All',
    'Missing Phone',
    'Missing Email',
    'Missing Address',
    'Missing Source',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<LeadProvider>(
      builder: (context, provider, child) {
        // Mock filtering logic (since we don't have backend support yet)
        // In a real app, this would be handled by the provider or API
        final incompleteLeads = provider.leads.where((lead) {
          // Check for missing fields
          final missingPhone = lead.phone.isEmpty;
          final missingEmail = lead.email.isEmpty;
          // final missingAddress = lead.address.isEmpty; // Assuming address exists
          // final missingSource = lead.sourceId.isEmpty;

          if (_selectedFilters.contains('All')) {
            return missingPhone ||
                missingEmail; // || missingAddress || missingSource;
          }

          bool matches = false;
          if (_selectedFilters.contains('Missing Phone') && missingPhone)
            matches = true;
          if (_selectedFilters.contains('Missing Email') && missingEmail)
            matches = true;
          // ... other checks

          return matches;
        }).toList();

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('Incomplete Leads'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            actions: [
              if (incompleteLeads.isNotEmpty)
                IconButton(
                  icon: const Icon(
                    Icons.delete_sweep_outlined,
                    color: AppColors.error,
                  ),
                  onPressed: () {
                    // TODO: Bulk delete action
                  },
                ),
            ],
          ),
          body: Column(
            children: [
              _buildFilterChips(),
              Expanded(
                child: incompleteLeads.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppDimensions.spacing16),
                        itemCount: incompleteLeads.length,
                        itemBuilder: (context, index) {
                          return _buildLeadCard(
                            context,
                            incompleteLeads[index],
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing16,
        vertical: AppDimensions.spacing8,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filterOptions.map((filter) {
            final isSelected = _selectedFilters.contains(filter);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (filter == 'All') {
                      _selectedFilters.clear();
                      _selectedFilters.add('All');
                    } else {
                      _selectedFilters.remove('All');
                      if (selected) {
                        _selectedFilters.add(filter);
                      } else {
                        _selectedFilters.remove(filter);
                        if (_selectedFilters.isEmpty) {
                          _selectedFilters.add('All');
                        }
                      }
                    }
                  });
                },
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLeadCard(BuildContext context, Lead lead) {
    // Identify missing fields for display
    final missingFields = <String>[];
    if (lead.phone.isEmpty) missingFields.add('Phone');
    if (lead.email.isEmpty) missingFields.add('Email');
    // if (lead.address.isEmpty) missingFields.add('Address');

    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing12),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${lead.firstName} ${lead.lastName}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Incomplete',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: missingFields.map((field) {
                return Chip(
                  label: Text('Missing $field'),
                  labelStyle: const TextStyle(
                    fontSize: 10,
                    color: AppColors.error,
                  ),
                  backgroundColor: AppColors.error.withOpacity(0.05),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Complete Profile'),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/leads/${lead.id}', // Navigate to detail/edit
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.success,
          ),
          const SizedBox(height: 16),
          Text(
            'All leads are complete!',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Great job maintaining data quality.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
