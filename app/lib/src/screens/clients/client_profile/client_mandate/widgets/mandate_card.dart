import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/clients/models/client_mandate_model.dart';
import 'package:flutter/material.dart';

class MandateCard extends StatelessWidget {
  final ClientMandateModel mandateModel;

  const MandateCard({Key? key, required this.mandateModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          border: Border.all(color: ColorConstants.borderColor),
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          _buildBankNameLogo(context),
          _buildBankBottomData(context),
        ],
      ),
    );
  }

  Widget _buildBankNameLogo(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          SizedBox(
            height: 38,
            width: 38,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(19),
              child: CachedNetworkImage(
                imageUrl: getBankLogo(mandateModel.paymentBankName),
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              mandateModel.paymentBankName ?? '-',
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineSmall!
                  .copyWith(fontSize: 18),
            ),
          ),
          // if (mandateModel.bankVerifiedStatus == 5)
          //   Row(
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: [
          //       Icon(
          //         Icons.check_circle,
          //         color: ColorConstants.greenAccentColor,
          //       ),
          //       SizedBox(width: 2),
          //       Text(
          //         'Verified',
          //         style: Theme.of(context)
          //             .primaryTextTheme
          //             .titleLarge!
          //             .copyWith(color: ColorConstants.greenAccentColor),
          //       )
          //     ],
          //   )
        ],
      ),
    );
  }

  Widget _buildBankBottomData(BuildContext context) {
    TextStyle labelStyle = Theme.of(context)
        .primaryTextTheme
        .headlineSmall!
        .copyWith(color: ColorConstants.tertiaryBlack, fontSize: 12);
    TextStyle titleStyle = Theme.of(context)
        .primaryTextTheme
        .headlineSmall!
        .copyWith(fontSize: 12);
    final toolTipText = getToolTipText();
    String mandateType = mandateModel.method ?? '';
    if (mandateModel.authType.isNotNullOrEmpty) {
      mandateType = mandateType.isNotNullOrEmpty
          ? '$mandateType - ${mandateModel.authType}'
          : mandateModel.authType ?? '';
    }
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Row(
            children: [
              Expanded(
                child: CommonUI.buildColumnTextInfo(
                  title: 'Account Number',
                  subtitle:
                      mandateModel.paymentBankAccountNumber?.toString() ?? '-',
                  titleStyle: labelStyle,
                  subtitleStyle: titleStyle,
                ),
              ),
              Expanded(
                child: CommonUI.buildColumnTextInfo(
                  title: 'Mandate Type',
                  subtitle: mandateType.isNullOrEmpty ? '-' : mandateType,
                  titleStyle: labelStyle,
                  subtitleStyle: titleStyle,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: CommonUI.buildColumnTextInfo(
                  title: 'Amount',
                  subtitle:
                      WealthyAmount.currencyFormat(mandateModel.amount, 0),
                  titleStyle: labelStyle,
                  subtitleStyle: titleStyle,
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonUI.buildColumnTextInfo(
                      title: 'Mandate Status ',
                      subtitle: mandateModel.statusText,
                      titleStyle: labelStyle,
                      subtitleStyle: titleStyle,
                    ),
                    if (toolTipText.isNotNullOrEmpty)
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
                        message: toolTipText,
                        child: Icon(
                          Icons.info_outline,
                          color: ColorConstants.black,
                          size: 16,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String getToolTipText() {
    String text = '';
    if (mandateModel.status == 'confirmed') {
      text =
          'Confirmed On: ${getFormattedDate(mandateModel.mandateConfirmedAt)}';
    } else if (mandateModel.status == 'rejected') {
      text = 'Rejected On: ${getFormattedDate(mandateModel.mandateExpiredAt)}';
      if (mandateModel.failureReason.isNotNullOrEmpty) {
        text += '\nReason: ${mandateModel.failureReason}';
      }
    }

    return text;
  }
}
