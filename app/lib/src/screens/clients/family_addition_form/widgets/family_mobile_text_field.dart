import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/client/client_family_controller.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class FamilyMobileTextField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final label = 'Mobile Number ';
    final textStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
              height: 1.4,
            );
    final hintStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.tertiaryBlack,
              height: 0.7,
            );
    return GetBuilder<ClientFamilyController>(
      builder: (controller) {
        return Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: Autocomplete(
            optionsBuilder: (textEditingValue) {
              return <String>[
                "${controller.client!.phoneNumber!.substring(controller.client!.phoneNumber!.length - 10)}"
              ];
            },
            onSelected: (String selection) {
              controller.mobileNumberController!.text = selection;
              controller.update();
            },
            fieldViewBuilder: (BuildContext context,
                TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted) {
              return TextFormField(
                // if we don't use callback controller here
                // then autocomplete feature not working
                controller: textEditingController,
                keyboardType: TextInputType.phone,
                style: textStyle,
                inputFormatters: [
                  NoLeadingSpaceFormatter(),
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(
                    controller.countryCode == indiaCountryCode ? 10 : 15,
                  )
                ],
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  controller.mobileNumberController!.text = value;
                  controller.update();
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return '$label is required.';
                  }
                  if (value.length < 10) {
                    return 'Mobile Number should be at least 10 characters';
                  }
                  return null;
                },
                obscureText: false,
                focusNode: focusNode,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                readOnly: false,
                scrollPadding: const EdgeInsets.only(bottom: 100.0),
                decoration: InputDecoration(
                  isDense: true,
                  errorStyle: Theme.of(context)
                      .primaryTextTheme
                      .bodyMedium!
                      .copyWith(
                          color: ColorConstants.errorTextColor, fontSize: 12),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: ColorConstants.lightGrey,
                    ),
                  ),
                  errorMaxLines: 2,
                  contentPadding: EdgeInsets.only(bottom: 8),
                  hintText: null,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: ColorConstants.primaryAppColor,
                    ),
                  ),
                  labelStyle: hintStyle,
                  labelText: label,
                  hintStyle: hintStyle,
                  prefixIcon: CountryCodePicker(
                    padding: EdgeInsets.only(right: 8),
                    initialSelection: indiaCountryCode,
                    flagWidth: 20.0,
                    showFlag: true,
                    showFlagDialog: true,
                    textStyle: textStyle.copyWith(
                      color: ColorConstants.black,
                      fontWeight: FontWeight.w600,
                    ),
                    onChanged: (CountryCode countryCode) {
                      controller.updateCountryCode(countryCode.dialCode);
                    },
                  ),
                  prefixIconConstraints: BoxConstraints.loose(Size(100, 36)),
                  suffixIconConstraints: BoxConstraints.loose(Size(100, 36)),
                ),
              );
            },
            optionsViewBuilder: (BuildContext context,
                void Function(String) onSelected, Iterable<String> options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(4.0)),
                  ),
                  color: Colors.white,
                  elevation: 2.0,
                  child: LayoutBuilder(
                    builder: (context, constraint) {
                      return ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: 100,
                            maxWidth: constraint.maxWidth - 60,
                          ),
                          child: ListView.builder(
                            itemCount: options.length,
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  onSelected(options.elementAt(0));
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 20),
                                  child: Text(
                                    "Use ${controller.client!.name}'s Number ${options.elementAt(0)}",
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .titleLarge!
                                        .copyWith(
                                          color: ColorConstants.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                              );
                            },
                          ));
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
