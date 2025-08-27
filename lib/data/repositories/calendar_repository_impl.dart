import 'package:dartz/dartz.dart';
import '../../domain/entities/failure.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../datasources/calendar_remote_data_source.dart';
import '../models/calendar_event_model.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarRemoteDataSource remoteDataSource;

  CalendarRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<CalendarEvent>>> getEvents() async {
    try {
      final result = await remoteDataSource.getEvents();
      
      return result.fold(
        (failure) => Left(failure),
        (eventModels) => Right(eventModels.map((e) => e.toEntity()).toList()),
      );
    } catch (e) {
      return const Left(ServerFailure('Unexpected error fetching events'));
    }
  }

  @override
  Future<Either<Failure, List<CalendarEvent>>> getEventsByDate(DateTime date) async {
    try {
      final result = await remoteDataSource.getEventsByDate(date);
      
      return result.fold(
        (failure) => Left(failure),
        (eventModels) => Right(eventModels.map((e) => e.toEntity()).toList()),
      );
    } catch (e) {
      return const Left(ServerFailure('Unexpected error fetching events by date'));
    }
  }

  @override
  Future<Either<Failure, List<CalendarEvent>>> getEventsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final result = await remoteDataSource.getEventsByDateRange(startDate, endDate);
      
      return result.fold(
        (failure) => Left(failure),
        (eventModels) => Right(eventModels.map((e) => e.toEntity()).toList()),
      );
    } catch (e) {
      return const Left(ServerFailure('Unexpected error fetching events by date range'));
    }
  }

  @override
  Future<Either<Failure, CalendarEvent>> createEvent(CalendarEvent event) async {
    try {
      final eventModel = CalendarEventModel(
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
      
      final result = await remoteDataSource.createEvent(eventModel);
      
      return result.fold(
        (failure) => Left(failure),
        (createdEventModel) => Right(createdEventModel.toEntity()),
      );
    } catch (e) {
      return const Left(ServerFailure('Unexpected error creating event'));
    }
  }

  @override
  Future<Either<Failure, CalendarEvent>> updateEvent(CalendarEvent event) async {
    try {
      final eventModel = CalendarEventModel(
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
      
      final result = await remoteDataSource.updateEvent(eventModel);
      
      return result.fold(
        (failure) => Left(failure),
        (updatedEventModel) => Right(updatedEventModel.toEntity()),
      );
    } catch (e) {
      return const Left(ServerFailure('Unexpected error updating event'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent(String eventId) async {
    try {
      final result = await remoteDataSource.deleteEvent(eventId);
      return result;
    } catch (e) {
      return const Left(ServerFailure('Unexpected error deleting event'));
    }
  }

  @override
  Future<Either<Failure, CalendarEvent>> getEventById(String eventId) async {
    try {
      final result = await remoteDataSource.getEventById(eventId);
      
      return result.fold(
        (failure) => Left(failure),
        (eventModel) => Right(eventModel.toEntity()),
      );
    } catch (e) {
      return const Left(ServerFailure('Unexpected error fetching event'));
    }
  }
}
