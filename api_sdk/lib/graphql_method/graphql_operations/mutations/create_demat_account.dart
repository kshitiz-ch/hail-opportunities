const String createDematAccount = r'''
  mutation createTradingAccount(
    $input: TradingAccountInput!
  ) {
    createTradingAccount(input: $input) {
      imageUrl
    }
  }
''';

const String editDematAccount = r'''
  mutation editTradingAccount(
    $input: UpdateTradingAccountInput!
  ) {
    updateTradingAccount(input: $input) {
      tradingAccount{
        dematId
      }
    }
  }
''';
