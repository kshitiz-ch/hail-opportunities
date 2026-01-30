import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/screens/store/fixed_deposit_list/widgets/product_video_section.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/dashboard/models/advisor_video_model.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../config/constants/color_constants.dart';
import '../../../config/constants/image_constants.dart';

@RoutePage()
class AboutWealthcasesScreen extends StatefulWidget {
  @override
  State<AboutWealthcasesScreen> createState() => _AboutWealthcasesScreenState();
}

class _AboutWealthcasesScreenState extends State<AboutWealthcasesScreen> {
  late YoutubePlayerController youtubePlayerController;

  @override
  void initState() {
    youtubePlayerController = YoutubePlayerController(
      params: const YoutubePlayerParams(
        origin: 'https://www.youtube-nocookie.com',
        // use 'https://www.youtube-nocookie.com'
        // temp fix https://github.com/sarbagyastha/youtube_player_flutter/issues/1112
        showControls: true,
        showFullscreenButton: true,
        loop: false,
        strictRelatedVideos: true,
        showVideoAnnotations: false,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    if (youtubePlayerController != null) {
      youtubePlayerController.close();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bodyStyle = context.headlineSmall?.copyWith(
      fontWeight: FontWeight.w500,
      color: ColorConstants.tertiaryBlack,
    );
    return YoutubePlayerScaffold(
      controller: youtubePlayerController,
      builder: (context, player) {
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            titleText: 'About Wealthcase',
            showBackButton: false,
            trailingWidgets: [
              InkWell(
                onTap: () => AutoRouter.of(context).popForced(),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.close,
                    size: 24,
                    color: ColorConstants.black,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductVideoSection(
                youtubePlayerController: youtubePlayerController,
                allowHorizontalPadding: false,
                advisorVideo: AdvisorVideoModel.fromJson(
                  {
                    "link": "https://www.youtube.com/watch?v=G9s455ZHf3M",
                  },
                ),
                player: player,
                productType: ProductVideosType.WEALTHCASE,
              ),
              SizedBox(height: 32),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      wealthcaseInfoSection(
                        context: context,
                        title:
                            "Wealthcase: Expert-Built Basket for Every Client",
                        description: TextSpan(
                          style: bodyStyle,
                          children: [
                            TextSpan(
                                text:
                                    "Investing doesn't have to mean endless stock-picking or chasing tips. With Wealthcase, your clients "),
                            TextSpan(
                              text:
                                  "get access to ready-made basket of stocks built by experts",
                              style: bodyStyle?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstants.black),
                            ),
                            TextSpan(
                                text:
                                    ", designed to make investing easier, smarter, and more aligned with their goals."),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: wealthcaseInfoSection(
                          context: context,
                          title: "What is a Wealthcase?",
                          description: TextSpan(
                            style: bodyStyle,
                            children: [
                              TextSpan(text: "A Wealthcase is "),
                              TextSpan(
                                text: "a curated basket of stocks",
                                style: bodyStyle?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: ColorConstants.black),
                              ),
                              TextSpan(text: ", bundled together "),
                              TextSpan(
                                text: "around powerful themes and ideas",
                                style: bodyStyle?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: ColorConstants.black),
                              ),
                              TextSpan(
                                  text:
                                      " driving the markets. From manufacturing to defence to technology—each basket is "),
                              TextSpan(
                                text:
                                    "designed by SEBI-registered professionals",
                                style: bodyStyle?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: ColorConstants.black),
                              ),
                              TextSpan(
                                  text:
                                      " to help your clients invest in opportunities that matter.\n\n"),
                              TextSpan(
                                  text:
                                      "Instead of buying one stock at a time, your clients can invest in an entire idea with just a few taps."),
                            ],
                          ),
                        ),
                      ),
                      wealthcaseInfoSection(
                        title: "Why Offer Wealthcase?",
                        context: context,
                        description: TextSpan(
                          children: [
                            WidgetSpan(
                              child: SizedBox(width: 4),
                            ),
                            TextSpan(
                              text: "• ",
                              style: bodyStyle,
                            ),
                            TextSpan(
                              text: "Built by Experts: ",
                              style: bodyStyle?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstants.black),
                            ),
                            TextSpan(
                              text:
                                  "Every basket is researched and structured by market professionals\n",
                              style: bodyStyle,
                            ),
                            WidgetSpan(
                              child: SizedBox(width: 4),
                            ),
                            TextSpan(
                              text: "• ",
                              style: bodyStyle,
                            ),
                            TextSpan(
                              text: "One-Tap Diversification: ",
                              style: bodyStyle?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstants.black),
                            ),
                            TextSpan(
                              text:
                                  "Clients can spread their investment across multiple stocks in a theme instantly\n",
                              style: bodyStyle,
                            ),
                            WidgetSpan(
                              child: SizedBox(width: 4),
                            ),
                            TextSpan(
                              text: "• ",
                              style: bodyStyle,
                            ),
                            TextSpan(
                              text: "Thematic Investing: ",
                              style: bodyStyle?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstants.black),
                            ),
                            TextSpan(
                              text:
                                  "Offer baskets that reflect your clients' beliefs in sectors shaping the future\n",
                              style: bodyStyle,
                            ),
                            WidgetSpan(
                              child: SizedBox(width: 4),
                            ),
                            TextSpan(
                              text: "• ",
                              style: bodyStyle,
                            ),
                            TextSpan(
                              text: "Hassle-Free Management: ",
                              style: bodyStyle?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstants.black),
                            ),
                            TextSpan(
                              text:
                                  "Clients stay in sync with the basket manager's updates and rebalance calls automatically",
                              style: bodyStyle,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: wealthcaseInfoSection(
                          title: "Understanding Subscription",
                          context: context,
                          description: TextSpan(
                            style: bodyStyle,
                            children: [
                              TextSpan(
                                text:
                                    "When your clients subscribe to a Wealthcase, they get full access to its detailed stock list and ongoing research updates.\n\n",
                              ),
                              TextSpan(
                                text: 'Subscriptions are ',
                              ),
                              TextSpan(
                                text: 'paid upfront',
                                style: bodyStyle?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: ColorConstants.black),
                              ),
                              TextSpan(
                                text: ' and charged as a ',
                              ),
                              TextSpan(
                                text: 'percentage of the amount invested (AUM)',
                                style: bodyStyle?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: ColorConstants.black),
                              ),
                              TextSpan(
                                text:
                                    '. The fee displayed on each Wealthcase is ',
                              ),
                              TextSpan(
                                text:
                                    'calculated based on its minimum investment amount',
                                style: bodyStyle?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: ColorConstants.black),
                              ),
                              TextSpan(
                                text:
                                    ' and adjusts proportionally if the client invests more. Applicable taxes (like GST) are added at checkout.\n\n',
                              ),
                              TextSpan(
                                text:
                                    'To complete the subscription, clients simply tap ',
                              ),
                              TextSpan(
                                text: '\"Subscribe & Invest\"',
                                style: bodyStyle?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: ColorConstants.black),
                              ),
                              TextSpan(
                                text:
                                    ' and finish the quick flow on the RIA website. Once done, they unlock the basket\'s constituents and can start investing right away.',
                              ),
                            ],
                          ),
                        ),
                      ),
                      wealthcaseInfoSection(
                        title: "How Clients Get Started",
                        context: context,
                        description: TextSpan(
                          style: bodyStyle,
                          children: [
                            TextSpan(
                              text: "1. ",
                            ),
                            TextSpan(
                              text: "Discover: ",
                              style: bodyStyle?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstants.black),
                            ),
                            TextSpan(
                              text:
                                  "Clients can browse through the list of Wealthcases on the Wealthy app. ",
                            ),
                            TextSpan(
                              text: "Explore",
                              style: bodyStyle?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstants.black),
                            ),
                            TextSpan(
                              text:
                                  " any Wealthcase to see what's inside, how it works, and its past performance.\n",
                            ),
                            TextSpan(
                              text: "2. ",
                            ),
                            TextSpan(
                              text: "Invest: ",
                              style: bodyStyle?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstants.black),
                            ),
                            TextSpan(
                              text:
                                  "Clients subscribe and put their money to work in minutes.\n",
                            ),
                            TextSpan(
                              text: "3. ",
                            ),
                            TextSpan(
                              text: "Stay in Sync: ",
                              style: bodyStyle?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstants.black),
                            ),
                            TextSpan(
                              text:
                                  "They get notified of any changes or updates from the Wealthcase manager and can rebalance with just a tap.",
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: wealthcaseInfoSection(
                          title: "Partner with Confidence",
                          context: context,
                          description: TextSpan(
                            style: bodyStyle,
                            children: [
                              TextSpan(
                                text: "A Wealthcase is designed for ",
                              ),
                              TextSpan(
                                text: "every kind of investor",
                                style: bodyStyle?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: ColorConstants.black),
                              ),
                              TextSpan(
                                text:
                                    "—whether your clients are just starting out or already building their portfolios. It takes the complexity out of stock selection and ongoing management, giving you a straightforward solution to offer expert-guided, research-backed investment opportunities.\n\n",
                              ),
                              TextSpan(
                                text:
                                    "Offer a Wealthcase today and help your clients invest in ideas that shape tomorrow.",
                                style: bodyStyle?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: ColorConstants.black),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ActionButton(
                margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                text: 'Got it!',
                onPressed: () => AutoRouter.of(context).popForced(),
              )
            ],
          ),
        );
      },
    );
  }

  Widget wealthcaseInfoSection({
    required String title,
    required InlineSpan description,
    required BuildContext context,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          AllImages().star,
          width: 20,
          height: 20,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.black,
                ),
              ),
              SizedBox(height: 6),
              Text.rich(description),
            ],
          ),
        ),
      ],
    );
  }
}
