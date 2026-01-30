import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/advisor/sip_book_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SipListingTabSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SipBookController>(
      id: 'sip-tab',
      builder: (controller) {
        return SizedBox(
          height: 30,
          child: Row(
            children: [
              Expanded(
                child: _buldCategoryPill(
                  context,
                  controller,
                  controller.sipBookTabs.first,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buldCategoryPill(
                  context,
                  controller,
                  controller.sipBookTabs[1],
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buldCategoryPill(
                  context,
                  controller,
                  controller.sipBookTabs.last,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buldCategoryPill(
    BuildContext context,
    SipBookController controller,
    SipBookTabType tab,
  ) {
    bool isSelected = controller.selectedSipBookTab == tab;

    return InkWell(
      onTap: () {
        controller.onSipTabChange(tab);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorConstants.primaryAppColor.withOpacity(0.05)
              : ColorConstants.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: isSelected
                  ? ColorConstants.primaryAppColor
                  : ColorConstants.secondarySeparatorColor),
        ),
        child: Center(
          child: Text(
            tab.name,
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  color: isSelected
                      ? ColorConstants.primaryAppColor
                      : ColorConstants.tertiaryBlack,
                ),
          ),
        ),
      ),
    );
  }
}
