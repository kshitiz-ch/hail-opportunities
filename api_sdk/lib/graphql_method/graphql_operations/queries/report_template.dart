const String reportTemplate = r'''
query reportTemplates($userId: String!) {
    entreat(userId: $userId) {
      id
      reportTemplates {
        id
        reportTemplateId
        name
        expiryTime
        description
        canGiveComments
        displayName
        tag
        schema
        reportType
        reportCategory
        groupName
      }
    }
  }
''';
