import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/store/models/store_search_results_model.dart';
import 'package:core/modules/wealthcase/models/wealthcase_search_model.dart';

class UniversalSearchCategory {
  static const MF = "mf";
  static const MF_FUND = "mffunds";
  static const UNLISTED_STOCK = "unlistedstock";
  static const DEBENTURE = "mld";
  static const FIXED_DEPOSIT = "fd";
  static const PMS = "pms";
  static const INSURANCE = "insurance";
  static const CUSTOMERS = "customers";
  static const GO_TO_SCREEN = "go_to_screen";
  static const WEALTHCASE = "wealthcase";
}

class UniversalSearchResultModel {
  UniversalSearchDataModel? mfFunds;
  UniversalSearchDataModel? mf;
  UniversalSearchDataModel? unlistedstock;
  UniversalSearchDataModel? pms;
  UniversalSearchDataModel? mld;
  UniversalSearchDataModel? fd;
  UniversalSearchDataModel? insurance;
  UniversalSearchDataModel? customers;
  UniversalSearchDataModel? goToScreen;
  UniversalSearchDataModel? wealthcase;

  UniversalSearchResultModel({
    this.mfFunds,
    this.mf,
    this.unlistedstock,
    this.pms,
    this.mld,
    this.fd,
    this.insurance,
    this.goToScreen,
  });

  static UniversalSearchDataModel? initialiseSearchDataModel(
      String category, Map<String, dynamic> json) {
    switch (category) {
      case UniversalSearchCategory.MF_FUND:
        return deSerialiseUniversalData(
            json,
            (e) => StoreSearchResultModel.fromJson(e),
            UniversalSearchCategory.MF_FUND);
      case UniversalSearchCategory.MF:
        return deSerialiseUniversalData(
            json,
            (e) => StoreSearchResultModel.fromJson(e),
            UniversalSearchCategory.MF);
      case UniversalSearchCategory.UNLISTED_STOCK:
        return deSerialiseUniversalData(
            json,
            (e) => StoreSearchResultModel.fromJson(e),
            UniversalSearchCategory.UNLISTED_STOCK);
      case UniversalSearchCategory.FIXED_DEPOSIT:
        return deSerialiseUniversalData(
            json,
            (e) => StoreSearchResultModel.fromJson(e),
            UniversalSearchCategory.FIXED_DEPOSIT);
      case UniversalSearchCategory.DEBENTURE:
        return deSerialiseUniversalData(
            json,
            (e) => StoreSearchResultModel.fromJson(e),
            UniversalSearchCategory.DEBENTURE);
      case UniversalSearchCategory.PMS:
        return deSerialiseUniversalData(
            json,
            (e) => StoreSearchResultModel.fromJson(e),
            UniversalSearchCategory.PMS);
      case UniversalSearchCategory.INSURANCE:
        return deSerialiseUniversalData(
            json,
            (e) => StoreSearchResultModel.fromJson(e),
            UniversalSearchCategory.INSURANCE);
      case UniversalSearchCategory.CUSTOMERS:
        return deSerialiseUniversalData(
            json, (e) => Client.fromJson(e), UniversalSearchCategory.CUSTOMERS);
      case UniversalSearchCategory.GO_TO_SCREEN:
        return deSerialiseUniversalData(
            json,
            (e) => GoToScreenDataModel.fromJson(e),
            UniversalSearchCategory.GO_TO_SCREEN);
      case UniversalSearchCategory.WEALTHCASE:
        return deSerialiseUniversalData(
            json,
            (e) => WealthcaseSearchResultModel.fromJson(e),
            UniversalSearchCategory.WEALTHCASE);
      default:
        return null;
    }
  }

  // UniversalSearchResultModel.fromJson(Map<String, dynamic> json) {
  //   mfFunds = deSerialiseUniversalData(
  //       json['mffunds'], (e) => StoreSearchResultModel.fromJson(e));
  //   mf = deSerialiseUniversalData(
  //       json['mf'], (e) => StoreSearchResultModel.fromJson(e));
  //   unlistedstock = deSerialiseUniversalData(
  //       json['unlistedstock'], (e) => StoreSearchResultModel.fromJson(e));
  //   pms = deSerialiseUniversalData(
  //       json['pms'], (e) => StoreSearchResultModel.fromJson(e));
  //   mld = deSerialiseUniversalData(
  //       json['mld'], (e) => StoreSearchResultModel.fromJson(e));
  //   fd = deSerialiseUniversalData(
  //       json['fd'], (e) => StoreSearchResultModel.fromJson(e));
  //   customers =
  //       deSerialiseUniversalData(json['customers'], (e) => Client.fromJson(e));
  //   insurance = deSerialiseUniversalData(
  //       json['insurance'], (e) => StoreSearchResultModel.fromJson(e));
  //   goToScreen = deSerialiseUniversalData(
  //       json['go_to_screen'], (e) => GoToScreenDataModel.fromJson(e));
  // }
}

UniversalSearchDataModel? deSerialiseUniversalData(
    Map<String, dynamic>? json, Function(dynamic e) cb, String? category) {
  if (json == null) return null;

  try {
    return UniversalSearchDataModel(
        meta: json['meta'] != null
            ? UniversalSearchMetaModel.fromJson(json['meta'])
            : null,
        data: WealthyCast.toList(json['data']).map(cb).toList(),
        category: WealthyCast.toStr(category));
  } catch (error) {
    return null;
  }
}

class UniversalSearchDataModel {
  UniversalSearchMetaModel? meta;
  List? data;
  String? category;

  UniversalSearchDataModel({this.meta, this.data, this.category});
}

class UniversalSearchMetaModel {
  int? limit;
  int? offset;
  int? totalCount;
  int? count;
  String? displayName;
  int? order;

  UniversalSearchMetaModel({
    this.limit,
    this.offset,
    this.totalCount,
    this.count,
    this.displayName,
    this.order,
  });

  UniversalSearchMetaModel.fromJson(Map<String, dynamic> json) {
    limit = WealthyCast.toInt(json['limit']);
    offset = WealthyCast.toInt(json['offset']);
    totalCount = WealthyCast.toInt(json['total_count']);
    count = WealthyCast.toInt(json['count']);
    displayName = WealthyCast.toStr(json['display_name']);
    order = WealthyCast.toInt(json['order']);
  }
}

class GoToScreenDataModel {
  String? screenName;
  String? displayName;
  ContextModel? context;

  GoToScreenDataModel({this.screenName, this.displayName, this.context});

  GoToScreenDataModel.fromJson(Map<String, dynamic> json) {
    screenName = WealthyCast.toStr(json['screen_name']);
    displayName = WealthyCast.toStr(json['display_name']);
    context =
        json["context"] != null ? ContextModel.fromJson(json["context"]) : null;
  }
}

class ContextModel {
  String? category;
  String? amc;
  String? productType;

  ContextModel({
    this.category,
    this.amc,
    this.productType,
  });

  ContextModel.fromJson(Map<String, dynamic> json) {
    category = WealthyCast.toStr(json['category']);
    amc = WealthyCast.toStr(json['amc']);
    productType = WealthyCast.toStr(json['product_type']);
  }
}
