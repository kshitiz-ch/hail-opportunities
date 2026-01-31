// Stopped SIP Models
class StoppedSipResponse {
  final int totalStoppedClients;
  final int totalActiveSipsAffected;
  final double totalLifetimeInvestment;
  final double averageDaysInactive;
  final List<StoppedSipOpportunity> opportunities;

  StoppedSipResponse({
    required this.totalStoppedClients,
    required this.totalActiveSipsAffected,
    required this.totalLifetimeInvestment,
    required this.averageDaysInactive,
    required this.opportunities,
  });

  factory StoppedSipResponse.fromJson(Map<String, dynamic> json) {
    return StoppedSipResponse(
      totalStoppedClients: json['total_stopped_clients'] ?? 0,
      totalActiveSipsAffected: json['total_active_sips_affected'] ?? 0,
      totalLifetimeInvestment:
          (json['total_lifetime_investment'] ?? 0).toDouble(),
      averageDaysInactive: (json['average_days_inactive'] ?? 0).toDouble(),
      opportunities: json['opportunities'] != null
          ? List<StoppedSipOpportunity>.from(
              (json['opportunities'] as List).map(
                (x) => StoppedSipOpportunity.fromJson(x),
              ),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_stopped_clients': totalStoppedClients,
      'total_active_sips_affected': totalActiveSipsAffected,
      'total_lifetime_investment': totalLifetimeInvestment,
      'average_days_inactive': averageDaysInactive,
      'opportunities': opportunities.map((x) => x.toJson()).toList(),
    };
  }
}

class StoppedSipOpportunity {
  final String userId;
  final String userName;
  final String agentExternalId;
  final String agentName;
  final int totalSips;
  final int activeSips;
  final int maxSuccessCount;
  final double lifetimeSuccessAmount;
  final String lastSuccessDate;
  final int daysSinceAnySuccess;
  final int monthsSinceSuccess;

  StoppedSipOpportunity({
    required this.userId,
    required this.userName,
    required this.agentExternalId,
    required this.agentName,
    required this.totalSips,
    required this.activeSips,
    required this.maxSuccessCount,
    required this.lifetimeSuccessAmount,
    required this.lastSuccessDate,
    required this.daysSinceAnySuccess,
    required this.monthsSinceSuccess,
  });

  factory StoppedSipOpportunity.fromJson(Map<String, dynamic> json) {
    return StoppedSipOpportunity(
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      agentExternalId: json['agent_external_id'] ?? '',
      agentName: json['agent_name'] ?? '',
      totalSips: json['total_sips'] ?? 0,
      activeSips: json['active_sips'] ?? 0,
      maxSuccessCount: json['max_success_count'] ?? 0,
      lifetimeSuccessAmount: (json['lifetime_success_amount'] ?? 0).toDouble(),
      lastSuccessDate: json['last_success_date'] ?? '',
      daysSinceAnySuccess: json['days_since_any_success'] ?? 0,
      monthsSinceSuccess: json['months_since_success'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'agent_external_id': agentExternalId,
      'agent_name': agentName,
      'total_sips': totalSips,
      'active_sips': activeSips,
      'max_success_count': maxSuccessCount,
      'lifetime_success_amount': lifetimeSuccessAmount,
      'last_success_date': lastSuccessDate,
      'days_since_any_success': daysSinceAnySuccess,
      'months_since_success': monthsSinceSuccess,
    };
  }
}

// Stagnant SIP Models
class StagnantSipResponse {
  final int totalStagnantSips;
  final int totalClientsAffected;
  final double totalSipValue;
  final List<StagnantSipOpportunity> opportunities;

  StagnantSipResponse({
    required this.totalStagnantSips,
    required this.totalClientsAffected,
    required this.totalSipValue,
    required this.opportunities,
  });

  factory StagnantSipResponse.fromJson(Map<String, dynamic> json) {
    return StagnantSipResponse(
      totalStagnantSips: json['total_stagnant_sips'] ?? 0,
      totalClientsAffected: json['total_clients_affected'] ?? 0,
      totalSipValue: (json['total_sip_value'] ?? 0).toDouble(),
      opportunities: json['opportunities'] != null
          ? List<StagnantSipOpportunity>.from(
              (json['opportunities'] as List).map(
                (x) => StagnantSipOpportunity.fromJson(x),
              ),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_stagnant_sips': totalStagnantSips,
      'total_clients_affected': totalClientsAffected,
      'total_sip_value': totalSipValue,
      'opportunities': opportunities.map((x) => x.toJson()).toList(),
    };
  }
}

class StagnantSipOpportunity {
  final String userId;
  final String userName;
  final String agentId;
  final String agentExternalId;
  final String agentName;
  final String sipMetaId;
  final String schemeName;
  final double currentSip;
  final String createdAt;
  final int monthsStagnant;
  final double successAmount;

  StagnantSipOpportunity({
    required this.userId,
    required this.userName,
    required this.agentId,
    required this.agentExternalId,
    required this.agentName,
    required this.sipMetaId,
    required this.schemeName,
    required this.currentSip,
    required this.createdAt,
    required this.monthsStagnant,
    required this.successAmount,
  });

  factory StagnantSipOpportunity.fromJson(Map<String, dynamic> json) {
    return StagnantSipOpportunity(
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      agentId: json['agent_id'] ?? '',
      agentExternalId: json['agent_external_id'] ?? '',
      agentName: json['agent_name'] ?? '',
      sipMetaId: json['sip_meta_id'] ?? '',
      schemeName: json['scheme_name'] ?? '',
      currentSip: (json['current_sip'] ?? 0).toDouble(),
      createdAt: json['created_at'] ?? '',
      monthsStagnant: json['months_stagnant'] ?? 0,
      successAmount: (json['success_amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'agent_id': agentId,
      'agent_external_id': agentExternalId,
      'agent_name': agentName,
      'sip_meta_id': sipMetaId,
      'scheme_name': schemeName,
      'current_sip': currentSip,
      'created_at': createdAt,
      'months_stagnant': monthsStagnant,
      'success_amount': successAmount,
    };
  }
}
