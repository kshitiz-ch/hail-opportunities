class InsuranceOpportunitiesResponse {
  final int totalOpportunities;
  final int noInsuranceCount;
  final int lowCoverageCount;
  final double totalOpportunityValue;
  final double totalMfValueAtRisk;
  final double averageAge;
  final List<InsuranceOpportunity> opportunities;

  InsuranceOpportunitiesResponse({
    required this.totalOpportunities,
    required this.noInsuranceCount,
    required this.lowCoverageCount,
    required this.totalOpportunityValue,
    required this.totalMfValueAtRisk,
    required this.averageAge,
    required this.opportunities,
  });

  factory InsuranceOpportunitiesResponse.fromJson(Map<String, dynamic> json) {
    return InsuranceOpportunitiesResponse(
      totalOpportunities: json['total_opportunities'] ?? 0,
      noInsuranceCount: json['no_insurance_count'] ?? 0,
      lowCoverageCount: json['low_coverage_count'] ?? 0,
      totalOpportunityValue: (json['total_opportunity_value'] ?? 0).toDouble(),
      totalMfValueAtRisk: (json['total_mf_value_at_risk'] ?? 0).toDouble(),
      averageAge: (json['average_age'] ?? 0).toDouble(),
      opportunities: json['opportunities'] != null
          ? List<InsuranceOpportunity>.from(
              (json['opportunities'] as List).map(
                (x) => InsuranceOpportunity.fromJson(x),
              ),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_opportunities': totalOpportunities,
      'no_insurance_count': noInsuranceCount,
      'low_coverage_count': lowCoverageCount,
      'total_opportunity_value': totalOpportunityValue,
      'total_mf_value_at_risk': totalMfValueAtRisk,
      'average_age': averageAge,
      'opportunities': opportunities.map((x) => x.toJson()).toList(),
    };
  }
}

class InsuranceOpportunity {
  final String userId;
  final String userName;
  final String agentExternalId;
  final String agentName;
  final int age;
  final double mfCurrentValue;
  final double totalPremium;
  final double expectedPremium;
  final String insuranceStatus;
  final double premiumOpportunityValue;
  final double coveragePercentage;

  InsuranceOpportunity({
    required this.userId,
    required this.userName,
    required this.agentExternalId,
    required this.agentName,
    required this.age,
    required this.mfCurrentValue,
    required this.totalPremium,
    required this.expectedPremium,
    required this.insuranceStatus,
    required this.premiumOpportunityValue,
    required this.coveragePercentage,
  });

  factory InsuranceOpportunity.fromJson(Map<String, dynamic> json) {
    return InsuranceOpportunity(
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      agentExternalId: json['agent_external_id'] ?? '',
      agentName: json['agent_name'] ?? '',
      age: json['age'] ?? 0,
      mfCurrentValue: (json['mf_current_value'] ?? 0).toDouble(),
      totalPremium: (json['total_premium'] ?? 0).toDouble(),
      expectedPremium: (json['expected_premium'] ?? 0).toDouble(),
      insuranceStatus: json['insurance_status'] ?? '',
      premiumOpportunityValue:
          (json['premium_opportunity_value'] ?? 0).toDouble(),
      coveragePercentage: (json['coverage_percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'agent_external_id': agentExternalId,
      'agent_name': agentName,
      'age': age,
      'mf_current_value': mfCurrentValue,
      'total_premium': totalPremium,
      'expected_premium': expectedPremium,
      'insurance_status': insuranceStatus,
      'premium_opportunity_value': premiumOpportunityValue,
      'coverage_percentage': coveragePercentage,
    };
  }
}

enum InsuranceStatus {
  noInsurance,
  lowCoverage,
  adequate;

  String get value {
    switch (this) {
      case InsuranceStatus.noInsurance:
        return 'NO_INSURANCE';
      case InsuranceStatus.lowCoverage:
        return 'LOW_COVERAGE';
      case InsuranceStatus.adequate:
        return 'ADEQUATE';
    }
  }

  static InsuranceStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'NO_INSURANCE':
        return InsuranceStatus.noInsurance;
      case 'LOW_COVERAGE':
        return InsuranceStatus.lowCoverage;
      case 'ADEQUATE':
        return InsuranceStatus.adequate;
      default:
        return InsuranceStatus.noInsurance;
    }
  }
}
