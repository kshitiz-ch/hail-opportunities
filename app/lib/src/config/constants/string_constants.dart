library constants;

import 'package:api_sdk/api_constants.dart';
import 'package:app/flavors.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';

// Onboarding Screens
const String app_name = "APP NAME";

const String indiaCountryCode = '+91';
const String uaeCountryCode = '+971';

const String defaultPstNumber = '8299719561';

double customPortfolioMinAmount = 1000;

// tabs
const String tab0 = "Tab 0";
const String tab1 = "Tab 1";
const String tab2 = "Tab 2";
const String tab3 = "Tab 3";

//Screen 1
const String screen_util = "Screen";

const String countriesDataFile = 'assets/data/countries.json';

// Floating Action Button default hero tag
const String kDefaultHeroTag = "bottom-fab";

const String bulletPointUnicode = '\u2022';
const String smallBulletPointUnicode = '\u00B7';

const managerAvatarPlaceholder =
    'https://i.wlycdn.com/wealth-managers/rm-female-icon.png';
//home
const String app_bar_title = 'Wealthy';
const String kyc_redirection_url = 'https://kycredirection.com';
const String amfi_distributor_url =
    "https://www.amfiindia.com/distributor-corner/become-mutual-fund-distributor";

String extractNameFromEmail(String email) {
  return email.split("@")[0];
}

String normaliseName(String name) {
  final stringBuffer = StringBuffer();

  var capitalizeNext = true;
  for (final letter in name.toLowerCase().codeUnits) {
    // UTF-16: A-Z => 65-90, a-z => 97-122.
    if (capitalizeNext && letter >= 97 && letter <= 122) {
      stringBuffer.writeCharCode(letter - 32);
      capitalizeNext = false;
    } else {
      // UTF-16: 32 == space, 46 == period
      if (letter == 32 || letter == 46) capitalizeNext = true;
      stringBuffer.writeCharCode(letter);
    }
  }

  return stringBuffer.toString();
}

String getInitials(String name) => name.isNotEmpty
    ? name.trim().split(' ').map((l) => l[0]).take(1).join()
    : '';

// final Map<String, String> relations = {
//   "brtr": "Brother",
//   "dgtr": "Daughter",
//   "wife": "Wife",
//   "son": "Son",
//   "fath": "Father",
//   "moth": "Mother",
//   "sis": "Sister",
//   "husb": "Husband",
//   "grmth": "GrandMother",
//   "grfth": "GrandFather",
//   "o": "Others"
// };

Map<int, String> nomineeRelationships = {
  1: "Spouse",
  2: "Son",
  3: "Daughter",
  4: "Mother",
  5: "Father",
  6: "Brother",
  7: "Sister",
  8: "Grand Father",
  9: "Grand Mother",
  // 10: "Grand Son",
  // 11: "Grand Daughter",
  12: "Others",
};

List<String> mfBasketPortfolioSubtypes = ["2099", "201", "202", "203"];

Map<String, double> mfBasketPortfolioMinSipAmount = {
  mfBasketPortfolioSubtypes[0]: 3000,
  mfBasketPortfolioSubtypes[1]: 400,
  mfBasketPortfolioSubtypes[2]: 400,
  mfBasketPortfolioSubtypes[3]: 1000
};

const otherFundsGoalSubtype = "20000";
const anyFundGoalSubtype = "30000";
const microSipGoalSubtype = "20002";
const goldGoalSubtype = "10051";

const taxSaverProductVariant = "2024";
const insuranceDefaultContactNumber = '+918299719561';

const String genericErrorMessage = 'Something went wrong.\nPlease try again';
const String notAvailableText = 'NA';
const String dataNotPresentText = 'Data not present for this duration';
const String exitKycText =
    "You have not completed all the required KYC steps. Exit Anyway?";

// Investment Types
// class InvestmentType {
//   static const ONE_TIME = "onetime";
//   static const SIP = "sip";
// }

class AgentType {
  static const VARIABLE = "VARIABLE";
  static const FIXED = "FIXED";
}

class ScoreSubfields {
  static const ThreeYearReturn = "3 Year Return";
  static const YTM = "Yield to Maturity";
  static const Alpha = "Alpha";
  static const SD = "Standard Deviation";
  static const MD = "Modified Duration";
  static const Beta = "Beta";
  static const AAA = "AAA/Sovereign Allocation";
  static const Holding = "Holding in top 20 securites";
  static const PE = "PE";
}

// Product Types
class ProductType {
  static const MF = "mf";
  static const MF_FUND = "mffunds";
  static const UNLISTED_STOCK = "unlistedstock";
  static const DEBENTURE = "mld";
  static const FIXED_DEPOSIT = "fd";
  static const SIF = "sif";
  static const SAVINGS = "traditional";
  static const HEALTH = "health";
  static const TERM = "term";
  static const TWO_WHEELER = "general";
  static const PMS = "pms";
  static const DEMAT = "demat";
  static const CREDIT_CARD = "creditcard";
}

class ProductVariant {
  static const switchTracker = "switch";
  static const demat = "demat";
}

class InsuranceProductVariant {
  static const SAVINGS = "traditional";
  static const HEALTH = "health";
  static const TERM = "term";
  static const TWO_WHEELER = "twowheeler";
  static const FOUR_WHEELER = "fourwheeler";
  static const PENSION = "pension";
  static const ULIP = "ulips";
  static const QUOTE = "quote";
}

// Product Category Types
class ProductCategoryType {
  static const INSURANCE = "Insure";
  static const INVESTMENT = "Investment";
  static const INVEST = "Invest";
  // static const LOAN = "Loan";
  static const DEMAT = "Demat";
}

class GoalType {
  static const TAX_SAVER = 0;
  static const GENERAL_INVESTMENT = 1;
  static const SWITCH = 2;
  static const DEBT_PORTFOLIOS = 3;
  static const ADVANCE_SIP = 4;
  static const CUSTOM = 9;
  static const ANY_FUNDS = 10;
}

class AgentKycStatus {
  static const MISSING = 0;
  static const INITIATED = 1;
  static const INPROGRESS = 2;
  static const SUBMITTED = 3;
  static const APPROVED = 4;
  static const REJECTED = 5;
  static const FAILED = -1;
}

class AgentEmpanelmentStatus {
  static const Created = "CR";
  static const Pending = "PD";
  static const InProgress = "INPR";
  static const Empanelled = "EPLD";
  static const Bypass = "BYP";
  static const BypassTemp = "BYPTMP";
}

class AgentEmpanelmentOrderStatus {
  static const Created = "CR";
  static const Authorised = "AUTH";
  static const Captured = "CAP";
  static const Failed = "FLD";
  static const Refunded = "RFD";
}

