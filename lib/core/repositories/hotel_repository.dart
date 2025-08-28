import 'package:dartz/dartz.dart';
import '../models/hotel_models.dart';
import '../services/hotel_service.dart';
import '../error/failures.dart';

abstract class HotelRepository {
  Future<Either<Failure, HotelSearchResult>> searchHotels({
    required String location,
    String? checkInDate,
    String? checkOutDate,
    int adults = 2,
    int children = 0,
    String currency = 'USD',
    String country = 'us',
    int? sortBy,
    List<int>? hotelClass,
    int maxResults = 20,
  });

  Future<Either<Failure, HotelFilterResult>> filterHotelsByRating(
    String searchId,
    double minRating,
  );

  Future<Either<Failure, String>> getHotelDetails(String searchId);
  
  Future<Either<Failure, List<String>>> getAllHotelSearchIds();
  
  Future<Either<Failure, bool>> deleteHotelSearch(String searchId);
  
  Future<Either<Failure, bool>> clearAllHotelSearches();
}

class HotelRepositoryImpl implements HotelRepository {
  final HotelService _hotelService;

  HotelRepositoryImpl(this._hotelService);

  @override
  Future<Either<Failure, HotelSearchResult>> searchHotels({
    required String location,
    String? checkInDate,
    String? checkOutDate,
    int adults = 2,
    int children = 0,
    String currency = 'USD',
    String country = 'us',
    int? sortBy,
    List<int>? hotelClass,
    int maxResults = 20,
  }) async {
    try {
      await _hotelService.initialize();
      
      final result = await _hotelService.searchHotels(
        location: location,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        adults: adults,
        children: children,
        currency: currency,
        country: country,
        sortBy: sortBy,
        hotelClass: hotelClass,
        maxResults: maxResults,
      );

      // Check if there's an error in the result
      if (result.fullDetails.containsKey('error')) {
        return Left(ServerFailure(result.fullDetails['error']));
      }

      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Error searching hotels: $e'));
    }
  }

  @override
  Future<Either<Failure, HotelFilterResult>> filterHotelsByRating(
    String searchId,
    double minRating,
  ) async {
    try {
      final result = await _hotelService.filterHotelsByRating(searchId, minRating);

      // Check if there's an error in the result
      if (result.fullDetails.containsKey('error')) {
        return Left(ServerFailure(result.fullDetails['error']));
      }

      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Error filtering hotels: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getHotelDetails(String searchId) async {
    try {
      final result = await _hotelService.getHotelDetails(searchId);
      
      if (result.startsWith('No hotel search found') || result.startsWith('Error')) {
        return Left(ServerFailure(result));
      }

      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Error getting hotel details: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAllHotelSearchIds() async {
    try {
      final result = await _hotelService.getAllHotelSearchIds();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Error getting hotel search IDs: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteHotelSearch(String searchId) async {
    try {
      final result = await _hotelService.deleteHotelSearch(searchId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Error deleting hotel search: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> clearAllHotelSearches() async {
    try {
      final result = await _hotelService.clearAllHotelSearches();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Error clearing hotel searches: $e'));
    }
  }
}
