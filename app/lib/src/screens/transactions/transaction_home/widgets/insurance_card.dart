import 'package:app/flavors.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/download_controller.dart';
import 'package:app/src/controllers/store/insurance/insurance_policy_controller.dart';
import 'package:app/src/screens/transactions/transaction_home/widgets/status_chip.dart';
import 'package:app/src/screens/transactions/transaction_home/widgets/transaction_list.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/transaction/models/insurance_transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InsuranceCard extends StatelessWidget {
  final InsuranceTransactionModel transaction;
  final bool showClientDetails;

  InsuranceCard({
    super.key,
    required this.transaction,
    this.showClientDetails = true,
  });

  late TextStyle? largeTextStyle;
  late TextStyle? smallTextStyle;

  @override
  Widget build(BuildContext context) {
    largeTextStyle = context.headlineSmall?.copyWith(
      fontWeight: FontWeight.w500,
      color: ColorConstants.black,
    );
    smallTextStyle = context.titleLarge?.copyWith(
      color: ColorConstants.tertiaryBlack,
      fontWeight: FontWeight.w500,
    );

    String name = '-';
    final insuranceType = (transaction.insuranceType ?? '-').toCapitalized();
    final insurer = transaction.insurer ?? '-';
    final date = transaction.orderStageAudit.isNotNullOrEmpty
        ? transaction.orderStageAudit?.last.stageEta
        : transaction.paymentCompletedAt;

    if (transaction.name.isNotNullOrEmpty) {
      name = transaction.name ?? '';
      if (name.contains('_')) {
        name = name.split('_').join(' ');
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: ColorConstants.borderColor, width: 1),
        borderRadius: BorderRadius.circular(12),
        color: ColorConstants.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section: Logo and Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // CachedNetworkImage(
                //   height: 40,
                //   width: 40,
                //   fit: BoxFit.cover,
                //   imageUrl: getAmcLogo(transaction.insurer ?? '-'),
                // ),
                // const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MarqueeWidget(
                        child: Text(
                          '$name | $insurer',
                          style: largeTextStyle,
                        ),
                      ),
                      const SizedBox(height: 6),
                      MarqueeWidget(
                        child: Text(
                          '$insuranceType • ${getFormattedDate(date)} • Policy # ${transaction.policyNumber ?? '-'}',
                          style: smallTextStyle?.copyWith(
                            color: ColorConstants.tertiaryBlack,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Middle section: Client and Amount details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: showClientDetails
                      ? _buildClientDetails()
                      : _buildAmountStatusDetails(),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: showClientDetails
                      ? _buildAmountStatusDetails()
                      : _buildStatusDetail(),
                ),
              ],
            ),
          ),
          if (transaction.enablePolicyActions)
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: CommonUI.buildProfileDataSeperator(
                height: 1,
                width: double.infinity,
              ),
            ),
          if (transaction.enablePolicyActions)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildCTAs(context),
            ),
        ],
      ),
    );
  }

  Widget _buildClientDetails() {
    String? clientName = '-';
    String? mobileNo = '-';
    if (transaction.userDetails.isNotNullOrEmpty) {
      clientName = (transaction.userDetails?.first.name ?? '-').toCapitalized();
      mobileNo = transaction.userDetails?.first.phone ?? '-';
    }
    return CommonUI.buildColumnTextInfo(
      title: 'Client',
      subtitle: clientName,
      titleStyle: smallTextStyle,
      subtitleStyle: largeTextStyle,
      gap: 4,
      optionalWidget: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          'Mobile: $mobileNo',
          style: smallTextStyle?.copyWith(color: ColorConstants.tertiaryBlack),
        ),
      ),
    );
  }

  Widget _buildAmountStatusDetails() {
    final amount = WealthyAmount.currencyFormat(transaction.premiumWithGst, 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amount', style: smallTextStyle),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text.rich(
            TextSpan(
              text: '$amount ',
              style: largeTextStyle?.copyWith(fontWeight: FontWeight.w500),
              children: [
                TextSpan(
                  text: 'Via ${transaction.sourcingChannel ?? '-'}',
                  style: smallTextStyle,
                ),
              ],
            ),
          ),
        ),
        if (showClientDetails)
          StatusChip(
            label: getLabel(),
            statusColor: getStatusColor(),
          ),
      ],
    );
  }

  Widget _buildStatusDetail() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status', style: smallTextStyle),
        SizedBox(height: 4),
        StatusChip(
          label: getLabel(),
          statusColor: getStatusColor(),
        )
      ],
    );
  }

  String getLabel() {
    switch (transaction.status) {
      case TransactionOrderStatus.Active:
        return 'Active';
      case TransactionOrderStatus.RevenueRelease:
        return 'Revenue Released';
      case TransactionOrderStatus.Create:
        return 'Created';
      case TransactionOrderStatus.Fail:
        return 'Failure';
      default:
        return '-';
    }
  }

  Color getStatusColor() {
    switch (transaction.status) {
      case TransactionOrderStatus.Active:
      case TransactionOrderStatus.RevenueRelease:
        return ColorConstants.greenAccentColor;
      case TransactionOrderStatus.Create:
        return ColorConstants.yellowAccentColor;
      case TransactionOrderStatus.Fail:
        return ColorConstants.redAccentColor;
      default:
        return ColorConstants.yellowAccentColor;
    }
  }

  Widget _buildCTAs(BuildContext context) {
    Widget _buildCTA({
      required String text,
      required VoidCallback onPressed,
      required bool showProgressIndicator,
      bool showToolTip = false,
    }) {
      return ActionButton(
        margin: EdgeInsets.zero,
        height: 30,
        bgColor: Colors.transparent,
        showBorder: false,
        text: text,
        suffixWidget:
            showToolTip ? _buildProtectedPdfInfo(context) : SizedBox.shrink(),
        showProgressIndicator: showProgressIndicator,
        customLoader: SizedBox(
          height: 25,
          width: 25,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
              color: ColorConstants.primaryAppColor,
            ),
          ),
        ),
        textStyle: largeTextStyle?.copyWith(
          color: ColorConstants.primaryAppColor,
          fontWeight: FontWeight.w500,
        ),
        onPressed: onPressed,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: GetBuilder<DownloadController>(
              tag: insurancePolicyDownloadTag,
              builder: (controller) {
                final fileName =
                    'policy_${transaction.policyNumber}_${transaction.orderId}';

                return _buildCTA(
                  text: 'Download Policy',
                  showProgressIndicator: controller.isFileDownloading.value &&
                      controller.fileName == fileName,
                  showToolTip: true,
                  onPressed: () {
                    InsurancePolicyController.addMixPanelAnalytics(
                      'partner_app_policy_downloaded',
                      context,
                      transaction,
                    );
                    onDownload(controller, fileName);
                  },
                );
              }),
        ),
        SizedBox(width: 10),
        Expanded(
          child: GetBuilder<InsurancePolicyController>(
            id: '${GetxId.share}-${transaction.orderId}',
            builder: (controller) {
              return _buildCTA(
                text: 'Share with Client',
                showProgressIndicator: controller.sharePolicyResponse.isLoading,
                onPressed: () async {
                  InsurancePolicyController.addMixPanelAnalytics(
                    'partner_app_policy_shared',
                    context,
                    transaction,
                  );
                  await controller.sharePolicy(
                    transaction.userId ?? '-',
                    transaction.orderId ?? '-',
                  );
                  showToast(text: controller.sharePolicyResponse.message);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void onDownload(DownloadController controller, String filename) {
    final baseUrl = F.appFlavor == Flavor.DEV
        ? 'https://api.buildwealthdev.in'
        : 'https://api.buildwealth.in';
    final queryParamMap = {'order_id': transaction.orderId ?? ''};
    String queryParam = Uri(queryParameters: queryParamMap).query;
    queryParam = '?$queryParam';
    final downloadUrl =
        '$baseUrl/insurance/v0/policy-doc/insurance-document/download/$queryParam';
    controller.downloadFile(
      url: downloadUrl,
      filename: filename,
      extension: '.pdf',
    );
  }

  Widget _buildProtectedPdfInfo(BuildContext context) {
    final insurer = transaction.insurer?.toLowerCase();
    String text = '';
    if (insurer == 'ipru') {
      text =
          "For password-protected PDFs: Use first 4 letters of proposer's name (lowercase) + DOB (DDMM), e.g., rahu0508 for Rahul, DOB 05/08.";
    }
    if (insurer == 'hdfc life') {
      text =
          "For password-protected PDFs: use Date of Birth in DDMMYYYY format, e.g., 05081990 as the password.";
    }

    if (text.isNullOrEmpty) {
      return SizedBox();
    }
    return Tooltip(
      showDuration: Duration(seconds: 7),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: ColorConstants.black, borderRadius: BorderRadius.circular(6)),
      triggerMode: TooltipTriggerMode.tap,
      textStyle: context.titleLarge!.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      message: text,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          Icons.info_outline,
          color: ColorConstants.primaryAppColor,
          size: 16,
        ),
      ),
    );
  }
}
