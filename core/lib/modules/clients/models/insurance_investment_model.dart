import 'package:core/modules/common/resources/wealthy_cast.dart';

class InsuranceInvestmentModel {
  InsuranceInvestmentModel(
      {this.totalInsurances,
      this.totalSumAssured,
      // this.inprogress,
      this.products});

  int? totalInsurances;
  int? totalSumAssured;
  // List<InsuranceInvestmentProductModel> inprogress;
  InsuranceInvestmentProductModel? products;

  InsuranceInvestmentModel.fromJson(Map<String, dynamic> json) {
    totalInsurances = WealthyCast.toInt(json['total_insurances']);
    totalSumAssured = WealthyCast.toInt(json['total_sum_assured']);
    // inprogress = List<InsuranceInvestmentProductModel>.from(WealthyCast.toList(
    //     json['inprogress'])
    //         .map((x) => InsuranceInvestmentProductModel.fromJson(x)));
    products = json['products'] != null
        ? InsuranceInvestmentProductModel.fromJson(json['products'])
        : null;
  }
}

class InsuranceInvestmentProductModel {
  List<MotorInsuranceInvestmentModel>? motor;
  List<HealthInsuranceInvestmentModel>? health;
  List<TermSavingsInsuranceInvestmentModel>? term;
  List<TermSavingsInsuranceInvestmentModel>? savings;

  InsuranceInvestmentProductModel({
    this.motor,
    this.health,
    this.term,
    this.savings,
  });

  InsuranceInvestmentProductModel.fromJson(Map<String, dynamic> json) {
    motor = List<MotorInsuranceInvestmentModel>.from(
        WealthyCast.toList(json['motor'])
            .map((x) => MotorInsuranceInvestmentModel.fromJson(x)));
    health = List<HealthInsuranceInvestmentModel>.from(
        WealthyCast.toList(json['health'])
            .map((x) => HealthInsuranceInvestmentModel.fromJson(x)));
    term = List<TermSavingsInsuranceInvestmentModel>.from(
        WealthyCast.toList(json['term'])
            .map((x) => TermSavingsInsuranceInvestmentModel.fromJson(x)));
    savings = List<TermSavingsInsuranceInvestmentModel>.from(
        WealthyCast.toList(json['savings'])
            .map((x) => TermSavingsInsuranceInvestmentModel.fromJson(x)));
  }
}

class HealthInsuranceInvestmentModel {
  String? plan;
  int? sumInsured;
  DateTime? expiryDate;
  String? personInsured;
  DateTime? policyStartDate;
  int? premiumAmount;
  String? multiplierBenefit;
  int? totalSumInsured;
  DateTime? renewalDate;
  String? policyNumber;
  String? insuranceType;
  String? insuranceCategory;

  HealthInsuranceInvestmentModel(
      {this.plan,
      this.sumInsured,
      this.expiryDate,
      this.personInsured,
      this.policyStartDate,
      this.premiumAmount,
      this.multiplierBenefit,
      this.totalSumInsured,
      this.renewalDate,
      this.policyNumber,
      this.insuranceType,
      this.insuranceCategory});

  HealthInsuranceInvestmentModel.fromJson(Map<String, dynamic> json) {
    plan = WealthyCast.toStr(json['plan']);
    sumInsured = WealthyCast.toInt(json['sum_insured']);
    expiryDate = WealthyCast.toDate(json['expiry_date']);
    personInsured = WealthyCast.toStr(json['person_insured']);
    policyStartDate = WealthyCast.toDate(json['policy_start_date']);
    premiumAmount = WealthyCast.toInt(json['premium_amount']);
    multiplierBenefit = WealthyCast.toStr(json['multiplier_benefit']);
    totalSumInsured = WealthyCast.toInt(json['total_sum_insured']);
    renewalDate = WealthyCast.toDate(json['renewal_date']);
    policyNumber = WealthyCast.toStr(json['policy_number']);
    insuranceType = WealthyCast.toStr(json['insurance_type']);
    insuranceCategory = WealthyCast.toStr(json['insurance_category']);
  }
}

class MotorInsuranceInvestmentModel {
  String? vehicleModel;
  DateTime? dateOfSale;
  String? vehicleRegistrationNumber;
  DateTime? renewalDate;
  String? policyNumber;
  MotorInsuranceProductDetails? productDetails;
  DateTime? expiryDate;
  DateTime? policyStartDate;
  String? plan;
  int? premiumAmount;
  String? insuranceType;
  String? insuranceCategory;

