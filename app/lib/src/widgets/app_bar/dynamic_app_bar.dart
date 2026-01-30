import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class DynamicAppBar extends StatelessWidget {
  final bool? showScrollAppBar;
  final String? title;
  final String? subtitle;
  final Widget? customWidget;

  const DynamicAppBar({
    Key? key,
    this.showScrollAppBar,
    this.title,
    this.subtitle,
    this.customWidget,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return !showScrollAppBar!
        ? _buildInitialAppBar(context)
        : _buildOnScrollAppBar(context);
  }

  Widget _buildOnScrollAppBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: getSafeTopPadding(24, context), left: 24),
      height: 56,
      color: Colors.transparent,
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              AutoRouter.of(context).popForced();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: ColorConstants.tertiaryBlack,
              size: 20.0,
            ),
          ),
          Text(
            title!,
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  height: 17 / 14,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 56,
              color: Colors.transparent,
              margin: EdgeInsets.only(
                  top: getSafeTopPadding(24, context), left: 24),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  AutoRouter.of(context).popForced();
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: ColorConstants.tertiaryBlack,
                  size: 20.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text(
                title!,
                style:
                    Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                          fontSize: 20,
                          color: ColorConstants.black,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 24.0, left: 30),
              child: Text(
                subtitle!,
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          color: ColorConstants.tertiaryBlack,
                        ),
              ),
            ),
          ],
        ),
        if (customWidget != null) customWidget!
      ],
    );
  }
}
