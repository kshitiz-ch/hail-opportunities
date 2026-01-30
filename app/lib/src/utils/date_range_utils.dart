/// Utility class to handle date range calculations
class DateRangeUtils {
  /// Helper function to create start of day (00:00:00)
  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Helper function to create end of day (23:59:59)
  static DateTime endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59);

  /// Get the dates for a given month and year
  static (DateTime start, DateTime end) getMonthDates(int year, int month) {
    final start = DateTime(year, month, 1);
    final end =
        (month < 12) ? DateTime(year, month + 1, 0) : DateTime(year + 1, 1, 0);
    return (start, end);
  }

  /// Calculate date range based on the selected time option
  ///
  /// Returns a tuple of (from, to) dates based on the provided [timeOption].
  /// The method handles various predefined time ranges and ensures proper
  /// date normalization with start/end of day times.
  ///
  /// Supported time options:
  /// - 'Last 7 Days': From 6 days ago to today
  /// - 'Last 15 Days': From 14 days ago to today
  /// - 'This Month': From 1st of current month to today
  /// - 'Last Month': Complete previous month
  /// - 'Last 3 Months': From 3 months ago to today
  /// - 'This Year': From January 1st of current year to today
  /// - Default: Today only
  static (DateTime from, DateTime to) calculateDateRange(String timeOption) {
    final now = DateTime.now();
    DateTime fromDate;
    DateTime toDate = endOfDay(now); // Default to end of current day

    switch (timeOption) {
      case 'Last 7 Days':
        fromDate = startOfDay(now.subtract(const Duration(days: 6)));
        break;

      case 'Last 15 Days':
        fromDate = startOfDay(now.subtract(const Duration(days: 14)));
        break;

      case 'This Month':
        fromDate = DateTime(now.year, now.month, 1);
        break;

      case 'Last Month':
        final (start, end) = now.month == 1
            ? getMonthDates(now.year - 1, 12) // December of previous year
            : getMonthDates(now.year, now.month - 1);
        fromDate = start;
        toDate = endOfDay(end);
        break;

      case 'Last 3 Months':
        // Use -2 to get exactly 3 months including current month
        // Example: If current month is June (6), then 6-2=4 (April)
        // Result: April, May, June = 3 complete months
        var month = now.month - 2;
        var year = now.year;

        if (month <= 0) {
          year--;
          month = 12 + month; // month is negative, so adding it subtracts
        }

        fromDate = DateTime(year, month, 1);
        // toDate remains end of current day
        break;

      case 'This Year':
        fromDate = DateTime(now.year, 1, 1);
        break;

      default:
        fromDate = startOfDay(now);
    }

    return _validateAndNormalizeDates(fromDate, toDate);
  }

  /// Ensure dates are valid and properly normalized
  static (DateTime from, DateTime to) _validateAndNormalizeDates(
    DateTime fromDate,
    DateTime toDate,
  ) {
    // Ensure fromDate is not after toDate
    if (fromDate.isAfter(toDate)) {
      final temp = fromDate;
      fromDate = toDate;
      toDate = temp;
    }

    // Normalize times to start/end of day
    return (startOfDay(fromDate), endOfDay(toDate));
  }
}
