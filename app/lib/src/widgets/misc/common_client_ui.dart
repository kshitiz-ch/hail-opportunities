import 'dart:math';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/client.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/input/popup_dropdown/popup_dropdown_menu.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/account_details_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'common_ui.dart';

class CommonClientUI {
  static Widget nameAvatar(BuildContext context, String? name,
      {double radius = 27, double fontSize = 24}) {
    final color = pickColor(Random().nextInt(4));

    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withOpacity(0.6),
      child: Center(
        child: Text(
          name?.initials ?? '-',
          style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: color,
              ),
        ),
      ),
    );
  }

  static Widget formLabelValue(BuildContext context,
      {required String label,
      String? value,
      bool showBorder = true,
      Widget? suffixWidget}) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(
                bottom: BorderSide(color: ColorConstants.borderColor),
              )
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style:
                        Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                              color: ColorConstants.tertiaryBlack,
                            ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    (value != null && value.isNotEmpty) ? value : 'NA',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineLarge!
                        .copyWith(
                          fontSize: 14,
                        ),
                  )
                ],
              ),
            ),
            if (suffixWidget != null) suffixWidget
          ],
        ),
      ),
    );
  }

  static TextStyle getLabelStyle(context) {
    return Theme.of(context)
        .primaryTextTheme
        .headlineSmall!
        .copyWith(color: ColorConstants.tertiaryBlack, height: 1, fontSize: 12);
  }

  static TextStyle getTextStyle(context) {
    return Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
          color: ColorConstants.black,
          fontWeight: FontWeight.w500,
          height: 1.4,
        );
  }

  static Widget borderTextFormField(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    String? labelText,
    TextInputType? keyboardType,
    int? maxLength,
    bool? enabled,
    List<TextInputFormatter> inputFormatters = const [],
    Widget? prefixIcon,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
    EdgeInsetsGeometry? contentPadding,
    bool useLabelasHint = true,
    BoxConstraints? prefixIconConstraints,
    bool isCompulsory = false,
  }) {
    final hintStyle = context.headlineSmall!.copyWith(
      color: ColorConstants.tertiaryBlack,
      fontWeight: FontWeight.w500,
    );
    final textStyle = context.headlineSmall!.copyWith(
      color: ColorConstants.black,
      fontWeight: FontWeight.w500,
    );

    final labelStyle = context.titleMedium?.copyWith(color: Color(0xFF808080));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!useLabelasHint)
          Padding(
            padding: EdgeInsets.only(bottom: 5, left: 8),
            child: Text(
              labelText ?? hintText,
              style: labelStyle,
            ),
          ),
        TextFormField(
          controller: controller,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            contentPadding: contentPadding,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: ColorConstants.borderColor2,
              ),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: ColorConstants.borderColor2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: ColorConstants.primaryAppColor,
              ),
            ),
            focusColor: ColorConstants.primaryAppColor,
            prefixIcon: prefixIcon,
            prefixIconConstraints: prefixIconConstraints,
            hintStyle: hintStyle,
            labelStyle: hintStyle,
            hintText: hintText,
            label: isCompulsory && useLabelasHint
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        labelText ?? hintText,
                        style: hintStyle,
                      ),
                      Transform.translate(
                        offset: Offset(0, -2),
                        child: Text(
                          '*',
                          style: hintStyle.copyWith(fontSize: 16),
                        ),
                      ),
                    ],
                  )
                : null,
            labelText:
                useLabelasHint && !isCompulsory ? labelText ?? hintText : null,
            errorStyle: Theme.of(context)
                .primaryTextTheme
                .bodyMedium!
                .copyWith(color: ColorConstants.errorTextColor, fontSize: 12),
            errorMaxLines: 2,
          ),
          maxLength: maxLength,
          enabled: enabled,
          keyboardType: keyboardType,
          inputFormatters: [
            NoLeadingSpaceFormatter(),
          ]..addAll(inputFormatters),
          style: textStyle,
          onChanged: onChanged,
          validator: validator != null
              ? validator
              : (value) {
                  if (value.isNullOrEmpty) {
                    return 'This field is Required';
                  }
                  return null;
                },
        ),
      ],
    );
  }

  static Widget popupDropDownField({
    required BuildContext context,
    required String hint,
    required String errorMessage,
    required String selectedValue,
    required TextEditingController inputController,
    required List<String> items,
    required Function(String, int) onChanged,
    bool isCompulsory = false,
  }) {
    final isEnabled = items.isNullOrEmpty;
    return InkWell(
      focusColor: isEnabled ? Colors.transparent : ColorConstants.lightGrey,
      onTap: () {
        if (isEnabled) {
          return null;
        }
        AutoRouter.of(context).pushNativeRoute(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) => PopUpDropdownMenu(
              items: items,
              showSelectedValueSeparately: true,
              onChanged: (value, {index}) {
                if (value.isNotNullOrEmpty) {
                  onChanged(value!, index!);
                }
              },
              disableOthers: true,
              label: hint,
              selectedValue: selectedValue,
              searchController: TextEditingController(),
            ),
          ),
        );
      },
      child: CommonClientUI.borderTextFormField(
        context,
        hintText: hint,
        controller: inputController,
        enabled: isEnabled,
        isCompulsory: isCompulsory,
      ),
    );
  }

  static Widget columnInfoText(
    context, {
    required String title,
    String? subtitle,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: CommonUI.buildColumnTextInfo(
        title: title,
        titleStyle: Theme.of(context)
            .primaryTextTheme
            .headlineSmall!
            .copyWith(fontSize: 13, color: ColorConstants.tertiaryBlack),
        subtitle: subtitle ?? 'NA',
        subtitleStyle:
            Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  fontSize: 13,
                  color: ColorConstants.black,
                ),
      ),
    );
  }

  static Widget folioUnitAmountRow(
      BuildContext context, FolioModel? folioOverview) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Free Amount  ',
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          fontSize: 12,
                          color: ColorConstants.black,
                        ),
              ),
              TextSpan(
                text: WealthyAmount.currencyFormat(
                    folioOverview?.withdrawalAmountAvailable, 2),
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(
                        fontSize: 12, color: ColorConstants.tertiaryBlack),
              ),
            ],
          ),
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Free Units  ',
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          fontSize: 12,
                          color: ColorConstants.black,
                        ),
              ),
              TextSpan(
                text: (folioOverview?.withdrawalUnitsAvailable ?? 0)
                    .toStringAsFixed(3),
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(
                        fontSize: 12, color: ColorConstants.tertiaryBlack),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget switchOrderUnitAmountRow(
      BuildContext context, double? currentValue, double? units) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Current Value  ',
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          fontSize: 12,
                          color: ColorConstants.black,
                        ),
              ),
              TextSpan(
                text: WealthyAmount.currencyFormat(currentValue, 2),
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(
                        fontSize: 12, color: ColorConstants.tertiaryBlack),
              ),
            ],
          ),
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Units  ',
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          fontSize: 12,
                          color: ColorConstants.black,
                        ),
              ),
              TextSpan(
                text: (units ?? 0).toStringAsFixed(3),
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(
                        fontSize: 12, color: ColorConstants.tertiaryBlack),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget disabledFieldInfo(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 5, left: 5),
      child: Row(
        children: [
          Icon(
            Icons.info,
            color: ColorConstants.tertiaryBlack,
          ),
          SizedBox(width: 2),
          Text(
            'This field cannot edit if KYC is submitted',
            style: Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(color: ColorConstants.tertiaryBlack, fontSize: 12),
          ),
        ],
      ),
    );
  }

  static Widget mandateBankTile(BuildContext context, BankAccountModel bank,
      {Function()? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap != null ? onTap : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bank.bank ?? '-',
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineMedium!
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Text(
                  WealthyCast.toStr(bank.number) ?? '-',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(color: ColorConstants.tertiaryBlack),
                ),
                Text(
                  ' | ',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(color: ColorConstants.tertiaryBlack),
                ),
                Text(
                  'IFSC ${bank.ifsc ?? '-'}',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(color: ColorConstants.tertiaryBlack),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget goalTransactStatus(BuildContext context,
      {bool? isPaused, DateTime? endDate}) {
    final data = getGoalTransactStatusData(isPaused, endDate);

    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: data['statusText'] == 'Inactive'
            ? Border.all(
                color: ColorConstants.darkGrey.withOpacity(0.2),
              )
            : Border(),
        color: ColorConstants.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(right: 6),
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: data['iconBackgroundColor'],
              shape: BoxShape.circle,
            ),
            child: Icon(
              data['icon'],
              size: 16,
              color: ColorConstants.white,
            ),
          ),
          Text(
            data['statusText'],
            style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                  color: ColorConstants.black,
                ),
          )
        ],
      ),
    );
  }

  static Widget goalTransactDays(
    BuildContext context,
    List<int> days, {
    int daysLimit = 3,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.calendar_month,
          color: ColorConstants.tertiaryBlack,
          size: 16,
        ),
        SizedBox(width: 4),
        Text(
          getGoalTransactDays(days, limit: daysLimit),
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.black, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // Edit, Delete
  static Widget goalTransactSchemeActions(BuildContext context,
      {required Function() onEdit, required Function() onDelete}) {
    return Row(
      children: [
        InkWell(
          onTap: onDelete,
          child: Row(
            children: [
              Image.asset(
                AllImages().deleteIcon,
                height: 12,
                width: 10,
                // fit: BoxFit.fitWidth,
              ),
              SizedBox(width: 6),
              Text(
                'Delete',
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(color: ColorConstants.tertiaryBlack),
              )
            ],
          ),
        ),
        SizedBox(width: 15),
        InkWell(
          onTap: onEdit,
          child: Row(
            children: [
              Image.asset(
                AllImages().editIcon,
                height: 10,
                width: 10,
                color: ColorConstants.primaryAppColor,
              ),
              SizedBox(width: 6),
              Text(
                'Edit',
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(color: ColorConstants.tertiaryBlack),
              )
            ],
          ),
        ),
      ],
    );
  }

  static Widget showEmptyFoliosCheckbox(BuildContext context,
      bool showEmptyFolios, Function toggleShowEmptyFolios) {
    return Row(
      children: [
        CommonUI.buildCheckbox(
          value: showEmptyFolios,
          onChanged: (bool? value) {
            toggleShowEmptyFolios();
          },
        ),
        Text(
          'Show Zero Balance Products',
          style: Theme.of(context)
              .primaryTextTheme
              .titleLarge
              ?.copyWith(color: ColorConstants.tertiaryBlack),
        )
      ],
    );
  }

  static Widget absoluteAnnualisedSwitch(
    BuildContext context, {
    required bool showAbsoluteReturn,
    Function? onTap,
    TextStyle? textStyle,
    Color? iconColor,
  }) {
    final isDisabled = onTap == null;
    return InkWell(
      onTap: () {
        if (isDisabled) return;
        onTap();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            showAbsoluteReturn ? 'Absolute' : 'XIRR',
            style: textStyle ??
                Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                      color: ColorConstants.tertiaryBlack,
                    ),
          ),
          SizedBox(width: 4),
          if (!isDisabled)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 3),
              decoration: BoxDecoration(
                color: ColorConstants.secondaryAppColor,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: iconColor ?? ColorConstants.primaryAppColor,
                    size: 10,
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: iconColor ?? ColorConstants.primaryAppColor,
                    size: 10,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static Widget buildRowTextInfo({
    required String title,
    required String subtitle,
    required TextStyle titleStyle,
    required TextStyle subtitleStyle,
    double gap = 6,
    Function? onTap,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: titleStyle),
        SizedBox(width: gap),
        GestureDetector(
          onTap: () {
            if (onTap != null) {
              onTap();
            }
          },
          child: Text(subtitle, style: subtitleStyle),
        )
      ],
    );
  }

  static Widget buildProfileReturnUI({
    required List<MapEntry<String, double>> returnData,
    bool rowLayout = false,
    required BuildContext context,
  }) {
    final titleStyle = Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: ColorConstants.tertiaryBlack,
        );
    final subtitleStyle =
        Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: ColorConstants.greenAccentColor,
            );
    if (rowLayout) {
      return SizedBox(
        height: 50,
        child: Row(
          children: returnData.map(
            (data) {
              final color = data.value.isNegative
                  ? ColorConstants.redAccentColor
                  : ColorConstants.greenAccentColor;
              final icon = data.value.isNegative
                  ? AllImages().lossIcon
                  : AllImages().gainIcon;
              final value = data.key.toLowerCase().contains('loss')
                  ? WealthyAmount.currencyFormat(data.value, 0)
                  : '${data.value.toStringAsFixed(1)}%';
              return Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.key, style: titleStyle),
                    SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(icon, height: 10, width: 10),
                        SizedBox(width: 4),
                        Text(value,
                            style: subtitleStyle?.copyWith(color: color)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ).toList(),
        ),
      );
    } else {
      return ListView.separated(
        padding: EdgeInsets.zero,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: returnData.length,
        itemBuilder: (context, index) {
          final color = returnData[index].value.isNegative
              ? ColorConstants.redAccentColor
              : ColorConstants.greenAccentColor;
          final icon = returnData[index].value.isNegative
              ? AllImages().lossIcon
              : AllImages().gainIcon;
          final value = returnData[index].key.toLowerCase().contains('loss')
              ? WealthyAmount.currencyFormat(returnData[index].value, 0)
              : '${returnData[index].value.toStringAsFixed(1)}%';
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  returnData[index].key,
                  style: titleStyle,
                  maxLines: 2,
                ),
              ),
              SizedBox(width: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(icon, height: 10, width: 10),
                  SizedBox(width: 4),
                  Text(value, style: subtitleStyle?.copyWith(color: color)),
                ],
              ),
            ],
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(height: 10);
        },
      );
    }
  }
}
