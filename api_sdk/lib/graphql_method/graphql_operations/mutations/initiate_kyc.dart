const String initiateKyc = r'''
mutation InitiateKYC($input: InitiateKYCInput!) {
  initiatePartnerKyc(input: $input) {
    kycRequest{
      id
      externalId
      agent {
        id
        name
        email
        phoneNumber
        isFirstTransactionCompleted
        bankStatus
        dematTncConsentAt
        kycStatus
        segment
        panNumber
        displayName
        agentReferralData {
          referralUrl
        }
        manager {
          id
          name
          phoneNumber
        }
      }
      phoneNumber
      name
      tpRequestId
      tpRequestValidTill
      kycStatus
      tpAccessToken
      tpAccessTokenValidTill
    }
    kycUrl
  }
}
  ''';
