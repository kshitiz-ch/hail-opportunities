import 'package:api_sdk/api_collection/store_api.dart';
import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:core/modules/clients/models/base_swp_model.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/swp_order_model.dart';
import 'package:core/modules/clients/resources/client_goal_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/goal_model.dart';
import 'package:core/modules/mutual_funds/models/store_fund_allocation.dart';
import 'package:core/modules/proposals/models/proposal_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';
import 'package:intl/src/intl/date_format.dart';

class SwpDetailController extends GetxController {
  GlobalKey<FormState> schemeFormKey = GlobalKey<FormState>();

  final String goalId;
  final GoalModel goal;
  final Client client;

  late TextEditingController amountController;
  late TextEditingController startDateController;
  late TextEditingController endDateController;

  final BaseSwpModel selectedSwp;
  late BaseSwpModel updatedSwp;

  ApiResponse swpDetailResponse = ApiResponse();
  ApiResponse fundMinWithdrawalResponse = ApiResponse();

  List<SwpOrderModel> pastSwps = [];

  int pageNo = 0;
  int limit = 20;
  bool isPaginating = false;
  bool isPagesRemaining = true;

  ScrollController? scrollController;

  SwpDetailController({
    required this.selectedSwp,
    required this.goal,
    required this.client,
    required this.goalId,
  });

  ApiResponse editSwpResponse = ApiResponse();
  final clientGoalRepository = ClientGoalRepository();
  ProposalModel? ticketResponse;

  @override
  void onInit() {
    scrollController = ScrollController();
    getClientSWPDetails(selectedSwp.externalId!);
    scrollController?.addListener(() {
      handlePagination();
    });
    fetchFundMinWithdrawal();
    super.onInit();
  }

  Future<void> prefillSWPFormData() async {
    updatedSwp = selectedSwp.clone();

    amountController = TextEditingController(
      text: WealthyAmount.formatNumber(
        (updatedSwp.amount ?? 0).toString(),
      ),
    );

    startDateController = TextEditingController(
      text: getFormattedDate(updatedSwp.startDate),
    );
    endDateController = TextEditingController(
      text: getFormattedDate(updatedSwp.endDate),
    );
  }

