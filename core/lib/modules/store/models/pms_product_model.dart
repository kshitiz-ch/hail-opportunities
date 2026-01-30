import 'package:core/modules/common/resources/wealthy_cast.dart';

class PMSProductsModel {
  List<PMSModel>? products;

  PMSProductsModel({this.products});

  PMSProductsModel.fromJson(Map<String, dynamic> json) {
    products = WealthyCast.toList(json['products'])
        .map((e) => PMSModel.fromJson(e))
        .toList();
  }
}

class PMSModel {
  String? productDescription;
  String? productManufacturer;
  List<PMSVariantModel>? variants;
  String? iconSvg;

  PMSModel(
      {this.productDescription,
      this.productManufacturer,
      this.variants,
      this.iconSvg});

  PMSModel.fromJson(Map<String, dynamic> json) {
    productDescription = WealthyCast.toStr(json['product_description']);
    productManufacturer = WealthyCast.toStr(json['product_manufacturer']);
    variants = WealthyCast.toList(json['variants'])
        .map((e) => PMSVariantModel.fromJson(e))
        .toList();
    iconSvg = WealthyCast.toStr(json['icon_svg']);
  }
}

class PMSVariantModel {
  int? id;
  int? productVariant;
  String? productType;
  String? category;
  String? categoryText;
  String? title;
  String? description;
  String? productUrl;
  String? iconSvg;
  String? iconUrl;
  List? possibleSwitchPeriods;
  bool? selectClient;
  bool? released;
  int? expiryTime;
  double? minPurchaseAmount;
  double? minTopupAmount;
  double? maxSellPrice;
  String? reportId;
  String? reportUrl;
  bool? isPublished;
  String? publishedAt;
  String? assetType;
  String? manufacturer;
  String? lastUpdatedAt;
  double? oneYearReturn;
  double? threeYearReturn;
  double? fiveYearReturn;
  double? returnsSinceLaunch;
  String? exitLoadDisplay;

  // New fields
  double? oneMonthReturn;
  double? threeMonthReturn;
  double? sixMonthReturn;
  double? oneMonthBenchmarkReturn;
  double? threeMonthBenchmarkReturn;
  double? sixMonthBenchmarkReturn;
  double? oneYearBenchmarkReturn;
  double? threeYearBenchmarkReturn;
  double? fiveYearBenchmarkReturn;
  double? sinceInceptionBenchmarkReturn;
  String? fundManager;
  double? currentAum;
  DateTime? inceptionDate;
  String? hurdleRate;

  double? sharpeRatio;

  double? beta;
  double? peRatio;
  double? pbRatio;
  bool? sipOption;
  bool? stpOption;
  String? benchmark;
  String? benchmarkName;
  Map<String, dynamic>? extras;
  DateTime? dataAsOnDate;

  // Percentage Field
  // (Management Fee - Fixed), (Management Fee - Hybrid), Exit Load, standard deviation.
  String? expenseRatio;
  String? expenseRatioProfitShare;
  String? exitLoad;
  String? standardDeviation;
  String? profitShare;

  // Chart Field
  List<PMSPieChartModel>? holdingsPie;
  List<PMSPieChartModel>? sectorAllocationPie;
  List<PMSPieChartModel>? marketCapPie;
  List<PMSLineChartModel>? strategyVsBenchmarkLine;

  PMSVariantModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toInt(json['id']);
    productVariant = WealthyCast.toInt(json['product_variant']);
    productType = WealthyCast.toStr(json['product_type']);
    category = WealthyCast.toStr(json['category']);
    categoryText = WealthyCast.toStr(json['category_text']);
    title = WealthyCast.toStr(json['title']);
    description = WealthyCast.toStr(json['description']);
    productUrl = WealthyCast.toStr(json['product_url']);
    iconSvg = WealthyCast.toStr(json['icon_svg']);
    iconUrl = WealthyCast.toStr(json['icon_url']);
    possibleSwitchPeriods = WealthyCast.toList(json['possible_switch_periods']);
    selectClient = WealthyCast.toBool(json['select_client']);
    released = WealthyCast.toBool(json['released']);
    expiryTime = WealthyCast.toInt(json['expiry_time']);
    minPurchaseAmount = WealthyCast.toDouble(json['min_purchase_amount']);
    minTopupAmount = WealthyCast.toDouble(json['min_topup_amount']);
    maxSellPrice = WealthyCast.toDouble(json['max_sell_price']);
    reportId = WealthyCast.toStr(json['report_id']);
    reportUrl = WealthyCast.toStr(json['report_url']);
    isPublished = WealthyCast.toBool(json['is_published']);
    publishedAt = WealthyCast.toStr(json['published_at']);
    assetType = WealthyCast.toStr(json['asset_type']);
    manufacturer = WealthyCast.toStr(json['manufacturer']);
    lastUpdatedAt = WealthyCast.toStr(json['last_updated_at']);
    oneYearReturn = WealthyCast.toDouble(json['one_year_return']);
    threeYearReturn = WealthyCast.toDouble(json['three_year_return']);
    fiveYearReturn = WealthyCast.toDouble(json['five_year_return']);
    expenseRatio = WealthyCast.toStr(json['expense_ratio']);
    expenseRatioProfitShare =
        WealthyCast.toStr(json['expense_ratio_profit_share']);
    exitLoad = WealthyCast.toStr(json['exit_load']);
    returnsSinceLaunch = WealthyCast.toDouble(json['returns_since_launch']);
    exitLoadDisplay = WealthyCast.toStr(json['exit_load_display']);

