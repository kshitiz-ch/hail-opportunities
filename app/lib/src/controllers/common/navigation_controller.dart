import 'dart:convert';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/ntypes.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/app_resources/app_resources_controller.dart';
import 'package:app/src/controllers/showcase/showcase_controller.dart';
import 'package:app/src/utils/push_notifications.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/main.dart';
import 'package:core/modules/app_resources/models/creatives_model.dart';
import 'package:core/modules/dashboard/models/advisor_overview_model.dart';
import 'package:core/modules/dashboard/models/advisor_video_model.dart';
import 'package:core/modules/dashboard/models/notification_context_model.dart';
import 'package:core/modules/store/models/mf/screener_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension ScreenEx on Screens {
  String get title {
    switch (this) {
      case Screens.PROPOSALS:
        return 'Proposals';
      case Screens.STORE:
        return 'Store';
      case Screens.CLIENTS:
        return 'Clients';
      case Screens.RESOURCES:
        return 'Resources';
      case Screens.HOME:
      default:
        return 'Home';
    }
  }

  String get icon {
    switch (this) {
      case Screens.PROPOSALS:
        return AllImages().proposalsInactive;
      case Screens.CLIENTS:
        return AllImages().clientsInactive;
      case Screens.STORE:
        return AllImages().storeInactive;
      case Screens.HOME:
        return AllImages().homeInactive;
      case Screens.RESOURCES:
        return AllImages().resourcesBottomNav;
      default:
        return AllImages().homeInactive;
    }
  }

  String get activeIcon {
    switch (this) {
      case Screens.PROPOSALS:
        return AllImages().proposalsActive;
      case Screens.CLIENTS:
        return AllImages().clientsActive;
      case Screens.STORE:
        return AllImages().storeActive;
      case Screens.HOME:
        return AllImages().homeActive;
      case Screens.RESOURCES:
        return AllImages().resourcesBottomNav;
      default:
        return AllImages().homeActive;
    }
  }
}

class NavigationController extends GetxController {
  final Rx<Screens> _currentScreen = Rx<Screens>(Screens.HOME);
  late RemoteMessage pushNotificationData;
  bool fromPushNotificationHandler = false;
  dynamic successData;
  String? fromScreen;
  bool showSalesPlanOnMoreScreen = true;
  bool showAppUpdateDialog = false;

  Screens get currentScreen => _currentScreen.value;
  int get currentScreenIndex => _currentScreen.value.index;

  @override
  void onReady() async {
    final SharedPreferences sharedPreferences = await prefs;
    bool isSalesPlanScreenViewed = sharedPreferences
            .getBool(SharedPreferencesKeys.isSalesPlanScreenViewed) ??
        false;

    if (!isSalesPlanScreenViewed) {
      showSalesPlanOnMoreScreen = isSalesPlanScreenViewed;
      update(['more-screen']);
    }
  }

  void enableShowSalesPlanOnMoreScreen() {
    showSalesPlanOnMoreScreen = true;
    update(['more-screen']);
  }

  bool isActive(Screens screen) => _currentScreen.value == screen;

  void setCurrentScreen(Screens screen, {String fromScreen = ''}) {
    _currentScreen.value = screen;
    this.fromScreen = fromScreen;
  }

  void setCurrentScreenByIndex(int index) {
    _currentScreen.value = Screens.values[index];

    // For Segment Events
    fromScreen = 'Home';
  }

  void setfromPushNotificationHandler(bool status, dynamic data) {
    this.fromPushNotificationHandler = status;
    this.successData = data;
    // notifyListeners();
  }

  void savePushNotificationData(RemoteMessage data) {
    this.pushNotificationData = data;
  }

