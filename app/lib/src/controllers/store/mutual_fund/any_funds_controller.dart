import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/mutual_funds/models/user_goal_subtype_scheme_model.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class AnyFundsController extends GetxController {
  List<SchemeMetaModel> customPortfolioFunds = [];
  NetworkState portfolioDetailState = NetworkState.loading;

  GoalSubtypeModel? selectedPortfolio;

  AnyFundsController({this.selectedPortfolio});

  Future<void> getGoalSubtype({required String userId}) async {
    try {
      String apiKey = (await getApiKey())!;
      QueryResult response = await (StoreRepository()
          .fetchGoalSubtype(apiKey, userId, selectedPortfolio!.externalId!));

      if (!response.hasException) {
        final data = response.data!;
        int? goalType = data['taxy']['goal']['goalSubtype']['goalType'];
        int? goalSubtype = data['taxy']['goal']['goalSubtype']['subtype'];

        selectedPortfolio!.goalType = goalType;
        selectedPortfolio!.productVariant = goalSubtype.toString();

        String? name = data['taxy']['goal']['name'];
        selectedPortfolio!.title = name;

        portfolioDetailState = NetworkState.loaded;
      } else {
        portfolioDetailState = NetworkState.error;
      }
    } catch (error) {
      portfolioDetailState = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> getAnyFunds(
      BuildContext context, Client client, String externalId) async {
    customPortfolioFunds.clear();

    try {
      final String apiKey = (await getApiKey())!;
      var response = await StoreRepository().getClientCustomGoalFunds(
        apiKey,
        externalId,
        client.taxyID!,
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
            schemeData["folioOverview"] = userGoalSubtype["folioOverview"];
            customPortfolioFunds.add(new SchemeMetaModel.fromJson(schemeData));
          },
        );
      }
    } finally {
      update();
    }
  }
}
