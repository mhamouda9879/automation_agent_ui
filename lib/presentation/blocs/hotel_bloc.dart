import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/hotel_usecases.dart';
import '../../core/models/hotel_models.dart';
import '../../core/error/failures.dart';

// Events
abstract class HotelEvent extends Equatable {
  const HotelEvent();

  @override
  List<Object?> get props => [];
}

class SearchHotelsEvent extends HotelEvent {
  final String location;
  final String? checkInDate;
  final String? checkOutDate;
  final int adults;
  final int children;
  final String currency;
  final String country;
  final int? sortBy;
  final List<int>? hotelClass;
  final int maxResults;

  const SearchHotelsEvent({
    required this.location,
    this.checkInDate,
    this.checkOutDate,
    this.adults = 2,
    this.children = 0,
    this.currency = 'USD',
    this.country = 'us',
    this.sortBy,
    this.hotelClass,
    this.maxResults = 20,
  });

  @override
  List<Object?> get props => [
    location,
    checkInDate,
    checkOutDate,
    adults,
    children,
    currency,
    country,
    sortBy,
    hotelClass,
    maxResults,
  ];
}

class FilterHotelsByRatingEvent extends HotelEvent {
  final String searchId;
  final double minRating;

  const FilterHotelsByRatingEvent({
    required this.searchId,
    required this.minRating,
  });

  @override
  List<Object> get props => [searchId, minRating];
}

class GetHotelDetailsEvent extends HotelEvent {
  final String searchId;

  const GetHotelDetailsEvent({required this.searchId});

  @override
  List<Object> get props => [searchId];
}

class GetAllHotelSearchIdsEvent extends HotelEvent {
  const GetAllHotelSearchIdsEvent();
}

class DeleteHotelSearchEvent extends HotelEvent {
  final String searchId;

  const DeleteHotelSearchEvent({required this.searchId});

  @override
  List<Object> get props => [searchId];
}

class ClearAllHotelSearchesEvent extends HotelEvent {
  const ClearAllHotelSearchesEvent();
}

// States
abstract class HotelState extends Equatable {
  const HotelState();

  @override
  List<Object?> get props => [];
}

class HotelInitial extends HotelState {}

class HotelLoading extends HotelState {}

class HotelSearchSuccess extends HotelState {
  final HotelSearchResult result;

  const HotelSearchSuccess(this.result);

  @override
  List<Object> get props => [result];
}

class HotelFilterSuccess extends HotelState {
  final HotelFilterResult result;

  const HotelFilterSuccess(this.result);

  @override
  List<Object> get props => [result];
}

class HotelDetailsSuccess extends HotelState {
  final String details;

  const HotelDetailsSuccess(this.details);

  @override
  List<Object> get props => [details];
}

class HotelSearchIdsSuccess extends HotelState {
  final List<String> searchIds;

  const HotelSearchIdsSuccess(this.searchIds);

  @override
  List<Object> get props => [searchIds];
}

class HotelOperationSuccess extends HotelState {
  final bool result;

  const HotelOperationSuccess(this.result);

  @override
  List<Object> get props => [result];
}

class HotelError extends HotelState {
  final String message;

  const HotelError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class HotelBloc extends Bloc<HotelEvent, HotelState> {
  final SearchHotels _searchHotels;
  final FilterHotelsByRating _filterHotelsByRating;
  final GetHotelDetails _getHotelDetails;
  final GetAllHotelSearchIds _getAllHotelSearchIds;
  final DeleteHotelSearch _deleteHotelSearch;
  final ClearAllHotelSearches _clearAllHotelSearches;

  HotelBloc({
    required SearchHotels searchHotels,
    required FilterHotelsByRating filterHotelsByRating,
    required GetHotelDetails getHotelDetails,
    required GetAllHotelSearchIds getAllHotelSearchIds,
    required DeleteHotelSearch deleteHotelSearch,
    required ClearAllHotelSearches clearAllHotelSearches,
  }) : _searchHotels = searchHotels,
       _filterHotelsByRating = filterHotelsByRating,
       _getHotelDetails = getHotelDetails,
       _getAllHotelSearchIds = getAllHotelSearchIds,
       _deleteHotelSearch = deleteHotelSearch,
       _clearAllHotelSearches = clearAllHotelSearches,
       super(HotelInitial()) {
    
    on<SearchHotelsEvent>(_onSearchHotels);
    on<FilterHotelsByRatingEvent>(_onFilterHotelsByRating);
    on<GetHotelDetailsEvent>(_onGetHotelDetails);
    on<GetAllHotelSearchIdsEvent>(_onGetAllHotelSearchIds);
    on<DeleteHotelSearchEvent>(_onDeleteHotelSearch);
    on<ClearAllHotelSearchesEvent>(_onClearAllHotelSearches);
  }

  Future<void> _onSearchHotels(
    SearchHotelsEvent event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelLoading());

    final params = SearchHotelsParams(
      location: event.location,
      checkInDate: event.checkInDate,
      checkOutDate: event.checkOutDate,
      adults: event.adults,
      children: event.children,
      currency: event.currency,
      country: event.country,
      sortBy: event.sortBy,
      hotelClass: event.hotelClass,
      maxResults: event.maxResults,
    );

    final result = await _searchHotels(params);

    result.fold(
      (failure) => emit(HotelError(_mapFailureToMessage(failure))),
      (hotelResult) => emit(HotelSearchSuccess(hotelResult)),
    );
  }

  Future<void> _onFilterHotelsByRating(
    FilterHotelsByRatingEvent event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelLoading());

    final params = FilterHotelsByRatingParams(
      searchId: event.searchId,
      minRating: event.minRating,
    );

    final result = await _filterHotelsByRating(params);

    result.fold(
      (failure) => emit(HotelError(_mapFailureToMessage(failure))),
      (filterResult) => emit(HotelFilterSuccess(filterResult)),
    );
  }

  Future<void> _onGetHotelDetails(
    GetHotelDetailsEvent event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelLoading());

    final result = await _getHotelDetails(event.searchId);

    result.fold(
      (failure) => emit(HotelError(_mapFailureToMessage(failure))),
      (details) => emit(HotelDetailsSuccess(details)),
    );
  }

  Future<void> _onGetAllHotelSearchIds(
    GetAllHotelSearchIdsEvent event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelLoading());

    final result = await _getAllHotelSearchIds(NoParams());

    result.fold(
      (failure) => emit(HotelError(_mapFailureToMessage(failure))),
      (searchIds) => emit(HotelSearchIdsSuccess(searchIds)),
    );
  }

  Future<void> _onDeleteHotelSearch(
    DeleteHotelSearchEvent event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelLoading());

    final result = await _deleteHotelSearch(event.searchId);

    result.fold(
      (failure) => emit(HotelError(_mapFailureToMessage(failure))),
      (success) => emit(HotelOperationSuccess(success)),
    );
  }

  Future<void> _onClearAllHotelSearches(
    ClearAllHotelSearchesEvent event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelLoading());

    final result = await _clearAllHotelSearches(NoParams());

    result.fold(
      (failure) => emit(HotelError(_mapFailureToMessage(failure))),
      (success) => emit(HotelOperationSuccess(success)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message;
      case CacheFailure:
        return failure.message;
      case NetworkFailure:
        return failure.message;
      case LocationFailure:
        return failure.message;
      case ValidationFailure:
        return failure.message;
      case AuthenticationFailure:
        return failure.message;
      default:
        return 'Unexpected error occurred';
    }
  }
}
