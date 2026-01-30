import 'dart:math';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/advisor/sip_book_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_bar_graph.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:core/modules/advisor/models/sip_metric_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:get/get.dart';

class CurrentMonthSipGraph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SipBookController>(
      id: 'daily-sip',
      initState: (_) {
        final controller = Get.find<SipBookController>();
        final currentWeek = (DateTime.now().day / 7).ceil();
        // max 4 week
        final index = min(currentWeek - 1, 3);
        controller.updateGraphIndex(index);
      },
      builder: (controller) {
        if (controller.dailySipCountResponse.state == NetworkState.loading) {
          return SkeltonLoaderCard(height: 200, radius: 0);
        }

        if (controller.dailySipCountResponse.state == NetworkState.error) {
          return RetryWidget(
            controller.sipMetricResponse.message,
            onPressed: () {
              controller.getDailySipCount();
            },
          );
        }
        final month = getMonthDescription(DateTime.now().month);

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColorConstants.borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$month's SIP Calendar",
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.black,
                        ),
                  ),
                  _buildDateWidget(context, controller)
                ],
              ),
              SizedBox(height: 10),
              _buildChartCarousel(
                getChartCarouselUI(controller),
                controller,
                context,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChartCarousel(
    List<Widget> children,
    SipBookController controller,
    BuildContext context,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 250,
          child: Swiper.children(
            loop: true,
            index: controller.swiperController.index,
            onIndexChanged: (value) {
              controller.updateGraphIndex(value);
            },
            // Dot Indicator
            controller: controller.swiperController,
            children: children,
          ),
        ),
        Text(
          'SIP Dates',
          style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                color: ColorConstants.black,
              ),
        ),
        SizedBox(height: 10),
        carouselDotIndicator(controller.swiperController.index),
      ],
    );
  }

  Widget carouselDotIndicator(int selectedIndex) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
        (index) {
          final isSelected = selectedIndex == index;
          return Container(
            width: isSelected ? 6 : 4,
            height: isSelected ? 6 : 4,
            margin: EdgeInsets.symmetric(horizontal: 2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? Color(0xffACACAC)
                  : Color(0xffD9D9D980).withOpacity(0.5),
            ),
          );
        },
      ),
    );
  }

  List<Widget> getChartCarouselUI(SipBookController controller) {
    final totalDataLength = controller.dailySipCountData.length;
    if (totalDataLength.isNullOrZero) {
      controller.dailySipCountData = List<DailySipModel>.generate(
        28,
        (index) {
          return DailySipModel(count: 0, amount: 0, day: index + 1);
        },
      );
    }
    if (totalDataLength < 28) {
      while (totalDataLength != 28) {
        final day = controller.dailySipCountData.last.day! + 1;
        controller.dailySipCountData.add(
          DailySipModel(count: 0, amount: 0, day: day),
        );
      }
    }
    return List<Widget>.generate(
      4,
      (index) {
        final startingIndex = index * 7;
        final graphData = controller.dailySipCountData
            .sublist(startingIndex, startingIndex + 7);
        return Padding(
          padding: const EdgeInsets.only(top: 30),
          child: CommonBarGraph(
            totalBar: 7,
            getLeftTitle: (value) {
              return value.toStringAsFixed(1);
            },
            getBottomTitle: (value) {
              return (startingIndex + value + 1).toStringAsFixed(0);
            },
            isDailyGraph: true,
            getBarHeight: (index) {
              return graphData[index].count!.toDouble();
            },
            getToolTipText: (index) {
              final amount =
                  WealthyAmount.currencyFormat(graphData[index].amount, 1);
              final count = '${graphData[index].count} SIP(s),';
              return '$count $amount';
            },
          ),
        );
      },
    );
  }

  Widget _buildDateWidget(BuildContext context, SipBookController controller) {
    final startingIndex = controller.swiperController.index * 7;
    final dateText = (startingIndex + 1).numberPattern +
        ' - ' +
        (startingIndex + 7).numberPattern;
    final isPreviousDisabled = startingIndex == 0;
    final isNextDisabled = startingIndex == 21;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            if (isPreviousDisabled) {
              return null;
            } else {
              controller.swiperController.previous();
            }
          },
          child: Icon(
            Icons.arrow_back_ios,
            size: 16,
            color: isPreviousDisabled
                ? Color(0xffE5E5E5)
                : ColorConstants.primaryAppColor,
          ),
        ),
        Text(
          dateText,
          style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                color: ColorConstants.black,
              ),
        ),
        InkWell(
          onTap: () {
            if (isNextDisabled) {
              return null;
            } else {
              controller.swiperController.next();
            }
          },
          child: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: isNextDisabled
                ? Color(0xffE5E5E5)
                : ColorConstants.primaryAppColor,
          ),
        ),
      ],
    );
  }
}
