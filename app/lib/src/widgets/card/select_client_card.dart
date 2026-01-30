import 'dart:math';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/common/select_client_controller.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectClientCard extends StatelessWidget {
  final Client? client;
  final bool isFamily;
  final int? effectiveIndex;
  final Function(Client?, bool)? onClientSelected;

  SelectClientCard({
    Key? key,
    this.client,
    this.isFamily = false,
    this.effectiveIndex,
    this.onClientSelected,
  }) : super(key: key);

  final SelectClientController controller = Get.find<SelectClientController>();

  @override
  Widget build(BuildContext context) {
    bool isSelected = false;

    if (client!.isSourceContacts) {
      isSelected =
          client?.phoneNumber == controller.selectedClient?.phoneNumber;
    } else {
      isSelected = client!.taxyID == controller.selectedClient?.taxyID;
    }

    return GestureDetector(
      onTap: () {
        if (onClientSelected != null) {
          onClientSelected!(client, false);
        } else {
          controller.onClientSelect(client);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorConstants.secondaryAppColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildClientLogo(context),
            SizedBox(width: 12),
            Expanded(child: _buildClientDetails(context)),
            if (client?.panUsageType.isNotNullOrEmpty ?? false)
              _buildAccountType(context)
            // if (client!.isSourceContacts) _buildClientSource(context),
            // if (isFamily && isSelected) _buildSelectedWidget(context)
          ],
        ),
      ),
    );
  }

  Widget _buildAccountType(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: ColorConstants.borderColor,
        ),
      ),
      child: Text(
        getPanUsageDescription(client!.panUsageType!),
        style: Theme.of(context)
            .primaryTextTheme
            .titleLarge!
            .copyWith(color: ColorConstants.tertiaryBlack, fontSize: 10),
      ),
    );
  }

  Widget _buildSelectedWidget(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            Icons.check,
            color: Colors.black,
          ),
        ),
        Text(
          'Selected',
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                color: ColorConstants.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Widget _buildClientDetails(BuildContext context) {
    String? subtitle = '-';

    if (client?.phoneNumber != null) {
      subtitle = client!.phoneNumber;
    } else if (client?.email != null && client!.email.toString().isNotEmpty) {
      subtitle = client!.email;
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
            client?.crn ?? '',
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
    final color = pickColor(Random().nextInt(4));
    return CircleAvatar(
      backgroundColor: effectiveIndex != null
          ? getRandomBgColor(effectiveIndex!)
          : color.withOpacity(0.5),
      child: Center(
        child: Text(
          client!.name!.initials,
          style: Theme.of(context).primaryTextTheme.displayMedium!.copyWith(
                color: effectiveIndex != null
                    ? getRandomTextColor(effectiveIndex!)
                    : color,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
      radius: 21,
    );
  }

  Widget _buildClientSource(BuildContext context) {
    return Text(
      'Contacts',
      style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
            color: ColorConstants.primaryAppColor.withOpacity(0.7),
          ),
    );
  }
}
