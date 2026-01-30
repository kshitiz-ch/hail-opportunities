const createPartnerUpdateRequest = r'''
  mutation create($updateField: String) {
  createPartnerFieldUpdateRequest(updateField: $updateField) {
      changeRequestUrl
    }
  }
''';
