class AppRouteName {
  //Splash
  static const String splashScreen = '/splash';

  //Lock
  static const String lockScreen = '/lock';

  //WebView
  static const String webviewScreen = '/web-view';
  static const String creditCardWebviewScreen = '/credit-card-web-view';

  // Network Offline
  static const String networkOfflineScreen = '/network-offline';

  //Authentication
  static const String authenticationScreen = '/authentication';
  static const String registerScreen = '/register';
  static const String signInPhoneScreen = '/login-phone';
  static const String signInEmailScreen = '/login-email';
  static const String loginHalfAgentScreen = '/login-half-agent';
  static const String verifyOtpScreen = '/verify-otp';
  static const String forgotPasswordWebViewScreen = '/forgot-password';
  static const String insuranceWebViewScreen = '/insurance-webview';
  static const String getStartedScreen = '/get-started';
  static const String verifyLoginOtpScreen = '/verify-login-otp';
  static const String verifySignupOtpScreen = '/verify-signup-otp';

  //Onboarding
  static const String onboardingQuestionScreen = '/onboarding';
  static const String storeOnboardingScreen = '/onboarding/store';
  static const String onboardingQuestionSuccessScreen = '/onboarding/sucess';
  static const String videoScreen = '/advisor-video/:videoId';

  //KYC
  static const String completeKycScreen = '/complete-kyc';
  static const String kycStatusScreen = '/kyc/status';
  static const String arnRegisterationScreen = '/kyc/arn-registeration';
  static const String arnDetectedScreen = '/kyc/arn-detected';
  static const String arnNotDetectedScreen = '/kyc/arn-not-detected';
  // static const String kycWebViewScreen = '/kyc/web-view';

  //Rewards
  static const String rewardScreen = '/rewards';
  static const String rewardSuccessScreen = '/rewards/success';
  static const String rewardTransactionLogScreen = '/rewards/logs';
  static const String rewardDetailScreen = '/rewards/:rewardId';
  static const String rewardCompletedScreen = '/rewards/completed';
  static const String redeemScreen = '/rewards/redeem';
  static const String redemptionStatusScreen = '/rewards/redeem/status';

  //Home
  static const String baseScreen = '/base';
  static const String notificationScreen = '/notifications';
  static const String profileScreen = '/profile';
  static const String brandingScreen = '/profile/branding';
  static const String profileUpdateScreen = '/profile/update';

  static const String partnerNomineeScreen = '/nominee';
  static const String quickActionEditScreen = '/quick-action/edit';
  static const String quickActionListScreen = '/quick-action';
  static const String successScreen = '/success';
  static const String universalSearchScreen = '/universal-search';
  static const String empanelmentScreen = '/empanelment';

  static const String partnerVerificationScreen = '/partner-verification';
  static const String changeDisplayNameScreen = '/profile/change-display-name';
  static const String partnerEmailAddScreen = '/profile/new-email';
  static const String partnerEmailVerifyScreen = '/profile/new-email/verify';

  static const String storyScreen = '/story';
  static const String reportScreen = '/report';
  static const String reportFormScreen = '/report/form';
  static const String reportDownloadScreen = '/report/download';

  // Advisor
  static const String sipBookScreen = '/sip-book';
  static const String payoutScreen = '/payout';
  static const String payoutDetailScreen = '/payout/detail';
  static const String payoutEmployeeScreen = '/payout/employee';
  static const String revenueSheetScreen = '/revenue-sheet';
  static const String revenueSheetDetailScreen = '/revenue-sheet/detail';

  //Proposals
  static const String proposalListScreen = '/proposals';
  static const String proposalDetailsScreen = '/proposals/detail/:proposalId';
  static const String deleteProposalScreen = '/proposals/delete';
  static const String proposalCreatedSuccessScreen = '/proposals/success';
  static const String preIpoSuccessScreen = '/proposals/pre-ipo-success';

  static const String transactionsScreen = '/transactions';

  static const String mfTransactionDetailScreen = '/transactions/mf/detail';

  //Clients
  static const String clientListScreen = '/clients';
  static const String topUpPortfolioScreen = '/clients/top-up-portfolios';
  static const String addClientScreen = '/clients/add';
  static const String searchContactsScreen = '/clients/add/contacts';
  static const String addClientFamilyCRNScreen = '/clients/add-family-crn';
  static const String addClientFamilyDetailScreen =
      '/clients/add-family-detail';
  static const String addClientFamilySuccessScreen =
      '/clients/add-family/success';
  static const String addClientFamilyVerificationScreen =
      '/clients/add-family/verify';
  static const String addClientFamilyCRNSearchScreen =
      '/clients/add-family/search-crn';

