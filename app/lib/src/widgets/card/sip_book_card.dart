import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/mf.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/clients/models/sip_user_data_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SipBookCard extends StatelessWidget {
  const SipBookCard({
    Key? key,
    required this.sipData,
    this.onTap,
    this.onClientView = false,
  }) : super(key: key);

  final SipUserDataModel sipData;
  final void Function()? onTap;
  final bool onClientView;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: ColorConstants.primaryCardColor,
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getSipDisplayName(sipData) ?? 'NA',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineLarge!
                                  .copyWith(fontSize: 16),
                            ),
                            SizedBox(height: 6),
                            _buildSipStatusText(context, sipData)
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          WealthyAmount.currencyFormat(sipData.sipAmount, 2,
                              showSuffix: true),
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineLarge!
                              .copyWith(fontSize: 16),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Divider(
              color: ColorConstants.borderColor.withOpacity(0.5),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 18.0, 20.0, 22.0),
              child: Column(
                children: [
                  if (onClientView)
                    _buildClientViewCardDetails(context)
                  else
                    _buildSipBookCardDetails(context)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildClientViewCardDetails(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 2,
              child: _buildLastStatusUI(context),
            ),
            Expanded(
              child: _buildSipDays(context),
            ),
          ],
        ),
        SizedBox(height: 26),
        Row(
          children: [
            _buildStartEndDate(context,
                isStartDate: true,
                crossAxisAlignment: CrossAxisAlignment.start),
            Spacer(),
            _buildStartEndDate(context, isStartDate: false)
          ],
        ),
      ],
    );
  }

  Widget _buildSipBookCardDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildClientDetails(context),
            ),
            Expanded(
              child: _buildSipDays(context),
            ),
          ],
        ),
        SizedBox(height: 26),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildLastStatusUI(context),
            ),
            _buildStartEndDate(context, isStartDate: true),
          ],
        ),
      ],
    );
  }

  String? _getSipDisplayName(SipUserDataModel sipUserData) {
    if (sipUserData.goalType == GoalType.ANY_FUNDS) {
      return sipData.fundName;
    } else {
      return sipData.goalName;
    }
  }

  Widget _buildSipDays(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            text: getSipDateStr(sipData.sipDays),
            style: Theme.of(context).primaryTextTheme.headlineSmall,
            children: [
              WidgetSpan(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: buildSipDaysInfoIcon(sipData.sipDays, context),
                ),
              )
            ],
          ),
          textAlign: TextAlign.right,
        ),
        Padding(
          padding: EdgeInsets.only(top: 5.0),
          child: Text(
            'SIP Day(s)',
            textAlign: TextAlign.right,
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  color: ColorConstants.tertiaryBlack,
                  overflow: TextOverflow.ellipsis,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildLastStatusUI(BuildContext context) {
    String lastStatusDescription =
        getSipLastStatusDescription(sipData.lastSipStatus);
    Color lastStatusTextColor =
        getSipLastStatusTextColor(sipData.lastSipStatus);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (lastStatusDescription.isNotNullOrEmpty)
              Flexible(
                child: MarqueeWidget(
                  child: Text(
                    lastStatusDescription,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(color: lastStatusTextColor),
                  ),
                ),
              ),
            if (lastStatusDescription.isNotNullOrEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3),
                child: Text(
                  '·',
                  style: Theme.of(context).primaryTextTheme.headlineSmall,
                ),
              ),
            Text(
              sipData.lastSipDate != null
                  ? DateFormat('dd-MM-yyyy').format(sipData.lastSipDate!)
                  : '-',
              style: Theme.of(context).primaryTextTheme.headlineSmall,
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          'Last Sip Status',
          style: Theme.of(context)
              .primaryTextTheme
              .headlineSmall!
              .copyWith(color: ColorConstants.tertiaryBlack),
        )
      ],
    );
  }

  Widget _buildStartEndDate(BuildContext context,
      {bool isStartDate = true,
      CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.end}) {
    DateTime? date = isStartDate ? sipData.startDate : sipData.endDate;
    return CommonUI.buildColumnTextInfo(
      crossAxisAlignment: crossAxisAlignment,
      title: date != null ? DateFormat('dd-MM-yyyy').format(date!) : '-',
      titleStyle: Theme.of(context).primaryTextTheme.headlineSmall,
      subtitle: '${isStartDate ? 'Start' : 'End'} Date',
      subtitleStyle: Theme.of(context)
          .primaryTextTheme
          .headlineSmall!
          .copyWith(color: ColorConstants.tertiaryBlack),
    );
  }

  Widget _buildClientDetails(BuildContext context) {
    return CommonUI.buildColumnTextInfo(
      title: (sipData.name ?? '-').toTitleCase(),
      titleMaxLength: 2,
      titleStyle: Theme.of(context).primaryTextTheme.headlineSmall,
      subtitle: sipData.phoneNumber ?? '-',
      subtitleStyle: Theme.of(context)
          .primaryTextTheme
          .headlineSmall!
          .copyWith(color: ColorConstants.tertiaryBlack),
    );
  }

  Widget _buildSipStatusText(BuildContext context, SipUserDataModel sipData) {
    String statusText = '';
    Color textColor;

    if (sipData.isPaused ?? false) {
      statusText = "Paused";
      textColor = ColorConstants.yellowAccentColor;
    } else if (sipData.isSipActive ?? false) {
      statusText = "Active";
      textColor = ColorConstants.greenAccentColor;
    } else {
      statusText = "Inactive";
      textColor = ColorConstants.lightPrimaryAppv2Color;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: textColor.withOpacity(0.15),
      ),
      child: Text(
        statusText,
        style: Theme.of(context)
            .primaryTextTheme
            .headlineSmall!
            .copyWith(color: textColor),
      ),
    );
  }
}
