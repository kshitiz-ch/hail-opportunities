const String wealthyAiUrl = r'''
  query($question: String) {
    partnerWealthyAiProfileRedirectUrl(question: $question) {
      redirectUrl
    }
  }
''';

const String getWealthyAiAccessToken = r'''
query {
  partnerWealthyAiAccessTokens {
    accessToken
    assistantKey
    threadId
    expiresAt
    suggestedQuestions
    isTemporary
  }
}
''';
