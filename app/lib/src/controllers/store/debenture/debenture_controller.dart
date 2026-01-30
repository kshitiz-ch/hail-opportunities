import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/client/add_client_controller.dart';
import 'package:core/main.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/common/models/api_response_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/store/models/debenture_model.dart';
import 'package:core/modules/store/models/demat_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
// ignore: implementation_imports
import 'package:intl/src/intl/date_format.dart';

class DebentureController extends GetxController {
  String? proposalUrl = '';
  TextEditingController noOfSecuritiesController = TextEditingController();

  DebentureModel? product;
  Client? selectedClient;
  bool hasClientCreated = false;
  List<DematModel> demats = [];

  bool showSecuritiesInput = false;
  bool disableDecrementSecurityButton = true;
  bool disableIncrementSecurityButton = false;
  int minimumSecurities = 1;

  bool isConfirmationDateNotElapsed = false;
  String? sellingPrice;
  double? totalAmount;
  String confirmationDateFormatted = '';

  DebentureModel? createProposalResponse;
  String createProposalErrorMessage = '';
  NetworkState createProposalState = NetworkState.cancel;

  DebentureController({this.product, this.selectedClient});

  @override
  void onInit() {
    checkIsConfirmationDateNotElapsed();
    checkSellingPrice();
    setInitialNumberOfSecurities();

    super.onInit();
  }

  @override
  void dispose() {
    noOfSecuritiesController.dispose();
    super.dispose();
  }

  checkShouldDisableSecurityButtons() {
    if (noOfSecuritiesController.text.isNotEmpty) {
      try {
        if (product!.lotCheckEnabled! &&
            double.parse(noOfSecuritiesController.text) ==
                product!.lotAvailable) {
          disableIncrementSecurityButton = true;
        } else {
          disableIncrementSecurityButton = false;
        }
      } catch (error) {
        LogUtil.printLog(error);
      }
    }

    if (noOfSecuritiesController.text.isNotEmpty) {
      try {
        if (int.parse(noOfSecuritiesController.text) == minimumSecurities) {
          disableDecrementSecurityButton = true;
        } else {
          disableDecrementSecurityButton = false;
        }
      } catch (error) {
        LogUtil.printLog(error);
      }
    }
  }

  setSelectedClient(client) {
    selectedClient = client;
    update();
  }

  checkIsConfirmationDateNotElapsed() {
    if (product?.confirmationDate != null) {
      final now = DateTime.now();
      DateTime confirmationDateParsed =
          DateTime.parse(product!.confirmationDate!);
      int difference = now.difference(confirmationDateParsed).inDays;
      if (difference <= 0) {
        isConfirmationDateNotElapsed = true;
      }
    }

    if (isConfirmationDateNotElapsed) {
      updateConfirmationDateFormatted();
    }

    update();
  }

  setInitialNumberOfSecurities() {
    try {
      minimumSecurities = (WealthyCast.toDouble(product!.minPurchaseAmount)! /
              WealthyCast.toDouble(product!.sellPrice)!)
          .ceil();
    } catch (error) {
      LogUtil.printLog(error);
    }

    noOfSecuritiesController.text = minimumSecurities.toString();
    updateTotalAmount();
    update();
  }

  checkSellingPrice() {
    if (isConfirmationDateNotElapsed) {
      sellingPrice = product!.confirmationAmount;
    } else {
      sellingPrice = product!.sellPrice;
    }

    update();
  }

  setshowSecuritiesInput() {
    showSecuritiesInput = true;
    update();
  }

  updateTotalAmount() {
    if (sellingPrice == null) {
      checkSellingPrice();
    }

    totalAmount =
        int.parse(noOfSecuritiesController.text) * double.parse(sellingPrice!);
  }

  updateNoOfSecurities({bool isIncrement = false}) {
    var newValue;
    if (isIncrement) {
      newValue = int.parse(noOfSecuritiesController.text) + 1;
    } else {
      newValue = int.parse(noOfSecuritiesController.text) - 1;
    }

    noOfSecuritiesController.text = newValue.toString();
    checkShouldDisableSecurityButtons();
    updateTotalAmount();

    update();
  }

  updateConfirmationDateFormatted() {
    try {
      if (product?.confirmationDate != null) {
        DateTime confirmationDateParsed =
            DateTime.parse(product!.confirmationDate!);
        confirmationDateFormatted =
            DateFormat('dd-MMM-yy').format(confirmationDateParsed);
        update();
      }
    } catch (error) {
      LogUtil.printLog(error);
    }
  }

  Future<void> createProposal() async {
    createProposalState = NetworkState.loading;
    update([GetxId.createProposal]);

    try {
      int? agentId = await getAgentId();
      String? apiKey = await getApiKey();

      Map<String, dynamic> extraDataMap = getPayloadExtraData();

      if (selectedClient?.isSourceContacts ?? false) {
        bool isClientCreated = await addClientFromContacts();
        if (!isClientCreated) return;
      }

      var data = await StoreRepository().addProposals(
        agentId!,
        selectedClient!.taxyID!,
        product!.productVariant.toString(),
        apiKey!,
        extraDataMap,
      );

      if (data['status'] == "200") {
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

  Map<String, dynamic> getPayloadExtraData() {
    return {
      "lumsum_amount": totalAmount,
      "product_category": product!.category,
      "product_extras": {
        "units": int.parse(noOfSecuritiesController.text),
      },
      "product_type": product!.productType,
      "product_type_variant": product!.productVariant
    };
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
}
