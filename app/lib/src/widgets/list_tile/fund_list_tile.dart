import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_mf_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/text/bottom_data.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';

class FundListTile extends StatefulWidget {
  // Fields
  final SchemeMetaModel fund;
  final bool isTopUpPortfolio;
  final bool showWealthyRating;

  const FundListTile(
      {Key? key,
      required this.fund,
      required this.isTopUpPortfolio,
      this.showWealthyRating = false})
      : super(key: key);

  @override
  State<FundListTile> createState() => _FundListTileState();
}

class _FundListTileState extends State<FundListTile>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _halfTween =
      Tween<double>(begin: 0.0, end: 0.5);
  final double verticalGap = 5.0;

  late AnimationController _controller;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _iconTurns =
        _controller.drive(_halfTween.chain(CurveTween(curve: Curves.easeIn)));

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 0.0),
      decoration: BoxDecoration(
          color: ColorConstants.primaryCardColor,
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 10.0, bottom: 10, left: 20, right: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    horizontalTitleGap: 12,
                    dense: true,
                    title: Text(
                      widget.fund.displayName ?? '',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleMedium!
                          .copyWith(fontSize: 14.0),
                    ),
                    subtitle:
                        widget.showWealthyRating && widget.fund.wRating != null
                            ? CommonMfUI.buildMfRating(context, widget.fund)
                            : Text(
                                '${fundTypeDescription(widget.fund.fundType)} ${widget.fund.fundCategory != null ? "| ${widget.fund.fundCategory}" : ""}',
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: Color(0xFF979797),
                                      fontSize: 11.0,
                                    ),
                              ),
                    leading: CommonUI.buildRoundedFullAMCLogo(
                        radius: 20, amcName: widget.fund.displayName),
                    onTap: () {
                      AutoRouter.of(context).push(FundDetailRoute(
                          isTopUpPortfolio: widget.isTopUpPortfolio,
                          fund: widget.fund,
                          showBottomBasketAppBar: false));
                    },
                  ),
                ),
                Chip(
                  label: Text(
                    "${widget.fund.idealWeight == null ? '' : '${widget.fund.idealWeight}%'}",
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                          color: ColorConstants.greenAccentColor,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  backgroundColor: ColorConstants.primaryCardColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4.0,
                    vertical: 2.0,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: ColorConstants.lightGrey,
          ),
          // Bottom
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 14.0, 16.0, 14.0),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.symmetric(vertical: 6.0),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BottomData(
                      title: WealthyAmount.currencyFormat(
                        (widget.isTopUpPortfolio &&
                                (widget.fund.folioOverview?.exists ?? false))
                            ? widget.fund.minAddDepositAmt
                            : widget.fund.minDepositAmt,
                        0,
                        showSuffix: false,
                      ),
                      subtitle: "Min Investment",
                      align: BottomDataAlignment.left,
                    ),
                    BottomData(
                      title:
                          "${widget.fund.exitLoadPercentage != null && widget.fund.exitLoadPercentage != 0 ? "${widget.fund.exitLoadPercentage!.toStringAsFixed(2)}%" : "-"}",
                      subtitle: "Exit Load",
                      align: BottomDataAlignment.left,
                    ),
                    BottomData(
                      title:
                          "${getReturnPercentageText(widget.fund.returns!.oneYrRtrns)}",
                      align: BottomDataAlignment.left,
                      subtitle: "Last 1 Y",
                    ),
                  ],
                ),
                trailing: RotationTransition(
                  turns: _iconTurns,
                  child: Icon(
                    Icons.expand_more,
                    color: ColorConstants.black.withOpacity(0.7),
                    size: 24,
                  ),
                ),
                onExpansionChanged: (isExpanding) {
                  isExpanding ? _controller.forward() : _controller.reverse();
                },
                children: [
                  Container(
                    // To Compensate arrow icon space on the top row
                    margin: const EdgeInsets.only(right: 40.0, top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BottomData(
                          title:
                              "${widget.fund.expenseRatio!.toStringAsFixed(2)}%",
                          subtitle: "Expense Ratio",
                          align: BottomDataAlignment.left,
                        ),
                        BottomData(
                          title:
                              "${getReturnPercentageText(widget.fund.returns!.rtrnsSinceLaunch)}",
                          subtitle: "Since Launch",
                          align: BottomDataAlignment.center,
                        ),
                        BottomData(
                          title:
                              "${getReturnPercentageText(widget.fund.returns!.threeYrRtrns)}",
                          subtitle: "Last 3 Y",
                          align: BottomDataAlignment.left,
                        ),
                        // SizedBox(
                        //   width: 10,
                        // )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
