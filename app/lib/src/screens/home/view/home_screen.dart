import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/controllers/store/store_search_controller.dart';
import 'package:app/src/screens/home/widgets/home_body.dart';
import 'package:app/src/screens/home/widgets/home_error_section.dart';
import 'package:app/src/screens/home/widgets/home_header.dart';
import 'package:app/src/screens/home/widgets/home_screen_loader.dart';
import 'package:core/modules/authentication/bloc/authentication/authentication_event.dart';
import 'package:core/modules/authentication/bloc/bloc_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const homeSearchControllerTag = 'home_product_search';

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.isRegistered<HomeController>()
      ? Get.find<HomeController>()
      : Get.put(HomeController(), permanent: true);

  final StoreSearchController storeSearchController =
      Get.put<StoreSearchController>(StoreSearchController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      body: GetBuilder<HomeController>(
        builder: (controller) {
          if (controller.advisorOverviewState == NetworkState.loading) {
            return HomeScreenLoader();
          }

          if (controller.advisorOverviewState == NetworkState.loaded) {
            return GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Section
                  HomeHeader(
                    tag: homeSearchControllerTag,
                  ),
                  Expanded(
                    child: HomeBody(),
                  )
                  // Expanded(
                  //   child: GetBuilder<UniversalSearchController>(
                  //     tag: homeSearchControllerTag,
                  //     id: 'search',
                  //     builder: (universalSearchController) {
                  //       if (universalSearchController.searchText.isNotEmpty &&
                  //           universalSearchController.searchResponse.state ==
                  //               NetworkState.loading) {
                  //         return SearchLoader();
                  //       }

                  //       if (universalSearchController.searchText.isNotEmpty &&
                  //           universalSearchController.searchResponse.state ==
                  //               NetworkState.loaded) {
                  //         return UniversalSearchResult(
                  //             tag: homeSearchControllerTag);
                  //         // return Container(
                  //         //   child: Text(
                  //         //       'The Query is ${universalSearchController.searchText}'),
                  //         // );
                  //         // return ProductSearchResultsSection(
                  //         //   tag: homeSearchControllerTag,
                  //         // );
                  //       }
                  //       return HomeBody();
                  //     },
                  //   ),
                  // )
                ],
              ),
            );
          }

          return _buildErrorState(context, controller);
        },
      ),
    );
  }

  Widget _buildErrorState(context, HomeController controller) {
    return HomeErrorSection(
      onRefresh: () {
        controller.refreshDashboard();
      },
      onLogout: () {
        AuthenticationBlocController()
            .authenticationBloc
            .add(UserLogOut(showLogoutMessage: false));
      },
      onSupport: () {
        openFreshChatSupport();
      },
    );
  }
}
