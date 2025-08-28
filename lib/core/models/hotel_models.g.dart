// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hotel_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HotelSearchRequest _$HotelSearchRequestFromJson(Map<String, dynamic> json) =>
    HotelSearchRequest(
      location: json['location'] as String,
      checkInDate: json['checkInDate'] as String?,
      checkOutDate: json['checkOutDate'] as String?,
      adults: (json['adults'] as num).toInt(),
      children: (json['children'] as num).toInt(),
      currency: json['currency'] as String,
      country: json['country'] as String,
      sortBy: (json['sortBy'] as num?)?.toInt(),
      hotelClass: (json['hotelClass'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      maxResults: (json['maxResults'] as num).toInt(),
    );

Map<String, dynamic> _$HotelSearchRequestToJson(HotelSearchRequest instance) =>
    <String, dynamic>{
      'location': instance.location,
      'checkInDate': instance.checkInDate,
      'checkOutDate': instance.checkOutDate,
      'adults': instance.adults,
      'children': instance.children,
      'currency': instance.currency,
      'country': instance.country,
      'sortBy': instance.sortBy,
      'hotelClass': instance.hotelClass,
      'maxResults': instance.maxResults,
    };

HotelProperty _$HotelPropertyFromJson(Map<String, dynamic> json) =>
    HotelProperty(
      name: json['name'] as String?,
      address: json['address'] as String?,
      overallRating: (json['overallRating'] as num?)?.toDouble(),
      reviewCount: (json['reviewCount'] as num?)?.toInt(),
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      amenities: (json['amenities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      ratePerNight: json['ratePerNight'] == null
          ? null
          : HotelRatePerNight.fromJson(
              json['ratePerNight'] as Map<String, dynamic>,
            ),
      hotelClass: json['hotelClass'] as String?,
      brand: json['brand'] as String?,
      propertyType: json['propertyType'] as String?,
    );

Map<String, dynamic> _$HotelPropertyToJson(HotelProperty instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'overallRating': instance.overallRating,
      'reviewCount': instance.reviewCount,
      'imageUrl': instance.imageUrl,
      'description': instance.description,
      'amenities': instance.amenities,
      'ratePerNight': instance.ratePerNight,
      'hotelClass': instance.hotelClass,
      'brand': instance.brand,
      'propertyType': instance.propertyType,
    };

HotelRatePerNight _$HotelRatePerNightFromJson(Map<String, dynamic> json) =>
    HotelRatePerNight(
      extractedLowest: (json['extractedLowest'] as num?)?.toDouble(),
      extractedHighest: (json['extractedHighest'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      rateType: json['rateType'] as String?,
    );

Map<String, dynamic> _$HotelRatePerNightToJson(HotelRatePerNight instance) =>
    <String, dynamic>{
      'extractedLowest': instance.extractedLowest,
      'extractedHighest': instance.extractedHighest,
      'currency': instance.currency,
      'rateType': instance.rateType,
    };

HotelSearchMetadata _$HotelSearchMetadataFromJson(Map<String, dynamic> json) =>
    HotelSearchMetadata(
      searchId: json['searchId'] as String,
      location: json['location'] as String,
      originalLocationRequest: json['originalLocationRequest'] as String?,
      checkInDate: json['checkInDate'] as String,
      checkOutDate: json['checkOutDate'] as String,
      originalDatesRequest:
          json['originalDatesRequest'] as Map<String, dynamic>?,
      guests: Map<String, int>.from(json['guests'] as Map),
      searchType: json['searchType'] as String,
      currency: json['currency'] as String,
      filters: json['filters'] as Map<String, dynamic>,
      searchTimestamp: json['searchTimestamp'] as String,
    );

Map<String, dynamic> _$HotelSearchMetadataToJson(
  HotelSearchMetadata instance,
) => <String, dynamic>{
  'searchId': instance.searchId,
  'location': instance.location,
  'originalLocationRequest': instance.originalLocationRequest,
  'checkInDate': instance.checkInDate,
  'checkOutDate': instance.checkOutDate,
  'originalDatesRequest': instance.originalDatesRequest,
  'guests': instance.guests,
  'searchType': instance.searchType,
  'currency': instance.currency,
  'filters': instance.filters,
  'searchTimestamp': instance.searchTimestamp,
};

HotelPriceRange _$HotelPriceRangeFromJson(Map<String, dynamic> json) =>
    HotelPriceRange(
      minPrice: (json['minPrice'] as num).toDouble(),
      maxPrice: (json['maxPrice'] as num).toDouble(),
      currency: json['currency'] as String,
    );

Map<String, dynamic> _$HotelPriceRangeToJson(HotelPriceRange instance) =>
    <String, dynamic>{
      'minPrice': instance.minPrice,
      'maxPrice': instance.maxPrice,
      'currency': instance.currency,
    };

HotelSearchSummary _$HotelSearchSummaryFromJson(
  Map<String, dynamic> json,
) => HotelSearchSummary(
  searchId: json['searchId'] as String,
  totalProperties: (json['totalProperties'] as num).toInt(),
  location: json['location'] as String,
  originalLocationRequest: json['originalLocationRequest'] as String?,
  dates: json['dates'] as String,
  originalDatesRequest: json['originalDatesRequest'] as Map<String, dynamic>?,
  guests: json['guests'] as String,
  priceRange: json['priceRange'] == null
      ? null
      : HotelPriceRange.fromJson(json['priceRange'] as Map<String, dynamic>),
  searchType: json['searchType'] as String,
  searchParameters: json['searchParameters'] as Map<String, dynamic>,
);

Map<String, dynamic> _$HotelSearchSummaryToJson(HotelSearchSummary instance) =>
    <String, dynamic>{
      'searchId': instance.searchId,
      'totalProperties': instance.totalProperties,
      'location': instance.location,
      'originalLocationRequest': instance.originalLocationRequest,
      'dates': instance.dates,
      'originalDatesRequest': instance.originalDatesRequest,
      'guests': instance.guests,
      'priceRange': instance.priceRange,
      'searchType': instance.searchType,
      'searchParameters': instance.searchParameters,
    };

HotelSearchResult _$HotelSearchResultFromJson(Map<String, dynamic> json) =>
    HotelSearchResult(
      summary: HotelSearchSummary.fromJson(
        json['summary'] as Map<String, dynamic>,
      ),
      fullDetails: json['fullDetails'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$HotelSearchResultToJson(HotelSearchResult instance) =>
    <String, dynamic>{
      'summary': instance.summary,
      'fullDetails': instance.fullDetails,
    };

HotelFilterResult _$HotelFilterResultFromJson(Map<String, dynamic> json) =>
    HotelFilterResult(
      summary: HotelSearchSummary.fromJson(
        json['summary'] as Map<String, dynamic>,
      ),
      fullDetails: json['fullDetails'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$HotelFilterResultToJson(HotelFilterResult instance) =>
    <String, dynamic>{
      'summary': instance.summary,
      'fullDetails': instance.fullDetails,
    };

LocationResult _$LocationResultFromJson(Map<String, dynamic> json) =>
    LocationResult(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$LocationResultToJson(LocationResult instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'error': instance.error,
    };

ReverseGeocodeResult _$ReverseGeocodeResultFromJson(
  Map<String, dynamic> json,
) => ReverseGeocodeResult(
  results: (json['results'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
  error: json['error'] as String?,
);

Map<String, dynamic> _$ReverseGeocodeResultToJson(
  ReverseGeocodeResult instance,
) => <String, dynamic>{'results': instance.results, 'error': instance.error};
