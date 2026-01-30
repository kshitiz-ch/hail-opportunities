const String deletePartner = r'''
query{
  hydra {
    agentProfileDeleteRequest {
      createdAt
      profileStatus
      agentEmail
      externalId
      status
    }
  }
}
''';
