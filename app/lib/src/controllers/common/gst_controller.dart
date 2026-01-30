import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/dashboard/resources/advisor_overview_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

enum GstFormMode { Add, Edit, Verify }

class GstController extends GetxController {
  NetworkState? verifyGstState;
  NetworkState? saveGstState;

  String saveGstErrorMessage = '';

  bool isDigioGstVerificationFailed = false;
  bool isGstPanLinkDeclared = false;

  TextEditingController gstNumberController = TextEditingController();

  String savedGstNumber;

  GstController({required this.savedGstNumber}) {
    if (savedGstNumber.isNotNullOrEmpty) {
      gstNumberController.text = savedGstNumber;
      update();
    }
  }

  @override
  void onInit() {
    gstNumberController.addListener(() {
      update();
    });

    super.onInit();
  }

  // Future<void> verifyGst() async {
  //   verifyGstState = NetworkState.loading;
  //   update();

  //   try {
  //     Map<String, dynamic> payload = {
  //       // "gst": "asd",
  //       "gst": gstNumberController.text,
  //       "pan_number": panNumberController.text
  //     };

  //     var response =
  //         await AdvisorOverviewRepository().verifyGst(apiKey, payload);

  //     if (response["status"] == "200") {
  //       bool isGstValid = response["is_valid"] ?? false;
  //       isDigioGstVerificationFailed = !isGstValid;

  //       verifyGstState = NetworkState.loaded;
  //     } else {
  //       verifyGstState = NetworkState.error;
  //       showToast(text: "Invalid GST");
  //     }
  //   } catch (error) {
  //     verifyGstState = NetworkState.error;
  //     showToast(text: "Invalid GST");
  //   } finally {
  //     update();
  //   }
  // }

  Future<void> saveGst({String? panNumber, String? gstNumber}) async {
    saveGstState = NetworkState.loading;
    update();

    try {
      String apiKey = (await getApiKey())!;

      Map<String, dynamic> payload = {
        "gst": gstNumber ?? gstNumberController.text,
        "pan_number": panNumber
      };

      var data = await AdvisorOverviewRepository().saveGst(apiKey, payload);

      if (data["status"] == "200") {
        bool isGstValid = data["response"]["is_valid"] ?? false;
        isDigioGstVerificationFailed = !isGstValid;
        saveGstState = NetworkState.loaded;
      } else {
        saveGstState = NetworkState.error;
        saveGstErrorMessage = getErrorMessageFromResponse(data["response"]);
      }
    } catch (error) {
      saveGstState = NetworkState.error;
      saveGstErrorMessage = "Please enter a valid GST";
    } finally {
      update();
    }
  }

  void toggleGstPanLinkDeclared() {
    isGstPanLinkDeclared = !isGstPanLinkDeclared;
    update();
  }
}
