import 'package:api_sdk/log_util.dart';
import 'package:app/flavors.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:freshchat_sdk/freshchat_sdk.dart';
import 'package:freshchat_sdk/freshchat_user.dart';
import 'package:get/get.dart';


class FreshchatService {
  static final FreshchatService _singleton = FreshchatService._internal();

  factory FreshchatService() {
    return _singleton;
  }

  FreshchatService._internal();

  String? externalId;
  String? restoreId;

  Future<void> initializeFreshchat() async {
    Freshchat.init(
      F.freshChatAppId,
      F.freshChatAppKey,
      F.freshChatDomain,
      themeName: 'FCTheme.plist',
    );

    // TODO: To be enabled once restore ID can be saved on Backend
    // Listen to restore id generation event
    // final restoreStream = Freshchat.onRestoreIdGenerated;
    // restoreStream.listen((dynamic event) async {
    //   LogUtil.printLog("Restore ID Generated: $event");
    //   final user = await Freshchat.getUser;
    //   restoreId = user.getRestoreId();
    //   Freshchat.identifyUser(
    //     externalId: externalId ?? '',
    //     restoreId: restoreId,
    //   );
    // });

    // Listen Freshchat message count update
    final unreadCountStream = Freshchat.onMessageCountUpdate;
    unreadCountStream.listen((dynamic event) {
      LogUtil.printLog("Have unread messages: $event");
      // TODO: Add event to FreshchatBloc
    });

    final userInteractionStream = Freshchat.onUserInteraction;
    userInteractionStream.listen((dynamic event) {
      LogUtil.printLog("User interaction for Freshchat SDK: $event");
    });
  }

  void setUser() {
    final homeController = Get.find<HomeController>();
    final userProfile = homeController.advisorOverviewModel?.agent;
    externalId = userProfile?.externalId;
    final tag = homeController.advisorOverviewModel?.agent?.isAgentFixed
        ? "Relationship Manager"
        : "Partner";
    final userPropertiesJson = {
      "cf_agent_id": homeController.agentId?.toString() ?? '',
      "cf_rm_email":
          homeController.advisorOverviewModel?.agent?.pst?.email ?? '',
      "cf_usertag": tag,
      "cf_crn": "-",
      "cf_partner_email": "-",
    };
    final nameList = (userProfile?.name ?? '').split(' ');
    String firstName = '';
    String lastName = '';
    if (nameList.length > 1) {
      lastName = nameList.removeLast();
      firstName = nameList.join(' ');
    } else {
      firstName = nameList.first;
      lastName = '';
    }
    final countryCode = extractCountryCode(userProfile?.phoneNumber);
    final phoneNo = extractPhoneNumber(userProfile?.phoneNumber);
    final freshchatUser = FreshchatUser(externalId, restoreId);
    freshchatUser.setFirstName(firstName);
    freshchatUser.setLastName(lastName);
    if (phoneNo.isNotNullOrEmpty) {
      freshchatUser.setPhone(countryCode, phoneNo);
    }
    if ((userProfile?.email ?? '').isNotNullOrEmpty) {
      freshchatUser.setEmail(userProfile?.email ?? '');
    }

    Freshchat.setUserProperties(userPropertiesJson);
    Freshchat.setUser(freshchatUser);
  }

  Future<void> restoreUser() async {
    final user = await Freshchat.getUser;
    restoreId = user.getRestoreId();
    Freshchat.identifyUser(externalId: externalId ?? '', restoreId: restoreId);
  }

  void resetUser() {
    Freshchat.resetUser();
  }
}
