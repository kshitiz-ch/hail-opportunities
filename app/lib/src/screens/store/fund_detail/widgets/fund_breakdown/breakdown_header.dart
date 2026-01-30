import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:flutter/material.dart';

class BreakdownHeader extends StatefulWidget {
  const BreakdownHeader({
    Key? key,
    required this.title,
    this.trailingWidget,
    this.subtitle,
    this.expandByDefault = false,
    this.isExpanded = false,
    required this.onToggleExpand,
    required this.child,
    this.borderColor,
    this.borderWidth,
  }) : super(key: key);

  final String title;
  final Widget? trailingWidget;
  final String? subtitle;
  final Widget child;
  final bool expandByDefault;
  final bool isExpanded;
  final Function() onToggleExpand;
  final Color? borderColor;
  final double? borderWidth;

  @override
  State<BreakdownHeader> createState() => _BreakdownHeaderState();
}

class _BreakdownHeaderState extends State<BreakdownHeader>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _halfTween =
      Tween<double>(begin: 0.0, end: 0.5);

  late AnimationController _controller;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _iconTurns =
        _controller.drive(_halfTween.chain(CurveTween(curve: Curves.easeIn)));
    _controller.addListener(() {});

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (widget.expandByDefault) {
    //   if (widget.expandByDefault &&
    //       !_controller.isCompleted &&
    //       !_controller.isAnimating) {
    //     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //       _controller.forward();
    //     });
    //   }
    // }
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: ColorConstants.secondarySeparatorColor,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Container(
          // expandedAlignment: Alignment.topLeft,
          // expandedCrossAxisAlignment: CrossAxisAlignment.end,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: widget.borderColor ?? ColorConstants.borderColor,
              width: widget.borderWidth ?? 1,
            ),
          ),
          // shape: ,
          // collapsedBackgroundColor: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: InkWell(
                  onTap: () {
                    MixPanelAnalytics.trackWithAgentId(
                      "expand_card",
                      screen: 'fund_details',
                      screenLocation: widget.title.toSnakeCase(),
                    );
                    widget.onToggleExpand();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.title,
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .headlineSmall!
                                        .copyWith(
                                            color: ColorConstants.black,
                                            fontWeight: FontWeight.w700),
                                  ),
                                ),
                                if (widget.trailingWidget != null)
                                  widget.trailingWidget!,
                              ],
                            ),
                          ),
                          Icon(
                            widget.isExpanded
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            color: ColorConstants.lightBlack,
                            size: 28,
                          )
                          // RotationTransition(
                          //   turns: widget.isExpanded ? _iconTurns : _iconTurns,
                          //   child: Icon(
                          //     Icons.expand_more_rounded,
                          //     color: ColorConstants.lightBlack,
                          //     size: 28,
                          //   ),
                          // )
                        ],
                      ),
                      if (widget.subtitle != null)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            widget.subtitle!,
                            style: Theme.of(context)
                                .primaryTextTheme
                                .titleLarge!
                                .copyWith(
                                    color: ColorConstants.tertiaryBlack,
                                    height: 1.3),
                          ),
                        )
                      else
                        SizedBox(height: 10)
                    ],
                  ),
                ),
              ),
              if (widget.isExpanded) ...[
                Divider(
                  color: ColorConstants.secondarySeparatorColor,
                ),
                widget.child
              ],
            ],
          ),
          // trailing: ,
          // onExpansionChanged: (isExpanding) {
          //   // isExpanding ? _controller.forward() : _controller.reverse();
          // },
        ),
        // child: ExpansionTile(
        //   // expandedAlignment: Alignment.topLeft,
        //   // expandedCrossAxisAlignment: CrossAxisAlignment.end,
        //   tilePadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(4),
        //   ),
        //   // collapsedBackgroundColor: Colors.white,
        //   title: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Text(
        //         widget.title,
        //         style: Theme.of(context)
        //             .primaryTextTheme
        //             .headlineSmall!
        //             .copyWith(
        //                 color: ColorConstants.black,
        //                 fontWeight: FontWeight.w700),
        //       ),
        //       if (widget.trailingWidget != null) widget.trailingWidget!
        //     ],
        //   ),
        //   subtitle: widget.subtitle != null
        //       ? Padding(
        //           padding: EdgeInsets.symmetric(vertical: 5),
        //           child: Text(
        //             widget.subtitle!,
        //             style: Theme.of(context)
        //                 .primaryTextTheme
        //                 .titleLarge!
        //                 .copyWith(
        //                     color: ColorConstants.tertiaryBlack, height: 1.3),
        //           ),
        //         )
        //       : null,
        //   trailing: RotationTransition(
        //     turns: _iconTurns,
        //     child: Icon(
        //       Icons.expand_more_rounded,
        //       color: ColorConstants.lightBlack,
        //       size: 28,
        //     ),
        //   ),
        //   onExpansionChanged: (isExpanding) {
        //     // isExpanding ? _controller.forward() : _controller.reverse();
        //   },
        //   children: [
        //     Divider(
        //       color: ColorConstants.secondarySeparatorColor,
        //     ),
        //     widget.child,
        //   ],
        // ),
      ),
    );
  }
}
