import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class SmartSearchAppBar extends StatelessWidget {
  const SmartSearchAppBar({Key? key, this.fromDeeplink = false})
      : super(key: key);

  final bool fromDeeplink;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 30, bottom: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 22),
                      child: InkWell(
                        onTap: () {
                          AutoRouter.of(context).popForced();
                        },
                        child: Image.asset(
                          AllImages().appBackIcon,
                          height: 32,
                          width: 32,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            AllImages().stars,
                            width: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Smart Search',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headlineMedium!
                                .copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: ColorConstants.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Find Clients, Products, and Quick Actions Instantly',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(color: ColorConstants.tertiaryBlack),
                ),
              ],
            ),
          ),
          if (fromDeeplink)
            Positioned(
              left: 20,
              top: 20,
              child: InkWell(
                onTap: () {
                  AutoRouter.of(context).popForced();
                },
                child: Image.asset(
                  AllImages().appBackIcon,
                  height: 32,
                  width: 32,
                ),
              ),
            )
        ],
      ),
    );
  }
}
