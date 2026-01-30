import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_edit_fund_controller.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

class SelectStartMonthBottomSheet extends StatefulWidget {
  const SelectStartMonthBottomSheet({Key? key}) : super(key: key);

  @override
  State<SelectStartMonthBottomSheet> createState() =>
      _SelectStartMonthBottomSheetState();
}

class _SelectStartMonthBottomSheetState
    extends State<SelectStartMonthBottomSheet> {
  int selectedYear = DateTime.now().year;

  void initState() {
    DateTime? startDate =
        Get.find<BasketEditFundController>().sipData.startDate;
    if (startDate != null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          selectedYear = startDate.year;
        });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 100),
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Start Month',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'SIP will start from this month',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.tertiaryBlack,
                        ),
                  ),
                ],
              ),
              CommonUI.bottomsheetCloseIcon(context)
            ],
          ),
          SizedBox(height: 22),
          GetBuilder<BasketEditFundController>(
            builder: (controller) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          if (selectedYear >
                              controller.startYearsAvailable.first) {
                            setState(() {
                              selectedYear--;
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: ColorConstants.secondaryAppColor,
                              shape: BoxShape.circle),
                          child: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: ColorConstants.primaryAppColor,
                            size: 12,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          selectedYear.toString(),
                          style:
                              Theme.of(context).primaryTextTheme.headlineLarge,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (selectedYear <
                              controller.startYearsAvailable.last) {
                            setState(() {
                              selectedYear++;
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: ColorConstants.secondaryAppColor,
                              shape: BoxShape.circle),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: ColorConstants.primaryAppColor,
                            size: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  GridView.count(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20).copyWith(top: 30),
                    crossAxisCount: 3,
                    childAspectRatio: 85 / 45,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    shrinkWrap: true,
                    children: List.generate(
                      12,
                      (index) {
                        return _buildMonthTile(index + 1, controller);
                      },
                    ),
                  )
                ],
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildMonthTile(int monthNumber, BasketEditFundController controller) {
    bool isDisabled = controller.startMonths.firstWhereOrNull(
            (DateTime element) =>
                element.month == monthNumber && element.year == selectedYear) ==
        null;
    bool isSelected = controller.sipData.startDate?.month == monthNumber &&
        controller.sipData.startDate?.year == selectedYear;

    return InkWell(
      onTap: () {
        if (isDisabled) return;
        DateTime date = DateTime(selectedYear, monthNumber);
        controller.updateStartDate(date);
        AutoRouter.of(context).popForced();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: isSelected
              ? ColorConstants.primaryAppColor
              : isDisabled
                  ? Colors.white
                  : ColorConstants.secondaryAppColor,
          border: isDisabled
              ? Border.all(color: ColorConstants.borderColor2)
              : null,
        ),
        child: Center(
          child: Text(
            getMonthDescription(monthNumber).substring(0, 3),
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                color: isSelected
                    ? ColorConstants.white
                    : isDisabled
                        ? ColorConstants.borderColor2
                        : ColorConstants.primaryAppColor),
          ),
        ),
      ),
    );
  }
}
