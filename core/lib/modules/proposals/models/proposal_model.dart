import 'package:core/config/string_utils.dart';
import 'package:core/modules/clients/models/account_details_model.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';

class ProposalModel {
  ProposalModel({
    this.createdAt,
    this.updatedAt,
    this.externalId,
    this.status,
    this.customer,
    this.agent,
    this.statusStr,
    this.canBeMarkedFailure,
    this.canEdit,
    this.canTopup,
    this.productCategory,
    this.productType,
    this.productTypeVariant,
    this.revenuePlan,
    this.plannedRevenue,
    this.lumsumAmount,
    this.paymentInitiatedAt,
    this.paymentCompletedAt,
    this.paymentStatusStr,
    this.failureReason,
    this.productExtrasJson,
    this.createdBy,
    this.updatedBy,
    this.customerUrl,
    this.isOfflineOrderSynced,
    this.displayName,
    this.month,
    this.year,
    this.possibleFailureReasons,
    this.productInfo,
    this.ppStatusStr,
    this.switchPeriods,
    this.userProfileStatuses,
    this.userProductOrderId,
    this.appVersion,
    this.proposalName,
    this.proposalType,
    this.basketName,
  });

  DateTime? createdAt;
  DateTime? updatedAt;
  String? externalId;
  int? status;
  bool? canBeMarkedFailure;
  bool? canEdit;
  bool? canTopup;
  Client? customer;
  AgentProposalModel? agent;
  String? statusStr;
  String? ppStatusStr;
  String? productCategory;
  String? productType;
  String? productTypeVariant;
  int? revenuePlan;
  double? plannedRevenue;
  double? lumsumAmount;
  String? paymentStatusStr;
  String? paymentInitiatedAt;
  String? paymentCompletedAt;
  String? failureReason;
  Map<String, dynamic>? productExtrasJson;
  String? createdBy;
  String? updatedBy;
  String? customerUrl;
  bool? isOfflineOrderSynced;
  String? displayName;
  int? month;
  int? year;
  List<String>? possibleFailureReasons;
  MFProductModel? productInfo;
  List? switchPeriods;
  List<UserProfileStatusModel>? userProfileStatuses;
  String? appVersion;
  String? userProductOrderId;

  String? proposalType;
  String? proposalName;
  String? basketName;

  bool get isSwitchTrackerProposal => this.productTypeVariant == "switch";
  bool get isDematProposal => this.productTypeVariant == "demat";
  bool get isMandate =>
      this.productCategory == "Invest" && this.productTypeVariant == "mandate";
  bool get isSip => this.productTypeVariant == "sip";

  double? get amount => isMandate
      ? WealthyCast.toDouble(productExtrasJson?["amount"])
      : lumsumAmount;

  bool get isWealthcaseProposal {
    return proposalType.isNotNullOrEmpty &&
        proposalType?.toLowerCase() == 'wealthcase';
  }

  BankAccountModel? get bankModel {
    BankAccountModel? bankModel;
    if (isMandate == true) {
      try {
        Map<String, dynamic>? bankJson = productExtrasJson?['bank_account'];
        if (bankJson != null && bankJson.isNotEmpty)
          bankModel = BankAccountModel.fromJson(bankJson);
      } catch (e) {}
    }
    return bankModel;
  }

  bool get isFailed => ppStatusStr?.toLowerCase() == 'failed';
  bool get isCompleted => ppStatusStr?.toLowerCase() == 'completed';

