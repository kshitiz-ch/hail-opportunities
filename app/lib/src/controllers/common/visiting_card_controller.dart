import 'dart:typed_data';

import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/dashboard/resources/advisor_overview_repository.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';

class VisitingCardController extends GetxController {
  NetworkState visitingCardBrochureState = NetworkState.cancel;
  Uint8List? visitingCardBrochurePdfByte;

  // Pdf starts with page 0
  int currentPdfPage = 0;
  int totalPages = 0;
  String templateName;

  PDFViewController? pdfViewController;

  VisitingCardController({required this.templateName});

  onInit() {
    getVisitingCardBrochure();
    super.onInit();
  }

  Future<void> getVisitingCardBrochure() async {
    visitingCardBrochureState = NetworkState.loading;
    update();

    try {
      String apiKey = await getApiKey() ?? '';
      String agentExternalId = await getAgentExternalId() ?? '';

      var response = await AdvisorOverviewRepository().getVisitingCardBrochure(
        apiKey: apiKey,
        agentExternalId: agentExternalId,
        templateName: templateName,
      );

      if (response['status'] == "200") {
        visitingCardBrochurePdfByte = response["response"];
        visitingCardBrochureState = NetworkState.loaded;
      } else {
        visitingCardBrochureState = NetworkState.error;
      }
    } catch (error) {
      visitingCardBrochureState = NetworkState.error;
    } finally {
      update();
    }
  }

  void updateCurrentPdfPage(int newPage) {
    pdfViewController?.setPage(0);
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
