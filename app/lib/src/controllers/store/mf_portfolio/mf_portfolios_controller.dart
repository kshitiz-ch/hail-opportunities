import 'dart:async';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/main.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/mf_investment_model.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/mutual_funds/models/user_goal_subtype_scheme_model.dart';
import 'package:core/modules/proposals/models/proposal_model.dart';
import 'package:core/modules/proposals/resources/proposals_repository.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:core/modules/top_up_portfolio/models/portfolio_model.dart';
import 'package:core/modules/top_up_portfolio/models/portfolio_user_products_model.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class MFPortfoliosController extends GetxController {
  String? apiKey = '';

  List<PortfolioUserProductsModel>? topUpPortfolios = [];
  PortfolioInvestmentModel? portfolioInvestment;
  // GoalSubtypeModel? selectedPortfolioDetail;
  // PortfolioUserProductsModel? selectedPortfolio;
  GoalSubtypeModel? selectedPortfolio;
  List<SchemeMetaModel> portfolioFunds = [];

  List<SchemeMetaModel> customPortfolioFunds = [];
  bool isFetchingPortfolioDetail = false;

  NetworkState? searchState;
  NetworkState? topUpPortfoliosState;
  NetworkState? portfolioDetailState;
  NetworkState? proposalDetailState;

  TextEditingController? searchController;
  String searchText = '';

  String mutualFundsErrorMessage = '';
  String portfolioErrorMessage = '';

  Timer? _debounce;
  FocusNode? searchBarFocusNode;

  String? selectedProposalExternalId = '';
  ProposalModel? selectedProposalDetail =
      ProposalModel(userProfileStatuses: []);

  bool canTopUp = false;
  bool isTaxSaverDeprecated = false;

  @override
  void onInit() {
    searchController = TextEditingController();
    searchState = NetworkState.cancel;

    super.onInit();
  }

  @override
  void onReady() async {
    apiKey = await getApiKey();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController!.dispose();
    searchBarFocusNode?.dispose();
    super.dispose();
  }

  setIsFetchingPortfolioDetail(bool isLoading) {
    isFetchingPortfolioDetail = isLoading;
    update([GetxId.topUpPortfolios]);
  }

  void updateProposalExternalId(String? externalId) {
    selectedProposalExternalId = externalId;
    update([GetxId.topUpPortfolios]);
  }

  Future<ProposalModel?> getUpdatedProposalDetail(String externalId) async {
    try {
      proposalDetailState = NetworkState.loading;
      update([GetxId.topUpPortfolios]);

      final response =
          await ProposalRepository().getProposalData(apiKey!, externalId);

      if (response['status'] == '200') {
        final Map<String, dynamic> data = response['response'];

        selectedProposalDetail = ProposalModel.fromJson(data);
      } else {
        selectedProposalDetail = null;
      }
    } catch (e) {
      selectedProposalDetail = null;
      LogUtil.printLog(e.toString());
    }

    proposalDetailState = NetworkState.loaded;
    update([GetxId.topUpPortfolios]);

    return selectedProposalDetail;
  }

  Future<dynamic> getGoalDetails(
      {required String userId, required String goalId}) async {
    portfolioFunds = [];
    portfolioDetailState = NetworkState.loading;
    update([GetxId.topUpPortfolios]);

    try {
      final String apiKey = (await getApiKey())!;
      QueryResult response = await StoreRepository().getGoalDetails(
        apiKey,
        userId: userId,
        goalId: goalId,
      );

      if (response.hasException) {
        portfolioErrorMessage = "This portfolio is not available for top up";
        portfolioDetailState = NetworkState.error;
      } else {
        final data = response.data!;

        Map<String, dynamic>? goalJson = data['taxy']['goal'];
        Map<String, dynamic>? goalSubtypeJson =
            goalJson != null ? goalJson['goalSubtype'] : null;

        if (goalJson != null) {
          portfolioInvestment = PortfolioInvestmentModel.fromJson(goalJson);
        }

        if (goalSubtypeJson != null) {
          selectedPortfolio = GoalSubtypeModel.fromJson({
            "title": goalJson!["displayName"],
            "external_id": goalId,
            "goal_type": goalSubtypeJson["goalType"],
            "product_variant": goalSubtypeJson["subtype"],
            "schemes": goalSubtypeJson["goalsubtypeschemes"],
            "past_one_year_returns": goalSubtypeJson["pastOneYearReturns"],
            "past_three_year_returns": goalSubtypeJson["pastThreeYearReturns"],
            "past_five_year_returns": goalSubtypeJson["pastFiveYearReturns"],
            "min_amount": goalSubtypeJson["minAmount"],
            "min_add_amount": goalSubtypeJson["minAmount"],
            "avg_returns": goalSubtypeJson["avgReturns"],
            "term": goalSubtypeJson["term"],
          });

          canTopUp = goalJson["canMakePayment"] ?? false;

          if (selectedPortfolio!.isTaxSaver && goalJson["endDate"] != null) {
            DateTime? endDateParsed = DateTime.tryParse(goalJson["endDate"]);
            isTaxSaverDeprecated = endDateParsed != null
                ? endDateParsed.isBefore(DateTime.now())
                : false;
          }

          bool isCustom = [GoalType.CUSTOM, GoalType.ANY_FUNDS]
              .contains(selectedPortfolio?.goalType);

          await getPortfolioFunds(userId, isWealthyPortfolio: !isCustom);

          portfolioDetailState = NetworkState.loaded;
        } else {
          throw Exception();
        }
      }
    } catch (error) {
      portfolioErrorMessage = "This portfolio is not available for top up";
      portfolioDetailState = NetworkState.error;
    } finally {
      update([GetxId.topUpPortfolios]);
    }
  }

  Future<void> getPortfolioFunds(String userId,
      {bool isWealthyPortfolio = false}) async {
    try {
      final String apiKey = (await getApiKey())!;
      var response = await StoreRepository().getClientCustomGoalFunds(
        apiKey,
        selectedPortfolio?.externalId ?? '',
        userId,
      );

      if (!response.hasException) {
        final data = response.data['taxy'];
        data['userGoalSubtypeSchemes'].forEach(
          (userGoalSubtype) {
            final userGoalSubtypeModel =
                UserGoalSubtypeSchemeModel.fromJson(userGoalSubtype);

            final schemeData = userGoalSubtype['schemeData'];
            schemeData['returns'] = {
              'oneYrRtrns': schemeData['oneYrRtrns'],
              'threeYrRtrns': schemeData['threeYrRtrns'],
              'fiveYrRtrns': schemeData['fiveYrRtrns'],
              'rtrnsSinceLaunch': schemeData['rtrnsSinceLaunch'],
            };

            schemeData["currentInvestedValue"] =
                userGoalSubtypeModel.currentInvestedValue;
            schemeData["currentValue"] = userGoalSubtypeModel.currentValue;
            schemeData["isDeprecated"] = userGoalSubtypeModel.isDeprecated;
            schemeData["idealWeight"] = userGoalSubtypeModel.idealWeight;
            schemeData["currentAbsoluteReturns"] =
                userGoalSubtypeModel.currentAbsoluteReturns;
            schemeData["folioOverview"] = userGoalSubtype["folioOverview"];
            if (userGoalSubtypeModel.wpc.isNotNullOrEmpty) {
              schemeData["wpc"] = userGoalSubtypeModel.wpc;
            }
            SchemeMetaModel schemeMetaModel =
                SchemeMetaModel.fromJson(schemeData);

            if (schemeMetaModel.idealWeight == null &&
                isWealthyPortfolio &&
                selectedPortfolio?.schemes != null) {
              ;
              Iterable temp = selectedPortfolio!.schemes!.where(
                (scheme) =>
                    schemeMetaModel.wschemecode == scheme['wschemecode'],
              );

              if (temp.isNotEmpty) {
                schemeMetaModel.idealWeight = temp.first["ideal_weight"] ?? 0;
              }
            }

            portfolioFunds.add(schemeMetaModel);
          },
        );

        if (selectedPortfolio?.isSmartSwitch ?? false) {
          try {
            portfolioFunds.sort(
                (a, b) => (a.idealWeight ?? 0).compareTo(b.idealWeight ?? 0));

            // Sort by AMC()
            portfolioFunds.sort((a, b) {
              String amcName1 = (a.displayName ?? "").split(" ").first;
              String amcName2 = (b.displayName ?? "").split(" ").first;
              return amcName1.compareTo(amcName2);
            });
          } catch (error) {
            LogUtil.printLog(error);
          }
        }
      }
    } finally {
      update();
    }
  }

  // TODO: Move all top up portfolio logic to a separate controller
  Future<dynamic> getTopUpPortfolios(Client client) async {
    topUpPortfoliosState = NetworkState.loading;
    update([GetxId.topUpPortfolios]);

    try {
      final String apiKey = (await getApiKey())!;
      var response = await StoreRepository().getClientPortfolios(
        apiKey,
        client.taxyID!,
        ProductCategoryType.INVEST,
      );

      if (!response.hasException) {
        final data = response.data['entreat'];
        PortfolioModel portfolioModel = PortfolioModel.fromJson(data);
        topUpPortfolios = portfolioModel.userProducts;
      }
      topUpPortfoliosState = NetworkState.loaded;
    } catch (error) {
      topUpPortfoliosState = NetworkState.loaded;
    } finally {
      update([GetxId.topUpPortfolios]);
    }
  }

  /// Search
  // TODO: Implement Search
  void search(String query) {
    searchState = NetworkState.loading;
    update(['search']);

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        clearSearchBar();
        return null;
      }
      // do something with query
      searchState = NetworkState.loaded;
      update(['search']);
    });
  }

  void clearSearchBar() {
    searchText = "";
    searchController!.clear();
    searchState = NetworkState.cancel;
    update(['search']);
  }
}
