import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/resources/client_goal_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/goal_model.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/mutual_funds/models/user_goal_subtype_scheme_model.dart';
import 'package:core/modules/proposals/models/proposal_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WithdrawalController extends GetxController {
  GlobalKey<FormState> schemeFormKey = GlobalKey<FormState>();
  ApiResponse withdrawalOrderResponse = ApiResponse();

  GoalModel goal;
  Client client;
  List<UserGoalSubtypeSchemeModel> goalSchemes = [];
  // List<UserGoalSubtypeSchemeModel> goalSchemesWithFolios = [];
  List<SchemeMetaModel> schemeWithFolios = [];

  Map<String, WithdrawalSchemeContext> withdrawalSchemesSelected = {};
  Map<String, WithdrawalSchemeContext>? dropdownSelectedScheme;

  TextEditingController amountController = TextEditingController();
  OrderValueType valueTypeSelected = OrderValueType.Amount;

  bool openAddFundBottomSheet = false;

  FocusNode amountInputFocusNode = FocusNode();

  ProposalModel? proposalResponse;

  WithdrawalController(
      {required this.goalSchemes, required this.client, required this.goal}) {
    // Filter out goals without folios
    if (goalSchemes.isNotNullOrEmpty) {
      goalSchemes.forEach(
        (goalScheme) {
          if (goalScheme.folioOverviews.isNotNullOrEmpty &&
              goalScheme.folioOverviews!.length > 1) {
            goalScheme.folioOverviews!.forEach((FolioModel folio) {
              if (folio.exists) {
                SchemeMetaModel schemeData =
                    SchemeMetaModel.clone(goalScheme.schemeData!);
                schemeData.folioOverview = folio;
                schemeWithFolios.add(schemeData);
              }
            });
          } else if ((goalScheme.folioOverview?.exists ?? false)) {
            SchemeMetaModel schemeData =
                SchemeMetaModel.clone(goalScheme.schemeData!);
            schemeData.folioOverview = goalScheme.folioOverview;
            schemeWithFolios.add(schemeData);
          }
        },
      );
    }

    // If AnyFund or with Portfolios with one scheme
    // Open Add Fund Bottomsheet instantly
    if (schemeWithFolios.length == 1) {
      openAddFundBottomSheet = true;
      SchemeMetaModel scheme = schemeWithFolios.first;
      if (scheme.folioOverview?.exists ?? false) {
        WithdrawalSchemeContext schemeContext = WithdrawalSchemeContext(
            schemeData: scheme,
            amount: (scheme.folioOverview?.withdrawalAmountAvailable ?? 0)
                .toString(),
            units: (scheme.folioOverview?.withdrawalUnitsAvailable ?? 0)
                .toString());
        updateDropdownSelectedScheme(schemeContext);
      }
      update();
    }
  }

  // Return true if all the folios are selected for withdrawal
  bool get isAllFoliosSelected {
    return withdrawalSchemesSelected.entries.length == schemeWithFolios.length;
  }

  double get minWithdrawalAmt {
    try {
      return dropdownSelectedScheme!.values.first.schemeData.minWithdrawalAmt ??
          0;
    } catch (error) {
      return 0;
    }
  }

  bool get partialWithdrawalDisabled {
    try {
      FolioModel folioOverview =
          dropdownSelectedScheme!.values.first.schemeData.folioOverview!;
      return minWithdrawalAmt > (folioOverview.withdrawalAmountAvailable ?? 0);
    } catch (error) {
      return false;
    }
  }

  bool get isFormValid {
    return dropdownSelectedScheme != null &&
        validator(amountController.text).isNullOrEmpty;
  }

  String? validator(String? value) {
    double valueEntered = WealthyCast.toDouble(value) ?? 0;
    bool isValueTypeUnits = valueTypeSelected != OrderValueType.Amount;

    if (valueEntered <= 0) {
      return 'This field cannot be zero';
    }

    FolioModel folioOverview =
        dropdownSelectedScheme!.values.first.schemeData.folioOverview!;

    if (isValueTypeUnits &&
        valueEntered > (folioOverview.withdrawalUnitsAvailable ?? 0)) {
      return 'Max Limit Exceeded';
    }

    if (valueTypeSelected == OrderValueType.Amount &&
        valueEntered > (folioOverview.withdrawalAmountAvailable ?? 0)) {
      return 'Max Limit Exceeded';
    }

    return null;
  }

  @override
  void dispose() {
    amountInputFocusNode.dispose();
    super.dispose();
  }

  Future<void> createWithdrawalOrder() async {
    withdrawalOrderResponse.state = NetworkState.loading;
    update([GetxId.sendTicket]);

    try {
      String apiKey = await getApiKey() ?? '';

      Map<String, dynamic> payload = getWithdrawalOrderPayload();

      final response = await ClientGoalRepository().createWithdrawalOrder(
        apiKey,
        client.taxyID ?? '',
        payload,
      );

      final status = WealthyCast.toInt(response['status']);
      final isSuccess = status != null && (status ~/ 100) == 2;

      if (isSuccess) {
        proposalResponse = ProposalModel.fromJson(response['response']);
        withdrawalOrderResponse.state = NetworkState.loaded;
      } else {
        withdrawalOrderResponse.message =
            getErrorMessageFromResponse(response['response']);
        withdrawalOrderResponse.state = NetworkState.error;
      }
    } catch (error) {
      withdrawalOrderResponse.state = NetworkState.error;
      withdrawalOrderResponse.message =
          "Something went wrong. Please try again";
    } finally {
      update([GetxId.sendTicket]);
    }
  }

  // Future<void> createWithdrawalOrder() async {
  //   update([GetxId.sendTicket]);
  //   withdrawalOrderResponse.state = NetworkState.loading;

  //   try {
  //     String apiKey = await getApiKey() ?? '';

  //     Map<String, dynamic> payload = getWithdrawalOrderPayload();

  //     QueryResult response = await ClientGoalRepository().createGoalOrder(
  //       apiKey,
  //       client.taxyID ?? '',
  //       payload,
  //     );

  //     if (response.hasException) {
  //       withdrawalOrderResponse.state = NetworkState.error;
  //       withdrawalOrderResponse.message =
  //           response.exception!.graphqlErrors[0].message;
  //     } else {
  //       withdrawalOrderResponse.state = NetworkState.loaded;
  //     }
  //   } catch (error) {
  //     withdrawalOrderResponse.state = NetworkState.error;
  //     withdrawalOrderResponse.message =
  //         "Something went wrong. Please try again";
  //   } finally {
  //     update([GetxId.sendTicket]);
  //   }
  // }

  Map<String, dynamic> getWithdrawalOrderPayload() {
    // double totalUnits = 0;
    // double totalAmount = 0;

    // Map<String, dynamic> context = {"goal_id": goal.id};

    // List<Map<String, dynamic>> schemes = [];

    // withdrawalSchemesSelected.entries
    //     .toList()
    //     .forEach((MapEntry<String, WithdrawalSchemeContext> element) {
    //   double units = WealthyCast.toDouble(element.value.units) ?? 0;
    //   double amount = WealthyCast.toDouble(element.value.amount) ?? 0;

    //   if (element.value.valueType == OrderValueType.Units) {
    //     totalUnits += units;
    //   } else {
    //     totalAmount += amount;
    //     ;
    //   }

    //   schemes.add({
    //     if (element.value.valueType == OrderValueType.Units)
    //       "units": units
    //     else
    //       "amount": amount,
    //     "wschemecode": element.value.schemeData.wschemecode,
    //     "folio_number": element.value.schemeData.folioOverview!.folioNumber
    //   });
    // });

    // context["schemes"] = schemes;

    // Map<String, dynamic> payload = {
    //   "context": json.encode(context),
    //   "title": getOrderTitle(totalUnits, totalAmount),
    //   "sendToCustomer": true,
    //   "groupId": 3,
    // };

    List<Map<String, dynamic>> schemes = [];

    withdrawalSchemesSelected.entries
        .toList()
        .forEach((MapEntry<String, WithdrawalSchemeContext> element) {
      double units = WealthyCast.toDouble(element.value.units) ?? 0;
      double amount = WealthyCast.toDouble(element.value.amount) ?? 0;
      final isValueTypeUnits = element.value.valueType != OrderValueType.Amount;

      schemes.add({
        if (isValueTypeUnits) "units": units else "amount": amount,
        "wschemecode": element.value.schemeData.wschemecode,
        "folio_number": element.value.schemeData.folioOverview!.folioNumber,
        if (element.value.valueType == OrderValueType.Full) 'is_full': true,
      });
    });

    Map<String, dynamic> payload = {
      "user_id": client.taxyID,
      "goal_id": goal.id,
      "schemes": schemes
    };

    return payload;
  }

  void updateDropdownSelectedScheme(WithdrawalSchemeContext schemeContext,
      {bool isEdit = false}) {
    if (dropdownSelectedScheme != null || isEdit) {
      valueTypeSelected = schemeContext.valueType;
      final isValueTypeUnits = valueTypeSelected != OrderValueType.Amount;

      amountController.text =
          isValueTypeUnits ? schemeContext.units : schemeContext.amount;
    }

    dropdownSelectedScheme = {schemeContext.id: schemeContext};

    if (partialWithdrawalDisabled) {
      valueTypeSelected = OrderValueType.Full;
      amountController.text = dropdownSelectedScheme!.values.first.units;
    }

    update([GetxId.schemeForm]);
  }

  void updatedSelectedWithdrawalScheme(String currentFundId) {
    if (withdrawalSchemesSelected.containsKey(currentFundId)) {
      withdrawalSchemesSelected.remove(currentFundId);
    }

    moveToWithdrawalSchemes();
  }

  void moveToWithdrawalSchemes() {
    if (dropdownSelectedScheme != null) {
      // check for full order
      if (valueTypeSelected != OrderValueType.Full) {
        final valueEntered = WealthyCast.toDouble(amountController.text) ?? 0;
        final folioOverview =
            dropdownSelectedScheme!.values.first.schemeData.folioOverview!;
        final maxAmount = folioOverview.withdrawalAmountAvailable ?? 0;
        final maxUnits = folioOverview.withdrawalUnitsAvailable ?? 0;
        final isPlaceFullOrder = canPlaceFullOrder(
          inputValue: valueEntered,
          maxAmount: maxAmount.toInt(),
          maxUnits: maxUnits,
          orderType: valueTypeSelected,
        );
        if (isPlaceFullOrder) {
          valueTypeSelected = OrderValueType.Full;
          amountController.text = maxUnits.toString();
        }
      }

      final isValueTypeUnits = valueTypeSelected != OrderValueType.Amount;

      if (isValueTypeUnits) {
        dropdownSelectedScheme!.values.first.units = amountController.text;
      } else {
        dropdownSelectedScheme!.values.first.amount = amountController.text;
      }

      dropdownSelectedScheme!.values.first.valueType = valueTypeSelected;

      withdrawalSchemesSelected.addAll({
        ...dropdownSelectedScheme!,
      });
    }

    update();
  }

  // Delete Scheme from Withdrawal list
  void removeWithdrawalScheme(String fundId) {
    withdrawalSchemesSelected.remove(fundId);
    update();
  }

  void resetForm() {
    dropdownSelectedScheme = null;
    valueTypeSelected = OrderValueType.Amount;
    amountController.clear();

    update([GetxId.schemeForm]);
  }

  void updateValueTypeSelected(OrderValueType value) {
    valueTypeSelected = value;
    if (valueTypeSelected == OrderValueType.Full) {
      amountController.text = (dropdownSelectedScheme!.values.first.schemeData
                  .folioOverview?.withdrawalUnitsAvailable ??
              0)
          .toString();
    } else {
      amountController.clear();
    }

    schemeFormKey.currentState!.validate();

    update([GetxId.schemeForm]);
  }

  String getOrderTitle(double totalUnits, totalAmount) {
    bool isAnyFund = goal.goalSubtype?.goalType == GoalType.ANY_FUNDS;

    String goalName;
    if (isAnyFund) {
      goalName =
          withdrawalSchemesSelected.values.first.schemeData.displayName ??
              goal.displayName ??
              'Goal';
    } else {
      goalName = goal.displayName ?? 'Goal';
    }

    if (totalUnits <= 0) {
      return "Withdrawal order of ${WealthyAmount.currencyFormat(totalAmount, 0)} for ${goalName}";
    }

    if (totalAmount <= 0) {
      return "Withdrawal order of ${totalUnits} units for ${goalName}";
    }

    return "Withdrawal order of ${WealthyAmount.currencyFormat(totalAmount, 0)} and ${totalUnits} units for ${goalName}";
  }
}

class WithdrawalSchemeContext {
  WithdrawalSchemeContext({
    required this.schemeData,
    this.amount = "",
    this.units = "",
    this.valueType = OrderValueType.Amount,
  });

  String get id => getFundIdentifier(schemeData);

  SchemeMetaModel schemeData;
  String amount;
  String units;
  OrderValueType valueType;
}
