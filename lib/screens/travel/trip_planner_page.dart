import 'package:flutter/material.dart';

import '../../data/tourist_places.dart';
import '../../models/tourist_place.dart';
import '../../models/trip.dart';
import '../../services/trip_service.dart';

class TripPlannerPage extends StatefulWidget {
  const TripPlannerPage({super.key});

  @override
  State<TripPlannerPage> createState() => _TripPlannerPageState();
}

class _TripPlannerPageState extends State<TripPlannerPage> {
  final TextEditingController _titleController =
      TextEditingController();

  final TripService _tripService = TripService();

  DateTime? _startDate;
  DateTime? _endDate;

  final List<TouristPlace> _selectedPlaces = [];

  Trip? _generatedTrip;

  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final DateTime now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (picked == null) return;

    setState(() {
      _startDate = picked;

      if (_endDate != null && _endDate!.isBefore(picked)) {
        _endDate = null;
      }

      _generatedTrip = null;
    });
  }

  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      _showMessage('Please select the start date first.');
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!,
      firstDate: _startDate!,
      lastDate: DateTime(
        _startDate!.year + 2,
        _startDate!.month,
        _startDate!.day,
      ),
    );

    if (picked == null) return;

    setState(() {
      _endDate = picked;
      _generatedTrip = null;
    });
  }

  void _showPlaceSelector() {
    final List<TouristPlace> availablePlaces =
        touristPlaces.where((place) {
      return !_isPlaceSelected(place);
    }).toList();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select Tourist Places',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: availablePlaces.isEmpty
                      ? const Center(
                          child: Text(
                            'All tourist places are already selected.',
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          itemCount: availablePlaces.length,
                          itemBuilder: (context, index) {
                            final TouristPlace place =
                                availablePlaces[index];

                            return Card(
                              margin: const EdgeInsets.only(
                                bottom: 10,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      Colors.blue.shade50,
                                  child: Icon(
                                    Icons.location_on,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                title: Text(
                                  place.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  place.category,
                                ),
                                trailing: const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.blue,
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedPlaces.add(place);
                                    _generatedTrip = null;
                                  });

                                  Navigator.pop(context);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isPlaceSelected(TouristPlace place) {
    return _selectedPlaces.any(
      (selected) => selected.name == place.name,
    );
  }

  void _removePlace(TouristPlace place) {
    setState(() {
      _selectedPlaces.removeWhere(
        (selected) => selected.name == place.name,
      );

      _generatedTrip = null;
    });
  }

  void _generateTrip() {
    if (_titleController.text.trim().isEmpty) {
      _showMessage('Please enter a trip name.');
      return;
    }

    if (_startDate == null || _endDate == null) {
      _showMessage('Please select both start and end dates.');
      return;
    }

    if (_selectedPlaces.isEmpty) {
      _showMessage('Please select at least one tourist place.');
      return;
    }

    final int totalDays =
        _endDate!.difference(_startDate!).inDays + 1;

    final List<TripDay> days = [];

    for (int i = 0; i < totalDays; i++) {
      final DateTime currentDate =
          _startDate!.add(Duration(days: i));

      days.add(
        TripDay(
          dayNumber: i + 1,
          date: currentDate,
          places: [],
        ),
      );
    }

    for (int i = 0; i < _selectedPlaces.length; i++) {
      final TouristPlace place = _selectedPlaces[i];

      final int dayIndex = i % days.length;

      final TripPlace tripPlace = TripPlace(
        placeId: _createPlaceId(place.name),
        name: place.name,
        category: place.category,
        latitude: place.latitude,
        longitude: place.longitude,
      );

      final List<TripPlace> updatedPlaces = [
        ...days[dayIndex].places,
        tripPlace,
      ];

      days[dayIndex] = TripDay(
        dayNumber: days[dayIndex].dayNumber,
        date: days[dayIndex].date,
        places: updatedPlaces,
      );
    }

    setState(() {
      _generatedTrip = Trip(
        id: '',
        uid: '',
        title: _titleController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        days: days,
        createdAt: DateTime.now(),
      );
    });

    _showMessage('Trip plan generated successfully.');
  }

  Future<void> _saveTrip() async {
    if (_generatedTrip == null) {
      _showMessage('Please generate the trip plan first.');
      return;
    }

    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _tripService.saveTrip(_generatedTrip!);

      if (!mounted) return;

      _showMessage('Trip saved successfully.');

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Could not save trip. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _createPlaceId(String name) {
    return name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_]+'), '');
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trip Planner',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTripBasicInfo(),
          const SizedBox(height: 20),
          _buildDateSection(),
          const SizedBox(height: 20),
          _buildPlacesSection(),
          const SizedBox(height: 20),

          // Generate Trip Plan
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _generateTrip,
              icon: const Icon(Icons.auto_awesome),
              label: const Text(
                'Generate Trip Plan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Save Trip
          if (_generatedTrip != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _isSaving ? null : _saveTrip,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  _isSaving
                      ? 'Saving Trip...'
                      : 'Save Trip',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],

          if (_generatedTrip != null) ...[
            const SizedBox(height: 28),
            _buildGeneratedPlan(),
          ],
        ],
      ),
    );
  }

  Widget _buildTripBasicInfo() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Trip Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _titleController,
              onChanged: (_) {
                if (_generatedTrip != null) {
                  setState(() {
                    _generatedTrip = null;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Trip Name',
                hintText:
                    'Example: Mumbai Weekend Trip',
                prefixIcon:
                    const Icon(Icons.card_travel),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Trip Dates',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectStartDate,
                    icon: const Icon(
                      Icons.calendar_today,
                    ),
                    label: Text(
                      _startDate == null
                          ? 'Start Date'
                          : _formatDate(_startDate!),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectEndDate,
                    icon: const Icon(Icons.event),
                    label: Text(
                      _endDate == null
                          ? 'End Date'
                          : _formatDate(_endDate!),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlacesSection() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Tourist Places',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${_selectedPlaces.length} selected',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _showPlaceSelector,
              icon: const Icon(
                Icons.add_location_alt,
              ),
              label: const Text(
                'Add Tourist Place',
              ),
            ),
            if (_selectedPlaces.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'No places selected yet.',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  children:
                      _selectedPlaces.map((place) {
                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        dense: true,
                        leading: const Icon(
                          Icons.location_on,
                          color: Colors.blue,
                        ),
                        title: Text(
                          place.name,
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                        subtitle:
                            Text(place.category),
                        trailing: IconButton(
                          onPressed: () =>
                              _removePlace(place),
                          icon: const Icon(
                            Icons
                                .remove_circle_outline,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratedPlan() {
    final Trip trip = _generatedTrip!;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Trip Plan',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          trip.title,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 14),
        ...trip.days.map(
          (day) => _buildDayCard(day),
        ),
      ],
    );
  }

  Widget _buildDayCard(TripDay day) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    '${day.dayNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Day ${day.dayNumber}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatDate(day.date),
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (day.places.isEmpty)
              const Text(
                'No place assigned.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              )
            else
              ...day.places.asMap().entries.map(
                (entry) {
                  final int index = entry.key;
                  final TripPlace place =
                      entry.value;

                  return Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}.',
                          style: TextStyle(
                            color:
                                Colors.blue.shade700,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                place.name,
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                place.category,
                                style:
                                    const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}