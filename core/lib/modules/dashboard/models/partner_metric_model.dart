import 'package:core/modules/common/resources/wealthy_cast.dart';

enum MetricType {
  TotalAum,
  TotalInvestedAmount,
  Mf,
  PreIpo,
  Mld,
  Ncd,
  Pms,
  Fd,
}

enum MarketType { All, Equity, Debt, Alternative, Commodity }

class PartnerMetricModel {
  PartnerMetricModel(
      {this.id,
      this.TOTAL,
      this.TOTALDebt,
      this.TOTALEquity,
      this.MF,
      this.MFEquity,
      this.MFDebt,
      this.MFCommodity,
      this.MLD,
      this.MLDEquity,
      this.MLDDebt,
      this.MLDCommodity,
      this.MLDAlternative,
      this.PMS,
      this.PMSDebt,
      this.PMSEquity,
      this.INSURANCE,
      this.FD,
      this.PREIPO,
      this.SGB,
      this.GSEC,
      this.NCD,
      this.NCDDebt,
      this.NCDEquity,
      this.NCDAlternative,
      this.AIFDebt,
      this.AIFEquity,
      this.AIFAlternative,
      this.AIFCommodity,
      this.AIF,
      this.TOTALAlternative,
      this.TOTALCommodity,
      this.date});

  String? id;
  PartnerMetricValueModel? TOTAL;
  PartnerMetricValueModel? TOTALDebt;
  PartnerMetricValueModel? TOTALEquity;
  PartnerMetricValueModel? MF;
  PartnerMetricValueModel? MFEquity;
  PartnerMetricValueModel? MFDebt;
  PartnerMetricValueModel? MFCommodity;
  PartnerMetricValueModel? MLD;
  PartnerMetricValueModel? MLDEquity;
  PartnerMetricValueModel? MLDDebt;
  PartnerMetricValueModel? MLDCommodity;
  PartnerMetricValueModel? MLDAlternative;
  PartnerMetricValueModel? PMS;
  PartnerMetricValueModel? PMSDebt;
  PartnerMetricValueModel? PMSEquity;
  PartnerMetricValueModel? INSURANCE;
  PartnerMetricValueModel? FD;
  PartnerMetricValueModel? PREIPO;
  PartnerMetricValueModel? SGB;
  PartnerMetricValueModel? GSEC;
  PartnerMetricValueModel? NCD;
  PartnerMetricValueModel? NCDDebt;
  PartnerMetricValueModel? NCDEquity;
  PartnerMetricValueModel? NCDAlternative;
  PartnerMetricValueModel? AIFDebt;
  PartnerMetricValueModel? AIFEquity;
  PartnerMetricValueModel? AIFAlternative;
  PartnerMetricValueModel? AIFCommodity;
  PartnerMetricValueModel? AIF;
  PartnerMetricValueModel? TOTALAlternative;
  PartnerMetricValueModel? TOTALCommodity;
  DateTime? date;

  MarketType _marketTypeSelected = MarketType.All;

  MarketType get marketTypeSelected => this._marketTypeSelected;

  set marketTypeSelected(MarketType marketType) {
    this._marketTypeSelected = marketType;
  }

  Map<MetricType, double> get metricDataByType {
    Map<MetricType, Map<MarketType, PartnerMetricValueModel?>> metricOverview =
        {
      MetricType.TotalAum: {
        MarketType.All: this.TOTAL,
        MarketType.Debt: this.TOTALDebt,
        MarketType.Equity: this.TOTALEquity,
        MarketType.Alternative: this.TOTALAlternative,
        MarketType.Commodity: this.TOTALCommodity
      },
      MetricType.Mf: {
        MarketType.All: this.MF,
        MarketType.Debt: this.MFDebt,
        MarketType.Equity: this.MFEquity,
        MarketType.Alternative: null,
        MarketType.Commodity: this.MFCommodity,
      },
      MetricType.Mld: {
        MarketType.All: this.MLD,
        MarketType.Debt: this.MLDDebt,
        MarketType.Equity: this.MLDEquity,
        MarketType.Alternative: this.MLDAlternative,
        MarketType.Commodity: this.MLDCommodity,
      },
      MetricType.Ncd: {
        MarketType.All: this.NCD,
        MarketType.Debt: this.NCDDebt,
        MarketType.Equity: this.NCDEquity,
        MarketType.Alternative: this.NCDAlternative,
        MarketType.Commodity: null,
      },
      MetricType.Pms: {
        MarketType.All: this.PMS,
        MarketType.Debt: this.PMSDebt,
        MarketType.Equity: this.PMSEquity,
        MarketType.Alternative: null,
        MarketType.Commodity: null,
      },
      MetricType.PreIpo: {
        MarketType.All: this.PREIPO,
        MarketType.Debt: null,
        MarketType.Equity: null,
        MarketType.Alternative: null,
        MarketType.Commodity: null,
      },
      MetricType.Fd: {
        MarketType.All: this.FD,
        MarketType.Debt: null,
        MarketType.Equity: null,
        MarketType.Alternative: null,
        MarketType.Commodity: null,
      }
    };

    return {
      MetricType.TotalAum:
          metricOverview[MetricType.TotalAum]![marketTypeSelected]
                  ?.currentValue ??
              0,
      MetricType.TotalInvestedAmount:
          metricOverview[MetricType.TotalAum]![marketTypeSelected]
                  ?.currentInvestedValue ??
              0,
      MetricType.Mf:
          metricOverview[MetricType.Mf]![marketTypeSelected]?.currentValue ?? 0,
      MetricType.PreIpo: metricOverview[MetricType.PreIpo]![marketTypeSelected]
              ?.currentValue ??
          0,
      MetricType.Mld:
          metricOverview[MetricType.Mld]![marketTypeSelected]?.currentValue ??
              0,
      MetricType.Ncd:
          metricOverview[MetricType.Ncd]![marketTypeSelected]?.currentValue ??
              0,
      MetricType.Pms:
          metricOverview[MetricType.Pms]![marketTypeSelected]?.currentValue ??
              0,
      MetricType.Fd:
          metricOverview[MetricType.Fd]![marketTypeSelected]?.currentValue ?? 0,
    };
  }

