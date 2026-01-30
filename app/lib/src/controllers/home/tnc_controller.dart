import 'dart:convert';
import 'dart:typed_data';

import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/advisor/resources/advisor_repository.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';

class TncController extends GetxController {
  ApiResponse generatePdfResponse = ApiResponse();
  ApiResponse uploadPdfResponse = ApiResponse();

  Uint8List? pdfBytes;

  // Pdf starts with page 0
  int currentPdfPage = 0;
  int totalPages = 0;

  bool enableAgreeButton = false;

  PDFViewController? pdfViewController;

  void onInit() {
    generateTncPdf();
    super.onInit();
  }

  Future<void> generateTncPdf() async {
    generatePdfResponse.state = NetworkState.loading;
    update();
    try {
      String apiKey = await getApiKey() ?? '';
      Map<String, dynamic> payload = await tncPayload();

      var data = await AdvisorRepository().generateTncPdf(apiKey, payload);

      if (data["status"] == "200") {
        generatePdfResponse.state = NetworkState.loaded;
        String base64code = data["response"]["pdf_data"];
        // List splitByBase64 = base64code.split(";base64,");
        pdfBytes = base64.decode(base64code);
      } else {
        generatePdfResponse.state = NetworkState.error;
        generatePdfResponse.message =
            getErrorMessageFromResponse(data["response"]);
      }
    } catch (error) {
      generatePdfResponse.message = genericErrorMessage;
      generatePdfResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> uploadTncPdf() async {
    uploadPdfResponse.state = NetworkState.loading;
    update();
    try {
      String apiKey = await getApiKey() ?? '';
      Map<String, dynamic> payload = await tncPayload();

      var response = await AdvisorRepository().uploadTncPdf(apiKey, payload);

      if (response["status"] == "200") {
        uploadPdfResponse.state = NetworkState.loaded;
      } else {
        uploadPdfResponse.state = NetworkState.error;
        uploadPdfResponse.message = getErrorMessageFromResponse(response);
      }
    } catch (error) {
      uploadPdfResponse.message = genericErrorMessage;
      uploadPdfResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<Map<String, dynamic>> tncPayload() async {
    int? agentId = await getAgentId();
    return {
      "agent_id": agentId.toString(),
      "tnc_type": "ARN",
    };
  }

  void updateCurrentPdfPage(int newPage) {
    if (newPage > (totalPages - 1)) {
      currentPdfPage = 0;
      pdfViewController?.setPage(0);
    } else if (newPage < 0) {
      currentPdfPage = totalPages - 1;
      pdfViewController?.setPage(totalPages - 1);
    } else {
      currentPdfPage = newPage;
      pdfViewController?.setPage(newPage);
    }
    update();
  }
}