// Any changes here should also be made under
// core/config/string_constants.dart
class ClientKycStatus {
  static const NOTRESPONDING = -1;
  static const MISSING = 0;
  static const INITIATED = 1;
  static const INPROGRESS = 2;
  static const SUBMITTEDBYCUSTOMER = 3;
  static const FOLLOWUPWITHCUSTOMER = 4;
  static const UPLOADEDTOKRA = 5;
  static const APPROVED = 6;
  static const REJECTEDBYKRA = 7;
  static const ESIGNPENDING = 8;
  static const APPROVEDBYADMIN = 9;
  static const REJECTEDBYADMIN = 10;
  static const VALIDATEDBYKRA = 11;
}

class ProposalStatus {
  static const CREATED = 0;
  static const PROPOSALINITIATED = 1;
  static const CLIENTCONFIRMED = 2;
  static const ACTIVE = 3;
  static const FAILURE = 4;
  static const COMPLETED = 5;
}

class TrackerRequestStatus {
  static const RequestedToCustomer = 1;
  static const InProgress = 2;
  static const Completed = 3;
  static const Failure = 4;
}

class TransactionStatusType {
  static const Created = 0;
  static const Initiated = 1;
  static const Processing = 2;
  static const Success = 3;
  static const Fail = 4;
}

class SchemeOrderStatusType {
  static const Failure = "F";
  static const Progress = "P";
  static const Success = "S";
}

class AdvisorContentContext {
  static const TopBanner = "top-banner";
  static const DownloadDocument = "download-document";
}

class RewardRedemptionStatus {
  static const Created = "C";
  static const PaymentInitiated = "PI";
  static const PaymentPending = "PP";
  static const PaymentSuccess = "PS";
}

class DeletePartnerRequestStatus {
  static const INITIATED = "INITIATED";
  static const APPROVE = "APPROVE";
  static const REJECT = "REJECT";
  static const DELETED = "DELETED";
}

// Any changes made here should also reflect on
// authentication_bloc.dart userlogout event
class SharedPreferencesKeys {
  static const hideRevenue = 'hide_revenue';
  static const finExp = "financial_experience";
  static const isAgentFixed = "is_agent_fixed";
  static const agentExternalId = "agent_external_id";
  static const delayRetryRedemption = "delay_retry_redemption";

  static const isSalesPlanIntroViewed = "sales_plan_intro_viewed";
  static const isSalesPlanScreenViewed = "sales_plan_screen_viewed";
  static const salesPlanType = "sales_plan_type";

  static const storyListBase64 = "story_base64";
  static const dailyMarketUpdateBase64 = "dmu_base64";

  static const hasContactPermissionAsked = "has_contact_permission_asked";
  static const currentPushNotificationData = "current_push_notification_data";
  static const showNewFeatureDetails = "show_new_feature_details";
  static const isNewUpdateFeatureViewed = "is_new_update_feature_viewed";
  static const showSearchShowCase = "show_search_showcase";
  // This variable also referenced in authentication_bloc
  static const shouldDisablePasscode = "shouldDisablePasscode";

  static const isTrackerSwitchUpdateViewed = "track_switch_update_viewed";
  static const useOldProposalApi = "use_old_proposal_api";

  static const homeQuickActions = "home_quick_actions";
  static const isReferralDetailsUsed = "is_referral_details_used";
  static const brochureUrl = "brochure_url";
  static const isMixPanelIdentitySet = "is_mixpanel_identity_set";

  static const agentCommunicationToken = 'agent_communication_token';
}

class GetxId {
  // Common
  static const proposal = 'proposal';
  static const form = 'form';
  static const search = 'search';
  static const schemeData = 'scheme-data';
  static const mandate = 'mandate';
  static const bank = 'bank';
  static const delete = 'delete';
  static const overview = 'overview';
  static const contentList = 'content-list';
  static const download = 'download';
  static const detail = 'detail';
  static const filter = 'filter';
  static const name = 'name';
  static const clients = 'clients';

  static const searchClient = 'search-client';
  static const createProposal = 'create-proposal';
  static const updateProposal = 'update-proposal';
  static const deleteProposal = 'delete-proposal';
  static const profile = 'profile';
  static const searchArn = 'search-arn';
  static const rewardBalance = 'reward-balance';
  static const topUpPortfolios = 'top-up-portfolios';
  static const notificationData = 'notification-data';
  static const notificationCount = 'notification-count';
  static const getClients = 'get-clients';
  static const searchClients = 'search-clients';
  static const pmsProducts = 'pms-products';
  static const registerAccount = 'register-account';
  static const storeProductDetail = 'store-product-detail';
  static const onboardingQuestion = 'onboarding-question';
  static const registerPhone = 'register-phone';
  static const verifySignInOtp = 'verify-sign-in-otp';
  // static const verifySignUpEmail = 'verify-signup-email';
  static const verifyEmail = 'verify-email';
  static const signInPhoneNumber = 'sign-in-phone-number';
  static const phoneNumberInput = 'phone-number-input';
  static const signInWithEmailAndPassword = 'sign-in-with-email-password';
  static const rewardDetail = 'reward-detail';
  static const creativesCarousel = 'creatives-carousel';
  static const insuranceProductDetail = 'insurance-product-detail';
  static const homeInsuranceProducts = 'home-insurance-products';
  static const referralCode = 'referral-code';

  // clients
  static const clientInvestments = 'investments';
  static const clientReport = 'client-report';
  static const nomineeBreakdowns = 'nominee-breakdowns';
  static const schemeForm = 'scheme-form';
  static const sendTicket = 'send-ticket';

  // Goals
  static const goalSchemeOrders = 'goal-scheme-orders';
  static const goalOrders = 'goal-orders';
  static const goalSip = 'goal-sip';

  static const goalStp = 'goal-stp';
  static const stpOrders = 'stp-orders';
  static const goalSwp = 'goal-swp';
  static const goalSwpOrders = 'goal-swp-orders';

  // revenue-sheet
  static const productWiseRevenue = 'product-wise-revenue';
  static const clientWiseRevenue = 'client-wise-revenue';

  // broking
  static const activity = 'activity';
  static const onboarding = 'onboarding';

  static const send = 'send';
  static const verify = 'verify';
  static const share = 'share';
}

class StoreProductPage {
  static const String HOME = "h";
  static const String POPULAR_PRODUCTS = "pp";
}

class StoreProductSections {
  static const String INSURANCE = 'insurance';
  static const String MF_PORTFOLIOS = 'mf_portfolios';
  static const String MF_FUNDS = 'mf_funds';
  static const String WEALTHY_PRODUCTS = 'wealthy_products';
}

