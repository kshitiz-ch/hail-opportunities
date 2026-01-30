import 'package:app/flavors.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/advisor/revenue_sheet_controller.dart';
import 'package:app/src/controllers/common/download_controller.dart';
import 'package:app/src/screens/advisor/revenue_sheet/widgets/donut_chart.dart';
import 'package:app/src/screens/advisor/revenue_sheet/widgets/revenue_search_bar.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/advisor/models/client_revenue_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

const String revenueSheetDownloadTag = 'revenue-sheet-list';

class ClientWiseRevenue extends StatelessWidget {
  final bool enableDownload;

  const ClientWiseRevenue({Key? key, required this.enableDownload})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Revenue Listing',
                style:
                    Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                          color: ColorConstants.black,
                          fontWeight: FontWeight.w500,
                        ),
              ),
              _buildDownloadButton(),
            ],
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 16),
          child: RevenueSearchBar(),
        ),
        GetBuilder<RevenueSheetController>(
          id: GetxId.clientWiseRevenue,
          builder: (controller) {
            if (controller.isPaginating) {
              return _buildClientWiseRevenueUI(controller, context);
            }
            if (controller.clientWiseRevenueResponse.state ==
                NetworkState.loading) {
              return SkeltonLoaderCard(
                height: 300,
                margin: const EdgeInsets.symmetric(horizontal: 20),
              );
            }
            if (controller.clientWiseRevenueResponse.state ==
                NetworkState.error) {
              return SizedBox(
                height: 300,
                child: Center(
                  child: RetryWidget(
                    controller.clientWiseRevenueResponse.message,
                    onPressed: () {
                      controller.getClientWiseRevenue();
                    },
                  ),
                ),
              );
            }
            if (controller.clientWiseRevenueResponse.state ==
                NetworkState.loaded) {
              return _buildClientWiseRevenueUI(controller, context);
            }
            return SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildClientWiseRevenueUI(
      RevenueSheetController controller, BuildContext context) {
    if (controller.clientWiseRevenue.isNullOrEmpty) {
      return Center(
        child: EmptyScreen(message: 'No Data Available'),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...List<Widget>.generate(
              controller.clientWiseRevenue.length,
              (index) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildClientRevenueCard(
                        controller.clientWiseRevenue[index],
                        context,
                        () {
                          AutoRouter.of(context).push(
                            RevenueSheetDetailRoute(
                              payoutId: controller.payoutId,
                              selectedClientRevenue:
                                  controller.clientWiseRevenue[index],
                              revenueDate: controller.overviewDate,
                              agentExternalIdList: controller.partnerOfficeModel
                                      ?.partnerEmployeeExternalIdList ??
                                  [],
                              partnerEmployeeSelected: controller
                                  .partnerOfficeModel?.partnerEmployeeSelected,
                            ),
                          );
                        },
                      ),
                    ),
                    if (index < (controller.clientWiseRevenue.length - 1))
                      CommonUI.buildProfileDataSeperator(
                        color: ColorConstants.borderColor,
                        height: 1,
                        width: double.infinity,
                      ),
                  ],
                );
              },
            ).toList(),
            if (controller.isPaginating &&
                controller.clientWiseRevenueResponse.state ==
                    NetworkState.loading)
              Center(
                child: CircularProgressIndicator(),
              )
          ],
        ),
      );
    }
  }

  Widget _buildClientRevenueCard(
      ClientRevenueModel model, BuildContext context, Function onPressed) {
    final titleStyle =
        Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: ColorConstants.black,
            );
    final subtitleStyle =
        Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w400,
              color: ColorConstants.tertiaryBlack,
            );
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              model.clientDetails?.name?.toTitleCase() ?? '-',
              style: titleStyle,
            ),
            Text(
              WealthyAmount.currencyFormat(model.totalRevenue, 2),
              style:
                  titleStyle?.copyWith(color: ColorConstants.greenAccentColor),
            ),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CRN ${model.clientDetails?.crn ?? '-'}',
              style: subtitleStyle,
            ),
            // Text(
            //   'Until 24 Jan 2024',
            //   style: subtitleStyle,
            // ),
          ],
        ),
        children: [
          _buildProductAggregate(context, model),
          _buildCTA(context, onPressed),
        ],
        onExpansionChanged: (value) {
          if (value) {
            MixPanelAnalytics.trackWithAgentId(
              "revenue_entry_click",
              screen: 'revenue_sheet',
              screenLocation: 'revenue_listing',
            );
          }
        },
      ),
    );
  }

  Widget _buildProductAggregate(
      BuildContext context, ClientRevenueModel model) {
    final titleStyle = Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: ColorConstants.tertiaryBlack,
        );
    final subtitleStyle =
        Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: ColorConstants.black,
            );
    Widget _buildRevenueDetails(int index) {
      if (index >= (model.productRevenueUIData!.sortedProducts).length) {
        return SizedBox();
      }
      final product = model.productRevenueUIData!.sortedProducts[index];
      final color = getColor(index);
      String title =
          getInvestmentProductTitle(product.productType?.toLowerCase());
      if (title.isNullOrEmpty) {
        title = product.productType.toCapitalized();
      }
      return Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                text: title,
                style: titleStyle,
                children: [
                  TextSpan(
                    text: ' ${product.percentage?.toStringAsFixed(1)}%',
                    style: titleStyle?.copyWith(color: color),
                  )
                ],
              ),
            ),
            SizedBox(height: 4),
            Text(
              WealthyAmount.currencyFormat(product.revenue, 2),
              style: subtitleStyle,
            )
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        ((model.productRevenueUIData?.sortedProducts.length ?? 0) / 2).ceil(),
        (rowIndex) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: List.generate(
              2,
              (colIndex) {
                final index = rowIndex * 2 + colIndex;
                return _buildRevenueDetails(index);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCTA(BuildContext context, Function onPreseed) {
    return SizedBox(
      width: 132,
      child: ActionButton(
        showBorder: true,
        height: 32,
        margin: EdgeInsets.symmetric(vertical: 24),
        text: 'View Other Details',
        bgColor: ColorConstants.white,
        borderColor: ColorConstants.primaryAppColor,
        textStyle: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
              color: ColorConstants.primaryAppColor,
              fontWeight: FontWeight.w400,
            ),
        onPressed: () {
          MixPanelAnalytics.trackWithAgentId(
            "view_other_details",
            screen: 'revenue_sheet',
            screenLocation: 'revenue_listing',
          );
          onPreseed();
        },
      ),
    );
  }

  Widget _buildDownloadButton() {
    if (!enableDownload) {
      return SizedBox();
    }
    return GetBuilder<RevenueSheetController>(
      id: GetxId.clientWiseRevenue,
      builder: (controller) {
        final showDownload =
            controller.clientWiseRevenueResponse.state == NetworkState.loaded &&
                controller.clientWiseRevenue.isNotNullOrEmpty;
        if (!showDownload) {
          return SizedBox();
        }
        return GetBuilder<DownloadController>(
          tag: revenueSheetDownloadTag,
          init: DownloadController(
            authorizationRequired: true,
            shouldOpenDownloadBottomSheet: true,
          ),
          builder: (downloadController) {
            return Obx(
              () {
                if (downloadController.isFileDownloading.value == true) {
                  return Container(
                    margin: EdgeInsets.only(right: 15),
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  );
                } else {
                  return ClickableText(
                    onClick: () {
                      MixPanelAnalytics.trackWithAgentId(
                        "download_click",
                        screen: 'revenue_sheet',
                        screenLocation: 'revenue_listing',
                      );
                      onDownload(downloadController);
                    },
                    text: 'Download',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: SvgPicture.asset(
                        AllImages().downloadIcon,
                        width: 14,
                      ),
                    ),
                  );
                }
              },
            );
            // return ClickableText(
            //   onClick: () {
            //     onDownload();
            //   },
            //   text: 'Download',
            //   fontSize: 14,
            //   fontWeight: FontWeight.w600,
            //   icon: SvgPicture.asset(
            //     AllImages().downloadIcon,
            //     width: 14,
            //   ),
            // );
          },
        );
      },
    );
  }

  void onDownload(DownloadController downloadController) {
    final revenueSheetController = Get.find<RevenueSheetController>();
    final url =
        '${F.url}/external-apis/revenue-sheet/download/?year=${revenueSheetController.overviewDate.year}&month=${revenueSheetController.overviewDate.month}';
    final filename = 'revenue_sheet';
    final fileExt = '.xlsx';
    downloadController.downloadFile(
      url: url,
      filename: filename,
      extension: fileExt,
      viewFileAnalyticFn: () {
        MixPanelAnalytics.trackWithAgentId(
          "view_report",
          screen: 'revenue_sheet',
          screenLocation: "download_report",
        );
      },
      shareFileAnalyticFn: () {
        MixPanelAnalytics.trackWithAgentId(
          "share_report",
          screen: 'revenue_sheet',
          screenLocation: "download_report",
        );
      },
    );
  }
}