  factory PartnerMetricModel.fromJson(Map<String, dynamic> json) =>
      PartnerMetricModel(
          id: WealthyCast.toStr(json["id"]),
          TOTAL: PartnerMetricValueModel.fromJson(json["TOTAL"]),
          TOTALDebt: PartnerMetricValueModel.fromJson(json["TOTALDebt"]),
          TOTALEquity: PartnerMetricValueModel.fromJson(json["TOTALEquity"]),
          MF: PartnerMetricValueModel.fromJson(json["MF"]),
          MFEquity: PartnerMetricValueModel.fromJson(json["MFEquity"]),
          MFDebt: PartnerMetricValueModel.fromJson(json["MFDebt"]),
          MFCommodity: PartnerMetricValueModel.fromJson(json["MFCommodity"]),
          MLD: PartnerMetricValueModel.fromJson(json["MLD"]),
          MLDEquity: PartnerMetricValueModel.fromJson(json["MLDEquity"]),
          MLDDebt: PartnerMetricValueModel.fromJson(json["MLDDebt"]),
          MLDCommodity: PartnerMetricValueModel.fromJson(json["MLDCommodity"]),
          MLDAlternative:
              PartnerMetricValueModel.fromJson(json["MLDAlternative"]),
          PMS: PartnerMetricValueModel.fromJson(json["PMS"]),
          PMSDebt: PartnerMetricValueModel.fromJson(json["PMSDebt"]),
          PMSEquity: PartnerMetricValueModel.fromJson(json["PMSEquity"]),
          INSURANCE: PartnerMetricValueModel.fromJson(json["INSURANCE"]),
          FD: PartnerMetricValueModel.fromJson(json["FD"]),
          PREIPO: PartnerMetricValueModel.fromJson(json["PREIPO"]),
          SGB: PartnerMetricValueModel.fromJson(json["SGB"]),
          GSEC: PartnerMetricValueModel.fromJson(json["GSEC"]),
          NCD: PartnerMetricValueModel.fromJson(json["NCD"]),
          NCDDebt: PartnerMetricValueModel.fromJson(json["NCDDebt"]),
          NCDEquity: PartnerMetricValueModel.fromJson(json["NCDEquity"]),
          NCDAlternative:
              PartnerMetricValueModel.fromJson(json["NCDAlternative"]),
          AIFDebt: PartnerMetricValueModel.fromJson(json["AIFDebt"]),
          AIFEquity: PartnerMetricValueModel.fromJson(json["AIFEquity"]),
          AIFAlternative:
              PartnerMetricValueModel.fromJson(json["AIFAlternative"]),
          AIFCommodity: PartnerMetricValueModel.fromJson(json["AIFCommodity"]),
          AIF: PartnerMetricValueModel.fromJson(json["AIF"]),
          TOTALAlternative:
              PartnerMetricValueModel.fromJson(json["TOTALAlternative"]),
          TOTALCommodity:
              PartnerMetricValueModel.fromJson(json["TOTALCommodity"]),
          date: WealthyCast.toDate(
            json["date"],
          ));
}

class PartnerMetricValueModel {
  PartnerMetricValueModel({this.currentInvestedValue, this.currentValue});

  double? currentInvestedValue;
  double? currentValue;

  factory PartnerMetricValueModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return PartnerMetricValueModel(currentInvestedValue: 0, currentValue: 0);
    }

    return PartnerMetricValueModel(
      currentInvestedValue:
          WealthyCast.toDouble(json["current_invested_value"]),
      currentValue: WealthyCast.toDouble(json["current_value"]),
    );
  }
}