  static const String clientDetailScreen = '/client/detail/:clientId';
  static const String clientGoalScreen = '/client/detail/goal';
  static const String clientGoalOrderSuccessScreen =
      '/client/detail/goal/order-success';
  static const String clientWithdrawalScreen = '/client/detail/withdrawal';
  static const String clientSWPScreen = '/client/detail/swp';
  static const String clientSWPDetailScreen = '/client/detail/swp/detail';
  static const String clientEditSWPScreen = '/client/detail/swp/edit';
  static const String clientStpScreen = '/client/detail/stp';
  static const String clientEditStpScreen = '/client/detail/stp/edit';
  static const String clientStpDetailScreen = '/client/detail/stp-detail';
  static const String clientSwitchOrderScreen = '/client/detail/switch-order';
  static const String clientWithdrawalSuccessScreen =
      '/client/detail/withdrawal/success';
  static const String clientSchemeTransactionsScreen =
      '/client/detail/goal/scheme-transactions';
  static const String clientInvestmentPortfolioListScreen =
      '/client/detail/portfolios-list';
  static const String clientInvestmentProductListScreen =
      '/client/detail/product-list';
  static const String clientEditAllocationScreen =
      '/client/detail/edit-allocation';

  static const String clientTrackerSwitchScreen = '/client/tracker/switch';
  static const String mfInvestmentListScreen = '/client/detail/mf-investment';
  static const String bankDetailsFormScreen = '/client/details/bank-form';
  static const String clientTrackerScreen = '/client/tracker';
  static const String clientReportScreen = '/client/report';
  static const String sipDetailScreen = '/client/sip/detail';
  static const String editSipFormScreen = '/client/sip/edit';
  static const String editSipSummaryScreen = '/client/sip/edit/summary';
  static const String clientFamilyDetailScreen = '/client/family';
  static const String clientDematScreen = '/client/demat';
  static const String clientUpdateDematScreen = '/client/demat/update';
  static const String clientAddressScreen = '/client/address';
  static const String addEditClientAddressScreen = '/client/address/update';

  // Client Profile
  static const String clientProfileScreen = '/client/profile';
  static const String clientPersonalFormScreen = '/client/personal';
  static const String clientNomineeScreen = '/client/nominee';
  static const String clientNomineeBreakdownScreen =
      '/client/nominee/breakdown';
  static const String clientNomineeFormScreen = '/client/nominee/form';
  static const String clientBankAccountScreen = '/client/bank';
  static const String clientMandateScreen = '/client/mandate';
  static const String clientBankFormScreen = '/client/bank/form';

  //Tracker
  static const String trackerListScreen = '/tracker';
  static const String sendTrackerRequestScreen = '/tracker/send';
  static const String trackerRequestSuccessScreen = '/tracker/success';

  //Demats
  static const String dematScreen = '/demats';
  static const String addDematScreen = '/demats/add';

  //Store
  static const String storeScreen = '/store';

  static const String storeDematScreen = '/store/demat';
  static const String storeSgbScreen = '/store/sgb';
  static const String dematSelectClientScreen = '/store/demat/select-client';
  static const String dematOverviewScreen = '/store/demat/overview';
  static const String dematProposalSuccessScreen =
      '/store/demat/proposal-success';

  static const String proposalSuccessScreen = '/store/success-new';

  static const String fundListScreen = '/store/funds';
  static const String mfListOldScreen = '/store/mf-list';
  static const String mfLobbyScreen = '/store/mf-lobby';
  static const String mfListScreen = '/store/mf';
  static const String topFundsNfoScreen = '/store/nfo';
  static const String curatedFundsScreen = '/store/curated-funds';
  static const String nfoDetailScreen = '/store/nfo/detail/:wschemecode';
  static const String fundDetailScreen = '/store/funds/detail/:wschemecode';
  static const String sifScreen = '/store/sif';
  static const String sifDetailScreen = '/store/sif/detail/:isin';

  static const String fixedDepositListScreen = '/store/fd';
  static const String fixedDepositOfflineListScreen = '/store/fd/offline';

  static const String preIPOListScreen = '/store/unlistedstock';
  static const String preIPODetailScreen = '/store/unlistedstock/detail';
  static const String preIPOFormScreen = '/store/unlistedstock/form';
  static const String preIPOReviewProposalScreen =
      '/store/unlistedstock/review';

  static const String debentureListScreen = '/store/debentures';
  static const String debentureDetailScreen = '/store/debentures/detail';
  static const String debentureReviewScreen = '/store/debentures/review';

