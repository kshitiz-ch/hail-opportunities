import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/nominee_controller.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_nominee_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChooseNomineeBottomSheet extends StatelessWidget {
  const ChooseNomineeBottomSheet({
    Key? key,
    this.currentNominee,
    this.replaceIndex,
  }) : super(key: key);

  final ClientNomineeModel? currentNominee;
  final int? replaceIndex;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientNomineeController>(
      builder: (controller) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                decoration: BoxDecoration(
                  color: ColorConstants.secondaryWhite,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose Nominee to ${replaceIndex != null ? 'Replace' : 'Add'}',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .displaySmall!
                                .copyWith(
                                    fontSize: 18,
                                    color: ColorConstants.tertiaryBlack),
                          ),
                          if (replaceIndex != null)
                            Text(
                              currentNominee?.name ?? '',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .displaySmall!
                                  .copyWith(fontSize: 18),
                            ),
                        ],
                      ),
                    ),
                    _buildCloseButton(context)
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height / 2,
                ),
                child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return Divider(color: ColorConstants.borderColor);
                  },
                  shrinkWrap: true,
                  itemCount: controller.userNominees.length,
                  itemBuilder: (context, index) {
                    ClientNomineeModel nominee = controller.userNominees[index];

                    bool isNomineeAlreadyExists = false;

                    for (NomineeBreakdown existingNominee
                        in controller.nomineeBreakdowns) {
                      if (existingNominee.nominee.externalId ==
                          nominee.externalId) {
                        isNomineeAlreadyExists = true;
                        break;
                      }
                    }

                    if (isNomineeAlreadyExists) {
                      return SizedBox();
                    } else {
                      return _buildNomineeCard(context, nominee, controller);
                    }
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildNomineeCard(BuildContext context, ClientNomineeModel nominee,
      ClientNomineeController controller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.symmetric(vertical: 24),
      // decoration: BoxDecoration(
      //   border: Border(
      //     bottom: BorderSide(color: ColorConstants.borderColor),
      //   ),
      // ),
      child: Row(
        children: [
          Expanded(
              child: CommonUI.buildColumnTextInfo(
            title: nominee.name ?? '-',
            titleStyle: Theme.of(context)
                .primaryTextTheme
                .headlineLarge!
                .copyWith(fontSize: 14),
            subtitleStyle: Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(color: ColorConstants.tertiaryBlack, fontSize: 14),
            subtitle: getRelationshipStatus(nominee.relationship) ?? '-',
          )),
          TextButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
              alignment: Alignment.centerRight,
            ),
            child: Text('Select'),
            onPressed: () {
              if (replaceIndex != null) {
                controller.replaceNomineeBreakdown(replaceIndex!, nominee);
              } else {
                controller.addNomineeBreakdown(nominee);
              }
              AutoRouter.of(context).pop();
            },
          )
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return InkWell(
      onTap: () {
        AutoRouter.of(context).popForced();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Icon(
          Icons.close,
          size: 24,
          color: ColorConstants.black,
        ),
      ),
      // child: Padding(
      //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
      //   child: Container(
      //     alignment: Alignment.topRight,
      //     height: 32,
      //     width: 32,
      //     margin: EdgeInsets.only(right: 10, top: 10),
      //     decoration: BoxDecoration(
      //       color: ColorConstants.darkScaffoldBackgroundColor,
      //       shape: BoxShape.circle,
      //     ),
      //     child: Center(
      //       child: Icon(
      //         Icons.close,
      //         size: 16,
      //         color: Colors.white,
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}
