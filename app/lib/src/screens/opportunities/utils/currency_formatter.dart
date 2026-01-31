/// Utility functions for formatting currency values in Opportunities module
class CurrencyFormatter {
  /// Formats a numeric amount into a compact currency string
  /// Examples: 10000000 -> "Rs. 1.0Cr", 150000 -> "Rs. 1.5L", 5000 -> "Rs. 5.0K"
  static String formatCompact(dynamic value) {
    if (value == null) return 'Rs. 0';
    
    double amount;
    if (value is String) {
      // Remove any existing currency symbols and parse
      final cleanValue = value
          .replaceAll('₹', '')
          .replaceAll('Rs.', '')
          .replaceAll('Rs', '')
          .replaceAll(',', '')
          .trim();
      amount = double.tryParse(cleanValue) ?? 0;
    } else if (value is num) {
      amount = value.toDouble();
    } else {
      return 'Rs. 0';
    }
    
    if (amount >= 10000000) {
      return 'Rs. ${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return 'Rs. ${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return 'Rs. ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return 'Rs. ${amount.toInt()}';
  }

  /// Formats a pre-formatted string value (like "₹1.82 L") to use "Rs." prefix
  static String sanitize(String? value) {
    if (value == null || value.isEmpty) return 'Rs. 0';
    return value
        .replaceAll('₹', 'Rs. ')
        .replaceAll('Rs.Rs.', 'Rs.')
        .trim();
  }
}
