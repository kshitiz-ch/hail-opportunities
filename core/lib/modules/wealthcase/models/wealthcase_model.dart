import 'package:core/modules/common/resources/wealthy_cast.dart';

class WealthcaseModel {
  String? basketId;
  String? riaName;
  String? name;
  String? viewName;
  String? description;
  String? status;
  double? commissionRate;
  String? sectors;
  CagrModel? cagr;
  List<CagrBenchmarkModel>? cagrBenchmarks;
  double? minInvestment;
  DateTime? lastReviewedAt;
  DateTime? nextReviewDate;
  String? reviewFrequency;
  String? riskProfile;
  int? stockCount;
  SubscriptionModel? subscription;
  int? pendingRebalance;
  String? benchmarkIndex;
  PerformanceModel? performance;
  List<BenchmarkModel>? benchmarks;

  Map<String, Map<String, double>> tableData = {};
  Map<String, Map<String, List<WealthcaseChartDataModel>>> chartData = {};

  String selectedPeriod = '1M';

  List<String> get availablePeriods {
    return tableData.keys.map((k) => k.toUpperCase()).toList();
  }

  WealthcaseModel.fromJson(Map<String, dynamic> json) {
    basketId = WealthyCast.toStr(json['basket_id']);
    riaName = WealthyCast.toStr(json['ria_name']);
    name = WealthyCast.toStr(json['name']);
    viewName = WealthyCast.toStr(json['view_name']);
    description = WealthyCast.toStr(json['description']);
    status = WealthyCast.toStr(json['status']);
    commissionRate = WealthyCast.toDouble(json['commission_rate']);
    sectors = WealthyCast.toStr(json['sectors']);
    cagr = json['cagr'] != null ? CagrModel.fromJson(json['cagr']) : null;
    if (json['cagr_benchmarks'] != null) {
      cagrBenchmarks = <CagrBenchmarkModel>[];
      json['cagr_benchmarks'].forEach((v) {
        cagrBenchmarks!.add(CagrBenchmarkModel.fromJson(v));
      });
    }
    minInvestment = WealthyCast.toDouble(json['min_investment']);
    lastReviewedAt = WealthyCast.toDate(json['last_reviewed_at']);
    nextReviewDate = WealthyCast.toDate(json['next_review_date']);
    reviewFrequency = WealthyCast.toStr(json['review_frequency']);
    riskProfile = WealthyCast.toStr(json['risk_profile']);
    stockCount = WealthyCast.toInt(json['stock_count']);
    subscription = json['subscription'] != null
        ? SubscriptionModel.fromJson(json['subscription'])
        : null;
    pendingRebalance = WealthyCast.toInt(json['pending_rebalance']);
    benchmarkIndex = WealthyCast.toStr(json['benchmark_index']);
    performance = json['performance'] != null
        ? PerformanceModel.fromJson(json['performance'])
        : null;
    if (json['benchmarks'] != null) {
      benchmarks = <BenchmarkModel>[];
      json['benchmarks'].forEach((v) {
        benchmarks!.add(BenchmarkModel.fromJson(v));
      });
    }
    tableData = getTableData();
    chartData = getChartData();
  }

  // Helper methods for UI display
  String get formattedCagr1Y {
    if (cagr?.cagr1y == null) return '-';
    return '${(cagr!.cagr1y! * 100).toStringAsFixed(2)}%';
  }

  String get formattedCagr3Y {
    if (cagr?.cagr3y == null) return '-';
    return '${(cagr!.cagr3y! * 100).toStringAsFixed(2)}%';
  }

  String get formattedCagr5Y {
    if (cagr?.cagr5y == null) return '-';
    return '${(cagr!.cagr5y! * 100).toStringAsFixed(2)}%';
  }

  String get formattedCagrMax {
    if (cagr?.cagrMax == null) return '-';
    return '${(cagr!.cagrMax! * 100).toStringAsFixed(2)}%';
  }

