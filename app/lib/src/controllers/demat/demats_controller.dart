import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/clients/models/account_details_model.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/resources/client_profile_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/store/models/demat_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:graphql/client.dart';

class DematsController extends GetxController {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? apiKey = '';

  Client? client;
  List<DematModel> demats = [];
  List<BankAccountModel> userBankAccounts = [];
  // AccountDetailsModel accountDetailsResult = AccountDetailsModel();

  NetworkState? dematsState;
  ApiResponse bankDetailsResponse = ApiResponse();

  String dematsErrorMessage = '';
  String accountDetailsErrorMessage = '';

  DematsController({required this.client});

  // Getters
  bool get isBankAccountExists {
    return userBankAccounts.isNotEmpty;
  }

  bool get isDematAccountExists => demats.isNotEmpty;

  @override
  void onInit() {
    dematsState = NetworkState.loading;
    bankDetailsResponse.state = NetworkState.loading;

    super.onInit();
  }

  @override
  void onReady() async {
    apiKey = await getApiKey();
    getClientankAccounts(client!);
    getDematAccounts(client!);
  }

  Future<void> getDematAccounts(Client client, {bool isRetry = false}) async {
    try {
      if (isRetry) {
        dematsState = NetworkState.loading;
        update();
      }
      QueryResult response =
          await (StoreRepository().getDematAccounts(client.taxyID!, apiKey!));

      if (response.hasException) {
        dematsErrorMessage = response.exception!.graphqlErrors[0].message;
        dematsState = NetworkState.error;
      } else {
        List result = response.data!['taxy']['tradingAccounts'];
        List<DematModel> dematModels = [];
        result.forEach((demat) {
          dematModels.add(DematModel.fromJson(demat));
        });
        demats = dematModels;
        dematsState = NetworkState.loaded;
      }
    } catch (error) {
      dematsState = NetworkState.error;
      dematsErrorMessage = 'Something went wrong';
    } finally {
      update();
    }
  }

  Future<void> getClientankAccounts(Client client) async {
    userBankAccounts.clear();

    try {
      QueryResult response = await ClientProfileRepository()
          .getClientBankAccounts(apiKey!, client.taxyID!);
      if (!response.hasException) {
        var data = response.data!["hagrid"];
        List userBankAccountsJson =
            WealthyCast.toList(data["userBankAccounts"]);

        userBankAccountsJson.forEach((bank) {
          userBankAccounts.add(BankAccountModel.fromJson(bank));
        });
        bankDetailsResponse.state = NetworkState.loaded;
      } else {
        bankDetailsResponse.state = NetworkState.error;
      }
    } catch (error) {
      accountDetailsErrorMessage = 'Something went wrong';
      bankDetailsResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }
}
