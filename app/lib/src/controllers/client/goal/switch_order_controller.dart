import 'dart:async';

import 'package:app/src/config/api_response.dart';
// import 'package:app/src/config/constants/scheme_constants.dart';
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
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SwitchOrderController extends GetxController {
  Client client;
  GoalModel goal;

  GlobalKey<FormState> schemeFormKey = GlobalKey<FormState>();

  ApiResponse switchOrderResponse = ApiResponse();

  List<UserGoalSubtypeSchemeModel> goalSchemes = [];
  List<SchemeMetaModel> switchOutSchemes = [];
  List<SchemeMetaModel> anyFundSwitchOutSchemes = [];
  UserGoalSubtypeSchemeModel? anyFundGoalScheme;
  // List<UserGoalSubtypeSchemeModel> goalSchemesWithFolios = [];

  List<SwitchOrderSchemeContext> switchOrderSchemes = [];
  SwitchOrderSchemeContext? dropdownSelectedScheme;

  List<SchemeMetaModel> fundsResult = [];
  NetworkState fundsState = NetworkState.cancel;

  String searchText = '';
  TextEditingController searchFundController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  OrderValueType valueTypeSelected = OrderValueType.Amount;

  Timer? _debounce;
  FocusNode searchBarFocusNode = FocusNode();
  FocusNode amountInputFocusNode = FocusNode();

  bool get isAnyFundPortfolio =>
      goal.goalSubtype?.goalType == GoalType.ANY_FUNDS;

  ProposalModel? ticketResponse;

  bool get isFormValid {
    return dropdownSelectedScheme?.switchIn != null &&
        validator(amountController.text).isNullOrEmpty;
  }

  String? validator(String? value) {
    double valueEntered = WealthyCast.toDouble(value) ?? 0;

    if (valueEntered <= 0) {
      return 'This field cannot be zero';
    }

    double? maxAmount = dropdownSelectedScheme?.switchOut.currentValue;
    double minAmount = dropdownSelectedScheme?.switchIn?.minAmount ?? 0;
    double? maxUnits = dropdownSelectedScheme?.switchOut.units;

    bool isValueTypeUnits = valueTypeSelected != OrderValueType.Amount;

    if (isValueTypeUnits && (valueEntered > (maxUnits ?? 0))) {
      return 'Max Limit Exceeded';
    }

    if (valueTypeSelected == OrderValueType.Amount &&
        valueEntered > (maxAmount ?? 0)) {
      return 'Max Limit Exceeded';
    }

    if (valueTypeSelected == OrderValueType.Amount &&
        valueEntered < minAmount) {
      return 'Min Amount is ${WealthyAmount.currencyFormat(minAmount, 0)}';
    }

    return null;
  }

  SwitchOrderController({
    required this.goalSchemes,
    required this.client,
    required this.goal,
    this.anyFundGoalScheme,
  }) {
    if (goalSchemes.isNotNullOrEmpty) {
      goalSchemes.forEach((goalScheme) {
        if (goalScheme.folioOverviews.isNotNullOrEmpty &&
            goalScheme.folioOverviews!.length > 1) {
          goalScheme.folioOverviews!.forEach((FolioModel folio) {
            SchemeMetaModel schemeData =
                SchemeMetaModel.clone(goalScheme.schemeData!);
            schemeData.folioOverview = folio;
            switchOutSchemes.add(schemeData);
          });
        } else {
          SchemeMetaModel schemeData =
              SchemeMetaModel.clone(goalScheme.schemeData!);
          schemeData.folioOverview = goalScheme.folioOverview;
          switchOutSchemes.add(schemeData);
        }
      });
    }

    if (isAnyFundPortfolio && anyFundGoalScheme?.folioOverviews != null) {
      anyFundGoalScheme?.folioOverviews!.forEach(
        (FolioModel folio) {
          SchemeMetaModel schemeData =
              SchemeMetaModel.clone(anyFundGoalScheme!.schemeData!);
          schemeData.folioOverview = folio;
          anyFundSwitchOutSchemes.add(schemeData);
        },
      );
    }
  }

  List<SchemeMetaModel> get switchInSchemes {
    SwitchOrderSchemeModel? switchOutFundSelected =
        dropdownSelectedScheme?.switchOut;

    List<SchemeMetaModel> switchInSchemesList = [];

    if (switchOutFundSelected != null) {
      switchOutSchemes.forEach(
        (scheme) {
          bool isAmcSame = switchOutFundSelected.amc == scheme.amc;
          bool isFundDifferent =
              switchOutFundSelected.wschemecode != scheme.wschemecode;
          bool isFolioSame = switchOutFundSelected.folioNumber ==
              scheme.folioOverview?.folioNumber;

          // bool isNewFund =
          //     isAmcSame && scheme.folioOverview?.folioNumber == null;
          bool isFundFromSameFolio =
              isAmcSame && isFundDifferent && isFolioSame;

          if (isFundFromSameFolio) {
            switchInSchemesList.add(scheme);
          }
        },
      );
    }
    return switchInSchemesList;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchFundController.dispose();
    searchBarFocusNode.dispose();
    amountInputFocusNode.dispose();
    super.dispose();
  }

  Future<void> createSwitchOrder() async {
    update([GetxId.sendTicket]);
    switchOrderResponse.state = NetworkState.loading;

    try {
      String apiKey = await getApiKey() ?? '';
      Map<String, dynamic> payload = getSwitchOrderPayload();
      final response = await ClientGoalRepository().createSwitchOrder(
        apiKey,
        client.taxyID ?? '',
        payload,
      );

      final status = WealthyCast.toInt(response['status']);
      final isSuccess = status != null && (status ~/ 100) == 2;

      if (isSuccess) {
        ticketResponse = ProposalModel.fromJson(response['response']);
        switchOrderResponse.state = NetworkState.loaded;
      } else {
        switchOrderResponse.message =
            getErrorMessageFromResponse(response['response']);
        switchOrderResponse.state = NetworkState.error;
      }
    } catch (error) {
      switchOrderResponse.state = NetworkState.error;
      switchOrderResponse.message = "Something went wrong. Please try again";
    } finally {
      update([GetxId.sendTicket]);
    }
  }

  Map<String, dynamic> getSwitchOrderPayload() {
    bool isAnyFund = goal.goalSubtype?.goalType == GoalType.ANY_FUNDS;

    String title =
        "Switch order for ${isAnyFund ? switchOrderSchemes.first.switchOut.displayName : goal.displayName ?? 'Goal'}";

    Map<String, dynamic> payload = {
      'proposal_name': title,
      'user_id': client.taxyID,
      'goal_id': goal.id,
    };

    List<Map<String, dynamic>> schemes = [];

    switchOrderSchemes.forEach((SwitchOrderSchemeContext schemeContext) {
      final isValueTypeUnits = schemeContext.valueType != OrderValueType.Amount;

      Map<String, dynamic> schemeObject = {
        "switchin": {"wschemecode": schemeContext.switchIn?.wschemecode},
        "switchout": {
          "wschemecode": schemeContext.switchOut.wschemecode,
          "folio_number": schemeContext.switchOut.folioNumber,
          if (isValueTypeUnits)
            "units": WealthyCast.toDouble(schemeContext.units)
          else
            "amount": WealthyCast.toDouble(schemeContext.amount),
          if (schemeContext.valueType == OrderValueType.Full) 'is_full': true,
        }
      };
      schemes.add(schemeObject);
    });

    payload["schemes"] = schemes;

    return payload;
  }

  void updateValueTypeSelected(OrderValueType value) {
    valueTypeSelected = value;
    if (valueTypeSelected == OrderValueType.Full) {
      amountController.text =
          (dropdownSelectedScheme!.switchOut.units ?? 0).toString();
    } else {
      amountController.clear();
    }

    schemeFormKey.currentState!.validate();

    update([GetxId.schemeForm]);
  }

  void updateDropdownSelectedScheme(
      SwitchOrderSchemeContext switchOrderSchemeContext,
      {bool isEdit = false}) {
    if (dropdownSelectedScheme != null || isEdit) {
      valueTypeSelected = switchOrderSchemeContext.valueType;
      bool isValueTypeUnits =
          switchOrderSchemeContext.valueType != OrderValueType.Amount;

      amountController.text = isValueTypeUnits
          ? switchOrderSchemeContext.units
          : switchOrderSchemeContext.amount;
    }

    dropdownSelectedScheme =
        SwitchOrderSchemeContext.clone(switchOrderSchemeContext);

    update([GetxId.schemeForm]);
  }

  // Delete Scheme from Switch Order list
  void removeSwitchOrderScheme(int index) {
    switchOrderSchemes.removeAt(index);
    update();
  }

  void moveToSwitchOrderSchemes({int? editIndex}) {
    if (dropdownSelectedScheme != null) {
      // check for full order
      if (valueTypeSelected != OrderValueType.Full) {
        final valueEntered = WealthyCast.toDouble(amountController.text) ?? 0;
        final maxAmount = dropdownSelectedScheme?.switchOut.currentValue ?? 0;
        final maxUnits = dropdownSelectedScheme?.switchOut.units ?? 0;
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

      bool isValueTypeUnits = valueTypeSelected != OrderValueType.Amount;
      if (isValueTypeUnits) {
        dropdownSelectedScheme!.units = amountController.text;
      } else {
        dropdownSelectedScheme!.amount = amountController.text;
      }

      dropdownSelectedScheme!.valueType = valueTypeSelected;

      if (editIndex != null) {
        switchOrderSchemes.removeAt(editIndex);
        switchOrderSchemes.insert(editIndex, dropdownSelectedScheme!);
      } else {
        switchOrderSchemes.add(dropdownSelectedScheme!);
      }

      // Reset states relatd to add fund
      dropdownSelectedScheme = null;
      valueTypeSelected = OrderValueType.Amount;
      amountController.clear();
    }

    update();
  }

  onFundSearch(String query) {
    if (query.isEmpty) {
      searchText = query;
      getFunds();

      // update(['search', 'funds']);
      _debounce!.cancel();
    } else {
      if (_debounce?.isActive ?? false) {
        _debounce!.cancel();
      }

      _debounce = Timer(
        const Duration(milliseconds: 500),
        () {
          searchText = query;

          getFunds();

          // update(['search']);
        },
      );
    }
  }

  Future<void> getFunds() async {
    fundsResult = [];
    fundsState = NetworkState.loading;
    update(['search']);

    try {
      String? apiKey = await getApiKey();

      Map filters = {};

      String? amcCode = dropdownSelectedScheme?.switchOut.amc;
      if (amcCode.isNotNullOrEmpty) {
        filters["amc"] = amcCode;
      }

      final response = await StoreRepository().searchMutualFunds(
        apiKey: apiKey,
        query: searchText,
        filters: filters,
        limit: 10,
        offset: 0,
      );

      if (response['status'] == "200") {
        List result = response['response']['data'];

        result.forEach((e) {
          SchemeMetaModel schemeModel = SchemeMetaModel.fromJson(e);
          if (schemeModel.isSwitchInAllowed) {
            fundsResult.add(schemeModel);
          }
        });

        fundsState = NetworkState.loaded;
      } else {
        fundsState = NetworkState.error;
      }
    } catch (error) {
      fundsState = NetworkState.error;
    } finally {
      update(['search']);
    }
  }

  void clearSearchBar() {
    searchFundController.clear();
    searchText = '';
    fundsResult = [];
  }
}

class SwitchOrderSchemeContext {
  SwitchOrderSchemeContext({
    this.switchIn,
    required this.switchOut,
    this.amount = "",
    this.units = "",
    this.valueType = OrderValueType.Amount,
  });

  SwitchOrderSchemeContext.clone(SwitchOrderSchemeContext x)
      : this(
          switchIn: x.switchIn,
          switchOut: x.switchOut,
          amount: x.amount,
          units: x.units,
          valueType: x.valueType,
        );

  SwitchOrderSchemeModel? switchIn;
  SwitchOrderSchemeModel switchOut;
  String amount;
  String units;
  OrderValueType valueType;
}

class SwitchOrderSchemeModel {
  SwitchOrderSchemeModel({
    required this.displayName,
    required this.amc,
    required this.wschemecode,
    required this.folioNumber,
    this.units,
    this.currentValue,
    this.minAmount,
  });

  String? amc;
  String? displayName;
  String? wschemecode;
  String? folioNumber;
  double? units;
  double? currentValue;
  double? minAmount;
}
