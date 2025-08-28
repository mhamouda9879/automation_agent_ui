import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'hotel_models.g.dart';

@JsonSerializable()
class HotelSearchRequest extends Equatable {
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

  const HotelSearchRequest({
    required this.location,
    this.checkInDate,
    this.checkOutDate,
    required this.adults,
    required this.children,
    required this.currency,
    required this.country,
    this.sortBy,
    this.hotelClass,
    required this.maxResults,
  });

  factory HotelSearchRequest.fromJson(Map<String, dynamic> json) =>
      _$HotelSearchRequestFromJson(json);

  Map<String, dynamic> toJson() => _$HotelSearchRequestToJson(this);

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

  HotelSearchRequest copyWith({
    String? location,
    String? checkInDate,
    String? checkOutDate,
    int? adults,
    int? children,
    String? currency,
    String? country,
    int? sortBy,
    List<int>? hotelClass,
    int? maxResults,
  }) {
    return HotelSearchRequest(
      location: location ?? this.location,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      currency: currency ?? this.currency,
      country: country ?? this.country,
      sortBy: sortBy ?? this.sortBy,
      hotelClass: hotelClass ?? this.hotelClass,
      maxResults: maxResults ?? this.maxResults,
    );
  }
}

@JsonSerializable()
class HotelProperty extends Equatable {
  final String? name;
  final String? address;
  final double? overallRating;
  final int? reviewCount;
  final String? imageUrl;
  final String? description;
  final List<String>? amenities;
  final HotelRatePerNight? ratePerNight;
  final String? hotelClass;
  final String? brand;
  final String? propertyType;

  const HotelProperty({
    this.name,
    this.address,
    this.overallRating,
    this.reviewCount,
    this.imageUrl,
    this.description,
    this.amenities,
    this.ratePerNight,
    this.hotelClass,
    this.brand,
    this.propertyType,
  });

  factory HotelProperty.fromJson(Map<String, dynamic> json) =>
      _$HotelPropertyFromJson(json);

  Map<String, dynamic> toJson() => _$HotelPropertyToJson(this);

  @override
  List<Object?> get props => [
        name,
        address,
        overallRating,
        reviewCount,
        imageUrl,
        description,
        amenities,
        ratePerNight,
        hotelClass,
        brand,
        propertyType,
      ];
}

@JsonSerializable()
class HotelRatePerNight extends Equatable {
  final double? extractedLowest;
  final double? extractedHighest;
  final String? currency;
  final String? rateType;

  const HotelRatePerNight({
    this.extractedLowest,
    this.extractedHighest,
    this.currency,
    this.rateType,
  });

  factory HotelRatePerNight.fromJson(Map<String, dynamic> json) =>
      _$HotelRatePerNightFromJson(json);

  Map<String, dynamic> toJson() => _$HotelRatePerNightToJson(this);

  @override
  List<Object?> get props => [
        extractedLowest,
        extractedHighest,
        currency,
        rateType,
      ];
}

@JsonSerializable()
class HotelSearchMetadata extends Equatable {
  final String searchId;
  final String location;
  final String? originalLocationRequest;
  final String checkInDate;
  final String checkOutDate;
  final Map<String, dynamic>? originalDatesRequest;
  final Map<String, int> guests;
  final String searchType;
  final String currency;
  final Map<String, dynamic> filters;
  final String searchTimestamp;

  const HotelSearchMetadata({
    required this.searchId,
    required this.location,
    this.originalLocationRequest,
    required this.checkInDate,
    required this.checkOutDate,
    this.originalDatesRequest,
    required this.guests,
    required this.searchType,
    required this.currency,
    required this.filters,
    required this.searchTimestamp,
  });

  factory HotelSearchMetadata.fromJson(Map<String, dynamic> json) =>
      _$HotelSearchMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$HotelSearchMetadataToJson(this);

  @override
  List<Object?> get props => [
        searchId,
        location,
        originalLocationRequest,
        checkInDate,
        checkOutDate,
        originalDatesRequest,
        guests,
        searchType,
        currency,
        filters,
        searchTimestamp,
      ];
}

@JsonSerializable()
class HotelPriceRange extends Equatable {
  final double minPrice;
  final double maxPrice;
  final String currency;

  const HotelPriceRange({
    required this.minPrice,
    required this.maxPrice,
    required this.currency,
  });

  factory HotelPriceRange.fromJson(Map<String, dynamic> json) =>
      _$HotelPriceRangeFromJson(json);

  Map<String, dynamic> toJson() => _$HotelPriceRangeToJson(this);

  @override
  List<Object?> get props => [minPrice, maxPrice, currency];
}

@JsonSerializable()
class HotelSearchSummary extends Equatable {
  final String searchId;
  final int totalProperties;
  final String location;
  final String? originalLocationRequest;
  final String dates;
  final Map<String, dynamic>? originalDatesRequest;
  final String guests;
  final HotelPriceRange? priceRange;
  final String searchType;
  final Map<String, dynamic> searchParameters;

  const HotelSearchSummary({
    required this.searchId,
    required this.totalProperties,
    required this.location,
    this.originalLocationRequest,
    required this.dates,
    this.originalDatesRequest,
    required this.guests,
    this.priceRange,
    required this.searchType,
    required this.searchParameters,
  });

  factory HotelSearchSummary.fromJson(Map<String, dynamic> json) =>
      _$HotelSearchSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$HotelSearchSummaryToJson(this);

  @override
  List<Object?> get props => [
        searchId,
        totalProperties,
        location,
        originalLocationRequest,
        dates,
        originalDatesRequest,
        guests,
        priceRange,
        searchType,
        searchParameters,
      ];
}

@JsonSerializable()
class HotelSearchResult extends Equatable {
  final HotelSearchSummary summary;
  final Map<String, dynamic> fullDetails;

  const HotelSearchResult({
    required this.summary,
    required this.fullDetails,
  });

  factory HotelSearchResult.fromJson(Map<String, dynamic> json) =>
      _$HotelSearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$HotelSearchResultToJson(this);

  @override
  List<Object?> get props => [summary, fullDetails];
}

@JsonSerializable()
class HotelFilterResult extends Equatable {
  final HotelSearchSummary summary;
  final Map<String, dynamic> fullDetails;

  const HotelFilterResult({
    required this.summary,
    required this.fullDetails,
  });

  factory HotelFilterResult.fromJson(Map<String, dynamic> json) =>
      _$HotelFilterResultFromJson(json);

  Map<String, dynamic> toJson() => _$HotelFilterResultToJson(this);

  @override
  List<Object?> get props => [summary, fullDetails];
}

@JsonSerializable()
class LocationResult extends Equatable {
  final double? latitude;
  final double? longitude;
  final String? error;

  const LocationResult({
    this.latitude,
    this.longitude,
    this.error,
  });

  factory LocationResult.fromJson(Map<String, dynamic> json) =>
      _$LocationResultFromJson(json);

  Map<String, dynamic> toJson() => _$LocationResultToJson(this);

  @override
  List<Object?> get props => [latitude, longitude, error];
}

@JsonSerializable()
class ReverseGeocodeResult extends Equatable {
  final List<Map<String, dynamic>>? results;
  final String? error;

  const ReverseGeocodeResult({
    this.results,
    this.error,
  });

  factory ReverseGeocodeResult.fromJson(Map<String, dynamic> json) =>
      _$ReverseGeocodeResultFromJson(json);

  Map<String, dynamic> toJson() => _$ReverseGeocodeResultToJson(this);

  @override
  List<Object?> get props => [results, error];
}
