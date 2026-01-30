import 'package:app/src/config/constants/color_constants.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class SimpleDropdownFormField<T> extends StatelessWidget {
  // Fields
  final List<T> items;
  final T? value;
  final String? label;
  final bool enabled;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final double? dropdownMaxHeight;
  final double? maxButtonHeight;
  final double? maxWidth;

  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;

  final Color? borderColor;
  final double borderRadius;
  final EdgeInsets? contentPadding;
  final bool useLabelAsHint;
  final String? Function(T?)? customText;
  final String hintText;
  final Widget? icon;
  final bool showBorder;
  final TextStyle? dropdownTextStyle;
  final TextStyle? selectedTextStyle;
  final bool removePadding;
  final Offset dropdownOffset;
  final AlignmentGeometry alignment;

  final Widget Function(T?)? customDropdownBuilder;
  final double? customMenuItemHeight;
  final Widget Function(T?)? customSelectedDropdownBuilder;
  final bool isCompulsory;

  // Constructor
  SimpleDropdownFormField({
    Key? key,
    required this.items,
    this.value,
    this.label,
    this.enabled = true,
    this.onChanged,
    this.validator,
    this.style,
    this.labelStyle,
    this.hintStyle,
    this.borderColor,
    this.borderRadius = 4,
    this.contentPadding,
    this.useLabelAsHint = false,
    this.dropdownMaxHeight,
    this.customText,
    this.maxButtonHeight = 50,
    this.maxWidth,
    required this.hintText,
    this.icon,
    this.showBorder = true,
    this.dropdownTextStyle,
    this.selectedTextStyle,
    this.removePadding = false,
    this.dropdownOffset = Offset.zero,
    this.alignment = AlignmentDirectional.centerStart,
    this.customDropdownBuilder,
    this.customMenuItemHeight,
    this.customSelectedDropdownBuilder,
    this.isCompulsory = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && !useLabelAsHint)
          Padding(
            padding: EdgeInsets.only(bottom: 5, left: 8),
            child: Text(
              label!,
              style: labelStyle ??
                  Theme.of(context)
                      .primaryTextTheme
                      .titleMedium!
                      .copyWith(color: Color(0xFF808080)),
            ),
          ),
        DropdownButtonFormField2(
          alignment: alignment,
          iconStyleData: IconStyleData(
            icon: icon ??
                Icon(
                  Icons.arrow_drop_down,
                  color: ColorConstants.tertiaryBlack,
                ),
          ),
          buttonStyleData: ButtonStyleData(
            elevation: 0,
            height: maxButtonHeight,
            width: maxWidth,
            decoration: showBorder
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(
                      color: ColorConstants.borderColor,
                    ),
                  )
                : null,
            padding:
                removePadding ? EdgeInsets.zero : EdgeInsets.only(right: 10),
          ),
          dropdownStyleData: DropdownStyleData(
            padding: removePadding ? EdgeInsets.zero : null,
            width: maxWidth,
            offset: dropdownOffset,
            elevation: 0,
            scrollbarTheme: ScrollbarThemeData(
              thumbVisibility: MaterialStateProperty.all<bool>(true),
              radius: Radius.circular(8),
              thickness: MaterialStateProperty.all<double>(5.0),
              mainAxisMargin: removePadding ? 0 : null,
              crossAxisMargin: removePadding ? 0 : null,
            ),
            maxHeight: dropdownMaxHeight ?? 200,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: ColorConstants.black.withOpacity(0.3),
                  offset: Offset(0.0, 1.0),
                  spreadRadius: 0.0,
                  blurRadius: 7.0,
                ),
              ],
              color: ColorConstants.white,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          style: style,
          value: items.contains(value) ? value : null,
          items: items.map((value) {
            return DropdownMenuItem(
              value: value,
              child: customDropdownBuilder != null
                  ? customDropdownBuilder!(value)
                  : Text(
                      customText != null
                          ? customText!(value)!
                          : value.toString(),
                      style: dropdownTextStyle ??
                          style ??
                          Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                color: enabled
                                    ? Colors.grey[700]
                                    : ColorConstants.darkGrey,
                                fontWeight: FontWeight.w600,
                              ),
                    ),
            );
          }).toList(),
          selectedItemBuilder: (BuildContext context) {
            return items.map(
              (value) {
                return customSelectedDropdownBuilder != null
                    ? customSelectedDropdownBuilder!(value)
                    : Text(
                        customText != null
                            ? customText!(value)!
                            : value.toString(),
                        style: selectedTextStyle ??
                            style ??
                            Theme.of(context)
                                .primaryTextTheme
                                .headlineSmall!
                                .copyWith(
                                  color: enabled
                                      ? Colors.grey[700]
                                      : ColorConstants.darkGrey,
                                  fontWeight: FontWeight.w600,
                                ),
                      );
              },
            ).toList();
          },
          hint: Text(
            hintText,
            style: hintStyle ??
                Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                      color: ColorConstants.tertiaryBlack,
                    ),
          ),
          isExpanded: true,
          menuItemStyleData: customMenuItemHeight != null
              ? MenuItemStyleData(height: customMenuItemHeight!)
              : const MenuItemStyleData(),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            // isDense: true,
            contentPadding: EdgeInsets.zero,
            border: showBorder
                ? OutlineInputBorder(
                    borderSide: BorderSide(color: ColorConstants.tertiaryBlack),
                    borderRadius: BorderRadius.circular(borderRadius),
                  )
                : null,
            labelText: useLabelAsHint && !isCompulsory ? label : null,
            label: isCompulsory && useLabelAsHint
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label ?? hintText,
                        style: hintStyle,
                      ),
                      Transform.translate(
                        offset: Offset(0, -2),
                        child: Text(
                          '*',
                          style: labelStyle?.copyWith(fontSize: 16),
                        ),
                      ),
                    ],
                  )
                : null,
            labelStyle: labelStyle,

            hintStyle: hintStyle ??
                Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                      color: Color(0xFFBEBEBE),
                      letterSpacing: -0.47,
                      fontWeight: FontWeight.w400,
                    ),
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorStyle: Theme.of(context)
                .primaryTextTheme
                .bodyMedium!
                .copyWith(color: ColorConstants.errorTextColor, fontSize: 12),
            errorMaxLines: 2,
          ),
          onChanged: enabled ? onChanged : null,
          validator: validator,
        ),
      ],
    );
  }
}
