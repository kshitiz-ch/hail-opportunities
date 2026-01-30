import 'dart:math';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/config/string_utils.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/family_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

@RoutePage()
class AddFamilySuccessScreen extends StatefulWidget {
  final FamilyModel? familyMember;
  final Client? client;
  final String? mobileNumber;

  const AddFamilySuccessScreen(
      {Key? key, this.familyMember, this.client, this.mobileNumber})
      : super(key: key);
  @override
  State<AddFamilySuccessScreen> createState() => _AddFamilySuccessScreenState();
}

class _AddFamilySuccessScreenState extends State<AddFamilySuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  void initState() {
    _lottieController = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = pickColor(Random().nextInt(4));
    String name = '${widget.familyMember?.memberName ?? ""}';
    if (name.trim().isNullOrEmpty) {
      name = widget.familyMember?.memberName ?? '';
    }
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: CustomAppBar(
      //   showBackButton: true,
      //   onBackPress: () {
      //     AutoRouter.of(context).popUntilRouteWithName(ClientDetailRoute.name);
      //   },
      //   // customBackIcon: Icons.close,
      // ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 30, right: 30, top: 100, bottom: 80),
        child: Column(
          children: [
            Container(
              child: Center(
                child: Container(
                  width: 90,
                  height: 90,
                  child: Lottie.asset(
                    AllImages().verifiedIconLottie,
                    controller: _lottieController,
                    onLoaded: (composition) {
                      _lottieController
                        ..duration = composition.duration
                        ..forward();
                    },
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Family Member added',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineMedium!
                  .copyWith(fontWeight: FontWeight.w500, height: 1.5),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 20),
              child: Text(
                'A new member was successully added to \n${widget.client!.name}’s profile',
                textAlign: TextAlign.center,
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          fontSize: 12,
                          color: ColorConstants.tertiaryGrey,
                          height: 1.4,
                        ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: ColorConstants.primaryCardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 21,
                        backgroundColor: color.withOpacity(0.6),
                        child: Center(
                          child: Text(
                            name.initials,
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headlineMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: color,
                                ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: CommonUI.buildColumnTextInfo(
                          title: name.toTitleCase(),
                          subtitle: familyRelationshipMapping.containsKey(
                                  widget.familyMember!.relationship)
                              ? familyRelationshipMapping[widget
                                  .familyMember!.relationship]!['relation']
                              : widget.familyMember?.relationship ??
                                  notAvailableText,
                          titleStyle: Theme.of(context)
                              .primaryTextTheme
                              .headlineMedium!
                              .copyWith(
                                fontWeight: FontWeight.w500,
                                color: ColorConstants.black,
                              ),
                          subtitleStyle: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(
                                fontWeight: FontWeight.w400,
                                color: ColorConstants.tertiaryBlack,
                              ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    child: Divider(color: ColorConstants.borderColor),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CommonUI.buildColumnTextInfo(
                          title: 'CRN Number',
                          subtitle: widget.familyMember?.memberCRN ??
                              notAvailableText,
                          subtitleStyle: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                fontWeight: FontWeight.w500,
                                color: ColorConstants.black,
                              ),
                          titleStyle: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(
                                fontWeight: FontWeight.w400,
                                color: ColorConstants.tertiaryBlack,
                              ),
                        ),
                      ),
                      Expanded(
                        child: CommonUI.buildColumnTextInfo(
                          title: 'Phone Number',
                          subtitle: widget.familyMember!.memberPhoneNumber
                                  .isNotNullOrEmpty
                              ? widget.familyMember!.memberPhoneNumber!
                              : (widget.mobileNumber ?? notAvailableText),
                          subtitleStyle: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                fontWeight: FontWeight.w500,
                                color: ColorConstants.black,
                              ),
                          titleStyle: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(
                                fontWeight: FontWeight.w400,
                                color: ColorConstants.tertiaryBlack,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: ActionButton(
        text: 'Done',
        onPressed: () {
          AutoRouter.of(context).popUntilRouteWithName(ClientDetailRoute.name);
          if (Get.isRegistered<ClientDetailController>()) {
            Get.find<ClientDetailController>().getUserProfileViewData();
          }
        },
        margin: EdgeInsets.symmetric(vertical: 24, horizontal: 30),
        textStyle: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.w700,
              color: ColorConstants.white,
            ),
      ),
    );
  }
}
