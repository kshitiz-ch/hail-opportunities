import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InvestmentStatusSection extends StatelessWidget {
  const InvestmentStatusSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientDetailController>(
      id: 'investment-status',
      builder: (controller) {
        if (controller.investmentStatusResponse.state == NetworkState.loading) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 20).copyWith(top: 40),
            decoration: BoxDecoration(
              color: ColorConstants.lightBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            height: 100,
          ).toShimmer(
            baseColor: ColorConstants.lightBackgroundColor,
            highlightColor: ColorConstants.white,
          );
        }

        if (controller.investmentStatusResponse.state == NetworkState.error) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 20).copyWith(top: 40),
            child: RetryWidget(
              'Something went wrong. Please try again',
              onPressed: () {
                controller.getClientInvestmentStatus();
              },
            ),
          );
        }

        if (controller.investmentStatusResponse.state == NetworkState.loaded) {
          return Container(
            padding: const EdgeInsets.all(20),
            margin: EdgeInsets.symmetric(horizontal: 20).copyWith(top: 40),
            decoration: BoxDecoration(
              color: ColorConstants.primaryAppv3Color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildStatusTile(
                  context,
                  title: 'Mutual Fund Profile',
                  value: controller.mfInvestmentStatus,
                  isVerified: controller.mfInvestmentStatus
                      .contains(InvestmentStatus.INVESTMENTREADY),
                  leadingWidget: _buildStatusInfoToolTip(context, controller),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Divider(
                    color: ColorConstants.lightPrimaryAppColor.withOpacity(0.2),
                  ),
                ),
                _buildStatusTile(
                  context,
                  title: 'Broking Profile',
                  value: controller.brokingInvestmentStatus,
                  isVerified: controller.brokingInvestmentStatus ==
                      InvestmentStatus.INVESTMENTREADY,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Divider(
                    color: ColorConstants.lightPrimaryAppColor.withOpacity(0.2),
                  ),
                ),
                _buildStatusTile(
                  context,
                  title: 'KRA KYC Status',
                  value: controller.kraStatus,
                  isVerified: false,
                  leadingWidget: _buildFetchKraStatus(context, controller),
                ),
              ],
            ),
          );
        }

        return SizedBox();
      },
    );
  }

  Widget? _buildStatusInfoToolTip(
      BuildContext context, ClientDetailController controller) {
    return controller.mfInvestmentStatusInfo.isNotNullOrEmpty
        ? Tooltip(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: ColorConstants.black,
                borderRadius: BorderRadius.circular(6)),
            triggerMode: TooltipTriggerMode.tap,
            textStyle: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
            message: controller.mfInvestmentStatusInfo,
            child: Padding(
              padding: EdgeInsets.only(left: 5),
              child: Icon(
                Icons.info,
                color: ColorConstants.tertiaryBlack,
              ),
            ),
          )
        : null;
  }

  Widget _buildFetchKraStatus(
      BuildContext context, ClientDetailController controller) {
    if (controller.kraStatusResponse.state == NetworkState.loading) {
      return Container(
        height: 10,
        width: 10,
        margin: EdgeInsets.only(left: 11),
        child: CircularProgressIndicator(
          strokeWidth: 1,
        ),
      );
    }

    return InkWell(
      onTap: () async {
        await controller.getClientKraStatusCheck();

        if (controller.kraStatusResponse.state == NetworkState.error ||
            controller.kraStatus.isNullOrEmpty) {
          showToast(text: "KRA KYC status not found");
        }
      },
      child: Padding(
        padding: EdgeInsets.only(left: 5),
        child: Icon(
          Icons.sync,
          color: ColorConstants.primaryAppColor,
        ),
      ),
    );
  }

  Widget _buildStatusTile(BuildContext context,
      {required String title,
      required String value,
      required bool isVerified,
      Widget? leadingWidget}) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context)
              .primaryTextTheme
              .headlineSmall!
              .copyWith(fontWeight: FontWeight.w300, fontSize: 13),
        ),
        if (isVerified)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              Icons.check_circle,
              color: ColorConstants.greenAccentColor,
            ),
          ),
        Expanded(
          child: Text(
            value.isNullOrEmpty ? 'NA' : value,
            textAlign: TextAlign.end,
            style: Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ),
        if (leadingWidget != null) leadingWidget
      ],
    );
  }
}
