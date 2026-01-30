import 'package:api_sdk/api_collection/store_api.dart';
import 'package:api_sdk/api_constants.dart';
import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/mf_investment_model.dart';
import 'package:core/modules/clients/resources/client_list_repository.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/mutual_funds/models/store_fund_allocation.dart';
import 'package:core/modules/mutual_funds/models/user_goal_subtype_scheme_model.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class MfInvestmentController extends GetxController {
  Client? client;

  ApiResponse mfInvestmentResponse = ApiResponse();
  MfInvestmentModel? mfInvestment;

  GoalSubtypeModel? selectedPortfolio;

  List<SchemeMetaModel> portfolioFunds = [];
  SchemeMetaModel? fundDetail;

  NetworkState? portfolioDetailState = NetworkState.cancel;
  NetworkState? fundsState = NetworkState.cancel;
  NetworkState? fundDetailState = NetworkState.cancel;

  String portfolioErrorMessage = '';
  String fundsErrorMessage = '';

  bool isFundExpanded = false;
  bool showEmptyFolios = false;
  bool canTopUp = false;
  bool isTaxSaverDeprecated = false;

  bool showAbsoluteReturn = true;

  List<MfInvestmentType> filtersSaved = [
    MfInvestmentType.Funds,
    MfInvestmentType.Portfolios
  ];

  List<MfInvestmentType> filtersSelected = [
    MfInvestmentType.Funds,
    MfInvestmentType.Portfolios
  ];

  MfInvestmentController(this.client);

  void onInit() {
    fetchMfProducts();
    super.onInit();
  }

  Future<void> fetchMfProducts() async {
    mfInvestmentResponse.state = NetworkState.loading;
    update();
    try {
      String apiKey = await getApiKey() ?? '';
      QueryResult response =
          await ClientListRepository().getProductInvestmentDetails(
        apiKey,
        client!.taxyID!,
        type: ClientInvestmentProductType.mutualFunds,
        showZeroFolios: showEmptyFolios,
      );

      if (response.hasException) {
        mfInvestmentResponse.state = NetworkState.error;
      } else {
        mfInvestment =
            MfInvestmentModel.fromJson(response.data!["userMFHybridView"]);

        mfInvestmentResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      mfInvestmentResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<dynamic> getGoalDetails(
      {required String userId, required String goalId}) async {
    portfolioFunds = [];
    portfolioDetailState = NetworkState.loading;
    update();
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
      update();
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
            try {
              userGoalSubtype['schemeData']['returns'] = {
                'oneYrRtrns': userGoalSubtype['schemeData']['oneYrRtrns'],
                'threeYrRtrns': userGoalSubtype['schemeData']['threeYrRtrns'],
                'fiveYrRtrns': userGoalSubtype['schemeData']['fiveYrRtrns'],
              };
            } catch (error) {
              LogUtil.printLog(error);
            }

            final userGoalSubtypeModel =
                UserGoalSubtypeSchemeModel.fromJson(userGoalSubtype);

            // final schemeData = userGoalSubtype['schemeData'];
            // schemeData['returns'] = {
            //   'oneYrRtrns': schemeData['oneYrRtrns'],
            //   'threeYrRtrns': schemeData['threeYrRtrns'],
            //   'fiveYrRtrns': schemeData['fiveYrRtrns'],
            //   'rtrnsSinceLaunch': schemeData['rtrnsSinceLaunch'],
            // };

            userGoalSubtypeModel.schemeData?.isDeprecated =
                userGoalSubtypeModel.isDeprecated;

            userGoalSubtypeModel.schemeData?.wpc = userGoalSubtypeModel.wpc;
            userGoalSubtypeModel.schemeData?.idealWeight =
                userGoalSubtypeModel.idealWeight;
            userGoalSubtypeModel.schemeData?.currentAbsoluteReturns =
                userGoalSubtypeModel.currentAbsoluteReturns;
            userGoalSubtypeModel.schemeData?.currentValue =
                userGoalSubtypeModel.currentValue;
            userGoalSubtypeModel.schemeData?.currentInvestedValue =
                userGoalSubtypeModel.currentInvestedValue;

            // =========================================================
            // FOLIO SPLITTING LOGIC (COMMENTED OUT)
            // =========================================================
            // Previously, if a scheme had multiple folios, we would create
            // separate cards for each folio. This was commented out because
            // the UI now shows one card per scheme with aggregate data,
            // not individual folio cards.
            //
            // To re-enable folio splitting (show multiple cards per scheme
            // based on number of folios), uncomment the if-else block below
            // and comment out the "CURRENT LOGIC" section.
            // =========================================================

            // if (userGoalSubtypeModel.folioOverviews.isNotNullOrEmpty &&
            //     userGoalSubtypeModel.folioOverviews!.length > 1) {
            //   userGoalSubtypeModel.folioOverviews!.forEach((folio) {
            //     SchemeMetaModel schemeMetaModel =
            //         SchemeMetaModel.clone(userGoalSubtypeModel.schemeData!);
            //     schemeMetaModel.folioOverview = folio;
            //
            //     // Override scheme-level aggregate values with folio-specific values
            //     schemeMetaModel.currentValue = folio.currentValue;
            //     schemeMetaModel.currentInvestedValue =
            //         folio.investedValue ?? folio.investedAmount;
            //     schemeMetaModel.units = folio.units;
            //
            //     // Calculate absolute returns for this specific folio
            //     // Returns as ratio (e.g., 0.009573 for 0.96%) to match API format
            //     if ((schemeMetaModel.currentInvestedValue ?? 0) > 0) {
            //       schemeMetaModel.currentAbsoluteReturns =
            //           ((schemeMetaModel.currentValue ?? 0) -
            //                   schemeMetaModel.currentInvestedValue!) /
            //               schemeMetaModel.currentInvestedValue!;
            //     } else {
            //       schemeMetaModel.currentAbsoluteReturns = 0;
            //     }
            //
            //     portfolioFunds.add(schemeMetaModel);
            //   });
            // } else {
            //   // Single folio case - use aggregate data
            //   userGoalSubtypeModel.schemeData?.folioOverview =
            //       userGoalSubtypeModel.folioOverview;
            //
            //   if (userGoalSubtypeModel.schemeData?.idealWeight == null &&
            //       isWealthyPortfolio &&
            //       selectedPortfolio?.schemes != null) {
            //     Iterable temp = selectedPortfolio!.schemes!.where(
            //       (scheme) =>
            //           userGoalSubtypeModel.schemeData?.wschemecode ==
            //           scheme['wschemecode'],
            //     );
            //
            //     if (temp.isNotEmpty) {
            //       userGoalSubtypeModel.schemeData?.idealWeight =
            //           temp.first["ideal_weight"] ?? 0;
            //     }
            //   }
            //
            //   portfolioFunds.add(userGoalSubtypeModel.schemeData!);
            // }

            // =========================================================
            // CURRENT LOGIC: One card per scheme (aggregate data)
            // =========================================================
            // Shows one card per scheme using scheme-level aggregate values
            // (currentValue, currentInvestedValue, currentAbsoluteReturns)
            // regardless of how many folios the scheme has.
            // =========================================================

            // Use the first folioOverview for display (aggregate data is in schemeData)
            userGoalSubtypeModel.schemeData?.folioOverview =
                userGoalSubtypeModel.folioOverview;

            if (userGoalSubtypeModel.schemeData?.idealWeight == null &&
                isWealthyPortfolio &&
                selectedPortfolio?.schemes != null) {
              ;
              Iterable temp = selectedPortfolio!.schemes!.where(
                (scheme) =>
                    userGoalSubtypeModel.schemeData?.wschemecode ==
                    scheme['wschemecode'],
              );

              if (temp.isNotEmpty) {
                userGoalSubtypeModel.schemeData?.idealWeight =
                    temp.first["ideal_weight"] ?? 0;
              }
            }

            portfolioFunds.add(userGoalSubtypeModel.schemeData!);
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

  Future<void> getFundDetails(String wSchemeCode) async {
    fundDetailState = NetworkState.loading;
    update();

    try {
      String apiKey = await getApiKey() ?? '';
      final QueryResult response =
          await StoreAPI.getSchemeData(apiKey, null, wSchemeCode);

      if (response.hasException) {
        response.exception!.graphqlErrors.forEach((graphqlError) {
          LogUtil.printLog(graphqlError.message);
        });
        fundDetailState = NetworkState.error;
      } else {
        StoreFundAllocation storeFundResult =
            StoreFundAllocation.fromJson(response.data!['metahouse']);

        fundDetail = storeFundResult.schemeMetas!.first;

        fundDetailState = NetworkState.loaded;
      }
    } catch (e) {
      fundDetailState = NetworkState.error;
    } finally {
      update();
    }
  }

  toggleFundExpanded() {
    isFundExpanded = !isFundExpanded;
    update();
  }

  toggleShowEmptyFolios() {
    showEmptyFolios = !showEmptyFolios;
    fetchMfProducts();
  }

  updateFiltersSelected(MfInvestmentType filter) {
    if (filtersSelected.contains(filter)) {
      filtersSelected.remove(filter);
    } else {
      filtersSelected.add(filter);
    }

    update(['filter-bottomsheet']);
  }

  saveFilters() {
    filtersSaved = List.from(filtersSelected);
    update();
  }

  void toggleAbsoluteReturn() {
    showAbsoluteReturn = !showAbsoluteReturn;
    update();
  }
}
