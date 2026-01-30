enum InvestmentType { oneTime, SIP }

enum FileState { loading, loaded, error }

enum NetworkState { loading, loaded, error, cancel }

enum ResponseEnums { SUCCESS, DATA_NOT_FOUND, FAILURE, GENERIC_ERROR }

enum Screens { HOME, PROPOSALS, STORE, CLIENTS, RESOURCES }

enum LockScreenMode { currentPassCodeMode, newPassCodeMode }

enum DesignationType { Employee, Member }

enum PartnerType { Self, Office }

enum MfInvestmentType { Funds, Portfolios }

enum OrderValueType { Amount, Units, Full }

enum SwitchFundType { SwitchIn, SwitchOut }

enum SipGraphType {
  SipBook
// SuccessfulSip
}

enum SipBookTabType { Online, Offline, Transactions }

enum BrokingChargeType { Delivery, Intraday, Future, Options }

enum SipUserDataFilter {
  isActive,
  isPaused,
  isInactive,
  pausedCurrentMonth,
  sipRegisteredCurrentMonth,
  notMandateApproved,
}

enum FundReturnInputType { Amount, Period }

enum FilterMode { filter, sort }

enum ReturnYearType { oneYear, threeYear, fiveYear }

enum FilterType { category, amc }

enum MfListType { WealthySelect, TopSelling, Nfo }

enum FundGraphView { Historical, Custom }

enum FundType { Equity, Debt, Hybrid, Commodity }

enum SortOrder { ascending, descending }

enum FundSelection { manual, automatic }

enum GoalDetailTabs { Overview, Transactions, SIP, STP, SWP }

enum ReportCategory { Individual, Family }

enum KycPanUsageType { INDIVIDUAL, NONINDIVIDUAL }

enum ReportDateType {
  SingleDate,
  SingleYear,
  IntervalDate,
  None,
}

enum CobType { Tracker, Manual }

enum CalculatorType {
  SipStepUp,
  Lumpsum,
  SWP,
  SipSwp,
  GoalPlanningLumpsum,
  GoalPlanningSIPLumpsum,
}

extension CalculatorTypeExtension on CalculatorType {
  String get calculatorName {
    switch (this) {
      case CalculatorType.SipStepUp:
        return 'SIP Calculator';
      case CalculatorType.Lumpsum:
        return 'Lumpsum Calculator';
      case CalculatorType.SWP:
        return 'SWP Calculator';
      case CalculatorType.SipSwp:
        return 'SIP SWP Calculator';
      case CalculatorType.GoalPlanningSIPLumpsum:
        return 'Goal Planning SIP + Lumpsum Calculator';
      case CalculatorType.GoalPlanningLumpsum:
        return 'Goal Planning Lumpsum Calculator';
      default:
        return 'Calculator';
    }
  }

  String get templateName {
    switch (this) {
      case CalculatorType.SipStepUp:
        return 'SIP-CALCULATOR';
      case CalculatorType.Lumpsum:
        return 'LUMPSUM-CALCULATOR';
      case CalculatorType.SWP:
        return 'SWP-CALCULATOR';
      case CalculatorType.SipSwp:
        return 'SIP-SWP-CALCULATOR';
      case CalculatorType.GoalPlanningLumpsum:
        return 'GOAL-PLANNING-LUMPSUM-CALCULATOR';
      case CalculatorType.GoalPlanningSIPLumpsum:
        return 'GOAL-PLANNING-SIP-LUMPSUM-CALCULATOR';
    }
  }

  String get calculatorFileName {
    switch (this) {
      case CalculatorType.SipStepUp:
        return 'sip_calculator';
      case CalculatorType.Lumpsum:
        return 'lumpsum_calculator';
      case CalculatorType.SWP:
        return 'swp_calculator';
      case CalculatorType.SipSwp:
        return 'sip_swp_calculator';
      case CalculatorType.GoalPlanningSIPLumpsum:
        return 'goal_planning_sip_lumpsum_calculator';
      case CalculatorType.GoalPlanningLumpsum:
        return 'goal_planning_lumpsum_calculator';
      default:
        return 'calculator';
    }
  }
}

enum AiScreenType { clients, faq }

enum AIAssistantType {
  clientAssistant,
  faqAssistant,
  birthdayWishPartnerClient;

  String get key {
    switch (this) {
      case AIAssistantType.clientAssistant:
        return 'CLIENT-FILTERING';
      case AIAssistantType.faqAssistant:
        return 'PARTNER_FAQ';
      case AIAssistantType.birthdayWishPartnerClient:
        return 'BIRTHDAY_WISH_PARTNER_CLIENT';
    }
  }
}

// New MF Transaction Enums
enum MFOrderStatus { Failure, Progress, Success }

enum MFOrderTypeDisplay { Purchase, SIP, Switch, SWP, STP, Redemption }

/// Defines the context in which the transaction list is being displayed.
enum TransactionScreenContext {
  /// Represents the general transaction screen with full features:
  /// type selector, aggregates, and search capabilities.
  general,

  /// Similar to [general], but also includes sort and filter options.
  /// Typically used for SIP book or similar detailed views.
  sipBook,

  /// Represents a view where transactions are displayed in a more minimal UI context,
  /// specifically for client detail views.
  clientDetailView,

  /// Represents a view where transactions are displayed in a more minimal UI context,
  /// specifically for goal detail views.
  goalDetailView,
}

/// Extension methods for [TransactionScreenContext] to control UI visibility
extension TransactionScreenContextExtension on TransactionScreenContext {
  bool get isTransactionView => this == TransactionScreenContext.general;
  bool get isSipBookView => this == TransactionScreenContext.sipBook;
  bool get isClientView => this == TransactionScreenContext.clientDetailView;
  bool get isGoalView => this == TransactionScreenContext.goalDetailView;

  bool get showTransactionTypeSelector => isTransactionView;
  bool get showAggregateSection => isTransactionView || isSipBookView;
}

enum PersonIDType {
  Aadhaar,
  Passport,
  Pan;

  String get description {
    switch (this) {
      case PersonIDType.Aadhaar:
        return 'Aadhaar Number';
      case PersonIDType.Passport:
        return 'Passport Number';
      case PersonIDType.Pan:
        return 'PAN Number';
    }
  }
}

/// Extension methods for [PersonIDType] to handle selection state
extension PersonIDTypeExtension on PersonIDType {
  bool get isAadhaar => this == PersonIDType.Aadhaar;
  bool get isPassport => this == PersonIDType.Passport;
  bool get isPan => this == PersonIDType.Pan;
}

enum AppResourcesSource { marketing, sales, recentlyAdded, single }
