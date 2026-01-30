import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/nominee_controller.dart';
import 'package:app/src/screens/clients/client_profile/nominee/widgets/choose_nominee_bottomsheet.dart';
import 'package:app/src/screens/clients/client_profile/nominee/widgets/edit_nominee_breakdown_card.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/line_dash.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter/src/foundation/key.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

@RoutePage()
class ClientNomineeBreakdownScreen extends StatelessWidget {
  const ClientNomineeBreakdownScreen({
    Key? key,
    required this.nomineeType,
  }) : super(key: key);

  final NomineeType nomineeType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorConstants.white,
        appBar: CustomAppBar(
          titleText: 'Edit ${getNomineeTypeDescription(nomineeType)} Nominee',
        ),
        body: GetBuilder<ClientNomineeController>(
          id: GetxId.nomineeBreakdowns,
          initState: (_) {
            if (Get.isRegistered<ClientNomineeController>()) {
              Get.find<ClientNomineeController>().shouldSplitPercentageEqually =
                  false;
              Get.find<ClientNomineeController>()
                  .assignNomineeBreakdowns(nomineeType);
            }
          },
          builder: (controller) {
            return Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: ColorConstants.borderColor),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMaxNomineeText(context),
                  _buildSplitPercentageCheckbox(context, controller),
                  _buildNomineeCards(context, controller),
                  _buildAddNomineeButton(context, controller)
                ],
              ),
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _buildUpdateButton(context));
  }

  Widget _buildMaxNomineeText(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 24, bottom: 24),
          child: Text(
            'Maximum of 3 nominee\'\s can be assigned',
            style: Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(fontSize: 12),
          ),
        ),
        LineDash(
          width: 4,
          color: ColorConstants.lightPrimaryAppv2Color,
        )
      ],
    );
  }

  Widget _buildSplitPercentageCheckbox(
      BuildContext context, ClientNomineeController controller) {
    return Padding(
      padding: EdgeInsets.only(top: 24, right: 6, bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 16,
            height: 16,
            child: CommonUI.buildCheckbox(
              showFillColor: false,
              checkColor: ColorConstants.white,
              unselectedBorderColor: ColorConstants.primaryAppColor,
              selectedBorderColor: ColorConstants.primaryAppColor,
              value: controller.shouldSplitPercentageEqually,
              shape: CircleBorder(),
              onChanged: (bool? value) {
                controller.toggleSplitPercentageEqually(nomineeType);
              },
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Split Percentage Equally',
            style: Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(color: ColorConstants.primaryAppColor),
          )
        ],
      ),
    );
  }

  Widget _buildNomineeCards(
      BuildContext context, ClientNomineeController controller) {
    return Flexible(
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: controller.nomineeBreakdowns.length,
        separatorBuilder: (context, index) => SizedBox(height: 16),
        itemBuilder: (context, index) {
          return EditNomineeBreakdownCard(
            nomineeType: nomineeType,
            index: index,
            nominee: controller.nomineeBreakdowns[index].nominee,
          );
        },
      ),
    );
  }

  Widget _buildAddNomineeButton(
      BuildContext context, ClientNomineeController controller) {
    if (controller.nomineeBreakdowns.length >= 3) {
      return SizedBox();
    }

    return InkWell(
      onTap: () {
        CommonUI.showBottomSheet(
          context,
          child: ChooseNomineeBottomSheet(),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(top: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(AllImages().plusRoundedIcon),
            SizedBox(width: 9),
            Text(
              'Add Nominee',
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineMedium!
                  .copyWith(color: ColorConstants.primaryAppColor),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateButton(context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        if (isKeyboardVisible) {
          return SizedBox();
        }

        return GetBuilder<ClientNomineeController>(
          id: GetxId.nomineeBreakdowns,
          builder: (controller) {
            return Container(
              color: ColorConstants.white,
              padding:
                  EdgeInsets.symmetric(horizontal: 30).copyWith(bottom: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.nomineePercentageEqual)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: ColorConstants.black,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'In order to continue, ensure the split percentage adds upto 100%',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headlineSmall,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: ColorConstants.redAccentColor,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'The percentage split doesn\'t sum up to 100%. Rectify to continue',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headlineSmall!
                                .copyWith(color: ColorConstants.errorColor),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 24),
                  ActionButton(
                    text: 'Save & Update',
                    margin: EdgeInsets.zero,
                    showProgressIndicator:
                        controller.nomineeBreakdownResponse.state ==
                            NetworkState.loading,
                    isDisabled: !controller.nomineePercentageEqual,
                    onPressed: () async {
                      await controller.updateNomineeBreakdown();

                      if (controller.nomineeBreakdownResponse.state ==
                          NetworkState.loaded) {
                        showToast(
                          text: 'Nominee Breakdown updated',
                        );

                        // Show Above Toast for 1 sec
                        await Future.delayed(Duration(seconds: 1));

                        AutoRouter.of(context).popUntilRouteWithName(
                          ClientNomineeListRoute.name,
                        );

                        // Refetch Bank Accounts
                        if (Get.isRegistered<ClientNomineeController>()) {
                          Get.find<ClientNomineeController>()
                              .getClientNominees();
                        }
                      } else {
                        showToast(
                            text: controller.nomineeBreakdownResponse.message);
                      }
                    },
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
