class PortfolioOpportunitiesResponse {
  final int totalClients;
  final int totalUnderperformingSchemes;
  final double totalValueUnderperforming;
  final List<PortfolioClient> clients;

  PortfolioOpportunitiesResponse({
    required this.totalClients,
    required this.totalUnderperformingSchemes,
    required this.totalValueUnderperforming,
    required this.clients,
  });

  factory PortfolioOpportunitiesResponse.fromJson(Map<String, dynamic> json) {
    return PortfolioOpportunitiesResponse(
      totalClients: json['total_clients'] ?? 0,
      totalUnderperformingSchemes: json['total_underperforming_schemes'] ?? 0,
      totalValueUnderperforming:
          (json['total_value_underperforming'] ?? 0).toDouble(),
      clients: json['clients'] != null
          ? List<PortfolioClient>.from(
              (json['clients'] as List).map(
                (x) => PortfolioClient.fromJson(x),
              ),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_clients': totalClients,
      'total_underperforming_schemes': totalUnderperformingSchemes,
      'total_value_underperforming': totalValueUnderperforming,
      'clients': clients.map((x) => x.toJson()).toList(),
    };
  }
}

class PortfolioClient {
  final String userId;
  final String clientName;
  final String agentExternalId;
  final String agentName;
  final int numberOfUnderperformingSchemes;
  final double totalValueUnderperforming;
  final List<UnderperformingScheme> underperformingSchemes;

  PortfolioClient({
    required this.userId,
    required this.clientName,
    required this.agentExternalId,
    required this.agentName,
    required this.numberOfUnderperformingSchemes,
    required this.totalValueUnderperforming,
    required this.underperformingSchemes,
  });

  factory PortfolioClient.fromJson(Map<String, dynamic> json) {
    return PortfolioClient(
      userId: json['user_id'] ?? '',
      clientName: json['client_name'] ?? '',
      agentExternalId: json['agent_external_id'] ?? '',
      agentName: json['agent_name'] ?? '',
      numberOfUnderperformingSchemes:
          json['number_of_underperforming_schemes'] ?? 0,
      totalValueUnderperforming:
          (json['total_value_underperforming'] ?? 0).toDouble(),
      underperformingSchemes: json['underperforming_schemes'] != null
          ? List<UnderperformingScheme>.from(
              (json['underperforming_schemes'] as List).map(
                (x) => UnderperformingScheme.fromJson(x),
              ),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'client_name': clientName,
      'agent_external_id': agentExternalId,
      'agent_name': agentName,
      'number_of_underperforming_schemes': numberOfUnderperformingSchemes,
      'total_value_underperforming': totalValueUnderperforming,
      'underperforming_schemes':
          underperformingSchemes.map((x) => x.toJson()).toList(),
    };
  }
}

class UnderperformingScheme {
  final String wpc;
  final String schemeName;
  final double liveXirr;
  final double benchmarkXirr;
  final double xirrUnderperformance;
  final double currentValue;
  final String benchmarkName;
  final String category;
  final String amcName;

  UnderperformingScheme({
    required this.wpc,
    required this.schemeName,
    required this.liveXirr,
    required this.benchmarkXirr,
    required this.xirrUnderperformance,
    required this.currentValue,
    required this.benchmarkName,
    required this.category,
    required this.amcName,
  });

  factory UnderperformingScheme.fromJson(Map<String, dynamic> json) {
    return UnderperformingScheme(
      wpc: json['wpc'] ?? '',
      schemeName: json['scheme_name'] ?? '',
      liveXirr: (json['live_xirr'] ?? 0).toDouble(),
      benchmarkXirr: (json['benchmark_xirr'] ?? 0).toDouble(),
      xirrUnderperformance: (json['xirr_underperformance'] ?? 0).toDouble(),
      currentValue: (json['current_value'] ?? 0).toDouble(),
      benchmarkName: json['benchmark_name'] ?? '',
      category: json['category'] ?? '',
      amcName: json['amc_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wpc': wpc,
      'scheme_name': schemeName,
      'live_xirr': liveXirr,
      'benchmark_xirr': benchmarkXirr,
      'xirr_underperformance': xirrUnderperformance,
      'current_value': currentValue,
      'benchmark_name': benchmarkName,
      'category': category,
      'amc_name': amcName,
    };
  }
}
