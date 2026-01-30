import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/clients/models/client_investments_model.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/resources/client_list_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/store/models/tracker_model.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class ClientAdditionalDetailController extends GetxController {
  // Fields
  Client? client;
  String? apiKey = '';

  ApiResponse trackerResponse = ApiResponse();
  ApiResponse investmentResponse = ApiResponse();

  double? trackerValue;
  List<FamilyReportModel> familyReports = [];
  DateTime? trackerLastSyncedAt;
  UserPortfolioOverviewModel? clientInvestmentsResult;

  // Constructor
  ClientAdditionalDetailController(this.client);

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() async {
    apiKey = await getApiKey();
    getTrackerInfo();
    getInvestments();

    super.onReady();
  }

  Future<void> getTrackerInfo({bool isRetry = false}) async {
    trackerResponse.state = NetworkState.loading;
    familyReports.clear();
    update(['tracker']);

    try {
      QueryResult response = await ClientListRepository()
          .getClientTrackerValue(apiKey!, client!.taxyID!);

      if (response.hasException) {
        trackerResponse.message = response.exception!.graphqlErrors[0].message;
        trackerResponse.state = NetworkState.error;
      } else {
        trackerValue = WealthyCast.toDouble(
            response.data?['phaser']?['familyOverview']?['mfCurrentValue']);
        List familyReportsJson = WealthyCast.toList(
            response.data?['phaser']?['familyOverview']?['familyReport']);
        familyReportsJson.forEach((familyReportJson) {
          familyReports.add(FamilyReportModel.fromJson(familyReportJson));
        });
        trackerResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      trackerResponse.message = 'Something went wrong';
      trackerResponse.state = NetworkState.error;
    } finally {
      update(['tracker']);
    }
  }

  /// Get Client's Investment data from API
  Future<void> getInvestments() async {
    investmentResponse.state = NetworkState.loading;
    update([GetxId.clientInvestments]);

    try {
      var response = await ClientListRepository()
          .getUserPortfolioOverview(apiKey!, client!.taxyID!);

      if (response.hasException) {
        investmentResponse.message = response.graphqlErrors.first.message;
        investmentResponse.state = NetworkState.error;
      } else {
        clientInvestmentsResult = UserPortfolioOverviewModel.fromJson(
            response.data['userPortfolioOverviewV1']);
        investmentResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      investmentResponse.message = 'Something went wrong';
      investmentResponse.state = NetworkState.error;
    } finally {
      update([GetxId.clientInvestments]);
    }
  }
}
