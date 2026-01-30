import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/store/mutual_fund/funds_controller.dart';
import 'package:app/src/screens/store/mf_list_old/widgets/fund_filters_bottomsheet.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/config/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterButtons extends StatelessWidget {
  const FilterButtons({Key? key, this.tag}) : super(key: key);

  final String? tag;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FundsController>(
      id: 'funds',
      tag: tag,
      global: true,
      builder: (controller) {
        int noOfFilterSaved = controller.filtersSaved.entries.length +
            (controller.minAmountFilter! > 0 ? 1 : 0);
        bool isFiltersSaved = noOfFilterSaved > 0;
        bool isSortingApplied = controller.sortingSaved.isNotNullOrEmpty;

        return Row(
          children: [
            Stack(
              children: [
                InkWell(
                  onTap: () {
                    CommonUI.showBottomSheet(
                      context,
                      borderRadius: 16.0,
                      isScrollControlled: true,
                      child: FundFiltersBottomSheet(tag: tag),
                    ).then((value) async {
                      if (Get.isRegistered<FundsController>()) {
                        FundsController controller =
                            Get.find<FundsController>();
                        controller.removeNonSavedFilters();
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Image.asset(
                      AllImages().fundFilterIcon,
                      height: 14,
                      width: 14,
                    ),
                  ),
                ),
                if (isFiltersSaved) CommonUI.buildRedDot(rightOffset: 5)
              ],
            ),
            SizedBox(width: 10),
            Stack(
              children: [
                InkWell(
                  onTap: () {
                    CommonUI.showBottomSheet(
                      context,
                      borderRadius: 16.0,
                      isScrollControlled: true,
                      child: FundFiltersBottomSheet(
                          filterMode: FilterMode.sort, tag: tag),
                    ).then((value) {
                      if (Get.isRegistered<FundsController>()) {
                        FundsController controller =
                            Get.find<FundsController>();
                        controller.removeNonSavedFilters();
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Image.asset(AllImages().swapIcon, width: 13),
                  ),
                ),
                if (isSortingApplied) CommonUI.buildRedDot(rightOffset: 8)
              ],
            ),
          ],
        );
      },
    );
  }
}
