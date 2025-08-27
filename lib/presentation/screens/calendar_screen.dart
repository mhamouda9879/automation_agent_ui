import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/calendar_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../../domain/entities/calendar_event.dart';
import '../../core/services/calendar_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/di/injection_container.dart' as di;

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  final CalendarService _calendarService = di.sl<CalendarService>();
  final AuthService _authService = di.sl<AuthService>();
  bool _isLoadingCalendarAccess = false;
  String? _calendarAccessStatus;

  @override
  void initState() {
    super.initState();
    // Load events for the current date
    context.read<CalendarBloc>().add(LoadEventsByDate(_selectedDate));
    
    // Check calendar access status
    _checkCalendarAccess();
  }

  Future<void> _checkCalendarAccess() async {
    setState(() {
      _isLoadingCalendarAccess = true;
    });

    try {
      final hasAccess = await _calendarService.checkCalendarAccess();
      final authData = await _authService.getAuthData();
      
      if (hasAccess && authData != null) {
        setState(() {
          _calendarAccessStatus = '✅ Calendar access granted\n📅 Scopes: ${_authService.getCalendarScopes(authData).join(', ')}';
        });
      } else {
        setState(() {
          _calendarAccessStatus = '❌ No calendar access\n🔐 Please sign in with Google';
        });
      }
    } catch (e) {
      setState(() {
        _calendarAccessStatus = '⚠️ Error checking calendar access: $e';
      });
    } finally {
      setState(() {
        _isLoadingCalendarAccess = false;
      });
    }
  }

  Future<void> _refreshTokens() async {
    try {
      final success = await _calendarService.refreshTokensIfNeeded();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Tokens refreshed successfully')),
        );
        _checkCalendarAccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Failed to refresh tokens')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error refreshing tokens: $e')),
      );
    }
  }

  Future<void> _testGoogleCalendarAPI() async {
    try {
      setState(() {
        _isLoadingCalendarAccess = true;
      });

      // Test getting user's calendars
      final calendars = await _calendarService.getUserCalendars();
      
      if (calendars['items'] != null) {
        final calendarCount = (calendars['items'] as List).length;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Successfully fetched $calendarCount calendars')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ No calendars found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error testing Google Calendar API: $e')),
      );
    } finally {
      setState(() {
        _isLoadingCalendarAccess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTokens,
            tooltip: 'Refresh Tokens',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(SignOutPressed());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar Access Status
          if (_calendarAccessStatus != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _calendarAccessStatus!.contains('✅') 
                    ? Colors.green.withOpacity(0.1)
                    : _calendarAccessStatus!.contains('❌')
                        ? Colors.red.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _calendarAccessStatus!.contains('✅')
                      ? Colors.green
                      : _calendarAccessStatus!.contains('❌')
                          ? Colors.red
                          : Colors.orange,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _calendarAccessStatus!.contains('✅')
                            ? Icons.check_circle
                            : _calendarAccessStatus!.contains('❌')
                                ? Icons.error
                                : Icons.warning,
                        color: _calendarAccessStatus!.contains('✅')
                            ? Colors.green
                            : _calendarAccessStatus!.contains('❌')
                                ? Colors.red
                                : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Calendar Access Status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _calendarAccessStatus!,
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (_calendarAccessStatus!.contains('✅'))
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ElevatedButton.icon(
                        onPressed: _isLoadingCalendarAccess ? null : _testGoogleCalendarAPI,
                        icon: _isLoadingCalendarAccess 
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.api),
                        label: Text(_isLoadingCalendarAccess ? 'Testing...' : 'Test Google Calendar API'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // Calendar Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
                    });
                  },
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_focusedDate),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Calendar Grid
          Expanded(
            child: _buildCalendarGrid(),
          ),
          
          // Events List
          Expanded(
            flex: 2,
            child: _buildEventsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: 42, // 6 weeks * 7 days
      itemBuilder: (context, index) {
        final dayOffset = index - firstWeekday + 1;
        final day = dayOffset;
        
        if (day < 1 || day > daysInMonth) {
          return Container();
        }
        
        final date = DateTime(_focusedDate.year, _focusedDate.month, day);
        final isSelected = date.year == _selectedDate.year &&
                          date.month == _selectedDate.month &&
                          date.day == _selectedDate.day;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
            context.read<CalendarBloc>().add(LoadEventsByDate(date));
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
              ),
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventsList() {
    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        if (state is CalendarLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is EventsLoaded) {
          if (state.events.isEmpty) {
            return const Center(
              child: Text(
                'No events for this date',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.events.length,
            itemBuilder: (context, index) {
              final event = state.events[index];
              return _buildEventCard(event);
            },
          );
        }
        
        if (state is CalendarError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<CalendarBloc>().add(LoadEventsByDate(_selectedDate));
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        return const Center(
          child: Text('Select a date to view events'),
        );
      },
    );
  }

  Widget _buildEventCard(CalendarEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.description),
            const SizedBox(height: 4),
            Text(
              '${DateFormat('MMM dd, yyyy').format(event.startTime)} at '
              '${DateFormat('HH:mm').format(event.startTime)}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            if (event.location != null) ...[
              const SizedBox(height: 2),
              Text(
                '📍 ${event.location}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _showEditEventDialog(context, event);
            } else if (value == 'delete') {
              _showDeleteEventDialog(context, event);
            }
          },
        ),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddEventDialog(),
    );
  }

  void _showEditEventDialog(BuildContext context, CalendarEvent event) {
    showDialog(
      context: context,
      builder: (context) => EditEventDialog(event: event),
    );
  }

  void _showDeleteEventDialog(BuildContext context, CalendarEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<CalendarBloc>().add(DeleteEvent(event.id));
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class AddEventDialog extends StatefulWidget {
  const AddEventDialog({Key? key}) : super(key: key);

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  DateTime _endDate = DateTime.now();
  TimeOfDay _endTime = TimeOfDay.now();
  bool _isAllDay = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Event'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isAllDay,
                    onChanged: (value) {
                      setState(() {
                        _isAllDay = value ?? false;
                      });
                    },
                  ),
                  const Text('All Day'),
                ],
              ),
              if (!_isAllDay) ...[
                ListTile(
                  title: const Text('Start Time'),
                  subtitle: Text(DateFormat('MMM dd, yyyy HH:mm').format(_startDate)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _startDate = date;
                      });
                    }
                  },
                ),
                ListTile(
                  title: const Text('End Time'),
                  subtitle: Text(DateFormat('MMM dd, yyyy HH:mm').format(_endDate)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _endDate = date;
                      });
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createEvent,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _createEvent() {
    if (_formKey.currentState!.validate()) {
      final event = CalendarEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        startTime: _startDate,
        endTime: _endDate,
        location: _locationController.text.isEmpty ? null : _locationController.text,
        isAllDay: _isAllDay,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      context.read<CalendarBloc>().add(CreateEvent(event));
      Navigator.of(context).pop();
    }
  }
}