    // New fields mapping
    oneMonthReturn = WealthyCast.toDouble(json['one_month_return']);
    threeMonthReturn = WealthyCast.toDouble(json['three_month_return']);
    sixMonthReturn = WealthyCast.toDouble(json['six_month_return']);
    oneMonthBenchmarkReturn =
        WealthyCast.toDouble(json['one_month_benchmark_return']);
    threeMonthBenchmarkReturn =
        WealthyCast.toDouble(json['three_month_benchmark_return']);
    sixMonthBenchmarkReturn =
        WealthyCast.toDouble(json['six_month_benchmark_return']);
    oneYearBenchmarkReturn =
        WealthyCast.toDouble(json['one_year_benchmark_return']);
    threeYearBenchmarkReturn =
        WealthyCast.toDouble(json['three_year_benchmark_return']);
    fiveYearBenchmarkReturn =
        WealthyCast.toDouble(json['five_year_benchmark_return']);
    sinceInceptionBenchmarkReturn =
        WealthyCast.toDouble(json['since_inception_benchmark_return']);
    fundManager = WealthyCast.toStr(json['fund_manager']);
    currentAum = WealthyCast.toDouble(json['current_aum']);
    inceptionDate = WealthyCast.toDate(json['inception_date']);
    hurdleRate = WealthyCast.toStr(json['hurdle_rate']);
    profitShare = WealthyCast.toStr(json['profit_share']);
    standardDeviation = WealthyCast.toStr(json['standard_deviation']);

    sharpeRatio = WealthyCast.toDouble(json['sharpe_ratio']);

    beta = WealthyCast.toDouble(json['beta']);
    peRatio = WealthyCast.toDouble(json['pe_ratio']);
    pbRatio = WealthyCast.toDouble(json['pb_ratio']);
    sipOption = WealthyCast.toBool(json['sip_option']);
    stpOption = WealthyCast.toBool(json['stp_option']);
    benchmark = WealthyCast.toStr(json['benchmark']);
    benchmarkName = WealthyCast.toStr(json['benchmark_name']);
    extras = json['extras'];
    dataAsOnDate = WealthyCast.toDate(json['data_as_on_date']);
    holdingsPie = WealthyCast.toList(json['holdings_pie'])
        .map((e) => PMSPieChartModel.fromJson(e))
        .toList();
    sectorAllocationPie = WealthyCast.toList(json['sector_allocation_pie'])
        .map((e) => PMSPieChartModel.fromJson(e))
        .toList();
    marketCapPie = WealthyCast.toList(json['market_cap_pie'])
        .map((e) => PMSPieChartModel.fromJson(e))
        .toList();
    strategyVsBenchmarkLine =
        WealthyCast.toList(json['strategy_vs_benchmark_line'])
            .map((e) => PMSLineChartModel.fromJson(e))
            .toList();
  }
}

class PMSPieChartModel {
  String? name;
  double? value;

  PMSPieChartModel({this.name, this.value});

  PMSPieChartModel.fromJson(Map<String, dynamic> json) {
    name = WealthyCast.toStr(json['name']);
    value = WealthyCast.toDouble(json['value']);
  }
}

class PMSLineChartModel {
  String? year;
  double? strategy;
  double? benchmark;

  PMSLineChartModel({this.year, this.strategy, this.benchmark});

  PMSLineChartModel.fromJson(Map<String, dynamic> json) {
    year = WealthyCast.toStr(json['year']);
    strategy = WealthyCast.toDouble(json['strategy']);
    benchmark = WealthyCast.toDouble(json['benchmark']);
    if (year == 'Since Inception') {
      // Handle 'Since Inception' case
      year = 'Since\nInception';
    }
  }
}
