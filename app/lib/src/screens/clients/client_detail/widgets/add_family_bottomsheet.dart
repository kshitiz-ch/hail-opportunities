import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/client/client_family_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddFamilyBottomSheet extends StatelessWidget {
  List<List<String>> options = [
    [
      'Family Member is an existing user',
      'If your family Member is an existing user'
    ],
    ['Add as a new user', 'Enter details to add as a new family member'],
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Choose method',
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ColorConstants.black,
                ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 30),
            child: Text(
              'Choose method to add family member',
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.w400,
                    color: ColorConstants.tertiaryGrey,
                  ),
            ),
          ),
          GetBuilder<ClientFamilyController>(builder: (controller) {
            return RadioButtons(
              items: [
                FamilyAdditionMethod.EXISTING_USER,
                FamilyAdditionMethod.NEW_USER
              ],
              selectedValue: controller.selectedMethod,
              spacing: 30,
              itemBuilder: (context, value, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: CommonUI.buildColumnTextInfo(
                    title: options[index][0],
                    subtitle: options[index][1],
                    gap: 8,
                    titleStyle: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          overflow: TextOverflow.ellipsis,
                        ),
                    subtitleStyle:
                        Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.w400,
                              color: ColorConstants.tertiaryGrey,
                              overflow: TextOverflow.ellipsis,
                            ),
                  ),
                );
              },
              direction: Axis.vertical,
              onTap: (value) {
                controller.updateAdditionMethod(value);
              },
            );
          }),
          GetBuilder<ClientFamilyController>(builder: (controller) {
            return ActionButton(
              text: 'Continue',
              margin: EdgeInsets.symmetric(horizontal: 30).copyWith(top: 80),
              textStyle:
                  Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                        color: ColorConstants.white,
                      ),
              onPressed: () {
                if (controller.selectedMethod ==
                    FamilyAdditionMethod.EXISTING_USER) {
                  controller.initCRNForm();
                  AutoRouter.of(context).push(AddFamilyCrnFormRoute());
                } else if (controller.selectedMethod ==
                    FamilyAdditionMethod.NEW_USER) {
                  controller.initDetailForm();
                  AutoRouter.of(context).push(AddFamilyDetailFormRoute());
                }
              },
            );
          })
        ],
      ),
    );
  }
}
