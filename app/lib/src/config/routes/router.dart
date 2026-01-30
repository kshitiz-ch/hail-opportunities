import 'package:app/src/config/routes/insurance_redirect_guard.dart';
import 'package:app/src/config/routes/route_name.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@AutoRouterConfig()
class RootRouter extends RootStackRouter {
  RootRouter(GlobalKey<NavigatorState>? navigatorKey)
      : super(navigatorKey: navigatorKey);

  List<AutoRoute> get routes => [
        AutoRoute(
          page: SplashRoute.page,
          path: AppRouteName.splashScreen,
          initial: true,
        ),
        AutoRoute(
          page: NetworkOfflineRoute.page,
          path: AppRouteName.networkOfflineScreen,
        ),
        AutoRoute(
            page: KycStatusRoute.page, path: AppRouteName.kycStatusScreen),
        AutoRoute(page: WebViewRoute.page, path: AppRouteName.webviewScreen),
        CustomRoute(
          page: CreditCardWebViewRoute.page,
          path: AppRouteName.creditCardWebviewScreen,
          transitionsBuilder: TransitionsBuilders.slideBottom,
        ),
        AutoRoute(
            page: NotificationRoute.page,
            path: AppRouteName.notificationScreen),
        AutoRoute(
            page: UniversalSearchRoute.page,
            path: AppRouteName.universalSearchScreen),
        // AutoRoute(
        //     page: CompleteKycRoute.page, path: AppRouteName.completeKycScreen),
        // AutoRoute(
        //     page: EmpanelmentRoute.page, path: AppRouteName.empanelmentScreen),
        AutoRoute(
            page: RewardSuccessRoute.page,
            path: AppRouteName.rewardSuccessScreen),
        AutoRoute(page: RewardsRoute.page, path: AppRouteName.rewardScreen),

        AutoRoute(page: BaseRoute.page, path: AppRouteName.baseScreen),
        AutoRoute(
            page: OnboardingQuestionsRoute.page,
            path: AppRouteName.onboardingQuestionScreen),
        AutoRoute(
            page: SendTrackerRequestRoute.page,
            path: AppRouteName.sendTrackerRequestScreen),
        AutoRoute(page: StoreRoute.page, path: AppRouteName.storeScreen),
        AutoRoute(
            page: TopUpPortfoliosRoute.page,
            path: AppRouteName.topUpPortfolioScreen),
        AutoRoute(
            page: TrackerRequestSuccessRoute.page,
            path: AppRouteName.trackerRequestSuccessScreen),
        AutoRoute(
            page: ProposalListRoute.page,
            path: AppRouteName.proposalListScreen),

        // Client Profile
        AutoRoute(
          page: ClientProfileRoute.page,
          path: AppRouteName.clientProfileScreen,
        ),
        AutoRoute(
          page: ChangeDisplayNameRoute.page,
          path: AppRouteName.changeDisplayNameScreen,
        ),
        AutoRoute(
          page: ClientPersonalFormRoute.page,
          path: AppRouteName.clientPersonalFormScreen,
        ),
        AutoRoute(
          page: ClientNomineeListRoute.page,
          path: AppRouteName.clientNomineeScreen,
        ),
        AutoRoute(
          page: ClientNomineeBreakdownRoute.page,
          path: AppRouteName.clientNomineeBreakdownScreen,
        ),
        AutoRoute(
          page: ClientNomineeFormRoute.page,
          path: AppRouteName.clientNomineeFormScreen,
        ),
        AutoRoute(
          page: ClientBankListRoute.page,
          path: AppRouteName.clientBankAccountScreen,
        ),
        AutoRoute(
          page: ClientMandateListRoute.page,
          path: AppRouteName.clientMandateScreen,
        ),
        AutoRoute(
          page: ClientBankFormRoute.page,
          path: AppRouteName.clientBankFormScreen,
        ),

        AutoRoute(
            page: MfInvestmentListRoute.page,
            path: AppRouteName.mfInvestmentListScreen),
        AutoRoute(
            page: ProductInvestmentListRoute.page,
            path: AppRouteName.clientInvestmentProductListScreen),
        AutoRoute(
            page: BankDetailsFormRoute.page,
            path: AppRouteName.bankDetailsFormScreen),
        AutoRoute(
            page: AddClientRoute.page, path: AppRouteName.addClientScreen),
        AutoRoute(
            page: SearchContactsRoute.page,
            path: AppRouteName.searchContactsScreen),
        AutoRoute(page: DematsRoute.page, path: AppRouteName.dematScreen),
        // AutoRoute(page: KYCWebviewRoute.page, path: AppRouteName.kycWebViewScreen),

        AutoRoute(page: ProfileRoute.page, path: AppRouteName.profileScreen),
        AutoRoute(
            page: ProfileUpdateRoute.page,
            path: AppRouteName.profileUpdateScreen),

        AutoRoute(page: SipBookRoute.page, path: AppRouteName.sipBookScreen),
        AutoRoute(page: PayoutRoute.page, path: AppRouteName.payoutScreen),
        AutoRoute(
            page: PayoutDetailRoute.page,
            path: AppRouteName.payoutDetailScreen),
        AutoRoute(
            page: EmployeePayoutRoute.page,
            path: AppRouteName.payoutEmployeeScreen),
        AutoRoute(
            page: RevenueSheetRoute.page,
            path: AppRouteName.revenueSheetScreen),
        AutoRoute(
            page: RevenueSheetDetailRoute.page,
            path: AppRouteName.revenueSheetDetailScreen),
        AutoRoute(
            page: ReportTemplateRoute.page, path: AppRouteName.reportScreen),
        AutoRoute(
            page: ReportFormRoute.page, path: AppRouteName.reportFormScreen),
        AutoRoute(
            page: ReportDownloadRoute.page,
            path: AppRouteName.reportDownloadScreen),
        AutoRoute(
            page: RewardsDetailsRoute.page,
            path: AppRouteName.rewardDetailScreen),

        AutoRoute(page: FundListRoute.page, path: AppRouteName.fundListScreen),
        AutoRoute(page: MfLobbyRoute.page, path: AppRouteName.mfLobbyScreen),
        AutoRoute(
            page: CuratedFundsRoute.page,
            path: AppRouteName.curatedFundsScreen),
        AutoRoute(
            page: NfoDetailRoute.page, path: AppRouteName.nfoDetailScreen),
        AutoRoute(page: MfListRoute.page, path: AppRouteName.mfListScreen),
        AutoRoute(
            page: TopFundsNfoRoute.page, path: AppRouteName.topFundsNfoScreen),
        AutoRoute(page: SifListRoute.page, path: AppRouteName.sifScreen),
        AutoRoute(
            page: SifDetailRoute.page, path: AppRouteName.sifDetailScreen),
        AutoRoute(
            page: MfPortfolioDetailRoute.page,
            path: AppRouteName.mfPortfolioDetailScreen),
        AutoRoute(
            page: PreIpoDetailRoute.page,
            path: AppRouteName.preIPODetailScreen),
        AutoRoute(
            page: DebentureDetailRoute.page,
            path: AppRouteName.debentureDetailScreen),
        AutoRoute(
            page: SelectClientRoute.page,
            path: AppRouteName.selectClientScreen),
        AutoRoute(
            page: FundDetailRoute.page, path: AppRouteName.fundDetailScreen),
        AutoRoute(
            page: TrackerListRoute.page, path: AppRouteName.trackerListScreen),
        AutoRoute(page: FaqRoute.page, path: AppRouteName.faqScreen),
        AutoRoute(page: SupportRoute.page, path: AppRouteName.supportScreen),
        AutoRoute(
            page: StoreOnboardingRoute.page,
            path: AppRouteName.storeOnboardingScreen),
        AutoRoute(
            page: ProposalDetailsRoute.page,
            path: AppRouteName.proposalDetailsScreen),
        AutoRoute(
            page: ProposalSuccessRoute.page,
            path: AppRouteName.proposalSuccessScreen),
        AutoRoute(page: RedeemRoute.page, path: AppRouteName.redeemScreen),
        AutoRoute(
            page: RedemptionStatusRoute.page,
            path: AppRouteName.redemptionStatusScreen),
        AutoRoute(
            page: MfPortfolioListRoute.page,
            path: AppRouteName.mfPortfolioListScreen),

        AutoRoute(
            page: DebentureReviewRoute.page,
            path: AppRouteName.debentureReviewScreen),
        AutoRoute(page: AddDematRoute.page, path: AppRouteName.addDematScreen),
        AutoRoute(
            page: MfPortfolioFormRoute.page,
            path: AppRouteName.mfPortfolioFormScreen),
        AutoRoute(
            page: MfPortfolioSubtypeListRoute.page,
            path: AppRouteName.mfPortfolioSubtypeListScreen),
        AutoRoute(
            page: PmsProductDetailRoute.page,
            path: AppRouteName.pmsProductDetailScreen),
        AutoRoute(
            page: PmsProductListRoute.page,
            path: AppRouteName.pmsProductListScreen),
        AutoRoute(
            page: PreIpoFormRoute.page, path: AppRouteName.preIPOFormScreen),
        AutoRoute(
            page: PreIpoReviewProposalRoute.page,
            path: AppRouteName.preIPOReviewProposalScreen),

        AutoRoute(
            page: ClientFamilyRoute.page,
            path: AppRouteName.clientFamilyScreen),
        AutoRoute(
            page: InsuranceListRoute.page,
            path: AppRouteName.insuranceListScreen),
        AutoRoute(
            page: PmsProviderListRoute.page,
            path: AppRouteName.pmsProviderListScreen),
        AutoRoute(page: PmsTncRoute.page, path: AppRouteName.pmsTncScreen),
        AutoRoute(
            page: PreIpoListRoute.page, path: AppRouteName.preIPOListScreen),
        AutoRoute(page: SgbRoute.page, path: AppRouteName.storeSgbScreen),
        AutoRoute(
            page: DematStoreRoute.page, path: AppRouteName.storeDematScreen),
        AutoRoute(
            page: DematSelectClientRoute.page,
            path: AppRouteName.dematSelectClientScreen),
        AutoRoute(
            page: DematOverviewRoute.page,
            path: AppRouteName.dematOverviewScreen),
        AutoRoute(
            page: DematProposalSuccessRoute.page,
            path: AppRouteName.dematProposalSuccessScreen),
        AutoRoute(
            page: FixedDepositListRoute.page,
            path: AppRouteName.fixedDepositListScreen),
        AutoRoute(
            page: FixedDepositOfflineListRoute.page,
            path: AppRouteName.fixedDepositOfflineListScreen),

        AutoRoute(
          page: CreditCardHomeRoute.page,
          path: AppRouteName.creditCardListScreen,
        ),
        AutoRoute(
          page: CreditCardProposalDetailRoute.page,
          path: AppRouteName.creditCardProposalDetailScreen,
        ),
        AutoRoute(
            page: DebentureListRoute.page,
            path: AppRouteName.debentureListScreen),
        AutoRoute(
            page: ProductDetailsLoaderRoute.page,
            path: AppRouteName.productDetailsLoaderScreen),
        AutoRoute(
            page: ClientDetailRoute.page,
            path: AppRouteName.clientDetailScreen),

        // Client Goal Features
        // ====================
        AutoRoute(
            page: ClientGoalRoute.page, path: AppRouteName.clientGoalScreen),
        AutoRoute(
            page: GoalOrderSuccessRoute.page,
            path: AppRouteName.clientGoalOrderSuccessScreen),
        AutoRoute(
            page: ClientWithdrawalRoute.page,
            path: AppRouteName.clientWithdrawalScreen),
        AutoRoute(
            page: ClientSwpRoute.page, path: AppRouteName.clientSWPScreen),
        AutoRoute(
            page: SwpDetailRoute.page,
            path: AppRouteName.clientSWPDetailScreen),
        AutoRoute(
            page: EditSwpRoute.page, path: AppRouteName.clientSWPDetailScreen),
        AutoRoute(
            page: ClientStpRoute.page, path: AppRouteName.clientStpScreen),
        AutoRoute(
            page: StpDetailRoute.page,
            path: AppRouteName.clientStpDetailScreen),
        AutoRoute(
            page: EditStpFormRoute.page,
            path: AppRouteName.clientEditStpScreen),
        AutoRoute(
            page: ClientSwitchOrderRoute.page,
            path: AppRouteName.clientSwitchOrderScreen),
        AutoRoute(
            page: ClientWithdrawalSuccessRoute.page,
            path: AppRouteName.clientWithdrawalSuccessScreen),

        AutoRoute(
            page: ClientSchemeTransactionsRoute.page,
            path: AppRouteName.clientSchemeTransactionsScreen),
        AutoRoute(
            page: OrderSummaryRoute.page,
            path: AppRouteName.orderSummaryScreen),
        AutoRoute(
            page: ClientListRoute.page, path: AppRouteName.clientListScreen),
        AutoRoute(page: StoryRoute.page, path: AppRouteName.storyScreen),
        AutoRoute(
            page: OnboardingQuestionsSuccessRoute.page,
            path: AppRouteName.onboardingQuestionSuccessScreen),
        AutoRoute(
            page: GetStartedRoute.page, path: AppRouteName.getStartedScreen),
        AutoRoute(page: SignUpRoute.page, path: AppRouteName.registerScreen),
        AutoRoute(
            page: SignInEmailRoute.page, path: AppRouteName.signInEmailScreen),
        AutoRoute(
            page: SignInWithPhoneRoute.page,
            path: AppRouteName.signInPhoneScreen),
        AutoRoute(
            page: VerifyLoginOtpRoute.page,
            path: AppRouteName.verifyLoginOtpScreen),
        AutoRoute(
            page: LoginHalfAgentRoute.page,
            path: AppRouteName.loginHalfAgentScreen),
        AutoRoute(
            page: VerifySignUpOtpRoute.page,
            path: AppRouteName.verifySignupOtpScreen),
        AutoRoute(page: VideoRoute.page, path: AppRouteName.videoScreen),
        AutoRoute(page: SuccessRoute.page, path: AppRouteName.successScreen),
        AutoRoute(
            page: InsuranceWebViewRoute.page,
            path: AppRouteName.insuranceWebViewScreen),
        AutoRoute(
            page: ForgotPasswordWebViewRoute.page,
            path: AppRouteName.forgotPasswordWebViewScreen),
        AutoRoute(
            page: PartnerVerificationRoute.page,
            path: AppRouteName.partnerVerificationScreen),
        AutoRoute(
            page: PartnerNomineeRoute.page,
            path: AppRouteName.partnerNomineeScreen),
        AutoRoute(
            page: PartnerEmailAddRoute.page,
            path: AppRouteName.partnerEmailAddScreen),
        AutoRoute(
            page: PartnerEmailVerifyRoute.page,
            path: AppRouteName.partnerEmailVerifyScreen),
        AutoRoute(
            page: SalesPlanUnboxRoute.page,
            path: AppRouteName.salesPlanUnboxScreen),
        AutoRoute(
            page: WealthAcademyRoute.page,
            path: AppRouteName.wealthAcademyScreen),
        AutoRoute(
            page: EventDetailRoute.page, path: AppRouteName.eventDetailScreen),
        AutoRoute(
            page: PlaylistPlayerRoute.page,
            path: AppRouteName.wealthAcademyPlaylistScreen),
        AutoRoute(
            page: RegisterEmailRoute.page,
            path: AppRouteName.registerEmailScreen),
        AutoRoute(
            page: VerifyEmailOtpRoute.page,
            path: AppRouteName.verifyEmailScreen),
        AutoRoute(
            page: BasketOverViewRoute.page,
            path: AppRouteName.basketOverviewScreen),
        AutoRoute(
            page: BasketEditFundRoute.page,
            path: AppRouteName.basketEditFundScreen),
        AutoRoute(
            page: InsuranceDetailRoute.page,
            path: AppRouteName.insuranceDetailScreen,
            guards: [InsuranceRedirectGuard()]),
        AutoRoute(
            page: InsuranceGenerateQuotesRoute.page,
            path: AppRouteName.insuranceGenerateQuotesScreen),
        AutoRoute(
            page: ContactRmBottomSheetRoute.page,
            path: AppRouteName.contactRMBottomSheetScreen),
        RedirectRoute(
            path: AppRouteName.creativesScreen,
            redirectTo: AppRouteName.resourcesScreen),
        AutoRoute(
            page: ResourcesRoute.page, path: AppRouteName.resourcesScreen),
        AutoRoute(
            page: AppUpdateRoute.page, path: AppRouteName.appUpdateScreen),
        AutoRoute(
            page: InsuranceHomeRoute.page,
            path: AppRouteName.insuranceHomeScreen),
        AutoRoute(
            page: SalesPlanRoute.page, path: AppRouteName.salesPlanScreen),
        AutoRoute(
            page: SalesPlanGalleryListRoute.page,
            path: AppRouteName.salesPlanGalleryListScreen),
        AutoRoute(
            page: SalesPlanPlayerRoute.page,
            path: AppRouteName.salesPlanPlayerScreen),
        AutoRoute(
            page: AddFamilyCrnFormRoute.page,
            path: AppRouteName.addClientFamilyCRNScreen),
        AutoRoute(
            page: AddFamilyDetailFormRoute.page,
            path: AppRouteName.addClientFamilyDetailScreen),
        AutoRoute(
            page: AddFamilySuccessRoute.page,
            path: AppRouteName.addClientFamilySuccessScreen),
        AutoRoute(
            page: AddFamilyVerificationRoute.page,
            path: AppRouteName.addClientFamilyVerificationScreen),
        AutoRoute(
          page: AddFamilyCrnSearchRoute.page,
          path: AppRouteName.addClientFamilyCRNSearchScreen,
        ),
        AutoRoute(
          page: MyTeamRoute.page,
          path: AppRouteName.myTeamScreen,
        ),
        AutoRoute(
          page: ExistingTeamMemberFormRoute.page,
          path: AppRouteName.existingTeamMemberFormScreen,
        ),
        AutoRoute(
          page: NewTeamMemberFormRoute.page,
          path: AppRouteName.newTeamMemberFormScreen,
        ),
        AutoRoute(
          page: VerifyTeamMemberOtpRoute.page,
          path: AppRouteName.verifyTeamMemberOtpScreen,
        ),
        AutoRoute(
          page: CreateTeamFormRoute.page,
          path: AppRouteName.createTeamFormScreen,
        ),
        AutoRoute(
          page: ClientTrackerRoute.page,
          path: AppRouteName.clientTrackerScreen,
        ),
        AutoRoute(
          page: SipDetailRoute.page,
          path: AppRouteName.sipDetailScreen,
        ),
        AutoRoute(
          page: EditSipFormRoute.page,
          path: AppRouteName.editSipFormScreen,
        ),
        AutoRoute(
          page: EditSipSummaryRoute.page,
          path: AppRouteName.editSipSummaryScreen,
        ),

        AutoRoute(
          page: ClientReportRoute.page,
          path: AppRouteName.clientReportScreen,
        ),
        AutoRoute(
          page: ClientTrackerSwitchRoute.page,
          path: AppRouteName.clientTrackerSwitchScreen,
        ),
        AutoRoute(
          page: ClientTrackerSwitchBasketRoute.page,
          path: AppRouteName.switchBasketScreen,
        ),

        AutoRoute(
          page: ClientFamilyDetailRoute.page,
          path: AppRouteName.clientFamilyDetailScreen,
        ),
        AutoRoute(
          page: ClientDematDetailRoute.page,
          path: AppRouteName.clientDematScreen,
        ),
        AutoRoute(
          page: AddEditDematRoute.page,
          path: AppRouteName.clientUpdateDematScreen,
        ),
        AutoRoute(
          page: ClientAddressRoute.page,
          path: AppRouteName.clientAddressScreen,
        ),
        AutoRoute(
          page: AddEditClientAddressRoute.page,
          path: AppRouteName.addEditClientAddressScreen,
        ),
        AutoRoute(
          page: TransactionsRoute.page,
          path: AppRouteName.transactionsScreen,
        ),
        AutoRoute(
          page: MfTransactionDetailRoute.page,
          path: AppRouteName.mfTransactionDetailScreen,
        ),
        AutoRoute(
          page: QuickActionEditRoute.page,
          path: AppRouteName.quickActionEditScreen,
        ),
        AutoRoute(
          page: QuickActionListRoute.page,
          path: AppRouteName.quickActionListScreen,
        ),
        AutoRoute(
          page: EditAllocationRoute.page,
          path: AppRouteName.clientEditAllocationScreen,
        ),
        AutoRoute(
          page: BrokingRoute.page,
          path: AppRouteName.brokingScreen,
        ),
        AutoRoute(
          page: BrokingOnboardingRoute.page,
          path: AppRouteName.brokingOnboardingScreen,
        ),
        AutoRoute(
          page: BrokingActivityRoute.page,
          path: AppRouteName.brokingActivityScreen,
        ),
        AutoRoute(
          page: BusinessReportGenerateRoute.page,
          path: AppRouteName.businessReportGenerateScreen,
        ),
        AutoRoute(
          page: BusinessReportTemplateRoute.page,
          path: AppRouteName.businessReportTemplateScreen,
        ),
        AutoRoute(
          page: SoaDownloadRoute.page,
          path: AppRouteName.soaDownloadScreen,
        ),
        AutoRoute(
          page: SoaFolioListRoute.page,
          path: AppRouteName.soaFolioListScreen,
        ),
        AutoRoute(
          page: MyBusinessRoute.page,
          path: AppRouteName.myBusinessScreen,
        ),
// Ticob
        AutoRoute(
          page: TicobRoute.page,
          path: AppRouteName.ticobScreen,
        ),
        AutoRoute(
          page: GenerateCobOptionRoute.page,
          path: AppRouteName.generateCobOptionScreen,
        ),
        AutoRoute(
          page: TicobFolioRoute.page,
          path: AppRouteName.ticobFolioScreen,
        ),
        AutoRoute(
          page: GenerateCobSuccessfulRoute.page,
          path: AppRouteName.generateCobSuccessScreen,
        ),

        // Newsletter
        AutoRoute(
          page: NewsLetterRoute.page,
          path: AppRouteName.newsLetterScreen,
        ),
        AutoRoute(
          page: NewsLetterDetailRoute.page,
          path: AppRouteName.newsLetterDetailScreen,
        ),

        AutoRoute(
          page: DeeplinkLoaderRoute.page,
        ),
        AutoRoute(
          page: DescriptionHtmlRoute.page,
        ),
        AutoRoute(
          page: ReferralRewardsFaqTermsRoute.page,
          path: AppRouteName.referralRewardsFaqTermScreen,
        ),
        AutoRoute(
          page: BrandingWebViewRoute.page,
          path: AppRouteName.brandingScreen,
        ),
        AutoRoute(
          page: ReferralDeeplinkRoute.page,
          path: AppRouteName.referralScreen,
        ),

        AutoRoute(
          page: ClientBirthdayRoute.page,
          path: AppRouteName.birthdayScreen,
        ),
        AutoRoute(
          page: BirthdayWishRoute.page,
          path: AppRouteName.birthdayWishScreen,
        ),

        AutoRoute(
          page: ChooseClientRoute.page,
          path: AppRouteName.chooseClientScreen,
        ),
        AutoRoute(
          page: PortfolioReviewRoute.page,
          path: AppRouteName.clientPortfolioReviewScreen,
        ),

        AutoRoute(
          page: CalculatorTemplateRoute.page,
          path: AppRouteName.calculatorScreen,
        ),
        AutoRoute(
          page: CalculatorRoute.page,
          path: AppRouteName.calculatorAppViewScreen,
        ),

        AutoRoute(
          page: WealthcaseListRoute.page,
          path: AppRouteName.wealthCaseScreen,
        ),
        AutoRoute(
          page: AboutWealthcasesRoute.page,
          path: AppRouteName.wealthCaseAboutScreen,
        ),
        AutoRoute(
          page: WealthcaseDetailRoute.page,
          path: AppRouteName.wealthCaseDetailScreen,
        ),
      ];
}