List<String> insuranceProductTypes = [
  ProductType.TERM,
  ProductType.SAVINGS,
  ProductType.HEALTH,
  ProductType.TWO_WHEELER
];

List<String> smartIndexProductVariants = [
  "50000",
  "50001",
  "50002",
];

Map<String, Map> insuranceSectionData = {
  InsuranceProductVariant.TERM: {
    'title': 'Term life Insurance',
    'image_path': AllImages().termLifeInsuranceIcon,
    'lottie': AllImages().termInsuranceLottie,
    'background_color': ColorConstants.termLifeBgColor,
    'text_color': ColorConstants.termLifeTextColor,
    'description': 'Protect your loved ones when you are not around',
    'product_logos': [
      // 'https://res.cloudinary.com/dti7rcsxl/image/upload/v1664536380/Max_Life_gm0dms.png',
      AllImages().hdfcLifeIcon,
      AllImages().maxLifeIcon,
      AllImages().tataAIAIcon,
      // 'https://res.cloudinary.com/dti7rcsxl/image/upload/v1664434349/TATAAIG_aizds9.png',
      // 'https://res.cloudinary.com/dti7rcsxl/image/upload/v1664434348/HDFC_Ergo_zkrwek.png'
    ],
    'category': 'life',
  },
  InsuranceProductVariant.HEALTH: {
    'title': 'Health Insurance',
    'image_path': AllImages().healthInsuranceIcon,
    'lottie': AllImages().healthInsuranceLottie,
    'background_color': ColorConstants.lavenderColor,
    'text_color': ColorConstants.healthTextColor,
    'description': 'Secure your family with health plans for every illness',
    'product_logos': [
      // 'https://res.cloudinary.com/dti7rcsxl/image/upload/v1664536379/Niva_Bupa_czu97z.png',
      AllImages().careHealthIcon,
      AllImages().nivaBupaIcon,
      AllImages().hdfcErgoIcon,
      // 'https://res.cloudinary.com/dti7rcsxl/image/upload/v1664536379/Care_qxbohc.png',
      // 'https://res.cloudinary.com/dti7rcsxl/image/upload/v1664536378/HDFC_Ergo_cdbmih.png',
    ]
  },
  InsuranceProductVariant.SAVINGS: {
    'title': 'Savings Insurance',
    'image_path': AllImages().savingsInsuranceIcon,
    'lottie': AllImages().savingsInsuranceLottie,
    'background_color': ColorConstants.savingBgColor,
    'text_color': ColorConstants.savingTextColor,
    'description': 'Stay insured while you build your own wealth',
    'product_logos': [
      // 'https://res.cloudinary.com/dti7rcsxl/image/upload/v1664434348/HDFC_Ergo_zkrwek.png',
      AllImages().hdfcLifeIcon,
      AllImages().maxLifeIcon,
      AllImages().tataAIAIcon,
    ],
    'category': 'life',
  },
  InsuranceProductVariant.TWO_WHEELER: {
    'title': 'Bike Insurance',
    'image_path': AllImages().twoWheelerInsuranceIcon,
    'lottie': AllImages().twoWheelerInsuranceLottie,
    'background_color': ColorConstants.sandColor,
    'text_color': ColorConstants.twoWheelerTextColor,
    'description': 'Insure your vehicle against every contingency',
    'product_logos': [
      AllImages().hdfcErgoIcon,
      // 'https://res.cloudinary.com/dti7rcsxl/image/upload/v1664536378/HDFC_Ergo_cdbmih.png',
    ]
  },
  InsuranceProductVariant.FOUR_WHEELER: {
    'title': 'Car Insurance',
    'image_path': AllImages().fourWheelerInsuranceIcon,
    'lottie': AllImages().fourWheelerInsuranceLottie,
    'background_color': ColorConstants.fourWheelerBgColor,
    'text_color': ColorConstants.redAccentColor.withOpacity(0.5),
    'description': 'Insure your vehicle against every contingency',
    'product_logos': [
      AllImages().hdfcErgoIcon,
      // 'https://res.cloudinary.com/dti7rcsxl/image/upload/v1664536378/HDFC_Ergo_cdbmih.png',
    ]
  },
  InsuranceProductVariant.PENSION: {
    'title': 'Pension Plans',
    'image_path': AllImages().pensionInsuranceIcon,
    'lottie': AllImages().retirementInsuranceLottie,
    'background_color': ColorConstants.white,
    'text_color': ColorConstants.black,
    'description':
        'Offer 100% guaranteed pension for life. No medicals, makes this the perfect choice to plan retirement needs',
    'product_logos': []
  },
  InsuranceProductVariant.ULIP: {
    'title': 'ULIPs',
    'image_path': AllImages().ulipInsuranceIcon,
    'lottie': AllImages().ulipInsuranceLottie,
    'background_color': ColorConstants.white,
    'text_color': ColorConstants.black,
    'description':
        'Long term wealth creation plans offering dual benefit of investing in markets with insurance cover',
    'product_logos': []
  },
  InsuranceProductVariant.QUOTE: {
    'title': 'Quote Generation Links',
    'image_path': AllImages().quoteGeneration,
    // 'lottie': AllImages().ulipInsuranceLottie,
    'background_color': ColorConstants.white,
    'text_color': ColorConstants.black,
    'description': 'Wealthy Quote Generation Links for Life Insurance',
    'product_logos': []
  },
};

String getKYCStatusText(int? status) {
  switch (status) {
    case 0:
      return 'MISSING';
    case 1:
      return 'INITIATED';
    case 2:
      return 'INPROGRESS';
    case 3:
      return 'SUBMITTED';
    case 4:
      return 'APPROVED';
    case 5:
      return 'REJECTED';
    case -1:
      return 'FAILED';
    default:
      return notAvailableText;
  }
}

Color getClientKYCStatusColor(int? status) {
  if (status == ClientKycStatus.APPROVED) {
    return ColorConstants.greenAccentColor;
  }
  if ([
    ClientKycStatus.NOTRESPONDING,
    ClientKycStatus.MISSING,
    ClientKycStatus.REJECTEDBYKRA,
    ClientKycStatus.REJECTEDBYADMIN,
  ].contains(status)) {
    return ColorConstants.errorColor;
  }
  return Colors.orange;
}

