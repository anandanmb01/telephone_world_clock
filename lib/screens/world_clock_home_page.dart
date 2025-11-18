import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../constants/country_data.dart';
import '../constants/country_codes.dart';
import '../widgets/concentric_clock_widget.dart';

/// Custom text input formatter for time input (HH:mm)
class TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Remove any non-digit characters except colon
    String digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');

    // Limit to 4 digits (HHmm)
    if (digitsOnly.length > 4) {
      digitsOnly = digitsOnly.substring(0, 4);
    }

    // Format with colon
    String formatted = '';
    if (digitsOnly.isEmpty) {
      formatted = '';
    } else if (digitsOnly.length <= 2) {
      formatted = digitsOnly;
    } else {
      formatted = '${digitsOnly.substring(0, 2)}:${digitsOnly.substring(2)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Main home page for the world clock application
class WorldClockHomePage extends StatefulWidget {
  const WorldClockHomePage({super.key});

  @override
  State<WorldClockHomePage> createState() => _WorldClockHomePageState();
}

class _WorldClockHomePageState extends State<WorldClockHomePage>
    with SingleTickerProviderStateMixin {
  late String _phoneCountryCode;
  late int _phoneOffset;
  Timer? _timer;
  DateTime _currentTime = DateTime.now();
  late TabController _tabController;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _localTimeController = TextEditingController();
  final TextEditingController _remoteTimeController = TextEditingController();

  // Get system timezone offset in minutes
  int get _systemOffset {
    final now = DateTime.now();
    final offset = now.timeZoneOffset;
    return offset.inMinutes;
  }

  // Get system timezone name
  String get _systemTimezoneName {
    final now = DateTime.now();
    final offset = now.timeZoneOffset;
    final hours = offset.inHours;
    final minutes = offset.inMinutes.remainder(60).abs();
    final sign = hours >= 0 ? '+' : '';
    return 'System (UTC$sign$hours:${minutes.toString().padLeft(2, '0')})';
  }

  // Detect default country based on system timezone offset
  String _detectCountryFromSystemTimezone() {
    final systemOffsetMinutes = _systemOffset;

    // Try to find a country with matching offset
    for (var entry in countryData.entries) {
      if (entry.value['offset'] == systemOffsetMinutes) {
        return entry.key;
      }
    }

    // If no exact match, return India as fallback
    return 'IN';
  }

  @override
  void initState() {
    super.initState();

    // Detect default country based on system timezone
    _phoneCountryCode = _detectCountryFromSystemTimezone();
    _phoneOffset = countryData[_phoneCountryCode]?['offset'] ?? 330;

    _tabController = TabController(length: 2, vsync: this);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    _phoneController.dispose();
    _localTimeController.dispose();
    _remoteTimeController.dispose();
    super.dispose();
  }

  void _resetPhoneNumber() {
    setState(() {
      _phoneController.clear();
      _phoneCountryCode = _detectCountryFromSystemTimezone();
      _phoneOffset = countryData[_phoneCountryCode]?['offset'] ?? 330;
      _localTimeController.clear();
      _remoteTimeController.clear();
    });
  }

  void _onPhoneChanged(String phoneNumber) {
    setState(() {
      _phoneCountryCode = detectCountryFromPhone(phoneNumber);
      _phoneOffset = countryData[_phoneCountryCode]?['offset'] ?? 330;
    });
  }

  void _onCountrySelected(String? countryCode) {
    if (countryCode != null) {
      setState(() {
        _phoneCountryCode = countryCode;
        _phoneOffset = countryData[countryCode]?['offset'] ?? 330;
      });
    }
  }

  void _convertLocalToRemote(String localTime) {
    try {
      final timeFormat = DateFormat('HH:mm');
      final parsedTime = timeFormat.parse(localTime);

      final localMinutes = parsedTime.hour * 60 + parsedTime.minute;
      final remoteMinutes = localMinutes + (_phoneOffset - _systemOffset);

      final normalizedMinutes = remoteMinutes % 1440;
      final adjustedMinutes = normalizedMinutes < 0 ? normalizedMinutes + 1440 : normalizedMinutes;

      final remoteHour = adjustedMinutes ~/ 60;
      final remoteMinute = adjustedMinutes % 60;

      _remoteTimeController.text = '${remoteHour.toString().padLeft(2, '0')}:${remoteMinute.toString().padLeft(2, '0')}';
    } catch (e) {
      _remoteTimeController.text = 'Invalid time';
    }
  }

  void _convertRemoteToLocal(String remoteTime) {
    try {
      final timeFormat = DateFormat('HH:mm');
      final parsedTime = timeFormat.parse(remoteTime);

      final remoteMinutes = parsedTime.hour * 60 + parsedTime.minute;
      final localMinutes = remoteMinutes + (_systemOffset - _phoneOffset);

      final normalizedMinutes = localMinutes % 1440;
      final adjustedMinutes = normalizedMinutes < 0 ? normalizedMinutes + 1440 : normalizedMinutes;

      final localHour = adjustedMinutes ~/ 60;
      final localMinute = adjustedMinutes % 60;

      _localTimeController.text = '${localHour.toString().padLeft(2, '0')}:${localMinute.toString().padLeft(2, '0')}';
    } catch (e) {
      _localTimeController.text = 'Invalid time';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('World Clock by Phone Number'),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Clock at the top
            _buildClockCard(),
            const SizedBox(height: 24),
            // Phone number input with reset button
            _buildPhoneInputCard(),
            const SizedBox(height: 24),
            // Time converter
            _buildTimeConverterCard(),
            const SizedBox(height: 16),
            // Credits at bottom right
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'for dibina',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.withOpacity(0.4),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClockCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '24-Hour World Clock',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: ConcentricClockWidget(
                currentTime: _currentTime,
                localOffset: _systemOffset,
                remoteOffset: _phoneOffset,
                localCountry: _systemTimezoneName,
                remoteCountry: countryData[_phoneCountryCode]?['name'] ?? 'Unknown',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInputCard() {
    return Card(
      elevation: 4,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(icon: Icon(Icons.phone), text: 'Mobile Number'),
              Tab(icon: Icon(Icons.public), text: 'Select Country'),
            ],
          ),
          SizedBox(
            height: 180,
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Mobile Number Input
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          hintText: '+916734... or +1234...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        onChanged: _onPhoneChanged,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Detected Country: ${countryData[_phoneCountryCode]?['name'] ?? 'Unknown'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Divider(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        thickness: 1,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _resetPhoneNumber,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Reset'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            textStyle: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Tab 2: Country Selector
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Country',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _phoneCountryCode,
                        decoration: const InputDecoration(
                          labelText: 'Country',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.flag),
                        ),
                        items: countryData.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value['name'] as String),
                          );
                        }).toList()
                          ..sort((a, b) => (a.child as Text).data!.compareTo((b.child as Text).data!)),
                        onChanged: _onCountrySelected,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Selected: ${countryData[_phoneCountryCode]?['name'] ?? 'Unknown'}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeConverterCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time Converter',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _localTimeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [TimeInputFormatter()],
                    decoration: InputDecoration(
                      labelText: '$_systemTimezoneName Time (HH:mm)',
                      border: const OutlineInputBorder(),
                      hintText: '14:30',
                    ),
                    onChanged: _convertLocalToRemote,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.sync_alt,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _remoteTimeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [TimeInputFormatter()],
                    decoration: InputDecoration(
                      labelText: '${countryData[_phoneCountryCode]?['name']} Time (HH:mm)',
                      border: const OutlineInputBorder(),
                      hintText: '09:00',
                    ),
                    onChanged: _convertRemoteToLocal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Time difference: ${((_phoneOffset - _systemOffset) / 60).toStringAsFixed(1)} hours',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
