import 'package:flutter/material.dart';
import 'package:ui_specification/core/theme/app_colors.dart';
import 'package:ui_specification/core/theme/app_dimensions.dart';
import 'package:ui_specification/core/utils/responsive.dart';
import 'package:ui_specification/features/dashboard/widgets/metric_card.dart';
import 'package:ui_specification/features/dashboard/widgets/metrics_chart.dart';
import 'package:ui_specification/features/dashboard/widgets/notifications_widget.dart';

/// Dashboard screen with metric cards
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = RefreshIndicator(
      onRefresh: () async {
        // TODO: Refresh dashboard data
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(
          Responsive.isMobile(context)
              ? AppDimensions.spacing12
              : AppDimensions.spacing16,
        ),
        child: Responsive.isMobile(context)
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Metrics Section
                  _buildQuickMetrics(context),
                  SizedBox(
                    height: Responsive.isMobile(context)
                        ? AppDimensions.spacing20
                        : AppDimensions.spacing24,
                  ),

                  // Chart Section
                  const MetricsChart(),
                  SizedBox(
                    height: Responsive.isMobile(context)
                        ? AppDimensions.spacing20
                        : AppDimensions.spacing24,
                  ),

                  // Notifications Section
                  const NotificationsWidget(),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Metrics Section
                  _buildQuickMetrics(context),
                  const SizedBox(height: AppDimensions.spacing32),

                  // Chart and Notifications in responsive layout
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      final isLargeScreen = screenWidth > 1200;

                      if (isLargeScreen) {
                        // Desktop: Side by side layout
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: const MetricsChart()),
                            const SizedBox(width: AppDimensions.spacing32),
                            Expanded(
                              flex: 2,
                              child: const NotificationsWidget(),
                            ),
                          ],
                        );
                      } else {
                        // Tablet: Vertical layout with adjusted spacing
                        return Column(
                          children: [
                            const MetricsChart(),
                            const SizedBox(height: AppDimensions.spacing32),
                            const NotificationsWidget(),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              _showNotificationsBottomSheet(context);
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
      body: content,
    );
  }

  Widget _buildQuickMetrics(BuildContext context) {
    final crossAxisCount = Responsive.isMobile(context) ? 2 : 4;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate aspect ratio based on available width to prevent overflow
        final availableWidth =
            constraints.maxWidth -
            (AppDimensions.spacing16 * (crossAxisCount - 1));
        final itemWidth = availableWidth / crossAxisCount;
        // Estimate content height: icon(24) + padding(16*2) + title(20) + value(28) + subtitle(16) + spacing(4*3) ≈ 140
        const estimatedContentHeight = 140.0;
        final aspectRatio = itemWidth / estimatedContentHeight;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppDimensions.spacing16,
          mainAxisSpacing: AppDimensions.spacing16,
          childAspectRatio: aspectRatio.clamp(
            1.0,
            3.0,
          ), // Clamp to reasonable range
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
              'Photography shoots in next 30 days',
              AppColors.primary,
              null,
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
              Icons.description_outlined,
              'Total Quotations',
              '89',
              'All time',
              AppColors.primary,
              null,
              '/quotations',
            ),
          ],
        );
      },
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
                  'Photography & Videography Services',
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
            icon: Icons.camera_alt,
            title: 'Photography Shoots',
            route: '/events',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.description_outlined,
            title: 'Quotations',
            route: '/quotations',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.payment_outlined,
            title: 'Payments',
            route: '/payments',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.warning_outlined,
            title: 'Incomplete Leads',
            route: '/leads/incomplete',
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
              _buildDrawerSubItem(
                context,
                title: 'Services',
                route: '/setup/services',
              ),
              _buildDrawerSubItem(
                context,
                title: 'Sub Services',
                route: '/setup/sub-services',
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

  void _showNotificationsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacing16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.divider, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Expanded(child: NotificationsWidget()),
          ],
        ),
      ),
    );
  }
}