  factory ProposalModel.fromJson(Map<String, dynamic> json) {
    String? customerUrl = WealthyCast.toStr(json['customer_url']);
    String? proposalName;

    if (customerUrl.isNullOrEmpty) {
      try {
        customerUrl =
            WealthyCast.toStr(json['product_extras_json']?['customer_url']);
        proposalName =
            WealthyCast.toStr(json['product_extras_json']?['proposal_name']);
      } catch (e) {}
    }

    return ProposalModel(
      createdAt: WealthyCast.toDate(json["created_at"]),
      updatedAt: WealthyCast.toDate(json["updated_at"]),
      externalId: WealthyCast.toStr(json["external_id"]),
      status: WealthyCast.toInt(json["status"]),
      basketName:
          WealthyCast.toStr(json['product_extras_json']?['basket_name']),
      customer:
          json["customer"] == null ? null : Client.fromJson(json["customer"]),
      agent: json["agent"] == null
          ? null
          : AgentProposalModel.fromJson(json["agent"]),
      statusStr: WealthyCast.toStr(json["status_str"]),
      paymentStatusStr: WealthyCast.toStr(json["payment_status_str"]) ?? "",
      ppStatusStr: WealthyCast.toStr(json["pp_status_str"]),
      productCategory: WealthyCast.toStr(json["product_category"]),
      productType: WealthyCast.toStr(json["product_type"])?.toLowerCase(),
      productTypeVariant: WealthyCast.toStr(json["product_type_variant"]),
      revenuePlan: WealthyCast.toInt(json["revenue_plan"]),
      plannedRevenue: WealthyCast.toDouble(json["planned_revenue"]) ?? 0,
      lumsumAmount: WealthyCast.toDouble(json["lumsum_amount"]),
      paymentInitiatedAt: WealthyCast.toStr(json["payment_initiated_at"]),
      paymentCompletedAt: WealthyCast.toStr(json["payment_completed_at"]),
      failureReason: WealthyCast.toStr(json["failure_reason"]),
      productExtrasJson: json["product_extras_json"],
      createdBy: WealthyCast.toStr(json["created_by"]),
      updatedBy: WealthyCast.toStr(json["updated_by"]),
      customerUrl: customerUrl,
      isOfflineOrderSynced: WealthyCast.toBool(json["is_offline_order_synced"]),
      displayName: WealthyCast.toStr(json["display_name"]),
      month: WealthyCast.toInt(json["month"]),
      year: WealthyCast.toInt(json["year"]),
      possibleFailureReasons:
          WealthyCast.toList<String>(json["possible_failure_reasons"]),
      productInfo: json["product_info"] == null
          ? null
          : MFProductModel.fromJson(json["product_info"]),
      userProfileStatuses: WealthyCast.toList(json["user_profile_statuses"])
          .map<UserProfileStatusModel>(
              (x) => UserProfileStatusModel.fromJson(x))
          .toList(),
      switchPeriods: WealthyCast.toList(json["switch_periods"]),
      canBeMarkedFailure: WealthyCast.toBool(json["can_be_marked_failure"]),
      canEdit: WealthyCast.toBool(json["can_edit"]),
      canTopup: WealthyCast.toBool(json["can_topup"]),
      appVersion: WealthyCast.toStr(json["app_version"]),
      userProductOrderId: WealthyCast.toStr(json["user_product_order_id"]),
      proposalType: WealthyCast.toStr(json["proposal_type"]),
      proposalName: proposalName,
    );
  }

  Map<String, dynamic> toJson() => {
        "created_at": createdAt == null ? null : createdAt!.toIso8601String(),
        "updated_at": updatedAt == null ? null : updatedAt!.toIso8601String(),
        "external_id": externalId,
        "status": status,
        "customer": customer,
        "agent": agent == null ? null : agent!.toJson(),
        "status_str": statusStr,
        "payment_status_str": paymentStatusStr ?? "",
        "pp_status_str": ppStatusStr,
        "product_category": productCategory,
        "product_type": productType,
        "product_type_variant": productTypeVariant,
        "revenue_plan": revenuePlan,
        "planned_revenue": plannedRevenue,
        "lumsum_amount": lumsumAmount,
        "payment_initiated_at": paymentInitiatedAt,
        "payment_completed_at": paymentCompletedAt,
        "failure_reason": failureReason,
        "product_extras_json": productExtrasJson,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "customer_url": customerUrl,
        "is_offline_order_synced": isOfflineOrderSynced,
        "display_name": displayName,
        "month": month,
        "year": year,
        "possible_failure_reasons": possibleFailureReasons ?? [],
        "product_info": productInfo,
        "switch_periods": switchPeriods ?? [],
        "user_profile_statuses": userProfileStatuses ?? [],
        "can_be_marked_failure": canBeMarkedFailure ?? false,
        "can_edit": canEdit ?? false,
        "can_topup": canTopup ?? false,
      };
}

