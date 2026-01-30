import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/store/fixed_deposit/fixed_deposits_controller.dart';
import 'package:app/src/screens/store/fixed_deposit_list/widgets/month_input_bottom_sheet.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/custom_slider_thumb_shape.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SliderField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<FixedDepositsController>(
      builder: (controller) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, controller),
            SizedBox(height: 20),
            _buildSlider(context, controller),
          ],
        );
      },
    );
  }

  Widget _buildSlider(
      BuildContext context, FixedDepositsController controller) {
    int totalDivisons = controller.fdListModel!.tenureMonths!.max! ~/ 12;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            //Divider
            if (totalDivisons > 0)
              LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List<Widget>.generate(
                      totalDivisons,
                      (index) {
                        final dividerText =
                            controller.fdListModel!.tenureMonths!.min! *
                                (index + 1);

                        return Container(
                          height: 70,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // height 50
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 15),
                                height: 20,
                                width: 1,
                                color:
                                    (index == 0 || index == totalDivisons - 1)
                                        ? Colors.transparent
                                        : ColorConstants.borderColor,
                              ),
                              // height 20
                              Container(
                                height: 20,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: index == 0 ? 5 : 0,
                                    right: index == totalDivisons - 1 ? 5 : 0,
                                  ),
                                  child: Text(
                                    '${dividerText}',
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .titleMedium!
                                        .copyWith(
                                          color: ColorConstants.tertiaryBlack,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            // Slider
            Container(
              height: 50,
              // fix:increase tap area
              // height 50 == divider height
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  minThumbSeparation: 0,
                  activeTrackColor: ColorConstants.primaryAppColor,
                  inactiveTrackColor: ColorConstants.borderColor,
                  trackShape: RoundedRectSliderTrackShape(),
                  thumbShape: CustomSliderThumbShape(
                    elevation: 4,
                    pressedElevation: 8,
                  ),
                  thumbColor: ColorConstants.primaryAppColor,
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 0.0),
                  tickMarkShape: RoundSliderTickMarkShape(),
                  activeTickMarkColor: Colors.transparent,
                  inactiveTickMarkColor: Colors.transparent,
                ),
                child: Slider(
                  value: controller.selectedTenureMonthPeriod!.toDouble(),
                  min: controller.fdListModel!.tenureMonths!.min!.toDouble(),
                  max: controller.fdListModel!.tenureMonths!.max!.toDouble(),
                  // slider move in multiple of 1
                  divisions: (controller.fdListModel!.tenureMonths!.max! -
                      controller.fdListModel!.tenureMonths!.min!),
                  // slider should move in multiple of 6
                  // divisions: (controller.fdListModel.tenureMonths.max -
                  //         controller.fdListModel.tenureMonths.min) ~/
                  //     6,
                  onChangeEnd: (double newValue) {
                    controller.updateTenurePeriod(
                      month: newValue.toInt(),
                      isFromSlider: true,
                      callApi: true,
                    );
                  },
                  onChanged: (double newValue) {
                    controller.updateTenurePeriod(
                      month: newValue.toInt(),
                      isFromSlider: true,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(
      BuildContext context, FixedDepositsController controller) {
    int year = controller.selectedTenureMonthPeriod! ~/ 12;
    int month = controller.selectedTenureMonthPeriod! % 12;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tenure Period',
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    color: ColorConstants.black,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            SizedBox(height: 8),
            Text(
              'Slide to Customize',
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    color: ColorConstants.tertiaryBlack,
                  ),
            ),
          ],
        ),
        Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                CommonUI.showBottomSheet(
                  context,
                  isScrollControlled: false,
                  isDismissible: false,
                  child: MonthInputBottomSheet(),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: ColorConstants.secondaryAppColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    width: 0.2,
                    color: ColorConstants.primaryAppColor,
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      '${controller.selectedTenureMonthPeriod} Months',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                            color: ColorConstants.primaryAppColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(width: 4),
                    Image.asset(
                      AllImages().fdEditIcon,
                      width: 10,
                      height: 10,
                    )
                  ],
                ),
              ),
            ),
            if (year > 0)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  '$year Year${year > 1 ? 's' : ''} ${month > 0 ? "$month Month${month > 1 ? 's' : ''}" : ""}',
                  textAlign: TextAlign.center,
                  style:
                      Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                            color: ColorConstants.primaryAppColor,
                          ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