  String get displayReviewFrequency {
    if (reviewFrequency == null) return 'Unknown';
    switch (reviewFrequency!.toUpperCase()) {
      case 'MONTHLY':
        return 'Monthly';
      case 'QUARTERLY':
        return 'Quarterly';
      case 'HALF_YEARLY':
        return 'Half Yearly';
      case 'YEARLY':
        return 'Yearly';
      case 'WEEKLY':
        return 'Weekly';
      case 'DAILY':
        return 'Daily';
      default:
        return reviewFrequency!
            .replaceAll('_', ' ')
            .toLowerCase()
            .split(' ')
            .map((word) => word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1)
                : '')
            .join(' ');
    }
  }

  /// Returns table data with time periods as keys and basket/benchmark performance as values
  /// For time >= 1 year: uses CAGR values
  /// For time < 1 year: uses return values from performance data
  Map<String, Map<String, double>> getTableData() {
    Map<String, Map<String, double>> tableData = {};

    // Define time periods
    final timePeriods = ['1m', '6m', '1y', '3y', '5y', 'max'];

    for (String timePeriod in timePeriods) {
      Map<String, double> periodData = {};

      // Add basket performance
      final basketName = name ?? 'Basket';

      if (timePeriod == '1m' || timePeriod == '6m') {
        // For short term periods, use performance return data
        final performanceValue = _getPerformanceReturn(timePeriod);
        if (performanceValue != null) {
          periodData[basketName] = performanceValue;
        }
      } else {
        // For long term periods (>=1y), use CAGR data
        final cagrValue = _getCagrValue(timePeriod);
        if (cagrValue != null) {
          periodData[basketName] = cagrValue * 100; // Convert to percentage
        }
      }

      // Add benchmark performance
      if (cagrBenchmarks != null) {
        for (var benchmark in cagrBenchmarks!) {
          final benchmarkName = benchmark.name ?? 'Benchmark';

          if (timePeriod == '1m' || timePeriod == '6m') {
            // For short term, try to get from performance benchmarks
            final benchmarkReturn =
                _getBenchmarkPerformanceReturn(timePeriod, benchmarkName);
            if (benchmarkReturn != null) {
              periodData[benchmarkName] = benchmarkReturn;
            }
          } else {
            // For long term, use CAGR from benchmark
            final benchmarkCagr = _getBenchmarkCagrValue(benchmark, timePeriod);
            if (benchmarkCagr != null) {
              periodData[benchmarkName] =
                  benchmarkCagr * 100; // Convert to percentage
            }
          }
        }
      }

      if (periodData.isNotEmpty) {
        tableData[timePeriod] = periodData;
      }
    }

    return tableData;
  }

  /// Get CAGR value for the basket based on time period
  double? _getCagrValue(String timePeriod) {
    if (cagr == null) return null;

    switch (timePeriod) {
      case '1y':
        return cagr!.cagr1y;
      case '3y':
        return cagr!.cagr3y;
      case '5y':
        return cagr!.cagr5y;
      case 'max':
        return cagr!.cagrMax;
      default:
        return null;
    }
  }

  /// Get CAGR value for benchmark based on time period
  double? _getBenchmarkCagrValue(
      CagrBenchmarkModel benchmark, String timePeriod) {
    if (benchmark.cagrDetails == null) return null;

    switch (timePeriod) {
      case '1y':
        return benchmark.cagrDetails!.cagr1y;
      case '3y':
        return benchmark.cagrDetails!.cagr3y;
      case '5y':
        return benchmark.cagrDetails!.cagr5y;
      case 'max':
        return benchmark.cagrDetails!.cagrMax;
      default:
        return null;
    }
  }

  /// Helper method to get the last performance data entry for a given time period
  PerformanceDataModel? _getLastPerformanceEntry(String timePeriod) {
    if (performance == null) return null;

    List<PerformanceDataModel>? periodData;
    switch (timePeriod) {
      case '1m':
        periodData = performance!.oneMonth;
        break;
      case '6m':
        periodData = performance!.sixMonths;
        break;
      default:
        return null;
    }

    if (periodData == null || periodData.isEmpty) return null;

    return periodData.last;
  }

  /// Get performance return for basket based on time period
  double? _getPerformanceReturn(String timePeriod) {
    final lastEntry = _getLastPerformanceEntry(timePeriod);
    return lastEntry?.changePerc;
  }

  /// Get benchmark performance return for short term periods
  double? _getBenchmarkPerformanceReturn(
      String timePeriod, String benchmarkName) {
    final lastEntry = _getLastPerformanceEntry(timePeriod);
    if (lastEntry?.benchmarks == null) return null;

    for (var benchmark in lastEntry!.benchmarks!) {
      if (benchmark.name == benchmarkName) {
        return benchmark.changePerc;
      }
    }
    return null;
  }

  /// Returns chart data with time periods as keys and basket/benchmark data as values
  /// Each period contains a map with basket name and benchmark names as keys
  /// and their corresponding List<WealthcaseChartDataModel> as values
  Map<String, Map<String, List<WealthcaseChartDataModel>>> getChartData() {
    if (performance == null) return {};

    final basketName = name ?? 'Basket';

    // Define time periods and their corresponding performance data
    final periodMap = <String, List<PerformanceDataModel>?>{
      '1m': performance!.oneMonth,
      '6m': performance!.sixMonths,
      '1y': performance!.oneYear,
      '3y': performance!.threeYears,
      '5y': performance!.fiveYears,
      'max': performance!.max,
    };

    final chartData = <String, Map<String, List<WealthcaseChartDataModel>>>{};

    for (final entry in periodMap.entries) {
      final period = entry.key;
      final periodData = entry.value;

      if (periodData == null || periodData.isEmpty) continue;

      // Get all unique benchmark names from first data point (optimization)
      final benchmarkNames = periodData.first.benchmarks
              ?.where((b) => b.name != null)
              .map((b) => b.name!)
              .toSet() ??
          <String>{};

      // Pre-allocate maps with known capacity
      final periodChartData = <String, List<WealthcaseChartDataModel>>{
        basketName: <WealthcaseChartDataModel>[],
        for (final name in benchmarkNames) name: <WealthcaseChartDataModel>[],
      };

      // Single pass through performance data
      for (final performanceData in periodData) {
        // Add basket data
        periodChartData[basketName]!.add(WealthcaseChartDataModel(
          date: performanceData.indexDate,
          initialValue: performanceData.initialValue,
          closeValue: performanceData.closeValue,
          name: basketName,
        ));

        // Add benchmark data using map lookup instead of nested loops
        if (performanceData.benchmarks != null) {
          for (final benchmark in performanceData.benchmarks!) {
            final benchmarkName = benchmark.name;
            if (benchmarkName != null &&
                periodChartData.containsKey(benchmarkName)) {
              periodChartData[benchmarkName]!.add(WealthcaseChartDataModel(
                date: performanceData.indexDate,
                initialValue: benchmark.initialValue,
                closeValue: benchmark.value,
                name: benchmarkName,
              ));
            }
          }
        }
      }

      // Remove empty lists and add to result
      periodChartData.removeWhere((key, value) => value.isEmpty);
      if (periodChartData.isNotEmpty) {
        chartData[period] = periodChartData;
      }
    }

    return chartData;
  }
}

