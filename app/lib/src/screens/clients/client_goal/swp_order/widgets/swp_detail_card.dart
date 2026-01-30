import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/goal/swp_detail_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SwpDetailCard extends StatelessWidget {
  final int swpIndex;

  SwpDetailCard({Key? key, required this.swpIndex}) : super(key: key);

  final controller = Get.find<SwpDetailController>();

  @override
  Widget build(BuildContext context) {
    final swpData = controller.pastSwps[swpIndex];
    final rowData = <String>[
      getDateMonthYearFormat(swpData.swpDate),
      WealthyAmount.currencyFormat(swpData.amount, 0),
      // status mapping is same for sip & swp
      getSIPV2StageText(swpData.status ?? '')
    ];

    final color = swpIndex % 2 == 0
        ? ColorConstants.secondaryWhite
        : ColorConstants.white;
    final texStyle = Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
          color: ColorConstants.black,
          fontWeight: FontWeight.w400,
          overflow: TextOverflow.ellipsis,
        );
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ListTile(
        tileColor: color,
        leading: Text(
          rowData[0],
          style: texStyle,
        ),
        title: Text(
          rowData[1],
          textAlign: TextAlign.center,
          style: texStyle,
        ),
        trailing: Text(
          rowData[2],
          style: texStyle.copyWith(
            color: getSIPV2StageTextColor(swpData.status ?? ''),
          ),
        ),
      ),
    );
  }
}
