import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/custom_expansion_tile.dart';
import 'package:core/modules/advisor/models/ticob_transaction_model.dart';
import 'package:core/modules/common/resources/utils.dart';
import 'package:flutter/material.dart';

class TicobTransactionCard extends StatelessWidget {
  final TicobTransactionModel ticobTransactionModel;

  const TicobTransactionCard({Key? key, required this.ticobTransactionModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: CustomExpansionTile(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: ColorConstants.borderColor2, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        collapsedShape: RoundedRectangleBorder(
          side: BorderSide(color: ColorConstants.borderColor2, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        title: _buildTransactionDetail(context),
        subtitle: _buildStatus(context),
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        showIconWithTitle: true,
        children: [
          CommonUI.buildProfileDataSeperator(color: ColorConstants.borderColor),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 17),
            child: _buildSchemeDetail(
              context: context,
              schemeData: ['Scheme Name', 'Units', 'Amount'],
              isHeader: true,
            ),
          ),
          ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.only(bottom: 12),
            itemCount: ticobTransactionModel.schemes?.length ?? 0,
            itemBuilder: (context, index) {
              final scheme = ticobTransactionModel.schemes![index];
              return _buildSchemeDetail(
                context: context,
                schemeData: [
                  scheme.schemeName,
                  scheme.units,
                  scheme.amount,
                ],
              );
            },
            separatorBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: CommonUI.buildProfileDataSeperator(
                    color: ColorConstants.borderColor),
              );
            },
          ),
        ],
        trailing: SizedBox.shrink(),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildTransactionDetail(BuildContext context) {
    final titleStyle =
        Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w400,
              color: ColorConstants.black,
            );
    final subtitleStyle =
        Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w400,
              color: ColorConstants.tertiaryBlack,
            );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CommonUI.buildColumnTextInfo(
              title: (ticobTransactionModel.name ?? '-').toTitleCase(),
              subtitle: 'CRN ${ticobTransactionModel.crn ?? '-'}',
              titleStyle: titleStyle,
              subtitleStyle: subtitleStyle,
              gap: 6,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: CommonUI.buildColumnTextInfo(
              title: ticobTransactionModel.amcName ?? '-',
              subtitle: ticobTransactionModel.folioNumber ?? '-',
              titleStyle: titleStyle,
              subtitleStyle: subtitleStyle,
              gap: 6,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: CommonUI.buildColumnTextInfo(
              title:
                  WealthyAmount.currencyFormat(ticobTransactionModel.amount, 2),
              subtitle:
                  WealthyAmount.currencyFormat(ticobTransactionModel.amount, 2),
              titleStyle: titleStyle,
              subtitleStyle: subtitleStyle,
              gap: 6,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatus(BuildContext context) {
    final style = Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w400,
          color: ColorConstants.tertiaryBlack,
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonUI.buildProfileDataSeperator(color: ColorConstants.borderColor),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              CommonUI.buildInfoToolTip(
                toolTipMessage:
                    'Processed on date is the date on which\nWealthy received transaction details from AMCs',
                context: context,
                titleText: 'Status ',
                titleStyle: style?.copyWith(color: ColorConstants.black),
                showDuration: Duration(seconds: 3),
              ),
              Text(
                ' : ',
                style: style?.copyWith(color: ColorConstants.black),
              ),
              if (ticobTransactionModel.postDate != null)
                Text(
                  'Processed on ${getFormattedDate(ticobTransactionModel.postDate)}',
                  style: style,
                )
              else
                Text('-', style: style)
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSchemeDetail({
    required BuildContext context,
    required List schemeData,
    bool isHeader = false,
  }) {
    final style = Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w400,
          color: isHeader ? ColorConstants.tertiaryBlack : ColorConstants.black,
        );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              schemeData.first.toString(),
              style: style,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              schemeData[1].toString(),
              style: style,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              isHeader
                  ? schemeData.last.toString()
                  : WealthyAmount.currencyFormat(schemeData.last, 2),
              style: style,
            ),
          ),
          SizedBox(width: 30),
        ],
      ),
    );
  }
}
