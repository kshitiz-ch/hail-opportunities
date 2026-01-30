class GoalType {
  static const TAX_SAVER = 0;
  static const GENERAL_INVESTMENT = 1;
  static const SWITCH = 2;
  static const DEBT_PORTFOLIOS = 3;
  static const ADVANCE_SIP = 4;
  static const CUSTOM = 9;
  static const ANY_FUNDS = 10;
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
