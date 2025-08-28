import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/hotel_bloc.dart';

class HotelSearchForm extends StatefulWidget {
  const HotelSearchForm({super.key});

  @override
  State<HotelSearchForm> createState() => _HotelSearchFormState();
}

class _HotelSearchFormState extends State<HotelSearchForm> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _adultsController = TextEditingController(text: '2');
  final _childrenController = TextEditingController(text: '0');
  final _maxResultsController = TextEditingController(text: '20');
  
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  String _selectedCurrency = 'USD';
  String _selectedCountry = 'us';
  int? _selectedSortBy;
  List<int> _selectedHotelClasses = [];

  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD'];
  final List<String> _countries = ['us', 'gb', 'de', 'fr', 'jp', 'ca', 'au'];
  final List<Map<String, dynamic>> _sortOptions = const [
    {'value': 0, 'label': 'Relevance'},
    {'value': 1, 'label': 'Price'},
    {'value': 2, 'label': 'Rating'},
    {'value': 3, 'label': 'Distance'},
  ];
  final List<Map<String, dynamic>> _hotelClassOptions = const [
    {'value': 1, 'label': 'Budget'},
    {'value': 2, 'label': 'Economy'},
    {'value': 3, 'label': 'Mid-Range'},
    {'value': 4, 'label': 'Upscale'},
    {'value': 5, 'label': 'Luxury'},
  ];

  @override
  void dispose() {
    _locationController.dispose();
    _adultsController.dispose();
    _childrenController.dispose();
    _maxResultsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Search Hotels',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Location field
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Destination',
                  hintText: 'Enter city, hotel name, or "current_location"',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a destination';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Date fields
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Check-in Date',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _checkInDate == null
                              ? 'Select date'
                              : DateFormat('MMM dd, yyyy').format(_checkInDate!),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Check-out Date',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _checkOutDate == null
                              ? 'Select date'
                              : DateFormat('MMM dd, yyyy').format(_checkOutDate!),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Guests and other options
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _adultsController,
                      decoration: const InputDecoration(
                        labelText: 'Adults',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || int.tryParse(value) == null) {
                          return 'Enter valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _childrenController,
                      decoration: const InputDecoration(
                        labelText: 'Children',
                        prefixIcon: Icon(Icons.child_care),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || int.tryParse(value) == null) {
                          return 'Enter valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Currency and Country
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCurrency,
                      decoration: const InputDecoration(
                        labelText: 'Currency',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      items: _currencies.map((currency) {
                        return DropdownMenuItem(
                          value: currency,
                          child: Text(currency),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCurrency = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCountry,
                      decoration: const InputDecoration(
                        labelText: 'Country',
                        prefixIcon: Icon(Icons.flag),
                        border: OutlineInputBorder(),
                      ),
                      items: _countries.map((country) {
                        return DropdownMenuItem(
                          value: country,
                          child: Text(country.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCountry = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Sort by
              DropdownButtonFormField<int?>(
                value: _selectedSortBy,
                decoration: const InputDecoration(
                  labelText: 'Sort By (Optional)',
                  prefixIcon: Icon(Icons.sort),
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('No preference'),
                  ),
                  ..._sortOptions.map((option) {
                    return DropdownMenuItem<int?>(
                      value: option['value'],
                      child: Text(option['label']),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSortBy = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Hotel class filter
              DropdownButtonFormField<List<int>>(
                value: _selectedHotelClasses.isEmpty ? null : _selectedHotelClasses,
                decoration: const InputDecoration(
                  labelText: 'Hotel Class (Optional)',
                  prefixIcon: Icon(Icons.star),
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<List<int>>(
                    value: [],
                    child: Text('All classes'),
                  ),
                  ..._hotelClassOptions.map((option) {
                    return DropdownMenuItem<List<int>>(
                      value: [option['value']],
                      child: Text(option['label']),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedHotelClasses = value ?? [];
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Max results
              TextFormField(
                controller: _maxResultsController,
                decoration: const InputDecoration(
                  labelText: 'Max Results',
                  prefixIcon: Icon(Icons.list),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Enter valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Search button
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.search),
                label: const Text('Search Hotels'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: isCheckIn ? 1 : 2)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          // Set check-out date to day after check-in if not already set
          if (_checkOutDate == null || _checkOutDate!.isBefore(picked)) {
            _checkOutDate = picked.add(const Duration(days: 1));
          }
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final event = SearchHotelsEvent(
        location: _locationController.text.trim(),
        checkInDate: _checkInDate != null 
            ? DateFormat('yyyy-MM-dd').format(_checkInDate!)
            : null,
        checkOutDate: _checkOutDate != null 
            ? DateFormat('yyyy-MM-dd').format(_checkOutDate!)
            : null,
        adults: int.parse(_adultsController.text),
        children: int.parse(_childrenController.text),
        currency: _selectedCurrency,
        country: _selectedCountry,
        sortBy: _selectedSortBy,
        hotelClass: _selectedHotelClasses.isNotEmpty ? _selectedHotelClasses : null,
        maxResults: int.parse(_maxResultsController.text),
      );
      
      context.read<HotelBloc>().add(event);
    }
  }
}
