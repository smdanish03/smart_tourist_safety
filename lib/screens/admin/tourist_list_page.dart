import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TouristListPage extends StatefulWidget {
  const TouristListPage({super.key});

  @override
  State<TouristListPage> createState() =>
      _TouristListPageState();
}

class _TouristListPageState
    extends State<TouristListPage> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  bool _loading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _tourists = [];

  @override
  void initState() {
    super.initState();
    _loadTourists();
  }

  Future<void> _loadTourists() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final QuerySnapshot<Map<String, dynamic>>
          snapshot =
          await _firestore
              .collection('tourists')
              .get();

      final List<Map<String, dynamic>> tourists =
          snapshot.docs.map(
        (
          QueryDocumentSnapshot<
              Map<String, dynamic>>
          document,
        ) {
          final Map<String, dynamic> data =
              document.data();

          return {
            'touristId': document.id,
            ...data,
          };
        },
      ).toList();

      tourists.sort(
        (
          Map<String, dynamic> a,
          Map<String, dynamic> b,
        ) {
          final String nameA =
              a['name']?.toString() ?? '';

          final String nameB =
              b['name']?.toString() ?? '';

          return nameA
              .toLowerCase()
              .compareTo(
                nameB.toLowerCase(),
              );
        },
      );

      if (!mounted) return;

      setState(() {
        _tourists = tourists;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage =
            'Could not load tourist details.';
      });
    }
  }

  String _getValue(
    Map<String, dynamic> tourist,
    String field,
  ) {
    final dynamic value = tourist[field];

    if (value == null ||
        value.toString().trim().isEmpty) {
      return 'Not available';
    }

    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tourist Management',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadTourists,
            tooltip: 'Refresh',
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadTourists,
                icon: const Icon(
                  Icons.refresh,
                ),
                label: const Text(
                  'Retry',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_tourists.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadTourists,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Icon(
              Icons.people_outline,
              size: 70,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'No tourists registered yet.',
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTourists,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    child: Icon(
                      Icons.people,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Registered Tourists',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_tourists.length} tourist${_tourists.length == 1 ? '' : 's'} registered',
                          style: TextStyle(
                            color:
                                Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          ..._tourists.map(
            (
              Map<String, dynamic> tourist,
            ) {
              final String touristId =
                  _getValue(
                tourist,
                'touristId',
              );

              final String name =
                  _getValue(
                tourist,
                'name',
              );

              final String email =
                  _getValue(
                tourist,
                'email',
              );

              final String phone =
                  _getValue(
                tourist,
                'phone',
              );

              final String city =
                  _getValue(
                tourist,
                'city',
              );

              return Card(
                margin: const EdgeInsets.only(
                  bottom: 12,
                ),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    child: Text(
                      name == 'Not available'
                          ? '?'
                          : name[0]
                              .toUpperCase(),
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Tourist ID: $touristId',
                  ),
                  childrenPadding:
                      const EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    18,
                  ),
                  children: [
                    const Divider(),
                    _TouristDetailRow(
                      icon: Icons.badge_outlined,
                      title: 'Tourist ID',
                      value: touristId,
                    ),
                    _TouristDetailRow(
                      icon: Icons.person_outline,
                      title: 'Name',
                      value: name,
                    ),
                    _TouristDetailRow(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      value: email,
                    ),
                    _TouristDetailRow(
                      icon: Icons.phone_outlined,
                      title: 'Phone',
                      value: phone,
                    ),
                    _TouristDetailRow(
                      icon: Icons.location_city,
                      title: 'City',
                      value: city,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TouristDetailRow
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _TouristDetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 21,
            color: Colors.blue,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 85,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
            ),
          ),
        ],
      ),
    );
  }
}