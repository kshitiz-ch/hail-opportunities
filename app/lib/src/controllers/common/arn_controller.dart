import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/dashboard/models/kyc/partner_arn_model.dart';
import 'package:core/modules/dashboard/resources/advisor_overview_repository.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class ArnController extends GetxController {
  String? fromScreen;
  int? euinSelected;
  String euin = '';

  NetworkState arnAttachState = NetworkState.cancel;
  String? arnAttachErrorMessage = '';

  Future<void> attachArn(String externalId, String euin) async {
    try {
      arnAttachState = NetworkState.loading;
      update();

      String apiKey = (await getApiKey())!;
      dynamic data = await AdvisorOverviewRepository()
          .attachEUIN(apiKey, externalId, euin);

      if (data is PartnerArnModel) {
        arnAttachState = NetworkState.loaded;
      } else {
        arnAttachState = NetworkState.error;
        arnAttachErrorMessage = data;
      }
    } catch (error) {
      arnAttachState = NetworkState.error;
      arnAttachErrorMessage = 'Something went wrong. Please contact your RM';
    }

    update();
  }

  void onEuinSelected(int index) {
    euinSelected = index;
    update();
  }
}
