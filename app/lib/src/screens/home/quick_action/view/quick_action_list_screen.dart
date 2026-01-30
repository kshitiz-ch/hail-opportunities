import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/home/quick_action_controller.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/advisor/models/quick_action_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class QuickActionListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<QuickActionController>(
      builder: (controller) {
        final actionList = <QuickActionModel>[
          ...controller.selectedActions,
          ...controller.unselectedActions
        ];
        actionList.sort((a, b) => a.name?.compareTo(b.name ?? '') ?? 0);

        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            titleText: 'Quick Actions',
            onBackPress: () {
              AutoRouter.of(context).popForced();
            },
          ),
          body: GridView.count(
            padding: EdgeInsets.symmetric(horizontal: 20)
                .copyWith(bottom: 60, top: 10),
            crossAxisCount: 4,
            shrinkWrap: true,
            primary: false,
            crossAxisSpacing: 5,
            mainAxisSpacing: 0,
            childAspectRatio: 0.8,
            children: actionList.map<Widget>(
              (data) {
                return CommonUI.buildQuickActionItem(
                  context: context,
                  quickActionModel: data,
                );
              },
            ).toList(),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: ActionButton(
            text: 'Edit',
            margin: EdgeInsets.symmetric(vertical: 24, horizontal: 30),
            onPressed: () {
              AutoRouter.of(context).push(QuickActionEditRoute());
            },
          ),
        );
      },
    );
  }
}