String getClientKYCStatusDescription(int? status) {
  switch (status) {
    case -1:
      return 'Not Responding';
    case 0:
      return 'Missing';
    case 1:
      return 'Initiated';
    case 2:
      return 'In Progress';
    case 3:
      return 'Submitted By Customer';
    case 4:
      return 'Follow up with customer';
    case 5:
      return 'Uploaded To KRA';
    case 6:
      return 'Approved';
    case 7:
      return 'Rejected By KRA';
    case 8:
      return 'Esign Pending';
    case 9:
      return 'Approved By Admin';
    case 10:
      return 'Rejected By Admin';
    case 11:
      return 'Validated By KRA';
    default:
      return notAvailableText;
  }
}

class PartnerBankStatus {
  static const MISSING = '0';
  static const INITIATED = '1';
  static const INPROGRESS = '2';
  static const SUBMITTED = '3';
  static const APPROVED = '4';
  static const REJECTED = '5';
}

String getPartnerBankStatusText(String? status) {
  switch (status) {
    case PartnerBankStatus.MISSING:
      return 'Missing';
    case PartnerBankStatus.INITIATED:
      return 'Initiated';
    case PartnerBankStatus.INPROGRESS:
      return 'In Progress';
    case PartnerBankStatus.SUBMITTED:
      return 'Submitted';
    case PartnerBankStatus.APPROVED:
      return 'Approved';
    case PartnerBankStatus.REJECTED:
      return 'Rejected';
    default:
      return 'Missing';
  }
}

class ProductVideosType {
  static const String MF_PORTFOLIO = 'portfolio';
  static const String PRE_IPO = 'pre-ipo';
  static const String FIXED_DEPOSIT = 'fd';
  static const String TRACKER = 'tracker';
  static const String WEALTHCASE = 'wealthcase';
}

class InvestmentProductType {
  static const String mf = 'mf';
  static const String unlistedStock = 'unlistedstock';
  static const String mld = 'mld';
  static const String pms = 'pms';
  static const String motor = 'motor';
  static const String term = 'term';
  static const String health = 'health';
  static const String savings = 'savings';
  static const String fd = 'fd';
}

String getInvestmentProductTitle(String? productType) {
  switch (productType?.toLowerCase()) {
    case InvestmentProductType.mf:
      return 'Mutual Funds';
    case InvestmentProductType.pms:
      return 'PMS';
    case InvestmentProductType.mld:
      return 'Debentures';
    case InvestmentProductType.unlistedStock:
      return 'Pre IPO';
    case InvestmentProductType.health:
      return 'Health';
    case InvestmentProductType.motor:
      return 'Motor';
    case InvestmentProductType.term:
      return 'Term';
    case InvestmentProductType.savings:
      return 'Savings';
    case InvestmentProductType.fd:
      return 'Fixed Deposit';
    default:
      return '';
  }
}

String getClientInvestmentProductTitle(
    ClientInvestmentProductType productType) {
  switch (productType) {
    case ClientInvestmentProductType.mutualFunds:
      return 'Mutual Funds';
    case ClientInvestmentProductType.pms:
      return 'PMS';
    case ClientInvestmentProductType.debentures:
      return 'Debentures';
    case ClientInvestmentProductType.preIpo:
      return 'Pre IPO';
    case ClientInvestmentProductType.fixedDeposit:
      return 'Fixed Deposit';
    case ClientInvestmentProductType.sif:
      return 'SIF';
    default:
      return '';
  }
}

// Fury
Map<String, Map> clientFamilyRelationshipMapping = {
  "FAT": {
    "relation": "Father",
    "gender": "M",
  },
  "MOT": {
    "relation": "Mother",
    "gender": "F",
  },
  "BRO": {
    "relation": "Brother",
    "gender": "M",
  },
  "SIS": {
    "relation": "Sister",
    "gender": "F",
  },
  "GRF": {
    "relation": "Grand Father",
    "gender": "M",
  },
  "GRM": {
    "relation": "Grand Mother",
    "gender": "F",
  },
  "HUF": {
    "relation": "HUF",
    "gender": "M",
  },
  "SON": {
    "relation": "Son",
    "gender": "M",
  },
  "WIF": {
    "relation": "Wife",
    "gender": "F",
  },
  "DAU": {
    "relation": "Daughter",
    "gender": "F",
  },
  "HUS": {
    "relation": "Husband",
    "gender": "M",
  },
  "OTH": {
    "relation": "Others",
    "gender": "M",
  },
  "COR": {
    "relation": "Corporate",
    "gender": "M",
  },
  "JOI": {
    "relation": "Joint",
    "gender": "M",
  }
};

// Hagrid
Map<String, Map> familyRelationshipMapping = {
  "FATH": {
    "relation": "Father",
    "gender": "M",
  },
  "MOTH": {
    "relation": "Mother",
    "gender": "F",
  },
  "BRTR": {
    "relation": "Brother",
    "gender": "M",
  },
  "SIS": {
    "relation": "Sister",
    "gender": "F",
  },
  "GRFTH": {
    "relation": "Grand Father",
    "gender": "M",
  },
  "GRMTH": {
    "relation": "Grand Mother",
    "gender": "F",
  },
  "HUF": {
    "relation": "HUF",
    "gender": "M",
  },
  "SON": {
    "relation": "Son",
    "gender": "M",
  },
  "WIFE": {
    "relation": "Wife",
    "gender": "F",
  },
  "DGTR": {
    "relation": "Daughter",
    "gender": "F",
  },
  "HUSB": {
    "relation": "Husband",
    "gender": "M",
  },
  "O": {
    "relation": "Others",
    "gender": "M",
  },
  "CORP": {
    "relation": "Corporate",
    "gender": "M",
  },
  "JOINT": {
    "relation": "Joint",
    "gender": "M",
  }
};

class CloudflareContent {
  static const String creatives = 'creatives';
  static const String insuranceSalesPlan = 'insurance_sales_plan';
  static const String schemeCode = 'scheme_code';
}

class PartnerProfessionSubString {
  static const String mfd = 'mutual fund distributor';
  static const String bank = 'work in a bank';
  static const String caOrTaxConsultant = 'ca/tax consultant';
  static const String loanAdvisor = 'loan advisor';
  static const String insuranceAgent = 'insurance agent';
}

class RevenueFilterText {
  static const String productType = 'Product Type';
  static const String revenueType = 'Revenue Type';
  static const String revenueStatus = 'Revenue Status';
  static const String transactions = 'Transactions';
}

String getExitLoadUnitDescription(String exitLoadUnit) {
  switch (exitLoadUnit.toLowerCase()) {
    case 'd':
      return 'days';
    case 'm':
      return 'months';
    case 'y':
      return 'years';
    default:
      return '';
  }
}

