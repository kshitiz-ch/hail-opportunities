import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/screens/store/mf_lobby/widgets/wealthy_select_section.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/common_mf_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/store/models/mf/screener_model.dart';
import 'package:flutter/material.dart';

@RoutePage()
class CuratedFundsScreen extends StatelessWidget {
  CuratedFundsScreen({
    Key? key,
    this.screener,
    this.fromFundIdeasScreen = false,
    @queryParam this.page,
  }) : super(key: key);

  ScreenerModel? screener;
  final bool fromFundIdeasScreen;
  final String? page;

  @override
  Widget build(BuildContext context) {
    bool fromTopFundsDeepLink = page == "top-funds";
    if (fromTopFundsDeepLink) {
      screener = ScreenerModel.fromJson(
        {
          "wpc": "SCR00000029",
          "name": "Top Performers",
          "instrument_type": "schemes",
          "description": null,
          "additional_data": [],
          "query_params": {},
          "uri": "/market/v0/screeners/schemes/SCR00000029/custom/"
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        titleText: screener?.name,
      ),
      body: screener == null
          ? _buildEmptySection()
          : SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(bottom: 50),
                child: WealthySelectSection(
                  screener: screener!,
                  fromCuratedFundsScreen: true,
                  fromFundIdeasScreen: fromFundIdeasScreen,
                ),
              ),
            ),
      bottomNavigationBar: CommonMfUI.buildMfLobbyBottomNavigationBar(),
    );
  }

  Widget _buildEmptySection() {
    return EmptyScreen(
      message: 'No Funds Found',
    );
  }
}
