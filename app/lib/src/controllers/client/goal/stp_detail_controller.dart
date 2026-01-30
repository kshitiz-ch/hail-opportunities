import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/modules/clients/models/base_switch_model.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/resources/client_goal_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/goal_model.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/mutual_funds/models/store_fund_allocation.dart';
import 'package:core/modules/proposals/models/proposal_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';
import 'package:intl/intl.dart';

class StpDetailController extends GetxController {
  ApiResponse stpOrdersResponse = ApiResponse();

  final GoalModel goal;
  final BaseSwitch stp;
  final Client client;

  List<StpOrderModel> stpOrders = [];

  bool isPaginating = false;

  // Form States
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController amountController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  DateTime? startDate;

  TextEditingController endDateController = TextEditingController();
  DateTime? endDate;

  List<int> selectedDays = [];
  bool isActive = false;

  ApiResponse updateStpOrderResponse = ApiResponse();
  ProposalModel? ticketResponse;

  // Scheme Data States
  NetworkState switchInSchemeDataState = NetworkState.loading;
  SchemeMetaModel? switchInSchemeData;

  StpDetailController({
    required this.goal,
    required this.stp,
    required this.client,
  });

  void onInit() {
    getSchemeData();
    getStpOrders();

    super.onInit();
  }

  Future<void> updateStpOrder({bool delete = false}) async {
    updateStpOrderResponse.state = NetworkState.loading;
    update([GetxId.sendTicket]);

    try {
      Map<String, dynamic> payload = getUpdateStpOrderPayload(delete: delete);
      final apiKey = await getApiKey();
      final response = await ClientGoalRepository().editStp(
        apiKey!,
        client.taxyID!,
        payload,
      );

      final status = WealthyCast.toInt(response['status']);
      final isSuccess = status != null && (status ~/ 100) == 2;

      if (isSuccess) {
        ticketResponse = ProposalModel.fromJson(response['response']);
        updateStpOrderResponse.state = NetworkState.loaded;
      } else {
        updateStpOrderResponse.message =
            getErrorMessageFromResponse(response['response']);
        updateStpOrderResponse.state = NetworkState.error;
      }
    } catch (error) {
      updateStpOrderResponse.state = NetworkState.error;
      updateStpOrderResponse.message = genericErrorMessage;
    } finally {
      update([GetxId.sendTicket]);
    }
  }

  Map<String, dynamic> getUpdateStpOrderPayload({bool delete = false}) {
    bool isAnyFund = goal.goalSubtype?.goalType == GoalType.ANY_FUNDS;
    final stpFund = stp.switchFunds!.first;

    String title =
        "${delete ? 'Delete' : 'Edit'} STP order for ${isAnyFund ? stpFund.switchoutSchemeName : goal.displayName ?? 'Goal'}";

    if (delete) {
      return {
        'external_id': stp.externalId,
        // 'proposal_name': title,
        'switchin_wschemecode': stpFund.switchinWschemecode,
        'switchout_wschemecode': stpFund.switchoutWschemecode,
        'delete': true
      };
    }

    Map<String, dynamic> schemeObject = {};
    final today =
        DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now().toUtc());
    final hasStatusChanged = !isActive != stp.isPaused;

    try {
      schemeObject = {
        "switch_amount":
            int.tryParse(amountController.text.replaceAll(",", "")),
        "switch_days": selectedDays.join(","),
        "switchin_wschemecode": stpFund.switchinWschemecode,
        "switchout_wschemecode": stpFund.switchoutWschemecode,
        if (stp.startDate != null)
          "start_date": startDate!.toIso8601String().split('T')[0],
        if (stp.endDate != null)
          "end_date": endDate!.toIso8601String().split('T')[0],
        if (hasStatusChanged)
          if (isActive) "resumed_at": today else "paused_at": today
      };
    } catch (error) {
      LogUtil.printLog(error);
    }

