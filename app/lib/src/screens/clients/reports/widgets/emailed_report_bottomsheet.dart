import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:flutter/material.dart';

class EmailedReportBottomSheet extends StatelessWidget {
  final String clientEmailID;
  final String clientName;
  final String reportName;
  final Function onDone;

  const EmailedReportBottomSheet({
    Key? key,
    required this.clientEmailID,
    required this.clientName,
    required this.reportName,
    required this.onDone,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Image.asset(
            AllImages().clientReportEmailIcon,
            width: 80,
            height: 96,
            alignment: Alignment.center,
          ),
        ),
        Text(
          'Report Emailed',
          textAlign: TextAlign.center,
          style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                color: ColorConstants.black,
                fontWeight: FontWeight.w500,
              ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30)
              .copyWith(top: 8, bottom: 62),
          child: Text.rich(
            TextSpan(
              text: '$reportName has been sent to $clientName on ',
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    color: ColorConstants.tertiaryGrey,
                    fontWeight: FontWeight.w500,
                  ),
              children: <TextSpan>[
                TextSpan(
                  text: clientEmailID,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                TextSpan(
                  text: ' and will be delivered in some time.',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        color: ColorConstants.tertiaryGrey,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        ActionButton(
          text: 'Done',
          margin: EdgeInsets.symmetric(horizontal: 30).copyWith(bottom: 24),
          onPressed: () {
            onDone();
          },
        )
      ],
    );
  }
}