String getExitLoadDescription(int? exitLoadTime, String? exitLoadUnit) {
  if (exitLoadTime == null || exitLoadUnit == null) {
    return '';
  }

  String exitLoadUnitDescription = getExitLoadUnitDescription(exitLoadUnit);

  return '$exitLoadTime $exitLoadUnitDescription';
}

List<String> webViewEnabledProductVariants = [
  InsuranceProductVariant.TWO_WHEELER,
  InsuranceProductVariant.FOUR_WHEELER,
  InsuranceProductVariant.HEALTH
];

String getCredilioStatusText(int? status) {
  // class CreditCardStatus(DjangoChoices):
  //   lead_submitted = ChoiceItem(1)
  //   lead_verified = ChoiceItem(2)
  //   lead_invalid = ChoiceItem(3)
  //   lead_expired = ChoiceItem(4)
  //   cards_offered = ChoiceItem(5)
  //   not_eligible = ChoiceItem(6)
  //   card_selected = ChoiceItem(7)
  //   application_incomplete = ChoiceItem(8)
  //   application_submitted = ChoiceItem(9)
  //   approved = ChoiceItem(10)
  //   aip_rejected = ChoiceItem(11)
  //   application_rejected = ChoiceItem(12)
  //   card_issued = ChoiceItem(13)
  //   application_expired = ChoiceItem(14)
  //   aip_in_progress = ChoiceItem(15)

  switch (status) {
    case 0:
      return '';
    case 1:
      return 'Lead Submitted';
    case 2:
      return 'Lead Verified';
    case 3:
      return 'Lead Invalid';
    case 4:
      return 'Lead Expired';
    case 5:
      return 'Cards Offered';
    case 6:
      return 'Not Eligible';
    case 7:
      return 'Card Selected';
    case 8:
      return 'Application Incomplete';
    case 9:
      return 'Application Submitted';
    case 10:
      return 'Approved';
    case 11:
      return 'AIP Rejected';
    case 12:
      return 'Application Rejected';
    case 13:
      return 'Card Issued';
    case 14:
      return 'Application Expired';
    case 15:
      return 'AIP In Progress';
    default:
      return '';
  }
}

String getBureauText(dynamic bureauScore) {
  // excellent = ChoiceItem(1)
  // fair = ChoiceItem(2)
  // good = ChoiceItem(3)
  // new_to_credit = ChoiceItem(4)
  // poor = ChoiceItem(5)
  // very_poor = ChoiceItem(6)

  // credilio response is giving bureauScore as string text only
  if (bureauScore is String) {
    return bureauScore.toString();
  }
  bureauScore = WealthyCast.toInt(bureauScore);
  // bureauScore in proposal listing extra json is of type int
  switch (bureauScore) {
    case 0:
      return notAvailableText;
    case 1:
      return 'Excellent';
    case 2:
      return 'Fair';
    case 3:
      return 'Good';
    case 4:
      return 'New to Credit';
    case 5:
      return 'Poor';
    case 6:
      return 'Very Poor';
    default:
      return notAvailableText;
  }
}

String getSchemeStatusDescription(String status) {
  switch (status.toLowerCase()) {
    case "p":
      return "Progress";
    case "f":
      return "Failure";
    case "s":
      return "Success";
    default:
      return '';
  }
}

Color getSchemeStatusColor(String status) {
  switch (status.toLowerCase()) {
    case "p":
      return ColorConstants.primaryAppColor;
    case "f":
      return ColorConstants.redAccentColor;
    case "s":
      return ColorConstants.greenAccentColor;
    default:
      return ColorConstants.primaryAppColor;
  }
}

String getServiceRequestStatusDescription(String status) {
  // Open: "O",
  // Closed: "C",
  // InProgress: "P",
  // Resolved: "R",
  // Duplicate: "D",
  // WaitingApproval: "W",
  // CustomerApproved: "A"

  switch (status.toUpperCase()) {
    case "O":
      return "Open";
    case "C":
      return "Closed";
    case "P":
      return "In Progress";
    case "R":
      return "Resolved";
    case "D":
      return "Duplicate";
    case "W":
      return "Waiting Approval";
    case "A":
      return "Customer Approved";
    default:
      return '';
  }
}

Map<String, String> bankAccountType = {
  "SB": "Saving",
  "CB": "Current",
  "NRE": "NRE",
  "NRO": "NRO"
};

String? getRelationshipStatus(String? relationship) {
  if (relationship == null || !(relationship.contains("_"))) {
    return null;
  }

  int? relationshipIndex = WealthyCast.toInt(relationship.split("_")[1]);

  return nomineeRelationships[relationshipIndex] ?? 'NA';
}

class PanUsageType {
  static const INDIVIDUAL = "INDIVIDUAL";
  static const GUARDIAN = "GUARDIAN";
  static const HUF = "HUF";
  static const JOINT = "JOINT";
  static const NONINDIVIDUAL = "NONINDIVIDUAL";
  static const INDIVIDUALNRE = "INDIVIDUAL_NRE";
  static const INDIVIDUALNRO = "INDIVIDUAL_NRO";
}

class PanUsageSubtype {
  static const NRI = "NRI";
  static const NON_NRI = "NON_NRI";
  static const HUF = "HUF";
  static const MINOR = "MINOR";
  static const DOUBLE_JOIN = "DOUBLE_JOIN";
  static const TRIPLE_JOIN = "TRIPLE_JOIN";
  static const LLP = "LLP";
  static const PVTLTD = "PVTLTD";
  static const TRUST = "TRUST";
  static const GOVT = "GOVT";
  static const PROPRIETORSHIP = "PROPRIETORSHIP";
  static const OTHER = "OTHER";
  static const BODY_CORPORATE = "BODY_CORPORATE";
}

String getPanUsageDescription(String? panType) {
  switch (panType) {
    case PanUsageSubtype.NRI:
      return "NRI";
    case PanUsageSubtype.NON_NRI:
      return "RESIDENT";
    case PanUsageSubtype.HUF:
      return "HUF";
    case PanUsageSubtype.MINOR:
      return "MINOR";
    case PanUsageSubtype.DOUBLE_JOIN:
      return "2 MEMBER";
    case PanUsageSubtype.TRIPLE_JOIN:
      return "3 MEMBER";
    case PanUsageSubtype.LLP:
      return "LLP";
    case PanUsageSubtype.PVTLTD:
      return "PVT LTD";
    case PanUsageSubtype.TRUST:
      return "TRUST";
    case PanUsageSubtype.GOVT:
      return "GOVT";
    case PanUsageSubtype.PROPRIETORSHIP:
      return "PROPRIETORSHIP";
    case PanUsageSubtype.OTHER:
      return "OTHER";
    case PanUsageSubtype.BODY_CORPORATE:
      return "BODY CORPORATE";
    case PanUsageType.INDIVIDUAL:
      return "INDIVIDUAL";
    case PanUsageType.GUARDIAN:
      return "GUARDIAN";
    case PanUsageType.JOINT:
      return "JOINT";
    case PanUsageType.NONINDIVIDUAL:
      return "NON INDIVIDUAL";
    case PanUsageType.INDIVIDUALNRE:
      return "INDIVIDUAL NRE";
    case PanUsageType.INDIVIDUALNRO:
      return "INDIVIDUAL NRO";
    default:
      return "";
  }
}

