const String partnerArnSelection =
    r'''mutation PartnerArnSelection($externalId: String!, $euin: String!) {

    partnerArnSelection(externalId: $externalId, euin: $euin) {
        partnerArnNode{
              id
              externalId
              arn
              euin
              arnStatus
              status
              additionalEuins
              nameAsPerArn
              addressAsPerArn
              phoneNumberAsPerArn
              arnValidFrom
              partnerApprovedAt
              isArnActive
        }
      }

}''';
