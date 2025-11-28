import 'package:flutter/material.dart';
import 'package:ui_specification/core/theme/app_colors.dart';
import 'package:ui_specification/core/theme/app_dimensions.dart';
import 'package:ui_specification/core/utils/responsive.dart';
import 'package:ui_specification/features/dashboard/widgets/metric_card.dart';

/// Dashboard screen with metric cards
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/my-profile');
            },
          ),
          const SizedBox(width: AppDimensions.spacing8),
        ],
      ),
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh dashboard data
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          child: _buildMetricGrid(context),
        ),
      ),
    );
  }

  Widget _buildMetricGrid(BuildContext context) {
    // Use ListView for mobile for natural card sizing
    if (Responsive.isMobile(context)) {
      return Column(
        children: [
          _buildMetricCard(
            context,
            Icons.leaderboard_outlined,
            'Total Leads',
            '42',
            'Past 30 days',
            AppColors.info,
            AppColors.success,
            '/leads',
          ),
          const SizedBox(height: AppDimensions.spacing8),
          _buildMetricCard(
            context,
            Icons.calendar_today_outlined,
            'Upcoming Orders',
            '12',
            'Events in next 30 days',
            AppColors.primary,
            null,
            '/orders',
          ),
          const SizedBox(height: AppDimensions.spacing8),
          _buildMetricCard(
            context,
            Icons.warning_amber_outlined,
            'Unassigned Orders',
            '5',
            'Requires team assignment',
            AppColors.warning,
            AppColors.warning,
            '/orders',
          ),
          const SizedBox(height: AppDimensions.spacing8),
          _buildMetricCard(
            context,
            Icons.payment_outlined,
            'Due Payment Orders',
            '3',
            'Overdue payments',
            AppColors.error,
            AppColors.error,
            '/orders',
          ),
          const SizedBox(height: AppDimensions.spacing8),
          _buildMetricCard(
            context,
            Icons.people_outline,
            'Total Clients',
            '48',
            'Active clients',
            AppColors.success,
            null,
            '/clients',
          ),
          _buildMetricCard(
            context,
            Icons.person_outline,
            'Open Leads',
            '31',
            'In pipeline',
            AppColors.info,
            null,
            '/leads',
          ),
          const SizedBox(height: AppDimensions.spacing8),
          _buildMetricCard(
            context,
            Icons.list_alt_outlined,
            'Total Orders',
            '127',
            'All time',
            AppColors.secondary,
            null,
            '/orders',
          ),
        ],
      );
    }

    // Use GridView for tablet and desktop
    final crossAxisCount = Responsive.value<int>(
      context: context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
    );

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppDimensions.spacing16,
      mainAxisSpacing: AppDimensions.spacing16,
      childAspectRatio: 2.0,
      children: [
        _buildMetricCard(
          context,
          Icons.leaderboard_outlined,
          'Total Leads',
          '42',
          'Past 30 days',
          AppColors.info,
          AppColors.success,
          '/leads',
        ),
        _buildMetricCard(
          context,
          Icons.calendar_today_outlined,
          'Upcoming Orders',
          '12',
          'Events in next 30 days',
          AppColors.primary,
          null,
          '/orders',
        ),
        _buildMetricCard(
          context,
          Icons.warning_amber_outlined,
          'Unassigned Orders',
          '5',
          'Requires team assignment',
          AppColors.warning,
          AppColors.warning,
          '/orders',
        ),
        _buildMetricCard(
          context,
          Icons.payment_outlined,
          'Due Payment Orders',
          '3',
          'Overdue payments',
          AppColors.error,
          AppColors.error,
          '/orders',
        ),
        _buildMetricCard(
          context,
          Icons.people_outline,
          'Total Clients',
          '48',
          'Active clients',
          AppColors.success,
          null,
          '/clients',
        ),
        _buildMetricCard(
          context,
          Icons.person_outline,
          'Open Leads',
          '31',
          'In pipeline',
          AppColors.info,
          null,
          '/leads',
        ),
        _buildMetricCard(
          context,
          Icons.list_alt_outlined,
          'Total Orders',
          '127',
          'All time',
          AppColors.secondary,
          null,
          '/orders',
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    String subtitle,
    Color iconColor,
    Color? highlightColor,
    String route,
  ) {
    return MetricCard(
      icon: icon,
      title: title,
      value: value,
      subtitle: subtitle,
      iconColor: iconColor,
      highlightColor: highlightColor,
      onTap: () {
        Navigator.of(context).pushNamed(route);
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.event_available,
                  size: 48,
                  color: AppColors.textOnPrimary,
                ),
                const SizedBox(height: AppDimensions.spacing8),
                Text(
                  'Event Management',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.dashboard_outlined,
            title: 'Dashboard',
            route: '/dashboard',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.person_add_outlined,
            title: 'Leads',
            route: '/leads',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.people_outlined,
            title: 'Clients',
            route: '/clients',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.shopping_cart_outlined,
            title: 'Orders',
            route: '/orders',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.event_outlined,
            title: 'Events',
            route: '/events',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.description_outlined,
            title: 'Quotations',
            route: '/quotations',
          ),
          const Divider(),
          ExpansionTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Setup & Master Data'),
            children: [
              _buildDrawerSubItem(
                context,
                title: 'Team Members',
                route: '/setup/team-members',
              ),
              _buildDrawerSubItem(
                context,
                title: 'Lead Sources',
                route: '/setup/lead-sources',
              ),
              _buildDrawerSubItem(
                context,
                title: 'Event Types',
                route: '/setup/event-types',
              ),
              _buildDrawerSubItem(
                context,
                title: 'Team Categories',
                route: '/setup/team-categories',
              ),
              _buildDrawerSubItem(
                context,
                title: 'Packages',
                route: '/setup/packages',
              ),
              _buildDrawerSubItem(
                context,
                title: 'Admin Notifications',
                route: '/setup/admin-notifications',
              ),
              _buildDrawerSubItem(
                context,
                title: 'Notification Templates',
                route: '/setup/notification-templates',
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.admin_panel_settings_outlined),
            title: const Text('User Management'),
            children: [
              _buildDrawerSubItem(context, title: 'Users', route: '/users'),
              _buildDrawerSubItem(context, title: 'Roles', route: '/roles'),
            ],
          ),
          _buildDrawerItem(
            context,
            icon: Icons.message_outlined,
            title: 'Messages',
            route: '/messages',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.account_circle_outlined,
            title: 'My Profile',
            route: '/my-profile',
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_outlined, color: AppColors.error),
            title: const Text('Logout'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(route);
      },
    );
  }

  Widget _buildDrawerSubItem(
    BuildContext context, {
    required String title,
    required String route,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 72, right: 16),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(route);
      },
    );
  }
}
