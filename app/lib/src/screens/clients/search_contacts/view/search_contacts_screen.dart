import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/client/search_contacts_controller.dart';
import 'package:app/src/screens/clients/search_contacts/widgets/contacts_list.dart';
import 'package:app/src/screens/clients/search_contacts/widgets/search_bar_section.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

@RoutePage()
class SearchContactsScreen extends StatelessWidget {
  final Function(Client)? onClientSelected;

  const SearchContactsScreen({Key? key, required this.onClientSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SearchContactsController>(
      init: SearchContactsController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.white,
          // AppBar
          appBar: CustomAppBar(
            showBackButton: true,
            titleText: 'Search Contact',
          ),

          // Body
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Search Bar
              SearchBarSection(),
              const SizedBox(height: 24),

              if (controller.searchResponse.state == NetworkState.loading)
                _buildLoadingIndicator()
              else if (controller.searchQuery.isEmpty)
                _buildEmptyText(context)
              else if (controller.searchResponse.state == NetworkState.loaded)
                _buildClientsList(controller, context)
              else
                _buildRetryWidget(controller)
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Expanded(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyText(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 200),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AllImages().fundSearchIcon,
              width: 104,
            ),
            SizedBox(height: 24),
            Text(
              'Search from your contacts',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineMedium!
                  .copyWith(
                      color: ColorConstants.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRetryWidget(SearchContactsController controller) {
    return Expanded(
      child: Center(
        child: RetryWidget(
          controller.searchResponse.message,
          onPressed: () {
            controller.getContacts(query: controller.searchQuery);
          },
        ),
      ),
    );
  }

  Widget _buildClientsList(
    SearchContactsController controller,
    BuildContext context,
  ) {
    bool isSearchResultEmpty =
        controller.searchQuery.isNotEmpty && controller.contacts.length == 0;

    if (isSearchResultEmpty) {
      return EmptyScreen(
        imagePath: AllImages().clientEmptyIcon,
        imageSize: 92,
        message: 'No Results found',
      );
    }

    bool isInSearchMode = controller.searchQuery.isNotEmpty;
    List<Client> contactsListToShow = controller.contacts;

    //sort by name irrespective of case
    if (isInSearchMode) {
      contactsListToShow.sort(
          ((a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase())));
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isInSearchMode ? 'Search Results' : 'Contacts',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        color: ColorConstants.tertiaryGrey,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Expanded(
            child: contactsListToShow.isNotEmpty
                ? ContactsList(
                    contacts: contactsListToShow,
                    onClientSelected: onClientSelected)
                : EmptyScreen(
                    imagePath: AllImages().clientEmptyIcon,
                    imageSize: 92,
                    message: 'No Contacts Found'),
          ),
        ],
      ),
    );
  }
}
