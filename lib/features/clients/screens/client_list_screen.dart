import 'package:flutter/material.dart';
import 'package:ui_specification/models/client.dart';
import 'package:provider/provider.dart';
import 'package:ui_specification/core/constants/routes.dart';
import 'package:ui_specification/core/theme/app_colors.dart';
import 'package:ui_specification/core/theme/app_dimensions.dart';
import 'package:ui_specification/core/utils/responsive.dart';
import 'package:ui_specification/core/widgets/custom_card.dart';
import 'package:ui_specification/core/widgets/loading_indicator.dart';
import 'package:ui_specification/core/widgets/empty_state.dart';
import 'package:ui_specification/core/widgets/filter_bar.dart';
import 'package:ui_specification/core/widgets/pagination_controls.dart';
import 'package:ui_specification/features/clients/providers/client_provider.dart';

/// Client list screen
class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  int _currentPage = 1;
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientProvider>().loadClients();
    });
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Client> _getFilteredClients(List<Client> clients) {
    return clients.where((client) {
      final matchesSearch =
          client.fullName.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          client.whatsappNumber.contains(_searchController.text);

      // Add more filters as needed based on Client model
      final matchesFilter = _selectedFilter == 'All';

      return matchesSearch && matchesFilter;
    }).toList();
  }

  List<Client> _getPaginatedClients(List<Client> clients) {
    final startIndex = (_currentPage - 1) * _rowsPerPage;
    if (startIndex >= clients.length) return [];
    final endIndex = (startIndex + _rowsPerPage).clamp(0, clients.length);
    return clients.sublist(startIndex, endIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        actions: [
          if (!Responsive.isMobile(context))
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing8,
              ),
              child: ElevatedButton.icon(
                onPressed: () =>
                    Navigator.of(context).pushNamed(Routes.clientForm),
                icon: const Icon(Icons.add),
                label: const Text('Add Client'),
              ),
            ),
        ],
      ),
      floatingActionButton: Responsive.isMobile(context)
          ? FloatingActionButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(Routes.clientForm),
              child: const Icon(Icons.add),
            )
          : null,
      body: Consumer<ClientProvider>(
        builder: (context, clientProvider, child) {
          if (clientProvider.isLoading) {
            return const LoadingIndicator(message: 'Loading clients...');
          }

          final filteredClients = _getFilteredClients(clientProvider.clients);
          final paginatedClients = _getPaginatedClients(filteredClients);
          final totalPages = (filteredClients.length / _rowsPerPage).ceil();

          return Column(
            children: [
              FilterBar(
                searchController: _searchController,
                searchHint: 'Search clients...',
                filters: const [
                  'All',
                ], // Add more filters if Client model supports it
                selectedFilter: _selectedFilter,
                onFilterChanged: (filter) {
                  setState(() {
                    _selectedFilter = filter;
                    _currentPage = 1;
                  });
                },
                onDateRangePressed: () {},
                onClearSearch: () {
                  _searchController.clear();
                },
              ),
              Expanded(
                child: filteredClients.isEmpty
                    ? EmptyState(
                        icon: Icons.people_outline,
                        message: 'No clients found',
                        subtitle: 'Try adjusting your search or filters',
                        actionLabel: 'Add Client',
                        onActionPressed: () =>
                            Navigator.of(context).pushNamed(Routes.clientForm),
                      )
                    : _buildMobileList(paginatedClients),
              ),
              if (filteredClients.isNotEmpty)
                PaginationControls(
                  currentPage: _currentPage,
                  totalPages: totalPages,
                  rowsPerPage: _rowsPerPage,
                  totalItems: filteredClients.length,
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

  Widget _buildMobileList(List<Client> clients) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.spacing8),
      itemCount: clients.length,
      itemBuilder: (context, index) {
        final client = clients[index];
        return CustomCard(
          onTap: () => Navigator.of(
            context,
          ).pushNamed(Routes.clientDetails, arguments: client.id),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      client.fullName.isNotEmpty ? client.fullName[0] : '?',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacing4),
                        Row(
                          children: [
                            const Icon(
                              Icons.chat,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppDimensions.spacing4),
                            Text(
                              client.whatsappNumber,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing8),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Source: ${client.source}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    '${client.createdDate.day}/${client.createdDate.month}/${client.createdDate.year}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataTable(List<Client> clients) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Card(
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Avatar')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('WhatsApp')),
              DataColumn(label: Text('Source')),
              DataColumn(label: Text('Created By')),
              DataColumn(label: Text('Created Date')),
              DataColumn(label: Text('Actions')),
            ],
            rows: clients.map((client) {
              return DataRow(
                cells: [
                  DataCell(
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        client.fullName.isNotEmpty ? client.fullName[0] : '?',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 120,
                      child: Text(
                        client.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(Text(client.whatsappNumber)),
                  DataCell(
                    SizedBox(
                      width: 100,
                      child: Text(
                        client.source,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 100,
                      child: Text(
                        client.createdBy,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      '${client.createdDate.day}/${client.createdDate.month}/${client.createdDate.year}',
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility_outlined, size: 20),
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              Routes.clientDetails,
                              arguments: client.id,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              Routes.clientForm,
                              arguments: client.id,
                            );
                          },
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
}
