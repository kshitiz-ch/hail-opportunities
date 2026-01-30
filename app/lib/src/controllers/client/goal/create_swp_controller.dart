import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/utils/swp_scheme_context.dart';
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

class CreateSwpController extends GetxController {
  GlobalKey<FormState> schemeFormKey = GlobalKey<FormState>();

  late String goalId;
  late GoalModel goal;
  late Client client;
  late List<UserGoalSubtypeSchemeModel> goalSchemes;

  Map<String, SwpSchemeContext> selectedSwpSchemes = {};
  List<SchemeMetaModel> schemeWithFolios = [];
  SwpSchemeContext? dropdownSelectedScheme;

  // For any fund portfolio
  List<SchemeMetaModel> anyFundSwitchOutSchemes = [];
  UserGoalSubtypeSchemeModel? anyFundGoalScheme;

  TextEditingController amountController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();

  bool openAddFundBottomSheet = false;

  bool get isAnyFundPortfolio =>
      goal.goalSubtype?.goalType == GoalType.ANY_FUNDS;

  CreateSwpController({
    required this.goal,
    required this.client,
    required this.goalSchemes,
    required this.goalId,
  });

  bool get isAnyFund => goal.goalSubtype?.goalType == GoalType.ANY_FUNDS;

  ApiResponse createSwpResponse = ApiResponse();
  final clientGoalRepository = ClientGoalRepository();
  ProposalModel? ticketResponse;

  bool get isFundDisabledForSwp {
    final minWithdrawalAmt =
        dropdownSelectedScheme?.schemeData.minWithdrawalAmt ?? 0;
    final currentValue =
        (dropdownSelectedScheme?.schemeData.folioOverview?.currentValue ?? 0);

    return minWithdrawalAmt > currentValue;
  }

  void onInit() {
    filterOutGoalWithoutFolios();
    super.onInit();
  }

  void filterOutGoalWithoutFolios() {
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

    // If AnyFund or with Portfolios with one scheme
    // Open Add Fund Bottomsheet instantly
    if (schemeWithFolios.length == 1) {
      openAddFundBottomSheet = true;
      SchemeMetaModel scheme = schemeWithFolios.first;
      if (scheme.folioOverview?.exists ?? false) {
        final schemeContext = SwpSchemeContext(
          schemeData: scheme,
          goalId: goalId,
        );
        updateDropdownSelectedScheme(schemeContext);
      }
      update();
    }
  }

  // Return true if all the folios are selected for withdrawal
  bool get isAllFoliosSelected {
    return selectedSwpSchemes.entries.length == schemeWithFolios.length;
  }

  Future<dynamic> createSWP() async {
    createSwpResponse.state = NetworkState.loading;
    update([GetxId.sendTicket]);

    try {
      Map<String, dynamic> payload = getCreateSwpPayload();
      final apiKey = await getApiKey();
      final response = await clientGoalRepository.createSwp(
        apiKey!,
        client.taxyID!,
        payload,
      );

      final status = WealthyCast.toInt(response['status']);
      final isSuccess = status != null && (status ~/ 100) == 2;

      if (isSuccess) {
        ticketResponse = ProposalModel.fromJson(response['response']);
        createSwpResponse.state = NetworkState.loaded;
      } else {
        createSwpResponse.message =
            getErrorMessageFromResponse(response['response']);
        createSwpResponse.state = NetworkState.error;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      createSwpResponse.message = genericErrorMessage;
      createSwpResponse.state = NetworkState.error;
    } finally {
      update([GetxId.sendTicket]);
    }
  }

  Map<String, dynamic> getCreateSwpPayload() {
    String proposalName = "Create SWP proposal for ";
    if (selectedSwpSchemes.isNotEmpty && selectedSwpSchemes.length == 1) {
      proposalName +=
          (selectedSwpSchemes.entries.first.value.schemeData.displayName ?? '');
    } else {
      proposalName += (goal.displayName ?? '');
    }
    final Map<String, dynamic> payload = {
      // "proposal_name": proposalName,
      'user_id': client.taxyID,
      "swp_meta_list": selectedSwpSchemes.entries
          .map((swpFund) => swpFund.value.toJson())
          .toList()
    };
    return payload;
  }

  void updateDropdownSelectedScheme(SwpSchemeContext swpSchemeContext,
      {bool isEdit = false}) {
    if (dropdownSelectedScheme != null || isEdit) {
      if (swpSchemeContext.amount != null) {
        amountController.text = swpSchemeContext.amount.toString();
      }
      if (swpSchemeContext.startDate != null) {
        startDateController.text =
            DateFormat('dd/MM/yyyy').format(swpSchemeContext.startDate!);
      } else {
        startDateController.clear();
      }
      if (swpSchemeContext.endDate != null) {
        endDateController.text =
            DateFormat('dd/MM/yyyy').format(swpSchemeContext.endDate!);
      } else {
        endDateController.clear();
      }
    }
    dropdownSelectedScheme = swpSchemeContext;
    update([GetxId.schemeForm]);
  }

  void updatedSelectedWithdrawalScheme(String currentFundId) {
    if (selectedSwpSchemes.containsKey(currentFundId)) {
      selectedSwpSchemes.remove(currentFundId);
    }

    moveToWithdrawalSchemes();
  }

  void moveToWithdrawalSchemes() {
    if (dropdownSelectedScheme != null) {
      selectedSwpSchemes[dropdownSelectedScheme!.id] = dropdownSelectedScheme!;
    }

    update();
  }

  // Delete Scheme from Withdrawal list
  void removeWithdrawalScheme(String fundId) {
    selectedSwpSchemes.remove(fundId);
    update();
  }

  void resetForm() {
    dropdownSelectedScheme = null;
    amountController.clear();
    endDateController.clear();
    startDateController.clear();
    update([GetxId.schemeForm]);
  }

  void updateSelectedSchemeAmount(String amount) {
    dropdownSelectedScheme?.amount =
        WealthyCast.toDouble(amount.replaceAll(',', '').replaceAll(' ', ''));
    update([GetxId.schemeForm]);
  }

  void updateSelectedSchemeStartDate(DateTime startDate) {
    dropdownSelectedScheme?.startDate = startDate;
    endDateController.clear();
    dropdownSelectedScheme?.endDate = null;
    update([GetxId.schemeForm]);
  }

  void updateSelectedSchemeEndDate(DateTime endDate) {
    dropdownSelectedScheme?.endDate = endDate;
    update([GetxId.schemeForm]);
  }

  void updateSelectedSchemeDays(List<int> days) {
    dropdownSelectedScheme?.days = days;
    update([GetxId.schemeForm]);
  }
}
