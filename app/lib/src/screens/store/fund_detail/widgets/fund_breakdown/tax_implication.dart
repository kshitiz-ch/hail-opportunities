import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_detail_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_score_controller.dart';
import 'package:app/src/screens/store/fund_detail/widgets/fund_breakdown/breakdown_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

class TaxImplication extends StatelessWidget {
  const TaxImplication({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FundScoreController>(
      builder: (controller) {
        return BreakdownHeader(
          isExpanded:
              Get.find<FundDetailController>().activeNavigationSection ==
                  FundNavigationTab.Tax,
          onToggleExpand: () {
            Get.find<FundDetailController>()
                .updateNavigationSection(FundNavigationTab.Tax);
          },
          title: 'Tax Implications',
          // subtitle: '',
          child: Container(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                  controller.schemeData?.taxationTypeRemarks ?? 'NA',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .titleLarge!
                      .copyWith(color: ColorConstants.tertiaryBlack),
                ),
                SizedBox(height: 15),
                Text(
                    '* Investors are advised to consult their Legal / Tax advisors in regard to tax/legal implications relating to their investments in the scheme',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .titleMedium!
                        .copyWith(color: ColorConstants.tertiaryBlack))
              ],
            ),
          ),
        );
      },
    );
  }
}
