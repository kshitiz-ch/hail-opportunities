const String totalAumQuery = r'''
  query totalAumQuery($agentExternalId: String!, $agentExternalIdList: [String]) {
    delta(userId: ""){
      partnerMonthlyMetric(agentExternalIdList: $agentExternalIdList, agentExternalId: $agentExternalId, months: 1, includeCurrentMonth: true) {
        TOTAL
        date
      }
    }
  }
''';

const String totalAumAggregateQuery = r'''
  query aumAggregateQuery($agentExternalId: String!, $agentExternalIdList: [String]) {
    delta(userId: ""){
      partnersMonthlyMetricAum(agentExternalIdList: $agentExternalIdList, agentExternalId: $agentExternalId, months: 1, includeCurrentMonth: true) {
        TOTAL
        date
      }
    }
  }
''';

String mfMetricsQuery = r'''
  query mfMetricsQuery($agentExternalIdList: [String], $date: String) {
    delta(userId: "") {
      partnersTotalMetric (agentExternalIdList: $agentExternalIdList, date: $date) {
       myBusinessData
      }
    }
  }
''';

String clientMetricsQuery = r'''
  query clientMetricsQuery($agentExternalIdList: [String]) {
    delta(userId: "") {
     partnersClientMetrics(agentExternalIdList: $agentExternalIdList) {
        totalClients
        mfKycClients
        brokingKycClients
        activeClients
        syncedClientsLast30Days
        totalExternalTrackerAmount
        totalTrackerSyncedAmount
      }
    }
  }
''';
