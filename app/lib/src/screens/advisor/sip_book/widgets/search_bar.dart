import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/advisor/sip_book_controller.dart';
import 'package:app/src/widgets/input/sip_book_filter/filter_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

class SearchBarSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final customBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        width: 1,
        color: ColorConstants.searchBarBorderColor,
      ),
    );
    return GetBuilder<SipBookController>(
      builder: (controller) {
        return Container(
          decoration: BoxDecoration(
            color: ColorConstants.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ColorConstants.searchBarBorderColor,
            ),
            boxShadow: [
              BoxShadow(
                color: ColorConstants.darkBlack.withOpacity(0.1),
                offset: Offset(0.0, 4.0),
                spreadRadius: 0.0,
                blurRadius: 10.0,
              ),
            ],
          ),
          child: TypeAheadField(
            // minCharsForSuggestions: 2,
            debounceDuration: Duration(milliseconds: 500),
            controller: controller.searchController,
            // textFieldConfiguration: TextFieldConfiguration(
            //   ,
            // ),
            emptyBuilder: (value) {
              return Center(
                child: Text(
                  'No Items Found',
                  style: Theme.of(context).primaryTextTheme.headlineSmall,
                ),
              );
            },
            decorationBuilder: (context, child) {
              return Material(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                shadowColor: ColorConstants.darkBlack.withOpacity(0.6),
                elevation: 2.0,
                child: child,
              );
            },
            suggestionsCallback: (pattern) async {
              return await controller.getSearchClients(pattern);
            },
            builder: (context, searchController, focusNode) {
              return TextField(
                autofocus: false,
                focusNode: focusNode,
                controller: searchController,
                style:
                    Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                          color: ColorConstants.black,
                          fontWeight: FontWeight.w400,
                        ),
                decoration: InputDecoration(
                  hintText: 'Search for a client',
                  hintStyle: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        height: 1.4,
                        color: ColorConstants.secondaryBlack,
                      ),
                  prefixIcon: IconButton(
                    icon: SvgPicture.asset(
                      AllImages().searchIcon,
                      width: 24,
                      height: 24,
                    ),
                    onPressed: null,
                  ),
                  suffixIcon: _buildSuffixButtons(context, controller),
                  border: customBorder,
                  enabledBorder: customBorder,
                  focusedBorder: customBorder,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 18, horizontal: 6),
                  labelStyle: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        height: 1.4,
                        color: ColorConstants.secondaryBlack,
                      ),
                ),
              );
            },
            itemBuilder: (context, suggestion) {
              Client client = suggestion;

              return ListTile(
                tileColor: ColorConstants.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                // leading: Icon(Icons.shopping_cart),
                title: Text(
                  client.name ?? '-',
                  style: Theme.of(context).primaryTextTheme.headlineMedium,
                ),
                subtitle: client.email.isNotNullOrEmpty
                    ? Text(
                        client.email!,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .copyWith(color: ColorConstants.tertiaryBlack),
                      )
                    : null,
              );
            },
            onSelected: (suggestion) {
              MixPanelAnalytics.trackWithAgentId(
                "search_bar_click",
                screen: 'sip_book',
                screenLocation: 'sip_book',
              );
              controller.selectClient(suggestion);
            },
          ),
        );
      },
    );
  }

  Widget _buildSuffixButtons(
      BuildContext context, SipBookController controller) {
    final showFilterIcon =
        (controller.selectedSipBookTab != SipBookTabType.Offline);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (controller.searchController.text.isNotNullOrEmpty)
          IconButton(
            icon: Icon(
              Icons.clear,
              size: 20.0,
            ),
            onPressed: () {
              controller.resetSelectClient();
            },
          ),
        if (showFilterIcon)
          CommonUI.buildProfileDataSeperator(
            height: 20,
            width: 1,
            color: ColorConstants.borderColor,
          ),
        if (showFilterIcon) FilterButton(),
      ],
    );
  }
}
