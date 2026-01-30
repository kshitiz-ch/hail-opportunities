import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/advisor/models/payout_model.dart';
import 'package:core/modules/advisor/resources/advisor_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class PayoutController extends GetxController
    with GetSingleTickerProviderStateMixin {
  ApiResponse payoutsResponse = ApiResponse();
  List<PayoutModel> payoutList = [];

  ApiResponse payoutProductBreakupResponse = ApiResponse();
  Map<String, List<PayoutBreakup>> payoutBreakupMap = {};

  final tabs = ['General Payouts', 'Broking Payouts'];

  late TabController tabController;

  bool get isBrokingPayout => tabController.index == 1;

  PayoutController() {
    tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  Future<void> onInit() async {
    super.onInit();

    getPayouts();

    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        getPayouts();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getPayouts() async {
    payoutsResponse.state = NetworkState.loading;
    update();

    try {
      final apiKey = await getApiKey() ?? '';

      QueryResult response = await AdvisorRepository().getPayouts(
        apiKey,
        isBrokingPayout: isBrokingPayout,
      );

      if (!response.hasException) {
        payoutsResponse.state = NetworkState.loaded;
        final payoutListJson = isBrokingPayout
            ? WealthyCast.toList(response.data!['hydra']['brokingPayouts'])
            : WealthyCast.toList(response.data!['hydra']['payouts']);

        payoutList = payoutListJson
            .map((payoutJson) => PayoutModel.fromJson(
                  payoutJson,
                  isBrokingPayout: isBrokingPayout,
                ))
            .toList();

        // sort in descending order of date
        payoutList.sort(
          ((a, b) {
            final dateA = a.payoutDate ?? a.payoutReadyDate;
            final dateB = b.payoutDate ?? b.payoutReadyDate;
            if (dateA == null || dateB == null) return 0;
            return dateB.compareTo(dateA);
          }),
        );
      } else {
        payoutsResponse.state = NetworkState.error;
        payoutsResponse.message = response.exception!.graphqlErrors[0].message;
      }
    } catch (error) {
      payoutsResponse.state = NetworkState.error;
      payoutsResponse.message = genericErrorMessage;
    } finally {
      update();
    }
  }

  Future<void> getPayoutProductBreakup(String payoutId) async {
    payoutProductBreakupResponse.state = NetworkState.loading;
    update([payoutId]);

    try {
      final apiKey = await getApiKey() ?? '';

      QueryResult response = await AdvisorRepository().getPayoutProductBreakup(
        apiKey!,
        payoutId,
        isBrokingPayout: isBrokingPayout,
      );
      if (!response.hasException) {
        payoutProductBreakupResponse.state = NetworkState.loaded;

        final payoutBreakupListJson = isBrokingPayout
            ? WealthyCast.toList(
                response.data!['hydra']['brokingPayoutBreakup'])
            : WealthyCast.toList(response.data!['hydra']['payoutBreakup']);

        final payoutBreakupList = payoutBreakupListJson
            .map(
              (payoutBreakupJson) => PayoutBreakup.fromJson(payoutBreakupJson),
            )
            .toList();
        payoutBreakupMap[payoutId] = List.from(payoutBreakupList);
      } else {
        payoutProductBreakupResponse.state = NetworkState.error;
        payoutProductBreakupResponse.message =
            response.exception!.graphqlErrors[0].message;
      }
    } catch (error) {
      payoutProductBreakupResponse.state = NetworkState.error;
      payoutProductBreakupResponse.message = genericErrorMessage;
    } finally {
      update([payoutId]);
    }
  }
}
