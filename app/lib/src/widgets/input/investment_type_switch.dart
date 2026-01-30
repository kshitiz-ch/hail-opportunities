import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';

class InvestmentTypeSwitch extends StatelessWidget {
  // Fields
  final InvestmentType? investmentType;
  final InvestmentType? investmentTypeAllowed;
  final Function(InvestmentType)? onChanged;
  final bool isOneTimeButtonDisabled;
  final bool? isSIPButtonDisabled;
  final String? oneTimeButtonDisableReason;
  final String? sipButtonDisableReason;
  final bool hasOneTimeBlockedfunds;
  final bool hasSipBlockedFunds;

  const InvestmentTypeSwitch({
    Key? key,
    this.investmentType,
    this.investmentTypeAllowed,
    this.onChanged,
    this.isOneTimeButtonDisabled = false,
    this.isSIPButtonDisabled = false,
    this.oneTimeButtonDisableReason,
    this.sipButtonDisableReason,
    this.hasOneTimeBlockedfunds = false,
    this.hasSipBlockedFunds = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (investmentTypeAllowed != null &&
              investmentTypeAllowed == InvestmentType.SIP)
            _buildSipButton(context)
          else if (investmentTypeAllowed != null &&
              investmentTypeAllowed == InvestmentType.oneTime)
            _buildOneTimeButton(context)
          else
            Row(
              children: [
                _buildSipButton(context),
                SizedBox(width: 10),
                _buildOneTimeButton(context),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSipButton(BuildContext context) {
    return _buildInvestmentTypeButton(
      context,
      text: 'SIP',
      isSelected: investmentType == InvestmentType.SIP,
      onPressed: () {
        if (isSIPButtonDisabled!) {
          // Show Toast
          showToast(
            context: context,
            text: sipButtonDisableReason ?? "SIP is Disabled",
          );
        } else if (hasSipBlockedFunds) {
          showToast(
              context: context,
              text:
                  "One or more selected funds have the SIP option disabled. Contact your Relationship Manager for details.",
              duration: Duration(seconds: 3));
        } else {
          onChanged!(InvestmentType.SIP);
        }
      },
    );
  }

  Widget _buildOneTimeButton(BuildContext context) {
    return _buildInvestmentTypeButton(
      context,
      text: 'One Time Purchase',
      isSelected: investmentType == InvestmentType.oneTime,
      onPressed: () {
        if (isOneTimeButtonDisabled) {
          // Show Toast
          showToast(
            context: context,
            text: oneTimeButtonDisableReason ?? "One Time Purchase is Disabled",
          );
        } else if (hasOneTimeBlockedfunds) {
          showToast(
            context: context,
            text:
                "One or more selected funds have the one-time option disabled. Contact your Relationship Manager for details",
            duration: Duration(seconds: 3),
          );
        } else {
          onChanged!(InvestmentType.oneTime);
        }
      },
    );
  }

  Widget _buildInvestmentTypeButton(
    context, {
    required String text,
    required bool isSelected,
    Function? onPressed,
  }) {
    return Container(
      constraints: BoxConstraints(minWidth: 100, maxWidth: 180),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: onPressed as void Function()?,
        child: AnimatedContainer(
          duration: 350.milliseconds,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: ColorConstants.secondaryWhite,
            borderRadius: BorderRadius.circular(8),
            border: !isSelected
                ? null
                : Border.all(
                    color: ColorConstants.primaryAppColor,
                    width: 1,
                  ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Color(0xFFE4E2ED),
                      offset: Offset(0, 12),
                      blurRadius: 14.0,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IgnorePointer(
                child: Container(
                  height: 16,
                  width: 16,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? ColorConstants.primaryAppColor
                          : ColorConstants.secondaryLightGrey,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    height: 6.26,
                    width: 6.26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? ColorConstants.primaryAppColor
                          : ColorConstants.secondaryWhite,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  text,
                  // textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        color: isSelected
                            ? ColorConstants.black
                            : ColorConstants.tertiaryGrey,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
