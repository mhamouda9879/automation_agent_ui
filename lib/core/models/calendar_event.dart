import 'package:json_annotation/json_annotation.dart';

part 'calendar_event.g.dart';

@JsonSerializable()
class CalendarEvent {
  final String? id;
  final String summary;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final String? description;
  final List<String>? attendees;
  final bool allDay;
  final String? draftId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? status; // 'draft', 'confirmed', 'cancelled'

  CalendarEvent({
    this.id,
    required this.summary,
    required this.startTime,
    required this.endTime,
    this.location,
    this.description,
    this.attendees,
    this.allDay = false,
    this.draftId,
    this.createdAt,
    this.updatedAt,
    this.status,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) => _$CalendarEventFromJson(json);
  Map<String, dynamic> toJson() => _$CalendarEventToJson(this);

  CalendarEvent copyWith({
    String? id,
    String? summary,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? description,
    List<String>? attendees,
    bool? allDay,
    String? draftId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      summary: summary ?? this.summary,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      description: description ?? this.description,
      attendees: attendees ?? this.attendees,
      allDay: allDay ?? this.allDay,
      draftId: draftId ?? this.draftId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'CalendarEvent(id: $id, summary: $summary, startTime: $startTime, endTime: $endTime, location: $location, status: $status)';
  }
}

@JsonSerializable()
class CalendarEventRequest {
  final String operation;
  final String? summary;
  final String? startTime;
  final String? endTime;
  final String? location;
  final String? description;
  final List<String>? attendees;
  final bool? allDay;
  final String? eventId;
  final String? draftId;
  final String? query;
  final int? maxResults;
  final String? timeMin;
  final String? timeMax;

  CalendarEventRequest({
    required this.operation,
    this.summary,
    this.startTime,
    this.endTime,
    this.location,
    this.description,
    this.attendees,
    this.allDay,
    this.eventId,
    this.draftId,
    this.query,
    this.maxResults,
    this.timeMin,
    this.timeMax,
  });

  factory CalendarEventRequest.fromJson(Map<String, dynamic> json) => _$CalendarEventRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CalendarEventRequestToJson(this);
}

@JsonSerializable()
class CalendarEventResponse {
  final bool success;
  final String? message;
  final List<CalendarEvent>? events;
  final CalendarEvent? event;
  final String? draftId;
  final Map<String, dynamic>? data;

  CalendarEventResponse({
    required this.success,
    this.message,
    this.events,
    this.event,
    this.draftId,
    this.data,
  });

  factory CalendarEventResponse.fromJson(Map<String, dynamic> json) => _$CalendarEventResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CalendarEventResponseToJson(this);
}

@JsonSerializable()
class AvailabilityCheckRequest {
  final String query;

  AvailabilityCheckRequest({required this.query});

  factory AvailabilityCheckRequest.fromJson(Map<String, dynamic> json) => _$AvailabilityCheckRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AvailabilityCheckRequestToJson(this);
}

@JsonSerializable()
class AvailabilityCheckResponse {
  final bool success;
  final String? message;
  final bool? isAvailable;
  final List<Map<String, dynamic>>? conflicts;
  final Map<String, dynamic>? data;

  AvailabilityCheckResponse({
    required this.success,
    this.message,
    this.isAvailable,
    this.conflicts,
    this.data,
  });

  factory AvailabilityCheckResponse.fromJson(Map<String, dynamic> json) => _$AvailabilityCheckResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AvailabilityCheckResponseToJson(this);
}
