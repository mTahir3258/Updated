import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui_specification/core/theme/app_colors.dart';
import 'package:ui_specification/core/theme/app_dimensions.dart';
import 'package:ui_specification/core/utils/responsive.dart';
import 'package:ui_specification/core/widgets/custom_card.dart';
import 'package:ui_specification/core/widgets/loading_indicator.dart';
import 'package:ui_specification/core/widgets/status_badge.dart';
import 'package:ui_specification/features/events/providers/event_provider.dart';
import 'package:ui_specification/models/event.dart';
import 'package:intl/intl.dart';
import 'package:ui_specification/core/constants/routes.dart';

class EventDetailScreen extends StatefulWidget {
  final String? eventId;

  const EventDetailScreen({super.key, this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final String id =
        widget.eventId ?? ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      body: Consumer<EventProvider>(
        builder: (context, provider, child) {
          final event = provider.getEventById(id);

          if (event == null) {
            return const Center(child: Text('Event not found'));
          }

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(event),
              SliverPadding(
                padding: const EdgeInsets.all(AppDimensions.spacing16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildEventInfoCard(event),
                    const SizedBox(height: AppDimensions.spacing16),
                    _buildServiceAssignmentSection(event),
                    const SizedBox(height: AppDimensions.spacing16),
                    _buildTeamSection(event),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(Event event) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(event.name, maxLines: 2, overflow: TextOverflow.ellipsis),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.event,
              size: 80,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventInfoCard(Event event) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Event Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushNamed(Routes.eventForm, arguments: event);
                  },
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: AppDimensions.spacing8),
            _buildInfoRow(
              Icons.confirmation_number,
              'Event ID',
              '#${event.id}',
            ),
            _buildInfoRow(Icons.person, 'Client', event.clientName),
            _buildInfoRow(Icons.category, 'Type', event.type),
            _buildInfoRow(
              Icons.calendar_today,
              'Date',
              DateFormat('MMMM dd, yyyy').format(event.date),
            ),
            _buildInfoRow(Icons.location_on, 'Venue', event.venue),
            const SizedBox(height: AppDimensions.spacing8),
            Row(
              children: [
                const Text(
                  'Status: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                StatusBadge(
                  label: event.status.name.toUpperCase(),
                  type: _getStatusType(event.status),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceAssignmentSection(Event event) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Service Assignment',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Add Service'),
                ),
              ],
            ),
            const Divider(),
            if (event.serviceIds.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppDimensions.spacing16),
                child: Center(child: Text('No services assigned')),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: event.serviceIds.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(Icons.room_service, color: AppColors.primary),
                    ),
                    title: Text('Service ${event.serviceIds[index]}'),
                    subtitle: const Text('Unassigned'),
                    trailing: TextButton(
                      onPressed: () {},
                      child: const Text('Assign'),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSection(Event event) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Assigned Team',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.person_add),
                  label: const Text('Assign Team'),
                ),
              ],
            ),
            const Divider(),
            if (event.assignedTeamIds.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppDimensions.spacing16),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.group_off,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: AppDimensions.spacing8),
                      Text(
                        'No team members assigned',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: event.assignedTeamIds.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text('Team Member ${event.assignedTeamIds[index]}'),
                    subtitle: const Text('Photographer'),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: AppColors.error,
                      ),
                      onPressed: () {},
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacing4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppDimensions.spacing8),
          Text(
            '$label: ',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
}
