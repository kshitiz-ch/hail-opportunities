import 'dart:math';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/controllers/home/universal_search_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecentSearch extends StatelessWidget {
  const RecentSearch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UniversalSearchController>(
      builder: (controller) {
        if (controller.recentSearches.isEmpty) {
          return SizedBox();
        }

        return Container(
          height: 50,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: EdgeInsets.only(left: 24),
              child: Row(
                children: [
                  Text(
                    'Recent Search',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(color: ColorConstants.secondaryBlack),
                  ),
                  SizedBox(width: 8),
                  ...controller.recentSearches
                      .sublist(0, min(controller.recentSearches.length, 10))
                      .map(
                        (e) => Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () {
                              MixPanelAnalytics.trackWithAgentId(
                                "recent_search_click",
                                screen: 'universal_search',
                                screenLocation: 'recent_search',
                              );

                              controller.searchController?.text = e;
                              FocusScope.of(context).unfocus();
                              controller.searchText = e;
                              controller.universalSearch(e);
                            },
                            child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: ColorConstants.borderColor,
                                  ),
                                ),
                                child: Text(
                                  e,
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .headlineSmall!
                                      .copyWith(
                                          color: ColorConstants.tertiaryBlack),
                                )),
                          ),
                        ),
                      )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
