import 'package:material_ui/material_ui.dart';
import 'package:self_finance/core/constants/constants.dart';

/// circular avatar widget that displays user initials
/// with a deterministic, harmonious background color when no profile image exists.
class DefaultUserImage extends StatelessWidget {
  const DefaultUserImage({
    super.key,
    this.userName,
    this.height,
    this.width,
    this.backgroundColor,
    this.textColor,
  });

  /// Name of the user used to generate initials and background color.
  final String? userName;

  /// Optional height constraint. Defaults to [width] or 44.0.
  final double? height;

  /// Optional width constraint. Defaults to [height] or 44.0.
  final double? width;

  /// Optional custom background color override.
  final Color? backgroundColor;

  /// Optional custom text color override.
  final Color? textColor;

  /// Pre-compiled regex to avoid re-compilation on every build frame.
  static final RegExp _whitespaceRegex = RegExp(r'\s+');

  /// Curated palette of accessible, vibrant avatar accent colors.
  static const List<Color> _avatarColors = <Color>[
    Color(0xFF4F46E5), // Indigo
    Color(0xFF2563EB), // Blue
    Color(0xFF0284C7), // Light Blue
    Color(0xFF0D9488), // Teal
    Color(0xFF059669), // Emerald
    Color(0xFF16A34A), // Green
    Color(0xFFD97706), // Amber
    Color(0xFFEA580C), // Orange
    Color(0xFFDC2626), // Red
    Color(0xFFDB2777), // Pink
    Color(0xFF9333EA), // Purple
    Color(0xFF7C3AED), // Violet
    Color(0xFF0891B2), // Cyan
    Color(0xFFE11D48), // Rose
  ];

  /// Extracts up to two initials from [name] in uppercase.
  /// Falls back to 'SF' if [name] is null or blank.
  static String getInitials(String? name) {
    if (name == null) return 'SF';
    final String clean = name.trim();
    if (clean.isEmpty) return 'SF';

    final List<String> words = clean
        .split(_whitespaceRegex)
        .where((String w) => w.isNotEmpty)
        .toList();

    if (words.length >= 2 && words[0].isNotEmpty && words[1].isNotEmpty) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }

    if (clean.length >= 2) {
      return clean.substring(0, 2).toUpperCase();
    }

    return clean.toUpperCase();
  }

  /// Deterministically maps [name] to a background color from [_avatarColors].
  static Color getColorForName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return _avatarColors.first;
    }
    final int hash = name.trim().toLowerCase().codeUnits.fold<int>(
      0,
      (int prev, int curr) => prev + curr,
    );
    return _avatarColors[hash.abs() % _avatarColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final double size = height ?? width ?? 44.0;
    final String initials = getInitials(userName);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accentColor = getColorForName(userName);

    // Soft accent tinted background instead of harsh solid saturation
    final Color bgColor =
        backgroundColor ?? accentColor.withValues(alpha: isDark ? 0.22 : 0.12);

    final Color fgColor =
        textColor ?? (backgroundColor != null ? Colors.white : accentColor);

    final double fontSize = size * 0.38;

    return Semantics(
      label: userName != null && userName!.trim().isNotEmpty
          ? '$userName avatar'
          : 'User avatar',
      child: SizedBox(
        height: size,
        width: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: accentColor.withValues(alpha: isDark ? 0.28 : 0.16),
            ),
          ),
          child: Center(
            child: Text(
              initials,
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                color: fgColor,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                fontFamily: Constant.appFont,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