String getResidentialStatusLabel(String? accountType) {
  switch (accountType) {
    case PanUsageType.INDIVIDUAL:
      return "Residential Status";
    case PanUsageType.JOINT:
      return "No. of Members";
    case PanUsageType.NONINDIVIDUAL:
      return "Company Type";
  }
  return "Residential Status";
}

Map<String, dynamic> defaultTagsData = {
  "categories": [
    {"text": "Insurance", "tag": "tag_4RuzqcLCq2v"},
    {"text": "AIF & PMS", "tag": "tag_3RHd3qnMwNE"},
    {"text": "Festivals", "tag": "tag_WN4PpwH9iiC"},
    {"text": "FD", "tag": "tag_37uwhfwaUxn"},
    {"text": "Tax Saving", "tag": "tag_i9PhiyHSn9w"},
    {"text": "Bonds & Debentures", "tag": "tag_wWgbjfMmaNU"},
    {"text": "Retirement", "tag": "tag_VVvkKFo422J"},
    {"text": "Mutual Funds", "tag": "tag_3RqFQPvqEvM"},
    {"text": "SIP", "tag": "tag_3RKFbBtxUPk"},
    {"text": "NRI", "tag": "tag_kwiuP3mZZ4j"},
    {"text": "Wishes", "tag": "tag_3NRhwtsSn9K"},
    {"text": "NFOs", "tag": "tag_WAS4k4RtWQ5"},
    {"text": "IPOs", "tag": "tag_39M8pMj8JtF"}
  ],
  "languages": [
    {"text": "English", "tag": "tag_3Js65koCX6A"},
    {"text": "Hindi", "tag": "tag_JsFpN7g8Loj"},
    {"text": "Bengali", "tag": "tag_3FWsCC7QiFd"},
    {"text": "Tamil", "tag": "tag_ZfG68vfeS2g"},
    {"text": "Telugu", "tag": "tag_35JHph9orYC"},
    {"text": "Kannada", "tag": "tag_Ut83RG3T7hL"},
    {"text": "Malayalam", "tag": "tag_3Q2TKxiyBvr"},
    {"text": "Gujarati", "tag": "tag_gUZcJcjeZMY"},
    {"text": "Marathi", "tag": "tag_EtEwJzRvTxW"}
  ],
  "sales_kit_categories": [
    {"text": "Acquire Clients", "tag": "tag_dUz4P9ULd4i"},
    {"text": "Client Meetings", "tag": "tag_w54ZyHBHKWB"}
  ],
  "sales_kit_languages": [
    {"text": "English", "tag": "tag_HqznVA3XQ83"},
    {"text": "Bengali", "tag": "tag_gzSnkuTYKoi"},
    {"text": "Gujarati", "tag": "tag_BrDEwXPVmbB"},
    {"text": "Hindi", "tag": "tag_QXVK6YvYTKG"},
    {"text": "Kannada", "tag": "tag_2xKPWBDEzKH"},
    {"text": "Marathi", "tag": "tag_3bAq3w6JbRt"},
    {"text": "Tamil", "tag": "tag_u7o98qRUoBN"},
    {"text": "Telugu", "tag": "tag_qiBMcZGZhu6"}
  ]
};

class InvestmentStatus {
  static const String STARTONBOARDING = "Start Onboarding";
  static const String CLIENTDETAILINPROGRESS = "Processing";
  static const String WAITINGFORACTIVATION = "Waiting for Activation";
  static const String INVESTMENTREADY = "Investment Ready";
}

String getClientInvestmentStatusDescription(String? status) {
  switch (status) {
    case "STARTONBOARDING":
      return InvestmentStatus.STARTONBOARDING;
    case "CLIENTDETAILINPROGRESS":
      return InvestmentStatus.CLIENTDETAILINPROGRESS;
    case "WAITINGFORACTIVATION":
      return InvestmentStatus.WAITINGFORACTIVATION;
    case "INVESTMENTREADY":
      return InvestmentStatus.INVESTMENTREADY;
    default:
      return '-';
  }
}

const KraStatusTypes = {
  "-1": "",
  0: "Missing",
  1: "Initiated",
  2: "In Progress",
  3: "Submitted By Customer",
  4: "FollowUp With Customer",
  5: "Uploaded To Kra",
  6: "Approved",
  7: "Rejected By Kra",
  8: "Esign Pending",
  9: "Approved By Admin",
  10: "Rejected By Admin",
  11: "Validated By Kra",
  12: "Rejected By System",
};

// Partner Transactions
class TransactionOrderStatus {
  // mf transaction filter
  static const int Created = 0;
  static const int PaymentInitiated = 1;
  static const int PaymentSuccess = 2;
  static const int NavAllocated = 3;
  static const int Failure = 4;

  // insurance transaction filter
  static const String Active = 'active';
  static const String RevenueRelease = 'revenue_released';
  static const String Create = 'created';
  static const String Fail = 'failure';
}

String getTransactionOrderStatusText(dynamic status) {
  switch (status) {
    // mf transaction
    case TransactionOrderStatus.Created:
      return 'Created';
    case TransactionOrderStatus.PaymentInitiated:
      return 'Payment Initiated';
    case TransactionOrderStatus.PaymentSuccess:
      return 'Payment Success';
    case TransactionOrderStatus.NavAllocated:
      return 'Nav Allocated';
    case TransactionOrderStatus.Failure:
      return 'Failure';

    // insurance transaction
    case TransactionOrderStatus.Active:
      return 'Active';
    case TransactionOrderStatus.RevenueRelease:
      return 'Revenue Released';
    case TransactionOrderStatus.Create:
      return 'Created';
    case TransactionOrderStatus.Fail:
      return 'Failure';

    default:
      return '-';
  }
}

class TransactionSchemeStatus {
  static const String Failure = 'F';
  static const String Progress = 'P';
  static const String Success = 'S';
}

