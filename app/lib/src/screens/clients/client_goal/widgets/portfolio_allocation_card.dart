import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/user_goal_subtype_scheme_model.dart';
import 'package:flutter/material.dart';

import 'scheme_overview.dart';

class PortfolioAllocationCard extends StatefulWidget {
  const PortfolioAllocationCard({Key? key, required this.goalScheme})
      : super(key: key);

  final UserGoalSubtypeSchemeModel goalScheme;

  @override
  State<PortfolioAllocationCard> createState() =>
      _PortfolioAllocationCardState();
}

class _PortfolioAllocationCardState extends State<PortfolioAllocationCard>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _halfTween =
      Tween<double>(begin: 0.0, end: 0.5);

  late AnimationController _animationController;
  late Animation<double> _iconTurns;

  bool isExpanding = false;

  @override
  void initState() {
    _animationController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _iconTurns = _animationController
        .drive(_halfTween.chain(CurveTween(curve: Curves.easeIn)));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ColorConstants.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSchemeLogoAndTitle(),
          _buildInvestmentOverview(),
          if (isExpanding)
            SchemeOverview(
                scheme: widget.goalScheme,
                mfInvestmentType: MfInvestmentType.Portfolios),
          _buildViewTransactionButton()
        ],
      ),
    );
  }

  Widget customTitleWidget() {
    return InkWell(
      onTap: () {
        AutoRouter.of(context)
            .push(FundDetailRoute(fund: widget.goalScheme.schemeData!));
      },
      child: RichText(
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          text: widget.goalScheme.schemeData?.displayName ?? '',
          style: context.headlineSmall,
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: CommonUI.redirectionButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchemeLogoAndTitle() {
    return InkWell(
      onTap: () {
        setState(() {
          isExpanding = !isExpanding;
        });

        if (isExpanding) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                AutoRouter.of(context)
                    .push(FundDetailRoute(fund: widget.goalScheme.schemeData!));
              },
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: CommonUI.buildRoundedFullAMCLogo(
                  radius: 20,
                  amcName: widget.goalScheme.schemeData?.displayName,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customTitleWidget(),
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${fundTypeDescription(widget.goalScheme.schemeData?.fundType)} ${widget.goalScheme.schemeData?.category != null ? "| ${widget.goalScheme.schemeData?.category}" : ""}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headlineSmall!
                                .copyWith(
                                  color: ColorConstants.tertiaryBlack,
                                  fontSize: 12.0,
                                ),
                          ),
                        ),
                        SizedBox(width: 10),
                        if (widget.goalScheme.isDeprecated ?? false)
                          Expanded(
                            child: Text(
                              'Deprecated',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .titleLarge!
                                  .copyWith(color: ColorConstants.errorColor),
                            ),
                          )
                        else
                          Expanded(
                            child: Row(
                              children: [
                                Image.asset(
                                  AllImages().verifiedIcon,
                                  width: 12,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Active',
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .titleLarge!,
                                ),
                              ],
                            ),
                          )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 5),
              child: RotationTransition(
                turns: _iconTurns,
                child: SizedBox(
                  child: Icon(
                    Icons.expand_more,
                    size: 16,
                    color: ColorConstants.secondaryBlack,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentOverview() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Row(
        children: [
          CommonClientUI.columnInfoText(
            context,
            title: 'Invested',
            subtitle: WealthyAmount.currencyFormat(
                widget.goalScheme.currentInvestedValue, 1),
          ),
          CommonClientUI.columnInfoText(
            context,
            title: 'Current Value',
            subtitle:
                WealthyAmount.currencyFormat(widget.goalScheme.currentValue, 1),
          ),
          _buildAbsoluteReturn()
        ],
      ),
    );
  }

  Widget _buildViewTransactionButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: ColorConstants.borderColor),
        ),
      ),
      padding: EdgeInsets.only(left: 12),
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () {
          if (widget.goalScheme.schemeData == null) {
            return showToast(text: 'Failed to get transaction details');
          }

          AutoRouter.of(context).push(
            ClientSchemeTransactionsRoute(
              scheme: widget.goalScheme.schemeData!,
            ),
          );
        },
        child: Text('View Transactions'),
      ),
    );
  }

  Widget _buildAbsoluteReturn() {
    TextStyle textStyle = Theme.of(context)
        .primaryTextTheme
        .headlineSmall!
        .copyWith(fontSize: 13);

    IconData icon = Icons.arrow_drop_up;
    Color iconColor = ColorConstants.greenAccentColor;

    if ((widget.goalScheme.currentAbsoluteReturns ?? 0) < 0) {
      icon = Icons.arrow_drop_down;
      iconColor = ColorConstants.redAccentColor;
    }

    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Absolute Return',
            style: textStyle.copyWith(color: ColorConstants.tertiaryBlack),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Row(
              children: [
                Text(
                  getPercentageText(widget.goalScheme.currentAbsoluteReturns),
                  style: textStyle.copyWith(color: ColorConstants.black),
                ),
                if (widget.goalScheme.currentAbsoluteReturns.isNotNullOrZero)
                  Icon(
                    icon,
                    size: 20,
                    color: iconColor,
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
