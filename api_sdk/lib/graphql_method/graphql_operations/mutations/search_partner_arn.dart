const String searchPartnerArn = r'''
  mutation searchPartnerMutation {
    searchPartnerArn {
      partnerArnNode {
        id
        externalId
        arn
        euin
        additionalEuins
        arnValidFrom
        partnerApprovedAt
        isArnActive
        arnValidTill
        status
      }
    }
  }
''';
