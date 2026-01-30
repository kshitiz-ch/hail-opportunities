import 'package:api_sdk/log_util.dart';
import 'package:core/config/string_utils.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';

class RevenueDetailModel {
  String? earningType;
  RowDataModel? revenueTypeDisplay;
  RowDataModel? productRemarkDisplay;
  RowDataModel? revenueCalculationDisplay;
  RowDataModel? revenueRemarkDisplay;
  RowDataModel? revenueDisplay;
  RowDataModel? releasedDateDisplay;
  RowDataModel? payoutDateDisplay;
  RowDataModel? revenueDateDisplay;
  RowDataModel? txnAmtOrdProcDisplay;
  RowDataModel? agentDetailsDisplay;
  RevenueDates? revenueDates;
  RowDataModel? uniqueIdentifiersDisplay;

  Map<String, dynamic>? mappedUIData;

  bool get doesReleasedDateExist {
    return ((this.releasedDateDisplay?.row1?.text ?? '').isNotNullOrEmpty &&
        this.releasedDateDisplay?.row1?.text != "-");
  }

  RevenueDetailModel.fromJson(Map<String, dynamic> json) {
    earningType = WealthyCast.toStr(json['earning_type']);
    revenueTypeDisplay = json['revenue_type_display'] != null
        ? RowDataModel.fromJson(json['revenue_type_display'])
        : null;
    productRemarkDisplay = json['product_remark_display'] != null
        ? RowDataModel.fromJson(json['product_remark_display'])
        : null;
    revenueCalculationDisplay = json['revenue_calculation_display'] != null
        ? RowDataModel.fromJson(json['revenue_calculation_display'])
        : null;
    revenueRemarkDisplay = json['revenue_remark_display'] != null
        ? RowDataModel.fromJson(json['revenue_remark_display'])
        : null;
    revenueDisplay = json['revenue_display'] != null
        ? RowDataModel.fromJson(json['revenue_display'])
        : null;
    releasedDateDisplay = json['released_date_display'] != null
        ? RowDataModel.fromJson(json['released_date_display'])
        : null;
    payoutDateDisplay = json['payout_date_display'] != null
        ? RowDataModel.fromJson(json['payout_date_display'])
        : null;
    revenueDateDisplay = json['revenue_date_display'] != null
        ? RowDataModel.fromJson(json['revenue_date_display'])
        : null;
    txnAmtOrdProcDisplay = json['txn_amt_ord_proc_display'] != null
        ? RowDataModel.fromJson(json['txn_amt_ord_proc_display'])
        : null;
    agentDetailsDisplay = json['agent_details_display'] != null
        ? RowDataModel.fromJson(json['agent_details_display'])
        : null;
    revenueDates = json['revenue_dates'] != null
        ? RevenueDates.fromJson(json['revenue_dates'])
        : null;
    uniqueIdentifiersDisplay = json['unique_identifiers_display'] != null
        ? RowDataModel.fromJson(json['unique_identifiers_display'])
        : null;
    mappedUIData = _getMappedUIData();
  }

