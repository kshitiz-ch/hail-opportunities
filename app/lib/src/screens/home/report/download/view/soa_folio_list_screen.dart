import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/advisor/soa_download_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/screens/home/report/download/widgets/folio_card.dart';
import 'package:app/src/screens/home/report/download/widgets/soa_amc_search_bar.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class SoaFolioListScreen extends StatelessWidget {
  final Function onDone;
  final String? tag;

  const SoaFolioListScreen({Key? key, required this.onDone, this.tag})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SOADownloadController>(
      tag: tag,
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            titleText: 'SOA Folios',
            subtitleText: 'Select folio to download SOA',
            onBackPress: () {
              // reset if back button clicked
              controller.onFolioSelect(null);
              AutoRouter.of(context).popForced();
            },
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SoaAmcSearchBar(tag: tag),
              SizedBox(height: 20),
              Expanded(
                child: _buildFolioList(context, controller),
              ),
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: _buildCTA(controller, context),
        );
      },
    );
  }

  Widget _buildFolioList(
    BuildContext context,
    SOADownloadController controller,
  ) {
    if (controller.soaFolioResponse.state == NetworkState.loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    if (controller.soaFolioResponse.state == NetworkState.error) {
      return Center(
        child: RetryWidget(
          controller.soaFolioResponse.message,
          onPressed: () {
            controller.getSoaFolioList();
          },
        ),
      );
    }
    if (controller.soaFolioResponse.state == NetworkState.loaded) {
      if (controller.filteredSoaFolioList.isNullOrEmpty) {
        return Center(
          child: EmptyScreen(message: 'No folios available'),
        );
      }
      return ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 120),
        itemCount: controller.filteredSoaFolioList.length,
        itemBuilder: (context, index) {
          final soaFolioModel = controller.filteredSoaFolioList[index];
          return FolioCard(
            soaFolioModel: soaFolioModel,
            selectedFolio: controller.selectedFolio?.folioNumber,
            onSelect: () {
              if (soaFolioModel != controller.selectedFolio) {
                controller.onFolioSelect(soaFolioModel);
              }
            },
          );
        },
        separatorBuilder: (_, __) => SizedBox(height: 20),
      );
    }
    return SizedBox();
  }

  Widget _buildCTA(SOADownloadController controller, BuildContext context) {
    if (controller.filteredSoaFolioList.isNullOrEmpty) {
      return SizedBox();
    }
    return ActionButton(
      text: 'Generate Latest SOA',
      isDisabled: controller.selectedFolio == null,
      showProgressIndicator:
          controller.soaReportCreateResponse.state == NetworkState.loading ||
              controller.getSoaReportReponse.state == NetworkState.loading,
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
      onPressed: () {
        onDone();
      },
    );
  }
}
