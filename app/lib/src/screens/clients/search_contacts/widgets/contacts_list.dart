import 'dart:math';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';

class ContactsList extends StatelessWidget {
  const ContactsList({Key? key, this.contacts, this.onClientSelected})
      : super(key: key);

  final List<Client>? contacts;
  final Function(Client)? onClientSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // in iOS default scroll behaviour is BouncingScrollPhysics
      // in android its ClampingScrollPhysics Setting
      //ClampingScrollPhysics explicitly for both
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: contacts!.length,
      itemBuilder: (BuildContext context, int index) {
        return _buidlContactCard(
          context,
          effectiveIndex: index % 7,
          contact: contacts![index],
        );
      },
    );
  }

  Widget _buidlContactCard(BuildContext context,
      {int? effectiveIndex, required Client contact}) {
    return GestureDetector(
      onTap: () {
        onClientSelected!(contact);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildClientLogo(context, effectiveIndex, contact),
            SizedBox(width: 12),
            Expanded(child: _buildClientDetails(context, contact)),
          ],
        ),
      ),
    );
  }

  Widget _buildClientLogo(
      BuildContext context, int? effectiveIndex, Client contact) {
    final color = pickColor(Random().nextInt(4));
    String contactInital = contact.name!.initials;
    RegExp regExp = new RegExp('^[a-zA-Z]');

    bool isInitialAlphabet = regExp.hasMatch(contactInital);

    return CircleAvatar(
      backgroundColor: effectiveIndex != null
          ? getRandomBgColor(effectiveIndex)
          : color.withOpacity(0.5),
      child: Center(
        child: Text(
          isInitialAlphabet ? contact.name!.initials : "-",
          style: Theme.of(context).primaryTextTheme.displayMedium!.copyWith(
                color: effectiveIndex != null
                    ? getRandomTextColor(effectiveIndex)
                    : color,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
      radius: 21,
    );
  }

  Widget _buildClientDetails(BuildContext context, Client contact) {
    String? subtitle = '-';

    if (contact.phoneNumber != null) {
      subtitle = contact.phoneNumber;
    } else if (contact.email != null && contact.email.toString().isNotEmpty) {
      subtitle = contact.email;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (contact.name?.toTitleCase() ?? contact.email!),
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
}
