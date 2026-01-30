import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/screens/clients/client_detail/widgets/profiles_family_section/family_profile_card.dart';
import 'package:app/src/screens/clients/client_detail/widgets/profiles_family_section/pan_profile_card.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilesFamilySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientDetailController>(
      id: 'profile-view',
      builder: (controller) {
        if (controller.userProfileViewResponse.state == NetworkState.loading) {
          return Padding(
            padding: EdgeInsets.only(top: 24),
            child: SkeltonLoaderCard(
              height: 300,
              margin: EdgeInsets.symmetric(horizontal: 20),
            ),
          );
        }
        if (controller.userProfileViewResponse.state == NetworkState.error) {
          return Container(
            margin: EdgeInsets.only(top: 24),
            height: 300,
            child: Center(
              child: RetryWidget(
                controller.userProfileViewResponse.message,
                onPressed: () {
                  controller.getUserProfileViewData();
                },
              ),
            ),
          );
        }

        if (controller.showProfileSection) {
          return Padding(
            padding: EdgeInsets.only(top: 24),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  width: MediaQuery.of(context).size.width,
                  child: _buildRadioTabBar(controller),
                ),
                SizedBox(height: 20),
                _buildProfileList(controller),
              ],
            ),
          );
        }

        return SizedBox();
      },
    );
  }

  Widget _buildRadioTabBar(ClientDetailController controller) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5),
      child: RadioButtons(
        items: controller.profileViewSections,
        onTap: (value) {
          controller.updateSelectedProfileSection(value);
        },
        selectedValue: controller.selectedProfileSection,
        itemBuilder: (context, value, index) {
          String title = '';
          if (index == 0) {
            title = _getClientNameWithHoldingsText(controller.client?.name);
          } else {
            title = value;
          }
          return Text(
            title.toString(),
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  color: controller.selectedProfileSection == value
                      ? ColorConstants.primaryAppColor
                      : ColorConstants.tertiaryBlack,
                  fontWeight: FontWeight.w500,
                ),
          );
        },
      ),
    );
  }

  String _getClientNameWithHoldingsText(String? clientName) {
    String name = (clientName ?? "").split(" ").first.toTitleCase();
    if (name.isNotNullOrEmpty) {
      return "${name}'s Holdings";
    } else {
      return "Your Holdings";
    }
  }

  Widget _buildProfileList(ClientDetailController controller) {
    if (controller.profileViewData.isEmpty) {
      return SizedBox();
    }
    return SizedBox(
      height: controller.isPanProfileSelected ? 75 : 110,
      child: PageView(
        padEnds: false,
        controller: PageController(
            viewportFraction: controller.isPanProfileSelected ? 0.55 : 0.7),
        children: controller.profileViewData.mapIndexed(
          (data, index) {
            if (data == null) {
              return SizedBox();
            }

            bool isLastItem = index == (controller.profileViewData.length - 1);

            return Padding(
              padding: EdgeInsets.only(left: 20, right: isLastItem ? 20 : 0),
              child: controller.isPanProfileSelected
                  ? PanProfileCard(
                      data: data,
                      onTap: () {
                        controller.updateSelectedProfile(data);
                      },
                      isSelected: controller.selectedProfile?.crn == data.crn,
                    )
                  : FamilyProfileCard(
                      data: data,
                      onTap: () {
                        controller.updateSelectedProfile(data);
                      },
                      isSelected: controller.selectedProfile?.crn == data.crn,
                    ),
            );
          },
        ).toList(),
      ),
    );
  }
}