  Future<void> fetchFundMinWithdrawal() async {
    try {
      // Note :-
      // Although swpFund is a list it will always have
      // single fund as swp order is created fund wise
      if (selectedSwp.swpFunds.isNullOrEmpty) {
        return;
      }
      fundMinWithdrawalResponse.state = NetworkState.loading;
      update();

      String apiKey = await getApiKey() ?? '';

      final QueryResult response = await StoreAPI.getSchemeData(
        apiKey,
        client.taxyID,
        selectedSwp.swpFunds!.first.wschemecode ?? '',
      );

      if (response.hasException) {
        response.exception!.graphqlErrors.forEach((graphqlError) {
          LogUtil.printLog(graphqlError.message);
        });
        fundMinWithdrawalResponse.message = "Something went wrong";
        fundMinWithdrawalResponse.state = NetworkState.error;
      } else {
        final fundsDetail =
            StoreFundAllocation.fromJson(response.data!['metahouse']);
        selectedSwp.swpFunds!.first.minWithdrawalAmt =
            fundsDetail.schemeMetas?.first.minWithdrawalAmt ?? 0;
        fundMinWithdrawalResponse.state = NetworkState.loaded;
      }
    } catch (e) {
      LogUtil.printLog(e.toString());
      fundMinWithdrawalResponse.message = "Something went wrong";
      fundMinWithdrawalResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<dynamic> getClientSWPDetails(String baseSwpId) async {
    swpDetailResponse.state = NetworkState.loading;
    if (!isPaginating) {
      pastSwps = [];
      pageNo = 0;
    }
    update([GetxId.goalSwpOrders]);

    try {
      String apiKey = await getApiKey() ?? '';

      int offset = ((pageNo + 1) * limit) - limit;
      Map<String, dynamic> payload = {
        'userId': client.taxyID!,
        'swpMetaId': baseSwpId,
        'filterDateForPast': DateTime.now()
            .subtract(Duration(days: 365 * 2 * (pageNo + 1)))
            .toIso8601String(),
        'toDate': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
        'limit': 20,
        'offset': offset,
      };
      QueryResult response = await ClientGoalRepository().getSWPDetails(
        apiKey,
        client.taxyID!,
        payload,
      );

      if (response.hasException) {
        swpDetailResponse.message =
            response.exception!.graphqlErrors[0].message;
        swpDetailResponse.state = NetworkState.error;
      } else {
        final responseData =
            WealthyCast.toList(response.data!['taxy']['swpsV2'])
                .map((swpJson) => SwpOrderModel.fromJson(swpJson))
                .toList();

        if (!isPaginating || pastSwps.isNullOrEmpty) {
          pastSwps = responseData;
        } else {
          // update past sips
          if (pastSwps.isNullOrEmpty) {
            pastSwps = responseData;
          } else {
            pastSwps.addAll(responseData);
          }
        }

        final isResponseNullOrEmpty = responseData.isNullOrEmpty;
        final isReponseSizeLessThanLimit = responseData.length < limit;
        // if the response has no data or has data less than limit it means no more data is present
        // so pagination not required
        isPagesRemaining =
            !(isResponseNullOrEmpty || isReponseSizeLessThanLimit);

        swpDetailResponse.state = NetworkState.loaded;
        LogUtil.printLog('past swp ==> ${responseData.length}');
        LogUtil.printLog('isPagesRemaining ==> ${isPagesRemaining}');
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      swpDetailResponse.message = genericErrorMessage;
      swpDetailResponse.state = NetworkState.error;
    } finally {
      update([GetxId.goalSwpOrders]);
    }
  }

  Future<dynamic> editSWP({bool delete = false}) async {
    editSwpResponse.state = NetworkState.loading;
    update();

    try {
      Map<String, dynamic> payload = getUpdateSwpPayload(delete: delete);
      final apiKey = await getApiKey();
      final response = await clientGoalRepository.editSwp(
        apiKey!,
        client.taxyID!,
        payload,
      );

      final status = WealthyCast.toInt(response['status']);
      final isSuccess = status != null && (status ~/ 100) == 2;

      if (isSuccess) {
        ticketResponse = ProposalModel.fromJson(response['response']);
        editSwpResponse.state = NetworkState.loaded;
      } else {
        editSwpResponse.message =
            getErrorMessageFromResponse(response['response']);
        editSwpResponse.state = NetworkState.error;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      editSwpResponse.message = genericErrorMessage;
      editSwpResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Map<String, dynamic> getUpdateSwpPayload({bool delete = false}) {
    String title = '${delete ? "Delete" : "Edit"} Swp for ';
    if (selectedSwp.swpFunds.isNotNullOrEmpty &&
        selectedSwp.swpFunds?.length == 1) {
      title += (selectedSwp.swpFunds!.first.schemeName ?? '');
    } else {
      title += (goal.displayName ?? '');
    }

    if (delete) {
      return {
        'external_id': selectedSwp.externalId,
        // 'proposal_name': title,
        'delete': true
      };
    }

    Map<String, dynamic> payload = {
      'external_id': selectedSwp.externalId,
      // 'proposal_name': title,
      'swp_days': updatedSwp.days?.join(','),
      'swp_amount': updatedSwp.amount,
      'start_date': updatedSwp.startDate!.toIso8601String().split('T').first,
      'end_date': updatedSwp.endDate!.toIso8601String().split('T').first,
      // 'requestor_code': '',
      // 'ticket_number': '',
      // 'delete':true,
    };

    if (selectedSwp.isPaused != updatedSwp.isPaused) {
      final dateFormatted =
          DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());
      if (updatedSwp.isPaused!) {
        payload['paused_at'] = dateFormatted;
        payload['pause_reason'] = '';
      } else {
        payload['resumed_at'] = dateFormatted;
      }
    }

    LogUtil.printLog('payload = ' + payload.toString());
    return payload;
  }

  void updateAmount(String amount) {
    if (amount.isEmpty) {
    } else {
      if (amount[0] == '₹') {
        amount = amount.substring(2);
      }
      updatedSwp.amount =
          WealthyCast.toInt(amount.replaceAll(',', '').replaceAll(' ', ''));
      if (amount.length > 1 && double.parse(amount) > 999) {
        amount = '${WealthyAmount.formatNumber(amount)}';
      }
      amountController.value = amountController.value.copyWith(
        text: '$amount',
        selection: TextSelection.collapsed(offset: amount.length),
      );
    }
    update();
  }

  void updateStartDate(DateTime startDate) {
    updatedSwp.startDate = startDate;
    startDateController.value = startDateController.value.copyWith(
      text: getFormattedDate(startDate),
    );
    update();
  }

  void updateEndDate(DateTime endDate) {
    updatedSwp.endDate = endDate;
    endDateController.value = endDateController.value.copyWith(
      text: getFormattedDate(endDate),
    );
    update();
  }

  void updateDays(List<int> days) {
    updatedSwp.days = days;
    update();
  }

  void updateStatus(bool isPaused) {
    updatedSwp.isPaused = isPaused;
    update();
  }

  void handlePagination() {
    if (scrollController!.hasClients) {
      bool isScrolledToBottom = scrollController!.position.maxScrollExtent <=
          scrollController!.position.pixels;

      if (isScrolledToBottom && isPagesRemaining && !isPaginating) {
        pageNo += 1;
        isPaginating = true;
        update([GetxId.goalSwpOrders]);
        if (selectedSwp.externalId != null)
          getClientSWPDetails(
            selectedSwp.externalId ?? '',
          ).then(
            (value) {
              isPaginating = false;
              update([GetxId.goalSwpOrders]);
            },
          );
      }
    }
  }
}
