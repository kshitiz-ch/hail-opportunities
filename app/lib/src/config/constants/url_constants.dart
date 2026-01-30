import 'package:app/flavors.dart';

urlConstants (appFlavor) {
  Map constants = {};
  switch (appFlavor) {
    case Flavor.PROD:
      constants = {
        "REDIRECT_API_URL": "https://api.buildwealth.in/dashboards/api/v0/mobile-redirect",
        "EXISTING_GOALS_URL": "https://app.buildwealth.in/wealthy-store/mfs?show-create-proposal=true",
        "OTHER_FUNDS_URL": "https://app.buildwealth.in/wealthy-store/mfs/Custom-Portfolio/20000/?name=Other-Funds",
        "MICRO_SIP_URL": "https://app.buildwealth.in/wealthy-store/mfs/Micro-SIP/20002/?name=Micro-SIP"
      };
      break;
    case Flavor.DEV:
      constants = {
        "REDIRECT_API_URL": "https://api.buildwealthdev.in/dashboards/api/v0/mobile-redirect",
        "EXISTING_GOALS_URL": "https://app.buildwealthdev.in/wealthy-store/mfs?show-create-proposal=true",
        "OTHER_FUNDS_URL": "https://app.buildwealthdev.in/wealthy-store/mfs/Custom-Portfolio/20000/?name=Other-Funds",
        "MICRO_SIP_URL": "https://app.buildwealthdev.in/wealthy-store/mfs/Micro-SIP/20002/?name=Micro-SIP"
      };
      break;
    default:
      constants = {
        "REDIRECT_API_URL": "https://api.buildwealthdev.in/dashboards/api/v0/mobile-redirect",
        "EXISTING_GOALS_URL": "https://app.buildwealthdev.in/wealthy-store/mfs?show-create-proposal=true",
        "OTHER_FUNDS_URL": "https://app.buildwealthdev.in/wealthy-store/mfs/Custom-Portfolio/20000/?name=Other-Funds",
        "MICRO_SIP_URL": "https://app.buildwealthdev.in/wealthy-store/mfs/Micro-SIP/20002/?name=Micro-SIP"
      };
  }

  return constants;
}