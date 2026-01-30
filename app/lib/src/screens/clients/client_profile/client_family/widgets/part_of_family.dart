import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/client/client_family_controller.dart';
import 'package:app/src/screens/clients/client_detail/widgets/remove_family_confirmation_bottomsheet.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/clients/models/family_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PartOfFamily extends StatelessWidget {
  final controller = Get.find<ClientFamilyController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            "Part of Family",
            style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        if (controller.familyList.isNullOrEmpty)
          _buildEmptyState(context)
        else
          _buildPartOfFamilyLst(context)
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Text(
      '${controller.client?.name} is currently not a part of any family group',
      style: Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
            color: ColorConstants.tertiaryBlack,
            fontWeight: FontWeight.w500,
          ),
    );
  }

  Widget _buildPartOfFamilyLst(BuildContext context) {
    return Flexible(
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return _buildPartOfFamilyCard(
            controller.familyList[index],
            context,
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(height: 10);
        },
        itemCount: controller.familyList.length,
      ),
    );
  }

  Widget _buildPartOfFamilyCard(
      FamilyInfoModel familyInfoModel, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: ColorConstants.white,
        border: Border.all(
          color: ColorConstants.borderColor2,
        ),
      ),
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  familyInfoModel.name!.trim().isNotNullOrEmpty
                      ? familyInfoModel.name!.toTitleCase()
                      : '',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium
                      ?.copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                      ),
                ),
                Text(
                  '${controller.client?.name} is added in the Family Group',
                  maxLines: 2,
                  style:
                      Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                            color: ColorConstants.tertiaryBlack,
                            fontWeight: FontWeight.w500,
                          ),
                ),
              ],
            ),
          ),
          _buildLeaveButton(context, familyInfoModel)
        ],
      ),
    );
  }

  Widget _buildLeaveButton(BuildContext context, FamilyInfoModel familyInfo) {
    return InkWell(
      onTap: () {
        CommonUI.showBottomSheet(
          context,
          child: RemoveFamilyConfirmationBottomSheet(
            isClientPartOfFamily: true,
            memberUserId: familyInfo.userId,
            text: 'LEAVE',
            title:
                'Are you sure you want to leave\nfrom ${familyInfo.name} family?',
            subtitle:
                'Type “LEAVE” in the folowing space to\n leave from ${familyInfo.name} family?',
            ctaText: 'Leave from Family',
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
            ' Leave',
            style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                  color: ColorConstants.errorTextColor,
                ),
          )
        ],
      ),
    );
  }
}
