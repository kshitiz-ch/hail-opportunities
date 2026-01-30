import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/controllers/client/client_family_controller.dart';
import 'package:app/src/screens/clients/client_detail/widgets/add_family_bottomsheet.dart';
import 'package:app/src/screens/clients/client_detail/widgets/remove_family_confirmation_bottomsheet.dart';
import 'package:app/src/screens/clients/client_detail/widgets/verify_account_bottomsheet.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/clients/models/family_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FamilyList extends StatelessWidget {
  final controller = Get.find<ClientFamilyController>();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Text(
            "${controller.client?.name}'s Family",
            style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        if (controller.familyMembersList.isNullOrEmpty)
          _buildEmptyState(context)
        else
          _buildFamilyLst(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Flexible(
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: ColorConstants.primaryAppv3Color,
          ),
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AllImages().addFamilyIcon,
                height: 92,
                width: 136,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30)
                    .copyWith(top: 12, bottom: 32),
                child: Text(
                  'Currently no family is created for ${controller.client?.name}. Add up to 25 members and keep track of their investments from your device.',
                  style:
                      Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                            color: ColorConstants.tertiaryBlack,
                            fontWeight: FontWeight.w500,
                            height: 18 / 12,
                          ),
                ),
              ),
              ClickableText(
                text: 'Create Family',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                onClick: () {
                  final clientDetailController =
                      Get.find<ClientDetailController>();
                  CommonUI.showBottomSheet(
                    context,
                    child: clientDetailController.isValidForfamilyAddition
                        ? AddFamilyBottomSheet()
                        : VerifyAccountBottomSheet(),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFamilyLst(BuildContext context) {
    return Flexible(
      child: Scrollbar(
        thumbVisibility: true,
        radius: Radius.circular(10),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return _buildFamilyCard(
              controller.familyMembersList[index],
              context,
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(height: 16);
          },
          itemCount: controller.familyMembersList.length,
        ),
      ),
    );
  }

  Widget _buildFamilyCard(FamilyModel familyModel, BuildContext context) {
    final relationKey = familyModel.relationship!.trim().toUpperCase();
    final isMale = familyRelationshipMapping.containsKey(relationKey)
        ? familyRelationshipMapping[relationKey]!['gender'] == 'M'
        : false;
    final relation = familyRelationshipMapping.containsKey(relationKey)
        ? familyRelationshipMapping[relationKey]!['relation']
        : 'Others';
    final name = '${familyModel.memberName ?? ""}';
    final subtitleStyle =
        Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
              color: ColorConstants.tertiaryBlack,
              fontWeight: FontWeight.w400,
              overflow: TextOverflow.ellipsis,
            );
    return GestureDetector(
      onTap: () {
        // TODO:
        // jo family client list ka part h on click move to its detail screen
        // else show this member not part of agent client list
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: ColorConstants.primaryAppv3Color,
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Personal Detail
            Row(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: AssetImage(
                      isMale
                          ? AllImages().familyMaleIcon
                          : AllImages().familyFemaleIcon,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: CommonUI.buildColumnTextInfo(
                      title: name.trim().isNotNullOrEmpty
                          ? name.toTitleCase()
                          : notAvailableText,
                      subtitle:
                          'CRN ${familyModel.memberCRN ?? notAvailableText}',
                      titleStyle: Theme.of(context)
                          .primaryTextTheme
                          .headlineMedium
                          ?.copyWith(
                            overflow: TextOverflow.ellipsis,
                            color: ColorConstants.black,
                            fontWeight: FontWeight.w400,
                          ),
                      subtitleStyle: subtitleStyle,
                    ),
                  ),
                ),
                Text(
                  relation,
                  style: subtitleStyle?.copyWith(
                    color: ColorConstants.black,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
            // Contact Detail
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: CommonUI.buildColumnTextInfo(
                      title: 'Email',
                      subtitle: familyModel.emailAddress ?? notAvailableText,
                      titleStyle: subtitleStyle,
                      subtitleStyle: subtitleStyle?.copyWith(
                        color: ColorConstants.black,
                      ),
                    ),
                  ),
                  Expanded(
                    child: CommonUI.buildColumnTextInfo(
                      title: 'Phone Number',
                      subtitle:
                          familyModel.memberPhoneNumber ?? notAvailableText,
                      titleStyle: subtitleStyle,
                      subtitleStyle: subtitleStyle?.copyWith(
                        color: ColorConstants.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildRemoveButton(context, familyModel),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoveButton(BuildContext context, FamilyModel familyModel) {
    return InkWell(
      onTap: () {
        CommonUI.showBottomSheet(
          context,
          child: RemoveFamilyConfirmationBottomSheet(
            isClientPartOfFamily: false,
            memberUserId: familyModel.id,
            text: 'REMOVE',
            title:
                'Are you sure you want to Remove\n${familyModel.memberName ?? ''} account from ${controller.client!.name} family?',
            subtitle:
                'Type “REMOVE” in the folowing space to\nremove ${familyModel.memberName ?? ''} account from ${controller.client!.name} family',
            ctaText: 'Remove from Family',
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 119, 119, 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.logout,
              size: 12,
              color: ColorConstants.errorColor,
            ),
          ),
          Text(
            ' Remove',
            style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                  color: ColorConstants.errorTextColor,
                ),
          )
        ],
      ),
    );
  }
}
