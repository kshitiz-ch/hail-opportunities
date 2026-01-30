import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InsuranceCard extends StatelessWidget {
  // Fields
  final String? title;
  final int? optionNumber;
  final String? productIcon;
  final VoidCallback? onPressed;
  final Color? bgColor;

  // Constructor
  const InsuranceCard(
      {Key? key,
      required this.title,
      this.optionNumber,
      this.productIcon,
      this.onPressed,
      this.bgColor})
      : super(key: key);

  const InsuranceCard.empty({this.onPressed, this.bgColor})
      : title = '',
        optionNumber = 0,
        productIcon = "";

  @override
  Widget build(BuildContext context) {
    double iconHeight = deviceSpecificValue(context, 40, 50);

    return Card(
      elevation: 0,
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              if (productIcon != null)
                productIcon!.endsWith("svg")
                    ? SvgPicture.network(
                        productIcon!,
                        height: iconHeight,
                      )
                    : Image.network(
                        productIcon!,
                        height: iconHeight,
                      ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: Text(
                  title!.toTitleCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        fontSize: deviceSpecificValue(context, 14, 16),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
