import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/resources/client_goal_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/goal_model.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/mutual_funds/models/user_goal_subtype_scheme_model.dart';
import 'package:core/modules/proposals/models/proposal_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StpController extends GetxController {
  // Params from Main Screen
  GoalModel goal;
  Client client;
  List<UserGoalSubtypeSchemeModel> goalSchemes = [];

  List<StpSchemeContext> stpBasket = [];
  StpSchemeContext? dropdownSelectedScheme;

  // For any fund portfolio
  List<SchemeMetaModel> anyFundSwitchOutSchemes = [];
  UserGoalSubtypeSchemeModel? anyFundGoalScheme;

  List<SchemeMetaModel> switchOutSchemes = [];
  ApiResponse stpOrderResponse = ApiResponse();

  // Form States
  GlobalKey<FormState> schemeFormKey = GlobalKey<FormState>();
  TextEditingController amountController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  List<int> selectedDays = [];

  ProposalModel? ticketResponse;

  bool get isAnyFundPortfolio =>
      goal.goalSubtype?.goalType == GoalType.ANY_FUNDS;

  StpController({
    required this.goalSchemes,
    required this.client,
    required this.goal,
    this.anyFundGoalScheme,
  }) {
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
                switchOutSchemes.add(schemeData);
              }
            });
          } else if ((goalScheme.folioOverview?.exists ?? false)) {
            SchemeMetaModel schemeData =
                SchemeMetaModel.clone(goalScheme.schemeData!);
            schemeData.folioOverview = goalScheme.folioOverview;
            switchOutSchemes.add(schemeData);
          }
        },
      );
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

    LogUtil.printLog(switchOutSchemes);
  }

  List<SchemeMetaModel> get switchInSchemes {
    SchemeMetaModel? switchOutFundSelected = dropdownSelectedScheme?.switchOut;

    List<SchemeMetaModel> switchInSchemesList = [];

    if (switchOutFundSelected != null) {
      switchOutSchemes.forEach(
        (scheme) {
          bool isAmcSame = switchOutFundSelected.amc == scheme.amc;
          bool isFundDifferent =
              switchOutFundSelected.wschemecode != scheme.wschemecode;
          bool isFolioSame = switchOutFundSelected.folioOverview?.folioNumber ==
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

  Future<void> createStpOrder() async {
    update([GetxId.sendTicket]);
    stpOrderResponse.state = NetworkState.loading;

    try {
      String apiKey = await getApiKey() ?? '';
      Map<String, dynamic> payload = getStpOrderPayload();
      final response = await ClientGoalRepository().createStp(
        apiKey,
        client.taxyID ?? '',
        payload,
      );

      final status = WealthyCast.toInt(response['status']);
      final isSuccess = status != null && (status ~/ 100) == 2;

      if (isSuccess) {
        ticketResponse = ProposalModel.fromJson(response['response']);
        stpOrderResponse.state = NetworkState.loaded;
      } else {
        stpOrderResponse.message =
            getErrorMessageFromResponse(response['response']);
        stpOrderResponse.state = NetworkState.error;
      }
    } catch (error) {
      stpOrderResponse.state = NetworkState.error;
      stpOrderResponse.message = "Something went wrong. Please try again";
    } finally {
      update([GetxId.sendTicket]);
    }
  }

  Map<String, dynamic> getStpOrderPayload() {
    List<Map<String, dynamic>> schemes = [];

    stpBasket.forEach((StpSchemeContext schemeContext) {
      Map<String, dynamic> schemeObject = {};
      try {
        schemeObject = {
          "goal": goal.id,
          "days": schemeContext.days?.join(","),
          "start_date":
              schemeContext.startDate!.toIso8601String().split('T')[0],
          "end_date": schemeContext.endDate!.toIso8601String().split('T')[0],
          "amount": schemeContext.amount?.toInt(),
          "switchin_wschemecode": schemeContext.switchIn?.wschemecode,
          "switchout_wschemecode": schemeContext.switchOut?.wschemecode,
          "folio_number": schemeContext.switchOut?.folioOverview?.folioNumber,
        };
      } catch (error) {
        LogUtil.printLog(error);
      }
      schemes.add(schemeObject);
    });

    bool isAnyFund = goal.goalSubtype?.goalType == GoalType.ANY_FUNDS;

    final title =
        "Create STP order for ${isAnyFund ? stpBasket.first.switchOut?.displayName : goal.displayName ?? 'Goal'}";

    return {
      'user_id': client.taxyID,
      // 'proposal_name': title,
      'switch_meta_list': schemes,
    };
  }

  void saveDropdownSelectedScheme({int? editIndex}) {
    dropdownSelectedScheme?.days = List<int>.from(selectedDays);
    dropdownSelectedScheme?.amount =
        double.tryParse(amountController.text.replaceAll(",", ""));

    if (editIndex != null) {
      stpBasket[editIndex] = dropdownSelectedScheme!;
    } else {
      stpBasket.add(dropdownSelectedScheme!);
    }

    clearInputStates();

    update();
  }

  void clearInputStates() {
    dropdownSelectedScheme = null;
    amountController.clear();
    startDateController.clear();
    endDateController.clear();
    selectedDays.clear();
  }

  void updateDropdownSelectedScheme(StpSchemeContext schemeContext,
      {bool isEdit = false}) {
    dropdownSelectedScheme = schemeContext;

    if (isEdit) {
      selectedDays = dropdownSelectedScheme?.days ?? [];
      startDateController.text =
          DateFormat('dd/MM/yyyy').format(dropdownSelectedScheme!.startDate!);
      endDateController.text =
          DateFormat('dd/MM/yyyy').format(dropdownSelectedScheme!.endDate!);
      amountController.text = (dropdownSelectedScheme?.amount ?? 0).toString();
    } else {
      if (dropdownSelectedScheme?.startDate == null) {
        startDateController.clear();
      }

      if (dropdownSelectedScheme?.endDate == null) {
        endDateController.clear();
      }

      if ((dropdownSelectedScheme?.days ?? []).isEmpty) {
        selectedDays.clear();
      }
    }

    update([GetxId.schemeForm]);
  }

  void updateStartDate(DateTime startDate) {
    dropdownSelectedScheme?.startDate = startDate;
    endDateController.clear();
    dropdownSelectedScheme?.endDate = null;
    update([GetxId.schemeForm]);
  }

  void updateEndDate(DateTime endDate) {
    dropdownSelectedScheme?.endDate = endDate;
    update([GetxId.schemeForm]);
  }

  void updateStpDays(List<int> days) {
    selectedDays = days;
    update([GetxId.schemeForm]);
  }
}

class StpSchemeContext {
  StpSchemeContext({
    this.switchIn,
    this.switchOut,
    this.amount = 0,
    this.startDate,
    this.endDate,
    this.days = const [],
  });

  SchemeMetaModel? switchIn;
  SchemeMetaModel? switchOut;
  double? amount;
  List<int>? days;
  DateTime? startDate;
  DateTime? endDate;
}
