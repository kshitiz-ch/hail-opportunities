import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/advisor/newsletter_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/advisor/models/newsletter_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';

@RoutePage()
class NewsLetterDetailScreen extends StatelessWidget {
  final String? newsLetterId;

  NewsLetterDetailScreen({
    Key? key,
    @pathParam this.newsLetterId,
  }) : super(key: key) {
    if (!Get.isRegistered<NewsLetterController>()) {
      Get.put<NewsLetterController>(NewsLetterController());
    }
    final controller = Get.find<NewsLetterController>();
    controller.articleScrollPercent = 0;
    controller.getNewsletterDetail(newsLetterId ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).viewPadding.top,
              bottom: 10,
            ),
            child: _buildArticleLoader(),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, bottom: 20),
            child: _buildBackButton(context),
          ),
          Expanded(
            child: GetBuilder<NewsLetterController>(
              initState: (_) {},
              builder: (controller) {
                if (controller.newsLetterDetailReponse.state ==
                    NetworkState.loading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (controller.newsLetterDetailReponse.state ==
                    NetworkState.error) {
                  return Center(
                    child: RetryWidget(
                      controller.newsLetterDetailReponse.message,
                      onPressed: () {
                        controller.getNewsletterDetail(newsLetterId ?? '');
                      },
                    ),
                  );
                }
                if (controller.newsLetterDetailReponse.state ==
                    NetworkState.loaded) {
                  if (controller.selectedNewsLetter == null ||
                      controller
                          .selectedNewsLetter!.htmlContent.isNullOrEmpty) {
                    return Center(
                        child: EmptyScreen(message: 'No article found'));
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildNewsDetailUI(controller, context),
                  );
                }
                return SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsDetailUI(
      NewsLetterController controller, BuildContext context) {
    final selectedNewsLetter = controller.selectedNewsLetter!;
    final style = Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w400,
          color: ColorConstants.tertiaryBlack,
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          selectedNewsLetter.title ?? '',
          style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: ColorConstants.black,
              ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 24),
          child: Row(
            children: [
              Text(
                getFormattedDate(selectedNewsLetter.publishedAt),
                style: style,
              ),
              Center(
                child: Container(
                  height: 2,
                  width: 2,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorConstants.tertiaryBlack),
                  margin: EdgeInsets.symmetric(horizontal: 3),
                ),
              ),
              Text(
                '${selectedNewsLetter.readTime} Mins Read ',
                style: style,
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            controller: controller.articleScrollControler,
            child: HtmlWidget(
              selectedNewsLetter.parsedHtmlContent ?? '',
              customStylesBuilder: (element) {
                if (element.localName == 'p' || element.localName == 'span') {
                  // fix styling issue in <a><span></a>
                  if (element.parent?.localName == 'a') {
                    return {
                      'color': '#6725F4 !important;',
                      'font-size': '16px !important;',
                    };
                  }
                  return {
                    'color': '#000000 !important;',
                    'font-size': '16px !important;',
                    'font-weight': '500',
                  };
                }
                if (element.localName == 'a') {
                  return {
                    'color': '#6725F4 !important;',
                    'font-size': '16px !important;',
                  };
                }
                if (element.localName == 'blockquote') {
                  return {
                    'border-left': '3px solid #6725F4;',
                    'padding-left': '8px;'
                  };
                }
                return {};
              },
              onTapUrl: (url) {
                LogUtil.printLog('url==>$url');
                if (url.isNotNullOrEmpty) {
                  AutoRouter.of(context).push(WebViewRoute(url: url));
                }
                return true;
              },
            ),
          ),
        ),
        _buildSocialShareUI(selectedNewsLetter, context)
      ],
    );
  }

  Widget _buildSocialShareUI(
    NewsLetterModel selectedNewsLetter,
    BuildContext context,
  ) {
    final socialShareData = getSocialShareData(selectedNewsLetter);
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: socialShareData.entries.map(
          (data) {
            final image = data.value['image'];
            final url = data.value['url'];
            return Padding(
              padding: const EdgeInsets.only(right: 24),
              child: InkWell(
                onTap: () {
                  if (data.key == 'Share') {
                    shareText(url);
                  } else {
                    launch(url);
                  }
                },
                child: Image.asset(
                  image,
                  height: 32,
                  width: 32,
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return InkWell(
      onTap: () {
        AutoRouter.of(context).popForced();
      },
      child: Image.asset(
        AllImages().appBackIcon,
        height: 32,
        width: 32,
      ),
    );
  }

  Widget _buildArticleLoader() {
    return GetBuilder<NewsLetterController>(
      id: 'article-read',
      builder: (controller) {
        return LayoutBuilder(
          builder: (context, constraint) {
            return Container(
              color: ColorConstants.primaryAppColor,
              height: 3,
              width: controller.articleScrollPercent * constraint.maxWidth,
            );
          },
        );
      },
    );
  }

  Map<String, dynamic> getSocialShareData(NewsLetterModel selectedNewsLetter) {
    final shareUrl = getNewsLetterShareUrl(selectedNewsLetter);
    return {
      'Share': {
        'url': shareUrl,
        'image': AllImages().newsletterShareIcon,
      },
      'Whatsapp': {
        'url':
            'https://api.whatsapp.com/send?text=$shareUrl?utm_source=WhatsApp&utm_medium=Share&%20%20utm_campaign=New%20Blog%20Post',
        'image': AllImages().whatsappIcon,
      },
      'X': {
        'url':
            'https://x.com/intent/tweet?url=$shareUrl?utm_source=Twitter&utm_medium=Share&%20%20utm_campaign=New%20Blog%20Post&via=wealthy_india',
        'image': AllImages().xIcon,
      },
      'Fb': {
        'url':
            'https://www.facebook.com/sharer/sharer.php?u=$shareUrl?utm_source=Facebook&utm_medium=Share&%20%20utm_campaign=New%20Blog%20Post',
        'image': AllImages().fbIcon,
      },
      'Linkedin': {
        'url':
            'https://www.linkedin.com/sharing/share-offsite/?url=$shareUrl?utm_source=LinkedIn&utm_medium=Share&%20%20utm_campaign=New%20Blog%20Post',
        'image': AllImages().linkedinIcon,
      },
    };
  }
}
