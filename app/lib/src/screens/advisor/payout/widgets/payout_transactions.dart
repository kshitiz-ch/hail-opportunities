import 'package:app/flavors.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/advisor/payout_controller.dart';
import 'package:app/src/controllers/common/download_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/advisor/models/payout_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

const String payoutDownloadTag = 'payout-invoice';

class PayoutTransactions extends StatelessWidget {
  final controller = Get.find<PayoutController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DownloadController>(
      tag: payoutDownloadTag,
      init: DownloadController(
        shouldOpenDownloadBottomSheet: true,
        authorizationRequired: true,
      ),
      builder: (downloadController) {
        return ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 24),
          itemCount: controller.payoutList.length,
          itemBuilder: (context, index) {
            final payout = controller.payoutList[index];

            return _buildPayoutCard(payout, context);
          },
          separatorBuilder: (_, __) => SizedBox(height: 15),
        );
      },
    );
  }

  Widget _buildPayoutCard(PayoutModel payoutModel, BuildContext context) {
    final style = Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
          color: ColorConstants.black,
          fontWeight: FontWeight.w400,
        );
    // TODO: add below when its available
    // final utr = payoutModel.payoutRedemptionDetails.isNotNullOrEmpty
    //     ? payoutModel.payoutRedemptionDetails!.first.utr ?? '-'
    //     : '-';
    final data = [
      ['Date ', getFormattedDate(payoutModel.payoutReadyDate)],
      [
        'Final Payout',
        WealthyAmount.currencyFormat(payoutModel.finalPayout, 2)
      ],
    ];
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: ColorConstants.borderColor,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: data.map(
                (item) {
                  return Expanded(
                    child: CommonUI.buildColumnTextInfo(
                      title: item.first,
                      subtitle: item.last,
                      subtitleStyle: style,
                      titleStyle: style?.copyWith(
                        color: ColorConstants.tertiaryBlack,
                      ),
                    ),
                  );
                },
              ).toList()
                ..add(
                  Expanded(
                    child: ClickableText(
                      padding: EdgeInsets.only(bottom: 10),
                      text: 'Invoice',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: SvgPicture.asset(
                          AllImages().downloadIcon,
                          width: 14,
                        ),
                      ),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      onClick: () {
                        MixPanelAnalytics.trackWithAgentId(
                          "download_invoice",
                          screen: 'payouts',
                          screenLocation: 'payouts',
                        );
                        onDownload(
                          payoutModel.payoutId!,
                          isBrokingPayout: controller.isBrokingPayout,
                        );
                      },
                    ),
                  ),
                ),
            ),
          ),
          CommonUI.buildProfileDataSeperator(
            color: ColorConstants.borderColor,
            width: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: 'Status  ',
                      style: style?.copyWith(
                        color: ColorConstants.tertiaryBlack,
                      ),
                      children: [
                        TextSpan(
                          text: payoutModel.statusDescription,
                          style: style?.copyWith(
                            color: payoutModel.status?.toUpperCase() == 'PS'
                                ? ColorConstants.greenAccentColor
                                : ColorConstants.yellowAccentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ClickableText(
                      text: 'View Details',
                      fontWeight: FontWeight.w400,
                      onClick: () {
                        MixPanelAnalytics.trackWithAgentId(
                          "view_details",
                          screen: 'payouts',
                          screenLocation: 'payout_transactions',
                        );
                        controller
                            .getPayoutProductBreakup(payoutModel.payoutId!);
                        AutoRouter.of(context).push(
                          PayoutDetailRoute(payoutModel: payoutModel),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onDownload(String payoutId, {bool isBrokingPayout = false}) {
    final downloadController =
        Get.find<DownloadController>(tag: payoutDownloadTag);
    String url =
        '${F.url}/external-apis/download-payout-invoice/?payout_id=$payoutId';

    if (isBrokingPayout) url += '&payout_type=broking';

    final filename = payoutId;
    final fileExt = '.pdf';
    downloadController.downloadFile(
      url: url,
      filename: filename,
      extension: fileExt,
    );
  }
}
