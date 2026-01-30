import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/advisor/newsletter_controller.dart';
import 'package:app/src/screens/advisor/newsletter/widgets/newsletter_common_ui.dart';
import 'package:app/src/screens/advisor/newsletter/widgets/newsletter_tabs.dart';
import 'package:app/src/screens/advisor/newsletter/widgets/newsletter_year_dropdown.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/line_dash.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class NewsLetterScreen extends StatelessWidget {
  late int initialTabIndex;
  String? contentType;

  NewsLetterScreen({
    Key? key,
    @QueryParam('content_type') this.contentType,
  }) : super(key: key) {
    if (contentType == 'bulls-eye') {
      initialTabIndex = 1;
    } else {
      initialTabIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewsLetterController>(
      init: NewsLetterController(initialTabIndex: initialTabIndex),
      builder: (controller) {
        final tabIndex = controller.tabController?.index ?? initialTabIndex;
        final tabInfo = newsLetterTabs[tabIndex];
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            titleText: 'Newsletters',
            trailingWidgets: [
              Container(
                width: 120,
                alignment: Alignment.centerRight,
                child: NewsletterYearDropdown(),
              ),
            ],
          ),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NewsLetterTabs(initialIndex: initialTabIndex),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: NewsLetterCommonUI.buildTabCard(
                  image: tabInfo['image']!,
                  title: tabInfo['title']!,
                  subtitle: tabInfo['description']!,
                  context: context,
                  // TODO: undo comment when subscribe api is available
                  // onSubscribe: tabIndex == 0
                  //     ? () {
                  //         CommonUI.showBottomSheet(
                  //           context,
                  //           child: KeyboardVisibilityBuilder(
                  //             builder: (_, isKeyboardVisible) {
                  //               return Padding(
                  //                 padding: EdgeInsets.only(
                  //                     bottom: isKeyboardVisible ? 250 : 0),
                  //                 child: SubscribeNewsLetterBottomSheet(),
                  //               );
                  //             },
                  //           ),
                  //         );
                  //       }
                  //     : null,
                ),
              ),
              Expanded(
                child: _buildNewsletterListing(controller),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNewsletterListing(NewsLetterController controller) {
    if (controller.newsLetterReponse.state == NetworkState.loading &&
        !controller.isPaginating) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    if (controller.newsLetterReponse.state == NetworkState.error) {
      return Center(
        child: RetryWidget(
          controller.newsLetterReponse.message,
          onPressed: () {
            controller.getNewsletters();
          },
        ),
      );
    }
    if (controller.newsLetterReponse.state == NetworkState.loaded &&
        controller.newsLetterList.isNullOrEmpty) {
      return Center(
        child: EmptyScreen(
            message: controller.tabController?.index == 0
                ? 'No newsletter found'
                : 'Coming Soon'),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.separated(
            controller: controller.scrollController,
            shrinkWrap: true,
            itemCount: controller.newsLetterList.length,
            padding: EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 10),
            separatorBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: LineDash(color: Color(0xffC4C4C4)),
              );
            },
            itemBuilder: (context, index) {
              final newsLetterModel = controller.newsLetterList[index];
              return InkWell(
                onTap: () {
                  AutoRouter.of(context).push(
                    NewsLetterDetailRoute(
                      newsLetterId: newsLetterModel.id.toString(),
                    ),
                  );
                },
                child: NewsLetterCommonUI.buildNewsLetterCard(
                  newsLetterModel: newsLetterModel,
                  context: context,
                ),
              );
            },
          ),
        ),
        if (controller.isPaginating) CommonUI.buildInfiniteLoader(),
      ],
    );
  }
}
