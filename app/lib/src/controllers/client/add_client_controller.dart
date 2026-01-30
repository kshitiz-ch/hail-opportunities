import 'dart:convert';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/firebase/firebase_event_service.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/resources/client_list_repository.dart';
import 'package:core/modules/common/models/api_response_model.dart';
import 'package:core/modules/common/resources/common_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class AddClientController extends GetxController {
  TextEditingController? phoneNumberController;
  TextEditingController? emailController;
  TextEditingController? nameController;

  String? countryCode = indiaCountryCode;

  Client? clientAdded;

  NetworkState? addClientState;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    addClientState = NetworkState.cancel;
    phoneNumberController = TextEditingController();
    emailController = TextEditingController();
    nameController = TextEditingController();

    super.onInit();
  }

  @override
  void dispose() {
    phoneNumberController!.dispose();
    emailController!.dispose();
    nameController!.dispose();

    super.dispose();
  }

  Future<void> addClient(onClientAdded) async {
    if (formKey.currentState!.validate()) {
      try {
        addClientState = NetworkState.loading;
        update(['add-client']);

        String apiKey = (await getApiKey())!;

        QueryResult response = await ClientListRepository().addClient(
          apiKey,
          emailController!.text,
          emailController!.text.isEmpty,
          nameController!.text.trim(),
          '($countryCode)${phoneNumberController!.text}',
          'Partner-App',
        );

        if (response.hasException) {
          String message = response.exception!.graphqlErrors[0].message;

          showToast(text: message);

          addClientState = NetworkState.error;
        } else {
          final data = response.data!;
          clientAdded = Client.fromJson(data['createAgentClient']['client']);
          showToast(text: "Client Added Successfully");

          await sendClientsCountAnalytics(apiKey);

          await onClientAdded(clientAdded, true);

          addClientState = NetworkState.loaded;
        }
      } catch (error) {
        showToast(
          text: "Could not add the client. Please try again",
        );
        addClientState = NetworkState.error;
      } finally {
        update(['add-client']);
      }
    }
  }

  Future<RestApiResponse> addClientFromContacts(Client clientToAdd) async {
    RestApiResponse result = RestApiResponse();

    try {
      String apiKey = (await getApiKey())!;
      String phoneNumber = sanitizePhoneNumber(clientToAdd.phoneNumber);

      var response = await ClientListRepository().addClient(
        apiKey,
        '',
        true,
        clientToAdd.name ?? '',
        // Add client from contact is only available for indian phone numbers
        '($indiaCountryCode)$phoneNumber',
        'Other',
      );

      await Future.delayed(Duration(seconds: 1));

      if (response.exception != null &&
          response.exception.graphqlErrors.length > 0) {
        String message = response.exception.graphqlErrors[0]?.message ??
            "Could not add the client. Please try again";
        showToast(
          text: message,
        );
        result.message = message;
        result.status = 0;
      } else {
        final data = response.data;
        Client client = Client.fromJson(data['createAgentClient']['client']);
        await sendClientsCountAnalytics(apiKey);

        result.data = client;
        result.status = 1;
      }
    } catch (error) {
      result.status = 0;
      result.message = 'Something went wrong. Please try again';
    }

    return result;
  }

  Future<void> sendClientsCountAnalytics(String apiKey) async {
    try {
      final agentExternalId = await getAgentExternalId() ?? '';

      final filters = [
        if (agentExternalId.isNotEmpty)
          {
            "key": "agent_external_id",
            "operation": "eq",
            "value": agentExternalId
          },
      ];

      final payload = {
        "q": "",
        "page": "1",
        "per_page": "1",
        "sort_by": "created_at",
        "sort_reverse": "false",
        "pt": "user_profile",
        "platform": "partner-app",
        "filters": jsonEncode(filters),
      };

      final response =
          await CommonRepository().universalSearch(apiKey, payload);

      final status = WealthyCast.toInt(response["status"]);

      final isSuccess = status != null && (status ~/ 100) == 2;

      if (isSuccess) {
        final totalCount = WealthyCast.toInt(
            response?['response']?['user_profiles']?['meta']?['total_count']);

        FirebaseEventService.logEvent(
          'WL_Resp_CL_Add_Resp_Succ',
          parameters: {'client_count': totalCount!},
        );
      }
    } catch (error) {
      LogUtil.printLog(error.toString());
    }
  }
}