class SubscriptionModel {
  double? amount;
  double? percentage;
  String? frequency;
  String? type;
  String? status;
  DateTime? nextDate;
  DateTime? expiryDate;
  Remarks? remarks;

  SubscriptionModel.fromJson(Map<String, dynamic> json) {
    amount = WealthyCast.toDouble(json['amount']);
    percentage = WealthyCast.toDouble(json['percentage']);
    frequency = WealthyCast.toStr(json['frequency']);
    type = WealthyCast.toStr(json['type']);
    status = WealthyCast.toStr(json['status']);
    nextDate = WealthyCast.toDate(json['next_date']);
    expiryDate = WealthyCast.toDate(json['expiry_date']);
    remarks =
        json['remarks'] != null ? Remarks.fromJson(json['remarks']) : null;
  }
}

class Remarks {
  String? percentageText;
  String? monthlyText;

  Remarks.fromJson(Map<String, dynamic> json) {
    percentageText = WealthyCast.toStr(json['percentage_text']);
    monthlyText = WealthyCast.toStr(json['monthly_text']);
  }
}

class CagrModel {
  double? cagr1y;
  double? cagr3y;
  double? cagr5y;
  double? cagrMax;

  CagrModel.fromJson(Map<String, dynamic> json) {
    cagr1y = WealthyCast.toDouble(json['cagr_1y']);
    cagr3y = WealthyCast.toDouble(json['cagr_3y']);
    cagr5y = WealthyCast.toDouble(json['cagr_5y']);
    cagrMax = WealthyCast.toDouble(json['cagr_max']);
  }
}

class CagrBenchmarkModel {
  String? name;
  CagrModel? cagrDetails;

  CagrBenchmarkModel({this.name, this.cagrDetails});

