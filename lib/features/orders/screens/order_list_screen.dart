import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui_specification/core/theme/app_colors.dart';
import 'package:ui_specification/core/theme/app_dimensions.dart';
import 'package:ui_specification/core/utils/responsive.dart';
import 'package:ui_specification/core/widgets/custom_card.dart';
import 'package:ui_specification/core/widgets/status_badge.dart';
import 'package:ui_specification/core/widgets/pagination_controls.dart';
import 'package:ui_specification/core/widgets/loading_indicator.dart';
import 'package:ui_specification/core/widgets/empty_state.dart';
import 'package:ui_specification/core/constants/routes.dart';
import 'package:ui_specification/features/orders/providers/order_provider.dart';
import 'package:ui_specification/models/order.dart';
import 'package:intl/intl.dart';

/// Order list screen with tabs
class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentPage = 1;
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Unassigned'),
            Tab(text: 'Payment Due'),
            Tab(text: 'Completed'),
          ],
        ),
        actions: [
          if (!Responsive.isDesktop(context))
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing8,
                vertical: AppDimensions.spacing8,
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.orderForm);
                },
                icon: const Icon(Icons.add),
                label: const Text('New Order'),
              ),
            ),
        ],
      ),
      floatingActionButton: Responsive.isMobile(context)
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushNamed(Routes.orderForm);
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingIndicator(message: 'Loading orders...');
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrdersList(provider.orders),
              _buildOrdersList(provider.upcomingOrders),
              _buildOrdersList(provider.unassignedOrders),
              _buildOrdersList(provider.paymentDueOrders),
              _buildOrdersList(
                provider.orders.where((o) => o.status == 'completed').toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders) {
    if (orders.isEmpty) {
      return EmptyState(
        icon: Icons.shopping_cart_outlined,
        message: 'No orders found',
        subtitle: 'Orders will appear here once created',
        actionLabel: 'Create Order',
        onActionPressed: () =>
            Navigator.of(context).pushNamed(Routes.orderForm),
      );
    }

    final totalItems = orders.length;
    final totalPages = (totalItems / _rowsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage < totalItems)
        ? startIndex + _rowsPerPage
        : totalItems;

    // Ensure startIndex is valid
    if (startIndex >= totalItems && totalItems > 0) {
      // Reset to first page if current page is out of bounds
      // This can happen when switching tabs
      // Ideally we should manage page state per tab or reset on tab switch
      // For now, just show empty or handle gracefully
      // But better to reset _currentPage in build or listener
    }

    final paginatedOrders = (startIndex < totalItems)
        ? orders.sublist(startIndex, endIndex)
        : <Order>[];

    return Column(
      children: [
        Expanded(
          child: Responsive.isMobile(context)
              ? _buildMobileList(paginatedOrders)
              : _buildDataTable(paginatedOrders),
        ),
        if (orders.isNotEmpty)
          PaginationControls(
            currentPage: _currentPage,
            totalPages: totalPages > 0 ? totalPages : 1,
            rowsPerPage: _rowsPerPage,
            totalItems: totalItems,
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
  }

  Widget _buildMobileList(List<Order> orders) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.spacing8),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return CustomCard(
          onTap: () => Navigator.of(
            context,
          ).pushNamed(Routes.orderDetails, arguments: order.id),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.eventName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  StatusBadge(
                    label: order.status.toUpperCase(),
                    type: _getStatusType(order.status),
                    small: true,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing8),
              Row(
                children: [
                  const Icon(
                    Icons.people,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppDimensions.spacing4),
                  Text(order.clientName, style: const TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing4),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppDimensions.spacing4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(order.eventDate),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing4),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppDimensions.spacing4),
                  Expanded(
                    child: Text(
                      order.venue,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushNamed(Routes.orderDetails, arguments: order.id);
                    },
                    child: const Text('View Details'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataTable(List<Order> orders) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Card(
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Order ID')),
              DataColumn(label: Text('Client')),
              DataColumn(label: Text('Event')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Venue')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: orders.map((order) {
              return DataRow(
                cells: [
                  DataCell(Text(order.id)),
                  DataCell(
                    SizedBox(
                      width: 120,
                      child: Text(
                        order.clientName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 150,
                      child: Text(
                        order.eventName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(DateFormat('MMM dd, yyyy').format(order.eventDate)),
                  ),
                  DataCell(
                    SizedBox(
                      width: 120,
                      child: Text(
                        order.venue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    StatusBadge(
                      label: order.status.toUpperCase(),
                      type: _getStatusType(order.status),
                      small: true,
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
                              Routes.orderDetails,
                              arguments: order.id,
                            );
                          },
                          tooltip: 'View',
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pushNamed(Routes.orderForm, arguments: order);
                          },
                          tooltip: 'Edit',
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
      case 'confirmed':
        return StatusType.success;
      case 'pending':
        return StatusType.pending;
      case 'completed':
        return StatusType.success;
      case 'cancelled':
        return StatusType.failed;
      default:
        return StatusType.pending;
    }
  }
}