  static const String mfPortfolioListScreen = '/store/portfolios';
  static const String mfPortfolioDetailScreen = '/store/portfolios/detail';
  static const String mfPortfolioFormScreen = '/store/portfolios/form';
  static const String mfPortfolioSubtypeListScreen =
      '/store/portfolios/:goalType';
  static const String orderSummaryScreen = '/store/portfolio/summary';

  static const String pmsProviderListScreen = '/store/pms';
  static const String pmsProductListScreen = '/store/pms/product';
  static const String pmsProductDetailScreen = '/store/pms/product/detail';
  static const String pmsTncScreen = '/store/pms/product/detail/tnc';

  static const String creditCardListScreen = '/store/credit-cards';
  static const String creditCardProposalDetailScreen =
      '/store/credit-cards/proposal/detail';

  static const String insuranceListScreen = '/store/insurance';
  static const String insuranceDetailScreen =
      '/store/insurance/:productVariant';
  static const String insuranceGenerateQuotesScreen =
      '/store/insurance/generate-quotes/:productVariant';

  static const String selectClientScreen = '/store/select-client';
  static const String clientFamilyScreen = '/store/client-family';
  static const String productDetailsLoaderScreen =
      '/store/product-details-loader';

  static const String faqScreen = '/faq';
  static const String supportScreen = '/support';

  // Wealth Academy
  static const String wealthAcademyScreen = '/wealth-academy';
  static const String salesPlanUnboxScreen = '/sales-plan-unbox';
  static const String eventsListScreen = '/wealth-academy/events';
  // static const String eventsListScreen = '/events';
  static const String eventDetailScreen = '/events/:eventScheduleId';
  static const String wealthAcademyPlaylistScreen =
      '/wealth-academy/playlist/:playlistId';

  static const String registerEmailScreen = '/register-email';
  static const String verifyEmailScreen = '/verify-email';
  static const String basketOverviewScreen = '/basket-overview';
  static const String basketEditFundScreen = '/basket-overview/edit';
  static const String switchBasketScreen = '/switch-basket-screen';

  static const String contactRMBottomSheetScreen = '/contact-rmbottom-sheet';
  static const String creativesScreen = '/creatives';
  static const String resourcesScreen = '/resources';

  static const String appUpdateScreen = '/update';
  static const String insuranceHomeScreen = '/insurance-home';
  static const String salesPlanScreen = '/sales-plan/:salesPlanId';
  static const String salesPlanGalleryListScreen = '/sales-plan/gallery';
  static const String salesPlanPlayerScreen = '/sales-plan/player';

  // My Team
  static const String myTeamScreen = '/my-team';
  static const String existingTeamMemberFormScreen = '/my-team/add/existing';
  static const String newTeamMemberFormScreen = '/my-team/add/new';
  static const String verifyTeamMemberOtpScreen = '/my-team/add/verify';
  static const String createTeamFormScreen = '/my-team/create';

  // Broking
  static const String brokingScreen = '/broking';
  static const String brokingOnboardingScreen = '/broking/onboarding';
  static const String brokingActivityScreen = '/broking/activity';

  static const String businessReportTemplateScreen = '/business-report';
  static const String businessReportGenerateScreen =
      '/business-report/generate';

  static const String myBusinessScreen = '/my-business';

  static const String soaDownloadScreen = '/soa-download';
  static const String soaFolioListScreen = '/soa-download/folio-list';

  // Change of Broker
  static const String ticobScreen = '/ticob';
  static const String ticobFolioScreen = '/ticob/folio';
  static const String generateCobOptionScreen = '/ticob/generate/option';
  static const String generateCobSuccessScreen = '/ticob/generate/success';

  // NewsLetter
  static const String newsLetterScreen = '/newsletter';
  static const String newsLetterDetailScreen = '/newsletter/:newsLetterId';

  static const String referralScreen = '/referral';
  static const String referralRewardsFaqTermScreen = '/referral/faq-terms';

  static const String birthdayScreen = '/birthday';
  static const String birthdayWishScreen = '/birthday/wish';

  static const String chooseClientScreen = '/choose-client/:type';

  static const String clientPortfolioReviewScreen = '/client/portfolio-review';

  static const String calculatorScreen = '/calculator';
  static const String calculatorAppViewScreen = '/calculator/app-view';

  static const String wealthCaseScreen = '/wealthcase';
  static const String wealthCaseAboutScreen = '/wealthcase/about';
  static const String wealthCaseDetailScreen = '/wealthcase/detail/:basketId';
}
