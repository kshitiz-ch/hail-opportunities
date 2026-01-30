import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';

class UpdateFormHeader extends StatelessWidget {
  final String? header;
  final String? description;
  final String? label;
  final String? currentValue;
  final bool? isVerified;
  final TextEditingController? textController;

  // for update form
  final Function(String)? onUpdateCountryCode;
  final String? countryCode;

  UpdateFormHeader({
    this.header,
    this.description,
    this.currentValue,
    this.label,
    this.isVerified = false,
    this.textController,
    this.onUpdateCountryCode,
    this.countryCode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header!,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                fontSize: 20,
                color: ColorConstants.black,
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 4),
        Text(
          description!,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                color: ColorConstants.tertiaryBlack,
              ),
        ),
        SizedBox(height: 20),
        Text(
          label!,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).primaryTextTheme.titleMedium!.copyWith(
                color: ColorConstants.tertiaryBlack,
              ),
        ),
        SizedBox(height: 7),
        Row(
          children: [
            Expanded(
              child: isVerified == false && textController != null
                  ? _buildTextField(context)
                  : Text(
                      currentValue.isNotNullOrEmpty
                          ? currentValue.toString()
                          : 'NA',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineMedium!
                          .copyWith(
                            fontWeight: FontWeight.w500,
                            color: ColorConstants.black,
                          ),
                    ),
            ),
            if (isVerified!)
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      AllImages().verifiedIcon,
                      width: 12,
                      height: 12,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Verified',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                            color: ColorConstants.greenAccentColor,
                          ),
                    ),
                  ],
                ),
              )
          ],
        )
      ],
    );
  }

  Widget _buildTextField(BuildContext context) {
    final showCountryCodeIcon = onUpdateCountryCode != null;
    return TextField(
      controller: textController,
      keyboardType:
          showCountryCodeIcon ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(6),
        prefixIconConstraints:
            showCountryCodeIcon ? BoxConstraints.loose(Size(100, 36)) : null,
        prefixIcon: showCountryCodeIcon
            ? CountryCodePicker(
                padding: EdgeInsets.only(right: 8),
                initialSelection: countryCode,
                flagWidth: 20.0,
                showFlag: true,
                showFlagDialog: true,
                textStyle: context.headlineMedium!.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w600,
                ),
                onChanged: (CountryCode countryCode) {
                  onUpdateCountryCode!(countryCode.dialCode!);
                },
              )
            : null,
      ),
      style: context.headlineMedium!.copyWith(
        fontWeight: FontWeight.w500,
        color: ColorConstants.black,
      ),
    );
  }
}
