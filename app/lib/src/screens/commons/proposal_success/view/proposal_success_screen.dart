import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/navigation_controller.dart';
import 'package:app/src/controllers/demat/demats_controller.dart';
import 'package:app/src/controllers/proposal/proposal_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/utils/fixed_center_docked_fab_location.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/account_details_model.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/client_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

@RoutePage()
class ProposalSuccessScreen extends StatefulWidget {
  // Fields
  final String? proposalUrl;
  final bool shouldPromptDemat;
  final Client? client;
  final String? productName;
  final int? expiryTime;
  final bool isDematAdded;
  final bool isBankAdded;
  final bool isCustom;
  final bool enablePopScope;

  // Constructor
  const ProposalSuccessScreen({
    Key? key,
    this.shouldPromptDemat = false,
    this.proposalUrl,
    required this.client,
    required this.productName,
    this.expiryTime,
    this.isDematAdded = true,
    this.isBankAdded = true,
    this.isCustom = false,
    this.enablePopScope = false,
  }) : super(key: key);

  @override
  _ProposalSuccessScreenState createState() => _ProposalSuccessScreenState();
}

class _ProposalSuccessScreenState extends State<ProposalSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  initState() {
    _lottieController = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    if (widget.isCustom) {
      if (Get.isRegistered<BasketController>()) {
        Get.find<BasketController>().clearPortfolioParams();
      }
    }
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.enablePopScope,
      child: Scaffold(
        backgroundColor: ColorConstants.white,
        body: SingleChildScrollView(
          padding: EdgeInsets.only(left: 30, right: 30, top: 30, bottom: 30),
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.only(bottom: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Container(
                      child: Center(
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
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Proposal Link Shared\nwith Client!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineMedium!
                          .copyWith(fontWeight: FontWeight.w500, height: 1.5),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 32),
                  child: Text(
                    '${widget.client?.name ?? 'Client'} will receive the proposal link via WhatsApp and by sms on their number ${widget.client?.phoneNumber ?? ''}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                            fontSize: 12,
                            color: ColorConstants.tertiaryGrey,
                            height: 1.4),
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
                          'Contact client to speed up\nthe confirmation ?',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 40, right: 40.0, bottom: 24.0, top: 16.0),
                        child: Text(
                          'Let ${widget.client?.name ?? 'Client'} know that you have shared the proposal link',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                  fontSize: 12,
                                  color: ColorConstants.tertiaryGrey,
                                  height: 1.4),
                        ),
                      ),
                      if (widget.client!.phoneNumber.isNotNullOrEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 28)
                              .copyWith(bottom: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () async {
                                  await launch(
                                      'tel:${widget.client?.phoneNumber}');
                                },
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      AllImages().callRoundedIcon,
                                      width: 24,
                                      height: 24,
                                    ),
                                    SizedBox(
                                      width: 6,
                                    ),
                                    Text(
                                      'Call Now',
                                      style: Theme.of(context)
                                          .primaryTextTheme
                                          .headlineSmall!
                                          .copyWith(
                                              fontWeight: FontWeight.w700),
                                    )
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  final link = WhatsAppUnilink(
                                      phoneNumber: widget.client?.phoneNumber,
                                      text:
                                          "Hey ${widget.client?.name ?? 'there'}, here is the created proposal for you ${widget.proposalUrl}.");

                                  await launch('$link');
                                },
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      AllImages().whatsappRoundedIcon,
                                      width: 24,
                                      height: 24,
                                    ),
                                    SizedBox(
                                      width: 6,
                                    ),
                                    Text(
                                      'Whatsapp',
                                      style: Theme.of(context)
                                          .primaryTextTheme
                                          .headlineSmall!
                                          .copyWith(
                                              fontWeight: FontWeight.w700),
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: InkWell(
                          onTap: () {
                            shareText(widget.proposalUrl!);
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
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headlineSmall!
                                    .copyWith(
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
                if (widget.shouldPromptDemat &&
                    (!widget.isDematAdded || !widget.isBankAdded))
                  _buildDematPrompt()
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FixedCenterDockedFabLocation(),
        floatingActionButton: Container(
          // shaderCallback: (Rect rect) {
          //   return LinearGradient(
          //     begin: Alignment.topCenter,
          //     end: Alignment.bottomCenter,
          //     colors: [
          //       Colors.white,
          //       Colors.transparent,
          //       Colors.transparent,
          //       Colors.white,
          //     ],
          //     stops: [
          //       0.0,
          //       0.1,
          //       0.9,
          //       1.0
          //     ], // 10% white, 80% transparent, 10% white
          //   ).createShader(rect);
          // },
          // blendMode: BlendMode.dstOut,
          child: Container(
            width: double.infinity,
            color: ColorConstants.white,
            padding: EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClickableText(
                  onClick: () {
                    AutoRouter.of(context)
                        .popUntil(ModalRoute.withName(BaseRoute.name));
                    Get.find<NavigationController>()
                        .setCurrentScreen(Screens.PROPOSALS);
                    if (Get.isRegistered<ProposalsController>()) {
                      ProposalsController proposalController =
                          Get.find<ProposalsController>();
                      proposalController.tabController!.index = 0;
                      proposalController.employeeAgentExternalId = null;
                      proposalController.client = null;
                      proposalController.partnerType = PartnerType.Self;
                      if (proposalController.selectedTabStatus == 'ALL') {
                        proposalController.resetPagination();
                        proposalController.getProposals();
                      } else {
                        proposalController.updateTabStatus("ALL");
                      }
                    }
                  },
                  text: 'Back To Proposals',
                  fontSize: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDematPrompt() {
    String getPromptText() {
      if (widget.isDematAdded && widget.isBankAdded) {
        return 'You have added a demat and bank account, you now have a higher chance of getting your proposal accepted ';
      } else if (widget.isBankAdded) {
        return 'Adding Demat details of the client creates higher chances of proposal acceptance';
      } else if (widget.isDematAdded) {
        return 'Adding Bank details of the client creates higher chances of proposal acceptance';
      } else {
        return 'Adding Demat & Bank details of the client creates higher chances of proposal acceptance';
      }
    }

    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: ColorConstants.secondaryCardColor,
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(
            "ADD${!widget.isDematAdded ? ' DEMAT' : ''}${!widget.isDematAdded && !widget.isBankAdded ? ' AND' : ''}${!widget.isBankAdded ? ' BANK' : ''} DETAILS",
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(fontWeight: FontWeight.w700),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 24),
            child: Text(
              getPromptText(),
              textAlign: TextAlign.center,
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  fontSize: 12,
                  color: ColorConstants.tertiaryGrey,
                  height: 1.4),
            ),
          ),
          ActionButton(
            margin: EdgeInsets.zero,
            text: 'Add Details',
            onPressed: () {
              if (!widget.isDematAdded) {
                AutoRouter.of(context).push(DematsRoute(
                  client: widget.client,
                  onProceed: () {
                    _handleNavigationToProposalScreen(context);
                  },
                ));
              } else if (!widget.isBankAdded) {
                ClientAccountModel accountDetails = ClientAccountModel();

                if (Get.isRegistered<DematsController>()) {
                  accountDetails.bankAccounts =
                      Get.find<DematsController>().userBankAccounts;
                }

                AutoRouter.of(context).push(
                  ClientBankFormRoute(
                    client: widget.client,
                    onBankAdded: (BankAccountModel? bank) async {
                      if (bank != null &&
                          Get.isRegistered<DematsController>()) {
                        Get.find<DematsController>()
                            .userBankAccounts
                            .insert(0, bank);
                      }

                      AutoRouter.of(context).popForced();

                      _handleNavigationToProposalScreen(context);
                    },
                  ),
                );

                // AutoRouter.of(context).push(
                //   BankDetailsFormRoute(
                //     client: widget.client,
                //     accountDetails: accountDetails,
                //     onProceed: () {
                //       _handleNavigationToProposalScreen(context);
                //     },
                //   ),
                // );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpireText(BuildContext context) {
    String expiryTimeSuffix = 'hours';
    double expiryTimeFormatted = widget.expiryTime!.toDouble();

    if (widget.expiryTime! >= 24) {
      expiryTimeFormatted = (widget.expiryTime! / 24);

      if (widget.expiryTime == 24) {
        expiryTimeSuffix = 'day';
      } else {
        expiryTimeSuffix = 'days';
      }
    }

    return RichText(
      text: TextSpan(
        style: Theme.of(context).primaryTextTheme.titleMedium!.copyWith(
              color: ColorConstants.darkGrey,
              letterSpacing: 0.14,
            ),
        children: <TextSpan>[
          TextSpan(
            text: "All proposals sent to client will expire in ",
          ),
          TextSpan(
            text: "${expiryTimeFormatted.toStringAsFixed(0)} $expiryTimeSuffix",
            style: Theme.of(context).primaryTextTheme.titleMedium!.copyWith(
                  color: ColorConstants.darkGrey,
                  letterSpacing: 0.14,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyProposalUrl(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.secondaryAppColor,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.only(left: 8, right: 8),
      margin: EdgeInsets.only(left: 16, right: 16, top: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              // color: Colors.red,
              child: Text(
                widget.proposalUrl!,
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(color: ColorConstants.tertiaryBlack),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              // backgroundColor:
              //     ColorConstants.primaryAppColor,
              padding: const EdgeInsets.all(0.0),
              fixedSize: Size.fromHeight(24.0),
            ),
            onPressed: () {
              copyData(data: widget.proposalUrl);
            },
            child: Text(
              'COPY',
            ),
          )
        ],
      ),
    );
  }

  String _buildInfoText(bool isDematAdded, bool isBankAdded) {
    if (widget.isDematAdded && isBankAdded) {
      return 'You have added a demat and bank account, you now have a higher chance of getting your proposal accepted ';
    } else if (isBankAdded) {
      return 'Adding Demat details of the client creates higher chances of proposal acceptance';
    } else if (widget.isDematAdded) {
      return 'Adding Bank details of the client creates higher chances of proposal acceptance';
    } else {
      return 'Adding Demat & Bank details of the client creates higher chances of proposal acceptance';
    }
  }

  void _handleNavigationToProposalScreen(BuildContext context) {
    AutoRouter.of(context).popUntil(ModalRoute.withName(BaseRoute.name));
    final NavigationController navController = Get.find<NavigationController>();
    navController.setCurrentScreen(Screens.PROPOSALS);
  }
}
