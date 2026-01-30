import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';

import 'choose_investment_dates.dart';

class SipDaySelectorNew extends StatelessWidget {
  const SipDaySelectorNew({
    Key? key,
    required this.selectedSipDays,
    required this.allowedSipDays,
    required this.onUpdateSipDays,
    required this.sipAmount,
  }) : super(key: key);

  final List<int> selectedSipDays;
  final List<int> allowedSipDays;
  final double sipAmount;
  final dynamic Function(List<int>) onUpdateSipDays;

  @override
  Widget build(BuildContext context) {
    String sipDays = '';
    if (selectedSipDays.isNotNullOrEmpty) {
      if (selectedSipDays.length > 3) {
        sipDays = selectedSipDays.sublist(0, 3).join(', ');
      } else {
        sipDays = selectedSipDays.join(', ');
      }
      final remainingDays = selectedSipDays.length - 3;
      if (remainingDays > 0) {
        sipDays += ', +$remainingDays days';
      }
    }
    final textStyle = Theme.of(context)
        .primaryTextTheme
        .headlineSmall
        ?.copyWith(fontWeight: FontWeight.w500);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select SIP Date',
          style: Theme.of(context)
              .primaryTextTheme
              .headlineSmall!
              .copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        Text(
          'SIP will debit on selected day(s) every month',
          style: Theme.of(context)
              .primaryTextTheme
              .headlineSmall!
              .copyWith(color: ColorConstants.tertiaryBlack),
        ),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: ColorConstants.secondaryWhite,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: GestureDetector(
            onTap: () {
              // if (controller.amountFocusNode.hasFocus) {
              //   controller.amountFocusNode.nextFocus();
              // }
              CommonUI.showBottomSheet(
                context,
                child: ChooseInvestmentDate(
                  description: 'SIP will debit on selected day(s) every month',
                  allowedSipDays: allowedSipDays,
                  selectedSipDays: selectedSipDays,
                  onUpdateSipDays: onUpdateSipDays,
                ),
              );
            },
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: ColorConstants.primaryAppColor,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: sipDays.isNotNullOrEmpty
                        ? Text(
                            sipDays,
                            style: textStyle?.copyWith(
                              color: ColorConstants.black,
                            ),
                          )
                        : Text(
                            'Choose SIP Day(s)',
                            style: textStyle,
                          ),
                  ),
                ),
                if (sipDays.isNotNullOrEmpty)
                  Text(
                    'Edit',
                    style: textStyle,
                  )
                else
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.black,
                    size: 20,
                  )
              ],
            ),
          ),
        ),
        if (selectedSipDays.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.symmetric(vertical: 10).copyWith(left: 20),
            decoration: BoxDecoration(
              color: ColorConstants.sandColor,
              border: Border.all(color: ColorConstants.blondColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Image.asset(AllImages().calculatorYellow, width: 15),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Monthly Debit ${WealthyAmount.currencyFormat(sipAmount * selectedSipDays.length, 0)}',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${selectedSipDays.length} Days ($sipDays) x ${WealthyAmount.currencyFormat(sipAmount, 0)}',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(color: ColorConstants.tertiaryBlack),
                        ),
                        Tooltip(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                              color: ColorConstants.black,
                              borderRadius: BorderRadius.circular(6)),
                          triggerMode: TooltipTriggerMode.tap,
                          textStyle: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                          message: '${selectedSipDays.length} Debits/Month',
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(
                              Icons.info_outline,
                              color: ColorConstants.tertiaryBlack,
                              size: 12,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
