import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';

class DownloadedReportBottomSheet extends StatelessWidget {
  final String? reportName;
  final Function onView;
  final Function onShare;

  const DownloadedReportBottomSheet({
    Key? key,
    this.reportName,
    required this.onView,
    required this.onShare,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
          child: Align(
            alignment: Alignment.topRight,
            child: CommonUI.bottomsheetCloseIcon(context),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Image.asset(
            AllImages().clientReportDownloadIcon,
            width: 86,
            height: 86,
            alignment: Alignment.center,
          ),
        ),
        Text(
          'File Downloaded',
          textAlign: TextAlign.center,
          style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                color: ColorConstants.black,
                fontWeight: FontWeight.w500,
              ),
        ),
        if (reportName.isNotNullOrEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 8),
            child: Text.rich(
              TextSpan(
                text: '$reportName has been downloaded',
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          color: ColorConstants.tertiaryGrey,
                          fontWeight: FontWeight.w500,
                        ),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30)
              .copyWith(bottom: 45, top: 30),
          child: Row(
            children: [
              Expanded(
                child: ActionButton(
                  bgColor: ColorConstants.secondaryAppColor,
                  textStyle: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.primaryAppColor,
                        fontSize: 16,
                      ),
                  text: 'View',
                  margin: EdgeInsets.zero,
                  onPressed: () {
                    MixPanelAnalytics.trackWithAgentId(
                      "view_report",
                      screen: 'client_report',
                      screenLocation: "download_report",
                    );
                    onView();
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ActionButton(
                  text: 'Share',
                  margin: EdgeInsets.zero,
                  onPressed: () {
                    MixPanelAnalytics.trackWithAgentId(
                      "share_report",
                      screen: 'client_report',
                      screenLocation: "download_report",
                    );
                    onShare();
                  },
                  textStyle: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.white,
                        fontSize: 16,
                      ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