  PageRouteInfo? pushNotificationHandler(
    RemoteMessage message, {
    viaLaunch = false,
    AdvisorOverviewModel? advisorOverview,
    BuildContext? context,
    bool isDataNotification = false,
  }) {
    NotificationContextModel? getNotificationContextModel() {
      NotificationContextModel? wcontext;
      if (message.data['wcontext'] != null) {
        try {
          dynamic wcontextJson;
          if (isDataNotification) {
            // from notification screen data is already in json so decoding not required
            wcontextJson = message.data['wcontext'];
          } else {
            if (message.data['wcontext'] is String) {
              wcontextJson = json.decode(message.data['wcontext']);
            } else {
              wcontextJson = message.data['wcontext'];
            }
          }
          wcontext = NotificationContextModel.fromJson(wcontextJson);
        } catch (error) {
          wcontext = NotificationContextModel.fromJson({});
        }
      }

      return wcontext;
    }

    // if (viaLaunch) {
    // PushNotificationsManager()
    //     .trackNotificationCall(message.data['tracking_url']);
    // }
    if (message.data['tracking_url'] != null) {
      PushNotificationsManager()
          .trackNotificationCall(message.data['tracking_url']);
    }

    // Check if a showcase currently visible
    // If so, call setActiveShowCase to hide the showcase
    if (Get.isRegistered<ShowCaseController>()) {
      ShowCaseController showCaseController = Get.find<ShowCaseController>();
      if (showCaseController.isShowCaseVisibleCurrently) {
        showCaseController.setActiveShowCase();
      }
    }

    switch (message.data['ntype'].toString().toLowerCase()) {
      case Ntype.defaultNtype:
        // TODO: Remove after Aug 27 update
        setCurrentScreen(Screens.HOME);

        break;
      case Ntype.initiateKyc:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);
          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          // return CompleteKycRoute(
          //   fromScreen: 'push-notification',
          // );
          return ProfileUpdateRoute();
        }

        break;

      case Ntype.learning:
        NotificationContextModel? wcontext = getNotificationContextModel();
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          // Temporary model
          if (wcontext!.videoUrl.isNullOrEmpty &&
              wcontext.playlistId.isNullOrEmpty) {
            return WealthAcademyRoute();
          }

          AdvisorVideoModel? videoModel;
          if (wcontext.videoUrl.isNotNullOrEmpty) {
            videoModel = AdvisorVideoModel.fromJson(
                {"id": 1, "link": wcontext.videoUrl});
          }

