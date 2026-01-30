import 'dart:async';

import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/client_profile_model.dart';
import 'package:core/modules/clients/resources/client_list_repository.dart';
import 'package:core/modules/clients/models/account_details_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class BankDetailsFormController extends GetxController {
  // Fields
  final GlobalKey<FormState> bankDetailsFormKey = GlobalKey<FormState>();

  final Client? client;
  ClientAccountModel? accountDetails;

  String? apiKey;

  TextEditingController? accountNumberController;
  TextEditingController? ifscController;
  String? accountType;

  NetworkState? addBankDetailsState;
  NetworkState? ifscState;

  BankAccountModel bankAccountResult = BankAccountModel();
  String addBankDetailsErrorMessage = '';
  String ifscErrorMessage = '';

  Timer? _debounce;

  // Constructor
  BankDetailsFormController(this.client, this.accountDetails);

  @override
  void onInit() {
    addBankDetailsState = NetworkState.cancel;

    // Initialize accountDetails if null to prevent null errors later
    if (accountDetails != null &&
        (accountDetails?.bankAccounts.isNotNullOrEmpty ?? false)) {
      accountNumberController = TextEditingController(
          text: accountDetails?.bankAccounts!.first.number);
      ifscController =
          TextEditingController(text: accountDetails?.bankAccounts!.first.ifsc);

      accountType = accountDetails!.bankAccounts!.first.accountType;

      bankAccountResult = accountDetails!.bankAccounts!.first;

      if (accountDetails!.bankAccounts!.first.number.isNotNullOrEmpty &&
          accountDetails!.bankAccounts!.first.ifsc.isNotNullOrEmpty) {
        ifscState = NetworkState.loaded;
      }
    } else {
      accountNumberController = TextEditingController();
      ifscController = TextEditingController();
    }

    super.onInit();
  }

  @override
  void onReady() async {
    apiKey = await getApiKey();

    super.onReady();
  }

  @override
  void dispose() {
    _debounce?.cancel();

    accountNumberController!.dispose();
    ifscController!.dispose();

    super.dispose();
  }

  Future<void> updateIfsc() async {
    ifscState = NetworkState.loading;
    update();

    try {
      QueryResult response;
      String bankAccountId = bankAccountResult.id ?? '';

      Map<String, dynamic> payload = {
        "number": accountNumberController?.text ?? '',
        "ifsc": ifscController?.text ?? ''
      };

      if (bankAccountId.isNullOrEmpty) {
        // createBankAccount
        response = await (ClientListRepository().createBankAccount(
          apiKey!,
          payload,
          client!.taxyID!,
        ));
      } else {
        payload["id"] = bankAccountId;
        response = await (ClientListRepository().updateBankAccount(
          apiKey!,
          payload,
          client!.taxyID!,
        ));
      }

      if (response.hasException) {
        ifscState = NetworkState.error;
        ifscErrorMessage = response.exception!.graphqlErrors[0].message;
      } else {
        bankAccountResult = BankAccountModel.fromJson(response.data![
            bankAccountId.isNullOrEmpty
                ? "createUserBankAccount"
                : "updateUserBankAccount"]["bankAccount"]);
        ifscState = NetworkState.loaded;
      }
    } catch (error) {
      ifscState = NetworkState.error;
      ifscErrorMessage = 'Something went wrong';
    } finally {
      update();
    }
  }

  Future<void> addBankDetails() async {
    addBankDetailsState = NetworkState.loading;
    update();

    try {
      QueryResult response;
      String bankAccountId = bankAccountResult.id ?? '';

      Map<String, dynamic> payload = {
        "number": accountNumberController?.text ?? '',
        "ifsc": ifscController?.text ?? '',
        "accType": accountType
      };

      if (bankAccountId.isNullOrEmpty) {
        // createBankAccount
        response = await (ClientListRepository().createBankAccount(
          apiKey!,
          payload,
          client!.taxyID!,
        ));
      } else {
        payload["id"] = bankAccountId;
        response = await (ClientListRepository().updateBankAccount(
          apiKey!,
          payload,
          client!.taxyID!,
        ));
      }

      if (response.hasException) {
        addBankDetailsState = NetworkState.error;
        addBankDetailsErrorMessage =
            response.exception!.graphqlErrors[0].message;
      } else {
        bankAccountResult = BankAccountModel.fromJson(response.data![
            bankAccountId.isNullOrEmpty
                ? "createUserBankAccount"
                : "updateUserBankAccount"]["bankAccount"]);
        addBankDetailsState = NetworkState.loaded;
      }
    } catch (error) {
      addBankDetailsState = NetworkState.error;
      addBankDetailsErrorMessage = 'Something went wrong';
    } finally {
      update();
    }
  }
}
