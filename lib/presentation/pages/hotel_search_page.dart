import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/hotel_bloc.dart';
import '../../core/services/hotel_service.dart';
import '../../core/repositories/hotel_repository.dart';
import '../../domain/usecases/hotel_usecases.dart';
import '../widgets/hotel_search_form.dart';
import '../widgets/hotel_results_list.dart';

class HotelSearchPage extends StatelessWidget {
  const HotelSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏨 Hotel Search'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocProvider(
        create: (context) => HotelBloc(
          searchHotels: SearchHotels(
            HotelRepositoryImpl(
              HotelService(),
            ),
          ),
          filterHotelsByRating: FilterHotelsByRating(
            HotelRepositoryImpl(
              HotelService(),
            ),
          ),
          getHotelDetails: GetHotelDetails(
            HotelRepositoryImpl(
              HotelService(),
            ),
          ),
          getAllHotelSearchIds: GetAllHotelSearchIds(
            HotelRepositoryImpl(
              HotelService(),
            ),
          ),
          deleteHotelSearch: DeleteHotelSearch(
            HotelRepositoryImpl(
              HotelService(),
            ),
          ),
          clearAllHotelSearches: ClearAllHotelSearches(
            HotelRepositoryImpl(
              HotelService(),
            ),
          ),
        ),
        child: const HotelSearchContent(),
      ),
    );
  }
}

class HotelSearchContent extends StatelessWidget {
  const HotelSearchContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HotelSearchForm(),
          const SizedBox(height: 20),
          Expanded(
            child: BlocBuilder<HotelBloc, HotelState>(
              builder: (context, state) {
                if (state is HotelLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is HotelSearchSuccess) {
                  return HotelResultsList(result: state.result);
                } else if (state is HotelError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                } else if (state is HotelInitial) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.hotel,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Search for Hotels',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Enter your destination and dates to find the perfect hotel',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
