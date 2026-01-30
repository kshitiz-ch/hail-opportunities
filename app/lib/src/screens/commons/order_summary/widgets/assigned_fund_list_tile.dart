import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/text/bottom_data.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';

// TODO: check later to remove or not remove
class AssignedFundListTile extends StatefulWidget {
  final SchemeMetaModel fund;
  final double? allotmentAmount;
  final bool isTopUpPortfolio;
  final bool isEditProposal;
  final int? index;

  const AssignedFundListTile({
    Key? key,
    this.index,
    this.isEditProposal = false,
    required this.fund,
    required this.isTopUpPortfolio,
    this.allotmentAmount,
  }) : super(key: key);

  @override
  State<AssignedFundListTile> createState() => _AssignedFundListTileState();
}

class _AssignedFundListTileState extends State<AssignedFundListTile>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _halfTween =
      Tween<double>(begin: 0.0, end: 0.5);

  late AnimationController _animationController;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    _animationController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _iconTurns = _animationController
        .drive(_halfTween.chain(CurveTween(curve: Curves.easeIn)));

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        title: Text(
          widget.fund.displayName ?? '',
          style: Theme.of(context)
              .primaryTextTheme
              .titleMedium!
              .copyWith(fontSize: 14.0),
        ),
        subtitle: Text(
          '${fundTypeDescription(widget.fund.fundType)} ${widget.fund.category != null ? "| ${widget.fund.category}" : ""}',
          style: Theme.of(context).primaryTextTheme.bodyMedium!.copyWith(
                color: ColorConstants.secondaryBlack,
                fontSize: 11.0,
              ),
        ),
        leading: CommonUI.buildRoundedFullAMCLogo(
            radius: 20, amcName: widget.fund.displayName),
        trailing: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.allotmentAmount != null)
                  Text(
                    WealthyAmount.currencyFormat(
                      widget.allotmentAmount,
                      // To check if the number has a decimal place/is a whole number
                      //For more info, visit: https://stackoverflow.com/questions/2304052/check-if-a-number-has-a-decimal-place-is-a-whole-number
                      widget.allotmentAmount! % 1 == 0 ? 0 : 1,
                      showSuffix: false,
                    ),
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium!
                        .copyWith(
                            color: ColorConstants.black,
                            fontWeight: FontWeight.w500),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 6.0),
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
                ),
              ],
            ),
            if (widget.fund.schemeStatus.isNotNullOrEmpty)
              Padding(
                padding: EdgeInsets.only(right: 20),
                child: Text(
                  getSchemeStatusDescription(widget.fund.schemeStatus ?? ''),
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                          color: getSchemeStatusColor(
                              widget.fund.schemeStatus ?? ''),
                          fontSize: 12),
                ),
              )
          ],
        ),
        tilePadding: const EdgeInsets.all(0),
        childrenPadding: const EdgeInsets.fromLTRB(56.0, 0.0, 10.0, 18.0),
        onExpansionChanged: (isExpanding) {
          isExpanding
              ? _animationController.forward()
              : _animationController.reverse();
        },
        children: [
          Row(
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
                flex: 1,
              ),
              BottomData(
                title:
                    "${widget.fund.expenseRatio != null ? "${widget.fund.expenseRatio!.toStringAsFixed(2)}%" : "-"}",
                subtitle: "Expense Ratio",
                align: BottomDataAlignment.left,
                flex: 1,
              ),
              BottomData(
                title: getReturnPercentageText(widget.fund.returns!.oneYrRtrns),
                subtitle: "Last 1 Y",
                align: BottomDataAlignment.left,
                flex: 1,
              ),
            ],
          ),
          SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BottomData(
                title:
                    getReturnPercentageText(widget.fund.returns!.threeYrRtrns),
                subtitle: "Last 3 Y",
                align: BottomDataAlignment.left,
                flex: 1,
              ),
              BottomData(
                title: getReturnPercentageText(
                    widget.fund.returns!.rtrnsSinceLaunch),
                subtitle: "Since Launch",
                align: BottomDataAlignment.left,
                flex: 1,
              ),
              BottomData(
                title:
                    "${widget.fund.exitLoadPercentage != null ? "${widget.fund.exitLoadPercentage!.toStringAsFixed(2)}%" : "-"}",
                subtitle: "Exit Load",
                align: BottomDataAlignment.left,
                flex: 1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
