import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/advisor/soa_download_controller.dart';
import 'package:app/src/screens/home/report/download/widgets/soa_report_card.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

@RoutePage()
class SoaDownloadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SOADownloadController>(
      init: SOADownloadController(),
      builder: (controller) {
        final showLoader =
            controller.soaReportCreateResponse.state == NetworkState.loading ||
                controller.getSoaReportReponse.state == NetworkState.loading;
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(titleText: 'Download SOA'),
          body: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 24),
            children: [
              _buildDropdown(
                context,
                label: 'Select Client',
                imagePath: AllImages().userOutline,
                value: controller.selectedClient?.name,
                onTap: () {
                  AutoRouter.of(context).push(
                    SelectClientRoute(
                      showClientFamilyList: false,
                      showSearchContactSwitch: false,
                      showAddNewClient: false,
                      skipSelectClientConfirmation: true,
                      onClientSelected: (Client? client, _) {
                        if (client != controller.selectedClient) {
                          controller.onClientSelect(client);
                        }
                        AutoRouter.of(context).popForced();
                      },
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: _buildDropdown(
                  context,
                  label: 'Select Folio Number',
                  imagePath: AllImages().soaFolioIcon,
                  value: controller.selectedFolio?.folioNumber,
                  onTap: () {
                    if (controller.selectedClient == null) {
                      return showToast(text: 'Please select the Client');
                    } else {
                      controller.amcSearchController.clear();
                      controller.getSoaFolioList();
                      AutoRouter.of(context).push(
                        SoaFolioListRoute(
                          onDone: () async {
                            await _onGenerate(controller);
                            AutoRouter.of(context).popForced();
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
              if (showLoader)
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                )
              else if (controller.soaReportModel != null)
                SOAReportCard(
                  onRetry: () {
                    _onGenerate(controller);
                  },
                )
              else
                _buildErrorState(controller, context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDropdown(
    BuildContext context, {
    required String label,
    required String imagePath,
    required void Function() onTap,
    String? value,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: ColorConstants.borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (value.isNullOrEmpty)
              Image.asset(
                imagePath,
                width: 20,
              )
            else
              SvgPicture.asset(
                AllImages().verifiedRoundedIcon,
                width: 20,
              ),
            SizedBox(width: 6),
            if (value.isNullOrEmpty)
              Text(
                label,
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.w600),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .titleLarge!
                        .copyWith(color: ColorConstants.tertiaryBlack),
                  ),
                  SizedBox(height: 2),
                  Text(
                    value!,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            Spacer(),
            Image.asset(
              AllImages().downArrow,
              width: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onGenerate(SOADownloadController controller) async {
    await controller.generateSOAReport();
    if (controller.soaReportCreateResponse.state == NetworkState.error) {
      showToast(text: controller.soaReportCreateResponse.message);
    } else if (controller.soaReportCreateResponse.state ==
        NetworkState.loaded) {
      if (controller.createdReportId.isNullOrEmpty) {
        showToast(text: 'Something went wrong. Please try again');
      } else {
        await controller.getSoaReport();
        if (controller.getSoaReportReponse.state == NetworkState.error) {
          showToast(text: controller.getSoaReportReponse.message);
        }
      }
    }
  }

  Widget _buildErrorState(
    SOADownloadController controller,
    BuildContext context,
  ) {
    final errorMsg = 'Something went wrong. Please try again to fetch report';
    final isGenerateReportFailed =
        controller.soaReportCreateResponse.state == NetworkState.error ||
            (controller.soaReportCreateResponse.state == NetworkState.loaded &&
                controller.createdReportId.isNullOrEmpty);
    final isGetReportFailed =
        controller.getSoaReportReponse.state == NetworkState.error;
    final isGenerateReportLoading =
        controller.soaReportCreateResponse.state == NetworkState.loading;
    final isGetReportLoading =
        controller.getSoaReportReponse.state == NetworkState.loading;

    if (isGetReportLoading ||
        isGenerateReportLoading ||
        isGenerateReportFailed ||
        isGetReportFailed) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorConstants.borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: ColorConstants.lightScaffoldBackgroundColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 14),
              child: Text(
                '** $errorMsg',
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          color: ColorConstants.errorColor,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                        ),
              ),
            ),
            ActionButton(
              height: 40,
              margin: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
              textStyle:
                  Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.primaryAppColor,
                      ),
              text: 'Retry',
              showProgressIndicator:
                  isGenerateReportLoading || isGetReportLoading,
              showBorder: true,
              borderColor: ColorConstants.primaryAppColor,
              bgColor: ColorConstants.white,
              customLoader: Center(
                child: SizedBox(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(
                    color: ColorConstants.primaryAppColor,
                  ),
                ),
              ),
              onPressed: () async {
                if (isGenerateReportFailed) {
                  await _onGenerate(controller);
                } else if (isGetReportFailed) {
                  await controller.getSoaReport();
                  if (controller.getSoaReportReponse.state ==
                      NetworkState.error) {
                    showToast(text: controller.getSoaReportReponse.message);
                  }
                }
              },
            ),
          ],
        ),
      );
    }
    return SizedBox();
  }
}