String getTransactionSchemeStatusText(String? status) {
  switch (status) {
    case TransactionSchemeStatus.Failure:
      return 'Failure';
    case TransactionSchemeStatus.Progress:
      return 'Progress';
    case TransactionSchemeStatus.Success:
      return 'Success';
    default:
      return '-';
  }
}

class TransactionOrderType {
  static const int Once = 1;
  static const int Sip = 2;
  static const int Switch = 3;
  static const int Swp = 4;
}

String getTransactionOrderTypeText(int? orderType) {
  switch (orderType) {
    case TransactionOrderType.Once:
      return 'Purchase';
    case TransactionOrderType.Sip:
      return 'Sip';
    case TransactionOrderType.Switch:
      return 'Switch';
    case TransactionOrderType.Swp:
      return 'Swp';
    default:
      return '-';
  }
}

class TransType {
  static const String Amount = 'A';
  static const String Units = 'U';
  static const String AllUnits = 'AU';
}

class TransactionSource {
  static const String Wealthy = 'W';
  static const String Outside = 'O';
  static const String ExternalSwitchIn = 'E';
  static const String FundMerge = 'F';
  static const String BrokerChange = 'B';
  static const String ArnTransfer = 'A';
}

String getTransactionSourceText(String? source) {
  switch (source) {
    case TransactionSource.Wealthy:
      return 'Wealthy';
    case TransactionSource.Outside:
      return 'Outside';
    case TransactionSource.ExternalSwitchIn:
      return 'External Switch In';
    case TransactionSource.FundMerge:
      return 'Fund Merge';
    case TransactionSource.BrokerChange:
      return 'Broker Change';
    case TransactionSource.ArnTransfer:
      return 'Arn Transfer';
    default:
      return '-';
  }
}

String getSipLastStatusDescription(String? status) {
  switch (status) {
    case "CR":
      return "Created";
    case "PR":
      return "Processing";
    case "OC":
      return "Order Created";
    case "OS":
      return "Order Success";
    case "POC":
      return "Partial Order Created";
    case "FL":
      return "Failed";
    case "PS":
      return "Paused";
    case "NAC":
      return "Nav Allocated";
    case "NA":
      return "Not Allocated";
    default:
      return "";
  }
}

Color getSipLastStatusTextColor(String? status) {
  switch (status) {
    case "CR":
      return ColorConstants.yellowAccentColor;
    case "PR":
      return ColorConstants.yellowAccentColor;
    case "OC":
      return ColorConstants.yellowAccentColor;
    case "OS":
      return ColorConstants.skyBlue;
    case "POC":
      return ColorConstants.skyBlue;
    case "FL":
      return ColorConstants.redAccentColor;
    case "PS":
      return ColorConstants.yellowAccentColor;
    case "NAC":
      return ColorConstants.greenAccentColor;
    case "NA":
      return ColorConstants.greyBlue;
    default:
      return ColorConstants.greyBlue;
  }
}

String getClientIdForHalfAgent() {
  return F.appFlavor == Flavor.DEV
      ? "78b89b86aefc10fcddbae2c55f33221c"
      : "04a0115593298658fca3b9949b81df2f";
}

final revenueProductMapping = <String, String>{
  'CreditCard': 'Credit Card',
  'MF': 'Mutual Fund',
  'PMS': 'PMS',
  'UnlistedStock': 'Unlisted Stock',
  'MLD': 'MLD',
  'Bonds': 'Bonds',
  'Alternates': 'Alternates',
  'FD': 'FD',
  'InvestmentMandateFee': 'Investment Mandate Fee',
  'NCD': 'NCD',
  'Term': 'Term',
  'Health': 'Health',
  'ULIP': 'ULIP',
  'Life': 'Life',
  'Traditional': 'Traditional',
  'Keyman': 'Keyman',
  'General': 'General',
  'InsuranceMandateFee': 'Insurance Mandate Fee',
  'Home': 'Home',
  'Loan': 'Loan',
  'LAP': 'LAP',
  'Personal': 'Personal',
  'Auto': 'Auto',
  'Business': 'Business',
  'LoanMandateFee': 'Loan Mandate Fee',
  'Savings': 'Savings',
  'Fourwheeler': 'Four wheeler',
  'Twowheeler': 'Two wheeler',
};

List<Map<String, String>> newsLetterTabs = [
  {
    "title": "Money Order",
    "description": "A weekly newsletter on the biggest economic trends",
    "image": AllImages().moneyOrderIcon,
    "content_type": "money-order",
  },
  {
    "title": "Bull’s Eye",
    "description": "A weekly newsletter on the stocks moving the market",
    "image": AllImages().bullsEyeIcon,
    "content_type": "bulls-eye",
  },
];

class RiskMeterDescription {
  static const low = "low";
  static const moderatelyLow = "moderately low";
  static const moderate = "moderate";
  static const moderatelyHigh = "moderately high";
  static const high = "high";
  static const veryHigh = "very high";
}

class ArnStatus {
  static const Pending = "P";
  static const Approved = "A";
  static const Rejected = "R";
}

class TaxStatus {
  static const indianResident = "INDIAN RESIDENT";
  static const nonResidentIndian = "NRI";
  static const nonIndividual = "NON INDIVIDUAL";

  static List<String> getAccountTypes(String taxStatus) {
    if (taxStatus == TaxStatus.indianResident) {
      return [
        AccountType.individual,
        AccountType.joint2Member,
        AccountType.joint3Member,
        AccountType.minor,
      ];
    }

    if (taxStatus == TaxStatus.nonResidentIndian) {
      return [
        AccountType.nro,
        AccountType.nre,
      ];
    }

    if (taxStatus == TaxStatus.nonIndividual) {
      return [
        AccountType.huf,
        AccountType.corporateLLP,
        AccountType.corporatePvtLtd,
        AccountType.trust,
        AccountType.corporateProprietorship,
        AccountType.govt,
        AccountType.other,
      ];
    }

    return [];
  }
}

class AccountType {
  static const individual = "INDIVIDUAL";
  static const joint2Member = "JOINT - 2 MEMBER";
  static const joint3Member = "JOINT - 3 MEMBER";
  static const minor = "MINOR";
  static const nro = "NRO";
  static const nre = "NRE";
  static const huf = "HUF";
  static const corporateLLP = "CORPORATE - LLP";
  static const corporatePvtLtd = "CORPORATE - PVT LTD";
  static const trust = "TRUST";
  static const corporateProprietorship = "CORPORATE - PROPRIETORSHIP";
  static const govt = "GOVT";
  static const other = "OTHER";