class UserProfileStatusModel {
  UserProfileStatusModel({
    this.title,
    this.isComplete,
    this.displayText,
  });

  String? title;
  bool? isComplete;
  String? displayText;

  factory UserProfileStatusModel.fromJson(Map<String, dynamic> json) =>
      UserProfileStatusModel(
        title: WealthyCast.toStr(json["title"]) ?? "",
        isComplete: WealthyCast.toBool(json["is_complete"]),
        displayText: WealthyCast.toStr(json["display_text"]) ?? "",
      );
}

class AgentProposalModel {
  AgentProposalModel({
    this.id,
    this.name,
    this.email,
  });

  int? id;
  String? name;
  String? email;

  factory AgentProposalModel.fromJson(Map<String, dynamic> json) =>
      AgentProposalModel(
        id: WealthyCast.toInt(json["id"]),
        name: WealthyCast.toStr(json["name"]),
        email: WealthyCast.toStr(json["email"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
      };
}

class CustomerModel {
  CustomerModel({
    this.name,
    this.email,
    this.phoneNumber,
    this.taxyId,
  });

  String? name;
  String? email;
  String? phoneNumber;
  String? taxyId;
  String? taxyID;

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        name: WealthyCast.toStr(json["name"]),
        email: WealthyCast.toStr(json["email"]),
        phoneNumber: WealthyCast.toStr(json["phone_number"]),
        taxyId: WealthyCast.toStr(json["taxy_id"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "phone_number": phoneNumber,
        "taxy_id": taxyId,
      };
}

class ProductExtrasJsonModel {
  ProductExtrasJsonModel({
    this.status,
    this.orderType,
  });

  dynamic orderType;
  String? status;

  factory ProductExtrasJsonModel.fromJson(Map<String, dynamic> json) =>
      ProductExtrasJsonModel(
        status: WealthyCast.toStr(json["status"]),
        orderType: json["order_type"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "order_type": orderType,
      };
}

class RevenuePlanModel {
  RevenuePlanModel({
    this.productCode,
    this.productName,
    this.productType,
    this.vendor,
    this.manufacturer,
    this.advisorRevenueCode,
    this.variant,
    this.productDisplayName,
    this.variantDisplayName,
    this.isRevenueCustom,
  });

  String? productCode;
  String? productName;
  String? productType;
  String? vendor;
  String? manufacturer;
  String? advisorRevenueCode;
  String? variant;
  String? productDisplayName;
  String? variantDisplayName;
  bool? isRevenueCustom;

  factory RevenuePlanModel.fromJson(Map<String, dynamic> json) =>
      RevenuePlanModel(
        productCode: WealthyCast.toStr(json["product_code"]),
        productName: WealthyCast.toStr(json["product_name"]),
        productType: WealthyCast.toStr(json["product_type"]),
        vendor: WealthyCast.toStr(json["vendor"]),
        manufacturer: WealthyCast.toStr(json["manufacturer"]),
        advisorRevenueCode: WealthyCast.toStr(json["advisor_revenue_code"]),
        variant: WealthyCast.toStr(json["variant"]),
        productDisplayName: WealthyCast.toStr(json["product_display_name"]),
        variantDisplayName: WealthyCast.toStr(json["variant_display_name"]),
        isRevenueCustom: WealthyCast.toBool(json["is_revenue_custom"]),
      );

  Map<String, dynamic> toJson() => {
        "product_code": productCode,
        "product_name": productName,
        "product_type": productType,
        "vendor": vendor,
        "manufacturer": manufacturer,
        "advisor_revenue_code": advisorRevenueCode,
        "variant": variant,
        "product_display_name": productDisplayName,
        "variant_display_name": variantDisplayName,
        "is_revenue_custom": isRevenueCustom,
      };
}
