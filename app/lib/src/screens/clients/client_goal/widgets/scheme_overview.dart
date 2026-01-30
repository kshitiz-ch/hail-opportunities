import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/mutual_funds/models/user_goal_subtype_scheme_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SchemeOverview extends StatelessWidget {
  const SchemeOverview(
      {Key? key, required this.scheme, required this.mfInvestmentType})
      : super(key: key);

  final UserGoalSubtypeSchemeModel scheme;
  final MfInvestmentType mfInvestmentType;

  @override
  Widget build(BuildContext context) {
    if (scheme.folioOverviews?.isNotEmpty ?? false) {
      return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: scheme.folioOverviews!.length,
        separatorBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Divider(color: ColorConstants.borderColor),
          );
        },
        itemBuilder: (BuildContext context, int index) {
          FolioModel folioOverview = scheme.folioOverviews![index];
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: _buildFolioOverview(
              context,
              scheme: scheme,
              folioOverview: folioOverview,
            ),
          );
        },
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 20),
      child: Center(
        child: Text(
          'No Folios Found',
          style: Theme.of(context)
              .primaryTextTheme
              .headlineSmall!
              .copyWith(fontWeight: FontWeight.w300),
        ),
      ),
    );
  }

  Widget _buildFolioOverview(BuildContext context,
      {required UserGoalSubtypeSchemeModel scheme,
      required FolioModel? folioOverview}) {
    if (!(folioOverview?.exists ?? false)) {
      return Padding(
        padding: EdgeInsets.only(top: 10),
        child: Center(
          child: Text(
            'No Folios Found',
            style: Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(fontWeight: FontWeight.w300),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            CommonClientUI.columnInfoText(
              context,
              title: 'Wschemecode',
              subtitle: scheme.schemeData?.wschemecode,
            ),
            CommonClientUI.columnInfoText(
              context,
              title: 'Folio Number',
              subtitle: folioOverview?.folioNumber,
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          children: [
            CommonClientUI.columnInfoText(
              context,
              title: 'Nav Date',
              subtitle: scheme.schemeData?.navDate != null
                  ? DateFormat('dd MMM yyyy')
                      .format(scheme.schemeData!.navDate!)
                  : 'NA',
            ),
            CommonClientUI.columnInfoText(
              context,
              title: 'Units',
              subtitle: (folioOverview?.units ?? 0).toStringAsFixed(2),
            ),
            CommonClientUI.columnInfoText(
              context,
              title: 'Nav',
              subtitle: (scheme.schemeData?.nav ?? 0).toStringAsFixed(2),
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          children: [
            CommonClientUI.columnInfoText(
              context,
              title: 'Free Units',
              subtitle: (folioOverview?.withdrawalUnitsAvailable ?? 0)
                  .toStringAsFixed(2),
            ),
            CommonClientUI.columnInfoText(
              context,
              title: 'Free Amount',
              subtitle: WealthyAmount.currencyFormat(
                  folioOverview?.withdrawalAmountAvailable, 2),
            ),
            CommonClientUI.columnInfoText(
              context,
              title: 'LTCG',
              subtitle:
                  WealthyAmount.currencyFormat(folioOverview?.liveLtcg, 2),
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          children: [
            CommonClientUI.columnInfoText(
              context,
              title: 'STCG',
              subtitle:
                  WealthyAmount.currencyFormat(folioOverview?.liveStcg, 2),
            ),
            CommonClientUI.columnInfoText(
              context,
              title: 'Exit Load Free Amount',
              subtitle: WealthyAmount.currencyFormat(
                folioOverview?.exitLoadFreeAmount,
                2,
              ),
              flex: 2,
            ),
            // _buildEmptyColumn()
          ],
        ),
        if (mfInvestmentType == MfInvestmentType.Portfolios)
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Row(
              children: [
                CommonClientUI.columnInfoText(
                  context,
                  title: 'IRR',
                  subtitle: getPercentageText(scheme.currentIrr),
                ),
                // CommonClientUI.columnInfoText(
                //   context,
                //   title: 'Absolute',
                //   subtitle: getPercentageText(scheme.currentAbsoluteReturns),
                //   flex: 2,
                // ),
                // _buildEmptyColumn()
              ],
            ),
          ),
      ],
    );
  }
}
