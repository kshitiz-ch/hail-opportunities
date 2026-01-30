import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/main.dart';
import 'package:core/modules/clients/models/account_details_model.dart';
import 'package:core/modules/clients/models/client_mandate_model.dart';
import 'package:core/modules/clients/models/mandate_option_model.dart';
import 'package:core/modules/clients/resources/client_profile_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

enum ProposalFormView { SelectBank, Amount }

class ClientMandateController extends GetxController {
  final Client client;
  ApiResponse mandates = ApiResponse();
  ApiResponse bankAccountsResponse = ApiResponse();

  ApiResponse proposalResponse = ApiResponse();
  String? proposalUrl;

  List<ClientMandateModel> mandateList = [];
  List<BankAccountModel> userBankAccounts = [];

  ProposalFormView proposalFormView = ProposalFormView.SelectBank;
  BankAccountModel? selectedBank;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController amountController = TextEditingController();

  MandateOptionModel? mandateOptionModel;
  ApiResponse mandateOptionResponse = ApiResponse();

  ClientMandateController(this.client);

  @override
  void onInit() async {
    getMandateOption();
    getClientBankAccounts();
    getClientMandates();
    super.onInit();
  }

  @override
  void onReady() async {}

  @override
  void dispose() {
    super.dispose();
  }

  Future<dynamic> getClientBankAccounts() async {
    bankAccountsResponse.state = NetworkState.loading;
    userBankAccounts.clear();
    update([GetxId.bank]);

    try {
      String apiKey = await getApiKey() ?? '';
      QueryResult response = await ClientProfileRepository()
          .getClientBankAccounts(apiKey, client.taxyID ?? '');

      if (response.hasException) {
        bankAccountsResponse.state = NetworkState.error;
        bankAccountsResponse.message =
            response.exception!.graphqlErrors[0].message;
      } else {
        var data = response.data!["hagrid"];
        List userBankAccountsJson =
            WealthyCast.toList(data["userBankAccounts"]);

        userBankAccountsJson.forEach((bank) {
          BankAccountModel bankAccountModel = BankAccountModel.fromJson(bank);

          int bankVerificationFailedStatus = 6;
          if (bankAccountModel.bankVerifiedStatus !=
              bankVerificationFailedStatus) {
            userBankAccounts.add(bankAccountModel);
          }
        });

        bankAccountsResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      bankAccountsResponse.state = NetworkState.error;
    } finally {
      update([GetxId.bank]);
    }
  }

  Future<void> getClientMandates() async {
    mandates.state = NetworkState.loading;
    update();

    try {
      String apiKey = await getApiKey() ?? '';
      QueryResult response = await ClientProfileRepository().getClientMandates(
        apiKey: apiKey,
        userId: client.taxyID!,
      );

      if (response.hasException) {
        mandates.message = response.exception!.graphqlErrors[0].message;
        mandates.state = NetworkState.error;
      } else {
        mandateList = WealthyCast.toList(response.data!['taxy']['userMandates'])
            .map((mandateJson) => ClientMandateModel.fromJson(mandateJson))
            .toList();
        mandateList.sort(
          (a, b) {
            return a.statusText == 'Active'
                ? -1
                : b.statusText == 'Active'
                    ? 1
                    : 0;
          },
        );
        mandates.state = NetworkState.loaded;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      mandates.message = 'Something went wrong';
      mandates.state = NetworkState.error;
    } finally {
      update();
    }
  }

  void updateProposalFormView(ProposalFormView newFormView) {
    proposalFormView = newFormView;
    update([GetxId.proposal]);
  }

  void updateSelectedBank(BankAccountModel bank) {
    selectedBank = bank;
    update([GetxId.proposal]);
  }

  Future<void> getMandateOption() async {
    mandateOptionResponse.state = NetworkState.loading;
    update();

    try {
      String apiKey = await getApiKey() ?? '';
      final payload = {"amount": 10000};
      final data =
          await ClientProfileRepository().getMandateOptions(apiKey, payload);

      if (data['status'] == "200") {
        mandateOptionModel = MandateOptionModel.fromJson(data['response']);
        mandateOptionResponse.state = NetworkState.loaded;
      } else {
        mandateOptionResponse.message =
            getErrorMessageFromResponse(data['response']);
        mandateOptionResponse.state = NetworkState.error;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      mandateOptionResponse.message = 'Something went wrong';
      mandateOptionResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> createProposal() async {
    proposalResponse.state = NetworkState.loading;
    update([GetxId.proposal]);

    try {
      int amount =
          WealthyCast.toInt(amountController.text.replaceAll(",", "")) ?? 0;
      Map<String, dynamic> payload = {
        "user_id": client.taxyID,
        "bank_account_id": selectedBank?.id,
        "bank_account": {
          "bank_verified_name": selectedBank?.bank,
          "ifsc": selectedBank?.ifsc,
          "acc_type": selectedBank?.accType,
          "number": selectedBank?.number
        },
        "amount": amount
      };

      String apiKey = await getApiKey() ?? '';
      var data =
          await ClientProfileRepository().shareMandateProposal(apiKey, payload);

      if (data['status'] == "200") {
        proposalUrl = data['response']?['customer_url'];
        proposalResponse.state = NetworkState.loaded;
      } else {
        proposalResponse.message =
            getErrorMessageFromResponse(data['response']);
        proposalResponse.state = NetworkState.error;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      proposalResponse.message = 'Something went wrong';
      proposalResponse.state = NetworkState.error;
    } finally {
      update([GetxId.proposal]);
    }
  }
}
