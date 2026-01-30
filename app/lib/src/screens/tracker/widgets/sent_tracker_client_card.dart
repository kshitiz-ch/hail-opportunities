import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';

class SentTrackerClientCard extends StatelessWidget {
  final Client? client;
  final int index;
  final String? trackerLink;

  SentTrackerClientCard({
    this.client,
    this.index = 0,
    this.trackerLink,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: ColorConstants.separatorColor.withOpacity(0.5),
      ),
      child: Row(
        children: [
          _buildClientLogo(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _buildClientDetails(context),
            ),
          ),
          _buildShareLink(context)
        ],
      ),
    );
  }

  Widget _buildShareLink(BuildContext context) {
    if (trackerLink.isNullOrEmpty) {
      return Text(
        'Request Failed',
        style: context.headlineSmall!.copyWith(
          color: ColorConstants.errorTextColor,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    final message =
        "Hey ${client?.name ?? 'there'}, here is the tracker sync request link for you ${trackerLink}.";

    return InkWell(
      onTap: () {
        shareText(message);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.share,
            color: ColorConstants.primaryAppColor,
            size: 20,
          ),
          SizedBox(width: 6),
          Text(
            'Share link',
            style: context.headlineSmall!.copyWith(
                color: ColorConstants.primaryAppColor,
                fontWeight: FontWeight.w700),
          )
        ],
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
