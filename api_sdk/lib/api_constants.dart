import 'package:graphql/client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

enum ClientInvestmentProductType {
  all,
  mutualFunds,
  preIpo,
  fixedDeposit,
  debentures,
  pms,
  insurance,
  sif
}

class ApiConstants {
  ApiConstants._();
  static ApiConstants _instance = ApiConstants._();
  factory ApiConstants() => _instance;
  String _baseUrl = '';

  String _certifiedBaseUrl = '';
  String _apiClientCertificate = '';
  String _apiClientCertificateKey = '';
  String _quinjetBaseUrl = '';
  String _fundsApiBaseUrl = '';
  String _xThreadId = '';
  String _xAccessToken = '';

  String advisorWorkerBaseUrl = 'https://advisor-worker.wealthy.workers.dev';
  String wealthyApiBaseUrl = 'https://api.wealthy.in';

  String get baseUrl => _baseUrl;

  String get certifiedBaseUrl => _certifiedBaseUrl;
  String get apiClientCertificate => _apiClientCertificate;
  String get apiClientCertificateKey => _apiClientCertificateKey;
  String get quinjetBaseUrl => _quinjetBaseUrl;
  String get fundsApiBaseUrl => _fundsApiBaseUrl;

  String get xThreadId => _xThreadId;
  String get xAccessToken => _xAccessToken;

  set xThreadId(String xThreadId) {
    this._xThreadId = xThreadId;
  }

  set xAccessToken(String xAccessToken) {
    this._xAccessToken = xAccessToken;
  }

  set baseUrl(String url) {
    this._baseUrl = url;
  }

  set certifiedBaseUrl(String certifiedBaseUrl) {
    this._certifiedBaseUrl = certifiedBaseUrl;
  }

  set apiClientCertificate(String apiClientCertificate) {
    this._apiClientCertificate = apiClientCertificate;
  }

  set apiClientCertificateKey(String apiClientCertificateKey) {
    this._apiClientCertificateKey = apiClientCertificateKey;
  }

  set quinjetBaseUrl(String quinjetBaseUrl) {
    this._quinjetBaseUrl = quinjetBaseUrl;
  }

  set fundsApiBaseUrl(String url) {
    this._fundsApiBaseUrl = url;
  }

  String get paymentCollectorUrl {
    if (isProd) {
      return 'https://collector.wealthydev.in/payments/api/v0/callback/J24D6eWDZiJm48250nxo1NxhEhDGtyW5UUhi5WuvRcxr1t39beO366jZEZywG4PEKXUhf0kzzf5vnp1g8SKaRRBiK5LCdc2URKP9/';
    } else {
      return "https://collector.wealthydev.in/payments/api/v0/callback/J24D6eWDZiJm48250nxo1NxhEhDGtyW5UUhi5WuvRcxr1t39beO366jZEZywG4PEKXUhf0kzzf5vnp1g8SKaRRBiK5LCdc2URKP9/";
    }
  }

  String get skynetBaseUrl {
    if (isProd) {
      return 'https://skynettrack.wealthy.in';
    } else {
      return "https://track.wealthydev.in";
    }
  }

  String get toolsBaseUrl {
    if (isProd) {
      // prod api not setup currently 
      return 'https://tools.wealthydev.in';
    } else {
      return "https://tools.wealthydev.in";
    }
  }

  String get newsletterSubscribeBaseUrl {
    if (isProd) {
      return 'https://apis.wealthy.in';
    } else {
      return 'https://apis.wealthydev.in';
    }
  }

  String _baseUrlTaxy = '';
  String get baseUrlTaxy => _baseUrlTaxy;

  set baseUrlTaxy(String url) {
    this._baseUrlTaxy = url;
  }

  String _graphqlUrl = '';
  String get graphqlUrl => _graphqlUrl;

  set graphqlUrl(String url) {
    this._graphqlUrl = url;
  }

  bool _isProd = false;
  bool get isProd => _isProd;

  set isProd(bool isProd) {
    this._isProd = isProd;
  }