class EditEventDialog extends StatefulWidget {
  final CalendarEvent event;

  const EditEventDialog({Key? key, required this.event}) : super(key: key);

  @override
  State<EditEventDialog> createState() => _EditEventDialogState();
}

class _EditEventDialogState extends State<EditEventDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late DateTime _startDate;
  late DateTime _endDate;
  late bool _isAllDay;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(text: widget.event.description);
    _locationController = TextEditingController(text: widget.event.location ?? '');
    _startDate = widget.event.startTime;
    _endDate = widget.event.endTime;
    _isAllDay = widget.event.isAllDay;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Event'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isAllDay,
                    onChanged: (value) {
                      setState(() {
                        _isAllDay = value ?? false;
                      });
                    },
                  ),
                  const Text('All Day'),
                ],
              ),
              if (!_isAllDay) ...[
                ListTile(
                  title: const Text('Start Time'),
                  subtitle: Text(DateFormat('MMM dd, yyyy HH:mm').format(_startDate)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _startDate = date;
                      });
                    }
                  },
                ),
                ListTile(
                  title: const Text('End Time'),
                  subtitle: Text(DateFormat('MMM dd, yyyy HH:mm').format(_endDate)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _endDate = date;
                      });
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updateEvent,
          child: const Text('Update'),
        ),
      ],
    );
  }

  void _updateEvent() {
    if (_formKey.currentState!.validate()) {
      final updatedEvent = widget.event.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        startTime: _startDate,
        endTime: _endDate,
        location: _locationController.text.isEmpty ? null : _locationController.text,
        isAllDay: _isAllDay,
        updatedAt: DateTime.now(),
      );
      
      context.read<CalendarBloc>().add(UpdateEvent(updatedEvent));
      Navigator.of(context).pop();
    }
  }
}
