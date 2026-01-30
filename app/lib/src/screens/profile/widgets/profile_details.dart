import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/controllers/home/profile_controller.dart';
import 'package:app/src/screens/profile/widgets/arn_detail.dart';
import 'package:app/src/screens/profile/widgets/bank_detail.dart';
import 'package:app/src/screens/profile/widgets/gst_details.dart';
import 'package:app/src/screens/profile/widgets/kyc_detail.dart';
import 'package:app/src/screens/profile/widgets/mobile_email_details.dart';
import 'package:app/src/screens/profile/widgets/relationship_manager.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/constants/enums.dart';

class ProfileDetails extends StatelessWidget {
  final ProfileController profileController = Get.find<ProfileController>();
  // BuildContext buildContext;
  ProfileDetails({
    Key? key,
  }) : super(key: key);

  void refreshAgentModel() {
    profileController.getAdvisorOverview();

    final homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    homeController.getAdvisorOverview();
  }

  @override
  Widget build(BuildContext context) {
    bool isPartnerVariable =
        profileController.advisorOverview?.agent?.agentType ==
            AgentType.VARIABLE;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MobileEmailDetail(),
        if (profileController.advisorOverview?.agent?.kycStatus ==
                AgentKycStatus.APPROVED &&
            !profileController.hasLimitedAccess)
          _buildNomineeDetails(context),
        if (isPartnerVariable &&
            profileController.advisorOverview!.agent!.manager != null)
          Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: ManagerCard(
              title: 'Your  Manager',
              manager: profileController.advisorOverview!.agent!.manager,
              bgColor: ColorConstants.primaryCardColor,
            ),
          ),

        if (!profileController.hasLimitedAccess)
          _buildKycRelatedFields(context),

        Container(
          margin: EdgeInsets.only(top: 32.0, bottom: 24),
          color: ColorConstants.secondaryWhite,
          height: 16,
        ),
        if (isPartnerVariable &&
            profileController.advisorOverview!.agent!.pst != null)
          ManagerCard(
            title: 'Your Relationship Manager',
            manager: profileController.advisorOverview!.agent!.pst,
            bgColor: ColorConstants.primaryCardColor,
          ),

        // Temporarily Hide
        // if (isPartnerVariable)
        //   Padding(
        //     padding: const EdgeInsets.only(top: 32.0),
        //     child: RewardBalance(
        //       profileController: profileController,
        //     ),
        //   ),
      ],
    );
  }

  Widget _buildKycRelatedFields(BuildContext context) {
    // show only kyc details for employee
    if (isEmployeeLoggedIn()) {
      return Padding(
        padding: const EdgeInsets.only(top: 32.0),
        child: KYCDetail(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 32.0),
          child: KYCDetail(),
        ),
        if (profileController.advisorOverview?.agent?.kycStatus ==
            AgentKycStatus.APPROVED)
          _buildEmpanelmentDetails(context),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 30).copyWith(top: 32.0),
          child: ARNDetail(
            refreshAgentModel: refreshAgentModel,
          ),
        ),
        _buildGstBankDetail(),
      ],
    );
  }

  Widget _buildGstBankDetail() {
    if (profileController.advisorOverview!.agent!.kycStatus ==
        AgentKycStatus.APPROVED) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GstDetails(
            agent: profileController.advisorOverview!.agent,
            refreshAgentModel: refreshAgentModel,
          ),
          BankDetail(
            refreshAgentModel: refreshAgentModel,
          ),
        ],
      );
    }
    return SizedBox();
  }

  Widget _buildEmpanelmentDetails(BuildContext context) {
    if (profileController.advisorOverview?.partnerArn?.status ==
        ArnStatus.Pending) {
      return SizedBox();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: GetBuilder<ProfileController>(
        id: 'empanelment',
        initState: (_) {
          ProfileController controller = Get.find<ProfileController>();
          if (controller.empanelmentState == NetworkState.cancel) {
            controller.getAgentEmpanelmentDetails();
          }
        },
        builder: (controller) {
          if (controller.empanelmentState == NetworkState.loading) {
            return Container(
              margin: EdgeInsets.only(top: 30, bottom: 30),
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            );
          }

          if (controller.empanelmentState == NetworkState.loaded &&
              controller.empanelmentDetails?.status != null) {
            if (controller.empanelmentDetails?.status ==
                    AgentEmpanelmentStatus.Bypass ||
                controller.empanelmentDetails?.status ==
                    AgentEmpanelmentStatus.BypassTemp) {
              return SizedBox();
            }

            final status = controller.empanelmentDetails!.status;
            final text = status == AgentEmpanelmentStatus.Empanelled
                ? 'Completed'
                : status == AgentEmpanelmentStatus.Pending
                    ? 'Pending'
                    : status == AgentEmpanelmentStatus.InProgress
                        ? 'In Progress'
                        : 'NA';

            return Container(
              margin: EdgeInsets.only(top: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Empanelment Status',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge!
                          .copyWith(
                            color: ColorConstants.tertiaryBlack,
                          ),
                    ),
                  ),
                  // if (status == AgentEmpanelmentStatus.Pending ||
                  //     status == AgentEmpanelmentStatus.InProgress)
                  //   ClickableText(
                  //     fontSize: 14,
                  //     fontWeight: FontWeight.w700,
                  //     onClick: () {
                  //       AutoRouter.of(context).push(
                  //         EmpanelmentRoute(
                  //           advisorOverview: controller.advisorOverview,
                  //         ),
                  //       );
                  //     },
                  //     text: 'Complete Now',
                  //   )
                  // else if (controller.empanelmentDetails?.status ==
                  //     AgentEmpanelmentStatus.Empanelled)
                  Text(
                    text,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                          color: status == AgentEmpanelmentStatus.Empanelled
                              ? ColorConstants.greenAccentColor
                              : ColorConstants.black,
                        ),
                  )
                  // else
                  //   Text(
                  //     'NA',
                  //     style: Theme.of(context)
                  //         .primaryTextTheme
                  //         .headlineSmall!
                  //         .copyWith(),
                  //   )
                ],
              ),
            );
          }
          return SizedBox();
        },
      ),
    );
  }

  Widget _buildNomineeDetails(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30).copyWith(top: 30),
      child: GetBuilder<ProfileController>(
        id: 'partner-nominee',
        initState: (_) {
          ProfileController controller = Get.find<ProfileController>();
          if (controller.partnerNomineeeState == NetworkState.cancel) {
            controller.getPartnerNominee();
          }
        },
        builder: (controller) {
          if (controller.partnerNomineeeState == NetworkState.loading) {
            return Container(
              margin: EdgeInsets.only(top: 30, bottom: 30),
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            );
          }
          return Row(
            children: [
              Expanded(
                child: CommonUI.buildColumnTextInfo(
                  gap: 6,
                  title: 'Nominee',
                  subtitle: controller.partnerNominee?.name ?? notAvailableText,
                  titleStyle:
                      Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                            color: ColorConstants.tertiaryBlack,
                          ),
                  subtitleStyle: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        color: ColorConstants.black,
                      ),
                  subtitleMaxLength: 5,
                ),
              ),
              // ClickableText(
              //   text: (controller.partnerNominee?.name ?? '').isNullOrEmpty
              //       ? 'Add'
              //       : 'Update',
              //   fontWeight: FontWeight.w700,
              //   fontSize: 14,
              //   onClick: () {
              //     AutoRouter.of(context).push(
              //       PartnerNomineeRoute(
              //         nominee: controller.partnerNominee,
              //         fromKycFlow: false,
              //       ),
              //     );
              //   },
              // ),
            ],
          );
        },
      ),
    );
  }
}
