import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/nominee_controller.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/clients/models/client_nominee_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'choose_nominee_bottomsheet.dart';
import 'delete_nominee_bottomsheet.dart';

class EditNomineeBreakdownCard extends StatelessWidget {
  const EditNomineeBreakdownCard(
      {Key? key,
      required this.nomineeType,
      required this.index,
      required this.nominee})
      : super(key: key);

  final NomineeType nomineeType;
  final ClientNomineeModel nominee;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientNomineeController>(
      id: GetxId.nomineeBreakdowns,
      builder: (controller) {
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ColorConstants.primaryAppv3Color,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nominee.name ?? 'NA',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineLarge!
                              .copyWith(fontSize: 14),
                        ),
                        Text(
                          getRelationshipStatus(nominee.relationship) ?? 'NA',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleMedium!
                              .copyWith(color: ColorConstants.tertiaryBlack),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: 68,
                    height: 38,
                    margin: EdgeInsets.only(left: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: ColorConstants.white,
                    ),
                    child: Center(
                      child: TextFormField(
                        controller:
                            controller.nomineeBreakdowns[index].controller,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        maxLength: 3,
                        decoration: InputDecoration(
                          counter: Offstage(),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          suffixText: '%',
                          suffixStyle:
                              Theme.of(context).primaryTextTheme.headlineMedium,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10)
                              .copyWith(bottom: 10),
                        ),
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).primaryTextTheme.headlineMedium,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 17),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      CommonUI.showBottomSheet(
                        context,
                        child: ChooseNomineeBottomSheet(
                          currentNominee: nominee,
                          replaceIndex: index,
                        ),
                      );
                    },
                    child: Text(
                      'Replace Nominee',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                            fontSize: 12,
                            color: ColorConstants.lightPrimaryAppColor,
                          ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    width: 1,
                    height: 12,
                    color: ColorConstants.tertiaryBlack,
                  ),
                  InkWell(
                    onTap: () {
                      controller.deleteNomineeBreakdown(index);
                      // CommonUI.showBottomSheet(
                      //   context,
                      //   child: DeleteNomineeBottomSheet(
                      //     nomineeName: nominee.name ?? '',
                      //     nomineeType: nomineeType,
                      //   ),
                      // );
                    },
                    child: Text(
                      'Delete',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                            fontSize: 12,
                            color: ColorConstants.errorColor,
                          ),
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
