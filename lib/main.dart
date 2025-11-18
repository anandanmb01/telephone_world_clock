import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'World Clock by Phone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const WorldClockHomePage(),
    );
  }
}

class WorldClockHomePage extends StatefulWidget {
  const WorldClockHomePage({super.key});

  @override
  State<WorldClockHomePage> createState() => _WorldClockHomePageState();
}

class _WorldClockHomePageState extends State<WorldClockHomePage> {
  String _selectedCountryCode = 'IN';
  String _phoneCountryCode = 'IN';
  int _localOffset = 330; // India UTC+5:30 in minutes
  int _phoneOffset = 330; // Default to India
  Timer? _timer;
  DateTime _currentTime = DateTime.now();

  final TextEditingController _localTimeController = TextEditingController();
  final TextEditingController _remoteTimeController = TextEditingController();

  final Map<String, Map<String, dynamic>> _countryData = {
    'IN': {'name': 'India', 'offset': 330, 'timezone': 'Asia/Kolkata'},
    'US': {'name': 'United States', 'offset': -300, 'timezone': 'America/New_York'},
    'GB': {'name': 'United Kingdom', 'offset': 0, 'timezone': 'Europe/London'},
    'AU': {'name': 'Australia', 'offset': 660, 'timezone': 'Australia/Sydney'},
    'JP': {'name': 'Japan', 'offset': 540, 'timezone': 'Asia/Tokyo'},
    'CN': {'name': 'China', 'offset': 480, 'timezone': 'Asia/Shanghai'},
    'DE': {'name': 'Germany', 'offset': 60, 'timezone': 'Europe/Berlin'},
    'FR': {'name': 'France', 'offset': 60, 'timezone': 'Europe/Paris'},
    'BR': {'name': 'Brazil', 'offset': -180, 'timezone': 'America/Sao_Paulo'},
    'ZA': {'name': 'South Africa', 'offset': 120, 'timezone': 'Africa/Johannesburg'},
    'AE': {'name': 'UAE', 'offset': 240, 'timezone': 'Asia/Dubai'},
    'SG': {'name': 'Singapore', 'offset': 480, 'timezone': 'Asia/Singapore'},
    'CA': {'name': 'Canada', 'offset': -300, 'timezone': 'America/Toronto'},
    'MX': {'name': 'Mexico', 'offset': -360, 'timezone': 'America/Mexico_City'},
    'IT': {'name': 'Italy', 'offset': 60, 'timezone': 'Europe/Rome'},
    'ES': {'name': 'Spain', 'offset': 60, 'timezone': 'Europe/Madrid'},
    'RU': {'name': 'Russia', 'offset': 180, 'timezone': 'Europe/Moscow'},
    'KR': {'name': 'South Korea', 'offset': 540, 'timezone': 'Asia/Seoul'},
    'ID': {'name': 'Indonesia', 'offset': 420, 'timezone': 'Asia/Jakarta'},
    'TH': {'name': 'Thailand', 'offset': 420, 'timezone': 'Asia/Bangkok'},
    'MY': {'name': 'Malaysia', 'offset': 480, 'timezone': 'Asia/Kuala_Lumpur'},
    'PH': {'name': 'Philippines', 'offset': 480, 'timezone': 'Asia/Manila'},
    'VN': {'name': 'Vietnam', 'offset': 420, 'timezone': 'Asia/Ho_Chi_Minh'},
    'PK': {'name': 'Pakistan', 'offset': 300, 'timezone': 'Asia/Karachi'},
    'BD': {'name': 'Bangladesh', 'offset': 360, 'timezone': 'Asia/Dhaka'},
    'NZ': {'name': 'New Zealand', 'offset': 780, 'timezone': 'Pacific/Auckland'},
  };

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
    _localTimeController.dispose();
    _remoteTimeController.dispose();
    super.dispose();
  }

  void _onPhoneChanged(PhoneNumber phone) {
    setState(() {
      _phoneCountryCode = phone.countryISOCode ?? 'IN';
      _phoneOffset = _countryData[_phoneCountryCode]?['offset'] ?? 330;
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
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Default Country',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCountryCode,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Your Country',
                      ),
                      items: _countryData.entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key,
                          child: Text('${entry.value['name']} (${entry.key})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCountryCode = value ?? 'IN';
                          _localOffset = _countryData[_selectedCountryCode]?['offset'] ?? 330;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter Phone Number',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    IntlPhoneField(
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      initialCountryCode: 'IN',
                      onChanged: _onPhoneChanged,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Detected Country: ${_countryData[_phoneCountryCode]?['name'] ?? 'Unknown'}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
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
                        localOffset: _localOffset,
                        remoteOffset: _phoneOffset,
                        localCountry: _countryData[_selectedCountryCode]?['name'] ?? 'Unknown',
                        remoteCountry: _countryData[_phoneCountryCode]?['name'] ?? 'Unknown',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
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
                              labelText: '${_countryData[_selectedCountryCode]?['name']} Time (HH:mm)',
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
                              labelText: '${_countryData[_phoneCountryCode]?['name']} Time (HH:mm)',
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
            ),
          ],
        ),
      ),
    );
  }
}

class ConcentricClockWidget extends StatelessWidget {
  final DateTime currentTime;
  final int localOffset;
  final int remoteOffset;
  final String localCountry;
  final String remoteCountry;

