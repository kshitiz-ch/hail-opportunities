import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart' as enums;
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/screens/commons/order_summary/view/order_summary_screen.dart';
import 'package:app/src/utils/sip_data.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/divider/smart_switch_divider.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/dynamic_list_builder.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';

class AssignedFundsSection extends StatelessWidget {
  // Fields
  final String? portfolioTitle;
  final List<SchemeMetaModel>? funds;
  final double? totalInvestmentAmount;
  final bool isSmartSwitch;
  final bool isCustom;
  final enums.InvestmentType? investmentType;
  final int? sipDay;
  final bool isTopUpPortfolio;
  final Map<String, SipData>? anyFundSipDetails;

  // COnstructor
  const AssignedFundsSection({
    Key? key,
    required this.portfolioTitle,
    required this.funds,
    required this.totalInvestmentAmount,
    required this.isTopUpPortfolio,
    this.isSmartSwitch = false,
    this.isCustom = false,
    this.investmentType,
    this.sipDay,
    this.anyFundSipDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30.0, top: 24),
          child: Text(
            "Assigned Funds",
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ColorConstants.tertiaryBlack,
                ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20)
              .copyWith(top: 16, bottom: 24),
          padding: EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: ColorConstants.primaryCardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0)
                      .copyWith(bottom: 16),
                  child: _buildPortfolioDetailsRow(context),
                ),
                CommonUI.buildProfileDataSeperator(),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: DynamicListBuilder(
                    scrollController: ScrollController(),
                    totalCount: funds!.length,
                    padding: EdgeInsets.zero,
                    showAllColor: ColorConstants.white,
                    initialListCount: isSmartSwitch ? 4 : 3,
                    itemBuilder: (index, animation) {
                      double? allotmentAmount;
                      if (isCustom) {
                        allotmentAmount = funds![index].amountEntered;
                      } else if (!isSmartSwitch &&
                          funds![index].idealWeight != null) {
                        allotmentAmount = totalInvestmentAmount! *
                            (funds![index].idealWeight! / 100);
                      }

                      return _buildFundTile(
                          context: context,
                          title: funds![index].displayName!,
                          description: getFundDescription(funds![index]),
                          allotmentAmount: allotmentAmount,
                          index: index);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Divider(
                    color: ColorConstants.lightGrey,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineMedium!
                            .copyWith(
                              fontWeight: FontWeight.w600,
                              color: ColorConstants.tertiaryBlack,
                            ),
                      ),
                      Text(
                        WealthyAmount.currencyFormat(totalInvestmentAmount, 0),
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineSmall!
                            .copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                      ),
                    ],
                  ),
                ),
              ]),
        ),
      ],
    );
  }

  Widget _buildPortfolioDetailsRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          backgroundImage: AssetImage(AllImages().fundIcon),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${funds!.length} Fund${funds!.length > 1 ? 's' : ''} ',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.black,
                          fontSize: 15),
                ),
                Text(
                  'Investment Type - ${investmentType == enums.InvestmentType.SIP ? 'Sip' : 'One Time Purchase'}',
                  style:
                      Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                            color: ColorConstants.tertiaryBlack,
                          ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildFundTile({
    required BuildContext context,
    required String title,
    required String description,
    double? allotmentAmount,
    int? index,
  }) {
    SchemeMetaModel fund = funds![index!];

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.transparent,
              backgroundImage: CachedNetworkImageProvider(
                getAmcLogo(title),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                            fontWeight: FontWeight.w500,
                            color: ColorConstants.black,
                          ),
                    ),
                    Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge!
                          .copyWith(
                            color: ColorConstants.tertiaryBlack,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            if (allotmentAmount != null)
              Text(
                WealthyAmount.currencyFormat(
                  allotmentAmount,
                  // To check if the number has a decimal place/is a whole number
                  //For more info, visit: https://stackoverflow.com/questions/2304052/check-if-a-number-has-a-decimal-place-is-a-whole-number
                  (allotmentAmount) % 1 == 0 ? 0 : 1,
                  showSuffix: false,
                ),
                style:
                    Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
              )
          ],
        ),
        if (investmentType == enums.InvestmentType.SIP &&
            anyFundSipDetails != null &&
            anyFundSipDetails!.isNotEmpty &&
            anyFundSipDetails!.containsKey(fund.basketKey))
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: buildSipCard(
              data: anyFundSipDetails![fund.basketKey]!,
              context: context,
            ),
          ),
        if (isSmartSwitch && index % 2 == 0)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: SmartSwitchDivider(
              indent: 0,
              endIndent: 0,
            ),
          )
        else
          SizedBox(
            height: 24,
          ),
      ],
    );
  }
}