    return {
      // 'proposal_name': title,
      'external_id': stp.externalId,
      ...schemeObject,
    };
  }

  String getStpStatus() {
    bool isInactive = stp.endDate?.isBefore(DateTime.now()) ?? false;
    bool isPaused = stp.isPaused == true;

    if (isInactive) {
      return 'Inactive';
    }

    if (isPaused) {
      return 'Paused';
    }

    return 'Active';
  }

  Future<void> getStpOrders() async {
    update([GetxId.stpOrders]);

    stpOrdersResponse.state = NetworkState.loading;

    try {
      String apiKey = await getApiKey() ?? '';

      DateTime today = DateTime.now();
      DateTime filterDate = DateTime(today.year - 1, today.month, today.day);

      Map<String, dynamic> payload = {
        "filterDate": filterDate.toIso8601String(),
        "limit": 20,
        "offset": 0,
        "switchMetaId": stp.externalId,
        "toDate": today.toIso8601String(),
        "userId": client.taxyID
      };

      QueryResult response = await ClientGoalRepository().getStpOrders(
        apiKey,
        client.taxyID ?? '',
        payload,
      );

      if (response.hasException) {
        stpOrdersResponse.message =
            response.exception!.graphqlErrors[0].message;
        stpOrdersResponse.state = NetworkState.error;
      } else {
        List ordersListJson = response.data?['taxy']?['switchesV2'] as List;
        ordersListJson.forEach((x) {
          stpOrders.add(StpOrderModel.fromJson(x));
        });
        stpOrdersResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      stpOrdersResponse.state = NetworkState.error;
      stpOrdersResponse.message = 'Something went wrong. Please try again';
    } finally {
      update([GetxId.stpOrders]);
    }
  }

  Future<void> getSchemeData() async {
    switchInSchemeDataState = NetworkState.loading;
    update([GetxId.schemeData]);

    try {
      String apiKey = await getApiKey() ?? '';
      final QueryResult response = await StoreRepository().getSchemeData(
          apiKey, null, stp.switchFunds!.first.switchinWschemecode!);

      if (response.hasException) {
        response.exception!.graphqlErrors.forEach((graphqlError) {
          LogUtil.printLog(graphqlError.message);
        });
        switchInSchemeDataState = NetworkState.error;
      } else {
        StoreFundAllocation fundsResult =
            StoreFundAllocation.fromJson(response.data!['metahouse']);
        switchInSchemeData = fundsResult.schemeMetas?.first;

        switchInSchemeDataState = NetworkState.loaded;
      }
    } catch (e) {
      LogUtil.printLog(e.toString());
      switchInSchemeDataState = NetworkState.error;
    } finally {
      update([GetxId.schemeData]);
    }
  }

  void updateStpDays(List<int> days) {
    selectedDays = days;
    update([GetxId.form]);
  }

  void initialiseFormStates() {
    if (stp.days.isNotNullOrEmpty) {
      selectedDays =
          List<int>.from(stp.days!.split(",").map((x) => int.tryParse(x)));
    }

    amountController.text = (stp.amount ?? 0).toString();

    isActive = !(stp.isPaused == true);

    if (stp.startDate != null) {
      startDateController.text =
          DateFormat('dd/MM/yyyy').format(stp.startDate!);
      startDate = stp.startDate;
    }
    if (stp.endDate != null) {
      endDateController.text = DateFormat('dd/MM/yyyy').format(stp.endDate!);
      endDate = stp.endDate;
    }

    update([GetxId.form]);
  }

  void updateStartDate(DateTime date) {
    startDate = date;
    endDateController.clear();
    endDate = null;
    update([GetxId.schemeForm]);
  }

  void updateEndDate(DateTime date) {
    endDate = date;
    update([GetxId.schemeForm]);
  }

  void toggleIsActive(bool value) {
    isActive = value;
    update([GetxId.form]);
  }
}
