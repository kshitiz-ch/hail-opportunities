import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/tracker/tracker_list_controller.dart';
import 'package:app/src/screens/tracker/widgets/send_tracker_bottom_bar.dart';
import 'package:app/src/screens/tracker/widgets/support_widgets.dart';
import 'package:app/src/screens/tracker/widgets/tracker_search_bar.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class SendTrackerRequestScreen extends StatefulWidget {
  @override
  _SendTrackerRequestScreenState createState() =>
      _SendTrackerRequestScreenState();
}

class _SendTrackerRequestScreenState extends State<SendTrackerRequestScreen> {
  bool? isInSearchMode;
  FocusNode? searchInputFocusNode;

  TrackerListController? trackerController;

  @override
  void initState() {
    super.initState();
    trackerController = Get.find<TrackerListController>();
    trackerController!.getClients();
    isInSearchMode = false;
    searchInputFocusNode = FocusNode();
  }

  void onQueryChange(String query) {
    setState(() {
      isInSearchMode = query.isNotEmpty;
    });
  }

  void goBackHandler() async {
    trackerController?.resetSearch();
    trackerController?.resetSelectedClients();
    AutoRouter.of(context).popForced();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, __) {
        onPopInvoked(didPop, () {
          goBackHandler();
        });
      },
      child: Scaffold(
        backgroundColor: ColorConstants.white,
        // AppBar
        appBar: CustomAppBar(
          showBackButton: true,
          titleText: 'Send Request',
          onBackPress: () {
            goBackHandler();
          },
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: GetBuilder<TrackerListController>(
                builder: (controller) {
                  return TrackerSearchBar(
                    onClear: () {
                      controller.searchController!.clear();
                      onQueryChange('');
                    },
                    onChanged: (query) {
                      bool isQueryChanged = query != controller.searchQuery;

                      if (isQueryChanged) {
                        controller.onClientSearch(query);
                        setState(() {
                          isInSearchMode = query.isNotEmpty;
                        });
                      }
                      // onQueryChange(value);
                      // controller.searchClient(value);
                    },
                    onSubmitted: (value) {
                      if (value.isEmpty) {
                        controller.searchController!.clear();
                        onQueryChange('');
                      }
                    },
                  );
                },
              ),
            ),

            Expanded(
              child: isInSearchMode!
                  ? GetBuilder<TrackerListController>(
                      id: GetxId.searchClient,
                      builder: (controller) {
                        if (controller.searchClientResponse.state ==
                            NetworkState.loading) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (controller.searchClientResponse.state ==
                            NetworkState.error) {
                          return Center(
                            child:
                                Text(controller.searchClientResponse.message),
                          );
                        } else if (controller.searchClientResponse.state ==
                            NetworkState.loaded) {
                          return ClientList(
                            isInSearchMode: isInSearchMode,
                            searchInputFocusNode: searchInputFocusNode,
                          );
                        } else {
                          return SizedBox();
                        }
                      },
                    )
                  : GetBuilder<TrackerListController>(
                      id: GetxId.getClients,
                      builder: (controller) {
                        if (controller.getClientResponse.state ==
                            NetworkState.loading) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (controller.getClientResponse.state ==
                            NetworkState.error) {
                          return Center(
                            child: Text(controller.getClientResponse.message),
                          );
                        } else if (controller.getClientResponse.state ==
                            NetworkState.loaded) {
                          return ClientList(
                            isInSearchMode: isInSearchMode,
                            searchInputFocusNode: searchInputFocusNode,
                          );
                        } else {
                          return SizedBox();
                        }
                      },
                    ),
            ),
          ],
        ),
        bottomNavigationBar:
            SendTrackerBottomBar(searchInputFocusNode: searchInputFocusNode),
      ),
    );
  }
}