  const ConcentricClockWidget({
    super.key,
    required this.currentTime,
    required this.localOffset,
    required this.remoteOffset,
    required this.localCountry,
    required this.remoteCountry,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ClockPainter(
        currentTime: currentTime,
        localOffset: localOffset,
        remoteOffset: remoteOffset,
        localCountry: localCountry,
        remoteCountry: remoteCountry,
        colorScheme: Theme.of(context).colorScheme,
      ),
      child: Container(),
    );
  }
}

class ClockPainter extends CustomPainter {
  final DateTime currentTime;
  final int localOffset;
  final int remoteOffset;
  final String localCountry;
  final String remoteCountry;
  final ColorScheme colorScheme;

  ClockPainter({
    required this.currentTime,
    required this.localOffset,
    required this.remoteOffset,
    required this.localCountry,
    required this.remoteCountry,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = min(size.width, size.height) / 2 - 20;
    final innerRadius = outerRadius * 0.65;

    // Calculate local time with offset
    final utcTime = currentTime.toUtc();
    final localMinutes = (utcTime.hour * 60 + utcTime.minute + localOffset) % 1440;
    final localHour = localMinutes / 60;

    // Calculate remote time with offset
    final remoteMinutes = (utcTime.hour * 60 + utcTime.minute + remoteOffset) % 1440;
    final remoteHour = remoteMinutes / 60;

    // Draw outer circle (remote time)
    _drawClock(canvas, center, outerRadius, remoteHour, remoteCountry, colorScheme.primary, true);

    // Draw inner circle (local time)
    _drawClock(canvas, center, innerRadius, localHour, localCountry, colorScheme.secondary, false);

    // Draw current time pointer for local time
    _drawTimePointer(canvas, center, innerRadius, localHour, colorScheme.secondary);

    // Draw current time pointer for remote time
    _drawTimePointer(canvas, center, outerRadius, remoteHour, colorScheme.primary);

    // Draw legend
    _drawLegend(canvas, size, colorScheme);
  }

  void _drawClock(Canvas canvas, Offset center, double radius, double currentHour,
                  String country, Color color, bool isOuter) {
    // Draw clock circle
    final circlePaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, circlePaint);

    // Draw clock border
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);

    // Draw hour markers and labels
    for (int i = 0; i < 24; i++) {
      final angle = (i * 15 - 90) * pi / 180; // 15 degrees per hour
      final markerStart = Offset(
        center.dx + radius * 0.9 * cos(angle),
        center.dy + radius * 0.9 * sin(angle),
      );
      final markerEnd = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      final markerPaint = Paint()
        ..color = color
        ..strokeWidth = i % 6 == 0 ? 3 : 1;
      canvas.drawLine(markerStart, markerEnd, markerPaint);

      // Draw hour numbers
      if (i % 3 == 0) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: i.toString(),
            style: TextStyle(
              color: color,
              fontSize: isOuter ? 14 : 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        final textOffset = Offset(
          center.dx + radius * 0.75 * cos(angle) - textPainter.width / 2,
          center.dy + radius * 0.75 * sin(angle) - textPainter.height / 2,
        );
        textPainter.paint(canvas, textOffset);
      }
    }

    // Draw country label
    final countryPainter = TextPainter(
      text: TextSpan(
        text: country,
        style: TextStyle(
          color: color,
          fontSize: isOuter ? 16 : 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    countryPainter.layout();
    final labelOffset = Offset(
      center.dx - countryPainter.width / 2,
      center.dy + (isOuter ? radius * 0.5 : 0) - countryPainter.height / 2,
    );
    countryPainter.paint(canvas, labelOffset);
  }

  void _drawTimePointer(Canvas canvas, Offset center, double radius, double currentHour, Color color) {
    final angle = (currentHour * 15 - 90) * pi / 180;
    final pointerEnd = Offset(
      center.dx + radius * 0.85 * cos(angle),
      center.dy + radius * 0.85 * sin(angle),
    );

    final pointerPaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, pointerEnd, pointerPaint);

    // Draw pointer circle at the end
    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pointerEnd, 6, circlePaint);

    // Draw time text
    final hour = currentHour.floor();
    final minute = ((currentHour - hour) * 60).round();
    final timeText = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    final timePainter = TextPainter(
      text: TextSpan(
        text: timeText,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.white.withOpacity(0.8),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    timePainter.layout();
    final timeOffset = Offset(
      pointerEnd.dx - timePainter.width / 2,
      pointerEnd.dy - timePainter.height - 10,
    );
    timePainter.paint(canvas, timeOffset);
  }

  void _drawLegend(Canvas canvas, Size size, ColorScheme colorScheme) {
    final legendY = size.height - 40;

    // Local time legend
    final localCirclePaint = Paint()
      ..color = colorScheme.secondary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(40, legendY), 8, localCirclePaint);

    final localTextPainter = TextPainter(
      text: TextSpan(
        text: 'Inner: $localCountry',
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    localTextPainter.layout();
    localTextPainter.paint(canvas, Offset(55, legendY - 6));

    // Remote time legend
    final remoteCirclePaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2 + 20, legendY), 8, remoteCirclePaint);

    final remoteTextPainter = TextPainter(
      text: TextSpan(
        text: 'Outer: $remoteCountry',
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    remoteTextPainter.layout();
    remoteTextPainter.paint(canvas, Offset(size.width / 2 + 35, legendY - 6));
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) {
    return currentTime != oldDelegate.currentTime ||
           localOffset != oldDelegate.localOffset ||
           remoteOffset != oldDelegate.remoteOffset;
  }
}
