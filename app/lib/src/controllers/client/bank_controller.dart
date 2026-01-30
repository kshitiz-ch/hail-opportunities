import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/clients/models/account_details_model.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/client_mandate_model.dart';
import 'package:core/modules/clients/models/client_profile_model.dart';
import 'package:core/modules/clients/resources/client_profile_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class ClientBankController extends GetxController {
  ApiResponse bankAccountsResponse = ApiResponse();
  ApiResponse setBankPrimaryResponse = ApiResponse();
  ClientMfProfileModel? clientMfProfile;
  Client? client;

  List<BankAccountModel> userBankAccounts = [];
  BankAccountModel? userBrokingBankAccount;
  List<ClientMandateModel> mandates = [];
  BankAccountModel? mfBankAccount;

  void onInit() {
    getClientBankAccounts();
    super.onInit();
  }

  ClientBankController(this.client);

  Future<dynamic> getClientBankAccounts() async {
    bankAccountsResponse.state = NetworkState.loading;
    userBankAccounts.clear();
    update();

    try {
      String apiKey = await getApiKey() ?? '';
      QueryResult response = await ClientProfileRepository()
          .getClientBankAccounts(apiKey, client?.taxyID ?? '');

      if (response.hasException) {
        bankAccountsResponse.state = NetworkState.error;
        bankAccountsResponse.message =
            response.exception!.graphqlErrors[0].message;
      } else {
        var data = response.data!["hagrid"];

        if (data["wealthyMfProfile"] != null) {
          clientMfProfile =
              ClientMfProfileModel.fromJson(data["wealthyMfProfile"]);
        }

        List userBankAccountsJson =
            WealthyCast.toList(data["userBankAccounts"]);

        userBankAccountsJson.forEach((bank) {
          BankAccountModel bankAccountModel = BankAccountModel.fromJson(bank);
          if (bankAccountModel.id == clientMfProfile?.defaultBankAccountId) {
            mfBankAccount = BankAccountModel.fromJson(bank);
          }

          userBankAccounts.add(bankAccountModel);
        });

        // Fetch broking bank accounts
        await fetchBrokingAccounts();

        // Disabled for now since separate mandate list is added
        // await getClientMandates();

        bankAccountsResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      bankAccountsResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> fetchBrokingAccounts() async {
    try {
      String apiKey = await getApiKey() ?? '';
      QueryResult response = await ClientProfileRepository()
          .getClientBrokingBankAccounts(apiKey, client?.taxyID ?? '');

      if (!response.hasException) {
        var data = response.data!["hagrid"];

        String defaultBankAccountId =
            data["wealthyBrokingProfile"]["defaultBankAccountId"];

        List userBrokingBankAccountsJson =
            WealthyCast.toList(data["userBrokingBankAccounts"]);

        for (var bankJson in userBrokingBankAccountsJson) {
          BankAccountModel brokingBankAccount =
              BankAccountModel.fromJson(bankJson);
          if (brokingBankAccount.id == defaultBankAccountId) {
            userBrokingBankAccount = brokingBankAccount;
            break;
          }
        }

        // userBrokingBankAccountsJson.forEach((bank) {
        //   userBrokingBankAccounts.add(BankAccountModel.fromJson(bank));
        // });
      }
    } catch (error) {
      LogUtil.printLog(error.toString());
    }
  }

  Future<void> getClientMandates() async {
    mandates.clear();
    try {
      String apiKey = await getApiKey() ?? '';
      QueryResult response = await ClientProfileRepository().getClientMandates(
        apiKey: apiKey,
        userId: client?.taxyID ?? '',
      );

      if (!response.hasException) {
        List mandatesJson = response.data!["taxy"]["mandates"];
        mandatesJson.forEach((element) {
          ClientMandateModel mandate = ClientMandateModel.fromJson(element);

          if (mandate.paymentBankAccountNumber != null) {
            assignBankAccountMandateStatus(mandate);
          }

          mandates.add(mandate);
        });
      }
    } catch (error) {
      LogUtil.printLog(error.toString());
    } finally {
      update();
    }
  }

  void assignBankAccountMandateStatus(ClientMandateModel mandate) {
    for (BankAccountModel bankAccount in userBankAccounts) {
      if (mandate.paymentBankAccountNumber == bankAccount.number) {
        bankAccount.isMandateCompleted = true;
        break;
      }
    }

    if (mandate.paymentBankAccountNumber == mfBankAccount?.number) {
      mfBankAccount?.isMandateCompleted = true;
    }

    if (mandate.paymentBankAccountNumber == userBrokingBankAccount?.number) {
      userBrokingBankAccount?.isMandateCompleted = true;
    }
  }

  Future<void> setDefaultBankAccount(String bankId) async {
    setBankPrimaryResponse.state = NetworkState.loading;
    update(["set-bank-primary"]);

    try {
      String apiKey = await getApiKey() ?? '';
      QueryResult response = await ClientProfileRepository()
          .setDefaultBankAccount(apiKey,
              clientId: client?.taxyID ?? '', bankId: bankId);

      if (response.hasException) {
        setBankPrimaryResponse.state = NetworkState.error;
        setBankPrimaryResponse.message =
            response.exception!.graphqlErrors[0].message;
      } else {
        setBankPrimaryResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      setBankPrimaryResponse.state = NetworkState.error;
      setBankPrimaryResponse.message = 'Something went wrong. Please try again';
    } finally {
      update(["set-bank-primary"]);
    }
  }
}
