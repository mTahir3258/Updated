import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui_specification/core/theme/app_colors.dart';
import 'package:ui_specification/core/widgets/status_badge.dart';
import 'package:ui_specification/features/orders/providers/order_provider.dart';
import 'package:ui_specification/core/constants/routes.dart';
import 'package:intl/intl.dart';

/// Modern Order Details Screen
class OrderDetailScreen extends StatelessWidget {
  final String? orderId;

  const OrderDetailScreen({super.key, this.orderId});

  @override
  Widget build(BuildContext context) {
    final id =
        orderId ??
        (ModalRoute.of(context)!.settings.arguments as String? ?? '');
    final order = context.read<OrderProvider>().getOrderById(id);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Not Found')),
        body: const Center(child: Text('Order not found')),
      );
    }

    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(order.eventName),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, Routes.orderForm, arguments: order);
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(child: Text('Send Reminder')),
              const PopupMenuItem(child: Text('Cancel Order')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Order Summary Card
          _buildGradientCard(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.primaryLight,
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    StatusBadge(
                      label: order.status.toUpperCase(),
                      type: _getStatusBadge(order.status),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSummaryRow('Order ID', order.id),
                _buildSummaryRow('Client', order.clientName),
                _buildSummaryRow('Event Type', order.eventType),
                _buildSummaryRow(
                  'Event Date',
                  DateFormat('dd MMM yyyy').format(order.eventDate),
                ),
                _buildSummaryRow('Venue', order.venue),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Payment Card
          _buildModernCard(
            title: 'Payment Details',
            icon: Icons.payment,
            iconColor: _getPaymentColor(order.paymentStatus),
            child: Column(
              children: [
                // Payment Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Payment Progress'),
                        Text(
                          '${(order.paymentProgress * 100).toInt()}%',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: order.paymentProgress,
                        minHeight: 12,
                        backgroundColor: AppColors.surfaceDim,
                        valueColor: AlwaysStoppedAnimation(
                          _getPaymentColor(order.paymentStatus),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                _buildPaymentRow(
                  'Total Amount',
                  currencyFormat.format(order.totalAmount),
                ),
                _buildPaymentRow(
                  'Paid Amount',
                  currencyFormat.format(order.paidAmount),
                  color: AppColors.success,
                ),
                _buildPaymentRow(
                  'Pending Amount',
                  currencyFormat.format(order.remainingAmount),
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                StatusBadge(
                  label: order.paymentStatus.toUpperCase(),
                  type: _getPaymentStatusBadge(order.paymentStatus),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Services & Team Assignment
          _buildModernCard(
            title: 'Services & Team',
            icon: Icons.people_alt,
            iconColor: AppColors.secondary,
            child: order.services.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('No services assigned'),
                    ),
                  )
                : Column(
                    children: order.services
                        .map((service) => _buildServiceTile(service))
                        .toList(),
                  ),
          ),

          const SizedBox(height: 16),

          // Payment History
          _buildModernCard(
            title: 'Payment History',
            icon: Icons.history,
            iconColor: AppColors.success,
            child: order.payments.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('No payments received'),
                    ),
                  )
                : Column(
                    children: order.payments
                        .map(
                          (payment) =>
                              _buildPaymentHistoryTile(payment, currencyFormat),
                        )
                        .toList(),
                  ),
          ),

          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.success,
        icon: const Icon(Icons.payment),
        label: const Text('Add Payment'),
      ),
    );
  }

  Widget _buildGradientCard({
    required Gradient gradient,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }

  Widget _buildModernCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTile(service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDim,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.work, color: AppColors.secondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.serviceName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.person,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      service.teamMember,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              service.status.toUpperCase(),
              style: const TextStyle(
                color: AppColors.success,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryTile(payment, NumberFormat format) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.successLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  format.format(payment.amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy').format(payment.date),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              payment.method.toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      case 'completed':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getPaymentColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.success;
      case 'partial':
        return AppColors.warning;
      case 'pending':
      case 'overdue':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  StatusType _getStatusBadge(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return StatusType.success;
      case 'pending':
        return StatusType.pending;
      case 'cancelled':
        return StatusType.failed;
      case 'completed':
        return StatusType.success;
      default:
        return StatusType.newStatus;
    }
  }

  StatusType _getPaymentStatusBadge(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return StatusType.success;
      case 'partial':
        return StatusType.inProgress;
      case 'pending':
      case 'overdue':
        return StatusType.failed;
      default:
        return StatusType.newStatus;
    }
  }
}
