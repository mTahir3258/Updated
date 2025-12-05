import 'dart:io';
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
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ui_specification/models/lead.dart';
import 'package:ui_specification/models/order.dart';

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
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.picture_as_pdf,
                    color: AppColors.redColor,
                  ),
                  onPressed: () => _generateAndViewPdf(quotation),
                  tooltip: 'View PDF',
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: AppColors.primary),
                  onPressed: () => _sharePdf(quotation),
                  tooltip: 'Share PDF',
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

  Future<void> _generateAndViewPdf(Quotation quotation) async {
    final pdf = pw.Document();

    // Mock lead and order data - in real app, fetch from providers
    final mockLead = Lead.getMockLeads().firstWhere(
      (lead) => lead.id == quotation.clientId,
      orElse: () => Lead.getMockLeads().first,
    );
    final mockOrder = Order.generateMockList(5).firstWhere(
      (order) => order.clientId == quotation.clientId,
      orElse: () => Order.generateMockList(5).first,
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Text(
                'Quotation Details',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),

              // Quotation Info
              pw.Text(
                'Quotation Number: ${quotation.quotationNumber}',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.Text(
                'Client: ${quotation.clientName}',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.Text(
                'Event Type: ${quotation.eventType}',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.Text(
                'Event Date: ${DateFormat('MMM dd, yyyy').format(quotation.eventDate)}',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.Text(
                'Status: ${quotation.status.name.toUpperCase()}',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox(height: 20),

              // Items
              pw.Text(
                'Items:',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              ...quotation.items.map(
                (item) => pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${item.description} (x${item.quantity})'),
                    pw.Text('₹${item.unitPrice}'),
                  ],
                ),
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total Amount:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    '₹${quotation.totalAmount}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Lead Details
              pw.Text(
                'Lead Details:',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Name: ${mockLead.fullName}'),
              pw.Text('Email: ${mockLead.email}'),
              pw.Text('Phone: ${mockLead.phone}'),
              pw.Text('Status: ${mockLead.status}'),
              pw.Text('Source: ${mockLead.source}'),
              pw.SizedBox(height: 20),

              // Order Details
              pw.Text(
                'Order Details:',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Order ID: ${mockOrder.id}'),
              pw.Text('Event Name: ${mockOrder.eventName}'),
              pw.Text('Venue: ${mockOrder.venue}'),
              pw.Text('Status: ${mockOrder.status}'),
              pw.Text('Total Amount: ₹${mockOrder.totalAmount}'),
              pw.Text('Paid Amount: ₹${mockOrder.paidAmount}'),
              pw.SizedBox(height: 20),

              // Assigned Team
              pw.Text(
                'Assigned Team:',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              if (quotation.team != null) pw.Text('Team: ${quotation.team}'),
              pw.Text('Number of Teams: ${mockOrder.services.length}'),
              ...mockOrder.services.map(
                (service) => pw.Text(
                  '${service.serviceName}: ${service.teamMember ?? 'Unassigned'} (${service.persons ?? 0} persons)',
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _sharePdf(Quotation quotation) async {
    final pdf = pw.Document();

    // Same content as above
    final mockLead = Lead.getMockLeads().firstWhere(
      (lead) => lead.id == quotation.clientId,
      orElse: () => Lead.getMockLeads().first,
    );
    final mockOrder = Order.generateMockList(5).firstWhere(
      (order) => order.clientId == quotation.clientId,
      orElse: () => Order.generateMockList(5).first,
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Quotation Details',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Quotation Number: ${quotation.quotationNumber}'),
              pw.Text('Client: ${quotation.clientName}'),
              pw.Text('Event Type: ${quotation.eventType}'),
              pw.Text(
                'Event Date: ${DateFormat('MMM dd, yyyy').format(quotation.eventDate)}',
              ),
              pw.Text('Status: ${quotation.status.name.toUpperCase()}'),
              pw.SizedBox(height: 20),
              pw.Text(
                'Items:',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              ...quotation.items.map(
                (item) => pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${item.description} (x${item.quantity})'),
                    pw.Text('₹${item.unitPrice}'),
                  ],
                ),
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total Amount:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    '₹${quotation.totalAmount}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Lead Details:',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Name: ${mockLead.fullName}'),
              pw.Text('Email: ${mockLead.email}'),
              pw.Text('Phone: ${mockLead.phone}'),
              pw.Text('Status: ${mockLead.status}'),
              pw.Text('Source: ${mockLead.source}'),
              pw.SizedBox(height: 20),
              pw.Text(
                'Order Details:',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Order ID: ${mockOrder.id}'),
              pw.Text('Event Name: ${mockOrder.eventName}'),
              pw.Text('Venue: ${mockOrder.venue}'),
              pw.Text('Status: ${mockOrder.status}'),
              pw.Text('Total Amount: ₹${mockOrder.totalAmount}'),
              pw.Text('Paid Amount: ₹${mockOrder.paidAmount}'),
              pw.SizedBox(height: 20),
              pw.Text(
                'Assigned Team:',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              if (quotation.team != null) pw.Text('Team: ${quotation.team}'),
              pw.Text('Number of Teams: ${mockOrder.services.length}'),
              ...mockOrder.services.map(
                (service) => pw.Text(
                  '${service.serviceName}: ${service.teamMember ?? 'Unassigned'} (${service.persons ?? 0} persons)',
                ),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    final tempDir = await getTemporaryDirectory();
    final file = File(
      '${tempDir.path}/quotation_${quotation.quotationNumber}.pdf',
    );
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Quotation ${quotation.quotationNumber}');
  }
}
