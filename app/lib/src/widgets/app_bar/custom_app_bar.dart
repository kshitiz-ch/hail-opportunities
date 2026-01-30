import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final Function? onBackPress;
  final String? titleText;
  final String? subtitleText;
  final Widget? customTitleWidget;
  final Widget? customSubtitleWidget;
  final List<Widget> trailingWidgets;

  double appBarHeight = 50;
  // pass subtitle height if custom subtitle widget is used
  double? subtitleHeight;

  @override
  Size preferredSize;
  final double leadingLeftPadding;

  final int maxLine;
  final backButtonSize = 32.0;

  final Color? backgroundColor;

  CustomAppBar({
    Key? key,
    this.preferredSize = const Size(0, 0),
    this.showBackButton = true,
    this.onBackPress,
    this.titleText,
    this.subtitleText,
    this.customTitleWidget,
    this.customSubtitleWidget,
    this.appBarHeight = 50,
    this.trailingWidgets = const <Widget>[],
    this.leadingLeftPadding = 20,
    this.subtitleHeight,
    this.maxLine = 1,
    this.backgroundColor,
  }) : super(key: key) {
    subtitleHeight ??= calculateSubtitleHeight();

    // We do not add subtitleHeight to appBarHeight here because subtitle is part of the 'bottom' widget of AppBar
    // adding it here would cause double counting of height leading to extra whitespace

    if (backButtonSize > appBarHeight) {
      appBarHeight = backButtonSize + 10;
    }

    if (preferredSize.width == 0 || preferredSize.height == 0) {
      preferredSize = Size.fromHeight(appBarHeight + (subtitleHeight ?? 0));
    }
    // action right padding
    if (trailingWidgets.isNotNullOrEmpty) {
      trailingWidgets.add(SizedBox(width: 20));
    }
  }
  @override
  Widget build(BuildContext context) {
    final leadingWidth =
        (showBackButton ? backButtonSize : 0) + leadingLeftPadding;
    return AppBar(
      centerTitle: false,
      elevation: 0,
      toolbarHeight: appBarHeight,
      backgroundColor: backgroundColor ?? Colors.transparent,
      leadingWidth: leadingWidth,
      leading: _buildBackButton(context),
      title: _buildTitle(context),
      actions: trailingWidgets,
      bottom: subtitleText.isNullOrEmpty && customSubtitleWidget == null
          ? null
          : PreferredSize(
              child: Container(
                margin: EdgeInsets.only(bottom: 10),
                alignment: Alignment.topLeft,
                child: _buildSubtitle(context),
              ),
              preferredSize: Size.fromHeight(subtitleHeight ?? 0),
            ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return showBackButton
        ? Padding(
            padding: EdgeInsets.only(left: leadingLeftPadding),
            child: InkWell(
              onTap: () {
                if (onBackPress != null) {
                  onBackPress!();
                } else {
                  AutoRouter.of(context).popForced();
                }
              },
              child: Image.asset(
                AllImages().appBackIcon,
                height: backButtonSize,
                width: backButtonSize,
              ),
            ),
          )
        : SizedBox();
  }

  Widget _buildSubtitle(BuildContext context) {
    Widget? subtitleWidget;

    if (customSubtitleWidget != null) {
      subtitleWidget = customSubtitleWidget;
    } else if (subtitleText.isNotNullOrEmpty) {
      subtitleWidget = Text(
        subtitleText!,
        maxLines: 4,
        style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.w500,
              color: ColorConstants.tertiaryBlack,
            ),
      );
    }
    return (subtitleWidget != null)
        ? Padding(
            padding: EdgeInsets.only(
              left: 66 - (showBackButton ? 0 : 32),
              right: 20,
            ),
            child: subtitleWidget,
          )
        : SizedBox();
  }

  Widget _buildTitle(BuildContext context) {
    Widget? titleWidget;
    if (customTitleWidget != null) {
      titleWidget = customTitleWidget;
    } else if (titleText.isNotNullOrEmpty) {
      titleWidget = Text(
        titleText!,
        maxLines: maxLine,
        style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: ColorConstants.black,
            ),
      );
    }
    return titleWidget ?? SizedBox();
  }

  double calculateSubtitleHeight() {
    final context = getGlobalContext();
    double height = 0;
    if (context != null && subtitleText.isNotNullOrEmpty) {
      final span = TextSpan(
        text: subtitleText,
        style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.w500,
              color: ColorConstants.tertiaryBlack,
            ),
      );

      // Calculate available width for the subtitle text
      // 66.0 -> Leading padding (including back button if present)
      // 32.0 -> Adjustment if back button is not shown (to align correctly)
      // 20.0 -> Right padding
      double padding = (66.0 - (showBackButton ? 0 : 32)) + 20.0;
      double screenWidth = MediaQuery.of(context).size.width;

      // Calculate height with constraint width to account for text wrapping
      height = getTextHeight(
        span,
        maxWidth: screenWidth - padding,
      );
    }
    // bottom margin
    height += 10;
    return height;
  }
}
