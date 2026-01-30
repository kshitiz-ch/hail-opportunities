const String createReport = r'''
mutation createReport($input: CreateReportInputs!) {
  createReport(input: $input) {
    report {
      id
      createdAt
      updatedAt
      reportId
      name
      displayName
      expiresAt
      timeRemaining
      requestorCode
      shortLink
      urlToken
      status
      error
      reportGeneratedAt
      template {
        id
        reportTemplateId
      }
    }
  }
}
''';

const String refreshReportLink = r'''
mutation refreshReportLink($input: GenerateReportShortLinkInput!) {
  generateReportLink(input: $input) {
    report {
      id
      createdAt
      updatedAt
      reportId
      name
      displayName
      expiresAt
      timeRemaining
      requestorCode
      shortLink
      urlToken
      status
      reportGeneratedAt
      error
    }
  }
}
''';
