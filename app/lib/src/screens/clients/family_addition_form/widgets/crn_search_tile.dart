import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';

class CRNSearchTile extends StatelessWidget {
  const CRNSearchTile({
    Key? key,
    required this.client,
    this.effectiveIndex = 0,
    this.onTap,
  }) : super(key: key);

  final Client client;
  final int effectiveIndex;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildClientLogo(context),
          SizedBox(width: 12),
          Expanded(child: _buildClientDetails(context)),
        ],
      ),
    );
  }

  Widget _buildClientDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (client.name?.toTitleCase() ?? client.email!),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                color: ColorConstants.black,
                fontWeight: FontWeight.w500,
              ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 2),
          child: Text.rich(
            TextSpan(
              text: 'CRN : ',
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    color: ColorConstants.tertiaryBlack,
                    height: 1.4,
                  ),
              children: [
                TextSpan(
                  text: client.crn,
                  style:
                      Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                            color: ColorConstants.black,
                            height: 1.4,
                          ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClientLogo(BuildContext context) {
    return CircleAvatar(
      backgroundColor: getRandomBgColor(effectiveIndex),
      child: Center(
        child: Text(
          client.name!.initials,
          style: Theme.of(context).primaryTextTheme.displayMedium!.copyWith(
                color: getRandomTextColor(effectiveIndex),
                fontSize: 20,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
        ),
      ),
      radius: 21,
    );
  }
}
