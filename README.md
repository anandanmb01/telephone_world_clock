# Telephone World Clock

A beautiful Flutter app that displays world time based on phone number country codes using concentric 24-hour clock visualization.

## Features

- **Phone Number Input**: Enter any phone number with country code (e.g., +91 for India)
- **Automatic Country Detection**: Instantly detects the country from the phone number's country code
- **Concentric 24-Hour Clock**: Stunning visualization with two circular clock faces
  - Inner circle: Your local country time
  - Outer circle: Phone number's country time
  - Real-time animated clock pointers
  - Hour markers and labels (0-23 hours)
- **Country Selector**: Choose your default country (defaults to India)
- **Time Converter**: Two-way time conversion between your country and the phone number's country
- **Material 3 Design**: Modern UI with light/dark theme support
- **26+ Countries Supported**: Major countries with accurate timezone offsets

## How to Run

1. Make sure you have Flutter installed on your system
2. Clone this repository
3. Navigate to the project directory
4. Install dependencies:
   ```bash
   flutter pub get
   ```
5. Run the app:
   ```bash
   flutter run
   ```

## How to Use

1. **Select Your Country**: Choose your default country from the dropdown (defaults to India)
2. **Enter Phone Number**: Type any phone number with country code (e.g., +1-555-1234 for USA)
3. **View the Clock**: The concentric clock will show:
   - Inner circle (your country's current time)
   - Outer circle (phone number country's current time)
   - Both clocks update in real-time every second
4. **Convert Times**: Use the time converter boxes to convert specific times between the two countries

## Supported Countries

India (IN), United States (US), United Kingdom (GB), Australia (AU), Japan (JP), China (CN), Germany (DE), France (FR), Brazil (BR), South Africa (ZA), UAE (AE), Singapore (SG), Canada (CA), Mexico (MX), Italy (IT), Spain (ES), Russia (RU), South Korea (KR), Indonesia (ID), Thailand (TH), Malaysia (MY), Philippines (PH), Vietnam (VN), Pakistan (PK), Bangladesh (BD), New Zealand (NZ)

## Technical Details

- **Framework**: Flutter 3.7+
- **UI Library**: Material 3
- **Dependencies**:
  - `intl_phone_field`: Phone number input with country code detection
  - `intl`: Date and time formatting
  - `timezone`: Timezone calculations
- **Custom Widgets**: ConcentricClockWidget with CustomPainter for clock rendering

## Clock Visualization

The concentric clock uses a 24-hour format where:
- 0 hours = 12 AM (midnight)
- 12 hours = 12 PM (noon)
- 23 hours = 11 PM

The clock pointers rotate around the center, showing the current time in both timezones simultaneously. The angular offset between the two pointers represents the time difference between the countries.

## Getting Started with Flutter

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
