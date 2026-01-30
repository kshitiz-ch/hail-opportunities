import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/config/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PMSProviderCard extends StatelessWidget {
  // Fields
  final String title;
  final int? productCount;
  final String? iconUrl;
  final String? description;
  final VoidCallback? onPressed;

  // Constructor
  const PMSProviderCard({
    Key? key,
    required this.title,
    this.productCount,
    this.iconUrl,
    this.description,
    this.onPressed,
  }) : super(key: key);

  const PMSProviderCard.empty({
    this.onPressed,
  })  : title = '',
        description = '',
        productCount = 0,
        iconUrl = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.primaryCardColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      padding: EdgeInsets.all(20),
      child: InkWell(
        splashColor: ColorConstants.secondaryWhite,
        onTap: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                iconUrl.isNotNullOrEmpty
                    ? CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 18,
                        child: iconUrl!.endsWith("svg")
                            ? SvgPicture.network(iconUrl!)
                            : Image.network(iconUrl!),
                      )
                    : SizedBox(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: CommonUI.buildColumnTextInfo(
                      title: title,
                      subtitle: description!,
                      subtitleMaxLength: 10,
                      titleStyle: Theme.of(context)
                          .primaryTextTheme
                          .headlineMedium!
                          .copyWith(
                            fontWeight: FontWeight.w600,
                            color: ColorConstants.black,
                          ),
                      subtitleStyle: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge!
                          .copyWith(
                            fontWeight: FontWeight.w400,
                            color: ColorConstants.tertiaryBlack,
                          ),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$productCount Product${productCount! > 1 ? 's' : ''}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium!
                        .copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_right_outlined,
                    color: ColorConstants.primaryAppColor,
                    size: 24,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
