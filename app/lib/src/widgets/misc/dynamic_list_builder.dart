import 'package:app/src/config/constants/color_constants.dart';
import 'package:flutter/material.dart';

class DynamicListBuilder extends StatefulWidget {
  final int? totalCount;
  final Widget Function(int, Animation)? itemBuilder;
  final ScrollController? scrollController;
  final GlobalKey<AnimatedListState>? listKey;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final Color? showAllColor;
  int initialListCount;

  DynamicListBuilder({
    Key? key,
    this.totalCount,
    this.itemBuilder,
    this.scrollController,
    this.listKey,
    this.padding,
    this.shrinkWrap = true,
    this.showAllColor,
    this.initialListCount = 3,
  }) : super(key: key);
  @override
  State<DynamicListBuilder> createState() => _DynamicListBuilderState();
}

class _DynamicListBuilderState extends State<DynamicListBuilder> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // widget.initialListCount = 3;
    return AnimatedList(
      padding: widget.padding,
      key: widget.listKey,
      controller: widget.scrollController,
      initialItemCount: widget.totalCount!,
      shrinkWrap: widget.shrinkWrap,
      physics: ClampingScrollPhysics(),
      itemBuilder: (context, index, animation) {
        int lastItemIndex = -1;
        if (isExpanded) {
          lastItemIndex = widget.totalCount! - 1;
        } else {
          lastItemIndex = widget.totalCount! > widget.initialListCount
              ? widget.initialListCount - 1
              : -1;
        }
        return widget.totalCount! <= widget.initialListCount
            ? widget.itemBuilder!(index, animation)
            : index > lastItemIndex
                ? SizedBox()
                : index < lastItemIndex
                    ? widget.itemBuilder!(index, animation)
                    : Column(
                        children: [
                          widget.itemBuilder!(index, animation),
                          widget.totalCount! > widget.initialListCount
                              ? InkWell(
                                  onTap: () {
                                    onTapShowButton();
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(top: 10),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: widget.showAllColor ??
                                          ColorConstants.secondaryWhite,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      !isExpanded ? 'Show all' : 'Show less',
                                      style: Theme.of(context)
                                          .primaryTextTheme
                                          .titleLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.w400,
                                            color:
                                                ColorConstants.primaryAppColor,
                                          ),
                                    ),
                                  ),
                                )
                              : SizedBox(),
                        ],
                      );
      },
    );
  }

  void onTapShowButton() {
    isExpanded = !isExpanded;
    if (mounted) {
      setState(() {});
    }
    if (widget.scrollController != null &&
        widget.scrollController!.hasClients) {
      Future.delayed(
        Duration(milliseconds: 100),
        () {
          widget.scrollController!.animateTo(
            isExpanded
                ? widget.scrollController!.position.maxScrollExtent
                : widget.scrollController!.position.minScrollExtent,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
      );
    }
  }
}
