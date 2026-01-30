import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:blitzllama_flutter/blitzllama_flutter.dart';
import 'package:core/main.dart';
import 'package:get/get.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MixPanelAnalytics {
  static Mixpanel? _instance;

  static Future<Mixpanel> init() async {
    if (_instance == null) {
      _instance = await Mixpanel.init("730e081f95d5786e5d3df1c4d26a7459",
          trackAutomaticEvents: false);
      _instance?.setLoggingEnabled(true);
    }

    return _instance!;
  }

  static void identify(String id, {String? email}) async {
    try {
      Mixpanel? mixpanel = MixPanelAnalytics._instance;

      mixpanel?.identify(id);

      if (email?.isNotNullOrEmpty ?? false) {
        mixpanel?.getPeople().set("email", email);
        mixpanel?.registerSuperProperties({"Email": email});
      }

      SharedPreferences sharedPreferences = await prefs;
      sharedPreferences.setBool(
          SharedPreferencesKeys.isMixPanelIdentitySet, true);
    } catch (error) {
      LogUtil.printLog('Something went wrong');
    }
  }

  static void trackWithAgentId(String eventName,
      {String? screen,
      String? screenLocation,
      Map<String, dynamic>? properties,
      bool sendToLlama = false}) async {
    try {
      Mixpanel? mixpanel = MixPanelAnalytics._instance;

      // set MixPanel Identity if not alreaady
      MixPanelAnalytics.setMixPanelIdentitySet();

      if (properties == null) {
        properties = Map<String, dynamic>();
      }

      int? agentId = await getAgentId();
      if (agentId != null) {
        properties['userId'] = '$agentId';
      }
      properties['dateTime'] = DateTime.now().toString();

      if (screen != null) {
        properties['screen'] = screen;
      }

      if (screenLocation != null) {
        properties['screen_location'] = screenLocation;
      }

      mixpanel?.track(eventName, properties: properties);

      if (sendToLlama) {
        BlitzllamaFlutter.triggerEvent(eventName);
      }
    } catch (error) {
      LogUtil.printLog('Something went wrong $error');
    }
  }

  static void setMixPanelIdentitySet() async {
    try {
      SharedPreferences sharedPreferences = await prefs;
      bool isMixPanelIdentitySet = sharedPreferences
              .getBool(SharedPreferencesKeys.isMixPanelIdentitySet) ??
          false;

      if (isMixPanelIdentitySet == false) {
        Mixpanel? mixpanel = MixPanelAnalytics._instance;
        String agentExternalId = await getAgentExternalId() ?? '';

        mixpanel?.identify(agentExternalId);

        if (Get.isRegistered<HomeController>()) {
          String email =
              Get.find<HomeController>().advisorOverviewModel?.agent?.email ??
                  '';
          mixpanel?.getPeople().set("email", email);
          mixpanel?.registerSuperProperties({"Email": email});
        }

        sharedPreferences.setBool(
            SharedPreferencesKeys.isMixPanelIdentitySet, true);
      }
    } catch (error) {
      LogUtil.printLog(error.toString());
    }
  }
}
