import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/text/bottom_data.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';

class EditableFundListTile extends StatefulWidget {
  // Fields
  final SchemeMetaModel fund;
  final Widget? rightPane;
  final VoidCallback? onPressed;
  final double leadingRadius;
  final bool isTopUpPortfolio;
  final Widget? bottomPane;

  // Controller
  const EditableFundListTile(
      {Key? key,
      required this.fund,
      this.rightPane,
      this.onPressed,
      this.leadingRadius = 20,
      this.isTopUpPortfolio = false,
      this.bottomPane})
      : super(key: key);

  @override
  State<EditableFundListTile> createState() => _EditableFundListTileState();
}

class _EditableFundListTileState extends State<EditableFundListTile>
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
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            minLeadingWidth: 30,
            contentPadding: const EdgeInsets.all(0),
            horizontalTitleGap: 12,
            dense: true,
            trailing: // Right Pane
                SizedBox(
              width: widget.rightPane == null
                  ? 26.0
                  : MediaQuery.of(context).size.width * 0.25,
              child: widget.rightPane,
            ),
            title: Text(
              widget.fund.displayName ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
                radius: widget.leadingRadius, amcName: widget.fund.displayName),
            onTap: widget.onPressed,
          ),

          // Bottom
          Padding(
            padding: const EdgeInsets.only(bottom: 14.0),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.all(0.0),
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
                      subtitle: "Min Deposit",
                      verticalGap: verticalGap,
                      align: BottomDataAlignment.left,
                    ),
                    BottomData(
                      title: "${widget.fund.expenseRatio!.toStringAsFixed(2)}%",
                      subtitle: "Expense Ratio",
                      verticalGap: verticalGap,
                      align: BottomDataAlignment.left,
                    ),
                    BottomData(
                      title: getReturnPercentageText(
                          widget.fund.returns!.oneYrRtrns),
                      align: BottomDataAlignment.left,
                      verticalGap: verticalGap,
                      subtitle: "Last 1 Y",
                    ),
                  ],
                ),
                trailing: RotationTransition(
                  turns: _iconTurns,
                  child: const Icon(
                    Icons.expand_more,
                    size: 24,
                  ),
                ),
                onExpansionChanged: (isExpanding) {
                  isExpanding ? _controller.forward() : _controller.reverse();
                },
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 35),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BottomData(
                          title: getReturnPercentageText(
                              widget.fund.returns!.threeYrRtrns),
                          subtitle: "Last 3 Y",
                          verticalGap: verticalGap,
                          align: BottomDataAlignment.left,
                        ),
                        BottomData(
                          title: getReturnPercentageText(
                              widget.fund.returns!.rtrnsSinceLaunch),
                          subtitle: "Since Launch",
                          verticalGap: verticalGap,
                          align: BottomDataAlignment.left,
                        ),
                        BottomData(
                          title:
                              "${widget.fund.exitLoadPercentage != null ? "${widget.fund.exitLoadPercentage!.toStringAsFixed(2)}%" : "-"}",
                          subtitle: "Exit Load",
                          verticalGap: verticalGap,
                          align: BottomDataAlignment.left,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (widget.bottomPane != null) widget.bottomPane!,
        ],
      ),
    );
  }
}
