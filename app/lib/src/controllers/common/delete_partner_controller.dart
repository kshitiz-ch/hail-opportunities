import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/dashboard/models/agent_delete_request_model.dart';
import 'package:core/modules/dashboard/resources/advisor_overview_repository.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class DeletePartnerController extends GetxController {
  late AdvisorOverviewRepository advisorOverviewRepository;
  String? apiKey;
  AgentProfileDeleteRequestModel? agentProfileDeleteRequestModel;

  NetworkState deletePartnerRequestState = NetworkState.cancel;
  NetworkState deletePartnerDetailState = NetworkState.cancel;
  NetworkState cancelDeletePartnerRequestState = NetworkState.cancel;

  String? deletePartnerRequestMessage = '';
  String? deletePartnerDetailErrorMessage = '';
  String? cancelDeletePartnerRequestMessage = '';

  bool isAccountDeletionRequestOpen = false;

  @override
  Future<void> onInit() async {
    advisorOverviewRepository = AdvisorOverviewRepository();
    apiKey = await getApiKey();
    // for initially checking whether delete request is made or not
    getDeletePartnerDetails();
    super.onInit();
  }

  @override
  void onReady() async {}

  @override
  void dispose() {
    super.dispose();
  }

  Future<dynamic> deletePartner() async {
    try {
      deletePartnerRequestState = NetworkState.loading;
      update();
      var response =
          await advisorOverviewRepository.deletePartnerRequest(apiKey!);
      if (response.hasException) {
        deletePartnerRequestMessage =
            response.exception.graphqlErrors[0].message;
        deletePartnerRequestState = NetworkState.error;
      } else {
        deletePartnerRequestMessage =
            response.data['deleteAgentProfileRequest']['agentProfileDeleteReq'];
        isAccountDeletionRequestOpen = true;
        // to update agentProfileDeleteRequestModel model
        getDeletePartnerDetails();
        deletePartnerRequestState = NetworkState.loaded;
      }
    } catch (error) {
      deletePartnerRequestMessage = 'Something went wrong! please try again';
      deletePartnerRequestState = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<dynamic> getDeletePartnerDetails() async {
    try {
      deletePartnerDetailState = NetworkState.loading;
      update();
      var response =
          await advisorOverviewRepository.getDeletePartnerDetails(apiKey!);
      if (response.hasException) {
        deletePartnerDetailErrorMessage =
            response.exception.graphqlErrors[0].message;
        deletePartnerDetailState = NetworkState.error;
      } else {
        agentProfileDeleteRequestModel =
            AgentProfileDeleteRequestModel.fromJson(
                response.data['hydra']['agentProfileDeleteRequest']);
        isAccountDeletionRequestOpen = agentProfileDeleteRequestModel?.status ==
            DeletePartnerRequestStatus.INITIATED;
        deletePartnerDetailState = NetworkState.loaded;
      }
    } catch (error) {
      deletePartnerDetailErrorMessage =
          'Something went wrong! please try again';
      deletePartnerDetailState = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<dynamic> cancelPartnerDeleteRequest() async {
    try {
      cancelDeletePartnerRequestState = NetworkState.loading;
      update();
      var response = await advisorOverviewRepository.cancelDeletePartnerRequest(
          apiKey!, agentProfileDeleteRequestModel!.externalId!);
      if (response.hasException) {
        cancelDeletePartnerRequestMessage =
            response.exception.graphqlErrors[0].message;
        cancelDeletePartnerRequestState = NetworkState.error;
      } else {
        isAccountDeletionRequestOpen = false;
        cancelDeletePartnerRequestMessage = response
            .data['cancelDeleteAgentProfileRequest']['agentProfileDeleteReq'];
        cancelDeletePartnerRequestState = NetworkState.loaded;
      }
    } catch (error) {
      cancelDeletePartnerRequestMessage =
          'Something went wrong! please try again';
      cancelDeletePartnerRequestState = NetworkState.error;
    } finally {
      update();
    }
  }
}
