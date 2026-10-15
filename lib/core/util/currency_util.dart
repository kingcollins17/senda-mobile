import 'package:intl/intl.dart';

/// Extension on [num] to format numeric values as currency strings.
extension CurrencyFormatting on num {
  /// Formats this number into a Nigerian Naira currency string using [NumberFormat.currency].
  ///
  /// [decimalDigits] defaults to 0.
  /// Example:
  /// ```dart
  /// 5000.toNaira(); // "₦5,000"
  /// 5000.5.toNaira(decimalDigits: 2); // "₦5,000.50"
  /// ```
  String toNaira({int decimalDigits = 0}) {
    return NumberFormat.currency(
      symbol: '₦',
      decimalDigits: decimalDigits,
    ).format(this);
  }

  /// Formats this number into a USDC currency string.
  ///
  /// [decimalDigits] defaults to 2.
  /// Example:
  /// ```dart
  /// 13.8.toUSDC(); // "13.80 USDC"
  /// 13.8.toUSDC(showSymbol: false); // "13.80"
  /// ```
  String toUSDC({
    int decimalDigits = 2,
    bool showSymbol = true,
    String symbol = 'USDC',
  }) {
    final formatted = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: decimalDigits,
    ).format(this).trim();
    return showSymbol ? '$formatted $symbol' : formatted;
  }
}

/// Convenience extension on nullable [num] for safe currency formatting.
extension CurrencyFormattingNullable on num? {
  /// Formats this nullable number into a Nigerian Naira currency string using [NumberFormat.currency].
  /// Returns [fallback] (defaulting to "₦0") when the value is null.
  String toNaira({int decimalDigits = 0, String fallback = '₦0'}) {
    if (this == null) return fallback;
    return this!.toNaira(decimalDigits: decimalDigits);
  }

  /// Formats this nullable number into a USDC currency string.
  /// Returns [fallback] (defaulting to "0.00 USDC") when the value is null.
  String toUSDC({
    int decimalDigits = 2,
    bool showSymbol = true,
    String symbol = 'USDC',
    String? fallback,
  }) {
    if (this == null) {
      return fallback ?? (showSymbol ? '0.00 $symbol' : '0.00');
    }
    return this!.toUSDC(
      decimalDigits: decimalDigits,
      showSymbol: showSymbol,
      symbol: symbol,
    );
  }
}

/// Convenience extension on [String] representing numeric amounts.
extension CurrencyStringFormatting on String {
  /// Parses the string into a number and formats it as a Nigerian Naira string.
  /// Returns the original string if parsing fails.
  String toNaira({int decimalDigits = 0}) {
    final parsed = num.tryParse(replaceAll(',', '').trim());
    return parsed != null ? parsed.toNaira(decimalDigits: decimalDigits) : this;
  }

  /// Parses the string into a number and formats it as a USDC string.
  /// Returns the original string if parsing fails.
  String toUSDC({
    int decimalDigits = 2,
    bool showSymbol = true,
    String symbol = 'USDC',
  }) {
    final parsed = num.tryParse(replaceAll(',', '').trim());
    return parsed != null
        ? parsed.toUSDC(
            decimalDigits: decimalDigits,
            showSymbol: showSymbol,
            symbol: symbol,
          )
        : this;
  }
}
