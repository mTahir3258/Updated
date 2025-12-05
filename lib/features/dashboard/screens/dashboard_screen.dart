import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:ui_specification/core/theme/app_colors.dart';
import 'package:ui_specification/core/theme/app_dimensions.dart';
import 'package:ui_specification/core/utils/responsive.dart';
import 'package:ui_specification/core/constants/app_images.dart';
import 'package:ui_specification/core/widgets/status_badge.dart';
import 'package:ui_specification/features/dashboard/widgets/metric_card.dart';
import 'package:ui_specification/features/dashboard/widgets/metrics_chart.dart';
import 'package:ui_specification/features/dashboard/widgets/notifications_widget.dart';
import 'package:ui_specification/features/events/providers/event_provider.dart';
import 'package:ui_specification/models/event.dart';

/// Dashboard screen with metric cards
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) => Scaffold(
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
        body: _buildBody(context, eventProvider),
      ),
    );
  }

  Widget _buildBody(BuildContext context, EventProvider eventProvider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;
    final padding = EdgeInsets.all(
      isMobile ? AppDimensions.spacing12 : AppDimensions.spacing16,
    );

    if (isMobile) {
      // Mobile: Scrollable layout
      return RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh dashboard data
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Metrics Section
              _buildQuickMetrics(context),
              const SizedBox(height: AppDimensions.spacing20),

              // Chart Section
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: AspectRatio(
                  aspectRatio: 3.0,
                  child: const MetricsChart(),
                ),
              ),
              const SizedBox(height: AppDimensions.spacing20),

              // Calendar Section
              _buildCalendarView(eventProvider),
              const SizedBox(height: AppDimensions.spacing20),

              // Notifications Section
              const NotificationsWidget(),
            ],
          ),
        ),
      );
    } else {
      // Tablet/Desktop: Scrollable layout with responsive design
      return SingleChildScrollView(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Metrics Section
            _buildQuickMetrics(context),
            SizedBox(
              height: isTablet
                  ? AppDimensions.spacing24
                  : AppDimensions.spacing32,
            ),

            // Chart and Notifications in responsive layout
            isDesktop
                ? Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 400),
                              child: AspectRatio(
                                aspectRatio: 2.5,
                                child: const MetricsChart(),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacing32),
                          Expanded(
                            flex: 2,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 300),
                              child: AspectRatio(
                                aspectRatio: 1.5,
                                child: const NotificationsWidget(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacing32),
                      _buildCalendarView(eventProvider),
                    ],
                  )
                : Column(
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 400),
                        child: AspectRatio(
                          aspectRatio: 3.0,
                          child: const MetricsChart(),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacing24),
                      _buildCalendarView(eventProvider),
                      const SizedBox(height: AppDimensions.spacing24),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: AspectRatio(
                          aspectRatio: 2.0,
                          child: const NotificationsWidget(),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      );
    }
  }

  Widget _buildQuickMetrics(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600
        ? 2
        : screenWidth < 1200
        ? 3
        : 4;

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

  Widget _buildCalendarView(EventProvider provider) {
    final events = provider.getEventsForDay(_selectedDay ?? _focusedDay);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final calendarFormat = isMobile
        ? CalendarFormat.week
        : CalendarFormat.month;
    final calendarHeight = isMobile
        ? 300.0
        : screenWidth < 1200
        ? 320.0
        : 350.0;
    final eventListHeight = isMobile ? 400.0 : 600.0;
    final calendarMargin = EdgeInsets.all(
      isMobile ? AppDimensions.spacing8 : AppDimensions.spacing16,
    );

    return Column(
      children: [
        Card(
          margin: calendarMargin,
          child: SizedBox(
            height: calendarHeight,
            child: TableCalendar<Event>(
              firstDay: DateTime.utc(2020, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: calendarFormat,
              eventLoader: (day) => provider.getEventsForDay(day),
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                markerDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: TextStyle(
                  fontSize: isMobile
                      ? 12
                      : screenWidth < 1200
                      ? 13
                      : 14,
                ),
                weekendTextStyle: TextStyle(
                  fontSize: isMobile
                      ? 12
                      : screenWidth < 1200
                      ? 13
                      : 14,
                ),
                outsideTextStyle: TextStyle(
                  fontSize: isMobile
                      ? 12
                      : screenWidth < 1200
                      ? 13
                      : 14,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
              ),
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: !isMobile, // Hide format button on mobile
                titleTextStyle: TextStyle(
                  fontSize: isMobile
                      ? 16
                      : screenWidth < 1200
                      ? 17
                      : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontSize: isMobile
                      ? 10
                      : screenWidth < 1200
                      ? 11
                      : 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
                weekendStyle: TextStyle(
                  fontSize: isMobile
                      ? 10
                      : screenWidth < 1200
                      ? 11
                      : 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              onFormatChanged: (format) {
                // Format changes disabled for responsive behavior
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ),
        ),
        const Divider(),
        SizedBox(
          height: eventListHeight,
          child: events.isEmpty
              ? const Center(child: Text('No events for this day'))
              : ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.spacing8),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return _buildEventCard(events[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEventCard(Event event) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final padding = EdgeInsets.all(
      isMobile ? AppDimensions.spacing8 : AppDimensions.spacing12,
    );
    final iconSize = isMobile ? 14.0 : 16.0;
    final spacing = isMobile ? AppDimensions.spacing4 : AppDimensions.spacing8;

    return Card(
      margin: EdgeInsets.only(
        bottom: isMobile ? AppDimensions.spacing4 : AppDimensions.spacing8,
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                ),
                StatusBadge(
                  label: event.status.name.toUpperCase(),
                  type: _getStatusType(event.status),
                  small: true,
                ),
              ],
            ),
            SizedBox(height: spacing),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: iconSize,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: AppDimensions.spacing4),
                Expanded(
                  child: Text(
                    event.clientName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.spacing4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: iconSize,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: AppDimensions.spacing4),
                Text(
                  DateFormat('MMM dd, yyyy').format(event.date),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: isMobile ? 12 : 14),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.spacing4),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: iconSize,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: AppDimensions.spacing4),
                Expanded(
                  child: Text(
                    event.venue,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  StatusType _getStatusType(EventStatus status) {
    switch (status) {
      case EventStatus.upcoming:
        return StatusType.newStatus;
      case EventStatus.completed:
        return StatusType.success;
      case EventStatus.cancelled:
        return StatusType.failed;
    }
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
                Image.asset(AppImages.appLogo, width: 48, height: 48),
                const SizedBox(height: AppDimensions.spacing8),
                Text(
                  'The Sacred Souls',
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
            title: 'Events',
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
