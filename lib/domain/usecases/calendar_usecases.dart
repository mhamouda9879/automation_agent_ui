import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/calendar_event.dart';
import '../entities/failure.dart';
import '../repositories/calendar_repository.dart';

// Parameter classes
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}

class DateParams extends Equatable {
  final DateTime date;

  const DateParams({required this.date});

  @override
  List<Object> get props => [date];
}

class DateRangeParams extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const DateRangeParams({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [startDate, endDate];
}

class CreateEventParams extends Equatable {
  final CalendarEvent event;

  const CreateEventParams({required this.event});

  @override
  List<Object> get props => [event];
}

class UpdateEventParams extends Equatable {
  final CalendarEvent event;

  const UpdateEventParams({required this.event});

  @override
  List<Object> get props => [event];
}

class DeleteEventParams extends Equatable {
  final String eventId;

  const DeleteEventParams({required this.eventId});

  @override
  List<Object> get props => [eventId];
}

class GetEventByIdParams extends Equatable {
  final String eventId;

  const GetEventByIdParams({required this.eventId});

  @override
  List<Object> get props => [eventId];
}

// UseCase abstract class
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class GetEvents implements UseCase<List<CalendarEvent>, NoParams> {
  final CalendarRepository repository;

  GetEvents(this.repository);

  @override
  Future<Either<Failure, List<CalendarEvent>>> call(NoParams params) async {
    return await repository.getEvents();
  }
}

class GetEventsByDate implements UseCase<List<CalendarEvent>, DateParams> {
  final CalendarRepository repository;

  GetEventsByDate(this.repository);

  @override
  Future<Either<Failure, List<CalendarEvent>>> call(DateParams params) async {
    return await repository.getEventsByDate(params.date);
  }
}

class GetEventsByDateRange implements UseCase<List<CalendarEvent>, DateRangeParams> {
  final CalendarRepository repository;

  GetEventsByDateRange(this.repository);

  @override
  Future<Either<Failure, List<CalendarEvent>>> call(DateRangeParams params) async {
    return await repository.getEventsByDateRange(params.startDate, params.endDate);
  }
}

class CreateEventUseCase implements UseCase<CalendarEvent, CreateEventParams> {
  final CalendarRepository repository;

  CreateEventUseCase(this.repository);

  @override
  Future<Either<Failure, CalendarEvent>> call(CreateEventParams params) async {
    return await repository.createEvent(params.event);
  }
}

class UpdateEventUseCase implements UseCase<CalendarEvent, UpdateEventParams> {
  final CalendarRepository repository;

  UpdateEventUseCase(this.repository);

  @override
  Future<Either<Failure, CalendarEvent>> call(UpdateEventParams params) async {
    return await repository.updateEvent(params.event);
  }
}

class DeleteEventUseCase implements UseCase<void, DeleteEventParams> {
  final CalendarRepository repository;

  DeleteEventUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteEventParams params) async {
    return await repository.deleteEvent(params.eventId);
  }
}

class GetEventByIdUseCase implements UseCase<CalendarEvent, GetEventByIdParams> {
  final CalendarRepository repository;

  GetEventByIdUseCase(this.repository);

  @override
  Future<Either<Failure, CalendarEvent>> call(GetEventByIdParams params) async {
    return await repository.getEventById(params.eventId);
  }
}
