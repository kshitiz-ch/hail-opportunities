import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/controllers/advisor/sip_book_controller.dart';
import 'package:app/src/widgets/input/sip_book_filter/transaction_filter_sort_bottomsheet.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'sip_filter_bottomsheet.dart';

class FilterButton extends StatelessWidget {
  const FilterButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SipBookController>(
      builder: (controller) {
        bool isFiltersSaved = false;
        if (controller.selectedSipBookTab == SipBookTabType.Online) {
          isFiltersSaved = controller.savedFilter != null;
        } else if (controller.selectedSipBookTab ==
            SipBookTabType.Transactions) {
          // by date filter is always applied
          isFiltersSaved = true;
        }

        return Stack(
          children: [
            InkWell(
              onTap: () {
                MixPanelAnalytics.trackWithAgentId(
                  "filter_click",
                  screen: 'sip_book',
                  screenLocation: 'sip_book',
                );

                controller.tempFilter = controller.savedFilter;

                CommonUI.showBottomSheet(
                  context,
                  borderRadius: 16.0,
                  isScrollControlled: true,
                  child: controller.selectedSipBookTab ==
                          SipBookTabType.Transactions
                      ? TransactionFilterSortBottomSheet()
                      : SipBookFilterBottomSheet(),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Image.asset(
                  AllImages().fundFilterIcon,
                  height: 18,
                  width: 18,
                ),
              ),
            ),
            if (isFiltersSaved) CommonUI.buildRedDot(rightOffset: 5)
          ],
        );
      },
    );
  }
}
