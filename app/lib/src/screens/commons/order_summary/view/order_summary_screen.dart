import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart'
    hide InvestmentType;
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/common/common_controller.dart';
import 'package:app/src/screens/commons/order_summary/widgets/assigned_funds_section.dart';
import 'package:app/src/utils/sip_data.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/add_client_contact_warning.dart';
import 'package:app/src/widgets/misc/client_store_card.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class OrderSummaryScreen extends StatelessWidget {
  // Fields
  final String? portfolioTitle;
  final Client? client;
  final List<SchemeMetaModel>? funds;
  final double? totalInvestmentAmount;
  final InvestmentType? investmentType;

  /// Typically a [ActionButton] used to
  /// create Proposal & handle navigation on pressed
  final Widget? fab;

  /// Required if investmentType == InvestmentType.SIP
  final int? sipDay;

  final bool isSmartSwitch;

  /// Set this true for Custom & Top-up flows
  final bool isCustom;

  /// Set this true for MicroSIP flow
  final bool isMicroSIP;

  /// Set this true Top-up flows
  final bool isTopUpPortfolio;

  /// Required if the investment type is SIP
  final String? userMandateStatus;

  final Map<String, SipData>? anyFundSipDetails;
  final SipData? otherFundSipDetails;
  // Constructor
  OrderSummaryScreen({
    Key? key,
    required this.portfolioTitle,
    required this.client,
    required this.funds,
    required this.totalInvestmentAmount,
    required this.investmentType,
    this.isSmartSwitch = false,
    this.sipDay,
    this.isCustom = false,
    this.isMicroSIP = false,
    this.userMandateStatus,
    this.fab,
    this.isTopUpPortfolio = false,
    this.anyFundSipDetails,
    this.otherFundSipDetails,
  }) : super(key: key) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        showBackButton: true,
        titleText: 'Proposal Summary',
      ),
      body: ListView(
        physics: ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          // Client Details Section
          SizedBox(height: 30),
          ClientStoreCard(
            client: client,
          ),
          if (client?.isSourceContacts ?? false)
            AddClientContactWarning(
              client: client,
            ),

          // if (!userMandateStatus.isNullOrEmpty &&
          //     investmentType == InvestmentType.SIP)
          //   _buildMandateStatus(context),

          // Assigned Funds Section
          AssignedFundsSection(
            portfolioTitle: portfolioTitle,
            funds: funds,
            totalInvestmentAmount: totalInvestmentAmount,
            isSmartSwitch: isSmartSwitch,
            isCustom: isCustom || isMicroSIP,
            investmentType: investmentType,
            sipDay: sipDay,
            isTopUpPortfolio: isTopUpPortfolio,
            anyFundSipDetails: anyFundSipDetails,
          ),
          if (investmentType == InvestmentType.SIP &&
              otherFundSipDetails != null &&
              (anyFundSipDetails == null || anyFundSipDetails!.isEmpty))
            _buildSipDetail(context)
        ],
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: fab,
      ),
    );
  }

  Widget _buildMandateStatus(context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
      ).copyWith(top: 16),
      child: GetBuilder<CommonController>(
        id: GetxId.mandate,
        initState: (_) {
          Get.find<CommonController>().getUserMandateStatus(
            amount: totalInvestmentAmount,
            sipDay: sipDay,
            taxyId: client?.taxyID,
          );
        },
        builder: (controller) {
          if (controller.userMandateState == NetworkState.loading) {
            return SkeltonLoaderCard(height: 30, radius: 9);
          }

          if (controller.userMandateState == NetworkState.error) {
            return RetryWidget(
              'Failed to load mandate details. Please try again',
              onPressed: () {
                controller.getUserMandateStatus(
                  amount: totalInvestmentAmount,
                  sipDay: sipDay,
                  taxyId: client?.taxyID,
                );
              },
            );
          }

          if (controller.userMandateState == NetworkState.loaded) {
            return Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ColorConstants.primaryAppColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: ColorConstants.primaryAppColor,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Text(
                      controller.userMandateStatus ??
                          'Mandate details not found',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                              color: ColorConstants.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          }

          return SizedBox();
        },
      ),
    );
  }

  Widget _buildSipDetail(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30).copyWith(bottom: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text(
              'SIP Details',
              style:
                  Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                        color: ColorConstants.tertiaryBlack,
                        fontWeight: FontWeight.w600,
                      ),
            ),
          ),
          buildSipCard(
            data: otherFundSipDetails!,
            context: context,
          )
        ],
      ),
    );
  }
}

Widget buildSipCard({
  required SipData data,
  required BuildContext context,
}) {
  final stepUpPeriod = !data.isStepUpSipEnabled ? '-' : data.stepUpPeriod;
  final stepUpPercentage =
      !data.isStepUpSipEnabled ? '-' : '${data.stepUpPercentage}%';
  String sipDays = '';
  if (data.selectedSipDays.isNotNullOrEmpty) {
    if (data.selectedSipDays.length > 3) {
      sipDays = data.selectedSipDays.sublist(0, 3).join(', ');
    } else {
      sipDays = data.selectedSipDays.join(', ');
    }
    final remainingDays = data.selectedSipDays.length - 3;
    if (remainingDays > 0) {
      sipDays += ', +$remainingDays days';
    }
  }
  final titleStyle = Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
        color: ColorConstants.tertiaryGrey,
        fontWeight: FontWeight.w400,
        overflow: TextOverflow.ellipsis,
      );
  final subtitleStyle =
      Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
            color: ColorConstants.black,
            fontWeight: FontWeight.w600,
            overflow: TextOverflow.ellipsis,
          );

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: CommonUI.buildColumnTextInfo(
              title: 'SIP Day(s)',
              subtitle: sipDays,
              titleStyle: titleStyle,
              subtitleStyle: subtitleStyle,
              subtitleMaxLength: 2,
            ),
          ),
          SizedBox(width: 4),
          Expanded(
            child: CommonUI.buildColumnTextInfo(
              title: 'Start Date',
              subtitleMaxLength: 2,
              subtitle: getFormattedDate(data.startDate),
              titleStyle: titleStyle,
              subtitleStyle: subtitleStyle,
            ),
          ),
          SizedBox(width: 4),
          Expanded(
            child: CommonUI.buildColumnTextInfo(
              title: 'End Date',
              subtitleMaxLength: 2,
              subtitle: getFormattedDate(data.endDate),
              titleStyle: titleStyle,
              subtitleStyle: subtitleStyle,
            ),
          ),
        ],
      ),
      SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: CommonUI.buildColumnTextInfo(
              title: 'Step up Period',
              subtitle: stepUpPeriod,
              titleStyle: titleStyle,
              subtitleStyle: subtitleStyle,
            ),
          ),
          Expanded(
            child: CommonUI.buildColumnTextInfo(
              title: 'Step up Percentage',
              titleMaxLength: 2,
              subtitle: stepUpPercentage,
              titleStyle: titleStyle,
              subtitleStyle: subtitleStyle,
            ),
          ),
        ],
      )
    ],
  );
}