  CagrBenchmarkModel.fromJson(Map<String, dynamic> json) {
    name = WealthyCast.toStr(json['name']);
    cagrDetails = json['cagr_details'] != null
        ? CagrModel.fromJson(json['cagr_details'])
        : null;
  }
}

class BenchmarkModel {
  String? name;
  String? token;
  int? exchange;

  BenchmarkModel({this.name, this.token, this.exchange});

  BenchmarkModel.fromJson(Map<String, dynamic> json) {
    name = WealthyCast.toStr(json['name']);
    token = WealthyCast.toStr(json['token']);
    exchange = WealthyCast.toInt(json['exchange']);
  }
}

class PerformanceModel {
  List<PerformanceDataModel>? oneMonth;
  List<PerformanceDataModel>? sixMonths;
  List<PerformanceDataModel>? oneYear;
  List<PerformanceDataModel>? threeYears;
  List<PerformanceDataModel>? fiveYears;
  List<PerformanceDataModel>? max;

  PerformanceModel.fromJson(Map<String, dynamic> json) {
    if (json['1m'] != null) {
      oneMonth = <PerformanceDataModel>[];
      json['1m'].forEach((v) {
        oneMonth!.add(PerformanceDataModel.fromJson(v));
      });
    }
    if (json['6m'] != null) {
      sixMonths = <PerformanceDataModel>[];
      json['6m'].forEach((v) {
        sixMonths!.add(PerformanceDataModel.fromJson(v));
      });
    }
    if (json['1y'] != null) {
      oneYear = <PerformanceDataModel>[];
      json['1y'].forEach((v) {
        oneYear!.add(PerformanceDataModel.fromJson(v));
      });
    }
    if (json['3y'] != null) {
      threeYears = <PerformanceDataModel>[];
      json['3y'].forEach((v) {
        threeYears!.add(PerformanceDataModel.fromJson(v));
      });
    }
    if (json['5y'] != null) {
      fiveYears = <PerformanceDataModel>[];
      json['5y'].forEach((v) {
        fiveYears!.add(PerformanceDataModel.fromJson(v));
      });
    }
    if (json['MAX'] != null) {
      max = <PerformanceDataModel>[];
      json['MAX'].forEach((v) {
        max!.add(PerformanceDataModel.fromJson(v));
      });
    }
  }
}

class PerformanceDataModel {
  double? changePerc;
  double? closeValue;
  DateTime? indexDate;
  String? indexName;
  double? initialValue;
  double? perc;
  String? recordType;
  int? rk;
  List<PerformanceBenchmarkModel>? benchmarks;

  PerformanceDataModel.fromJson(Map<String, dynamic> json) {
    changePerc = WealthyCast.toDouble(json['change_perc']);
    closeValue = WealthyCast.toDouble(json['close_value']);
    indexDate = WealthyCast.toDate(json['index_date']);
    indexName = WealthyCast.toStr(json['index_name']);
    initialValue = WealthyCast.toDouble(json['initial_value']);
    perc = WealthyCast.toDouble(json['perc']);
    recordType = WealthyCast.toStr(json['record_type']);
    rk = WealthyCast.toInt(json['rk']);
    if (json['benchmarks'] != null) {
      benchmarks = <PerformanceBenchmarkModel>[];
      json['benchmarks'].forEach((v) {
        benchmarks!.add(PerformanceBenchmarkModel.fromJson(v));
      });
    }
  }
}

class PerformanceBenchmarkModel {
  String? name;
  double? value;
  double? initialValue;
  double? changePerc;

  PerformanceBenchmarkModel.fromJson(Map<String, dynamic> json) {
    name = WealthyCast.toStr(json['name']);
    value = WealthyCast.toDouble(json['value']);
    initialValue = WealthyCast.toDouble(json['initial_value']);
    changePerc = WealthyCast.toDouble(json['change_perc']);
  }
}

class WealthcaseChartDataModel {
  DateTime? date;
  double? initialValue;
  double? closeValue;
  String? name;
  double? normalisedValue;

  WealthcaseChartDataModel({
    this.date,
    this.initialValue,
    this.closeValue,
    this.name,
  }) {
    if (initialValue != null && initialValue != 0 && closeValue != null) {
      normalisedValue = (closeValue! / initialValue!) * 100;
    } else {
      normalisedValue = null;
    }
  }
}
