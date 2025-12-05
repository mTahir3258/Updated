import 'package:flutter/material.dart';
import 'package:ui_specification/core/constants/breakpoints.dart';
import 'package:ui_specification/core/theme/app_colors.dart';
import 'package:ui_specification/core/theme/app_dimensions.dart';
import 'package:ui_specification/core/utils/responsive.dart';
import 'package:ui_specification/core/widgets/custom_card.dart';

/// Notifications widget for dashboard
class NotificationsWidget extends StatelessWidget {
  const NotificationsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive values
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;

    // Adjust number of notifications shown based on screen size
    final notifications = [
      {
        'title': 'New lead assigned',
        'subtitle': 'John Doe requested a quote',
        'time': '2 hours ago',
        'icon': Icons.person_add_outlined,
        'color': AppColors.primary,
      },
      {
        'title': 'Order payment due',
        'subtitle': 'Order #1234 payment overdue',
        'time': '1 day ago',
        'icon': Icons.payment_outlined,
        'color': AppColors.error,
      },
      {
        'title': 'Photography shoot reminder',
        'subtitle': 'Wedding photography tomorrow',
        'time': '3 hours ago',
        'icon': Icons.event_outlined,
        'color': AppColors.warning,
      },
      {
        'title': 'Quotation approved',
        'subtitle': 'Quote #567 approved by client',
        'time': '5 hours ago',
        'icon': Icons.check_circle_outlined,
        'color': AppColors.success,
      },
    ];

    // Show fewer notifications on smaller screens
    final maxNotifications = Responsive.value<int>(
      context: context,
      mobile: 3,
      tablet: 3,
      desktop: 4,
    );
    final displayNotifications = notifications.take(maxNotifications).toList();

    return CustomCard(
      padding: EdgeInsets.all(
        Responsive.value<double>(
          context: context,
          mobile: AppDimensions.spacing12,
          tablet: AppDimensions.spacing12,
          desktop: AppDimensions.spacing16,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Notifications',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: Responsive.value<double>(
                    context: context,
                    mobile: 16.0,
                    tablet: 17.0,
                    desktop: 18.0,
                  ),
                ),
              ),
              if (!isMobile)
                TextButton(
                  onPressed: () {
                    // Navigate to notifications screen
                  },
                  child: const Text('View All'),
                ),
            ],
          ),
          SizedBox(
            height: Responsive.value<double>(
              context: context,
              mobile: AppDimensions.spacing6,
              tablet: AppDimensions.spacing8,
              desktop: AppDimensions.spacing8,
            ),
          ),
          ...displayNotifications.map(
            (notification) => _buildNotificationItem(notification, context),
          ),
          if (isMobile)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    // Navigate to notifications screen
                  },
                  child: const Text('View All'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    Map<String, dynamic> notification,
    BuildContext context,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: Responsive.value<double>(
          context: context,
          mobile: AppDimensions.spacing8,
          tablet: AppDimensions.spacing8,
          desktop: AppDimensions.spacing12,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(
              Responsive.value<double>(
                context: context,
                mobile: AppDimensions.spacing6,
                tablet: AppDimensions.spacing6,
                desktop: AppDimensions.spacing8,
              ),
            ),
            decoration: BoxDecoration(
              color: (notification['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: Icon(
              notification['icon'] as IconData,
              color: notification['color'] as Color,
              size: Responsive.value<double>(
                context: context,
                mobile: 18.0,
                tablet: 19.0,
                desktop: 20.0,
              ),
            ),
          ),
          SizedBox(
            width: Responsive.value<double>(
              context: context,
              mobile: AppDimensions.spacing8,
              tablet: AppDimensions.spacing8,
              desktop: AppDimensions.spacing12,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['title'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: Responsive.value<double>(
                      context: context,
                      mobile: 13.0,
                      tablet: 13.0,
                      desktop: 14.0,
                    ),
                  ),
                ),
                SizedBox(
                  height: Responsive.value<double>(
                    context: context,
                    mobile: AppDimensions.spacing2,
                    tablet: AppDimensions.spacing4,
                    desktop: AppDimensions.spacing4,
                  ),
                ),
                Text(
                  notification['subtitle'] as String,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: Responsive.value<double>(
                      context: context,
                      mobile: 11.0,
                      tablet: 11.0,
                      desktop: 12.0,
                    ),
                  ),
                ),
                SizedBox(
                  height: Responsive.value<double>(
                    context: context,
                    mobile: AppDimensions.spacing2,
                    tablet: AppDimensions.spacing4,
                    desktop: AppDimensions.spacing4,
                  ),
                ),
                Text(
                  notification['time'] as String,
                  style: TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: Responsive.value<double>(
                      context: context,
                      mobile: 9.0,
                      tablet: 9.0,
                      desktop: 10.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