  Map<String, dynamic> _getMappedUIData() {
    final isWealthCaseProduct =
        (this.earningType ?? '').toLowerCase().replaceAll(" ", "") ==
            'wealthcase'; // wealthcase product

    final productRemark1 =
        (this.productRemarkDisplay?.row1?.text ?? '').toLowerCase();
    final productRemark2 =
        (this.productRemarkDisplay?.row2?.text ?? '').toLowerCase();
    final orderType = productRemark1.contains('sip')
        ? 'Sip'
        : productRemark1.contains('onetime')
            ? 'One Time'
            : '';
    final name = orderType.isNullOrEmpty
        ? productRemark1
        : productRemark2.isNotNullOrEmpty
            ? productRemark2
            : productRemark1;
    final orderIdDisplay = this.txnAmtOrdProcDisplay?.row2?.text;
    String orderId =
        orderIdDisplay.isNotNullOrEmpty && orderIdDisplay!.contains(':')
            ? orderIdDisplay.split(':').last
            : 'N/A';
    final transactionDisplay = this.txnAmtOrdProcDisplay?.row1?.text;
    String transactionDate = 'N/A';
    String transactionAmount = 'N/A';

    if (transactionDisplay.isNotNullOrEmpty &&
        transactionDisplay!.contains('|')) {
      transactionDate = transactionDisplay.split('|').last.trim();
      transactionAmount = transactionDisplay.split('|').first.trim();
    }

    // Product Type
    String productType = '';
    try {
      final productRemarkList =
          productRemark1.contains('-') ? productRemark1.split('-') : [];
      if (productRemarkList.length >= 2) {
        productType = productRemarkList[1].toString();
      }
    } catch (e) {}

    // get unique identifiers
    Map<String, String> uniqueIdentifierMap = {};
    if (uniqueIdentifiersDisplay?.row1?.jsonData != null) {
      try {
        Map uniqueIdentifierJson =
            uniqueIdentifiersDisplay?.row1?.jsonData ?? {};
        if (uniqueIdentifierJson.isNotEmpty) {
          uniqueIdentifierJson.entries.forEach(
            (identifier) {
              if (identifier.key == 'brokerage_id') {
                // don't show brokerage id
                return;
              }
              final uniqueIdentifierKey = identifier.key
                  .toString()
                  .replaceAll('_', ' ')
                  .toCapitalized();
              final uniqueIdentifierValue =
                  identifier.value.toString().toCapitalized();
              if (uniqueIdentifierKey.isNotNullOrEmpty) {
                uniqueIdentifierMap[uniqueIdentifierKey] =
                    uniqueIdentifierValue.isNotNullOrEmpty
                        ? uniqueIdentifierValue
                        : 'N/A';
              }
            },
          );
        }
      } catch (e) {
        LogUtil.printLog('error ' + e.toString());
      }
    }

    final source = this.revenueTypeDisplay?.row2?.text?.toUpperCase();

    String transactionDetail = '$transactionAmount\n$transactionDate';

    String wealthcaseSubscriptionFrequency = '';

    if (isWealthCaseProduct) {
      productType = 'Wealthcase';
      wealthcaseSubscriptionFrequency =
          this.txnAmtOrdProcDisplay?.row2?.text ?? '';
      if (wealthcaseSubscriptionFrequency.isNotNullOrEmpty) {
        transactionDetail += '\n$wealthcaseSubscriptionFrequency';
      }
      if (uniqueIdentifierMap.containsKey('Order id')) {
        orderId = uniqueIdentifierMap['Order id'] ?? 'N/A';
        uniqueIdentifierMap.remove('Order id');
      }
    }

    Map<String, String> data = {
      'Product Name': name.toTitleCase(),
      'Revenue Amount': this.revenueDisplay?.row1?.text ?? 'N/A',
      'Order ID': orderId,
      'Revenue Type': this.revenueTypeDisplay?.row1?.text ?? 'N/A',
      // show source in case of broker change
      if (source.isNotNullOrEmpty && source == 'B') 'Source': 'Broker Change',
      if (orderType.isNotNullOrEmpty) 'Order Type': orderType,
      if (productType.isNotNullOrEmpty) 'Product Type': productType,
      'Revenue Calculation': this.revenueCalculationDisplay?.row1?.text ?? '',
      'Revenue Date': this.revenueDateDisplay?.row1?.text ?? 'N/A',
      'Payout Date': payoutDateDisplay?.row1?.text ?? 'N/A',
      'Transaction Detail': transactionDetail,
      // Unique identifier eg folio number
      ...uniqueIdentifierMap
    };

    return data;
  }
}

class RowDataModel {
  DataModel? row1;
  DataModel? row2;
  DataModel? row3;

  RowDataModel.fromJson(Map<String, dynamic> json) {
    row1 = json['row1'] != null ? DataModel.fromJson(json['row1']) : null;
    row2 = json['row2'] != null ? DataModel.fromJson(json['row2']) : null;
    row3 = json['row3'] != null ? DataModel.fromJson(json['row3']) : null;
  }
}

class DataModel {
  String? text;
  String? html;
  String? info;
  Map? jsonData;

  DataModel({this.text, this.html, this.info});

  DataModel.fromJson(Map<String, dynamic> json) {
    text = WealthyCast.toStr(json['text']);
    html = WealthyCast.toStr(json['html']);
    info = WealthyCast.toStr(json['info']);
    try {
      jsonData = json['text'];
    } catch (e) {}
  }
}

class RevenueDates {
  DateTime? fromDate;
  DateTime? toDate;

  RevenueDates.fromJson(Map<String, dynamic> json) {
    fromDate = WealthyCast.toDate(json['from_date']);
    toDate = WealthyCast.toDate(json['to_date']);
  }
}
