import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/clients/models/client_investments_model.dart';
import 'package:flutter/material.dart';

class PMSProductCard extends StatefulWidget {
  final ProductInvestmentModel product;
  final bool showAbsoluteReturn;

  const PMSProductCard({
    Key? key,
    required this.product,
    required this.showAbsoluteReturn,
  }) : super(key: key);

  @override
  State<PMSProductCard> createState() => _PMSProductCardState();
}

class _PMSProductCardState extends State<PMSProductCard> {
  bool showAdditionalDetails = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.primaryCardColor,
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          _buildReturnDetails(context),
          if (showAdditionalDetails)
            CommonUI.buildProfileDataSeperator(
                color: ColorConstants.borderColor),
          if (showAdditionalDetails) _buildAdditionalDetails(context),
          CommonUI.buildProfileDataSeperator(color: ColorConstants.borderColor),
          _buildDetailCTA(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final absoluteReturn = widget.product.unrealisedGain ?? 0;
    final returnPercentage = widget.showAbsoluteReturn
        ? widget.product.absoluteReturn ?? 0
        : widget.product.xirr ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              (widget.product.name ?? '-').toTitleCase(),
              style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: ColorConstants.black,
                  ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    absoluteReturn.isNegative
                        ? AllImages().lossIcon
                        : AllImages().gainIcon,
                    width: 12,
                    height: 12,
                  ),
                  SizedBox(width: 5),
                  Text(
                    WealthyAmount.currencyFormatWithoutTrailingZero(
                        absoluteReturn, 2),
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.black,
                        ),
                  )
                ],
              ),
              Text(
                '(${(returnPercentage * 100).toStringAsFixed(2)}%)',
                style: Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                      color: absoluteReturn.isNegative
                          ? ColorConstants.redAccentColor
                          : ColorConstants.greenAccentColor,
                    ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReturnDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16)
          .copyWith(top: 7, bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildData(
              context: context,
              key: 'Invested Value',
              value: WealthyAmount.currencyFormatWithoutTrailingZero(
                  widget.product.schemeMetaData?.netCapital, 2),
              toolTip: "Difference between capital inflow and capital outflow",
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _buildData(
              context: context,
              key: 'Current Value',
              value: WealthyAmount.currencyFormatWithoutTrailingZero(
                  widget.product.currentValue, 2),
              toolTip:
                  "Current market value of the securities in the portfolio",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
          .copyWith(right: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildData(
              context: context,
              key: 'Capital Inflow',
              value: WealthyAmount.currencyFormatWithoutTrailingZero(
                  widget.product.schemeMetaData?.inflow, 2),
              toolTip: "Sum of all cash investments made since inception",
            ),
          ),
          SizedBox(width: 2),
          Expanded(
            child: _buildData(
              context: context,
              key: 'Capital Outflow',
              value: WealthyAmount.currencyFormatWithoutTrailingZero(
                  widget.product.schemeMetaData?.outflow, 2),
              toolTip: "Sum of all cash taken out since inception",
            ),
          ),
          // SizedBox(width: 2),
          // Expanded(
          //   child: _buildData(
          //     context: context,
          //     key: 'Net Capital',
          //     value: WealthyAmount.currencyFormatWithoutTrailingZero(
          //         widget.product.schemeMetaData?.netCapital, 2),
          //     toolTip: "Difference between capital inflow and capital outflow",
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildData({
    required BuildContext context,
    required String key,
    required String value,
    String? toolTip,
  }) {
    final titleStyle = Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
          color: ColorConstants.tertiaryBlack,
          fontWeight: FontWeight.w400,
        );
    final subtitleStyle =
        Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w600,
            );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (toolTip.isNotNullOrEmpty)
          CommonUI.buildInfoToolTip(
            titleText: key,
            titleStyle: titleStyle,
            toolTipMessage: toolTip!,
            rightPadding: 2,
            showDuration: Duration(seconds: 10),
          )
        else
          Text(key, style: titleStyle),
        SizedBox(height: 6),
        Text(value, style: subtitleStyle)
      ],
    );
  }

  Widget _buildDetailCTA() {
    return ClickableText(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onClick: () {
        setState(() {
          showAdditionalDetails = !showAdditionalDetails;
        });
      },
      fontSize: 14,
      fontWeight: FontWeight.w400,
      text: showAdditionalDetails ? 'Less Details' : 'More Details',
      suffixIcon: Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Icon(
          showAdditionalDetails
              ? Icons.keyboard_arrow_up_rounded
              : Icons.keyboard_arrow_down_rounded,
          color: ColorConstants.primaryAppColor,
        ),
      ),
    );
  }
}
