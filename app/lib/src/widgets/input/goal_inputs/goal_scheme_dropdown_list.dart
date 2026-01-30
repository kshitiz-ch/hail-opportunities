import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/client/goal/goal_scheme_search_controller.dart';
import 'package:app/src/widgets/card/scheme_folio_card.dart';
import 'package:app/src/widgets/input/search_box.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GoalSchemeDropdownList extends StatelessWidget {
  const GoalSchemeDropdownList({
    Key? key,
    this.amcCode,
    required this.goalSchemes,
    required this.onSchemeSelect,
    this.switchFundType = SwitchFundType.SwitchOut,
  }) : super(key: key);

  final String? amcCode;
  final List<SchemeMetaModel> goalSchemes;
  final Function(SchemeMetaModel schemeData) onSchemeSelect;
  final SwitchFundType switchFundType;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GetBuilder<GoalSchemeSearchController>(
        init: GoalSchemeSearchController(
          switchFundType: switchFundType,
          amcCode: amcCode,
        ),
        id: 'search',
        builder: (controller) {
          return GestureDetector(
            onTap: () {
              AutoRouter.of(context).popForced();
            },
            child: Container(
              color: Colors.black.withOpacity(0.6),
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(30, 80, 30, 0),
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height -
                          (MediaQuery.of(context).viewInsets.bottom + 50),
                    ),
                    child: Column(
                      children: [
                        Container(
                          color: Colors.transparent,
                          margin: EdgeInsets.only(bottom: 5),
                          alignment: Alignment.topRight,
                          child: CommonUI.bottomsheetRoundedCloseIcon(context),
                        ),
                        Flexible(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            width: MediaQuery.of(context).size.width,
                            child: switchFundType == SwitchFundType.SwitchIn
                                ? _buildSwitchInDropdownContent(
                                    context, controller)
                                : _buildSwitchOutDropdownContent(
                                    context, controller),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSwitchInDropdownContent(BuildContext context, controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSearchBar(context, controller),
        if (controller.fundsState == NetworkState.loading)
          _builLoadingIndicator(context)
        else if ((controller.fundsResult.isEmpty && goalSchemes.isEmpty) ||
            controller.fundsState == NetworkState.error)
          _buildEmptyState(context)
        else
          _buildSchemeList(context)
      ],
    );
  }

  Widget _buildSwitchOutDropdownContent(BuildContext context, controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (goalSchemes.isNullOrEmpty)
          _buildEmptyState(context)
        else
          Flexible(
            child: Scrollbar(
              thumbVisibility: true,
              radius: Radius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  itemCount: goalSchemes.length,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(color: ColorConstants.borderColor);
                  },
                  itemBuilder: (BuildContext context, int index) {
                    SchemeMetaModel scheme = goalSchemes[index];

                    return _buildFundCard(context, scheme);
                  },
                ),
              ),
            ),
          )
      ],
    );
  }

  Widget _buildSearchBar(
      BuildContext context, GoalSchemeSearchController controller) {
    return Container(
      padding: EdgeInsets.only(left: 12, right: 12, top: 20, bottom: 10),
      child: SearchBox(
        labelText: "Search for funds",
        textEditingController: controller.searchFundController,
        prefixIcon: Icon(
          Icons.search,
          color: ColorConstants.tertiaryBlack,
        ),
        onChanged: (text) {
          if (text != controller.searchText) {
            controller.onFundSearch(text);
          }
        },
      ),
    );
  }

  Widget _builLoadingIndicator(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Text(
        "No Funds Found",
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .primaryTextTheme
            .headlineSmall!
            .copyWith(color: ColorConstants.black, fontSize: 13),
      ),
    );
  }

  Widget _buildSchemeList(BuildContext context) {
    return Flexible(
      child: Scrollbar(
        thumbVisibility: true,
        radius: Radius.circular(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Goal Funds
              ListView.separated(
                itemCount: goalSchemes.length,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(color: ColorConstants.borderColor);
                },
                itemBuilder: (BuildContext context, int index) {
                  SchemeMetaModel scheme = goalSchemes[index];

                  return _buildFundCard(context, scheme);
                },
              ),

              // Divider between two lists
              GetBuilder<GoalSchemeSearchController>(
                id: 'search',
                builder: (controller) {
                  if (goalSchemes.isNotEmpty &&
                      controller.fundsResult.isNotEmpty) {
                    return Divider(
                      color: ColorConstants.borderColor,
                    );
                  }

                  return SizedBox();
                },
              ),

              // Non Goal, Same AMC funds
              GetBuilder<GoalSchemeSearchController>(
                id: 'search',
                builder: (controller) {
                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: controller.fundsResult.length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                        color: ColorConstants.borderColor,
                      );
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return _buildFundCard(
                          context, controller.fundsResult[index]);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFundCard(BuildContext context, SchemeMetaModel scheme) {
    return InkWell(
      onTap: () {
        onSchemeSelect(scheme);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          children: [
            SchemeFolioCard(
              displayName: scheme.displayName,
              folioNumber: scheme.folioOverview?.folioNumber,
              minAmount: scheme.minDepositAmt,
            ),
            if (scheme.folioOverview?.exists ?? false)
              Padding(
                padding: EdgeInsets.only(top: 15),
                child: CommonClientUI.switchOrderUnitAmountRow(
                  context,
                  scheme.folioOverview?.currentValue,
                  scheme.folioOverview?.units,
                ),
              )
          ],
        ),
      ),
    );
  }
}
