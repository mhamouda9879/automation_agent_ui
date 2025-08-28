import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/models/hotel_models.dart';
import '../blocs/hotel_bloc.dart';

class HotelResultsList extends StatelessWidget {
  final HotelSearchResult result;

  const HotelResultsList({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search summary
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search Results',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Location: ${result.summary.location}'),
                Text('Dates: ${result.summary.dates}'),
                Text('Guests: ${result.summary.guests}'),
                Text('Total Properties: ${result.summary.totalProperties}'),
                if (result.summary.priceRange != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Price Range: \$${result.summary.priceRange!.minPrice.toStringAsFixed(0)} - \$${result.summary.priceRange!.maxPrice.toStringAsFixed(0)} ${result.summary.priceRange!.currency}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Properties list
        Expanded(
          child: ListView.builder(
            itemCount: result.fullDetails['properties']?.length ?? 0,
            itemBuilder: (context, index) {
              final property = result.fullDetails['properties'][index];
              return HotelPropertyCard(
                property: property,
                searchId: result.summary.searchId,
              );
            },
          ),
        ),
      ],
    );
  }
}

class HotelPropertyCard extends StatelessWidget {
  final Map<String, dynamic> property;
  final String searchId;

  const HotelPropertyCard({
    super.key,
    required this.property,
    required this.searchId,
  });

  @override
  Widget build(BuildContext context) {
    final name = property['name'] ?? 'Unknown Hotel';
    final address = property['address'] ?? 'Address not available';
    final rating = property['overall_rating']?.toDouble() ?? 0.0;
    final reviewCount = property['review_count'] ?? 0;
    final imageUrl = property['image_url'];
    final ratePerNight = property['rate_per_night'];
    final hotelClass = property['hotel_class'] ?? '';
    final brand = property['brand'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hotel image
          if (imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.hotel,
                      size: 64,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hotel name and brand
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (brand.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          brand,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Address
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Rating and reviews
                Row(
                  children: [
                    if (rating > 0) ...[
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (reviewCount > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '($reviewCount reviews)',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                    const Spacer(),
                    if (hotelClass.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          hotelClass,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Price information
                if (ratePerNight != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        color: Colors.green[600],
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Per Night:',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (ratePerNight['extracted_lowest'] != null)
                        Text(
                          '\$${ratePerNight['extracted_lowest'].toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.green[600],
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showHotelDetails(context),
                        icon: const Icon(Icons.info_outline),
                        label: const Text('Details'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _bookHotel(context),
                        icon: const Icon(Icons.book_online),
                        label: const Text('Book Now'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
   
    ));
  }

  void _showHotelDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(property['name'] ?? 'Hotel Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Address: ${property['address'] ?? 'Not available'}'),
              if (property['description'] != null)
                Text('Description: ${property['description']}'),
              if (property['amenities'] != null) ...[
                const SizedBox(height: 8),
                const Text('Amenities:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...(property['amenities'] as List).map((amenity) => Text('• $amenity')).toList(),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _bookHotel(BuildContext context) {
    // This would typically navigate to a booking page or external booking service
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking functionality would be implemented here'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
