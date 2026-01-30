import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/client.dart';
import 'package:app/src/controllers/client/goal/goal_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/base_switch_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/goal_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StpCard extends StatelessWidget {
  final BaseSwitch stp;
  // final ClientSipController? controller =
  //     Get.isRegistered<ClientSipController>()
  //         ? Get.find<ClientSipController>()
  //         : null;

  StpCard({
    Key? key,
    required this.stp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle =
        Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
            );

    GoalModel? goal = Get.find<GoalController>().goal;
    return InkWell(
      onTap: () {
        AutoRouter.of(context).push(
          StpDetailRoute(
            stp: stp,
            goal: goal!,
            client: Get.find<GoalController>().client,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: ColorConstants.primaryCardColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name, Status, Amount
            _buildCardHeader(context, goal, textStyle),

            _buildDivider(),

            // Days, Start Date
            _buildCardFooter(context, textStyle)
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(
      BuildContext context, GoalModel? goal, TextStyle textStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDisplayName(stp, goal) ?? '',
                  maxLines: 2,
                  style: textStyle,
                ),
                SizedBox(height: 10),
                CommonClientUI.goalTransactStatus(
                  context,
                  isPaused: stp.isPaused,
                  endDate: stp.endDate,
                )
              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topRight,
              child: CommonUI.buildColumnTextInfo(
                gap: 6,
                title: WealthyAmount.currencyFormat(stp.amount, 0),
                subtitle: 'Amount',
                titleStyle: textStyle.copyWith(fontSize: 14),
                subtitleStyle: textStyle.copyWith(
                  fontSize: 14,
                  color: ColorConstants.tertiaryBlack,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: CommonUI.buildProfileDataSeperator(
        color: ColorConstants.borderColor,
        height: 1,
        width: double.infinity,
      ),
    );
  }

  Widget _buildCardFooter(BuildContext context, TextStyle textStyle) {
    List<int>? days =
        (stp.days ?? '').split(',').map((e) => int.parse(e.trim())).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.access_time,
                      color: ColorConstants.tertiaryBlack,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      getGoalTransactDays(days),
                      style: textStyle.copyWith(
                        fontSize: 14,
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Every month',
                  style: textStyle.copyWith(
                    fontSize: 12,
                    color: ColorConstants.tertiaryBlack,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                stp.startDate != null
                    ? DateFormat('dd MMM yyyy').format(stp.startDate!)
                    : '-',
                style: textStyle.copyWith(
                  fontSize: 14,
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Start Date',
                style: textStyle.copyWith(
                  fontSize: 12,
                  color: ColorConstants.tertiaryBlack,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

String? _getDisplayName(BaseSwitch stp, GoalModel? goal) {
  if (stp.switchFunds.isNotNullOrEmpty &&
      stp.switchFunds!.first.switchoutSchemeName.isNotNullOrEmpty) {
    return stp.switchFunds!.first.switchoutSchemeName;
  } else {
    return goal?.displayName;
  }
}

Widget _buildPausedOrActiveText(BuildContext context, BaseSwitch stp) {
  Color iconColor;
  IconData icon;
  String statusText;

  if (stp.isPaused == true) {
    iconColor = ColorConstants.yellowAccentColor;
    icon = Icons.pause;
    statusText = 'Paused';
  } else {
    iconColor = ColorConstants.greenAccentColor;
    icon = Icons.done;
    statusText = 'Active';
  }

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        margin: EdgeInsets.only(right: 6),
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: iconColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: ColorConstants.white,
        ),
      ),
      Text(
        statusText,
        style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
              color: ColorConstants.black,
            ),
      )
    ],
  );
}

String getStpDateStr(BaseSwitch stp) {
  String dateStr = '';
  if (stp.days.isNotNullOrEmpty) {
    List<int>? days =
        stp.days?.split(',').map((e) => WealthyCast.toInt(e.trim())!).toList();
    if (days.isNotNullOrEmpty) {
      if (days!.length > 3) {
        dateStr = days.sublist(0, 3).map((e) => e.numberPattern).join(', ');
      } else {
        dateStr = days.map((e) => e.numberPattern).join(', ');
      }
      final remainingDays = days.length - 3;
      if (remainingDays > 0) {
        dateStr += ', +$remainingDays days';
      }
    }
  } else {
    dateStr = '-';
  }
  return dateStr;
}
