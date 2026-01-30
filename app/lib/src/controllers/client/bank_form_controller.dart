import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/clients/models/account_details_model.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/resources/client_list_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class ClientBankFormController extends GetxController {
  Client? client;

  ApiResponse bankFormResponse = ApiResponse();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  BankAccountModel? bankAccount = BankAccountModel();
  BankAccountModel? bankAccountResult;

  TextEditingController accountController = TextEditingController();
  TextEditingController ifscController = TextEditingController();

  String? accountType;

  bool isEditFlow = false;

  ClientBankFormController(this.client, this.bankAccount);

  @override
  void onInit() {
    if (bankAccount != null) {
      accountController.text = bankAccount?.number ?? '';
      ifscController.text = bankAccount?.ifsc ?? '';
      accountType = bankAccount?.accType;
      isEditFlow = bankAccount?.id.isNotNullOrEmpty ?? false;
    }

    super.onInit();
  }

  Future<void> addBankDetails() async {
    bankFormResponse.state = NetworkState.loading;
    update();

    try {
      QueryResult response;

      String apiKey = await getApiKey() ?? '';

      Map<String, dynamic> payload = {
        "number": accountController.text,
        "ifsc": ifscController.text,
        "accType": accountType
      };

      if (isEditFlow) {
        // Edit Bank Account
        payload["id"] = bankAccount?.id;
        response = await (ClientListRepository().updateBankAccount(
          apiKey,
          payload,
          client!.taxyID!,
        ));
      } else {
        // Create Bank Account
        response = await (ClientListRepository().createBankAccount(
          apiKey,
          payload,
          client!.taxyID!,
        ));
      }

      if (response.hasException) {
        bankFormResponse.state = NetworkState.error;
        bankFormResponse.message = response.exception!.graphqlErrors[0].message;
      } else {
        bankFormResponse.state = NetworkState.loaded;
        bankAccountResult = BankAccountModel.fromJson(response.data![isEditFlow
            ? "updateUserBankAccount"
            : "createUserBankAccount"]["bankAccount"]);
      }
    } catch (error) {
      bankFormResponse.state = NetworkState.error;
      bankFormResponse.message = 'Something went wrong';
    } finally {
      update();
    }
  }
}
