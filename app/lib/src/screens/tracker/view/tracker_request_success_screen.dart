import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/navigation_controller.dart';
import 'package:app/src/controllers/tracker/tracker_list_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/screens/tracker/widgets/sent_tracker_client_card.dart';
import 'package:app/src/utils/fixed_center_docked_fab_location.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

@RoutePage()
class TrackerRequestSuccessScreen extends StatefulWidget {
  final List<Client> clients;
  final Map<String, String> trackerLinkMap;

  TrackerRequestSuccessScreen({
    Key? key,
    this.clients = const [],
    this.trackerLinkMap = const {},
  }) : super(key: key);

  @override
  _TrackerRequestSuccessScreenState createState() =>
      _TrackerRequestSuccessScreenState();
}

class _TrackerRequestSuccessScreenState
    extends State<TrackerRequestSuccessScreen> with TickerProviderStateMixin {
  late AnimationController _lottieController;

  (String, String)? parentRouteDetail;

  @override
  void initState() {
    parentRouteDetail = getParentRouteDetails(context);
    _lottieController = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: ColorConstants.white,
        appBar: CustomAppBar(
          showBackButton: false,
          trailingWidgets: [
            IconButton(
              onPressed: () {
                onPress();
              },
              icon: Icon(
                Icons.close,
                size: 20,
                color: ColorConstants.black,
              ),
            )
          ],
        ),
        body: Container(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    child: Lottie.asset(
                      AllImages().verifiedIconLottie,
                      controller: _lottieController,
                      onLoaded: (composition) {
                        _lottieController
                          ..duration = composition.duration
                          ..forward();
                      },
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Expanded(child: _buildTrackerRequestsUI()),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FixedCenterDockedFabLocation(),
        floatingActionButton: ActionButton(
          margin: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          text: 'Back to ${parentRouteDetail?.$2 ?? 'Tracker'}',
          onPressed: () {
            onPress();
          },
        ),
      ),
    );
  }

  Widget _buildTrackerRequestsUI() {
    // If there are no clients, show an empty screen
    if (widget.clients.isNullOrEmpty) {
      return Center(
        child: EmptyScreen(
          message: 'You have not shared any tracker requests yet.',
        ),
      );
    }
    // If there are multiple clients, show a list of SentTrackerClientCard
    if (widget.clients.length > 1) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Tracker request successfully shared with ${widget.trackerLinkMap.length} client(s)!',
              textAlign: TextAlign.center,
              style: context.headlineMedium!.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40)
                  .copyWith(bottom: 100),
              child: SingleChildScrollView(
                child: Column(
                  children: List<Widget>.generate(
                    widget.clients.length,
                    (index) => SentTrackerClientCard(
                      client: widget.clients[index],
                      index: index,
                      trackerLink:
                          widget.trackerLinkMap[widget.clients[index].taxyID] ??
                              '',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    // If there's only one client, show a different UI
    final client = widget.clients.first;
    final trackersyncLink = widget.trackerLinkMap[client.taxyID] ?? '';
    final message =
        "Hey ${client.name ?? 'there'}, here is the tracker sync request link for you ${trackersyncLink}.";

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Tracker Request Link Shared with Client!',
              textAlign: TextAlign.center,
              style: context.headlineMedium!.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 32),
            child: Text(
              "${client.name} will receive the tracker sync request link via WhatsApp/Email. You can also copy the link below and share it directly in case the client hasn't received it.",
              textAlign: TextAlign.center,
              style: context.headlineSmall!.copyWith(
                fontSize: 12,
                color: ColorConstants.tertiaryGrey,
                height: 1.4,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: ColorConstants.primaryCardColor,
                borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    'Contact client to speed up\nthe tracker sync ?',
                    textAlign: TextAlign.center,
                    style: context.headlineSmall!
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 40, right: 40.0, bottom: 24.0, top: 16.0),
                  child: Text(
                    'Let ${client.name} know that you have shared the tracker sync request link',
                    textAlign: TextAlign.center,
                    style: context.headlineSmall!.copyWith(
                        fontSize: 12,
                        color: ColorConstants.tertiaryGrey,
                        height: 1.4),
                  ),
                ),
                if (client.phoneNumber.isNotNullOrEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28)
                        .copyWith(bottom: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () async {
                            await launch('tel:${client.phoneNumber}');
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                AllImages().callRoundedIcon,
                                width: 24,
                                height: 24,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Call Now',
                                style: context.headlineSmall!
                                    .copyWith(fontWeight: FontWeight.w700),
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            final link = WhatsAppUnilink(
                              phoneNumber: client.phoneNumber,
                              text: message,
                            );

                            await launch('$link');
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                AllImages().whatsappRoundedIcon,
                                width: 24,
                                height: 24,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Whatsapp',
                                style: context.headlineSmall!
                                    .copyWith(fontWeight: FontWeight.w700),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                Divider(
                  color: ColorConstants.lightGrey,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: InkWell(
                    onTap: () {
                      shareText(message);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.share,
                          color: ColorConstants.primaryAppColor,
                          size: 20,
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Text(
                          'Share link via',
                          style: context.headlineSmall!.copyWith(
                              color: ColorConstants.primaryAppColor,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onPress() {
    if (parentRouteDetail != null) {
      switch (parentRouteDetail!.$1) {
        case ClientTrackerRoute.name:
          return AutoRouter.of(context)
              .popUntil(ModalRoute.withName(ClientTrackerRoute.name));
        case ClientDetailRoute.name:
          return AutoRouter.of(context)
              .popUntil(ModalRoute.withName(ClientDetailRoute.name));
        case PortfolioReviewRoute.name:
          return AutoRouter.of(context)
              .popUntil(ModalRoute.withName(PortfolioReviewRoute.name));
      }
    }

    AutoRouter.of(context).popUntil(ModalRoute.withName(BaseRoute.name));

    Get.find<NavigationController>().setCurrentScreen(Screens.HOME);

    if (Get.isRegistered<TrackerListController>()) {
      Get.delete<TrackerListController>();
    }
    AutoRouter.of(context).push(TrackerListRoute());
  }

  (String, String)? getParentRouteDetails(BuildContext context) {
    final navigationStack = AutoRouter.of(context).stack;
    final parentRouteName = navigationStack.length > 1
        ? navigationStack[navigationStack.length - 2].name
        : '';
    switch (parentRouteName) {
      case ClientTrackerRoute.name:
        return (ClientTrackerRoute.name, 'Tracker');
      case ClientDetailRoute.name:
        return (ClientDetailRoute.name, 'Client Detail');
      case PortfolioReviewRoute.name:
        return (PortfolioReviewRoute.name, 'Portfolio Review');

      default:
        return null;
    }
  }
}
