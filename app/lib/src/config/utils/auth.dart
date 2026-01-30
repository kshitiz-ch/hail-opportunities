import 'package:android_play_install_referrer/android_play_install_referrer.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:core/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> getReferralDetails() async {
  String utmSource = "utm_source";
  String utmTerm = "utm_term";
  String utmCampaign = "utm_campaign";
  String utmContent = "utm_content";
  String utmMedium = "utm_medium";
  String gclidKey = "gclid";
  String gbraidKey = "gbraid"; // New privacy-safe ID
  String wbraidKey = "wbraid";

  try {
    final SharedPreferences sharedPreferences = await prefs;
    if (sharedPreferences
            .getBool(SharedPreferencesKeys.isReferralDetailsUsed) ==
        true) {
      return {};
    }

    ReferrerDetails referrerDetails =
        await AndroidPlayInstallReferrer.installReferrer;

    String utmString = referrerDetails.installReferrer.toString();

    Uri uri = Uri.parse('?${utmString}');
    Map<String, String> queryParams = uri.queryParameters;

    String? gclidValue = queryParams[gclidKey];
    String? gbraidValue = queryParams[gbraidKey];
    String? wbraidValue = queryParams[wbraidKey];

    bool isDefaultGooglePlayParams = queryParams[utmSource] == "google-play";
    if (isDefaultGooglePlayParams) {
      return {};
    }

    return {
      utmSource: queryParams[utmSource],
      utmTerm: queryParams[utmTerm],
      utmCampaign: queryParams[utmCampaign],
      utmContent: queryParams[utmContent],
      utmMedium: queryParams[utmMedium]
    };
  } catch (error) {
    return {};
  }
}
