import 'dart:convert';
import 'dart:io';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/wealthy_demat_model.dart';
import 'package:core/modules/clients/resources/client_profile_repository.dart';
import 'package:core/modules/store/models/demat_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class ClientDematController extends GetxController {
  final Client client;
  String? apiKey = '';

  ApiResponse wealthyDemat = ApiResponse();
  ApiResponse externalDemat = ApiResponse();
  WealthyDematModel? wealthyDematModel;
  List<DematModel> externalDematList = [];

  GlobalKey<FormState>? addEditDematFormKey;
  ApiResponse addEditDemat = ApiResponse();
  TextEditingController? dpIdController;
  TextEditingController? clientIdController;
  FocusNode? clientIdFocusNode;
  String? fileName;
  List<PlatformFile>? _paths;
  FileType filePickerType = FileType.custom;

  ClientDematController(this.client);

  @override
  void onInit() {
    wealthyDemat.state = NetworkState.loading;

    super.onInit();
  }

  @override
  void onReady() async {
    apiKey = await getApiKey();
    getWealthyDemat();
    getExternalDemats();
    super.onReady();
  }

  @override
  void dispose() {
    dpIdController!.dispose();
    clientIdController!.dispose();

    clientIdFocusNode!.dispose();

    super.dispose();
  }

  Future<dynamic> getWealthyDemat() async {
    wealthyDemat.state = NetworkState.loading;
    update();

    try {
      QueryResult response = await ClientProfileRepository()
          .getClientWealthyDematDetail(apiKey!, client.taxyID!);

      if (response.hasException) {
        wealthyDemat.message = response.exception!.graphqlErrors[0].message;
        wealthyDemat.state = NetworkState.error;
      } else {
        if (response.data!['hagrid']['wealthyBrokingProfile'] != null) {
          wealthyDematModel = WealthyDematModel.fromJson(
            response.data!['hagrid']['wealthyBrokingProfile'],
          );
        }

        wealthyDemat.state = NetworkState.loaded;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      wealthyDemat.message = 'Something went wrong';
      wealthyDemat.state = NetworkState.error;
    } finally {
      update();
    }
  }

  // TODO:
  // update when moved to hagrid
  Future<void> getExternalDemats() async {
    try {
      externalDemat.state = NetworkState.loading;
      update();
      QueryResult response = await (ClientProfileRepository()
          .getDematAccounts(client.taxyID!, apiKey!));

      if (response.hasException) {
        externalDemat.message = response.exception!.graphqlErrors[0].message;
        externalDemat.state = NetworkState.error;
      } else {
        externalDematList = (response.data!['taxy']['tradingAccounts'] as List)
            .map((externalDematJson) => DematModel.fromJson(externalDematJson))
            .toList();
        externalDemat.state = NetworkState.loaded;
      }
    } catch (error) {
      externalDemat.state = NetworkState.error;
      externalDemat.message = 'Something went wrong';
    } finally {
      update();
    }
  }

  void initDematInputForm({int? editIndex}) {
    addEditDematFormKey = GlobalKey<FormState>();
    dpIdController = editIndex == null
        ? TextEditingController()
        : TextEditingController(text: externalDematList[editIndex].dpid);
    // dp id + client id = demat id
    clientIdController = editIndex == null
        ? TextEditingController()
        : TextEditingController(
            text: externalDematList[editIndex].dematId?.substring(8),
          );
    fileName = null;
    _paths = null;
    filePickerType = FileType.custom;
    clientIdFocusNode = FocusNode();
  }

  Future<void> addEditDematAccount({int? editIndex}) async {
    if (addEditDematFormKey!.currentState!.validate()) {
      if (_paths == null) {
        return showToast(
          text: "Please attach screenshot",
        );
      }

      String fileBase64 = _convertFileTobase64(_paths!.first.path);
      Map body = {
        'dematId':
            dpIdController!.text.toUpperCase() + clientIdController!.text,
        'content': fileBase64
      };
      if (editIndex != null) {
        body['tradingAccountId'] =
            externalDematList[editIndex].tradingAccountId;
      }

      try {
        await _createEditDematAccount(body, editIndex != null);

        if (addEditDemat.state == NetworkState.loaded) {
          showToast(
            text: 'Demat Account "${editIndex == null ? 'Added' : 'Updated'} "',
          );
        } else {
          showToast(
            text: addEditDemat.message,
          );
        }
      } catch (error) {
        showToast(
          text: 'Something went wrong',
        );
      } finally {
        update();
      }
    }
  }

  /// Create a new Demat account for the client by callign the API
  Future<void> _createEditDematAccount(Map body, bool isEdit) async {
    addEditDemat.state = NetworkState.loading;
    update();
    try {
      QueryResult response;
      if (isEdit) {
        response = await (ClientProfileRepository()
            .editDematAccount(client.taxyID!, body, apiKey!));
      } else {
        response = await (ClientProfileRepository()
            .createDematAccount(client.taxyID!, body, apiKey!));
      }

      if (response.hasException) {
        addEditDemat.state = NetworkState.error;
        addEditDemat.message = response.exception!.graphqlErrors[0].message;
      } else {
        addEditDemat.state = NetworkState.loaded;
      }
    } catch (error) {
      addEditDemat.state = NetworkState.error;
      addEditDemat.message = 'Something went wrong';
    }
  }

  /// Opens File Explorer app and let user select a file
  void openFileExplorer() async {
    try {
      _paths = (await FilePicker.platform.pickFiles(
        type: filePickerType,
        allowMultiple: false,
        allowedExtensions: ['jpg', 'pdf', 'doc', 'png'],
      ))
          ?.files;
    } on PlatformException {
      showToast(
        text: 'please allow storage permission',
      );
    } catch (error) {
      LogUtil.printLog(error.toString());
    }

    if (_paths != null) {
      if (_paths?.first.name != null && _paths!.first.name.length > 18) {
        fileName = _paths!.first.name.substring(0, 20) +
            '...' +
            _paths!.first.extension!;
      } else {
        fileName = _paths!.first.name;
      }

      update();
    }
  }

  void deleteSelectedFile() {
    _paths = null;
    fileName = null;
    update();
  }

  String _convertFileTobase64(filePath) {
    final bytes = File(filePath).readAsBytesSync();
    return base64Encode(bytes);
  }

  void resetDematForm() {
    dpIdController?.clear();
    clientIdController?.clear();
    addEditDemat.state = NetworkState.cancel;
    update();
  }
}
