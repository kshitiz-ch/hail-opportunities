import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/proposal/proposal_detail_controller.dart';
import 'package:app/src/screens/commons/order_summary/widgets/assigned_fund_list_tile.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/divider/smart_switch_divider.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';

// class SwitchTrackerFundsSection extends StatefulWidget {
//   const SwitchTrackerFundsSection({
//     Key? key,
//     required this.controller,
//   }) : super(key: key);

//   final ProposalDetailController controller;

//   @override
//   State<SwitchTrackerFundsSection> createState() =>
//       _SwitchTrackerFundsSectionState();
// }

class SwitchTrackerFundsSection extends StatelessWidget {
  const SwitchTrackerFundsSection({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final ProposalDetailController controller;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? productExtrasJson =
        controller.proposal?.productExtrasJson;
    List schemes = productExtrasJson != null
        ? WealthyCast.toList(productExtrasJson["schemes"])
        : [];

    if (schemes.isNullOrEmpty) {
      return SizedBox();
    }

    List<Map<String, dynamic>> switchTrackerSchemes = [];

    schemes.forEach((schemeJson) {
      SwitchTrackerSchemeModel switchInFund =
          SwitchTrackerSchemeModel.fromJson(schemeJson["switchin"]);
      SwitchTrackerSchemeModel switchOutFund =
          SwitchTrackerSchemeModel.fromJson(schemeJson["switchout"]);
      switchTrackerSchemes.add(
        {"switchin": switchInFund, "switchout": switchOutFund},
      );
    });

    int itemCount = switchTrackerSchemes.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30)
              .copyWith(top: 32, bottom: 24),
          child: Text(
            'Funds in this Proposal ($itemCount)',
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ColorConstants.tertiaryBlack,
                ),
          ),
        ),
        ListView.separated(
          physics: NeverScrollableScrollPhysics(),
          itemCount: switchTrackerSchemes.length,
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 30),
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(height: 20);
          },
          itemBuilder: (BuildContext context, int index) {
            Map<String, dynamic> switchTrackerScheme =
                switchTrackerSchemes[index];

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                border: Border.all(
                  color: ColorConstants.secondarySeparatorColor,
                ),
              ),
              child: Column(
                children: [
                  _buildFundCard(
                    context,
                    switchTrackerScheme["switchout"],
                    isSwitchOut: true,
                  ),
                  _buildSeparator(context, switchTrackerScheme["switchout"]),
                  _buildFundCard(context, switchTrackerScheme["switchin"])
                ],
              ),
            );
          },
        )
      ],
    );
  }

  Widget _buildFundCard(BuildContext context, SwitchTrackerSchemeModel fund,
      {bool isSwitchOut = false}) {
    return ListTile(
      leading: CommonUI.buildRoundedFullAMCLogo(
        radius: 20,
        amcName: fund.fundName,
      ),
      title: Text(
        fund.fundName ?? '',
        style: Theme.of(context)
            .primaryTextTheme
            .titleMedium!
            .copyWith(fontSize: 14.0),
      ),
      subtitle: isSwitchOut && fund.folioNumber.isNotNullOrEmpty
          ? Text(
              'Folio #${fund.folioNumber}',
              style: Theme.of(context).primaryTextTheme.bodyMedium!.copyWith(
                    color: ColorConstants.secondaryBlack,
                    fontSize: 11.0,
                  ),
            )
          : null,
      // trailing: Padding(
      //   padding: EdgeInsets.only(right: 20),
      //   child: Text(
      //     'Created',
      //     // getSchemeStatusDescription(widget.fund.schemeStatus ?? ''),
      //     style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
      //         color: ColorConstants.primaryAppColor,
      //         // color: getSchemeStatusColor(widget.fund.schemeStatus ?? ''),
      //         fontSize: 12),
      //   ),
      // ),
    );
  }

  Widget _buildSeparator(BuildContext context, SwitchTrackerSchemeModel fund) {
    String text = '';
    if (fund.amount.isNotNullOrZero) {
      text = WealthyAmount.currencyFormat(fund.amount, 0);
    } else if (fund.units.isNotNullOrZero) {
      text = '${fund.units.toString()} Units';
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: CommonUI.buildProfileDataSeperator(
              height: 1,
              width: double.infinity,
              color: ColorConstants.secondarySeparatorColor,
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ColorConstants.secondarySeparatorColor,
              ),
            ),
            child: Image.asset(
              AllImages().trackerSwitchIcon,
              height: 15,
              width: 15,
            ),
          ),
          SizedBox(width: 13),
          Text(
            text,
            style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w500,
                ),
          ),
          Expanded(
            child: CommonUI.buildProfileDataSeperator(
              height: 1,
              width: double.infinity,
              color: ColorConstants.secondarySeparatorColor,
            ),
          ),
        ],
      ),
    );
  }
}
