import 'dart:convert';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/config/string_utils.dart';
import 'package:core/modules/clients/models/client_address_model.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/resources/client_profile_repository.dart';
import 'package:core/modules/common/models/country_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class ClientAddressController extends GetxController {
  final Client client;
  String? apiKey;
  ApiResponse fetchAddress = ApiResponse();
  ApiResponse addEditAddress = ApiResponse();
  ApiResponse deleteAddress = ApiResponse();

  final int addressLineMaxLength = 40;

  TextEditingController? addressline1InputController;
  TextEditingController? addressline2InputController;
  TextEditingController? addressline3InputController;
  TextEditingController? stateInputController;
  TextEditingController? cityInputController;
  TextEditingController? pincodeInputController;
  TextEditingController? countryInputController;
  TextEditingController? addressTitleController;

  GlobalKey<FormState> addressFormKey = GlobalKey<FormState>();

  List<ClientAddressModel> clientAddressModelList = <ClientAddressModel>[];
  List<CountryModel> countries = [];
  int? selectedCountryIndex;
  int? selectedStateIndex;

  ClientAddressController(this.client);

  bool get isInputFieldEmpty =>
      addressline1InputController!.text.isNullOrEmpty &&
      addressline2InputController!.text.isNullOrEmpty &&
      stateInputController!.text.isNullOrEmpty &&
      cityInputController!.text.isNullOrEmpty &&
      pincodeInputController!.text.isNullOrEmpty &&
      countryInputController!.text.isNullOrEmpty;

  @override
  void onInit() async {
    fetchAddress.state = NetworkState.loading;
    getCountriesData();
    super.onInit();
  }

  @override
  void onReady() async {
    apiKey = await getApiKey();
    getClientAddressDetail();
    super.onReady();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<dynamic> getClientAddressDetail() async {
    fetchAddress.state = NetworkState.loading;
    update();

    try {
      QueryResult response = await ClientProfileRepository()
          .getClientAddressDetail(apiKey!, client.taxyID!);

      if (response.hasException) {
        fetchAddress.message = response.exception!.graphqlErrors[0].message;
        fetchAddress.state = NetworkState.error;
      } else {
        if (response.data!['hagrid']['userAddresses'] != null) {
          clientAddressModelList =
              (response.data!['hagrid']['userAddresses'] as List)
                  .map<ClientAddressModel>(
                    (userAddressJson) =>
                        ClientAddressModel.fromJson(userAddressJson),
                  )
                  .toList();
        } else {
          clientAddressModelList = <ClientAddressModel>[];
        }

        fetchAddress.state = NetworkState.loaded;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      fetchAddress.message = 'Something went wrong';
      fetchAddress.state = NetworkState.error;
    } finally {
      update();
    }
  }

  void initInputController({int? editIndex}) {
    addressFormKey = GlobalKey<FormState>();
    addressline1InputController = editIndex != null
        ? TextEditingController(text: clientAddressModelList[editIndex].line1)
        : TextEditingController();
    addressline2InputController = editIndex != null
        ? TextEditingController(text: clientAddressModelList[editIndex].line2)
        : TextEditingController();
    addressline3InputController = editIndex != null
        ? TextEditingController(text: clientAddressModelList[editIndex].line3)
        : TextEditingController();
    stateInputController = editIndex != null
        ? TextEditingController(
            text: clientAddressModelList[editIndex].state != null
                ? clientAddressModelList[editIndex].state.toTitleCase()
                : '')
        : TextEditingController();
    cityInputController = editIndex != null
        ? TextEditingController(
            text: clientAddressModelList[editIndex].city != null
                ? clientAddressModelList[editIndex].city.toTitleCase()
                : '')
        : TextEditingController();
    pincodeInputController = editIndex != null
        ? TextEditingController(text: clientAddressModelList[editIndex].pincode)
        : TextEditingController();
    countryInputController = editIndex != null
        ? TextEditingController(
            text: clientAddressModelList[editIndex].country != null
                ? clientAddressModelList[editIndex].country.toTitleCase()
                : '')
        : TextEditingController();
    addressTitleController = editIndex != null
        ? TextEditingController(text: clientAddressModelList[editIndex].title)
        : TextEditingController();

    if (editIndex != null) {
      updateCountryIndex();
      updateStateIndex();
    } else {
      selectedCountryIndex = null;
      selectedStateIndex = null;
    }

    update();
  }

  Future<String> addClientAddress() async {
    String addedAddressId = '';
    addEditAddress.state = NetworkState.loading;
    update();

    try {
      QueryResult response = await ClientProfileRepository().addClientAddress(
        apiKey!,
        client.taxyID!,
        getAddUpdateAddressPayload(),
      );

      if (response.hasException) {
        addEditAddress.message = response.exception!.graphqlErrors[0].message;
        addEditAddress.state = NetworkState.error;
      } else {
        addedAddressId =
            response.data!['addAddress']['userAddress']['externalId'];
        addEditAddress.message = 'Addresses added successfully';
        addEditAddress.state = NetworkState.loaded;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      addEditAddress.message = 'Something went wrong';
      addEditAddress.state = NetworkState.error;
    } finally {
      update();
    }
    return addedAddressId;
  }

  Future<dynamic> updateClientAddress(int editIndex) async {
    addEditAddress.state = NetworkState.loading;
    update();

    try {
      QueryResult response =
          await ClientProfileRepository().updateClientAddress(
        apiKey!,
        client.taxyID!,
        getAddUpdateAddressPayload(editIndex: editIndex),
      );

      if (response.hasException) {
        addEditAddress.message = response.exception!.graphqlErrors[0].message;
        addEditAddress.state = NetworkState.error;
      } else {
        addEditAddress.message = 'Address updated successfully';
        addEditAddress.state = NetworkState.loaded;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      addEditAddress.message = 'Something went wrong';
      addEditAddress.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<dynamic> deleteClientAddress(
      int deleteIndex, BuildContext context) async {
    deleteAddress.state = NetworkState.loading;
    update();

    try {
      QueryResult response =
          await ClientProfileRepository().deleteClientAddress(
        apiKey!,
        client.taxyID!,
        clientAddressModelList[deleteIndex].externalID!,
      );

      if (response.hasException) {
        deleteAddress.message = response.exception!.graphqlErrors[0].message;
        deleteAddress.state = NetworkState.error;
      } else {
        deleteAddress.message = response.data!['deleteAddress']['message'];
        deleteAddress.state = NetworkState.loaded;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      deleteAddress.message = 'Something went wrong';
      deleteAddress.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Map<String, String> getAddUpdateAddressPayload({int? editIndex}) {
    final payload = <String, String>{
      'line1': addressline1InputController?.text ?? '',
      'line2': addressline2InputController?.text ?? '',
      'line3': addressline3InputController?.text ?? '',
      'city': cityInputController?.text ?? '',
      'state': stateInputController?.text ?? '',
      'country': countryInputController?.text ?? '',
      'pincode': pincodeInputController?.text ?? '',
      'title': addressTitleController?.text ?? '',
    };

    // IN UI following field are not present so taking from object itself in case of edit
    if (editIndex != null) {
      payload['id'] = clientAddressModelList[editIndex].externalID ?? '';
    }

    LogUtil.printLog('getAddUpdateAddressPayload==>${payload.toString()}');
    return payload;
  }

  Future<void> getAddressFromPin(String pin) async {
    try {
      var data = await ClientProfileRepository().getAddressFromPin(pin);
      if (data['status'] == '200') {
        List postOfficeList = data["response"]["PostOffice"] as List;

        // prefill input field
        var postOffice = postOfficeList.first;
        cityInputController?.text = postOffice["District"] ?? '';
        stateInputController?.text = postOffice["State"] ?? '';
        countryInputController?.text = postOffice["Country"] ?? '';

        updateCountryIndex();
        updateStateIndex();
        update();
      }
    } catch (error) {
      LogUtil.printLog(error.toString());
    }
  }

  void updateCountryIndex() {
    // update country index
    final isCountryAdded =
        (countryInputController?.text ?? '').isNotNullOrEmpty;
    if (isCountryAdded) {
      selectedCountryIndex = countries.indexWhere((element) =>
          element.name?.toLowerCase() ==
          (countryInputController?.text ?? '').toLowerCase());
    }
  }

  void updateStateIndex() {
    // update state index
    final isStateAdded = (stateInputController?.text ?? '').isNotNullOrEmpty &&
        selectedCountryIndex != null &&
        selectedCountryIndex! >= 0 &&
        selectedCountryIndex! < countries.length;
    if (isStateAdded) {
      selectedStateIndex = countries[selectedCountryIndex!].state?.indexWhere(
          (element) =>
              element.name?.toLowerCase() ==
              (stateInputController?.text ?? '').toLowerCase());
    }
  }

  void onChangeCountry(String value, int index) {
    if (value != countryInputController?.text) {
      countryInputController?.text = value;
      selectedCountryIndex = index;
      stateInputController?.clear();
      cityInputController?.clear();
      selectedStateIndex = null;
      update();
    }
  }

  void onChangeState(String value, int index) {
    if (value != stateInputController?.text) {
      stateInputController?.text = value;
      selectedStateIndex = index;
      cityInputController?.clear();
      update();
    }
  }

  void onChangeCity(String value) {
    if (value != cityInputController?.text) {
      cityInputController?.text = value;
      update();
    }
  }

  Future<void> getCountriesData() async {
    final data = await rootBundle.loadString(countriesDataFile);
    countries = (jsonDecode(data) as List)
        .map(
          (dynamic e) => CountryModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }
}
