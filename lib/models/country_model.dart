class Country {
  final String name;
  final String code; // ISO 2-letter alpha code (e.g., 'IN', 'US')
  final String dialCode; // International dial code (e.g., '+91', '+1')
  final String flag; // Emoji flag

  const Country({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });

  /// Default country used when none is selected (India)
  static const Country defaultCountry = Country(
    name: 'India',
    code: 'IN',
    dialCode: '+91',
    flag: '🇮🇳',
  );

  /// Curated list of major countries sorted alphabetically with India at top
  static const List<Country> allCountries = [
    Country(name: 'India', code: 'IN', dialCode: '+91', flag: '🇮🇳'),
    Country(name: 'United States', code: 'US', dialCode: '+1', flag: '🇺🇸'),
    Country(name: 'United Kingdom', code: 'GB', dialCode: '+44', flag: '🇬🇧'),
    Country(name: 'United Arab Emirates', code: 'AE', dialCode: '+971', flag: '🇦🇪'),
    Country(name: 'Australia', code: 'AU', dialCode: '+61', flag: '🇦🇺'),
    Country(name: 'Bahrain', code: 'BH', dialCode: '+973', flag: '🇧🇭'),
    Country(name: 'Bangladesh', code: 'BD', dialCode: '+880', flag: '🇧🇩'),
    Country(name: 'Brazil', code: 'BR', dialCode: '+55', flag: '🇧🇷'),
    Country(name: 'Canada', code: 'CA', dialCode: '+1', flag: '🇨🇦'),
    Country(name: 'China', code: 'CN', dialCode: '+86', flag: '🇨🇳'),
    Country(name: 'Egypt', code: 'EG', dialCode: '+20', flag: '🇪🇬'),
    Country(name: 'France', code: 'FR', dialCode: '+33', flag: '🇫🇷'),
    Country(name: 'Germany', code: 'DE', dialCode: '+49', flag: '🇩🇪'),
    Country(name: 'Hong Kong', code: 'HK', dialCode: '+852', flag: '🇭🇰'),
    Country(name: 'Indonesia', code: 'ID', dialCode: '+62', flag: '🇮🇩'),
    Country(name: 'Ireland', code: 'IE', dialCode: '+353', flag: '🇮🇪'),
    Country(name: 'Italy', code: 'IT', dialCode: '+39', flag: '🇮🇹'),
    Country(name: 'Japan', code: 'JP', dialCode: '+81', flag: '🇯🇵'),
    Country(name: 'Kenya', code: 'KE', dialCode: '+254', flag: '🇰🇪'),
    Country(name: 'Kuwait', code: 'KW', dialCode: '+965', flag: '🇰🇼'),
    Country(name: 'Malaysia', code: 'MY', dialCode: '+60', flag: '🇲🇾'),
    Country(name: 'Mexico', code: 'MX', dialCode: '+52', flag: '🇲🇽'),
    Country(name: 'Nepal', code: 'NP', dialCode: '+977', flag: '🇳🇵'),
    Country(name: 'Netherlands', code: 'NL', dialCode: '+31', flag: '🇳🇱'),
    Country(name: 'New Zealand', code: 'NZ', dialCode: '+64', flag: '🇳🇿'),
    Country(name: 'Nigeria', code: 'NG', dialCode: '+234', flag: '🇳🇬'),
    Country(name: 'Oman', code: 'OM', dialCode: '+968', flag: '🇴🇲'),
    Country(name: 'Pakistan', code: 'PK', dialCode: '+92', flag: '🇵🇰'),
    Country(name: 'Philippines', code: 'PH', dialCode: '+63', flag: '🇵🇭'),
    Country(name: 'Qatar', code: 'QA', dialCode: '+974', flag: '🇶🇦'),
    Country(name: 'Russia', code: 'RU', dialCode: '+7', flag: '🇷🇺'),
    Country(name: 'Saudi Arabia', code: 'SA', dialCode: '+966', flag: '🇸🇦'),
    Country(name: 'Singapore', code: 'SG', dialCode: '+65', flag: '🇸🇬'),
    Country(name: 'South Africa', code: 'ZA', dialCode: '+27', flag: '🇿🇦'),
    Country(name: 'South Korea', code: 'KR', dialCode: '+82', flag: '🇰🇷'),
    Country(name: 'Spain', code: 'ES', dialCode: '+34', flag: '🇪🇸'),
    Country(name: 'Sri Lanka', code: 'LK', dialCode: '+94', flag: '🇱🇰'),
    Country(name: 'Sweden', code: 'SE', dialCode: '+46', flag: '🇸🇪'),
    Country(name: 'Switzerland', code: 'CH', dialCode: '+41', flag: '🇨🇭'),
    Country(name: 'Thailand', code: 'TH', dialCode: '+66', flag: '🇹🇭'),
    Country(name: 'Turkey', code: 'TR', dialCode: '+90', flag: '🇹🇷'),
    Country(name: 'Vietnam', code: 'VN', dialCode: '+84', flag: '🇻🇳'),
  ];

  static Country fromDialCode(String dialCode) {
    final cleanCode = dialCode.trim();
    return allCountries.firstWhere(
      (c) => c.dialCode == cleanCode,
      orElse: () => defaultCountry,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Country &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          dialCode == other.dialCode;

  @override
  int get hashCode => code.hashCode ^ dialCode.hashCode;

  @override
  String toString() => '$flag $name ($dialCode)';
}
