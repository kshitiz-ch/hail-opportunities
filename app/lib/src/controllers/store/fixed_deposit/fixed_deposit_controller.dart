import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/client/add_client_controller.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/common/models/api_response_model.dart';
import 'package:core/modules/store/models/fixed_deposit_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class FixedDepositController extends GetxController {
  String? proposalUrl = '';

  FixedDepositModel? product;

  Client? selectedClient;

  NetworkState createProposalState = NetworkState.loaded;
  String createProposalErrorMessage = '';

  /// Constructor
  FixedDepositController({this.product});

  setSelectedClient(client) {
    selectedClient = client;
    update();
  }

  Future<void> createProposal(FixedDepositModel? product) async {
    createProposalState = NetworkState.loading;
    update([GetxId.createProposal]);

    try {
      int? agentId = await getAgentId();
      String? apiKey = await getApiKey();

      if (selectedClient?.isSourceContacts ?? false) {
        bool isClientCreated = await addClientFromContacts();
        if (!isClientCreated) return;
      }

      Map<String, dynamic> payload = {
        "agent_id": agentId,
        "user_id": selectedClient!.taxyID,
        "product_category": product!.category,
        "product_type": product.productType,
        "product_type_variant": product.productVariant,
        "lumsum_amount": 0,
        "product_extras": null,
      };

      var data = await StoreRepository()
          .createFixedDepositProposal(apiKey!, agentId, payload);

      if (data['status'] == "200") {
        proposalUrl = data['response']['customer_url'];
        createProposalState = NetworkState.loaded;
      } else {
        createProposalState = NetworkState.error;
        createProposalErrorMessage =
            getErrorMessageFromResponse(data['response']);
      }
    } catch (error) {
      createProposalState = NetworkState.error;
      createProposalErrorMessage = "Something went wrong";
    } finally {
      update([GetxId.createProposal]);
    }
  }

  Future<bool> addClientFromContacts() async {
    RestApiResponse clientCreatedResponse =
        await AddClientController().addClientFromContacts(selectedClient!);
    if (clientCreatedResponse.status == 1) {
      selectedClient = clientCreatedResponse.data;
      update([GetxId.createProposal]);
      return true;
    } else {
      // CommonUI.showMessageToast(clientCreatedResponse.message, Colors.black);
      createProposalState = NetworkState.cancel;
      return false;
    }
  }
}