  static List<String> getPanPanSubtype(String accountType) {
    if (accountType == AccountType.individual) {
      return [PanUsageType.INDIVIDUAL, PanUsageSubtype.NON_NRI];
    }
    if (accountType == AccountType.joint2Member) {
      return [PanUsageType.JOINT, PanUsageSubtype.DOUBLE_JOIN];
    }
    if (accountType == AccountType.joint3Member) {
      return [PanUsageType.JOINT, PanUsageSubtype.TRIPLE_JOIN];
    }

    if (accountType == AccountType.minor) {
      return [PanUsageType.GUARDIAN, PanUsageSubtype.MINOR];
    }

    if (accountType == AccountType.nro) {
      return [PanUsageType.INDIVIDUALNRO, PanUsageSubtype.NRI];
    }
    if (accountType == AccountType.nre) {
      return [PanUsageType.INDIVIDUALNRE, PanUsageSubtype.NRI];
    }
    if (accountType == AccountType.huf) {
      return [PanUsageType.HUF, PanUsageSubtype.HUF];
    }

    if (accountType == AccountType.corporateLLP) {
      return [PanUsageType.NONINDIVIDUAL, PanUsageSubtype.LLP];
    }

    if (accountType == AccountType.corporatePvtLtd) {
      return [PanUsageType.NONINDIVIDUAL, PanUsageSubtype.PVTLTD];
    }
    if (accountType == AccountType.trust) {
      return [PanUsageType.NONINDIVIDUAL, PanUsageSubtype.TRUST];
    }
    if (accountType == AccountType.corporateProprietorship) {
      return [PanUsageType.NONINDIVIDUAL, PanUsageSubtype.PROPRIETORSHIP];
    }
    if (accountType == AccountType.govt) {
      return [PanUsageType.NONINDIVIDUAL, PanUsageSubtype.GOVT];
    }
    if (accountType == AccountType.other) {
      return [PanUsageType.NONINDIVIDUAL, PanUsageSubtype.OTHER];
    }

    return [];
  }

  static String getTaxStatusAccountType({
    required String panUsagetype,
    required String panUsageSubtype,
    required bool taxStatus,
    required bool accountType,
  }) {
    if (panUsagetype == PanUsageType.INDIVIDUAL &&
        panUsageSubtype == PanUsageSubtype.NON_NRI) {
      return accountType ? AccountType.individual : TaxStatus.indianResident;
    }

    if (panUsagetype == PanUsageType.JOINT &&
        panUsageSubtype == PanUsageSubtype.DOUBLE_JOIN) {
      return accountType ? AccountType.joint2Member : TaxStatus.indianResident;
    }
    if (panUsagetype == PanUsageType.JOINT &&
        panUsageSubtype == PanUsageSubtype.TRIPLE_JOIN) {
      return accountType ? AccountType.joint3Member : TaxStatus.indianResident;
    }

    if (panUsagetype == PanUsageType.GUARDIAN &&
        panUsageSubtype == PanUsageSubtype.MINOR) {
      return accountType ? AccountType.minor : TaxStatus.indianResident;
    }

    if (panUsagetype == PanUsageType.INDIVIDUALNRE &&
        panUsageSubtype == PanUsageSubtype.NRI) {
      return accountType ? AccountType.nre : TaxStatus.nonResidentIndian;
    }
    if (panUsagetype == PanUsageType.INDIVIDUALNRO &&
        panUsageSubtype == PanUsageSubtype.NRI) {
      return accountType ? AccountType.nro : TaxStatus.nonResidentIndian;
    }

    if (panUsagetype == PanUsageType.HUF &&
        panUsageSubtype == PanUsageSubtype.HUF) {
      return accountType ? AccountType.huf : TaxStatus.nonIndividual;
    }

    if (panUsagetype == PanUsageType.NONINDIVIDUAL) {
      if (panUsageSubtype == PanUsageSubtype.LLP) {
        return accountType ? AccountType.corporateLLP : TaxStatus.nonIndividual;
      }
      if (panUsageSubtype == PanUsageSubtype.PVTLTD) {
        return accountType
            ? AccountType.corporatePvtLtd
            : TaxStatus.nonIndividual;
      }
      if (panUsageSubtype == PanUsageSubtype.TRUST) {
        return accountType ? AccountType.trust : TaxStatus.nonIndividual;
      }
      if (panUsageSubtype == PanUsageSubtype.PROPRIETORSHIP) {
        return accountType
            ? AccountType.corporateProprietorship
            : TaxStatus.nonIndividual;
      }
      if (panUsageSubtype == PanUsageSubtype.GOVT) {
        return accountType ? AccountType.govt : TaxStatus.nonIndividual;
      }
      if (panUsageSubtype == PanUsageSubtype.OTHER) {
        return accountType ? AccountType.other : TaxStatus.nonIndividual;
      }
    }

    return '-';
  }

  static String getInvestorType(String accountType) {
    if (accountType == AccountType.individual) {
      return 'INDIVIDUAL';
    }
    if (accountType == AccountType.joint2Member) {
      return 'JOINT';
    }
    if (accountType == AccountType.joint3Member) {
      return 'JOINT';
    }
    if (accountType == AccountType.minor) {
      return 'MINOR';
    }
    if (accountType == AccountType.nre) {
      return 'INDIVIDUAL_NRE';
    }
    if (accountType == AccountType.nro) {
      return 'INDIVIDUAL_NRO';
    }
    if (accountType == AccountType.huf) {
      return 'HUF';
    }
    if (accountType == AccountType.corporateLLP) {
      return 'LLP';
    }

    if (accountType == AccountType.corporatePvtLtd) {
      return 'PVTLTD';
    }
    if (accountType == AccountType.trust) {
      return 'TRUST';
    }
    if (accountType == AccountType.corporateProprietorship) {
      return 'PROPRIETORSHIP';
    }
    if (accountType == AccountType.govt) {
      return 'GOVT';
    }

    if (accountType == AccountType.other) {
      return 'OTHER';
    }

    return '';
  }
}

class FeatureFlag {
  static const String partnerBrandingSection = 'partner_branding_section';
  static const String portfolioReviewSection = 'portfolio_review_section';
}

const Map<String, String> amcLogoMapping = {
  'old bridge': 'https://i.wlycdn.com/amc-logos/old-bridge.png',
  'bank of india': 'https://i.wlycdn.com/amc-logos/boi.png'
};

// Mapping between route name & page name
final routePageNameMap = {
  ResourcesRoute.name: 'Poster Gallery',
};

// Mapping between ntype & page name
final nTypePageNameMap = {
  'resources': 'Sales Kit',
  'creatives': 'Poster Gallery'
};

// Mapping between quick action name & route name
final quickActionNameMap = {
  'posters': 'Poster Gallery',
  'resources': 'Sales Kit'
};
