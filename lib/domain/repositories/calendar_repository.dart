import 'package:dartz/dartz.dart';
import '../entities/calendar_event.dart';
import '../entities/failure.dart';

abstract class CalendarRepository {
  Future<Either<Failure, List<CalendarEvent>>> getEvents();
  Future<Either<Failure, List<CalendarEvent>>> getEventsByDate(DateTime date);
  Future<Either<Failure, List<CalendarEvent>>> getEventsByDateRange(DateTime startDate, DateTime endDate);
  Future<Either<Failure, CalendarEvent>> createEvent(CalendarEvent event);
  Future<Either<Failure, CalendarEvent>> updateEvent(CalendarEvent event);
  Future<Either<Failure, void>> deleteEvent(String eventId);
  Future<Either<Failure, CalendarEvent>> getEventById(String eventId);
}
