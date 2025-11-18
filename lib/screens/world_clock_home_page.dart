import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/country_data.dart';
import '../constants/country_codes.dart';
import '../widgets/concentric_clock_widget.dart';

/// Main home page for the world clock application
class WorldClockHomePage extends StatefulWidget {
  const WorldClockHomePage({super.key});

  @override
  State<WorldClockHomePage> createState() => _WorldClockHomePageState();
}

class _WorldClockHomePageState extends State<WorldClockHomePage> {
  String _selectedCountryCode = 'IN';
  String _phoneCountryCode = 'IN';
  int _localOffset = 330; // Used for time converter (default India)
  int _phoneOffset = 330; // Default to India
  Timer? _timer;
  DateTime _currentTime = DateTime.now();

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

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _localTimeController.dispose();
    _remoteTimeController.dispose();
    super.dispose();
  }

  void _resetPhoneNumber() {
    setState(() {
      _phoneController.clear();
      _phoneCountryCode = 'IN';
      _phoneOffset = 330;
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

  void _convertLocalToRemote(String localTime) {
    try {
      final timeFormat = DateFormat('HH:mm');
      final parsedTime = timeFormat.parse(localTime);

      final localMinutes = parsedTime.hour * 60 + parsedTime.minute;
      final remoteMinutes = localMinutes + (_phoneOffset - _localOffset);

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
      final localMinutes = remoteMinutes + (_localOffset - _phoneOffset);

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
            const SizedBox(height: 16),
            // Default country selection
            _buildCountrySelectionCard(),
            const SizedBox(height: 24),
            // Time converter
            _buildTimeConverterCard(),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Enter Phone Number',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ElevatedButton.icon(
                  onPressed: _resetPhoneNumber,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 8),
            Text(
              'Detected Country: ${countryData[_phoneCountryCode]?['name'] ?? 'Unknown'}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountrySelectionCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Default Country',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCountryCode,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select Your Country',
              ),
              items: countryData.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text('${entry.value['name']} (${entry.key})'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCountryCode = value ?? 'IN';
                  _localOffset = countryData[_selectedCountryCode]?['offset'] ?? 330;
                });
              },
            ),
          ],
        ),
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
                    decoration: InputDecoration(
                      labelText: '${countryData[_selectedCountryCode]?['name']} Time (HH:mm)',
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
              'Time difference: ${((_phoneOffset - _localOffset) / 60).toStringAsFixed(1)} hours',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
