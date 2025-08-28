import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/models/hotel_models.dart';
import '../../core/error/failures.dart';
import '../../core/repositories/hotel_repository.dart';

class SearchHotels implements UseCase<HotelSearchResult, SearchHotelsParams> {
  final HotelRepository repository;

  SearchHotels(this.repository);

  @override
  Future<Either<Failure, HotelSearchResult>> call(SearchHotelsParams params) async {
    return await repository.searchHotels(
      location: params.location,
      checkInDate: params.checkInDate,
      checkOutDate: params.checkOutDate,
      adults: params.adults,
      children: params.children,
      currency: params.currency,
      country: params.country,
      sortBy: params.sortBy,
      hotelClass: params.hotelClass,
      maxResults: params.maxResults,
    );
  }
}

class SearchHotelsParams extends Equatable {
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

  const SearchHotelsParams({
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

class FilterHotelsByRating implements UseCase<HotelFilterResult, FilterHotelsByRatingParams> {
  final HotelRepository repository;

  FilterHotelsByRating(this.repository);

  @override
  Future<Either<Failure, HotelFilterResult>> call(FilterHotelsByRatingParams params) async {
    return await repository.filterHotelsByRating(
      params.searchId,
      params.minRating,
    );
  }
}

class FilterHotelsByRatingParams extends Equatable {
  final String searchId;
  final double minRating;

  const FilterHotelsByRatingParams({
    required this.searchId,
    required this.minRating,
  });

  @override
  List<Object> get props => [searchId, minRating];
}

class GetHotelDetails implements UseCase<String, String> {
  final HotelRepository repository;

  GetHotelDetails(this.repository);

  @override
  Future<Either<Failure, String>> call(String searchId) async {
    return await repository.getHotelDetails(searchId);
  }
}

class GetAllHotelSearchIds implements UseCase<List<String>, NoParams> {
  final HotelRepository repository;

  GetAllHotelSearchIds(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) async {
    return await repository.getAllHotelSearchIds();
  }
}

class DeleteHotelSearch implements UseCase<bool, String> {
  final HotelRepository repository;

  DeleteHotelSearch(this.repository);

  @override
  Future<Either<Failure, bool>> call(String searchId) async {
    return await repository.deleteHotelSearch(searchId);
  }
}

class ClearAllHotelSearches implements UseCase<bool, NoParams> {
  final HotelRepository repository;

  ClearAllHotelSearches(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.clearAllHotelSearches();
  }
}

class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
