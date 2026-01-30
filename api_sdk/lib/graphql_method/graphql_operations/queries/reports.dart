const String reportList = r'''
query reportList($userId: String!, $templateName: String) {
    entreat(userId: $userId) {
      id
      reports (templateName: $templateName) {
        id
        createdAt
        reportId
        name
        displayName
        expiresAt
        timeRemaining
        requestorCode
        shortLink
        urlToken
        accessToken
        editorTimeRemaining
        editorUrl
      }
    }
  }
''';

const String getReportById = r'''
query getReportById($userId: String!, $id: ID) {
    entreat(userId: $userId) {
      report (id: $id) {
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
        accessToken
        editorTimeRemaining
        editorUrl
        reportGeneratedAt
        status
        error
      }
    }
  }
''';
