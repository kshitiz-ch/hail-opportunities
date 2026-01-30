import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';

class ClientStoreCard extends StatelessWidget {
  final Client? client;
  final EdgeInsets? padding;

  const ClientStoreCard({Key? key, this.client, this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? subtitle = '-';

    if (client?.phoneNumber != null) {
      subtitle = client!.phoneNumber;
    } else if (client?.email != null && client!.email.toString().isNotEmpty) {
      subtitle = client!.email;
    }

    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 30).copyWith(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Client Details',
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.tertiaryBlack,
                ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildAvatar(context),
              SizedBox(
                width: 12,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (client?.name?.toTitleCase() ?? client?.email ?? ''),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                          color: ColorConstants.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge!
                          .copyWith(
                            color: ColorConstants.tertiaryGrey,
                            fontSize: 12,
                            height: 1.4,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(context) {
    return CircleAvatar(
      backgroundColor: getRandomBgColor(1),
      child: Center(
        child: Text(
          client?.name?.initials ?? '',
          style: Theme.of(context).primaryTextTheme.displayMedium!.copyWith(
                color: getRandomTextColor(1),
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
      radius: 21,
    );
  }
}
