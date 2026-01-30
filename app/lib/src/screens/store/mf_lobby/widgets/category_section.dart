import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/screener_controller.dart';
import 'package:app/src/screens/store/mf_lobby/mf_list/widgets/filter_sort_bottomsheet.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:core/modules/store/models/mf/screener_model.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({
    Key? key,
    required this.controller,
    required this.choices,
  }) : super(key: key);

  final ScreenerController controller;
  final List<Choice> choices;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ScrollablePositionedList.builder(
        itemCount: choices.length + 1, // +1 is for 'More' Categorey
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 20),
        itemBuilder: (context, index) {
          if (index == choices.length) {
            return _buldCategoryPill(
              context,
              controller,
              Choice(displayName: '+ More', value: 'more'),
            );
          } else {
            return _buldCategoryPill(
              context,
              controller,
              choices[index],
              index: index,
            );
          }
        },
        itemScrollController: controller.categoryScrollController,
      ),
    );
    // return SingleChildScrollView(
    //   scrollDirection: Axis.horizontal,
    //   child: Row(
    //     mainAxisSize: MainAxisSize.min,
    //     children: [
    //       ...choices
    //           .mapIndexed(
    //             (Choice choice, int index) => _buldCategoryPill(
    //               context,
    //               controller,
    //               choice,
    //               index: index,
    //             ),
    //           )
    //           .toList(),
    //       if (choices.isNotEmpty)
    //         _buldCategoryPill(
    //           context,
    //           controller,
    //           Choice(displayName: '+ More', value: 'more'),
    //         )
    //     ],
    //   ),
    // );
  }

  Widget _buldCategoryPill(
      BuildContext context, ScreenerController controller, Choice choice,
      {int index = 0}) {
    bool isSelected = (controller.categorySelected ?? [])
            .firstWhereOrNull((element) => element.value == choice.value) !=
        null;
    bool openFilterBottomSheet = choice.value == 'more';
    return InkWell(
      onTap: () {
        MixPanelAnalytics.trackWithAgentId(
          "category_pill_click",
          screen: 'mutual_fund_store',
          screenLocation: controller.screener?.name?.toSnakeCase(),
        );

        if (openFilterBottomSheet) {
          if (controller.fromListScreen) {
            controller.changeFilterMode(FilterMode.filter);
            controller.getSavedFilterAndSort();

            if (controller.categoryOptions.isEmpty) {
              controller.getCategoryOptions();
            }

            String controllerTag = "${controller.screener?.wpc}-list";
            CommonUI.showBottomSheet(
              context,
              child: FilterSortBottomSheet(tag: controllerTag),
            );
          } else {
            AutoRouter.of(context).push(
              MfListRoute(
                screener: controller.screener,
                openFiltersByDefault: true,
                categorySelected: controller.categorySelected,
                categorySelectedIndex: controller.categorySelectedIndex,
              ),
            );
          }
          return;
        }

        if (controller.screenerResponse.state == NetworkState.loading) {
          return;
        }

        controller.updateCategorySelected(choice, categoryIndex: index);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 9, horizontal: 16),
        margin: EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorConstants.primaryAppColor.withOpacity(0.05)
              : ColorConstants.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: isSelected
                  ? ColorConstants.primaryAppColor
                  : ColorConstants.secondarySeparatorColor),
        ),
        child: Text(
          choice.displayName!,
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                color: isSelected
                    ? ColorConstants.primaryAppColor
                    : ColorConstants.tertiaryBlack,
              ),
        ),
      ),
    );
  }
}
