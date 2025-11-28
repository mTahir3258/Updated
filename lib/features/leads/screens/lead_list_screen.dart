import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui_specification/core/theme/app_colors.dart';
import 'package:ui_specification/core/theme/app_dimensions.dart';
import 'package:ui_specification/core/utils/responsive.dart';
import 'package:ui_specification/core/widgets/status_badge.dart';
import 'package:ui_specification/core/widgets/custom_card.dart';
import 'package:ui_specification/core/widgets/empty_state.dart';
import 'package:ui_specification/core/widgets/loading_indicator.dart';
import 'package:ui_specification/core/widgets/filter_bar.dart';
import 'package:ui_specification/core/widgets/pagination_controls.dart';
import 'package:ui_specification/features/leads/providers/lead_provider.dart';
import 'package:ui_specification/models/lead.dart';
import 'package:ui_specification/core/constants/routes.dart';

/// Lead list screen with responsive design
class LeadListScreen extends StatefulWidget {
  const LeadListScreen({super.key});

  @override
  State<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends State<LeadListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  int _currentPage = 1;
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeadProvider>().loadLeads();
    });
    _searchController.addListener(() {
      setState(() {}); // Rebuild to filter
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Lead> _getFilteredLeads(List<Lead> leads) {
    return leads.where((lead) {
      final matchesSearch =
          lead.fullName.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          lead.phone.contains(_searchController.text);

      final matchesFilter =
          _selectedFilter == 'All' ||
          lead.status.toLowerCase() == _selectedFilter.toLowerCase();

      return matchesSearch && matchesFilter;
    }).toList();
  }

  List<Lead> _getPaginatedLeads(List<Lead> leads) {
    final startIndex = (_currentPage - 1) * _rowsPerPage;
    if (startIndex >= leads.length) return [];
    final endIndex = (startIndex + _rowsPerPage).clamp(0, leads.length);
    return leads.sublist(startIndex, endIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leads'),
        actions: [
          if (!Responsive.isMobile(context))
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing8,
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.leadForm);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Lead'),
              ),
            ),
        ],
      ),
      floatingActionButton: Responsive.isMobile(context)
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushNamed(Routes.leadForm);
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: Consumer<LeadProvider>(
        builder: (context, leadProvider, child) {
          if (leadProvider.isLoading) {
            return const LoadingIndicator(message: 'Loading leads...');
          }

          final filteredLeads = _getFilteredLeads(leadProvider.leads);
          final paginatedLeads = _getPaginatedLeads(filteredLeads);
          final totalPages = (filteredLeads.length / _rowsPerPage).ceil();

          return Column(
            children: [
              FilterBar(
                searchController: _searchController,
                searchHint: 'Search leads...',
                filters: const [
                  'All',
                  'New',
                  'In Progress',
                  'Success',
                  'Failed',
                ],
                selectedFilter: _selectedFilter,
                onFilterChanged: (filter) {
                  setState(() {
                    _selectedFilter = filter;
                    _currentPage = 1; // Reset to first page
                  });
                },
                onDateRangePressed: () {
                  // TODO: Implement date range picker
                },
                onClearSearch: () {
                  _searchController.clear();
                },
              ),
              Expanded(
                child: filteredLeads.isEmpty
                    ? EmptyState(
                        icon: Icons.person_add_outlined,
                        message: 'No leads found',
                        subtitle: 'Try adjusting your search or filters',
                        actionLabel: 'Add Lead',
                        onActionPressed: () {
                          Navigator.of(context).pushNamed(Routes.leadForm);
                        },
                      )
                    : Responsive(
                        mobile: _buildMobileList(paginatedLeads),
                        tablet: _buildDataTable(paginatedLeads),
                        desktop: _buildDataTable(paginatedLeads),
                      ),
              ),
              if (filteredLeads.isNotEmpty)
                PaginationControls(
                  currentPage: _currentPage,
                  totalPages: totalPages,
                  rowsPerPage: _rowsPerPage,
                  totalItems: filteredLeads.length,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  onRowsPerPageChanged: (rows) {
                    setState(() {
                      _rowsPerPage = rows;
                      _currentPage = 1;
                    });
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileList(List<Lead> leads) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.spacing8),
      itemCount: leads.length,
      itemBuilder: (context, index) {
        final lead = leads[index];
        return CustomCard(
          onTap: () {
            Navigator.of(
              context,
            ).pushNamed(Routes.leadDetails, arguments: lead.id);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lead.fullName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  StatusBadge(
                    label: lead.status.toUpperCase(),
                    type: _getStatusType(lead.status),
                    small: true,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing8),
              Row(
                children: [
                  const Icon(
                    Icons.phone,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppDimensions.spacing4),
                  Text(
                    lead.phone,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing4),
              Row(
                children: [
                  const Icon(
                    Icons.source,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppDimensions.spacing4),
                  Text(
                    lead.source,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing8),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushNamed(Routes.leadDetails, arguments: lead.id);
                    },
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('View'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        Routes.leadForm,
                        arguments: lead,
                      );
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataTable(List<Lead> leads) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Card(
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Phone')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Source')),
              DataColumn(label: Text('Actions')),
            ],
            rows: leads.map((lead) {
              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 120,
                      child: Text(
                        lead.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(Text(lead.phone)),
                  DataCell(
                    SizedBox(
                      width: 150,
                      child: Text(
                        lead.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    StatusBadge(
                      label: lead.status.toUpperCase(),
                      type: _getStatusType(lead.status),
                      small: true,
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 100,
                      child: Text(
                        lead.source,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility_outlined, size: 20),
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pushNamed(Routes.leadDetails, arguments: lead.id);
                          },
                          tooltip: 'View',
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pushNamed(Routes.leadForm, arguments: lead);
                          },
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: const Icon(Icons.call_outlined, size: 20),
                          onPressed: () {},
                          tooltip: 'Call',
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  StatusType _getStatusType(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return StatusType.newStatus;
      case 'in_progress':
        return StatusType.inProgress;
      case 'success':
        return StatusType.success;
      case 'failed':
        return StatusType.failed;
      default:
        return StatusType.pending;
    }
  }
}
