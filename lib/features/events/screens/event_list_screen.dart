import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ui_specification/core/theme/app_colors.dart';
import 'package:ui_specification/core/theme/app_dimensions.dart';
import 'package:ui_specification/core/utils/responsive.dart';
import 'package:ui_specification/core/widgets/custom_card.dart';
import 'package:ui_specification/core/widgets/empty_state.dart';
import 'package:ui_specification/core/widgets/filter_bar.dart';
import 'package:ui_specification/core/widgets/loading_indicator.dart';
import 'package:ui_specification/core/widgets/pagination_controls.dart';
import 'package:ui_specification/core/widgets/status_badge.dart';
import 'package:ui_specification/features/events/providers/event_provider.dart';
import 'package:ui_specification/models/event.dart';
import 'package:intl/intl.dart';
import 'package:ui_specification/core/constants/routes.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  bool _isCalendarView = true;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Filter & Pagination State
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  DateTimeRange? _selectedDateRange;
  int _currentPage = 1;
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEvents();
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

  List<Event> _getFilteredEvents(List<Event> allEvents) {
    return allEvents.where((event) {
      // Search Filter
      final query = _searchController.text.toLowerCase();
      final matchesSearch =
          event.name.toLowerCase().contains(query) ||
          event.clientName.toLowerCase().contains(query) ||
          event.venue.toLowerCase().contains(query);

      // Status Filter
      final matchesStatus =
          _selectedStatus == 'All' ||
          event.status.name.toUpperCase() == _selectedStatus.toUpperCase();

      // Date Range Filter
      final matchesDate =
          _selectedDateRange == null ||
          (event.date.isAfter(
                _selectedDateRange!.start.subtract(const Duration(days: 1)),
              ) &&
              event.date.isBefore(
                _selectedDateRange!.end.add(const Duration(days: 1)),
              ));

      return matchesSearch && matchesStatus && matchesDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photography Shoots'),
        actions: [
          IconButton(
            icon: Icon(_isCalendarView ? Icons.list : Icons.calendar_month),
            onPressed: () {
              setState(() {
                _isCalendarView = !_isCalendarView;
              });
            },
            tooltip: _isCalendarView
                ? 'Switch to List View'
                : 'Switch to Calendar View',
          ),
          if (!Responsive.isMobile(context))
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing8,
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.eventForm);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Photography Shoot'),
              ),
            ),
        ],
      ),
      floatingActionButton: Responsive.isMobile(context)
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushNamed(Routes.eventForm);
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          if (eventProvider.isLoading) {
            return const LoadingIndicator(message: 'Loading events...');
          }

          return _isCalendarView
              ? _buildCalendarView(eventProvider)
              : _buildListView(eventProvider);
        },
      ),
    );
  }

  Widget _buildCalendarView(EventProvider provider) {
    final events = provider.getEventsForDay(_selectedDay ?? _focusedDay);

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(AppDimensions.spacing16),
          child: TableCalendar<Event>(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            eventLoader: (day) => provider.getEventsForDay(day),
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              markerDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
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
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
        ),
        const Divider(),
        Expanded(
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

  Widget _buildListView(EventProvider provider) {
    final filteredEvents = _getFilteredEvents(provider.events);
    final totalItems = filteredEvents.length;
    final totalPages = (totalItems / _rowsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage < totalItems)
        ? startIndex + _rowsPerPage
        : totalItems;
    final paginatedEvents = filteredEvents.isEmpty
        ? <Event>[]
        : filteredEvents.sublist(startIndex, endIndex);

    return Column(
      children: [
        FilterBar(
          searchController: _searchController,
          filters: const ['All', 'UPCOMING', 'COMPLETED', 'CANCELLED'],
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
          child: filteredEvents.isEmpty
              ? EmptyState(
                  icon: Icons.event_busy,
                  message: 'No events found',
                  subtitle: 'Try adjusting your filters',
                  actionLabel: 'Add Event',
                  onActionPressed: () =>
                      Navigator.of(context).pushNamed(Routes.eventForm),
                )
              : Responsive(
                  mobile: ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.spacing8),
                    itemCount: paginatedEvents.length,
                    itemBuilder: (context, index) {
                      return _buildEventCard(paginatedEvents[index]);
                    },
                  ),
                  tablet: _buildDataTable(paginatedEvents),
                  desktop: _buildDataTable(paginatedEvents),
                ),
        ),
        if (filteredEvents.isNotEmpty && !Responsive.isMobile(context))
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
  }

  Widget _buildEventCard(Event event) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing8),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                StatusBadge(
                  label: event.status.name.toUpperCase(),
                  type: _getStatusType(event.status),
                  small: true,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppDimensions.spacing4),
                Text(
                  event.clientName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
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
                  DateFormat('MMM dd, yyyy').format(event.date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing4),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppDimensions.spacing4),
                Text(event.venue, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(List<Event> events) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Card(
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Photography Shoot')),
              DataColumn(label: Text('Client')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Venue')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: events.map((event) {
              return DataRow(
                cells: [
                  DataCell(Text(DateFormat('MMM dd, yyyy').format(event.date))),
                  DataCell(
                    SizedBox(
                      width: 150,
                      child: Text(
                        event.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 120,
                      child: Text(
                        event.clientName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 100,
                      child: Text(
                        event.type,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 120,
                      child: Text(
                        event.venue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    StatusBadge(
                      label: event.status.name.toUpperCase(),
                      type: _getStatusType(event.status),
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
                              Routes.eventDetails,
                              arguments: event.id,
                            );
                          },
                          tooltip: 'View',
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pushNamed(Routes.eventForm, arguments: event);
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
