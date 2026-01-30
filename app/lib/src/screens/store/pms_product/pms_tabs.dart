import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/store/pms/pms_product_controller.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PmsTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<PMSProductController>(
      id: 'navigation',
      builder: (controller) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTabs(context, PMSNavigationTab.Strategy, controller),
            _buildTabs(context, PMSNavigationTab.Portfolio, controller),
          ],
        );
      },
    );
  }

  Widget _buildTabs(
    BuildContext context,
    PMSNavigationTab tab,
    PMSProductController controller,
  ) {
    bool isSelected = controller.selectedTab == tab;
    return Expanded(
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
                color: isSelected
                    ? ColorConstants.primaryAppColor
                    : Colors.transparent),
          ),
        ),
        child: InkWell(
          onTap: () {
            controller.updateNavigationTab(tab);
          },
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            child: MarqueeWidget(
              child: Text(
                tab.name.replaceAll("_", " "),
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? ColorConstants.black
                            : ColorConstants.tertiaryBlack),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
