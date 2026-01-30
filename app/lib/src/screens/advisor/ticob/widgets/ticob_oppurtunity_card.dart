import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/custom_expansion_tile.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';

class TicobOpportunityCard extends StatelessWidget {
  TextStyle? titleStyle;
  TextStyle? subtitleStyle;

  final Client client;
  final Function onGenerateCob;

  TicobOpportunityCard(
      {Key? key, required this.client, required this.onGenerateCob})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    titleStyle = Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w400,
          color: ColorConstants.black,
        );
    subtitleStyle = Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w400,
          color: ColorConstants.tertiaryBlack,
        );

    return ListTileTheme(
      dense: true,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: CustomExpansionTile(
          showIconWithTitle: true,
          title: _buildOpportunityDetail(context),
          tilePadding: EdgeInsets.symmetric(vertical: 8).copyWith(left: 24),
          childrenPadding: EdgeInsets.zero,
          children: [
            _buildAdditionalDetail(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOpportunityDetail(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CommonUI.buildColumnTextInfo(
              title: client.name.toTitleCase(),
              subtitle: 'CRN ${client.crn}',
              titleStyle: titleStyle,
              subtitleStyle: subtitleStyle,
              gap: 5),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            WealthyAmount.currencyFormat(client.trakFamilyMfCurrentValue, 0),
            style: titleStyle,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            WealthyAmount.currencyFormat(client.trakCobOpportunityValue, 0),
            style: titleStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalDetail(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ColorConstants.lotionColor,
        border: Border.all(color: ColorConstants.secondarySeparatorColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agent Details',
                  style: subtitleStyle,
                ),
                SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CommonUI.buildColumnTextInfo(
                      title: client.agent?.name?.toTitleCase() ?? '-',
                      subtitle: client.agent?.email ?? '-',
                      titleStyle: titleStyle,
                      subtitleStyle:
                          subtitleStyle?.copyWith(color: ColorConstants.black),
                      gap: 6,
                    ),
                    if ((client.agent?.email ?? '').isNotNullOrEmpty)
                      InkWell(
                        onTap: () async {
                          await copyData(data: client.agent?.email);
                          showToast(text: 'Email copied');
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Icon(
                            Icons.copy,
                            size: 14,
                            color: ColorConstants.primaryAppColor,
                          ),
                        ),
                      )
                  ],
                )
              ],
            ),
          ),
          CommonUI.buildProfileDataSeperator(
              color: ColorConstants.secondarySeparatorColor),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: CommonUI.buildColumnTextInfo(
                    title: 'No of PAN Synced',
                    subtitle: '${client.totalMfPansTracked} PAN Synced',
                    titleStyle: subtitleStyle,
                    subtitleStyle:
                        subtitleStyle?.copyWith(color: ColorConstants.black),
                  ),
                ),
                SizedBox(width: 20),
                SizedBox(
                  width: 150,
                  height: 36,
                  child: ActionButton(
                    text: 'Generate COB Form',
                    margin: EdgeInsets.zero,
                    onPressed: () {
                      onGenerateCob();
                    },
                    textStyle:
                        Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                              color: ColorConstants.white,
                              fontWeight: FontWeight.w400,
                            ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
