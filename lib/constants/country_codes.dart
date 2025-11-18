/// Maps country dialing codes to ISO country codes
const Map<String, String> countryCodeMap = {
  // North America
  '1': 'US',      // United States, Canada

  // Europe
  '44': 'GB',     // United Kingdom
  '33': 'FR',     // France
  '49': 'DE',     // Germany
  '39': 'IT',     // Italy
  '34': 'ES',     // Spain
  '7': 'RU',      // Russia

  // Asia
  '91': 'IN',     // India
  '86': 'CN',     // China
  '81': 'JP',     // Japan
  '82': 'KR',     // South Korea
  '65': 'SG',     // Singapore
  '971': 'AE',    // UAE
  '92': 'PK',     // Pakistan
  '880': 'BD',    // Bangladesh
  '62': 'ID',     // Indonesia
  '66': 'TH',     // Thailand
  '60': 'MY',     // Malaysia
  '63': 'PH',     // Philippines
  '84': 'VN',     // Vietnam

  // Oceania
  '61': 'AU',     // Australia
  '64': 'NZ',     // New Zealand

  // South America
  '55': 'BR',     // Brazil
  '52': 'MX',     // Mexico

  // Africa
  '27': 'ZA',     // South Africa
};

/// Detects country ISO code from a phone number string
String detectCountryFromPhone(String phoneNumber) {
  // Remove any non-digit characters except +
  final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

  // Remove leading + if present
  final digits = cleaned.startsWith('+') ? cleaned.substring(1) : cleaned;

  if (digits.isEmpty) {
    return 'IN'; // Default to India
  }

  // Try to match country codes (check longer codes first)
  for (int length = 3; length >= 1; length--) {
    if (digits.length >= length) {
      final code = digits.substring(0, length);
      if (countryCodeMap.containsKey(code)) {
        return countryCodeMap[code]!;
      }
    }
  }

  return 'IN'; // Default to India if no match
}
