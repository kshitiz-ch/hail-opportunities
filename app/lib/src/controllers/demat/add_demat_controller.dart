import 'dart:convert';
import 'dart:io';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:core/main.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:graphql/client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddDematController extends GetxController {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  NetworkState? addDematState;

  String? apiKey = '';
  String addDematErrorMessage = '';

  TextEditingController? dpIdController;
  TextEditingController? clientIdController;

  FocusNode? clientIdFocusNode;

  String? fileName;
  List<PlatformFile>? _paths;
  FileType _pickingType = FileType.custom;

  @override
  void onInit() {
    addDematState = NetworkState.cancel;

    dpIdController = TextEditingController();
    clientIdController = TextEditingController();

    clientIdFocusNode = FocusNode();

    super.onInit();
  }

  @override
  void onReady() async {
    final SharedPreferences sharedPreferences = await prefs;
    apiKey = sharedPreferences.getString('apiKey');

    super.onReady();
  }

  @override
  void dispose() {
    dpIdController!.dispose();
    clientIdController!.dispose();

    clientIdFocusNode!.dispose();

    super.dispose();
  }

  Future<void> addDematAccount(Client? client) async {
    if (formKey.currentState!.validate()) {
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

      try {
        await _createDematAccount(client!, body);

        if (addDematState == NetworkState.loaded) {
          showToast(
            text: 'Demat Account Added',
          );
        } else {
          showToast(
            text: addDematErrorMessage,
          );
        }
      } catch (error) {
        showToast(
          text: 'Something went wrong',
        );
      } finally {
        update(['add-demat']);
      }
    }
  }

  /// Create a new Demat account for the client by callign the API
  Future<void> _createDematAccount(Client client, Map body) async {
    addDematState = NetworkState.loading;
    update(['add-demat']);
    try {
      QueryResult response = await (StoreRepository()
          .createDematAccount(client.taxyID!, body, apiKey!));

      if (response.hasException) {
        addDematState = NetworkState.error;
        addDematErrorMessage = response.exception!.graphqlErrors[0].message;
      } else {
        addDematState = NetworkState.loaded;
      }
    } catch (error) {
      addDematState = NetworkState.error;
      addDematErrorMessage = 'Something went wrong';
    }
  }

  /// Opens File Explorer app and let user select a file
  void openFileExplorer() async {
    try {
      _paths = (await FilePicker.platform.pickFiles(
        type: _pickingType,
        allowMultiple: false,
        allowedExtensions: ['jpg', 'pdf', 'doc', 'png'],
      ))
          ?.files;
    } on PlatformException {
      showToast(
        text: 'please allow storage permission',
      );
    } catch (error) {
      LogUtil.printLog(error);
    }

    if (_paths != null) {
      if (_paths?.first.name != null && _paths!.first.name.length > 18) {
        fileName = _paths!.first.name.substring(0, 20) +
            '...' +
            _paths!.first.extension!;
      } else {
        fileName = _paths!.first.name;
      }

      update(['add-demat-sc']);
    }
  }

  void deleteSelectedFile() {
    _paths = null;
    fileName = null;
    update(['add-demat-sc']);
  }

  String _convertFileTobase64(filePath) {
    final bytes = File(filePath).readAsBytesSync();
    return base64Encode(bytes);
  }
}
