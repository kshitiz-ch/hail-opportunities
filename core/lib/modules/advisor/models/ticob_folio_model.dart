import 'package:core/modules/common/resources/wealthy_cast.dart';

class TicobFolioListing {
  List<TicobFolioModel> ticobRegularFolioList = [];
  List<TicobFolioModel> ticobNonRegularFolioList = [];

  int get totalFolios =>
      ticobRegularFolioList.length + ticobNonRegularFolioList.length;

  TicobFolioListing.fromJson(Map<String, dynamic> json) {
    ticobRegularFolioList = [];
    ticobNonRegularFolioList = [];
    WealthyCast.toList(json['familyMfSchemeOverviews']).forEach(
      (jsonData) {
        final folioOverviewJsonList =
            WealthyCast.toList(jsonData['folioOverviews']);
        folioOverviewJsonList.forEach(
          (folioOverviewJson) {
            final schemeCode = WealthyCast.toStr(
                folioOverviewJson['schemeCode'] ??
                    jsonData['schemeCode'] ??
                    jsonData['schemeMeta']?['schemeCode']);
            final folioNumber =
                WealthyCast.toStr(folioOverviewJson['folioNumber']);
            final investedAmount =
                WealthyCast.toDouble(folioOverviewJson['investedAmount']);
            final currentValue =
                WealthyCast.toDouble(folioOverviewJson['currentValue']);
            final amc = WealthyCast.toStr(jsonData['schemeMeta']?['amc']);
            final amcCode =
                WealthyCast.toStr(jsonData['schemeMeta']?['amcCode']);
            final planType =
                WealthyCast.toStr(jsonData['schemeMeta']?['planType']);

            final ticobFolioModel = TicobFolioModel(
              schemeCode: schemeCode,
              folioNumber: folioNumber,
              investedAmount: investedAmount,
              currentValue: currentValue,
              amc: amc,
              amcCode: (amcCodeMapping[amcCode] ?? '').toString(),
              planType: planType,
            );

            if (ticobFolioModel.isRegularFund) {
              ticobRegularFolioList.add(ticobFolioModel);
            } else {
              ticobNonRegularFolioList.add(ticobFolioModel);
            }
          },
        );
      },
    );
  }
}

class TicobFolioModel {
  String? schemeCode;
  String? folioNumber;
  double? investedAmount;
  double? currentValue;
  String? amc;
  String? amcCode;
  String? planType;

  TicobFolioModel({
    this.schemeCode,
    this.folioNumber,
    this.investedAmount,
    this.currentValue,
    this.amc,
    this.amcCode,
    this.planType,
  });

  bool get isRegularFund => this.planType?.toUpperCase() == 'R';
  bool get isDisabled => !isRegularFund;
}

const amcCodeMapping = {
  'FRN': 1001,
  'RIL': 1004,
  'TRS': 1005,
  'SBI': 1007,
  'KKM': 1008,
  'ICI': 1009,
  'SNM': 1011,
  'LNT': 1013,
  'CNR': 1016,
  'PBG': 1020,
  'BNP': 1021,
  'DSP': 1023,
  'ABS': 1025,
  'UTI': 1026,
  'IDF': 1028,
  'TAT': 1029,
  'HDF': 1030,
  'PNP': 1033,
  'AXS': 1040,
  'PRF': 1044,
  'MRE': 1045,
  'MOS': 1046,
  'INV': 1051,
  'EDL': 1052,
  'ESS': 1048,
  'PFS': 1053,
  'QTI': 1054,
  'OAK': 1055,
  'HSB': 1050,
  'IIF': 1056,
  'MHD': 1057,
  'UNN': 1058,
  'LIC': 1047,
  'JMF': 1062,
  'SMC': 1059,
  'ITI': 1060,
  'QMF': 1061,
  'IDB': 1049,
  'BMF': 1063,
  'HLS': 1064,
  'TRT': 1065,
  'OBR': 1066,
  'BOI': 1067,
  'IND': 1068,
  'CPM': 1069,
  'UNF': 1070
};
