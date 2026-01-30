const String createBankAccount =
    r'''mutation createBankAccount($input: CreateBankAccountInput!) {
   createBankAccount(input: $input) {
    bankAccount {
      id
      address
      branch
      bank
      ifsc
      micr
      number
      isVerified
      bankVerifiedName
      bankVerifiedStatus
    }
    }
}''';

const String updateBankAccount =
    r'''mutation updateBankAccount($input: UpdateBankAccountInput!) {
   updateBankAccount(input: $input) {
    bankAccount {
      id
      address
      branch
      bank
      ifsc
      micr
      number
      isVerified
      bankVerifiedName
      bankVerifiedStatus
    }
    }
}''';
