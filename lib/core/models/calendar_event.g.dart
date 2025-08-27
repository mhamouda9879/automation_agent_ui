// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarEvent _$CalendarEventFromJson(Map<String, dynamic> json) =>
    CalendarEvent(
      id: json['id'] as String?,
      summary: json['summary'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      location: json['location'] as String?,
      description: json['description'] as String?,
      attendees: (json['attendees'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      allDay: json['allDay'] as bool? ?? false,
      draftId: json['draftId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$CalendarEventToJson(CalendarEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'summary': instance.summary,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'location': instance.location,
      'description': instance.description,
      'attendees': instance.attendees,
      'allDay': instance.allDay,
      'draftId': instance.draftId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'status': instance.status,
    };

CalendarEventRequest _$CalendarEventRequestFromJson(
  Map<String, dynamic> json,
) => CalendarEventRequest(
  operation: json['operation'] as String,
  summary: json['summary'] as String?,
  startTime: json['startTime'] as String?,
  endTime: json['endTime'] as String?,
  location: json['location'] as String?,
  description: json['description'] as String?,
  attendees: (json['attendees'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  allDay: json['allDay'] as bool?,
  eventId: json['eventId'] as String?,
  draftId: json['draftId'] as String?,
  query: json['query'] as String?,
  maxResults: (json['maxResults'] as num?)?.toInt(),
  timeMin: json['timeMin'] as String?,
  timeMax: json['timeMax'] as String?,
);

Map<String, dynamic> _$CalendarEventRequestToJson(
  CalendarEventRequest instance,
) => <String, dynamic>{
  'operation': instance.operation,
  'summary': instance.summary,
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'location': instance.location,
  'description': instance.description,
  'attendees': instance.attendees,
  'allDay': instance.allDay,
  'eventId': instance.eventId,
  'draftId': instance.draftId,
  'query': instance.query,
  'maxResults': instance.maxResults,
  'timeMin': instance.timeMin,
  'timeMax': instance.timeMax,
};

CalendarEventResponse _$CalendarEventResponseFromJson(
  Map<String, dynamic> json,
) => CalendarEventResponse(
  success: json['success'] as bool,
  message: json['message'] as String?,
  events: (json['events'] as List<dynamic>?)
      ?.map((e) => CalendarEvent.fromJson(e as Map<String, dynamic>))
      .toList(),
  event: json['event'] == null
      ? null
      : CalendarEvent.fromJson(json['event'] as Map<String, dynamic>),
  draftId: json['draftId'] as String?,
  data: json['data'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$CalendarEventResponseToJson(
  CalendarEventResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'events': instance.events,
  'event': instance.event,
  'draftId': instance.draftId,
  'data': instance.data,
};

AvailabilityCheckRequest _$AvailabilityCheckRequestFromJson(
  Map<String, dynamic> json,
) => AvailabilityCheckRequest(query: json['query'] as String);

Map<String, dynamic> _$AvailabilityCheckRequestToJson(
  AvailabilityCheckRequest instance,
) => <String, dynamic>{'query': instance.query};

AvailabilityCheckResponse _$AvailabilityCheckResponseFromJson(
  Map<String, dynamic> json,
) => AvailabilityCheckResponse(
  success: json['success'] as bool,
  message: json['message'] as String?,
  isAvailable: json['isAvailable'] as bool?,
  conflicts: (json['conflicts'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
  data: json['data'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$AvailabilityCheckResponseToJson(
  AvailabilityCheckResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'isAvailable': instance.isAvailable,
  'conflicts': instance.conflicts,
  'data': instance.data,
};
