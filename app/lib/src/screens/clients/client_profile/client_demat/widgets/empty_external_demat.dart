import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/client/client_demat_controller.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmptyExternalDemat extends StatelessWidget {
  final controller = Get.find<ClientDematController>();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'External Demat',
          style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                color: ColorConstants.black,
                fontWeight: FontWeight.w500,
              ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: ColorConstants.primaryAppv3Color,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: EdgeInsets.all(30),
          child: Text(
            "No Demat Account has been added yet! Add your Client’s External Demat Account to get started with their Trading Journey",
            style: Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                  color: ColorConstants.tertiaryBlack,
                  fontWeight: FontWeight.w500,
                  height: 18 / 12,
                ),
          ),
        ),
        Center(
          child: GestureDetector(
            onTap: () {
              controller.initDematInputForm();
              AutoRouter.of(context).push(
                AddEditDematRoute(),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ColorConstants.primaryAppColor,
                    ),
                  ),
                  padding: EdgeInsets.all(5),
                  child: Icon(
                    Icons.add,
                    size: 20,
                    color: ColorConstants.primaryAppColor,
                  ),
                ),
                Text(
                  '  Add New Demat Account',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium
                      ?.copyWith(
                        color: ColorConstants.primaryAppColor,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