          return PlaylistPlayerRoute(
            initialVideo: videoModel,
            playlistId: wcontext.playlistId,
          );
        }
        break;

      case Ntype.resources:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          return ResourcesRoute(initialTabIndex: 1);
        }
        break;

      case Ntype.wealthcase:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          NotificationContextModel wcontext = getNotificationContextModel()!;
          if (wcontext.id.isNotNullOrEmpty) {
            return WealthcaseDetailRoute(basketId: wcontext.id);
          } else {
            return WealthcaseListRoute();
          }
        }
        break;

      case Ntype.referral:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          return ReferralDeeplinkRoute();
        }
        break;

      case Ntype.branding:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          return BrandingWebViewRoute();
        }
        break;

      case Ntype.birthdayWish:
        NotificationContextModel? wcontext = getNotificationContextModel();

        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          if (wcontext == null || wcontext.name.isNullOrEmpty) {
            return ClientBirthdayRoute();
          }

          final client = Client(
            name: wcontext.name,
            dob: wcontext.dob,
            id: wcontext.id,
          );

          return BirthdayWishRoute(client: client);
        }
        break;

      case Ntype.portfolioReview:
        NotificationContextModel? wcontext = getNotificationContextModel();
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          return ChooseClientRoute();
        }
        break;

      case Ntype.story:
        NotificationContextModel? wcontext = getNotificationContextModel();
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          return StoryRoute(storyIdToNavigate: wcontext?.storyId);
        }
        break;

      case Ntype.calculators:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          return CalculatorTemplateRoute();
        }
        break;

      case Ntype.managerWhatsapp:
        NotificationContextModel wcontext = getNotificationContextModel()!;

        launch(wcontext.directUrl!);
        break;

      case Ntype.managerContact:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          if (advisorOverview != null) {
            return ContactRmBottomSheetRoute(
              advisorModel: advisorOverview,
            );
          }
        }

        break;

      case Ntype.rewardHome:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          return RewardsRoute(
            fromScreen: 'push-notification',
          );
        }

        break;

      case Ntype.rewardsWon:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          return RewardSuccessRoute();
        }

        break;

      case Ntype.advisorProfile:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          return ProfileRoute();
        }

        break;

      case Ntype.clientsList:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          if (context != null) {
            AutoRouter.of(context)
                .popUntil(ModalRoute.withName(BaseRoute.name));
            setCurrentScreen(Screens.CLIENTS);
          } else {
            return ClientListRoute();
          }
          // return Clients();
        }

        break;

      // client profile coming from notification screen
      case Ntype.clientProfile:
      case Ntype.clientDetail:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          setfromPushNotificationHandler(true, message);
        } else {
          NotificationContextModel? wcontext = getNotificationContextModel();

          // TODO: update logic
          // temporary fix for notification screen
          // as external id not coming in attributes of notification api
          // so creating client object from data getting in attribute key value pair
          return isDataNotification
              // Client object
              ? ClientDetailRoute(client: message.data['client'])
              // Client external id
              : ClientDetailRoute(clientId: wcontext?.clientId);
        }

        break;

      case Ntype.eventDetail:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          setfromPushNotificationHandler(true, message);
        } else {
          NotificationContextModel wcontext = getNotificationContextModel()!;
          return EventDetailRoute(eventScheduleId: wcontext.eventId);
        }

        break;

      case Ntype.sipBook:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);
          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          return SipBookRoute();
        }

        break;

      case Ntype.mfTracker:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);
          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          return TrackerListRoute();
        }

        break;

      case Ntype.advisorTeam:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);
          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          return MyTeamRoute();
        }

        break;

      case Ntype.nfo:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);
          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          return TopFundsNfoRoute(activeTab: MfListType.Nfo);
        }

        break;

      case Ntype.storeList:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);
          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          NotificationContextModel wcontext = getNotificationContextModel()!;

          if (wcontext.productCategory?.toLowerCase() ==
                  ProductCategoryType.INSURANCE.toLowerCase() ||
              wcontext.productType?.toLowerCase() ==
                  ProductCategoryType.INSURANCE.toLowerCase()) {
            if (wcontext.productVariant.isNullOrEmpty) {
              return InsuranceHomeRoute();
            } else {
              return InsuranceDetailRoute(
                  productVariant: wcontext.productVariant);
            }
          }

          if (wcontext.productType != null) {
            PageRouteInfo? screenToNavigate;
            switch (wcontext.productType!.toLowerCase()) {
              case ProductType.MF:
                screenToNavigate = MfPortfolioListRoute();
                break;
              case ProductType.UNLISTED_STOCK:
                screenToNavigate = PreIpoListRoute();
                break;
              case ProductType.FIXED_DEPOSIT:
                screenToNavigate = FixedDepositListRoute();
                break;
              case ProductType.PMS:
                screenToNavigate = PmsProviderListRoute();
                break;
              case ProductType.SIF:
                screenToNavigate = SifListRoute();
                break;
              case ProductType.DEMAT:
                screenToNavigate = DematStoreRoute();
                break;
              case ProductType.CREDIT_CARD:
                screenToNavigate = CreditCardHomeRoute();
                break;
              case ProductType.DEBENTURE:
                screenToNavigate = DebentureListRoute();
                break;
              case ProductType.MF_FUND:
                screenToNavigate = MfLobbyRoute();
                break;
            }
            return screenToNavigate;
          } else {
            if (context != null) {
              AutoRouter.of(context)
                  .popUntil(ModalRoute.withName(BaseRoute.name));
              setCurrentScreen(Screens.STORE);
            } else {
              return StoreRoute(showBackButton: true);
            }
          }
        }

        break;

      case Ntype.contentDetail:
        NotificationContextModel wcontext = getNotificationContextModel()!;
        setCurrentScreen(Screens.HOME);

        // setTab(DASHBOARD_SCREEN);

        if (wcontext.webviewUrl.toString().trim().isNotEmpty) {
          if (viaLaunch) {
            setCurrentScreen(Screens.HOME);

            // setTab(DASHBOARD_SCREEN);
            setfromPushNotificationHandler(true, message);
          } else {
            return WebViewRoute(url: wcontext.webviewUrl);
          }
        } else if (wcontext.directUrl.toString().trim().isNotEmpty) {
          launch(wcontext.directUrl!);
        }
        break;

      case Ntype.proposalsList:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          NotificationContextModel wcontext = getNotificationContextModel()!;
          if (wcontext.status != null) {
            return ProposalListRoute(
              tabStatus: wcontext.status,
              showBackButton: true,
            );
          } else {
            LogUtil.printLog('context==>$context');
            if (context != null) {
              AutoRouter.of(context)
                  .popUntil(ModalRoute.withName(BaseRoute.name));
              setCurrentScreen(Screens.PROPOSALS);
            } else {
              return ProposalListRoute();
            }
          }
        }

        break;

      case Ntype.proposalDetail:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          setfromPushNotificationHandler(true, message);
        } else {
          NotificationContextModel? wcontext = getNotificationContextModel();
          return ProposalDetailsRoute(proposalId: wcontext?.proposalId);
        }

        break;

      case Ntype.mfList:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          setfromPushNotificationHandler(true, message);
        } else {
          NotificationContextModel? wcontext = getNotificationContextModel();
          if (wcontext?.amc.isNotNullOrEmpty ?? false) {
            return MfListRoute(amc: wcontext?.amc);
          } else if (wcontext?.productCategory.isNotNullOrEmpty ?? false) {
            Choice categorySelected = Choice(
                displayName: wcontext?.productCategory,
                value: wcontext?.productCategory);
            return MfListRoute(categorySelected: [categorySelected]);
          } else {
            return MfLobbyRoute();
          }
        }

        break;

      case Ntype.clientReports:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          setfromPushNotificationHandler(true, message);
        } else {
          return ReportTemplateRoute();
        }

        break;

      case Ntype.creatives:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          setfromPushNotificationHandler(true, message);
        } else {
          NotificationContextModel wcontext = getNotificationContextModel()!;

          TagModel? defaultCategory;
          TagModel? defaultLanguage;
          CreativeNewModel? creative;

          if (wcontext.category.isNotNullOrBlank) {
            defaultCategory = TagModel(tag: wcontext.category);
          }

          if (wcontext.language.isNotNullOrBlank) {
            defaultLanguage = TagModel(tag: wcontext.language);
          }

          if (wcontext.creativeUrl.isNotNullOrBlank) {
            creative = CreativeNewModel(
              name: "",
              url: wcontext.creativeUrl,
              type: "img",
            );
          }

          return ResourcesRoute(
            showDailyCreative: wcontext.showDailyCreative,
            defaultCategory: defaultCategory,
            creative: creative,
            defaultLanguage: defaultLanguage,
          );
        }

        break;

      case Ntype.advisorActivity:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          return NotificationRoute();
        }
        break;

      case Ntype.revenueSheet:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          return RevenueSheetRoute();
        }
        break;
      case Ntype.payout:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          return PayoutRoute();
        }
        break;

      case Ntype.myBusiness:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          return MyBusinessRoute();
        }
        break;

      case Ntype.broking:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          return BrokingRoute();
        }
        break;

      case Ntype.empanelment:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          // return EmpanelmentRoute();
          return ProfileUpdateRoute();
        }
        break;

      case Ntype.partnerNominee:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          return PartnerNomineeRoute();
        }
        break;

      case Ntype.transactions:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          return TransactionsRoute();
        }
        break;

      case Ntype.businessReport:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          return BusinessReportTemplateRoute();
        }
        break;

      case Ntype.cob:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          return TicobRoute();
        }
        break;

      case Ntype.faq:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          return FaqRoute();
        }
        break;

      case Ntype.support:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          return SupportRoute();
        }
        break;

      case Ntype.soa:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, message);
        } else {
          return SoaDownloadRoute();
        }
        break;

      case Ntype.successScreen:
        Map<String, dynamic>? eventData = message.data['event_data'] != null
            ? json.decode(message.data['event_data'])
            : {};
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          // setTab(DASHBOARD_SCREEN);
          setfromPushNotificationHandler(true, eventData);
        } else {
          return KycStatusRoute(
              kycStatus: AgentKycStatus.APPROVED, trackingData: eventData);
        }

        break;

      case Ntype.newsletter:
        if (viaLaunch) {
          setCurrentScreen(Screens.HOME);

          setfromPushNotificationHandler(true, message);
        } else {
          NotificationContextModel wcontext = getNotificationContextModel()!;
          if (wcontext.id.isNotNullOrEmpty) {
            return NewsLetterDetailRoute(newsLetterId: wcontext.id);
          } else {
            return NewsLetterRoute();
          }
        }

        break;

      default:
        setCurrentScreen(Screens.HOME);
        // setTab(DASHBOARD_SCREEN);
        return null;
    }

    //List of Outdated notifications payload

    // case 'add-new-client':
    //   if (viaLaunch) {
    //     setCurrentScreen(Screens.HOME);

    //     // setTab(DASHBOARD_SCREEN);
    //     setfromPushNotificationHandler(true, message);
    //   } else {
    //     return Clients(
    //       showAddClient: true,
    //     );
    //   }
    //   break;

    // case 'learning':
    //   if (viaLaunch) {
    //     setCurrentScreen(Screens.HOME);

    //     // setTab(DASHBOARD_SCREEN);
    //     setfromPushNotificationHandler(true, message);
    //   } else {
    //     return Learn();
    //   }

    //   break;

    // case 'client-profile':
    //   setCurrentScreen(Screens.CLIENTS);

    //   // setTab(CLIENT_SCREEN);
    //   break;

    // case 'advisor-team':
    //   setCurrentScreen(Screens.PROPOSALS);

    //   // setTab(PROPOSALS_SCREEN);
    //   break;

    // case 'proposals-details':
    //   setCurrentScreen(Screens.PROPOSALS);

    //   // setTab(PROPOSALS_SCREEN);
    //   break;
  }
}
