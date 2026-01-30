const String brokingClientOnboarding = r'''
  query brokingClientOnboarding($input: UserBrokingProfileQueryInputArgs!, $filters: UserBrokingProfileFilter) {
    userBrokingProfileData(input: $input, filters: $filters){
      count
      profileAndKycData {
        name
        agentId
        agentName
        ucc
        phoneNumber
        frontendStatus
        isFnoEnabled
        isTradingEnabled
        kycStatus
        updatedAt
        createdAt
        userId
        email
      }
    }
  }
''';

const String brokingClientActivity = r'''
  query brokingClientActivity($input: AgentBrokingTransactionSummaryInputArgs!, $filters: AgentTransactionSummaryFilter) {
    agentBrokingTransactionSummaryData(input: $input, filters: $filters) {
      count
      userTransactionSummaryData {
        userId
        ucc
        name
        agentId
        totalPayin
        totalPayout
        brokerageFno
        brokerageNse
        brokerageTotal
      }
    }
  }
''';

String brokingDetails = r'''
  query partnersTotalMetric($agentExternalIdList: [String], $date: String) {
    delta(userId: "") {
      partnersTotalMetric (agentExternalIdList: $agentExternalIdList, date: $date) {
       brokingDetails
      }
    }
  }
''';

String partnerApStatus = r'''
query partnerApStatus($agentId: ID!) {
  hydra{
    partnerApStatus(agentId: $agentId){
      NSECm NSEFno BSECm BSEFno
    }
  }
}
''';

String brokingPlans = r'''
  query brokingPlans {
    partnerAvailableWealthyBrokingApPlans {
      openingCharges
      amcCharges
      planName
      planCode
      isWealthyDefault
      segmentCharges {
        id
        createdAt
        updatedAt
        brokerageProfileName
        templateName
        tradeSegment
        chargeType
        chargeValueType
        value
        maxBrokerage
        description
      }
    }

    partnerWealthyBrokingApData{
      apId
      apRegistrationNo
      apName
      panNumber
      externalAgentId
      defaultBrokeragePlan
    }
  }
''';
