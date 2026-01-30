import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/client/goal/switch_order_controller.dart';
import 'package:app/src/widgets/card/scheme_folio_card.dart';
import 'package:app/src/widgets/input/search_box.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SwitchInDropdownList extends StatelessWidget {
  const SwitchInDropdownList({
    Key? key,
    required this.schemes,
    required this.onSchemeSelect,
    required this.controller,
  }) : super(key: key);

  final List<SchemeMetaModel> schemes;
  final Function(SchemeMetaModel schemeData) onSchemeSelect;
  final SwitchOrderController controller;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GetBuilder<SwitchOrderController>(
        id: 'search',
        initState: (_) {
          Get.find<SwitchOrderController>().getFunds();
        },
        builder: (controller) {
          return GestureDetector(
            onTap: () {
              AutoRouter.of(context).popForced();
            },
            child: Container(
              color: Colors.black.withOpacity(0.6),
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
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // if (schemes.isNotNullOrEmpty)
                                Container(
                                  padding: EdgeInsets.only(
                                      left: 12, right: 12, top: 20, bottom: 10),
                                  child: SearchBox(
                                    labelText: "Search for funds",
                                    textEditingController:
                                        controller.searchFundController,
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
                                ),
                                if (controller.fundsState ==
                                    NetworkState.loading)
                                  _builLoadingIndicator(context)
                                else if ((controller.fundsResult.isEmpty &&
                                        schemes.isEmpty) ||
                                    controller.fundsState == NetworkState.error)
                                  _buildEmptyState(context)
                                else
                                  _buildSchemeList(context, controller)
                              ],
                            ),
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

  Widget _buildSchemeList(
      BuildContext context, SwitchOrderController controller) {
    return Flexible(
      child: Scrollbar(
        thumbVisibility: true,
        radius: Radius.circular(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Goal Funds
              ListView.builder(
                itemCount: schemes.length,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  SchemeMetaModel scheme = schemes[index];

                  return _buildFundCard(context, scheme);
                },
              ),

              // Non Goal, Same AMC funds
              GetBuilder<SwitchOrderController>(
                id: 'search',
                builder: (controller) {
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: controller.fundsResult.length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
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
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: ColorConstants.borderColor),
          ),
        ),
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
