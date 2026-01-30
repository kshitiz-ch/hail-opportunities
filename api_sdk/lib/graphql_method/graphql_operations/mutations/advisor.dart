const String createAgentReport = r'''
  mutation createAgentReport(
    $agentId: ID,
    $templateName: String!,
    $context: JSONString
    $regenerate: Boolean
  ) {
    createAgentReport(
      agentId: $agentId,
      templateName: $templateName,
      context: $context
      regenerate: $regenerate
    ) {
      report {
        id
        createdAt
        name
        status
        urlToken
        expiresAt
        requestorCode
        shortLink
        reportGeneratedAt
        reportUrl
      }
    }
  }
''';

const String refreshAgentReportLink = r'''
mutation refreshAgentReportLink($report: ID!) {
  generateAgentReportLink(report: $report) {
    report {
      id
      createdAt
      name
      status
      urlToken
      expiresAt
      requestorCode
      shortLink
      reportGeneratedAt
      reportUrl
    }
  }
}
''';

const String storeEmpanelmentAddress = r'''
  mutation storeEmpanelmentAddress($input: StoreEmpanelmentAddressInput!) {
    storeEmpanelmentAddress(input: $input) {
      empanelmentAddressNode {
        externalId
        line1
        line2
        city
        state
        postalCode
        country
      }
    }
  }
''';

const String payEmpanelmentFee = r'''
  mutation PayEmpanelmentFeesMutation {
    payEmpanelmentFees {
      empanelmentNode {
        id
        status
        fees
        gst
        totalFees
        empanelledAt
        bypassedAt
        orderId
        orderStatus
        thirdPartyOrderId
        orderFinalStageArrivedAt
      }
    }
  }
''';

const String createPartnerNominee = r'''
  mutation createPartnerNominee(
    $agentId: String!,
    $input: [PartnerNomineeInput]!
) {
    createPartnerNominee(
      agentId: $agentId,
      input: $input
    ) {
      nominees {
        id
        name
        dob
        address
        relationship
        guardianName
        guardianAddress
        percentage
      }
    }
  }
''';

const String changeDisplayName = r'''
  mutation changeDisplayName(
    $agentId: String!,
    $displayName: String!
) {
    changeDisplayName(
      agentId: $agentId,
      displayName: $displayName
    ) {
      agent {
        displayName
      }
    }
  }
''';

const String changeReferralCode = r'''
  mutation changeClientReferralCode(
    $agentId: ID!,
    $referralCode: String!
  ) {
    changeClientReferralCode (
      agentId: $agentId,
      referralCode: $referralCode
    ) {
      referralCode
    }
  }
''';

const String callAiAssistant = r'''
mutation callAiAssistant($input: CallAssistantInput!) {
  callAiAssistant(input: $input) {
    value
    extras
    metadata
  }
}
''';

const String agentCommunicationAuthToken = r'''
mutation {
  agentCommunicationAuthToken {
    userToken
  }
}
''';
