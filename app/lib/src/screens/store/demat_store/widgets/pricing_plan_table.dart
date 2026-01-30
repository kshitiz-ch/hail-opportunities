import 'dart:math';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/demat/demat_proposal_controller.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:core/modules/broking/models/broking_plan_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PricingPlanTable extends StatelessWidget {
  const PricingPlanTable({super.key, required this.controller});

  final DematProposalController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 120,
              height: 70,
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: ColorConstants.borderColor)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Default Plan',
                      style: context.titleLarge!.copyWith(
                        color: ColorConstants.tertiaryBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    if (controller.defaultPlan?.planCode != null)
                      Row(
                        children: [
                          Flexible(
                            child: MarqueeWidget(
                              child: Text(
                                controller.defaultPlan?.planName ?? "-",
                                style: context.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(
                            Icons.check_circle_outline_rounded,
                            color: ColorConstants.greenAccentColor,
                            size: 12,
                          )
                        ],
                      ),
                  ],
                ),
              ),
            ),
            _buildTableTitleRow(context, 'Equity Delivery'),
            _buildTableTitleRow(context, 'Equity Intraday'),
            _buildTableTitleRow(context, 'Equity Future'),
            _buildTableTitleRow(context, 'Equity Options'),
          ],
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: ColorConstants.borderColor),
              borderRadius: BorderRadius.circular(2),
            ),
            // fix : fix iOS issue: Scrollbar position is wrong in horizontal ListView
            // https://github.com/flutter/flutter/issues/57920#issuecomment-893970066
            child: MediaQuery(
              data: MediaQuery.of(context).removePadding(removeBottom: true),
              child: SafeArea(
                child: RawScrollbar(
                  thumbVisibility: false,
                  thumbColor: ColorConstants.tertiaryBlack.withOpacity(0.4),
                  thickness: controller.brokingPlans.length > 3 ? 3 : 0,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            ...controller.brokingPlans.mapIndexed((x, index) {
                              bool isLastColumn =
                                  index == controller.brokingPlans.length - 1;

                              return _buildTableHeader(
                                context,
                                x,
                                isDefaultPlan: x.planCode ==
                                    controller.defaultPlan?.planCode,
                                isLastColumn: isLastColumn,
                              );
                            }).toList()
                          ],
                        ),
                        _buildTableRow(context, BrokingChargeType.Delivery,
                            isOdd: true),
                        _buildTableRow(context, BrokingChargeType.Intraday),
                        _buildTableRow(context, BrokingChargeType.Future,
                            isOdd: true),
                        _buildTableRow(context, BrokingChargeType.Options),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableTitleRow(BuildContext context, String text) {
    return Container(
      width: 120,
      height: 60,
      decoration: BoxDecoration(
        color: ColorConstants.secondaryButtonColor,
        border: Border(
          bottom: BorderSide(
            color: ColorConstants.borderColor,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: context.titleLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, BrokingChargeType chargeType,
      {bool isOdd = false}) {
    return Container(
      color: isOdd ? ColorConstants.secondaryWhite : Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              ...controller.brokingPlans.mapIndexed((x, index) {
                bool isLastColumn = index == controller.brokingPlans.length - 1;
                SegmentCharge? segmentCharge =
                    getSegmentChargeByType(x, chargeType);
                return _buildValues(
                  context,
                  segmentCharge,
                  controller.planSelected?.planCode == x.planCode,
                  isLastColumn: isLastColumn,
                );
              }).toList()
            ],
          ),
        ],
      ),
    );
  }

  SegmentCharge? getSegmentChargeByType(
      BrokingPlanModel plan, BrokingChargeType chargeType) {
    switch (chargeType) {
      case BrokingChargeType.Delivery:
        return plan.equityDelivery;
      case BrokingChargeType.Intraday:
        return plan.equityIntraday;
      case BrokingChargeType.Future:
        return plan.equityFuture;
      case BrokingChargeType.Options:
        return plan.equityOptions;
      default:
        return null;
    }
  }

  Widget _buildValues(context, SegmentCharge? charge, bool isSelected,
      {bool isLastColumn = false}) {
    return GetBuilder<DematProposalController>(builder: (controller) {
      double width = max(
          (MediaQuery.of(context).size.width - 32) /
              controller.brokingPlans.length,
          130);

      return Container(
        width: width,
        height: 60,
        decoration: BoxDecoration(
          border: !isLastColumn
              ? Border(
                  right: BorderSide(color: ColorConstants.borderColor),
                )
              : null,
        ),
        child: Container(
          margin: EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if ((charge?.description ?? "").length < 40)
                Text(
                  charge?.description ?? "-",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .titleLarge!
                      .copyWith(
                          color: ColorConstants.black,
                          fontWeight: FontWeight.w400),
                )
              else
                MarqueeWidget(
                  child: Text(
                    charge?.description ?? "-",
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .titleLarge!
                        .copyWith(
                            color: ColorConstants.black,
                            fontWeight: FontWeight.w400),
                  ),
                )
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTableHeader(context, BrokingPlanModel plan,
      {bool isDefaultPlan = false, bool isLastColumn = true}) {
    return GetBuilder<DematProposalController>(
      builder: (controller) {
        // bool isDisabled = controller.isAuthorised == false &&
        //     (controller.planSelected?.planCode != plan.planCode);
        bool isPlanSelected =
            plan.planCode == controller.planSelected?.planCode;

        double width = max(
            (MediaQuery.of(context).size.width - 32) /
                controller.brokingPlans.length,
            130);

        double containerWidth = width;

        if (!isLastColumn && !isPlanSelected) {
          containerWidth = width - 1;
        }

        return Container(
          width: width,
          decoration: BoxDecoration(
            border: !isLastColumn && !isPlanSelected
                ? Border(
                    right: BorderSide(color: ColorConstants.borderColor),
                  )
                : null,
          ),
          child: Row(
            children: [
              Column(
                children: [
                  InkWell(
                    onTap: () {
                      controller.updatePlanSelected(plan);
                    },
                    child: Container(
                      width: containerWidth,
                      height: 70,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: isPlanSelected
                            ? Border.all(
                                color: ColorConstants.primaryAppColor,
                              )
                            : Border(
                                bottom: BorderSide(
                                    color: ColorConstants.borderColor),
                              ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          children: [
                            if (isPlanSelected)
                              Icon(
                                Icons.check_circle,
                                color: ColorConstants.primaryAppColor,
                                size: 16,
                              )
                            else
                              Icon(
                                Icons.radio_button_unchecked,
                                color: ColorConstants.tertiaryBlack,
                                size: 16,
                              ),
                            SizedBox(
                              height: 4,
                            ),
                            MarqueeWidget(
                              child: Text(
                                plan.planName ?? '-',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headlineSmall!
                                    .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isPlanSelected
                                          ? ColorConstants.primaryAppColor
                                          : ColorConstants.black,
                                    ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
