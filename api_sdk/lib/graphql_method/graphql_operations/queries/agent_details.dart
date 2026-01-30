const String agentDetails = r'''
query {
  hydra {
     agent {
      name
      email
      phoneNumber
      isFirstTransactionCompleted
      bankStatus
      dematTncConsentAt
      id
      kycStatus
      segment
    }
  }
}
''';
