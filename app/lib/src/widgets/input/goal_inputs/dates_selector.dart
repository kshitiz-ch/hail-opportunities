import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/common/common_controller.dart';
import 'package:app/src/screens/store/common_new/widgets/choose_investment_dates.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DatesSelector extends StatelessWidget {
  const DatesSelector({
    Key? key,
    required this.selectedDays,
    required this.onChanged,
    required this.orderType,
  }) : super(key: key);

  final String orderType;
  final List<int> selectedDays;
  final Function(List<int> sipDays) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildDateHeader(context),
        ),
        _buildDateSelected(context),
      ],
    );
  }

  Widget _buildDateSelected(BuildContext context) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: selectedDays
          .map(
            (date) => _buildSelectedDateUI(date, context),
          )
          .toList(),
    );
  }

  Widget _buildSelectedDateUI(int date, BuildContext context) {
    return Container(
      width: ((SizeConfig().screenWidth! - 72) / 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ColorConstants.primaryAppv3Color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        date.numberPattern,
        textAlign: TextAlign.center,
        style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
              color: ColorConstants.primaryAppColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context) {
    String orderTypeTitle = orderType.toUpperCase();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          Text(
            'Selected $orderTypeTitle Date(s)',
            style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                  color: ColorConstants.tertiaryBlack,
                ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () {
                  CommonUI.showBottomSheet(
                    context,
                    child: ChooseInvestmentDate(
                      title: 'Choose $orderTypeTitle dates',
                      description:
                          'You can choose multiple days for $orderTypeTitle in a month',
                      // maxDaysLimit: 4,
                      allowedSipDays: Get.isRegistered<CommonController>()
                          ? Get.find<CommonController>().allowedSipDays.toList()
                          : [],
                      selectedSipDays: selectedDays,
                      onUpdateSipDays: onChanged,
                      isSip: false,
                    ),
                  );
                },
                child: Text(
                  selectedDays.isEmpty ? 'Select' : 'Edit',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall
                      ?.copyWith(
                        color: ColorConstants.primaryAppColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //   return Container(
  //     decoration: BoxDecoration(
  //       color: ColorConstants.primaryCardColor,
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: InkWell(
  //       onTap: () {
  //         CommonUI.showBottomSheet(
  //           context,
  //           child: ChooseInvestmentDate(
  //             title: title,
  //             allowedSipDays: Get.isRegistered<CommonController>()
  //                 ? Get.find<CommonController>().allowedSipDays
  //                 : [],
  //             selectedSipDays: selectedDays,
  //             onUpdateSipDays: onChanged,
  //             maxSipDaysLimit: 4, // For SWP and STP
  //           ),
  //         );
  //       },
  //       child: Padding(
  //         padding: const EdgeInsets.all(16.0),
  //         child: Row(
  //           children: [
  //             Icon(
  //               Icons.calendar_today_outlined,
  //               size: 16,
  //               color: ColorConstants.primaryAppColor,
  //             ),
  //             Expanded(
  //               child: Padding(
  //                 padding: const EdgeInsets.symmetric(horizontal: 6),
  //                 child: selectedDays.isNotNullOrEmpty
  //                     ? Text.rich(
  //                         TextSpan(
  //                           text: 'Days ',
  //                           style: textStyle?.copyWith(
  //                             color: ColorConstants.tertiaryBlack,
  //                           ),
  //                           children: [
  //                             TextSpan(
  //                               text: selectedDays.join(","),
  //                               style: textStyle?.copyWith(
  //                                 color: ColorConstants.black,
  //                               ),
  //                             )
  //                           ],
  //                         ),
  //                       )
  //                     : Text(
  //                         'Select Days',
  //                         style: textStyle,
  //                       ),
  //               ),
  //             ),
  //             if (selectedDays.isNotNullOrEmpty)
  //               Text(
  //                 'Edit',
  //                 style: textStyle,
  //               ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
