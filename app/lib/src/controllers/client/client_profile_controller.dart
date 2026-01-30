import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/resources/client_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class ClientProfileController extends GetxController {
  ApiResponse deleteClientResponse = ApiResponse();
  Client? client;

  TextEditingController deleteTextController = TextEditingController();

  ClientProfileController({this.client});

  Future<void> deleteClient() async {
    deleteClientResponse.state = NetworkState.loading;

    update([GetxId.delete]);

    try {
      String apiKey = await getApiKey() ?? '';
      QueryResult response = await ClientProfileRepository()
          .deleteClient(apiKey, client?.id ?? '');
      if (response.hasException) {
        deleteClientResponse.state = NetworkState.error;
        deleteClientResponse.message =
            response.exception!.graphqlErrors[0].message;
      } else {
        deleteClientResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      deleteClientResponse.state = NetworkState.error;
      deleteClientResponse.message = genericErrorMessage;
    } finally {
      update([GetxId.delete]);
    }
  }
}
