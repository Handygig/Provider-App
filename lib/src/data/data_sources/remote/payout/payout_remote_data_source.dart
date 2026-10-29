import 'package:provider_app/src/data/models/payout/bank_account_model.dart';

abstract class PayoutRemoteDataSource {
  Future<List<BankAccountModel>> getBankAccounts();
  Future<BankAccountModel> addBankAccount({
    required String bankName,
    required String branchName,
    required String accountHolderName,
    required String accountNumber,
    String? routingNumber,
    String? swiftCode,
    bool isDefault = false,
  });
  Future<void> setPrimaryBankAccount(String accountId);
  Future<void> deleteBankAccount(String accountId);
}
