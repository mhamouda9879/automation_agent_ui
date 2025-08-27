import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/failure.dart';
import '../../domain/usecases/calendar_usecases.dart';

// Events
abstract class CalendarBlocEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadEvents extends CalendarBlocEvent {}

class LoadEventsByDate extends CalendarBlocEvent {
  final DateTime date;

  LoadEventsByDate(this.date);

  @override
  List<Object?> get props => [date];
}

class LoadEventsByDateRange extends CalendarBlocEvent {
  final DateTime startDate;
  final DateTime endDate;

  LoadEventsByDateRange({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class CreateEvent extends CalendarBlocEvent {
  final CalendarEvent event;

  CreateEvent(this.event);

  @override
  List<Object?> get props => [event];
}

class UpdateEvent extends CalendarBlocEvent {
  final CalendarEvent event;

  UpdateEvent(this.event);

  @override
  List<Object?> get props => [event];
}

class DeleteEvent extends CalendarBlocEvent {
  final String eventId;

  DeleteEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class GetEventById extends CalendarBlocEvent {
  final String eventId;

  GetEventById(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

// States
abstract class CalendarState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CalendarInitial extends CalendarState {}

class CalendarLoading extends CalendarState {}

class EventsLoaded extends CalendarState {
  final List<CalendarEvent> events;

  EventsLoaded(this.events);

  @override
  List<Object?> get props => [events];
}

class EventCreated extends CalendarState {
  final CalendarEvent event;

  EventCreated(this.event);

  @override
  List<Object?> get props => [event];
}

class EventUpdated extends CalendarState {
  final CalendarEvent event;

  EventUpdated(this.event);

  @override
  List<Object?> get props => [event];
}

class EventDeleted extends CalendarState {
  final String eventId;

  EventDeleted(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class EventLoaded extends CalendarState {
  final CalendarEvent event;

  EventLoaded(this.event);

  @override
  List<Object?> get props => [event];
}

class CalendarError extends CalendarState {
  final String message;

  CalendarError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class CalendarBloc extends Bloc<CalendarBlocEvent, CalendarState> {
  final GetEvents getEvents;
  final GetEventsByDate getEventsByDate;
  final GetEventsByDateRange getEventsByDateRange;
  final CreateEventUseCase createEventUseCase;
  final UpdateEventUseCase updateEventUseCase;
  final DeleteEventUseCase deleteEventUseCase;
  final GetEventByIdUseCase getEventByIdUseCase;

  CalendarBloc({
    required this.getEvents,
    required this.getEventsByDate,
    required this.getEventsByDateRange,
    required this.createEventUseCase,
    required this.updateEventUseCase,
    required this.deleteEventUseCase,
    required this.getEventByIdUseCase,
  }) : super(CalendarInitial()) {
    on<LoadEvents>(_onLoadEvents);
    on<LoadEventsByDate>(_onLoadEventsByDate);
    on<LoadEventsByDateRange>(_onLoadEventsByDateRange);
    on<CreateEvent>(_onCreateEvent);
    on<UpdateEvent>(_onUpdateEvent);
    on<DeleteEvent>(_onDeleteEvent);
    on<GetEventById>(_onGetEventById);
  }

  Future<void> _onLoadEvents(
    LoadEvents event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    
    final result = await getEvents(NoParams());
    
    result.fold(
      (failure) => emit(CalendarError(failure.message)),
      (events) => emit(EventsLoaded(events)),
    );
  }

  Future<void> _onLoadEventsByDate(
    LoadEventsByDate event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    
    final result = await getEventsByDate(DateParams(date: event.date));
    
    result.fold(
      (failure) => emit(CalendarError(failure.message)),
      (events) => emit(EventsLoaded(events)),
    );
  }

  Future<void> _onLoadEventsByDateRange(
    LoadEventsByDateRange event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    
    final result = await getEventsByDateRange(DateRangeParams(
      startDate: event.startDate,
      endDate: event.endDate,
    ));
    
    result.fold(
      (failure) => emit(CalendarError(failure.message)),
      (events) => emit(EventsLoaded(events)),
    );
  }

  Future<void> _onCreateEvent(
    CreateEvent event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    
    final result = await createEventUseCase(CreateEventParams(event: event.event));
    
    result.fold(
      (failure) => emit(CalendarError(failure.message)),
      (createdEvent) => emit(EventCreated(createdEvent)),
    );
  }

  Future<void> _onUpdateEvent(
    UpdateEvent event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    
    final result = await updateEventUseCase(UpdateEventParams(event: event.event));
    
    result.fold(
      (failure) => emit(CalendarError(failure.message)),
      (updatedEvent) => emit(EventUpdated(updatedEvent)),
    );
  }

  Future<void> _onDeleteEvent(
    DeleteEvent event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    
    final result = await deleteEventUseCase(DeleteEventParams(eventId: event.eventId));
    
    result.fold(
      (failure) => emit(CalendarError(failure.message)),
      (_) => emit(EventDeleted(event.eventId)),
    );
  }

  Future<void> _onGetEventById(
    GetEventById event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    
    final result = await getEventByIdUseCase(GetEventByIdParams(eventId: event.eventId));
    
    result.fold(
      (failure) => emit(CalendarError(failure.message)),
      (event) => emit(EventLoaded(event)),
    );
  }
}
