import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/clients/models/user_profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FamilyProfileCard extends StatelessWidget {
  final ProfileModel data;
  final bool isSelected;
  final Function onTap;

  const FamilyProfileCard({
    Key? key,
    required this.data,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorConstants.white,
          border: Border.all(
            color: isSelected
                ? ColorConstants.primaryAppColor
                : ColorConstants.secondarySeparatorColor,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: Offset(0.0, 0.0),
                    spreadRadius: 0.0,
                    blurRadius: 4.0,
                  ),
                ]
              : [],
        ),
        child: _buildFamilyCard(context),
      ),
    );
  }

  Widget _buildFamilyCard(BuildContext context) {
    final titleLarge = Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: ColorConstants.tertiaryBlack,
        );
    final headlineSmall =
        Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: ColorConstants.black,
            );
    final relation = clientFamilyRelationshipMapping[
        (data.relationship ?? '-').toUpperCase()]!['relation'];
    return Column(
      children: [
        Row(
          children: [
            CommonClientUI.nameAvatar(
              context,
              data.name,
              radius: 18,
              fontSize: 18,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: MarqueeWidget(
                          child: Text(
                            (data.name ?? '-').toTitleCase(),
                            style: headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: ColorConstants.black,
                            ),
                          ),
                        ),
                      ),
                      if (isSelected)
                        Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Image.asset(
                            AllImages().verifiedIcon,
                            width: 13,
                          ),
                        )
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    relation,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .titleLarge!
                        .copyWith(color: ColorConstants.tertiaryBlack),
                  )
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        Row(
          children: [
            Text.rich(
              TextSpan(
                text: 'CRN  ',
                style: titleLarge,
                children: [
                  TextSpan(
                    text: data.crn,
                    style: titleLarge?.copyWith(
                      color: ColorConstants.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: CommonUI.buildProfileDataSeperator(
                height: 14,
                width: 1,
                color: ColorConstants.secondarySeparatorColor,
              ),
            ),
            GetBuilder<ClientDetailController>(
              builder: (controller) {
                return ClickableText(
                  text: 'View Full Profile',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  onClick: () async {
                    controller.switchToFamilyProfileView(data);
                  },
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
