/// Maps country dialing codes to ISO country codes
const Map<String, String> countryCodeMap = {
  // North America
  '1': 'US',      // United States, Canada

  // South America
  '54': 'AR',     // Argentina
  '55': 'BR',     // Brazil
  '56': 'CL',     // Chile
  '57': 'CO',     // Colombia
  '51': 'PE',     // Peru
  '58': 'VE',     // Venezuela
  '52': 'MX',     // Mexico

  // Europe
  '44': 'GB',     // United Kingdom
  '33': 'FR',     // France
  '49': 'DE',     // Germany
  '39': 'IT',     // Italy
  '34': 'ES',     // Spain
  '31': 'NL',     // Netherlands
  '32': 'BE',     // Belgium
  '41': 'CH',     // Switzerland
  '43': 'AT',     // Austria
  '46': 'SE',     // Sweden
  '47': 'NO',     // Norway
  '45': 'DK',     // Denmark
  '358': 'FI',    // Finland
  '48': 'PL',     // Poland
  '30': 'GR',     // Greece
  '351': 'PT',    // Portugal
  '353': 'IE',    // Ireland
  '7': 'RU',      // Russia
  '380': 'UA',    // Ukraine
  '420': 'CZ',    // Czech Republic
  '40': 'RO',     // Romania

  // Middle East
  '971': 'AE',    // UAE
  '966': 'SA',    // Saudi Arabia
  '972': 'IL',    // Israel
  '90': 'TR',     // Turkey
  '961': 'LB',    // Lebanon
  '962': 'JO',    // Jordan
  '964': 'IQ',    // Iraq
  '965': 'KW',    // Kuwait
  '974': 'QA',    // Qatar
  '973': 'BH',    // Bahrain
  '968': 'OM',    // Oman
  '20': 'EG',     // Egypt

  // Asia
  '91': 'IN',     // India
  '86': 'CN',     // China
  '81': 'JP',     // Japan
  '82': 'KR',     // South Korea
  '65': 'SG',     // Singapore
  '852': 'HK',    // Hong Kong
  '886': 'TW',    // Taiwan
  '92': 'PK',     // Pakistan
  '880': 'BD',    // Bangladesh
  '62': 'ID',     // Indonesia
  '66': 'TH',     // Thailand
  '60': 'MY',     // Malaysia
  '63': 'PH',     // Philippines
  '84': 'VN',     // Vietnam
  '94': 'LK',     // Sri Lanka
  '977': 'NP',    // Nepal
  '95': 'MM',     // Myanmar
  '855': 'KH',    // Cambodia
  '856': 'LA',    // Laos
  '976': 'MN',    // Mongolia
  '7': 'KZ',      // Kazakhstan (shares code 7 with Russia)
  '998': 'UZ',    // Uzbekistan
  '93': 'AF',     // Afghanistan
  '98': 'IR',     // Iran

  // Oceania
  '61': 'AU',     // Australia
  '64': 'NZ',     // New Zealand
  '679': 'FJ',    // Fiji

  // Africa
  '27': 'ZA',     // South Africa
  '234': 'NG',    // Nigeria
  '254': 'KE',    // Kenya
  '233': 'GH',    // Ghana
  '251': 'ET',    // Ethiopia
  '255': 'TZ',    // Tanzania
  '256': 'UG',    // Uganda
  '213': 'DZ',    // Algeria
  '212': 'MA',    // Morocco
  '216': 'TN',    // Tunisia
  '263': 'ZW',    // Zimbabwe
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
