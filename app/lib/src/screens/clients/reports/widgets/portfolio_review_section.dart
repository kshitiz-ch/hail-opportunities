import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/client/portfolio_review_controller.dart';
import 'package:app/src/screens/clients/client_detail/widgets/send_tracker_request_bottom_sheet.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/input/bordered_text_form_field.dart';
import 'package:app/src/widgets/input/simple_dropdown_form_field.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:core/modules/common/resources/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PortfolioReviewSection extends StatelessWidget {
  final controller = Get.find<PortfolioReviewController>();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPortfolioReviewCard(context),
          const SizedBox(height: 12),
          _buildTrackerCard(context),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildPANSection(context),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildAsOnDateSection(context),
          ),
          const SizedBox(height: 24),
          _buildOutsideInvestmentNote(context),
          const SizedBox(height: 24),
          _buildDisclaimer(context),
          const SizedBox(height: 80)
        ],
      ),
    );
  }

  Widget _buildPortfolioReviewCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorConstants.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'External Portfolio Review',
            style: context.headlineSmall?.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A focused review of your client\'s external investments with clear insights and smart recommendations.',
            style: context.headlineSmall?.copyWith(
              color: ColorConstants.tertiaryBlack,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackerCard(BuildContext context) {
    final Color accentColor = controller.isTrackerSynced
        ? ColorConstants.greenAccentColor
        : ColorConstants.tangerineColor;

    final IconData iconData =
        controller.isTrackerSynced ? Icons.check_circle : Icons.error_outline;

    final String titleText = controller.isTrackerSynced
        ? 'Tracker last synced: ${getFormattedDate(controller.trackerLastSyncDate!)}'
        : 'Mutual Fund tracker data not yet synced';

    final String subtitleText = controller.isTrackerSynced
        ? 'Review will contain holdings upto this date.'
        : 'Please sync the tracker to proceed with generating the MF review report.';

    final Widget actionWidget = controller.isTrackerSynced
        ? ClickableText(
            prefixIcon: Image.asset(
              AllImages().syncIcon,
              height: 24,
              width: 24,
              color: ColorConstants.primaryAppColor,
            ),
            text: 'Re-Sync',
            fontWeight: FontWeight.w700,
            fontSize: 14,
            onClick: () {
              onSync(context);
            },
            mainAxisAlignment: MainAxisAlignment.center,
          )
        : ClickableText(
            text: 'Send Tracker Request ',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            onClick: () {
              onSync(context);
            },
            mainAxisAlignment: MainAxisAlignment.center,
          );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconData,
                color: accentColor,
                size: controller.isTrackerSynced ? 24 : 20,
              ),
              SizedBox(width: controller.isTrackerSynced ? 6 : 8),
              Flexible(
                child: Text(
                  titleText,
                  style: context.headlineSmall?.copyWith(
                    color: ColorConstants.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: controller.isTrackerSynced ? 8 : 12),
          Text(
            subtitleText,
            style: context.headlineSmall?.copyWith(
              color: ColorConstants.tertiaryBlack,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          actionWidget,
        ],
      ),
    );
  }

  Widget _buildPANSection(BuildContext context) {
    final labelStyle = context.headlineSmall?.copyWith(
      color: controller.isTrackerSynced
          ? ColorConstants.black
          : ColorConstants.tertiaryBlack,
      fontWeight: FontWeight.w500,
    );

    final textStyle = context.headlineMedium?.copyWith(
      color: controller.isTrackerSynced
          ? ColorConstants.black
          : ColorConstants.tertiaryBlack,
      fontWeight: FontWeight.w500,
    );

    if (controller.syncedPansResponse.isLoading) {
      return SkeltonLoaderCard(height: 200);
    }
    if (controller.syncedPansResponse.isError) {
      return SizedBox(
        height: 200,
        child: Center(
          child: RetryWidget(
            'Error fetching Pan Card Details',
            onPressed: () {
              controller.getSyncedPans();
            },
          ),
        ),
      );
    }

    return SimpleDropdownFormField<String>(
      label: 'Choose PAN',
      labelStyle: labelStyle,
      items: controller.panCards,
      enabled: controller.isTrackerSynced,
      hintText: 'Choose one option',
      hintStyle: textStyle?.copyWith(color: ColorConstants.secondaryBlack),
      borderRadius: 12,
      style: textStyle,
      value: controller.selectedPAN,
      onChanged: (value) {
        controller.updateSelectedPAN(value);
      },
    );
  }

  Widget _buildAsOnDateSection(BuildContext context) {
    final labelStyle = context.headlineSmall?.copyWith(
      color: controller.isTrackerSynced
          ? ColorConstants.black
          : ColorConstants.tertiaryBlack,
      fontWeight: FontWeight.w500,
    );

    final textStyle = context.headlineMedium?.copyWith(
      color: controller.isTrackerSynced
          ? ColorConstants.black
          : ColorConstants.tertiaryBlack,
      fontWeight: FontWeight.w500,
    );

    return GestureDetector(
      onTap: controller.isTrackerSynced
          ? () => _selectDate(context, controller)
          : null,
      child: AbsorbPointer(
        child: BorderedTextFormField(
          label: 'As on Date',
          controller: controller.asOnDateController,
          labelStyle: labelStyle,
          style: textStyle,
          enabled: controller.isTrackerSynced,
          borderRadius: BorderRadius.circular(12),
          suffixIcon: Icon(
            Icons.calendar_today,
            color: controller.isTrackerSynced
                ? ColorConstants.primaryAppColor
                : ColorConstants.tertiaryBlack,
            size: 20,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    PortfolioReviewController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorConstants.primaryAppColor,
              onPrimary: ColorConstants.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.updateAsOnDate(picked);
    }
  }

  Widget _buildOutsideInvestmentNote(BuildContext context) {
    final selectedPanModel = controller.selectedPanModel;

    if (selectedPanModel == null) {
      return SizedBox();
    }

    Color textColor = ColorConstants.primaryAppColor;

    String msg = '';
    if (controller.selectedPanModel?.hasValidOutsideInvestments == false) {
      msg = 'No external investments found for this PAN';
      textColor = ColorConstants.redAccentColor;
    } else {
      msg =
          'Current external portfolio value for this PAN : ${WealthyAmount.currencyFormat(
        controller.selectedPanModel?.outsideCurrentValue ?? 0,
        2,
      )}';
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: ColorConstants.lightScaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorConstants.borderColor),
      ),
      margin: EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 14),
      child: Text(
        '$msg',
        style: context.headlineSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildDisclaimer(BuildContext context) {
    final style = context.titleLarge?.copyWith(
      color: ColorConstants.tertiaryBlack,
      fontWeight: FontWeight.w500,
      height: 1.4,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Disclaimer : ',
            style: style?.copyWith(color: ColorConstants.black),
          ),
          TextSpan(
            text:
                'This report is based on system calculations and AI-assisted insights. Please review before sharing. MFDs must follow AMFI Code of Ethics and act in the investor\'s best interest. By generating this report, you agree to these terms.',
            style: style,
          ),
        ],
      ),
    );
  }

  void onSync(BuildContext context) {
    CommonUI.showBottomSheet(
      context,
      child: SendTrackerRequestBottomSheet(
        client: controller.client.getHydraClientModel(),
      ),
    );
  }
}
