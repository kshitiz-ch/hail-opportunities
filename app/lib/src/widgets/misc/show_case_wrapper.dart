import 'package:app/src/widgets/animation/ripple_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../controllers/showcase/showcase_controller.dart';

class ShowCaseWrapper extends StatefulWidget {
  const ShowCaseWrapper({
    Key? key,
    this.currentShowCaseId,
    this.child,
    this.minRadius,
    this.maxRadius,
    this.constraints,
    this.extraSpacing,
    this.rippleExpandingHeight,
    this.rippleExpandingWidth,
    this.onTargetClick,
    this.focusNode,
  }) : super(key: key);

  final String? currentShowCaseId;
  final Widget? child;
  final double? minRadius;
  final double? maxRadius;
  final EdgeInsetsGeometry? extraSpacing;
  final double? rippleExpandingHeight;
  final double? rippleExpandingWidth;
  final BoxConstraints? constraints;
  final Function? onTargetClick;
  final FocusNode? focusNode;

  @override
  State<ShowCaseWrapper> createState() => _ShowCaseWrapperState();
}

class _ShowCaseWrapperState extends State<ShowCaseWrapper> {
  ShowCaseController showCaseController = Get.find<ShowCaseController>();
  GlobalKey globalKey = GlobalKey();

  startShowCase() async {
    if (showCaseController.activeShowCaseId == widget.currentShowCaseId) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        ShowCaseWidget.of(context).startShowCase([globalKey]);
      });
    }
  }

  @override
  void initState() {
    startShowCase();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool showCaseActive =
        showCaseController.activeShowCaseId == widget.currentShowCaseId;

    if (widget.rippleExpandingHeight != null &&
        widget.rippleExpandingWidth != null &&
        showCaseActive) {
      return Container(
        height: widget.rippleExpandingHeight,
        width: widget.rippleExpandingWidth,
        child: showCaseChild(showCaseController, showCaseActive),
      );
    }
    return showCaseChild(showCaseController, showCaseActive);
  }

  Widget showCaseChild(
      ShowCaseController showCaseController, bool showCaseActive) {
    String? title = checkIndexBound(showCaseController)
        ? showCaseController
            .currentActiveList[showCaseController.activeShowCaseIndex]['title']
        : '';
    String? description = checkIndexBound(showCaseController)
        ? showCaseController
                .currentActiveList[showCaseController.activeShowCaseIndex]
            ['description']
        : '';

    return Showcase(
        key: globalKey,
        title: title,
        description: description,
        // shapeBorder: CircleBorder(),
        targetShapeBorder: CircleBorder(),
        showArrow: true,
        // animationDuration: Duration(milliseconds: 1000),
        scaleAnimationDuration: Duration(milliseconds: 1000),
        movingAnimationDuration: Duration(milliseconds: 1000),
        tooltipBackgroundColor: Colors.black,
        // showcaseBackgroundColor: Colors.black,
        textColor: Colors.white,
        overlayColor: Colors.transparent,
        overlayOpacity: 0,
        tooltipBorderRadius: BorderRadius.all(Radius.circular(8)),
        // tipBorderRadius: BorderRadius.all(Radius.circular(8)),
        disposeOnTap: true,
        titleTextStyle: TextStyle(fontSize: 14, color: Colors.white),
        descTextStyle: TextStyle(fontSize: 12, color: Colors.white),
        onTargetClick: () {
          if (widget.onTargetClick != null) {
            widget.onTargetClick!();
          }
        },
        onToolTipClick: () async {
          if (widget.onTargetClick != null) {
            widget.onTargetClick!();
          } else {
            await showCaseController.setActiveShowCase();
          }
        },
        blurValue: 0,
        child: RippleAnimationWidget(
            startAnimation: showCaseActive,
            color: Color(0xff5FCFFF),
            minRadius: widget.minRadius,
            maxRadius: widget.maxRadius,
            constraints: widget.constraints,
            child: Container(
                margin: (widget.extraSpacing != null && showCaseActive)
                    ? widget.extraSpacing
                    : EdgeInsets.all(0),
                child: widget.child)));
  }

  bool checkIndexBound(ShowCaseController showCaseController) {
    int length = showCaseController.currentActiveList.length;

    if (showCaseController.activeShowCaseIndex >= 0 &&
        showCaseController.activeShowCaseIndex < length) {
      return true;
    }
    return false;
  }
}
