import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/client/client_edit_sip_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/input/simple_dropdown_form_field.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/clients/models/client_mandate_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectMandate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientEditSipController>(
      builder: (controller) {
        if (controller.sipMandateResponse.isLoading) {
          return SkeltonLoaderCard(height: 100);
        }
        if (controller.sipMandateResponse.isError) {
          return SizedBox(
            height: 100,
            child: Center(
              child: RetryWidget(
                controller.sipMandateResponse.message,
                onPressed: () {
                  controller.getSipMandates();
                },
              ),
            ),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Bank for this SIP',
              style: context.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: ColorConstants.black,
              ),
            ),
            SizedBox(height: 12),
            ColoredBox(
              color: controller.selectedMandate != null
                  ? Colors.transparent
                  : ColorConstants.black.withOpacity(0.02),
              child: SimpleDropdownFormField<ClientMandateModel>(
                maxButtonHeight: 70,
                customMenuItemHeight: 70,
                items: controller.sipMandateList,
                hintText: 'Choose Mandate',
                hintStyle: context.headlineSmall
                    ?.copyWith(color: ColorConstants.tertiaryBlack),
                value: controller.selectedMandate,
                customSelectedDropdownBuilder: (val) {
                  return _buildMandateUI(
                    val!,
                    context,
                    showBorder: false,
                    isCurrent: val == controller.currentMandate,
                  );
                },
                customDropdownBuilder: (mandateModel) {
                  return _buildMandateUI(
                    mandateModel!,
                    context,
                    isCurrent: mandateModel == controller.currentMandate,
                  );
                },
                onChanged: (value) {
                  controller.selectedMandate = value;
                  controller.update();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMandateUI(
    ClientMandateModel mandateModel,
    BuildContext context, {
    bool showBorder = true,
    bool isCurrent = false,
  }) {
    final subtitle =
        '${mandateModel.maskedPaymentBankAccountNumber} $smallBulletPointUnicode ${WealthyAmount.currencyFormat(mandateModel.amount, 0)} $smallBulletPointUnicode ${mandateModel.method}';
    return Container(
      decoration: BoxDecoration(
        border: showBorder
            ? Border(
                bottom:
                    BorderSide(color: ColorConstants.secondarySeparatorColor),
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 21,
            child: CachedNetworkImage(
              imageUrl: getBankLogo(mandateModel.paymentBankName),
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: 7),
          CommonUI.buildColumnTextInfo(
            title: mandateModel.paymentBankName ?? '-',
            subtitle: subtitle,
            titleStyle: context.headlineMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: ColorConstants.black,
            ),
            subtitleStyle: context.titleLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: ColorConstants.tertiaryBlack,
            ),
            gap: 6,
            titleSuffixIcon: isCurrent
                ? Container(
                    margin: EdgeInsets.only(left: 4),
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: ColorConstants.lightYellowColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Current',
                      style: context.titleSmall?.copyWith(
                        color: ColorConstants.black,
                      ),
                    ),
                  )
                : null,
          )
        ],
      ),
    );
  }
}
