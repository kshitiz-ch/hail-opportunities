import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';

class DematContactPhoneBottomSheet extends StatelessWidget {
  const DematContactPhoneBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact',
                style:
                    Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.black,
                        ),
              ),
              CommonUI.bottomsheetCloseIcon(context)
            ],
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              children: [
                _buildPhoneTile(context, "9606921395"),
                // Divider(
                //   color: ColorConstants.borderColor,
                // ),
                // _buildPhoneTile(context, "7506692756"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPhoneTile(BuildContext context, String phone) {
    return InkWell(
      onTap: () async {
        await launch('tel:$phone');
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            Icon(
              Icons.phone,
              color: ColorConstants.primaryAppColor,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              phone,
              style: Theme.of(context).primaryTextTheme.headlineMedium,
            )
          ],
        ),
      ),
    );
  }
}