  MotorInsuranceInvestmentModel(
      {this.vehicleModel,
      this.dateOfSale,
      this.vehicleRegistrationNumber,
      this.renewalDate,
      this.policyNumber,
      this.productDetails,
      this.expiryDate,
      this.policyStartDate,
      this.plan,
      this.premiumAmount,
      this.insuranceType,
      this.insuranceCategory});

  MotorInsuranceInvestmentModel.fromJson(Map<String, dynamic> json) {
    vehicleModel = WealthyCast.toStr(json['vehicle_model']);
    dateOfSale = WealthyCast.toDate(json['date_of_sale']);
    vehicleRegistrationNumber =
        WealthyCast.toStr(json['vehicle_registration_number']);
    renewalDate = WealthyCast.toDate(json['renewal_date']);
    policyNumber = WealthyCast.toStr(json['policy_number']);
    productDetails = json['product_details'] != null
        ? new MotorInsuranceProductDetails.fromJson(json['product_details'])
        : null;
    expiryDate = WealthyCast.toDate(json['expiry_date']);
    policyStartDate = WealthyCast.toDate(json['policy_start_date']);
    plan = WealthyCast.toStr(json['plan']);
    premiumAmount = WealthyCast.toInt(json['premium_amount']);
    insuranceType = WealthyCast.toStr(json['insurance_type']);
    insuranceCategory = WealthyCast.toStr(json['insurance_category']);
  }
}

class MotorInsuranceProductDetails {
  String? productCode;
  String? productDisplayName;
  String? productManufacturer;
  String? productType;
  String? productVendor;

  MotorInsuranceProductDetails(
      {this.productCode,
      this.productDisplayName,
      this.productManufacturer,
      this.productType,
      this.productVendor});

  MotorInsuranceProductDetails.fromJson(Map<String, dynamic> json) {
    productCode = WealthyCast.toStr(json['product_code']);
    productDisplayName = WealthyCast.toStr(json['product_display_name']);
    productManufacturer = WealthyCast.toStr(json['product_manufacturer']);
    productType = WealthyCast.toStr(json['product_type']);
    productVendor = WealthyCast.toStr(json['product_vendor']);
  }
}

class TermSavingsInsuranceInvestmentModel {
  String? annualPremium;
  String? insuranceCategory;
  String? insuranceType;
  String? lifeInsured;
  String? maturityValue;
  DateTime? nextDueDate;
  String? nomineeName;
  String? numberOfPremiumsPaid;
  String? plan;
  String? policyNumber;
  String? policyStartDate;
  int? policyValidity;
  int? premiumPaymentTerm;
  int? sumAssured;
  String? surrenderValue;

  TermSavingsInsuranceInvestmentModel(
      {this.annualPremium,
      this.insuranceCategory,
      this.insuranceType,
      this.lifeInsured,
      this.maturityValue,
      this.nextDueDate,
      this.nomineeName,
      this.numberOfPremiumsPaid,
      this.plan,
      this.policyNumber,
      this.policyStartDate,
      this.policyValidity,
      this.premiumPaymentTerm,
      this.sumAssured,
      this.surrenderValue});

  TermSavingsInsuranceInvestmentModel.fromJson(Map<String, dynamic> json) {
    annualPremium = WealthyCast.toStr(json['annual_premium']);
    insuranceCategory = WealthyCast.toStr(json['insurance_category']);
    insuranceType = WealthyCast.toStr(json['insurance_type']);
    lifeInsured = WealthyCast.toStr(json['life_insured']);
    maturityValue = WealthyCast.toStr(json['maturity_value']);
    nextDueDate = WealthyCast.toDate(json['next_due_date']);
    nomineeName = WealthyCast.toStr(json['nominee_name']);
    numberOfPremiumsPaid = WealthyCast.toStr(json['number_of_premiums_paid']);
    plan = WealthyCast.toStr(json['plan']);
    policyNumber = WealthyCast.toStr(json['policy_number']);
    policyStartDate = WealthyCast.toStr(json['policy_start_date']);
    policyValidity = WealthyCast.toInt(json['policy_validity']);
    premiumPaymentTerm = WealthyCast.toInt(json['premium_payment_term']);
    sumAssured = WealthyCast.toInt(json['sum_assured']);
    surrenderValue = WealthyCast.toStr(json['surrender_value']);
  }
}
