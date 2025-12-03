import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ui_specification/core/theme/app_colors.dart';
import 'package:ui_specification/core/theme/app_dimensions.dart';
import 'package:ui_specification/core/widgets/custom_card.dart';
import 'package:ui_specification/core/widgets/status_badge.dart';
import 'package:ui_specification/core/widgets/empty_state.dart';
import 'package:ui_specification/core/widgets/loading_indicator.dart';
import 'package:ui_specification/features/quotations/providers/quotation_provider.dart';
import 'package:ui_specification/models/quotation.dart';
import 'package:ui_specification/core/widgets/filter_bar.dart';
import 'package:ui_specification/core/widgets/pagination_controls.dart';
import 'package:ui_specification/core/constants/routes.dart';
import 'package:ui_specification/core/utils/responsive.dart';

class QuotationListScreen extends StatefulWidget {
  const QuotationListScreen({super.key});

  @override
  State<QuotationListScreen> createState() => _QuotationListScreenState();
}

class _QuotationListScreenState extends State<QuotationListScreen> {
  // Filter & Pagination State
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  DateTimeRange? _selectedDateRange;
  int _currentPage = 1;
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuotationProvider>().loadQuotations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _currentPage = 1;
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedStatus = filter;
      _currentPage = 1;
    });
  }

  void _onDateRangeChanged() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _currentPage = 1;
      });
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _onRowsPerPageChanged(int rows) {
    setState(() {
      _rowsPerPage = rows;
      _currentPage = 1;
    });
  }

  List<Quotation> _getFilteredQuotations(List<Quotation> allQuotations) {
    return allQuotations.where((quotation) {
      // Search Filter
      final query = _searchController.text.toLowerCase();
      final matchesSearch =
          quotation.clientName.toLowerCase().contains(query) ||
          quotation.quotationNumber.toLowerCase().contains(query);

      // Status Filter
      final matchesStatus =
          _selectedStatus == 'All' ||
          quotation.status.name.toUpperCase() == _selectedStatus.toUpperCase();

      // Date Range Filter
      final matchesDate =
          _selectedDateRange == null ||
          (quotation.createdAt.isAfter(
                _selectedDateRange!.start.subtract(const Duration(days: 1)),
              ) &&
              quotation.createdAt.isBefore(
                _selectedDateRange!.end.add(const Duration(days: 1)),
              ));

      return matchesSearch && matchesStatus && matchesDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Consumer<QuotationProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const LoadingIndicator();
                }

                final filteredQuotations = _getFilteredQuotations(
                  provider.quotations,
                );
                final totalItems = filteredQuotations.length;
                final totalPages = (totalItems / _rowsPerPage).ceil();
                final startIndex = (_currentPage - 1) * _rowsPerPage;
                final endIndex = (startIndex + _rowsPerPage < totalItems)
                    ? startIndex + _rowsPerPage
                    : totalItems;
                final paginatedQuotations = filteredQuotations.isEmpty
                    ? <Quotation>[]
                    : filteredQuotations.sublist(startIndex, endIndex);

                return Column(
                  children: [
                    FilterBar(
                      searchController: _searchController,
                      filters: const [
                        'All',
                        'DRAFT',
                        'SENT',
                        'ACCEPTED',
                        'REJECTED',
                      ],
                      selectedFilter: _selectedStatus,
                      onFilterChanged: _onFilterChanged,
                      onDateRangePressed: _onDateRangeChanged,
                      onClearSearch: () {
                        _searchController.clear();
                        setState(() {
                          _currentPage = 1;
                        });
                      },
                    ),
                    Expanded(
                      child: filteredQuotations.isEmpty
                          ? const EmptyState(
                              icon: Icons.description_outlined,
                              message: 'No Quotations Found',
                              subtitle:
                                  'Try adjusting your search or create a new one.',
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(
                                AppDimensions.spacing16,
                              ),
                              itemCount: paginatedQuotations.length,
                              itemBuilder: (context, index) {
                                return _buildQuotationCard(
                                  paginatedQuotations[index],
                                );
                              },
                            ),
                    ),
                    if (filteredQuotations.isNotEmpty &&
                        !Responsive.isMobile(context))
                      PaginationControls(
                        currentPage: _currentPage,
                        totalPages: totalPages > 0 ? totalPages : 1,
                        rowsPerPage: _rowsPerPage,
                        totalItems: totalItems,
                        onPageChanged: _onPageChanged,
                        onRowsPerPageChanged: _onRowsPerPageChanged,
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, Routes.quotationForm);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('New Quotation'),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.yellow],
        ),
      ),
      padding: const EdgeInsets.only(
        top: 60, // Status bar padding
        left: AppDimensions.spacing16,
        right: AppDimensions.spacing16,
        bottom: AppDimensions.spacing16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quotations',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your proposals',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildQuotationCard(Quotation quotation) {
    return CustomCard(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.quotationDetails,
          arguments: quotation.id,
        );
      },
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  quotation.quotationNumber,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                StatusBadge(
                  label: quotation.status.name.toUpperCase(),
                  type: _getStatusType(quotation.status),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              quotation.clientName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.event, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${quotation.eventType} • ${DateFormat('MMM dd, yyyy').format(quotation.eventDate)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      NumberFormat.currency(
                        symbol: '₹',
                        decimalDigits: 0,
                      ).format(quotation.totalAmount),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Created ${DateFormat('MMM dd').format(quotation.createdAt)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  StatusType _getStatusType(QuotationStatus status) {
    switch (status) {
      case QuotationStatus.draft:
        return StatusType.pending;
      case QuotationStatus.sent:
        return StatusType.inProgress;
      case QuotationStatus.accepted:
        return StatusType.success;
      case QuotationStatus.rejected:
        return StatusType.failed;
    }
  }
}
