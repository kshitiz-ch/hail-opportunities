import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/config/string_utils.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/wealthcase/models/wealthcase_model.dart';
import 'package:core/modules/wealthcase/resources/wealthcase_repository.dart';
import 'package:get/get.dart';

class WealthcaseController extends GetxController {
  ApiResponse wealthcaseListResponse = ApiResponse();
  List<WealthcaseModel> wealthcaseList = [];

  WealthcaseModel? selectedWealthcase;

  ApiResponse basketDetailResponse = ApiResponse();

  ApiResponse sendProposalResponse = ApiResponse();

  // State for showing/hiding benchmark comparison
  bool showBenchmarkComparison = false;
  BenchmarkModel? selectedBenchmark;

  void setSelectedBenchmark(BenchmarkModel benchmark) {
    selectedBenchmark = benchmark;
    showBenchmarkComparison = true;
    update();
  }

  @override
  void onReady() {
    super.onReady();
    getWealthcaseList();
  }

  Future<void> getWealthcaseList() async {
    try {
      wealthcaseListResponse.state = NetworkState.loading;
      update();

      String apiKey = await getApiKey() ?? '';

      final response = await WealthcaseRepository().getWealthcaseList(apiKey);

      if (response['status'] == '200') {
        wealthcaseList = WealthyCast.toList(response['response'])
            .map((item) => WealthcaseModel.fromJson(item))
            .toList();
        wealthcaseListResponse.state = NetworkState.loaded;
      } else {
        wealthcaseListResponse.state = NetworkState.error;
        wealthcaseListResponse.message =
            getErrorMessageFromResponse(response['response']);
      }
    } catch (e) {
      LogUtil.printLog('Error fetching wealthcase list: $e');
      wealthcaseListResponse.state = NetworkState.error;
      wealthcaseListResponse.message = 'Something went wrong';
    } finally {
      update();
    }
  }

  Future<void> getWealthcaseBasketDetail(String basketId) async {
    try {
      // Reset selected wealthcase
      selectedWealthcase = null;

      // Reset benchmark comparison state
      showBenchmarkComparison = false;
      selectedBenchmark = null;

      basketDetailResponse.state = NetworkState.loading;
      update();

      String apiKey = await getApiKey() ?? '';

      final response = await WealthcaseRepository()
          .getWealthcaseBasketDetail(apiKey, basketId);

      if (response['status'] == '200') {
        selectedWealthcase = WealthcaseModel.fromJson(response['response']);
        basketDetailResponse.state = NetworkState.loaded;
      } else {
        basketDetailResponse.state = NetworkState.error;
        basketDetailResponse.message =
            getErrorMessageFromResponse(response['response']);
      }
    } catch (e) {
      LogUtil.printLog('Error fetching wealthcase basket detail: $e');
      basketDetailResponse.state = NetworkState.error;
      basketDetailResponse.message = 'Something went wrong';
    } finally {
      update();
    }
  }

  Future<String?> sendWealthcaseProposal(
    String basketId,
    String userId, {
    List<String>? agentExternalIds,
  }) async {
    String? proposalUrl;
    try {
      sendProposalResponse.state = NetworkState.loading;
      update();

      final apiKey = await getApiKey() ?? '';
      final proposalData = {
        "user_id": userId,
        "basket_id": basketId,
        if (agentExternalIds.isNotNullOrEmpty)
          "agent_external_ids": agentExternalIds
      };

      final response = await WealthcaseRepository().createWealthCaseProposal(
        apiKey,
        proposalData,
      );

      final status = WealthyCast.toInt(response['status']);
      final isSuccess = status != null && (status ~/ 100) == 2;

      if (isSuccess) {
        proposalUrl =
            WealthyCast.toStr(response['response']['customer_url']) ?? '';
        sendProposalResponse.message =
            'Wealthcase proposal created successfully';

        sendProposalResponse.state = NetworkState.loaded;
      } else {
        sendProposalResponse.state = NetworkState.error;
        sendProposalResponse.message =
            WealthyCast.toStr(response['response']['message']) ??
                getErrorMessageFromResponse(response['response']);
      }
    } catch (e) {
      LogUtil.printLog('Error fetching wealthcase proposal: $e');
      sendProposalResponse.state = NetworkState.error;
      sendProposalResponse.message = 'Something went wrong';
    } finally {
      update();
      return proposalUrl;
    }
  }
}
