import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/common/select_client_controller.dart';
import 'package:app/src/controllers/showcase/showcase_controller.dart';
import 'package:app/src/widgets/input/search_box.dart';
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
    this.selectClientcontroller,
    this.showCaseController,
  }) : super(key: key);

  final Key showCaseWrapperKey;
  final FocusNode? focusNode;
  final Function? onClickFinished;
  final SelectClientController? selectClientcontroller;
  final ShowCaseController? showCaseController;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShowCaseController>(
        id: 'update-showcase-index',
        builder: (controller) {
          if (controller.activeShowCaseId !=
              showCaseIds.SelectClientSearch.id) {
            WidgetsBinding.instance.addPostFrameCallback((t) {
              onClickFinished!();
            });
            return SizedBox();
          }

          return ShowCaseWidget(
            disableScaleAnimation: true,
            disableBarrierInteraction: false,
            onStart: (index, key) {},
            onFinish: () async {
              if (showCaseController!.activeShowCaseId ==
                  showCaseIds.SelectClientSearch.id) {
                await showCaseController!.setActiveShowCase();
                onClickFinished!();
              }
            },
            builder: (context) {
              return ShowCaseWrapper(
                key: showCaseWrapperKey,
                focusNode: focusNode,
                currentShowCaseId: showCaseIds.SelectClientSearch.id,
                minRadius: 12,
                maxRadius: 24,
                constraints: BoxConstraints(
                  maxHeight: 86,
                  minHeight: 66,
                  maxWidth: MediaQuery.of(context).size.width - 30,
                  minWidth: MediaQuery.of(context).size.width - 50,
                ),
                onTargetClick: () async {
                  await showCaseController!.setActiveShowCase();
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
                      String? activeShowCaseId =
                          showCaseController?.activeShowCaseId;

                      if (activeShowCaseId ==
                          showCaseIds.SelectClientSearch.id) {
                        await showCaseController!.setActiveShowCase();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          focusNode!.requestFocus();
                        });
                        onClickFinished!();
                      }
                    },
                    child: IgnorePointer(
                      ignoring: true,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 30.0),
                        decoration: BoxDecoration(
                          color: ColorConstants.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: ColorConstants.searchBarBorderColor,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ColorConstants.darkBlack.withOpacity(0.1),
                              offset: Offset(0.0, 4.0),
                              spreadRadius: 0.0,
                              blurRadius: 10.0,
                            ),
                          ],
                        ),
                        child: SearchBox(
                          textEditingController:
                              selectClientcontroller!.searchController,
                          prefixIcon: Icon(
                            Icons.search,
                            size: 20,
                            color: ColorConstants.tertiaryGrey,
                          ),
                          suffixIcon: selectClientcontroller!
                                  .searchQuery.isEmpty
                              ? null
                              : IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    size: 20.0,
                                  ),
                                  onPressed:
                                      selectClientcontroller!.clearSearchBar,
                                ),
                          labelText: 'Search by number, name or email',
                          textColor: ColorConstants.secondaryBlack,
                          customBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              width: 1,
                              color: ColorConstants.searchBarBorderColor,
                            ),
                          ),
                          height: 56,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 18, horizontal: 6),
                          labelStyle: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                height: 1.4,
                                color: ColorConstants.secondaryBlack,
                              ),
                          onChanged: (query) {
                            bool isQueryChanged =
                                query != selectClientcontroller!.searchQuery;

                            if (isQueryChanged) {
                              selectClientcontroller!.onClientSearch(query);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        });
  }
}
