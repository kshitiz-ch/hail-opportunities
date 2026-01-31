class OpportunitiesOverviewResponse {
  final DashboardHero dashboardHero;
  final List<TopFocusClient> topFocusClients;

  OpportunitiesOverviewResponse({
    required this.dashboardHero,
    required this.topFocusClients,
  });

  factory OpportunitiesOverviewResponse.fromJson(Map<String, dynamic> json) {
    return OpportunitiesOverviewResponse(
      dashboardHero: DashboardHero.fromJson(json['dashboard_hero'] ?? {}),
      topFocusClients: json['top_focus_clients'] != null
          ? List<TopFocusClient>.from(
              (json['top_focus_clients'] as List).map(
                (x) => TopFocusClient.fromJson(x),
              ),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dashboard_hero': dashboardHero.toJson(),
      'top_focus_clients': topFocusClients.map((x) => x.toJson()).toList(),
    };
  }
}

class DashboardHero {
  final double totalOpportunityValue;
  final String formattedValue;
  final String executiveSummary;
  final OpportunityBreakdown opportunityBreakdown;

  DashboardHero({
    required this.totalOpportunityValue,
    required this.formattedValue,
    required this.executiveSummary,
    required this.opportunityBreakdown,
  });

  factory DashboardHero.fromJson(Map<String, dynamic> json) {
    return DashboardHero(
      totalOpportunityValue: (json['total_opportunity_value'] ?? 0).toDouble(),
      formattedValue: json['formatted_value'] ?? '',
      executiveSummary: json['executive_summary'] ?? '',
      opportunityBreakdown: OpportunityBreakdown.fromJson(
        json['opportunity_breakdown'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_opportunity_value': totalOpportunityValue,
      'formatted_value': formattedValue,
      'executive_summary': executiveSummary,
      'opportunity_breakdown': opportunityBreakdown.toJson(),
    };
  }
}

class OpportunityBreakdown {
  final String insurance;
  final String sipRecovery;
  final String portfolioRebalancing;

  OpportunityBreakdown({
    required this.insurance,
    required this.sipRecovery,
    required this.portfolioRebalancing,
  });

  factory OpportunityBreakdown.fromJson(Map<String, dynamic> json) {
    return OpportunityBreakdown(
      insurance: json['insurance'] ?? '',
      sipRecovery: json['sip_recovery'] ?? '',
      portfolioRebalancing: json['portfolio_rebalancing'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'insurance': insurance,
      'sip_recovery': sipRecovery,
      'portfolio_rebalancing': portfolioRebalancing,
    };
  }
}

class TopFocusClient {
  final String userId;
  final String clientName;
  final String totalImpactValue;
  final List<String> tags;
  final String pitchHook;
  final DrillDownDetails drillDownDetails;

  TopFocusClient({
    required this.userId,
    required this.clientName,
    required this.totalImpactValue,
    required this.tags,
    required this.pitchHook,
    required this.drillDownDetails,
  });

  factory TopFocusClient.fromJson(Map<String, dynamic> json) {
    return TopFocusClient(
      userId: json['user_id'] ?? '',
      clientName: json['client_name'] ?? '',
      totalImpactValue: json['total_impact_value'] ?? '',
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      pitchHook: json['pitch_hook'] ?? '',
      drillDownDetails: DrillDownDetails.fromJson(
        json['drill_down_details'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'client_name': clientName,
      'total_impact_value': totalImpactValue,
      'tags': tags,
      'pitch_hook': pitchHook,
      'drill_down_details': drillDownDetails.toJson(),
    };
  }
}

class DrillDownDetails {
  final PortfolioReview portfolioReview;
  final SipHealth sipHealth;
  final Insurance insurance;

  DrillDownDetails({
    required this.portfolioReview,
    required this.sipHealth,
    required this.insurance,
  });

  factory DrillDownDetails.fromJson(Map<String, dynamic> json) {
    return DrillDownDetails(
      portfolioReview: PortfolioReview.fromJson(
        json['portfolio_review'] ?? {},
      ),
      sipHealth: SipHealth.fromJson(json['sip_health'] ?? {}),
      insurance: Insurance.fromJson(json['insurance'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'portfolio_review': portfolioReview.toJson(),
      'sip_health': sipHealth.toJson(),
      'insurance': insurance.toJson(),
    };
  }
}

class PortfolioReview {
  final bool hasIssue;
  final List<PortfolioScheme> schemes;

  PortfolioReview({
    required this.hasIssue,
    required this.schemes,
  });

  factory PortfolioReview.fromJson(Map<String, dynamic> json) {
    return PortfolioReview(
      hasIssue: json['has_issue'] ?? false,
      schemes: json['schemes'] != null
          ? List<PortfolioScheme>.from(
              (json['schemes'] as List).map(
                (x) => PortfolioScheme.fromJson(x),
              ),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'has_issue': hasIssue,
      'schemes': schemes.map((x) => x.toJson()).toList(),
    };
  }
}

class PortfolioScheme {
  final String name;
  final double xirrLag;

  PortfolioScheme({
    required this.name,
    required this.xirrLag,
  });

  factory PortfolioScheme.fromJson(Map<String, dynamic> json) {
    return PortfolioScheme(
      name: json['name'] ?? '',
      xirrLag: (json['xirr_lag'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'xirr_lag': xirrLag,
    };
  }
}

class SipHealth {
  final List<StoppedSip> stoppedSips;
  final List<StagnantSip> stagnantSips;

  SipHealth({
    required this.stoppedSips,
    required this.stagnantSips,
  });

  factory SipHealth.fromJson(Map<String, dynamic> json) {
    return SipHealth(
      stoppedSips: json['stopped_sips'] != null
          ? List<StoppedSip>.from(
              (json['stopped_sips'] as List).map(
                (x) => StoppedSip.fromJson(x),
              ),
            )
          : [],
      stagnantSips: json['stagnant_sips'] != null
          ? List<StagnantSip>.from(
              (json['stagnant_sips'] as List).map(
                (x) => StagnantSip.fromJson(x),
              ),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stopped_sips': stoppedSips.map((x) => x.toJson()).toList(),
      'stagnant_sips': stagnantSips.map((x) => x.toJson()).toList(),
    };
  }
}

class StoppedSip {
  final String scheme;
  final int daysStopped;
  final double amount;

  StoppedSip({
    required this.scheme,
    required this.daysStopped,
    required this.amount,
  });

  factory StoppedSip.fromJson(Map<String, dynamic> json) {
    return StoppedSip(
      scheme: json['scheme'] ?? '',
      daysStopped: json['days_stopped'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scheme': scheme,
      'days_stopped': daysStopped,
      'amount': amount,
    };
  }
}

class StagnantSip {
  final String scheme;
  final double yearsRunning;

  StagnantSip({
    required this.scheme,
    required this.yearsRunning,
  });

  factory StagnantSip.fromJson(Map<String, dynamic> json) {
    return StagnantSip(
      scheme: json['scheme'] ?? '',
      yearsRunning: (json['years_running'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scheme': scheme,
      'years_running': yearsRunning,
    };
  }
}

class Insurance {
  final bool hasGap;
  final double gapAmount;
  final String wealthBand;

  Insurance({
    required this.hasGap,
    required this.gapAmount,
    required this.wealthBand,
  });

  factory Insurance.fromJson(Map<String, dynamic> json) {
    return Insurance(
      hasGap: json['has_gap'] ?? false,
      gapAmount: (json['gap_amount'] ?? 0).toDouble(),
      wealthBand: json['wealth_band'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'has_gap': hasGap,
      'gap_amount': gapAmount,
      'wealth_band': wealthBand,
    };
  }
}
