import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientStatusDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientDetailController>(
      id: 'client-status',
      builder: (controller) {
        return Container(
          color: hexToColor("#F6F6F6"),
          height: 100,
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            scrollDirection: Axis.horizontal,
            children: [
              getStatusWidget(
                apiResponse: controller.investmentStatusResponse,
                data: [
                  MapEntry('MF Profile', controller.mfInvestmentStatus),
                  MapEntry(
                      'Broking Profile', controller.brokingInvestmentStatus)
                ],
                onRetry: () {
                  controller.getClientInvestmentStatus();
                },
                context: context,
              ),
              getStatusWidget(
                apiResponse: controller.mandateResponse,
                data: [
                  MapEntry(
                    'Mandate Status',
                    controller.userMandateMeta?.statusText ?? '-',
                  ),
                  MapEntry(
                    'Mandate Approved on',
                    getFormattedDate(
                        controller.userMandateMeta?.mandateConfirmedAt),
                  )
                ],
                onRetry: () {
                  controller.getUserMandateMeta();
                },
                context: context,
              ),
              getStatusWidget(
                apiResponse: controller.clientMfProfileResponse,
                data: [
                  MapEntry(
                    'Tax Status',
                    AccountType.getTaxStatusAccountType(
                      panUsageSubtype:
                          controller.clientMfProfile?.panUsageSubtype ?? '-',
                      panUsagetype:
                          controller.clientMfProfile?.panUsageType ?? '-',
                      accountType: false,
                      taxStatus: true,
                    ),
                  ),
                  MapEntry(
                    'PAN Number',
                    controller.clientMfProfile?.panNumber ?? '-',
                  )
                ],
                onRetry: () {
                  controller.getClientProfileDetails();
                },
                context: context,
              ),
              getStatusWidget(
                apiResponse: controller.investmentStatusResponse,
                data: [
                  MapEntry('KRA KYC Status', controller.kraStatus),
                  MapEntry('Last Active',
                      getFormattedDate(controller.client?.lastSeenAt))
                ],
                onRetry: () {
                  controller.getClientInvestmentStatus();
                },
                context: context,
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget getStatusWidget({
  required ApiResponse apiResponse,
  required List<MapEntry<String, String>> data,
  required Function onRetry,
  required BuildContext context,
}) {
  final style = Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
        color: ColorConstants.tertiaryBlack,
        fontWeight: FontWeight.w400,
      );
  late Widget statusWidget;
  if (apiResponse.state == NetworkState.loading) {
    statusWidget = SkeltonLoaderCard(height: 70);
  } else if (apiResponse.state == NetworkState.error) {
    statusWidget = RetryWidget(
      apiResponse.message,
      onPressed: () {
        onRetry();
      },
    );
  } else {
    statusWidget = Row(
      children: [
        Expanded(
          child: _buildStatusInfo(
            title: data.first.key,
            subtitle: data.first.value,
            titleStyle: style,
            subtitleStyle: style?.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
            ),
            showVerifiedIcon: data.first.value == 'Investment Ready',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _buildStatusInfo(
            title: data.last.key,
            subtitle: data.last.value,
            titleStyle: style,
            subtitleStyle: style?.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
            ),
            showVerifiedIcon: data.last.value == 'Investment Ready',
          ),
        )
      ],
    );
  }

  return Container(
    width: SizeConfig().screenWidth! * 0.7,
    margin: EdgeInsets.only(right: 10),
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: ColorConstants.borderColor),
      borderRadius: BorderRadius.circular(8),
    ),
    child: statusWidget,
  );
}

Widget _buildStatusInfo({
  required String title,
  required String subtitle,
  required TextStyle? titleStyle,
  required TextStyle? subtitleStyle,
  bool showVerifiedIcon = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(title, style: titleStyle),
      SizedBox(height: 6),
      Row(
        children: [
          Flexible(
            child: Text(
              subtitle,
              style: subtitleStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showVerifiedIcon)
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Image.asset(
                AllImages().verifiedIcon,
                height: 12,
                width: 12,
                alignment: Alignment.bottomCenter,
              ),
            ),
        ],
      )
    ],
  );
}
