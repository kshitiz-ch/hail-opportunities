import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';

class ClientCard extends StatelessWidget {
  const ClientCard(
      {Key? key,
      required this.client,
      this.isSelected = false,
      this.effectiveIndex = 0,
      this.suffixWidget,
      this.padding,
      this.onClick})
      : super(key: key);

  final Client client;
  final bool isSelected;
  final int effectiveIndex;
  final EdgeInsets? padding;
  final Widget? suffixWidget;
  final void Function()? onClick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        padding: padding ?? EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorConstants.secondaryAppColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildNameAvatar(context, client, effectiveIndex),
            SizedBox(width: 12),
            Expanded(child: _buildClientDetails(context, client)),
            if (suffixWidget != null)
              suffixWidget!
            else if (isSelected)
              _buildSelectedText(context)
          ],
        ),
      ),
    );
  }

  Widget _buildNameAvatar(
      BuildContext context, Client client, int effectiveIndex) {
    return CircleAvatar(
      backgroundColor: getRandomBgColor(effectiveIndex),
      child: Center(
        child: Text(
          client.name?.initials ?? '-',
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

  Widget _buildClientDetails(BuildContext context, Client client) {
    String? subtitle = '-';

    if (client.phoneNumber != null) {
      subtitle = client.phoneNumber;
    } else if (client.email != null && client.email.toString().isNotEmpty) {
      subtitle = client.email;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (client.name?.toTitleCase() ?? client.email!),
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

  Widget _buildSelectedText(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.done, color: ColorConstants.black),
        SizedBox(width: 6),
        Text(
          'Selected',
          style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(),
        ),
      ],
    );
  }
}
