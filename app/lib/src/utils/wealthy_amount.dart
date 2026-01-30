import 'package:intl/intl.dart';

class WealthyAmount {
  /// Add commas to the amount value
  static String formatNumber(String s) =>
      NumberFormat.decimalPattern('hi_IN').format(double.parse(s));

  static String currencyFormat(
    var amount,
    int numberOfPlaces, {
    bool showSuffix = false,
  }) {
    if (amount == null || amount == '') {
      return '₹0';
    }
    if (amount == 0) {
      return '₹0';
    }
    double parsedAmount = double.parse(amount.toString());

    if (!showSuffix) {
      String string = parsedAmount.toStringAsFixed(numberOfPlaces);
      if (string.length > 1 && double.parse(string) > 999) {
        return "₹${formatNumber(string.replaceAll(',', ''))}";
      } else {
        return "₹${string}";
      }
    }

    String currencyValue = '';
    if (parsedAmount >= 10000000) {
      currencyValue =
          '${(parsedAmount / 10000000).toStringAsFixed(numberOfPlaces)} Cr';
    } else if (parsedAmount >= 100000) {
      currencyValue =
          '${(parsedAmount / 100000).toStringAsFixed(numberOfPlaces)} L';
    } else if (parsedAmount >= 1000) {
      currencyValue =
          '${(parsedAmount / 1000).toStringAsFixed(numberOfPlaces)} K';
    } else {
      currencyValue = parsedAmount.toStringAsFixed(numberOfPlaces);
    }

    return '₹$currencyValue';
  }

  /// Formats amount to remove unnecessary trailing zeros after the decimal.
  /// Examples:
  ///   6.50 -> "6.5" (or "₹6.5" if addCurrency is true)
  ///   6.55 -> "6.55" (or "₹6.55" if addCurrency is true)
  static String formatWithoutTrailingZero(var amount, int numberOfPlaces,
      {bool addCurrency = false}) {
    if (amount == null || amount == '') {
      return addCurrency ? '₹0' : '0';
    }
    if (amount == 0) {
      return addCurrency ? '₹0' : '0';
    }

    double parsedAmount = double.parse(amount.toString());
    String formattedAmount = parsedAmount.toStringAsFixed(numberOfPlaces);

    // Remove trailing zeros and possible trailing decimal point
    formattedAmount = formattedAmount.replaceFirst(RegExp(r'\.?0+$'), '');

    if (formattedAmount.length > 1 && double.parse(formattedAmount) > 999) {
      formattedAmount = formatNumber(formattedAmount.replaceAll(',', ''));
    }

    return addCurrency ? "₹$formattedAmount" : formattedAmount;
  }

  // Merge this with currencyFormat
  static currencyFormatWithoutTrailingZero(var amount, int numberOfPlaces) {
    if (amount == null || amount == '') {
      return '₹0';
    }
    if (amount == 0) {
      return '₹0';
    }

    RegExp regex = RegExp(r"([.]+0+)(?!.*\d)");

    double parsedAmount = double.parse(amount.toString());

    String formattedAmount =
        parsedAmount.toStringAsFixed(numberOfPlaces).replaceAll(regex, '');

    if (formattedAmount.length > 1 && double.parse(formattedAmount) > 999) {
      return "₹${formatNumber(formattedAmount.replaceAll(',', ''))}";
    } else {
      return "₹${formattedAmount}";
    }
  }
}
