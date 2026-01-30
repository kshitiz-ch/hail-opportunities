import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/client.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/client/goal/goal_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/base_swp_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SwpCard extends StatelessWidget {
  final BaseSwpModel baseSwp;

  SwpCard({Key? key, required this.baseSwp}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isInactive = baseSwp.endDate?.isBefore(DateTime.now()) ?? false;
    final textStyle =
        Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
            );

    return InkWell(
      onTap: () {
        AutoRouter.of(context).push(
          SwpDetailRoute(
            selectedBaseSwp: baseSwp,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isInactive
              ? ColorConstants.white
              : ColorConstants.primaryCardColor,
          borderRadius: BorderRadius.circular(4),
          border: isInactive
              ? Border.all(color: ColorConstants.borderColor)
              : Border(),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
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
                          getSWPDisplayName(baseSwp),
                          maxLines: 2,
                          style: textStyle,
                        ),
                        CommonClientUI.goalTransactStatus(
                          context,
                          isPaused: baseSwp.isPaused,
                          endDate: baseSwp.endDate,
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: CommonUI.buildColumnTextInfo(
                        gap: 6,
                        title: WealthyAmount.currencyFormat(baseSwp.amount, 0),
                        subtitle: 'SWP Amount',
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
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: CommonUI.buildProfileDataSeperator(
                color: ColorConstants.borderColor,
                height: 1,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: ColorConstants.tertiaryBlack,
                    size: 16,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Text(
                              getGoalTransactDays(baseSwp.days),
                              style: textStyle.copyWith(
                                fontSize: 14,
                                color: ColorConstants.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String getSWPDisplayName(BaseSwpModel baseSwp) {
  String? displayName = '';
  final controller = Get.find<GoalController>();

  try {
    if (baseSwp.swpFunds.isNotNullOrEmpty && baseSwp.swpFunds!.length == 1) {
      displayName = baseSwp.swpFunds!.first.schemeName;
    } else {
      displayName = controller.goal?.displayName;
    }
    if (displayName.isNullOrEmpty) {
      displayName = notAvailableText;
    }
  } catch (error) {
    LogUtil.printLog(error);
  }
  return displayName ?? '';
}
