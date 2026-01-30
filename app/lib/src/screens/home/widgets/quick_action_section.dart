import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/home/quick_action_controller.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/advisor/models/quick_action_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuickActionSection extends StatelessWidget {
  late TextStyle headerTextStyle;
  late TextStyle dataTextStyle;
  final bool fromSmartSearch;
  QuickActionSection({this.fromSmartSearch = false}) {
    Get.put<QuickActionController>(QuickActionController());
  }
  @override
  Widget build(BuildContext context) {
    headerTextStyle =
        Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w600,
            );
    dataTextStyle = Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
          color: ColorConstants.black,
          fontWeight: FontWeight.w400,
        );
    return GetBuilder<QuickActionController>(
      builder: (controller) {
        if (controller.fetchActionResponse.state == NetworkState.loading) {
          return SkeltonLoaderCard(height: 300);
        }
        if (controller.fetchActionResponse.state == NetworkState.error) {
          return SizedBox(
            height: 300,
            child: Center(
              child: RetryWidget(
                controller.fetchActionResponse.message,
                onPressed: () {
                  controller.getQuickActions();
                },
              ),
            ),
          );
        }
        if (controller.fetchActionResponse.state == NetworkState.loaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: fromSmartSearch ? 0 : 10)
                        .copyWith(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quick Actions',
                      style: headerTextStyle,
                    ),
                    if (!fromSmartSearch)
                      ClickableText(
                        onClick: () {
                          final isUniversalSearchScreen = isPageAtTopStack(
                              context, UniversalSearchRoute.name);
                          MixPanelAnalytics.trackWithAgentId(
                            "quick_action_view_all",
                            properties: {
                              "screen_location": "quick_action",
                              "screen": isUniversalSearchScreen
                                  ? "Universal Search"
                                  : "Home",
                            },
                          );
                          AutoRouter.of(context).push(QuickActionListRoute());
                        },
                        text: 'View All',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      )
                  ],
                ),
              ),
              if (controller.selectedActions.isNullOrEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Center(
                    child: Text(
                      'No Actions Added to Quick Action',
                      style: headerTextStyle.copyWith(fontSize: 14),
                    ),
                  ),
                )
              else
                _buildQuickActionList(context, controller),
            ],
          );
        }
        return SizedBox();
      },
    );
  }

  Widget _buildQuickActionList(
      BuildContext context, QuickActionController controller) {
    late List<QuickActionModel> quickActions;
    if (fromSmartSearch) {
      quickActions = <QuickActionModel>[
        ...controller.selectedActions,
        ...controller.unselectedActions
      ];
      quickActions.sort((a, b) => a.name?.compareTo(b.name ?? '') ?? 0);
    } else {
      quickActions = controller.updatedSelectedActions;
    }

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      primary: false,
      crossAxisSpacing: 5,
      mainAxisSpacing: 0,
      childAspectRatio: 0.8,
      padding: EdgeInsets.zero,
      children: quickActions.map(
        (model) {
          return CommonUI.buildQuickActionItem(
            context: context,
            quickActionModel: model,
          );
        },
      ).toList(),
    );
  }
}
