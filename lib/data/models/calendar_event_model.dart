import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/calendar_event.dart';

part 'calendar_event_model.g.dart';

@JsonSerializable()
class CalendarEventModel extends CalendarEvent {
  const CalendarEventModel({
    required super.id,
    required super.title,
    required super.description,
    required super.startTime,
    required super.endTime,
    super.location,
    super.isAllDay,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) => _$CalendarEventModelFromJson(json);

  Map<String, dynamic> toJson() => _$CalendarEventModelToJson(this);

  factory CalendarEventModel.fromEntity(CalendarEvent event) {
    return CalendarEventModel(
      id: event.id,
      title: event.title,
      description: event.description,
      startTime: event.startTime,
      endTime: event.endTime,
      location: event.location,
      isAllDay: event.isAllDay,
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
    );
  }

  CalendarEvent toEntity() {
    return CalendarEvent(
      id: id,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      location: location,
      isAllDay: isAllDay,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
