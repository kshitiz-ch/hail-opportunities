import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/common/demat_select_client_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

import 'selected_clients_bottomsheet.dart';

class FloatingActionButtonSection extends StatelessWidget {
  const FloatingActionButtonSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      return GetBuilder<DematSelectClientController>(
        builder: (controller) {
          if (controller.selectedClients.isEmpty || isKeyboardVisible) {
            return SizedBox();
          }

          return Container(
            decoration: BoxDecoration(
              color: ColorConstants.white,
              border: Border(
                top: BorderSide(
                  width: 0.5,
                  color: ColorConstants.black.withOpacity(0.25),
                ),
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  // mainAxisSize: MainAxisSize.min,
                  // crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildClientCount(
                        context, controller.selectedClients.length),
                    Text(
                      ' Selected',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineMedium!
                          .copyWith(
                            fontWeight: FontWeight.w600,
                            color: ColorConstants.tertiaryBlack,
                          ),
                    ),
                  ],
                ),
                SizedBox(width: 24),
                ActionButton(
                  responsiveButtonMaxWidthRatio: 0.4,
                  height: 56,
                  margin: EdgeInsets.zero,
                  text: 'Proceed',
                  borderRadius: 51,
                  onPressed: () async {
                    AutoRouter.of(context).push(DematOverviewRoute(
                        selectedClients: controller.selectedClients));
                  },
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildClientCount(BuildContext context, int count) {
    return TextButton(
      onPressed: () {
        CommonUI.showBottomSheet(
          context,
          child: SelectedClientsBottomSheet(),
        );
      },
      child: Text(
        "$count Client(s)",
        style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.w600,
              color: ColorConstants.primaryAppColor,
            ),
      ),
    );
  }
}
