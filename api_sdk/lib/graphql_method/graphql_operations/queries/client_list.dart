const String clientList = r'''
   query leads($recentLeads: Boolean, $q: String, $limit: Int, $offset: Int, $requestAgentId: String) {
    hydra {
      id
      customerCount
      clients(recentLeads: $recentLeads, q: $q, limit: $limit, offset: $offset, requestAgentId: $requestAgentId) {
      id
      taxyId
      email
      agent {
        id
        name
        email
        externalId
      }
      mfEmail
      phoneNumber
      name
      dob
      accountId
      hasMandate 
      firstTransactionAt 
      source 
      wealthyInvestedValue 
      wealthyIrr 
      wealthyCurrentValue 
      trakMfIrr 
      totalFamilyCurrentValue 
      totalSelfCurrentValue
      frequentSeenLocation 
      lastSeenAt 
      investorActivatedAt 
      privilegeActivatedAt  
      currentAgentAssignedAt 
      sourceType 
      investmentCurrentValue 
      loanCurrentValue 
      insuranceCurrentValue 
      unlistedStocksCurrentValue
      currentMonthPipelinedRevenue
      agentTotalRevenue
      totalNoOfInsurance
      emailVerified
      phoneVerified
      crn
      panNumber
      panUsageType
    }
    }
  }
''';

const String employeesClientCount = r'''
   query clientsCount ($agentExternalId: String) {
    hydra {
      employee(agentExternalId: $agentExternalId) {
        customersCount
      }
    }
  }
''';

const String clientsCount = r'''
   query clientsCount {
    hydra {
      id
      customerCount
    }
  }
''';

const String clientDetails = r'''
   query clientDetails($id: ID, $agentId: ID) {
    hydra {
      id
      customerCount
      client(id: $id, agentId: $agentId) {
        id
        taxyId
        email
        name
        mfEmail
        phoneNumber
        emailVerified
        phoneVerified
      }
    }
  }
''';

const String clientLoginDetails = r'''
   query clientDetails($userId: String) {
    hagrid(userId: $userId) {
      wealthyMfProfile {
        email
        emailVerifiedAt
      }

      wealthyUserDetailsPrefill(onBoardProduct: "MF") {
        firstName
        lastName
        email
        emailVerifiedAt
        phoneNumber
        phoneVerifiedAt
      }
    }
  }
''';
