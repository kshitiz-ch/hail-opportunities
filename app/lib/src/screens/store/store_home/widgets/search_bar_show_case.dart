import 'package:app/src/controllers/showcase/showcase_controller.dart';
import 'package:app/src/controllers/store/store_search_controller.dart';
import 'package:app/src/screens/store/store_home/widgets/search_bar_section.dart';
import 'package:app/src/widgets/misc/show_case_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';

class SearchBarShowCase extends StatelessWidget {
  const SearchBarShowCase({
    Key? key,
    required this.showCaseWrapperKey,
    required this.focusNode,
    this.onClickFinished,
    this.storeSearchController,
    this.showCaseController,
  }) : super(key: key);

  final Key showCaseWrapperKey;
  final FocusNode? focusNode;
  final Function? onClickFinished;
  final StoreSearchController? storeSearchController;
  final ShowCaseController? showCaseController;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShowCaseController>(
      id: 'update-showcase-index',
      builder: (controller) {
        if (controller.activeShowCaseId != showCaseIds.StoreSearchBar.id) {
          WidgetsBinding.instance.addPostFrameCallback((t) {
            onClickFinished!();
          });
          return SizedBox();
        }

        return ShowCaseWidget(
          disableBarrierInteraction: false,
          disableScaleAnimation: true,
          onStart: (index, key) {},
          onFinish: () async {
            if (showCaseController!.activeShowCaseId ==
                showCaseIds.StoreSearchBar.id) {
              await showCaseController!.setActiveShowCase();
              onClickFinished!();
            }
          },
          builder: (context) {
            return ShowCaseWrapper(
              key: showCaseWrapperKey,
              focusNode: focusNode,
              currentShowCaseId: showCaseIds.StoreSearchBar.id,
              minRadius: 12,
              maxRadius: 24,
              constraints: BoxConstraints(
                maxHeight: 86,
                minHeight: 50,
                maxWidth: MediaQuery.of(context).size.width,
                minWidth: MediaQuery.of(context).size.width - 65,
              ),
              onTargetClick: () async {
                await showCaseController!.setActiveShowCase();
                ShowCaseWidget.of(context).next();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  focusNode!.requestFocus();
                });
                onClickFinished!();
              },
              rippleExpandingHeight: 86,
              rippleExpandingWidth: double.maxFinite,
              child: Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () async {
                    String activeShowCaseId =
                        showCaseController!.activeShowCaseId;

                    if (activeShowCaseId == showCaseIds.StoreSearchBar.id) {
                      await showCaseController!.setActiveShowCase();
                      ShowCaseWidget.of(context).next();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        focusNode!.requestFocus();
                      });
                      onClickFinished!();
                    }
                  },
                  child: IgnorePointer(
                    ignoring: true,
                    child: SearchBarContainer(
                      focusNode: focusNode,
                      storeSearchController: storeSearchController,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
