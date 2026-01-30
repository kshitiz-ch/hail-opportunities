import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/delete_partner_controller.dart';
import 'package:app/src/controllers/home/profile_controller.dart';
import 'package:app/src/screens/commons/delete_partner/cancel_delete_partner.dart';
import 'package:app/src/screens/profile/widgets/profile_details.dart';
import 'package:app/src/screens/profile/widgets/profile_footer.dart';
import 'package:app/src/screens/profile/widgets/profile_header.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/dashboard/models/advisor_overview_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class ProfileScreen extends StatefulWidget {
  final bool fromPushNotification;
  final bool reload;
  AdvisorOverviewModel? advisorOverview;

  ProfileScreen({
    this.advisorOverview,
    this.fromPushNotification = false,
    @queryParam this.reload = true,
  });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isPartnerArnSearching = false;
  final deletePartnerController = Get.isRegistered<DeletePartnerController>()
      ? Get.find<DeletePartnerController>()
      : Get.put<DeletePartnerController>(DeletePartnerController());

  @override
  void initState() {
    super.initState();
  }

  void goBackHandler() {
    if (widget.fromPushNotification) {
      AutoRouter.of(context).push(BaseRoute());
    } else {
      AutoRouter.of(context).popForced();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      init: ProfileController(widget.advisorOverview),
      id: GetxId.profile,
      dispose: (_) => Get.delete<ProfileController>(),
      builder: (controller) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, __) {
            onPopInvoked(didPop, goBackHandler);
          },
          child: Scaffold(
            backgroundColor: ColorConstants.white,
            appBar: _buildAppBar(controller),
            body: _buildUI(controller),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(ProfileController controller) {
    if (controller.getAdvisorOverviewState == NetworkState.loaded) {
      return PreferredSize(
        preferredSize: Size(0, 0),
        child: SizedBox(),
      );
    }
    return CustomAppBar(
      showBackButton: true,
      onBackPress: goBackHandler,
    );
  }

  Widget _buildUI(ProfileController controller) {
    if (controller.getAdvisorOverviewState == NetworkState.loading) {
      return Center(child: CircularProgressIndicator());
    }
    if (controller.getAdvisorOverviewState == NetworkState.error) {
      return Center(
        child: Text(controller.advisorOverviewErrorMessage),
      );
    }

    if (controller.getAdvisorOverviewState == NetworkState.loaded) {
      return SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProfileHeader(
              onBackPress: () {
                widget.fromPushNotification
                    ? goBackHandler()
                    : AutoRouter.of(context).popForced();
              },
            ),
            _buildCancelUI(),
            _buildUpdateProfileCard(context, controller),
            ProfileDetails(),
            ProfileFooter(appVersion: controller.appVersion),
          ],
        ),
      );
    }
    return SizedBox();
  }

  Widget _buildCancelUI() {
    return GetBuilder<DeletePartnerController>(
      builder: (controller) {
        if (controller.isAccountDeletionRequestOpen) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: CancelDeletePartner(),
          );
        }
        return SizedBox();
      },
    );
  }

  Widget _buildUpdateProfileCard(
      BuildContext context, ProfileController profileController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Text(
              'Complete or modify your profile details',
              style: context.headlineSmall!.copyWith(
                color: ColorConstants.black,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
            ),
          ),
          SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Center(
              child: ActionButton(
                margin: EdgeInsets.zero,
                height: 40,
                borderRadius: 16,
                textStyle: context.titleLarge!.copyWith(
                  color: ColorConstants.white,
                  fontWeight: FontWeight.bold,
                ),
                text: 'Edit Details',
                suffixWidget: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(
                    Icons.arrow_forward,
                    color: ColorConstants.white,
                    size: 16,
                  ),
                ),
                onPressed: () {
                  AutoRouter.of(context).push(ProfileUpdateRoute());
                  // openProfileUpdateUrl(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
