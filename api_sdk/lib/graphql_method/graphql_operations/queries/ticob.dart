const ticobTransactions = r'''
  query ticobTransactions ($agentExternalIdList: [String], $filters: String, $searchText: String, $orderBy: String, $offset: Int , $limit: Int) {
    taxy {
      userMfTicobTransactions(agentExternalIdList: $agentExternalIdList, filters: $filters, searchText: $searchText, orderBy: $orderBy, offset: $offset, limit: $limit) {
        count
        userTicobTransactionData {
          name
          email
          units
          userId
          amc
          amount
          agentName
          agentExternalId
          postDate
          panNumber
          folioNumber
          crn
          amcName
          schemes {
            schemeName
            units
            amount
          }
        }
      }
    }
  }
''';

const cobOpportunities = r'''
  query cobOpportunities($requestAgentId: String!, $limit: Int, $offset: Int, $trakCobOpportunityValueFilter: String, $q: String) {
  hydra {
    id
    customerCountV2(requestAgentId: $requestAgentId, trakCobOpportunityValueFilter: $trakCobOpportunityValueFilter, q: $q)
    clients(requestAgentId: $requestAgentId, limit: $limit, offset: $offset, trakCobOpportunityValueFilter: $trakCobOpportunityValueFilter, q: $q) {
      id
      name
      partnerNickname
      crn
      taxyId
      panNumber
      email
      agent {
        name
        email
      }
      trakFamilyMfCurrentValue
      trakCobOpportunityValue
      totalMfPansTracked
    }
  }
}
''';

const syncedPanInfo = r'''
  query syncedPanInfo($userId: String!) {
  phaser(userId: $userId) {
    wsyncPansInfo {
      pan
      name
      lastSyncedAt
      mfOpportunity
      mfCurrentValue
    }
  }
}
''';

const String ticobFolioOverview = '''
query ticobFolioOverview(\$panNumber: String, \$userId: String!, \$broker: String!){
  phaser(userId: \$userId) {
    familyMfSchemeOverviews(panNumber: \$panNumber, broker: \$broker) {
      schemeCode
      folioOverviews {
        folioNumber
        investedAmount
        currentValue
        schemeName
        schemeCode
      }
      schemeMeta {
        amc
        amcCode
        schemeName
        schemeCode
        planType
      }
    }
  }
}
''';
