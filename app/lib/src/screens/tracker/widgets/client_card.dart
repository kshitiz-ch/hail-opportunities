import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';

class ClientCard extends StatelessWidget {
  final Client? client;
  final int index;
  final bool isValueSelected;
  final onClickHandler;

  ClientCard(
      {this.client,
      this.isValueSelected = false,
      this.index = 0,
      this.onClickHandler});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClickHandler,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 30).copyWith(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Row(
          children: [
            _buildClientLogo(context),
            SizedBox(width: 12),
            Expanded(child: _buildClientDetails(context)),
            _buildCheckBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckBox() {
    return Transform.scale(
      scale: 0.8,
      alignment: Alignment.centerRight,
      child: CommonUI.buildCheckbox(
        value: isValueSelected,
        unselectedBorderColor: ColorConstants.darkGrey,
        onChanged: (bool? value) {
          onClickHandler();
        },
      ),
    );
  }

  Widget _buildClientDetails(BuildContext context) {
    String? subtitle = '-';

    if (client != null && client!.mfEmail.isNotNullOrEmpty) {
      subtitle = client!.mfEmail;
    } else if (client != null && client!.email.isNotNullOrEmpty) {
      subtitle = client!.email;
    } else if (client != null && client!.phoneNumber.isNotNullOrEmpty) {
      subtitle = client!.phoneNumber;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (client?.name?.toTitleCase() ?? client!.email!),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                color: ColorConstants.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 2),
          child: Text(
            subtitle!,
            style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                  color: ColorConstants.tertiaryBlack,
                  height: 1.4,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildClientLogo(BuildContext context) {
    final effectiveIndex = index % 7;
    return CircleAvatar(
      backgroundColor: getRandomBgColor(effectiveIndex),
      child: Center(
        child: Text(
          client!.name!.initials,
          style: Theme.of(context).primaryTextTheme.displayMedium!.copyWith(
                color: getRandomTextColor(effectiveIndex),
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
      radius: 21,
    );
  }
}
