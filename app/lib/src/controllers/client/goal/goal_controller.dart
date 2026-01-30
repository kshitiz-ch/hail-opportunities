import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/mf.dart';
import 'package:app/src/controllers/client/client_additional_detail_controller.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:core/modules/clients/models/base_sip_model.dart';
import 'package:core/modules/clients/models/base_switch_model.dart';
import 'package:core/modules/clients/models/base_swp_model.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/transaction_model.dart';
import 'package:core/modules/clients/resources/client_goal_repository.dart';
import 'package:core/modules/clients/resources/client_list_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/meta_data_model.dart';
import 'package:core/modules/mutual_funds/models/goal_model.dart';
import 'package:core/modules/mutual_funds/models/user_goal_subtype_scheme_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class GoalController extends GetxController {
  GoalModel? goal;
  List<UserGoalSubtypeSchemeModel> goalSchemes = [];
  //editedGoalSchemes  used for edit allocation
  List<UserGoalSubtypeSchemeModel> editedGoalSchemes = [];

  Client client;
  String goalId;
  MfInvestmentType mfInvestmentType;

  String? wschemecodeSelected;

  ApiResponse goalDetailResponse = ApiResponse();
  ApiResponse goalAllocationResponse = ApiResponse();
  ApiResponse markCustomResponse = ApiResponse();
  ApiResponse updateGoalResponse = ApiResponse();

  // Order Counts
  int mfOrderCount = 0;
  int sipCount = 0;
  int switchCount = 0;
  int swpCount = 0;
  int mfSchemeOrderCount = 0;

  // Scheme Order states
  ApiResponse schemeOrdersResponse = ApiResponse();
  MetaDataModel schemeOrdersMeta =
      MetaDataModel(limit: 20, page: 0, totalCount: 0);
  bool isSchemeOrdersPaginating = false;
  ScrollController schemeOrdersScrollController = ScrollController();
  UserGoalSubtypeSchemeModel? anyFundScheme;
  List<SchemeOrderModel> schemeOrders = [];
  bool isAllAnyFundSchemesFetched = false;

  // SIP states
  ApiResponse sipListResponse = ApiResponse();
  bool showActiveSip = false;
  BaseSipModel? baseSipModel;
  List<BaseSip>? activeBaseSipList;

  // STP States
  ApiResponse stpListResponse = ApiResponse();
  List<BaseSwitch> baseStps = [];

  // SWP States
  ApiResponse swpListResponse = ApiResponse();
  List<BaseSwpModel> swpList = [];

  GoalController({
    required this.client,
    required this.goalId,
    required this.mfInvestmentType,
    this.wschemecodeSelected,
  });

  @override
  void onInit() {
    getGoalSummary();

    schemeOrdersScrollController.addListener(handleSchemeOrdersPagination);

    super.onInit();
  }

  Future<dynamic> getGoalSummary() async {
    goalDetailResponse.state = NetworkState.loading;
    update();

    try {
      final String apiKey = (await getApiKey())!;

      QueryResult response = await StoreRepository()
          .getGoalSummary(apiKey, userId: client.taxyID ?? '', goalId: goalId);

      if (response.hasException) {
        goalDetailResponse.state = NetworkState.error;
        goalDetailResponse.message =
            response.exception!.graphqlErrors[0].message;
      } else {
        goal = GoalModel.fromJson(response.data!['taxy']['goal']);
        goalDetailResponse.state = NetworkState.loaded;

        await getGoalOrderCounts();

        await getGoalAllocation();
      }
    } catch (error) {
      goalDetailResponse.state = NetworkState.error;
      goalDetailResponse.message =
          'Failed to load goal details. Please try again';
    } finally {
      update();
    }
  }

  Future<void> getGoalOrderCounts() async {
    try {
      final String apiKey = (await getApiKey())!;

      QueryResult response = await StoreRepository().getGoalOrderCounts(apiKey,
          userId: client.taxyID ?? '',
          goalId: goalId,
          wschemecode: mfInvestmentType == MfInvestmentType.Funds
              ? wschemecodeSelected
              : '');

      if (!response.hasException) {
        Map<String, dynamic> data = response.data!['taxy'];
        mfOrderCount = data['mfOrdersCount'] ?? 0;
        mfSchemeOrderCount = data['mfSchemeOrdersCount'] ?? 0;
        sipCount = data['sipCountV2']['totalCount'] ?? 0;
        switchCount = data['switchCount']['totalCount'] ?? 0;
        swpCount = data['swpCount']['totalCount'] ?? 0;
      }
    } catch (error) {
      LogUtil.printLog(error);
    }
  }

  Future<dynamic> getGoalAllocation({bool filterBySchemeCode = true}) async {
    goalSchemes.clear();
    editedGoalSchemes.clear();

    goalAllocationResponse.state = NetworkState.loading;

    try {
      final String apiKey = (await getApiKey())!;

      QueryResult response = await StoreRepository().fetchClientGoalAllocations(
        apiKey,
        goalId: goalId,
        userId: client.taxyID ?? '',
        wschemecode: mfInvestmentType == MfInvestmentType.Funds
            ? wschemecodeSelected
            : '',
      );

      if (response.hasException) {
        goalAllocationResponse.state = NetworkState.error;
        goalAllocationResponse.message =
            response.exception!.graphqlErrors[0].message;
      } else {
        final data = response.data!['taxy'];
        if (mfInvestmentType == MfInvestmentType.Funds) {
          for (var json in data['userGoalSubtypeSchemes']) {
            UserGoalSubtypeSchemeModel goalSchemeModel =
                UserGoalSubtypeSchemeModel.fromJson(json);

            goalSchemeModel.schemeData?.wpc = goalSchemeModel.wpc;

            // Filtering the AnyFund selected from AnyFund portfolio
            if (goalSchemeModel.schemeData?.wschemecode ==
                wschemecodeSelected) {
              anyFundScheme = goalSchemeModel;
              break;
            }
          }
        }

        data['userGoalSubtypeSchemes'].forEach((json) {
          UserGoalSubtypeSchemeModel scheme =
              UserGoalSubtypeSchemeModel.fromJson(json);
          scheme.schemeData?.wpc = scheme.wpc;
          goalSchemes.add(scheme);
        });

        if (!filterBySchemeCode) {
          isAllAnyFundSchemesFetched = true;
        }

        goalAllocationResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      goalAllocationResponse.state = NetworkState.error;
      goalAllocationResponse.message =
          'Failed to load goal details. Please try again';
    }
  }

  Future<void> getAllAnyFundSchemes() async {
    goalSchemes.clear();

    goalAllocationResponse.state = NetworkState.loading;

    try {
      final String apiKey = (await getApiKey())!;

      QueryResult response = await StoreRepository().getGoalSchemesv2(
        apiKey,
        goalId: goalId,
        userId: client.taxyID ?? '',
        wschemecode: '',
      );

      if (response.hasException) {
        goalAllocationResponse.state = NetworkState.error;
        goalAllocationResponse.message =
            response.exception!.graphqlErrors[0].message;
      } else {
        final data = response.data!['userFolioData'];

        // TODO: Filter out Any Fund scheme
        data.forEach((json) {
          UserGoalSubtypeSchemeModel scheme = toGoalSubtypeSchemeModel(json);
          goalSchemes.add(scheme);
        });

        isAllAnyFundSchemesFetched = true;

        goalAllocationResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      goalAllocationResponse.state = NetworkState.error;
      goalAllocationResponse.message =
          'Failed to load goal details. Please try again';
    }
  }

  Future<dynamic> getClientSIPList() async {
    sipListResponse.state = NetworkState.loading;
    update([GetxId.goalSip]);

    try {
      String apiKey = await getApiKey() ?? '';

      Map<String, dynamic> payload = {
        'userId': client.taxyID!,
        'goalId': goalId
      };

      QueryResult response = await ClientListRepository().getSIPList(
        apiKey,
        client.taxyID!,
        payload,
      );

      if (response.hasException) {
        sipListResponse.message = response.exception!.graphqlErrors[0].message;
        sipListResponse.state = NetworkState.error;
      } else {
        baseSipModel = BaseSipModel();
        baseSipModel!.baseSips = (response.data!['taxy']['sipMetas'] as List)
            .map((json) => BaseSip.fromJson(json))
            .toList();

        sipListResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      sipListResponse.message = genericErrorMessage;
      sipListResponse.state = NetworkState.error;
    } finally {
      update([GetxId.goalSip]);
    }
  }

  Future<dynamic> getClientSWPList() async {
    swpListResponse.state = NetworkState.loading;
    swpList.clear();
    update([GetxId.goalSwp]);

    try {
      String apiKey = await getApiKey() ?? '';

      QueryResult response = await ClientGoalRepository().getSwpList(
        apiKey,
        client.taxyID!,
        goalId,
      );

      if (response.hasException) {
        swpListResponse.message = response.exception!.graphqlErrors[0].message;
        swpListResponse.state = NetworkState.error;
      } else {
        WealthyCast.toList(response.data!['taxy']['swpMetas']).forEach((json) {
          BaseSwpModel swp = BaseSwpModel.fromJson(json);
          if (mfInvestmentType == MfInvestmentType.Funds) {
            bool anyFundSchemeSwpExists = (swp.swpFunds ?? []).any(
                (SwpFunds fund) => fund.wschemecode == wschemecodeSelected);

            if (anyFundSchemeSwpExists) {
              swpList.add(swp);
            }
          } else {
            swpList.add(swp);
          }
        });
        swpListResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      swpListResponse.message = genericErrorMessage;
      swpListResponse.state = NetworkState.error;
    } finally {
      update([GetxId.goalSwp]);
    }
  }

  Future<dynamic> getClientStpList() async {
    stpListResponse.state = NetworkState.loading;
    baseStps.clear();
    update([GetxId.goalStp]);

    try {
      String apiKey = await getApiKey() ?? '';

      QueryResult response = await ClientListRepository()
          .getStpList(apiKey, client.taxyID!, goalId);

      if (response.hasException) {
        stpListResponse.message = response.exception!.graphqlErrors[0].message;
        stpListResponse.state = NetworkState.error;
      } else {
        (response.data!['taxy']['switchMetas'] as List).forEach((json) {
          BaseSwitch stp = BaseSwitch.fromJson(json);
          if (mfInvestmentType == MfInvestmentType.Funds) {
            bool anyFundSchemeStpExists = (stp.switchFunds ?? []).any(
                (SwitchFundsModel fund) =>
                    fund.switchoutWschemecode == wschemecodeSelected);

            if (anyFundSchemeStpExists) {
              baseStps.add(stp);
            }
          } else {
            baseStps.add(stp);
          }
        });

        stpListResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      stpListResponse.message = genericErrorMessage;
      stpListResponse.state = NetworkState.error;
    } finally {
      update([GetxId.goalStp]);
    }
  }

  Future<void> markGoalAsCustom() async {
    markCustomResponse.state = NetworkState.loading;
    update(['mark-custom']);

    try {
      String apiKey = await getApiKey() ?? '';

      QueryResult response = await ClientGoalRepository()
          .markGoalAsCustom(apiKey, client.taxyID!, goalId);
      if (response.hasException) {
        markCustomResponse.message =
            response.exception!.graphqlErrors[0].message;
        markCustomResponse.state = NetworkState.error;
      } else {
        goal =
            GoalModel.fromJson(response.data!['convertGoalToCustom']['goal']);
        if (Get.isRegistered<ClientDetailController>()) {
          await Get.find<ClientAdditionalDetailController>().getInvestments();
        }
        markCustomResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      markCustomResponse.state = NetworkState.error;
      markCustomResponse.message = genericErrorMessage;
    } finally {
      update(['mark-custom']);
    }
  }

  Future<void> getGoalSchemeOrders() async {
    if (wschemecodeSelected.isNullOrEmpty) {
      schemeOrdersResponse.message = 'Something went wrong. Please try again';
      schemeOrdersResponse.state = NetworkState.error;
      return;
    }

    if (!isSchemeOrdersPaginating) {
      schemeOrdersMeta.page = 0;
      schemeOrders.clear();
    }

    schemeOrdersResponse.state = NetworkState.loading;
    update([GetxId.goalSchemeOrders]);

    try {
      int offset = ((schemeOrdersMeta.page! + 1) * schemeOrdersMeta.limit!) -
          schemeOrdersMeta.limit!;
      String apiKey = await getApiKey() ?? '';
      QueryResult response = await (StoreRepository().getGoalSchemeOrders(
          apiKey,
          goalId: goalId,
          wschemecode: wschemecodeSelected,
          userId: client.taxyID ?? '',
          limit: schemeOrdersMeta.limit!,
          offset: offset));

      if (response.hasException) {
        schemeOrdersResponse.message =
            response.exception!.graphqlErrors[0].message;
        schemeOrdersResponse.state = NetworkState.error;
      } else {
        response.data!['taxy']['schemeOrders'].forEach((schemeOrderJson) {
          schemeOrders.add(SchemeOrderModel.fromJson(schemeOrderJson));
        });

        schemeOrdersMeta.totalCount =
            response.data!['taxy']!['mfSchemeOrdersCount'];

        schemeOrdersResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      schemeOrdersResponse.message = 'Something went wrong';
      schemeOrdersResponse.state = NetworkState.error;
    } finally {
      isSchemeOrdersPaginating = false;
      update([GetxId.goalSchemeOrders]);
    }
  }

  handleSchemeOrdersPagination() {
    if (schemeOrdersScrollController.hasClients) {
      bool isScrolledToBottom =
          schemeOrdersScrollController.position.maxScrollExtent <=
              schemeOrdersScrollController.position.pixels;

      bool isPagesRemaining = (schemeOrdersMeta.totalCount! /
              (schemeOrdersMeta.limit! * (schemeOrdersMeta.page! + 1))) >
          1;

      if (isScrolledToBottom &&
          isPagesRemaining &&
          schemeOrdersResponse.state != NetworkState.loading) {
        schemeOrdersMeta.page = schemeOrdersMeta.page! + 1;
        isSchemeOrdersPaginating = true;

        getGoalSchemeOrders();
      }
    }
  }

  void toggleActiveSIPButton() {
    showActiveSip = !showActiveSip;
    update([GetxId.goalSip]);
  }

  void updateGoalAllocationData(
      {required int goalIndex, int? percentage, bool? isDeprecated}) {
    editedGoalSchemes[goalIndex].idealWeight =
        percentage ?? editedGoalSchemes[goalIndex].idealWeight;
    editedGoalSchemes[goalIndex].isDeprecated =
        isDeprecated ?? editedGoalSchemes[goalIndex].isDeprecated;
    update([goalIndex]);
  }

  Future<void> updateGoal() async {
    updateGoalResponse.state = NetworkState.loading;
    update(['update-goal']);

    try {
      String apiKey = await getApiKey() ?? '';
      QueryResult response = await ClientGoalRepository().updateGoal(
        apiKey,
        client.taxyID!,
        getUpdateGoalPayload(),
      );
      if (response.hasException) {
        updateGoalResponse.message =
            response.exception!.graphqlErrors[0].message;
        updateGoalResponse.state = NetworkState.error;
      } else {
        await getGoalSummary();
        updateGoalResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      updateGoalResponse.state = NetworkState.error;
      updateGoalResponse.message = genericErrorMessage;
    } finally {
      update(['update-goal']);
    }
  }

  Map<String, dynamic> getUpdateGoalPayload() {
    Map<String, dynamic> data = {};
    data['id'] = goalId;
    List<Map> funds = [];
    for (final scheme in editedGoalSchemes) {
      // send only non depreciated funds to api
      if (!(scheme.isDeprecated ?? false)) {
        funds.add({
          'wschemecode': scheme.schemeData?.wschemecode,
          'percentage': scheme.idealWeight,
        });
      }
    }
    data['funds'] = funds;
    return data;
  }
}
