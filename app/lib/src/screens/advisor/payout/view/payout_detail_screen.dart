import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/advisor/payout_controller.dart';
import 'package:app/src/screens/advisor/payout/widgets/payout_common_ui.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/advisor/models/payout_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class PayoutDetailScreen extends StatelessWidget {
  final PayoutModel payoutModel;
  late Map<String, String> payoutOverviewLabelValues;
  late Map<String, String> payoutBreakupData;

  PayoutDetailScreen({Key? key, required this.payoutModel}) : super(key: key) {
    final bankAcccount = payoutModel.payoutRedemptionDetails.isNotNullOrEmpty
        ? payoutModel.payoutRedemptionDetails!.first.paidBankAccountNo ?? '-'
        : '-';
    final bankIfsc = payoutModel.payoutRedemptionDetails.isNotNullOrEmpty
        ? payoutModel.payoutRedemptionDetails!.first.paidBankIfscNo ?? '-'
        : '-';
    // TODO: add below when its available
    // final utr = payoutModel.payoutRedemptionDetails.isNotNullOrEmpty
    //     ? payoutModel.payoutRedemptionDetails!.first.utr ?? '-'
    //     : '-';
    payoutOverviewLabelValues = {
      'Bank Account': bankAcccount,
      'Bank IFSC': bankIfsc,
      // 'UTR Number': utr,
      'Amount': WealthyAmount.currencyFormat(payoutModel.finalPayout, 2),
      if (!payoutModel.isBrokingPayout)
        'Payout Date': getFormattedDate(payoutModel.payoutDate)
      else
        // revenueDate == payoutDate for broking payouts
        'Payout Date': getFormattedDate(payoutModel.revenueDate),
      if (payoutModel.isBrokingPayout)
        'Payout Released': getFormattedDate(payoutModel.payoutReleasedAt),
      'Status': payoutModel.statusDescription,
    };
    payoutBreakupData = {
      'Base Payout': WealthyAmount.currencyFormat(payoutModel.basePayout, 2),
      'GST': WealthyAmount.currencyFormat(payoutModel.effectiveGst, 2),
      'TDS': WealthyAmount.currencyFormat(payoutModel.tds, 2),
    };
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(titleText: 'Payout Details'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            PayoutCommonUI.buildDetailSection(
              data: payoutOverviewLabelValues.entries,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: CommonUI.buildProfileDataSeperator(
                color: ColorConstants.separatorColor,
                width: double.infinity,
              ),
            ),
            PayoutCommonUI.buildDetailSection(
              data: payoutBreakupData.entries,
              title: 'Breakup of Payout',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: CommonUI.buildProfileDataSeperator(
                color: ColorConstants.separatorColor,
                width: double.infinity,
              ),
            ),
            _buildBasePayoutBreakup(),
            SizedBox(
              height: payoutModel.employeesPayouts.isNotNullOrEmpty ? 150 : 100,
            ),
          ],
        ),
      ),
      floatingActionButton: _buildCTA(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBasePayoutBreakup() {
    return GetBuilder<PayoutController>(
      id: payoutModel.payoutId,
      builder: (controller) {
        if (controller.payoutProductBreakupResponse.state ==
            NetworkState.loading) {
          return CommonUI.buildShimmerWidget();
        }

        if (controller.payoutProductBreakupResponse.state ==
            NetworkState.error) {
          return SizedBox(
            height: 120,
            child: Center(
              child: RetryWidget(
                controller.payoutProductBreakupResponse.message,
                onPressed: () {
                  controller.getPayoutProductBreakup(payoutModel.payoutId!);
                },
              ),
            ),
          );
        }

        if (controller.payoutProductBreakupResponse.state ==
            NetworkState.loaded) {
          final payoutProductBreakupData = controller
                  .payoutBreakupMap[payoutModel.payoutId]
                  ?.map<MapEntry<String, String>>(
                (breakupData) {
                  String productDescription =
                      getInvestmentProductTitle(breakupData.productType);
                  if (productDescription.isNullOrEmpty) {
                    productDescription =
                        breakupData.productType.toCapitalized();
                  }
                  return MapEntry<String, String>(
                    productDescription,
                    WealthyAmount.currencyFormat(breakupData.baseRevenue, 2),
                  );
                },
              ) ??
              {};
          final isBankDetailMissing =
              payoutOverviewLabelValues['Bank Account'] == '-' &&
                  payoutOverviewLabelValues['Bank IFSC'] == '-';
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PayoutCommonUI.buildDetailSection(
                data: payoutProductBreakupData,
                title: 'Breakup of Base Payout',
                emptyDataMessage:
                    isBankDetailMissing ? 'Bank details missing' : null,
              ),
              SizedBox(height: 20),
              _buildBasePayoutDescription(),
            ],
          );
        }

        return SizedBox();
      },
    );
  }

  Widget _buildBasePayoutDescription() {
    return Builder(builder: (context) {
      final style = Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
            color: ColorConstants.tertiaryBlack,
            fontWeight: FontWeight.w300,
            fontStyle: FontStyle.italic,
          );
      return Container(
        width: SizeConfig().screenWidth,
        decoration: BoxDecoration(
          color: ColorConstants.lightScaffoldBackgroundColor,
          border: Border.all(
            color: ColorConstants.tertiaryBlack,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "** Base Payout : The initial amount paid before any deductions. It's the starting point of the payment process, representing your total earnings",
              style: style,
            ),
            SizedBox(height: 10),
            Text(
              "** For partners not registered for GST, the base payout amount includes the GST. However, in the breakdown of the base payout section, the payout from mutual funds does not include the GST amount.",
              style: style,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCTA(BuildContext context) {
    return Container(
      color: ColorConstants.white,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ActionButton(
            margin: EdgeInsets.symmetric(vertical: 10),
            text: 'View Revenue Sheet',
            onPressed: () {
              MixPanelAnalytics.trackWithAgentId(
                "view_revenue_sheet",
                screen: 'payout_details',
                screenLocation: 'payout_details',
              );
              AutoRouter.of(context).push(
                RevenueSheetRoute(payoutId: payoutModel.payoutId),
              );
            },
          ),
          if (payoutModel.employeesPayouts.isNotNullOrEmpty)
            ClickableText(
              text: 'View Employee wise Segregation',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              textColor: ColorConstants.primaryAppColor,
              padding: EdgeInsets.only(bottom: 10),
              onClick: () {
                AutoRouter.of(context).push(EmployeePayoutRoute(
                  employeesPayouts: payoutModel.employeesPayouts ?? [],
                ));
              },
            ),
        ],
      ),
    );
  }
}
