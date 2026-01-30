import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/client/add_client_controller.dart';
import 'package:core/main.dart';
import 'package:core/modules/common/models/api_response_model.dart';
import 'package:core/modules/proposals/models/proposal_model.dart';
import 'package:core/modules/store/models/unlisted_stocks_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class PreIPOController extends GetxController {
  // Fields
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Client? selectedClient;

  UnlistedProductModel? product;
  UnlistedStockModel preIPOsResult = UnlistedStockModel(products: []);

  NetworkState? dematsState;
  NetworkState? accountDetailsState;
  NetworkState? createProposalState;
  NetworkState? updateProposalState;

  String? proposalUrl = '';
  String? apiKey = '';
  int? agentId;

  // Used in Update Proposal Flow
  bool isUpdateProposal;
  ProposalModel? proposal;

  String dematsErrorMessage = '';
  String accountDetailsErrorMessage = '';

  ProposalModel? createProposalResponse;
  String createProposalErrorMessage = '';
  String updateProposalErrorMessage = '';

  double? sharePrice = 0;
  int? shares = 0;

  TextEditingController? sharePriceController;
  TextEditingController? sharesController;

  FocusNode? sharesFocusNode;

  // Constructor
  PreIPOController({
    this.product,
    this.selectedClient,
    this.isUpdateProposal = false,
    this.proposal,
  }) : assert(isUpdateProposal ? proposal != null : true);

  @override
  void onInit() {
    dematsState = NetworkState.loading;
    accountDetailsState = NetworkState.loading;
    createProposalState = NetworkState.cancel;
    updateProposalState = NetworkState.cancel;

    sharePriceController = TextEditingController();
    sharesController = TextEditingController();

    sharesFocusNode = FocusNode();

    if (isUpdateProposal) {
      selectedClient = proposal!.customer;
    }

    super.onInit();
  }

  @override
  void onReady() async {
    apiKey = await getApiKey();
    agentId = await getAgentId();
  }

  @override
  void dispose() {
    sharePriceController!.dispose();
    sharesController!.dispose();

    sharesFocusNode!.dispose();

    super.dispose();
  }

  Future<void> createProposal() async {
    createProposalState = NetworkState.loading;
    update([GetxId.createProposal]);

    try {
      if (selectedClient!.isSourceContacts) {
        bool isClientCreated = await addClientFromContacts();
        if (!isClientCreated) return;
      }

      Map payload = await getCreateProposalPayload();
      var data = await StoreRepository().createPreIpoProposal(payload, apiKey!);

      if (data['status'] == '200') {
        // TODO: Same approach for other Controllers
        createProposalResponse = ProposalModel.fromJson(data['response']);
        proposalUrl = data['response']['customer_url'];
        createProposalState = NetworkState.loaded;
      } else {
        createProposalErrorMessage =
            getErrorMessageFromResponse(data['response']);
        createProposalState = NetworkState.error;
      }
    } catch (error) {
      createProposalErrorMessage = 'Something went wrong. Please try again';
      createProposalState = NetworkState.error;
    } finally {
      update([GetxId.createProposal]);
    }
  }

  /// Update the Pre IPO proposal
  Future<void> updateProposal() async {
    updateProposalState = NetworkState.loading;
    update([GetxId.updateProposal]);

    try {
      Map payload = await getUpdateProposalPayload();
      final data = await StoreRepository().updatePreIpoProposal(
        payload,
        proposal!.externalId!,
        apiKey!,
      );

      if (data['status'] == '200') {
        proposalUrl = data['response']['customer_url'];
        updateProposalState = NetworkState.loaded;
      } else {
        updateProposalErrorMessage =
            getErrorMessageFromResponse(data['response']);
        updateProposalState = NetworkState.error;
      }
    } catch (error) {
      updateProposalErrorMessage = 'Something went wrong. Please try again';
      updateProposalState = NetworkState.error;
    } finally {
      if (updateProposalState == NetworkState.error) {
        showToast(
          text: updateProposalErrorMessage,
        );
      }
      update([GetxId.updateProposal]);
    }
  }

  Map getCreateProposalPayload() {
    Map payload = {
      'agent_id': agentId,
      'user_id': selectedClient!.taxyID,
      'product_type_variant': product!.productVariant,
      'product_category': "Invest",
      'product_type': "UnlistedStock",
      'lumsum_amount': (shares! * sharePrice!).toStringAsFixed(2),
      'product_extras': {
        "sell_price": sharePrice,
        "units": shares,
        "min_stocks": (product!.minPurchaseAmount! / product!.minSellPrice!),
        "min_sell_price": product!.minSellPrice.toString(),
        "max_sell_price": product!.maxSellPrice.toString(),
        "min_purchase_amount": product!.minPurchaseAmount.toString()
      },
    };

    return payload;
  }

  Map getUpdateProposalPayload() {
    var productExtrasJson = {
      "sell_price": sharePrice,
      "units": shares,
      "min_stocks": (product!.minPurchaseAmount! / product!.minSellPrice!),
      "name": product!.title,
      "isin": product!.isin,
      "vendor": proposal!.productExtrasJson!['vendor'],
    };

    Map payload = {
      "agent_id": agentId,
      "lumsum_amount": shares! * sharePrice!,
      "product_extras": productExtrasJson
    };

    return payload;
  }

  Future<bool> addClientFromContacts() async {
    RestApiResponse clientCreatedResponse =
        await AddClientController().addClientFromContacts(selectedClient!);
    if (clientCreatedResponse.status == 1) {
      selectedClient = clientCreatedResponse.data;
      update([GetxId.createProposal]);
      return true;
    } else {
      // createProposalErrorMessage = clientCreatedResponse.message;
      createProposalState = NetworkState.cancel;
      return false;
    }
  }

  setSelectedClient(Client client) {
    selectedClient = client;
    update();
  }

  void resetPreIPOForm() {
    sharePriceController!.clear();
    sharePrice = 0;
    sharesController!.clear();
    shares = 0;
  }
}
