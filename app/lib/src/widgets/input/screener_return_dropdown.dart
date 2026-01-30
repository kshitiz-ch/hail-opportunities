import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/controllers/store/mutual_fund/screener_controller.dart';
import 'package:core/modules/store/models/mf/screener_model.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class ScreenerReturnDropdown extends StatelessWidget {
  const ScreenerReturnDropdown({Key? key, required this.controller})
      : super(key: key);

  final ScreenerController controller;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        customButton: Row(
          children: [
            Text(
              controller.returnTypeSelected?.displayName ?? '',
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineSmall!
                  .copyWith(color: ColorConstants.primaryAppColor),
            ),
            Image.asset(
              AllImages().swapHorizIcon,
              width: 16,
            ),
          ],
        ),
        items: (controller.screener?.returnParams?.choices ?? [])
            .map(
              (Choice choice) => DropdownMenuItem(
                value: choice.value,
                onTap: () {
                  MixPanelAnalytics.trackWithAgentId(
                    "return_selected",
                    screen: 'mutual_fund_store',
                    screenLocation: controller.screener?.name?.toSnakeCase(),
                    properties: {
                      "return": choice.value,
                    },
                  );

                  controller.updateReturnTypeSelected(choice);
                },
                child: Text(
                  choice.displayName ?? '',
                  style: Theme.of(context).primaryTextTheme.titleLarge,
                ),
              ),
            )
            .toList(),
        onChanged: (value) {},
        dropdownStyleData: DropdownStyleData(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
          ),
          offset: const Offset(-40, -10),
        ),
        menuItemStyleData: MenuItemStyleData(
          padding: const EdgeInsets.only(left: 16, right: 16),
        ),
      ),
    );
  }
}