  String _aiBaseUrl = 'https://aiapis.wealthy.in';
  String get aiBaseUrl => _aiBaseUrl;

  set aiBaseUrl(String url) {
    this._aiBaseUrl = url;
  }

  GraphQLClient client(String? apiKey, dynamic headers) {
    final HttpLink _httpLink = HttpLink(graphqlUrl, defaultHeaders: headers);

    final AuthLink _authLink = AuthLink(
      getToken: () => apiKey,
    );

    final Link _link = _authLink.concat(_httpLink);

    return GraphQLClient(
      cache: GraphQLCache(),
      link: _link,
      queryRequestTimeout: Duration(seconds: 30),
    );
  }

  getRestApiUrl(String endpoint) {
    switch (endpoint) {
      case 'taxy':
        return "$baseUrl/taxy/external-apis/v0/";
      case 'login':
        return "$baseUrl/dashboards/api/v0/login/";
      case 'signup':
        return "$baseUrl/dashboards/api/v0/sign-up-via-otp/";
      case 'signup-captcha':
        return "$certifiedBaseUrl/partners/app-auth/v0/sign-up-via-otp/";
      case 'verify-signup':
        return "$baseUrl/dashboards/api/v0/verify-sign-up-otp/";
      case 'verify-signup-captcha':
        return "$certifiedBaseUrl/partners/app-auth/v0/verify-sign-up-otp/";
      case 'resend-signup-otp':
        return "$baseUrl/dashboards/api/v0/resend-sign-up-otp/";
      case 'onboarding-question-v2':
        return "$baseUrl/external-apis/v1/qna/";
      case 'cities':
        return "$baseUrl/external-apis/v0/all-cities/";
      case 'branding':
        return "$baseUrl/external-apis/v0/branding/";
      case 'update-lead-qna':
        return "$baseUrl/external-apis/v0/update-lead-qna/";
      case 'update-lead-qna-v2':
        return "$baseUrl/external-apis/v1/update-lead-qna/";
      case 'forgot-password':
        return "$baseUrl/dashboards/api/v0/forgot-password/";
      case 'notification':
        return "$baseUrl/notif/v0/data-notifications/";
      case 'notification-count':
        return "$baseUrl/notif/v0/data-notification-counter/";
      case 'notification-reset-count':
        return "$baseUrl/notif/v0/reset-data-notification-counter/";
      case 'skynet-v1':
        return "https://skynettrack.wealthy.in/skynet/v1/";
      case 'set-fcm-token':
        return "$baseUrl/external-apis/pn-tokens/";
      case 'verify-agent':
        return "$baseUrl/external-apis/agent-verify/";
      case 'proposals':
        return "$baseUrl/external-apis/v0/proposals/";
      case 'proposals-v2':
        return "$baseUrl/quinjet/proposals/api/v0/proposals/";
      case 'quinjet-proposals':
        return "$baseUrl/quinjet/proposals/api/";
      case 'swp-proposal':
        return "$baseUrl/quinjet/proposals/api/swp/v0/";
      case 'stp-proposal':
        return "$baseUrl/quinjet/proposals/api/stp/v0/";
      case 'order-proposal':
        return "$baseUrl/quinjet/proposals/api/order/v0/";
      case 'store-demat':
        return "$baseUrl/quinjet/proposals/api/v0/demat";
      case 'mandate-proposal':
        return "$baseUrl/quinjet/proposals/api/v0/mandate/";
      case 'mandate-options':
        return "$baseUrl/taxy/external-apis/v0/mandate/options/";
      case 'login-otp':
        return "$baseUrl/dashboards/api/v0/send-login-otp/";
      case 'login-phone':
        return "$baseUrl/dashboards/api/v0/login-via-otp/";
      case 'login-phone-captcha':
        return "$certifiedBaseUrl/partners/app-auth/v0/login-via-otp/";
      case 'validate-referral-code':
        return "$baseUrl/dashboards/api/v0/validate-referral-code/";
      case 'create-pv-request':
        return '$baseUrl/external-apis/v0/create-pv-request/';
      case 'send-pv-otp':
        return "$baseUrl/external-apis/v0/send-pv-otp/";
      case 'resend-pv-otp':
        return "$baseUrl/external-apis/v0/resend-pv-otp/";
      case 'verify-pv-otp':
        return "$baseUrl/external-apis/v0/verify-pv-otp/";
      case 'store-products-old':
        return "$baseUrl/external-apis/v0/store-products/";
      case 'store-products-v1':
        return "$baseUrl/external-apis/v1/store-products/";
      case 'store-products-v2':
        return "$baseUrl/external-apis/v2/store-products/";
      case 'store-products-v3':
        return "$baseUrl/external-apis/v3/store-products/";
      case 'mf-search':
        return "$baseUrl/external-apis/v0/mf/search/";

      case 'sif-products':
        return "$baseUrl/metahouse/partners/v0/schemes/sifs/";

      case 'scout-search':
        return "$baseUrl/scout/v0/search/";

      case 'search-store':
        return "$baseUrl/external-apis/v0/store-products/search/";
      case 'get-user-sip-meta':
        return "$baseUrl/taxy/external-apis/v0/get-user-sip-meta/";
      case 'revenue-book':
        return "$baseUrl/external-apis/revenue-book-agg/";
      case 'gst':
        return "$baseUrl/external-apis/v0/gst/";
      case 'digio-webhook':
        return "$baseUrl/dashboards/api/v0/kyc/digio-webhook/";
      case 'tracker-request':
        return '$baseUrl/trak/advisors/v0/partner-requested-syncs/';
      case 'update-client-details':
        return '$baseUrl/hagrid/v0/update/';
      case 'initialize-email-verification':
        return '$baseUrl/entreat/api/v0/operations/generics/taxy/users/actions/initialize-email-verification/';
      case 'rewards':
        return '$baseUrl/rewards-apis/v0/external/rewards/';
      case 'rewards-redemption':
        return '$baseUrl/rewards-apis/v0/external/redeem/';
      case 'chart-data':
        return '$wealthyApiBaseUrl/taxy/api/v0/indexes/product/';
      case 'send-cr-otp':
        return "$baseUrl/external-apis/v0/send-cr-otp/";
      case 'verify-cr-otp':
        return "$baseUrl/external-apis/v0/verify-cr-otp/";
      case 'events':
        return '$baseUrl/events/event-clients/api/v0/';
      case 'client-investment-data':
        return '$baseUrl/nova/api/v0/user-data-v2/';
      // My Team
      case 'validate-team-agent-lead-otp':
        return '$baseUrl/external-apis/partner-office/validate-agent-lead-otp/';
      case 'resend-team-agent-lead-otp':
        return '$baseUrl/external-apis/partner-office/resend-agent-lead-otp/';
      case 'validate-and-add-employee':
        return '$baseUrl/external-apis/partner-office/validate-otp-and-add-employee/';
      case 'validate-and-add-associate':
        return '$baseUrl/external-apis/partner-office/validate-otp-and-add-associate/';
      // Fixed Deposits
      case 'fd-data':
        return '$baseUrlTaxy/fdapi/fd/master-data/';
      case 'fd-interest-data':
        return '$baseUrlTaxy/fdapi/v1/interest-rates/';
      case 'metahouse-mf-funds':
        return '$baseUrl/metahouse/api/v0/mf-funds/';

      // Credit Card
      // https://api.buildwealthdev.in/credit-card/
      case 'credit-card-proposal':
        return '$baseUrl/credit-card/v0/create/';
      case 'credit-card-detail':
        return '$baseUrl/credit-card/v0/cc/';
      case 'credit-card-summary':
        return '$baseUrl/credit-card/v0/summary/';
      case 'credit-card-promotions':
        return '$baseUrl/credit-card/v0/promotions/';
      case 'credit-card-resume':
        return '$baseUrl/credit-card/v0/continue/';

      case 'client-detail-change-request':
        return '$baseUrlTaxy/hagrid/dashboards/external/create-udcr/';

      case 'visiting-card-brochure':
        return '$baseUrl/external-apis/partner-office/generate-visiting-card-and-brochure/';
      case 'tag-master':
        return '$baseUrl/external-apis/partner-office/tagmaster/tag/fetch/objects/';
      case 'sip-version-for-user':
        return '$baseUrl/taxy/external-apis/v0/sip/v2/check-sip-version-for-user';
      case 'postal':
        return 'http://www.postalpincode.in/api/pincode/';
      // since every service in dev is moved to GCP, so the existing
      // URL will work.(http://api.wealthydev.in/quinjet)
      // For prod, it is temporary moved to quinjet.wealthy.systems
      // since not all services are moved to GCP

      case 'tracker-switch-proposal':
        return '$baseUrl/quinjet/proposals/api/v0/mf/create';

      case 'sip-edit-proposal':
        return '$baseUrl/quinjet/proposals/api/mf/v0/edit-sip';

      case 'kyc-sub-flow':
        return '$baseUrl/external-apis/initiate-sub-flow/';

      case 'audit-demat-consent':
        return '$baseUrl/external-apis/demat-consent/';

      case 'access-token':
        return '$baseUrl/dashboards/fetch/access-token/';
      case 'mf-lobby':
        return '$baseUrl/metahouse/partners';

      case 'metahouse-open':
        return '$baseUrl/metahouse/open/api/v0/mf-funds';

      case 'revenue-sheet':
        return '$baseUrl/external-apis/revenue-sheet';

      case 'partner-office-revenue-book':
        return '$baseUrl/external-apis/partner-office-revenue-book';

      case 'partner-revenue-book':
        return '$baseUrl/external-apis/revenue-book';

      case 'amc-soa-list':
        return '$baseUrl/taxy/external-apis/v0/get-amc-soa-download-details/';

      case 'soa-folio-list':
        return '$baseUrl/taxy/external-apis/v0/get-user-folios/';

      case 'sip-start-months-v2':
        return '$baseUrl/taxy/external-apis/v0/fetch-sip-start-months-v2';

      case 'sip-start-and-end-date-v2':
        return '$baseUrl/taxy/external-apis/v0/fetch-sip-start-and-end-date-v2';

      case 'generate-ticob-form':
        return '$baseUrl/taxy/external-apis/v0/generate-ticob-form-v3/';
      case 'tnc':
        return '$baseUrl/external-apis/tnc/';

      case 'newsletter':
        return '$baseUrl/wealthpress/api/v0/contents/';

      case 'newsletter-subscribe':
        return '$newsletterSubscribeBaseUrl/campaign-subscription/v0/money-order/subscribe-campaign/';

      case 'agent-profile-photo':
        return '$baseUrl/external-apis/profile-photo/';

      case 'client-filters-field':
        return '$baseUrl/external-apis/agent-filters-field-mapping/';
      // ai Apis
      case 'ai-response-api':
        return "$aiBaseUrl/playground/api/v0/threads";
      // Insurance Policy Apis
      case 'share-insurance-policy':
        return '$baseUrl/insurance/share-policy-pdf';
      case 'insurance-send-otp':
        return '$baseUrl/insurance/send-otp';
      case 'insurance-verify-otp':
        return '$baseUrl/insurance/verify-otp';

      case 'register-device-token':
        return '$skynetBaseUrl/skynet/v1/user/device/';
      case 'deregister-device-token':
        return '$skynetBaseUrl/skynet/v1/user/device/signout/';

      case 'partner-referral-info':
        return '$baseUrl/external-apis/v0/referral/info/';

      case 'wealthcase-baskets':
        return '$baseUrl/midas/api/agents/v0/wealthcase/?includePerformance=true';
      case 'wealthcase-basket-detail':
        return '$baseUrl/midas/api/agents/v0/wealthcase/';

      case 'portfolio-synced-pans':
        return '$baseUrl/phaser/external-apis/portfolio/v0/pans/synced';

      case 'calculator-report-pdf':
        return '$baseUrl/report-generator/external-apis/v0/generate-pdf/';

      case 'pdf-branding':
        return '$toolsBaseUrl/api/v1/pdf/branding';

      default:
    }
  }
}
